script_trigger_type = 'On Connect';

function showWhereForUser(targetUser)
    if targetUser == nil then
        writeChat('ERROR: No user found');
        return;
    end
    
    writeChat('Finding position...');
    wait(0.1);
    
    local pos = targetUser.getPosition();
    local app = getApp();
    
    -- Also show as percentage
    local percent = app.convertPositionToPercent(pos.x, pos.y);
    
    local message = '📍 ' .. targetUser.displayName .. ' | ';
    message = message .. 'X:' .. math.floor(pos.x) .. ' ';
    message = message .. 'Y:' .. math.floor(pos.y) .. ' ';
    message = message .. '(Percent: ' .. math.floor(percent.x * 100) .. '%, ' .. math.floor(percent.y * 100) .. '%)';
    
    writeChat(message);
end

function onChatMessage(user, string_message)
    if user == nil or string_message == nil then
        return;
    end
    
    local msg = string.lower(string_message);
    if msg == '!where' or msg == '!whereami' then
        showWhereForUser(user);
    end
end

return function()
    if commandUser ~= nil then
        showWhereForUser(commandUser);
        return;
    end
    
    addEvent('chatMessage', 'onChatMessage');
    keepAlive();
end