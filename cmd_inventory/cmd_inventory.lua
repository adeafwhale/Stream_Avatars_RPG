return function()
    if commandUser == nil then
        writeChat('ERROR: No user found');
        return;
    end
    
    writeChat('📦 Checking inventory...');
    wait(0.1);
    
    -- Load player inventory
    local inventory = commandUser.loadUserData('rpg_inventory');
    
    if inventory == nil then
        -- Create new inventory
        inventory = {
            wood = 0,
            stone = 0,
            ore = 0,
            fiber = 0,
            fish = 0,
            potion_small = 0,
            potion_medium = 0,
            potion_large = 0
        };
        commandUser.saveUserData('rpg_inventory', inventory);
        writeChat(commandUser.displayName .. ' - New inventory created!');
    else
        if inventory.wood == nil then inventory.wood = 0 end
        if inventory.stone == nil then inventory.stone = 0 end
        if inventory.ore == nil then inventory.ore = 0 end
        if inventory.fiber == nil then inventory.fiber = 0 end
        if inventory.fish == nil then inventory.fish = 0 end
        if inventory.potion_small == nil then inventory.potion_small = 0 end
        if inventory.potion_medium == nil then inventory.potion_medium = 0 end
        if inventory.potion_large == nil then inventory.potion_large = 0 end
    end
    
    -- Show inventory
    local message = '📦 ' .. commandUser.displayName .. ' | ';
    message = message .. 'Wood:' .. inventory.wood .. ' ';
    message = message .. 'Stone:' .. inventory.stone .. ' ';
    message = message .. 'Ore:' .. inventory.ore .. ' ';
    message = message .. 'Fiber:' .. inventory.fiber .. ' ';
    message = message .. 'Fish:' .. inventory.fish .. ' ';
    message = message .. 'Potion(S):' .. inventory.potion_small .. ' ';
    message = message .. 'Potion(M):' .. inventory.potion_medium .. ' ';
    message = message .. 'Potion(L):' .. inventory.potion_large;
    
    writeChat(message);
end
