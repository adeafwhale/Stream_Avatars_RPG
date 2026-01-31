script_trigger_type = 'On Connect';

-- =========================
-- CONFIG
-- =========================
DANGER_MIN_ID = 1
DANGER_MAX_ID = 75

-- Danger stays true if a user has touched a danger block within this many seconds
DANGER_TOUCH_TIMEOUT = 2.0

-- Per-user throttle so scriptable block triggers don't melt CPU
DANGER_TOUCH_COOLDOWN = 0.35

-- =========================
-- DEBUG HELPERS
-- =========================
local function dbg(msg)
    log('[RPG] ' .. tostring(msg))
end

-- =========================
-- FAST RUNTIME TABLES (IN MEMORY)
-- =========================
-- DO NOT save these to userData (performance killer)
local lastDangerTouch = {}   -- user.id -> os.clock()
local lastDangerEvent = {}   -- user.id -> os.clock()

local function isInDangerNow(user)
    local t = lastDangerTouch[user.id] or 0
    return (t > 0) and ((os.clock() - t) < DANGER_TOUCH_TIMEOUT)
end

-- =========================
-- GEAR -> STATS
-- =========================
local function getRarityBonus(gearName)
    if not gearName or gearName == '' or gearName == 'none' then return 0 end
    if string.find(gearName, 'mythic') then return 10 end
    if string.find(gearName, 'legendary') then return 8 end
    if string.find(gearName, 'special') then return 6 end
    if string.find(gearName, 'epic') then return 5 end
    if string.find(gearName, 'rare') then return 3 end
    if string.find(gearName, 'uncommon') then return 2 end
    if string.find(gearName, 'common') then return 1 end
    return 0
end

local function getGearStats(gearName)
    local stats = { attack = 0, defense = 0, gathering = 0, luck = 0, health = 0 }
    if gearName == nil or gearName == '' or gearName == 'none' then return stats end

    local rarityBonus = getRarityBonus(gearName)

    if string.find(gearName, 'weapon_') then
        stats.attack = rarityBonus
        if string.find(gearName, 'claymore') then
            stats.attack = stats.attack + 2
        elseif string.find(gearName, 'shield') then
            stats.defense = rarityBonus
            stats.attack = 0
        end
    elseif string.find(gearName, 'tool_') then
        stats.gathering = rarityBonus
    elseif string.find(gearName, 'outfit_') then
        stats.defense = rarityBonus
        stats.health = rarityBonus * 10
    elseif string.find(gearName, 'head_') then
        stats.luck = rarityBonus
        stats.defense = math.floor(rarityBonus / 2)
    elseif string.find(gearName, 'pet_') then
        stats.luck = rarityBonus
        stats.attack = math.floor(rarityBonus / 2)
    end

    return stats
end

local function ensureBaseStats(user)
    local data = user.loadUserData('rpg_stats')
    if data == nil then
        data = { attack = 0, defense = 0, gathering = 0, luck = 0, health = 100 }
        user.saveUserData('rpg_stats', data)
    end
    return data
end

local function resolveStats(user)
    local base = ensureBaseStats(user)
    local equipped = user.getGear()

    local bonus = { attack = 0, defense = 0, gathering = 0, luck = 0, health = 0 }
    for slot, gearName in pairs(equipped) do
        local s = getGearStats(gearName)
        bonus.attack = bonus.attack + s.attack
        bonus.defense = bonus.defense + s.defense
        bonus.gathering = bonus.gathering + s.gathering
        bonus.luck = bonus.luck + s.luck
        bonus.health = bonus.health + s.health
    end

    return {
        attack = base.attack + bonus.attack,
        defense = base.defense + bonus.defense,
        gathering = base.gathering + bonus.gathering,
        luck = base.luck + bonus.luck,
        health = base.health + bonus.health
    }
end

-- =========================
-- PLAYER STATE (ghost only persisted)
-- =========================
local function ensureState(user)
    local st = user.loadUserData('rpg_state')
    if st == nil then
        st = { isGhost = false, ghostUntil = 0 }
        user.saveUserData('rpg_state', st)
    end
    return st
end

local function saveState(user, st)
    user.saveUserData('rpg_state', st)
end

local function refreshGhostIfExpired(user, st)
    if st.isGhost and st.ghostUntil ~= 0 and os.time() >= st.ghostUntil then
        st.isGhost = false
        st.ghostUntil = 0
        saveState(user, st)
        writeChat('✨ ' .. user.displayName .. ' is alive again!')
    end
end

local function setGhost(user, seconds)
    local st = ensureState(user)
    st.isGhost = true
    st.ghostUntil = (seconds and seconds > 0) and (os.time() + seconds) or 0
    saveState(user, st)

    -- also clear danger in memory
    lastDangerTouch[user.id] = 0
    lastDangerEvent[user.id] = 0
end

local function revive(user)
    local st = ensureState(user)
    st.isGhost = false
    st.ghostUntil = 0
    saveState(user, st)
end

-- =========================
-- ZONES (danger blocks 1-75) - THROTTLED + IN MEMORY
-- =========================
local function isDangerBlock(id)
    return id and id >= DANGER_MIN_ID and id <= DANGER_MAX_ID
end

function onZoneTrigger(user, block)
    if user == nil or block == nil then return end
    if not isDangerBlock(block.id) then return end

    local st = ensureState(user)
    refreshGhostIfExpired(user, st)

    if st.isGhost then
        -- IMPORTANT: no writeChat spam here
        return
    end

    local now = os.clock()
    local prev = lastDangerEvent[user.id] or 0

    -- throttle
    if (now - prev) < DANGER_TOUCH_COOLDOWN then
        return
    end

    lastDangerEvent[user.id] = now
    lastDangerTouch[user.id] = now
end

-- =========================
-- WHERE (POSITION) COMMAND (YOUR EDIT)
-- =========================
function showWhereForUser(targetUser)
    if targetUser == nil then
        writeChat('ERROR: No user found')
        return
    end

    writeChat('Finding position...')
    wait(0.1)

    local pos = targetUser.getPosition()
    local app = getApp()

    -- Some builds may not support convertPositionToPercent (guard it)
    local percentText = ''
    if app ~= nil and app.convertPositionToPercent ~= nil then
        local percent = app.convertPositionToPercent(pos.x, pos.y)
        percentText = ' (Percent: ' .. math.floor(percent.x * 100) .. '%, ' .. math.floor(percent.y * 100) .. '%)'
    end

    local message = '📍 ' .. targetUser.displayName .. ' | '
    message = message .. 'X:' .. math.floor(pos.x) .. ' '
    message = message .. 'Y:' .. math.floor(pos.y) .. percentText

    writeChat(message)
end

-- =========================
-- COMMANDS
-- =========================
local function cmdStats(user)
    local s = resolveStats(user)
    writeChat('⚔️ ' .. user.displayName ..
        ' | ATK:' .. s.attack ..
        ' DEF:' .. s.defense ..
        ' GATHER:' .. s.gathering ..
        ' LUCK:' .. s.luck ..
        ' HP:' .. s.health)
end

local function cmdWhere(user)
    local st = ensureState(user)
    refreshGhostIfExpired(user, st)

    writeChat('🧭 ' .. user.displayName ..
        ' | danger=' .. tostring(isInDangerNow(user)) ..
        ' ghost=' .. tostring(st.isGhost))
end

local function cmdGhost(user)
    setGhost(user, 0)
    writeChat('👻 ' .. user.displayName .. ' is now a ghost.')
end

local function cmdRevive(user)
    revive(user)
    writeChat('✨ ' .. user.displayName .. ' revived.')
end

function onChatMessage(user, string_message)
    if user == nil or string_message == nil then return end
    local msg = string.lower(string_message)

    if msg == '!stats' then return cmdStats(user) end
    if msg == '!where' then return cmdWhere(user) end

    -- your position-style command (choose whichever you prefer)
    if msg == '!whereami' or msg == '!pos' then
        showWhereForUser(user)
        return
    end

    if msg == '!ghostme' then return cmdGhost(user) end
    if msg == '!reviveme' then return cmdRevive(user) end
end

-- =========================
-- ENTRY
-- =========================
return function()
    dbg('Loaded. Danger blocks ' .. DANGER_MIN_ID .. '-' .. DANGER_MAX_ID)

    -- If this script was run as a "command script" (commandUser is set),
    -- show position for that user and exit (your screenshot logic)
    if commandUser ~= nil then
        showWhereForUser(commandUser)
        return
    end

    addEvent('chatMessage', 'onChatMessage')
    addEvent('scriptableBlocks', 'onZoneTrigger')

    keepAlive()
end
