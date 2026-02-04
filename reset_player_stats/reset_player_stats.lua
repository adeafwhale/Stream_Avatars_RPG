-- Quick script to reset a player's attack stat (or all stats)
-- To use: Set this as "On Command Call" with command name like !resetstats

return function()
    local targetUsername = 'tonythebard'; -- Change this to target different players
    
    local user = getUser(targetUsername);
    if user == nil then
        writeChat('User ' .. targetUsername .. ' not found!');
        return;
    end
    
    -- Load current stats
    local playerData = user.loadUserData('rpg_stats');
    
    if playerData == nil then
        writeChat(targetUsername .. ' has no RPG stats yet.');
        return;
    end
    
    -- Show current stats
    writeChat('Current stats for ' .. targetUsername .. ':');
    writeChat('Attack: ' .. (playerData.attack or 0));
    writeChat('Defense: ' .. (playerData.defense or 0));
    writeChat('Health: ' .. (playerData.health or 100));
    writeChat('Luck: ' .. (playerData.luck or 0));
    writeChat('Accuracy: ' .. (playerData.accuracy or 80));
    writeChat('Dodge: ' .. (playerData.dodge or 5));
    
    -- Reset attack to 0
    playerData.attack = 0;
    
    -- Uncomment below to reset all stats:
    -- playerData.attack = 0;
    -- playerData.defense = 0;
    -- playerData.health = 100;
    -- playerData.luck = 0;
    -- playerData.accuracy = 80;
    -- playerData.dodge = 5;
    
    -- Save the updated stats
    user.saveUserData('rpg_stats', playerData);
    
    writeChat('Reset attack stat for ' .. targetUsername .. ' to 0');
end
