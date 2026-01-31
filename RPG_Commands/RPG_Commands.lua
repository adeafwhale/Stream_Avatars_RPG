script_trigger_type = 'On Connect';

local function cmdStats(user)
    local s = RPG.resolveStats(user)
    writeChat('⚔️ ' .. user.displayName ..
        ' ATK:' .. s.attack ..
        ' DEF:' .. s.defense ..
        ' GATHER:' .. s.gathering ..
        ' LUCK:' .. s.luck ..
        ' HP:' .. s.health)
end

local function cmdGhost(user)
    RPG.setGhost(user, 0) -- 0 = until manually revived
    writeChat('👻 ' .. user.displayName .. ' is now a ghost (can’t enter danger).')
end

local function cmdRevive(user)
    RPG.revive(user)
    writeChat('✨ ' .. user.displayName .. ' is alive again.')
end

local function cmdWhere(user)
    local st = RPG.getState(user)
    writeChat('📍 ' .. user.displayName ..
        ' danger=' .. tostring(st.inDanger) ..
        ' ghost=' .. tostring(st.isGhost))
end

function onChatMessage(user, message)
    if user == nil or message == nil then return end
    local msg = string.lower(message)

    if msg == '!stats' then return cmdStats(user) end
    if msg == '!where' then return cmdWhere(user) end

    -- admin-ish testing commands (you can restrict later)
    if msg == '!ghostme' then return cmdGhost(user) end
    if msg == '!reviveme' then return cmdRevive(user) end
end

return function()
    addEvent('chatMessage', 'onChatMessage')
    keepAlive()
end
