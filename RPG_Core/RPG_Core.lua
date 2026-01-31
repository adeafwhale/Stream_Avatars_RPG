script_trigger_type = 'On Connect';

-- =========================
-- RPG CORE: Stats + State
-- =========================

RPG = RPG or {}
RPG.VERSION = "0.1"

-- ---------- Gear -> Stats ----------
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

function RPG.getGearStats(gearName)
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

function RPG.resolveStats(user)
    local base = ensureBaseStats(user)
    local equipped = user.getGear()

    local bonus = { attack = 0, defense = 0, gathering = 0, luck = 0, health = 0 }
    for slot, gearName in pairs(equipped) do
        local s = RPG.getGearStats(gearName)
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

-- ---------- Player State ----------
local function ensureState(user)
    local st = user.loadUserData('rpg_state')
    if st == nil then
        st = { isGhost = false, ghostUntil = 0, inDanger = false, lastDangerTouch = 0 }
        user.saveUserData('rpg_state', st)
    end
    return st
end

local function saveState(user, st)
    user.saveUserData('rpg_state', st)
end

function RPG.getState(user)
    local st = ensureState(user)
    -- expire ghost if timed
    if st.isGhost and st.ghostUntil ~= 0 and os.time() >= st.ghostUntil then
        st.isGhost = false
        st.ghostUntil = 0
        saveState(user, st)
    end
    return st
end

function RPG.setGhost(user, seconds)
    local st = ensureState(user)
    st.isGhost = true
    st.inDanger = false
    st.lastDangerTouch = 0
    st.ghostUntil = (seconds and seconds > 0) and (os.time() + seconds) or 0
    saveState(user, st)
end

function RPG.revive(user)
    local st = ensureState(user)
    st.isGhost = false
    st.ghostUntil = 0
    saveState(user, st)
end

function RPG.setDanger(user, isDanger)
    local st = ensureState(user)
    st.inDanger = isDanger
    saveState(user, st)
end

function RPG.touchDanger(user)
    local st = ensureState(user)
    st.inDanger = true
    st.lastDangerTouch = os.clock()
    saveState(user, st)
end

return function()
    -- core provides functions; keepAlive so other scripts can call them
    keepAlive()
end
log("RPG core loaded " .. RPG.VERSION)

