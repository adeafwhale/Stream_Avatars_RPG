return function()
    if commandUser == nil then
        writeChat('ERROR: No user found');
        return;
    end
    
    writeChat('🪵 Adding wood...');
    wait(0.1);
    
    -- Load inventory
    local inventory = commandUser.loadUserData('rpg_inventory');
    
    if inventory == nil then
        inventory = {
            wood = 0,
            stone = 0,
            ore = 0,
            fiber = 0,
            fish = 0
        };
    end
    
    -- Add 5 wood
    inventory.wood = inventory.wood + 5;
    
    -- Save
    commandUser.saveUserData('rpg_inventory', inventory);
    
    writeChat('✅ +5 Wood! Total: ' .. inventory.wood);
end
