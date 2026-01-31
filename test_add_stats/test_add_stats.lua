return function()z`
    writeChat('✨ Processing...');
    
    -- Tiny delay to let Stream Avatars "catch up"
    wait(0.1);
    
    if commandUser == nil then
        writeChat('ERROR: No user found');
        return;
    end
    
    local playerData = commandUser.loadUserData('rpg_stats');
    
    if playerData == nil then
        writeChat('ERROR: Use !stats first to initialize');
        return;
    end
    
    -- Add 5 attack
    playerData.attack = playerData.attack + 5;
    
    -- Save updated stats
    commandUser.saveUserData('rpg_stats', playerData);
    
    -- Show updated stats
    local message = '⚔️ ' .. commandUser.displayName .. ' | ';
    message = message .. 'ATK:' .. playerData.attack .. ' ';
    message = message .. 'DEF:' .. playerData.defense .. ' ';
    message = message .. 'GATHER:' .. playerData.gathering .. ' ';
    message = message .. 'LUCK:' .. playerData.luck .. ' ';
    message = message .. 'HP:' .. playerData.health;
    
    writeChat(message);
end