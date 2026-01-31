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
            fish = 0
        };
        commandUser.saveUserData('rpg_inventory', inventory);
        writeChat(commandUser.displayName .. ' - New inventory created!');
    end
    
    -- Show inventory
    local message = '📦 ' .. commandUser.displayName .. ' | ';
    message = message .. 'Wood:' .. inventory.wood .. ' ';
    message = message .. 'Stone:' .. inventory.stone .. ' ';
    message = message .. 'Ore:' .. inventory.ore .. ' ';
    message = message .. 'Fiber:' .. inventory.fiber .. ' ';
    message = message .. 'Fish:' .. inventory.fish;
    
    writeChat(message);
end
