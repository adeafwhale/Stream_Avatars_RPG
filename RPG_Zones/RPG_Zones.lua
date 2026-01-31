script_trigger_type = 'On Connect';

DANGER_MIN_ID = 1
DANGER_MAX_ID = 75
DANGER_TOUCH_TIMEOUT = 2.0

local function isDangerBlock(id)
    return id and id >= DANGER_MIN_ID and id <= DANGER_MAX_ID
end

function onZoneTrigger(user, block)
    if user == nil or block == nil then return end
    if not isDangerBlock(block.id) then return end

    local st = RPG.getState(user)
    if st.isGhost then
        RPG.setDanger(user, false)
        writeChat('🚫 ' .. user.displayName .. ' is a ghost and can’t enter danger.')
        return
    end

    RPG.touchDanger(user)
end

function zoneTick()
    local users = getUsers()
    if users == nil then return end

    for _, u in pairs(users) do
        local st = RPG.getState(u)

        if st.inDanger then
            local last = st.lastDangerTouch or 0
            if last > 0 and (os.clock() - last) >= DANGER_TOUCH_TIMEOUT then
                RPG.setDanger(u, false)
                -- optional: writeChat(u.displayName .. ' is safe now.')
            end
        end
    end
end

return function()
    addEvent('scriptableBlocks', 'onZoneTrigger')

    while true do
        zoneTick()
        wait(0.25)
    end
end
