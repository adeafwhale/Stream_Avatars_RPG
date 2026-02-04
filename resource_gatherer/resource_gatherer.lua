script_trigger_type = 'On Connect';

resourceUsers = {};
resourceSpawnPoints = {};

function defineResourceSpawns()
    local points = {};
    local app = getApp();
    local res = app.getResolution();
    
    local spawnY = 110;
    local screenWidth = res.x;
    
    -- Wood spawns (left side)
    table.insert(points, {
        type = 'wood',
        resourceName = 'Resource_Wood_1',
        x = screenWidth * 0.2,
        y = spawnY,
        respawnTime = 5
    });
    
    table.insert(points, {
        type = 'wood',
        resourceName = 'Resource_Wood_2',
        x = screenWidth * 0.25,
        y = spawnY,
        respawnTime = 5
    });
    
    -- Ore spawns (right side)
    table.insert(points, {
        type = 'ore',
        resourceName = 'Resource_Ore_1',
        x = screenWidth * 0.85,
        y = spawnY,
        respawnTime = 8
    });
    
    table.insert(points, {
        type = 'ore',
        resourceName = 'Resource_Ore_2',
        x = screenWidth * 0.8,
        y = spawnY,
        respawnTime = 8
    });
    
    --[[ DISABLED - Stone and Fiber
    -- Stone spawns (right side)
    table.insert(points, {
        type = 'stone',
        resourceName = 'Resource_Stone_1',
        x = screenWidth * 0.75,
        y = spawnY,
        respawnTime = 45
    });
    
    table.insert(points, {
        type = 'stone',
        resourceName = 'Resource_Stone_2',
        x = screenWidth * 0.7,
        y = spawnY,
        respawnTime = 45
    });
    
    -- Fiber spawns (bottom center)
    table.insert(points, {
        type = 'fiber',
        resourceName = 'Resource_Fiber_1',
        x = screenWidth * 0.5,
        y = spawnY,
        respawnTime = 30
    });
    
    table.insert(points, {
        type = 'fiber',
        resourceName = 'Resource_Fiber_2',
        x = screenWidth * 0.6,
        y = spawnY,
        respawnTime = 30
    });
    ]]--
    
    resourceSpawnPoints = points;
    set('resourceSpawnPoints', points);
end

function getResourceSpawnPointByName(resourceName)
    if resourceName == nil then
        return nil;
    end

    for i, spawnPoint in ipairs(resourceSpawnPoints) do
        if spawnPoint.resourceName == resourceName then
            return spawnPoint, i;
        end
    end

    return nil;
end

function spawnResourceAt(spawnPointIndex)
    local spawnPoint = resourceSpawnPoints[spawnPointIndex];
    if spawnPoint == nil then
        return;
    end
    
    -- Use the built-in spawn command (same as enemy_spawner)
    runCommand('!spawn ' .. spawnPoint.resourceName, true);
    
    wait(1);
    
    -- Get the spawned resource
    local resourceUser = getUser(spawnPoint.resourceName);
    
    if resourceUser == nil then
        return;
    end

    -- Tag this user as a resource IMMEDIATELY (persists per user)
    -- Do this BEFORE changing avatar so other systems don't detect it as a player
    resourceUser.saveUserData('resource_tag', {
        isResource = true,
        resourceType = spawnPoint.type,
        source = 'resource_gatherer'
    });

    -- Use setTemporaryAvatar to set the resource avatar (set to 0 for permanent until app restart)
    local avatarName = 'resource_' .. spawnPoint.type;
    resourceUser.setTemporaryAvatar(avatarName, 0);
    
    -- Position the resource
    resourceUser.setPosition(spawnPoint.x, spawnPoint.y);
    
    -- Store resource data
    local resources = get('resourceUsers');
    if resources == nil then
        resources = {};
    end
    
    table.insert(resources, {
        resourceName = spawnPoint.resourceName,
        type = spawnPoint.type,
        spawnPointIndex = spawnPointIndex,
        respawnTime = spawnPoint.respawnTime,
        isRespawning = false
    });
    
    set('resourceUsers', resources);
end

function isResourceUser(user)
    if user == nil then
        return false;
    end

    local tag = user.loadUserData('resource_tag');
    if tag ~= nil and tag.isResource == true then
        return true;
    end

    return false;
end

function isEnemyUser(user)
    if user == nil then
        return false;
    end

    local tag = user.loadUserData('enemy_tag');
    if tag ~= nil and tag.isEnemy == true then
        return true;
    end

    return false;
end

function hasToolEquipped(user)
    if user == nil then
        return false;
    end

    local equippedGear = user.getGear();
    if equippedGear == nil then
        return false;
    end

    for _, itemName in pairs(equippedGear) do
        if type(itemName) == 'string' and string.find(itemName, 'tools_') ~= nil then
            return true;
        end
    end

    return false;
end

function onResourceAvatarSpawned(user)
    if user == nil then
        return;
    end

    if not isResourceUser(user) then
        return;
    end

    if getBackground() ~= 'brothers_crossing' then
        return;
    end

    local spawnPoint, index = getResourceSpawnPointByName(user.displayName);
    if spawnPoint == nil then
        return;
    end

    wait(0.15);
    -- Enforce position lock
    user.setPosition(spawnPoint.x, spawnPoint.y);
    
    -- Re-hide nametag in case it reset
    user.override_nametag = '';
end

function maintainResourcePositions()
    -- This runs continuously to keep resources in their spawn locations
    while true do
        yield();

        local resources = get('resourceUsers');
        if resources ~= nil and #resources > 0 then
            for _, resourceData in ipairs(resources) do
                local resource = getUser(resourceData.resourceName);
                if resource ~= nil then
                    local spawnPoint = resourceSpawnPoints[resourceData.spawnPointIndex];
                    if spawnPoint ~= nil then
                        local pos = resource.getPosition();
                        if math.abs(pos.x - spawnPoint.x) > 5 or math.abs(pos.y - spawnPoint.y) > 5 then
                            resource.setPosition(spawnPoint.x, spawnPoint.y);
                        end
                    end
                end
            end
        end

        wait(0.5);
    end
end

function checkProximityForHarvest()
    -- This runs continuously to check for nearby resources
    while true do
        yield();
        
        local resources = get('resourceUsers');
        if resources == nil or #resources == 0 then
            wait(1);
        else
            local allUsers = getUsers();
            
            for _, player in ipairs(allUsers) do
                -- Skip resources and enemies (tagged users)
                if not isResourceUser(player) and not isEnemyUser(player) then
                    local playerPos = player.getPosition();
                    
                    -- Check if player is in active combat
                    local inCombat = player.loadUserData('in_combat');
                    if inCombat == true then
                        goto skip_player; -- Player in active combat, skip harvesting
                    end

                    -- Require a tool to harvest resources
                    if not hasToolEquipped(player) then
                        goto skip_player; -- No tool equipped, skip harvesting
                    end
                    
                    for i, resourceData in ipairs(resources) do
                        local resource = getUser(resourceData.resourceName);
                        
                        if resource ~= nil then
                            -- Skip resources that are currently respawning
                            if resourceData.isRespawning == true then
                                goto continue;
                            end
                            
                            local resourcePos = resource.getPosition();
                            local dx = playerPos.x - resourcePos.x;
                            local dy = playerPos.y - resourcePos.y;
                            
                            -- For wood, require close X-axis alignment (trunk center) but allow more Y distance
                            -- For ore, use standard distance calculation
                            local canHarvest = false;
                            
                            if resourceData.type == 'wood' then
                                -- Must be within 30px horizontally (aligned with trunk) AND 100px vertically
                                if math.abs(dx) < 30 and math.abs(dy) < 100 then
                                    canHarvest = true;
                                end
                            elseif resourceData.type == 'ore' then
                                local distance = math.sqrt(dx * dx + dy * dy);
                                if distance < 30 then
                                    canHarvest = true;
                                end
                            else
                                local distance = math.sqrt(dx * dx + dy * dy);
                                if distance < 100 then
                                    canHarvest = true;
                                end
                            end

                            -- If within range, start harvest
                            if canHarvest then
                                writeChat('🌲 Harvesting ' .. resourceData.type .. '...');
                                
                                -- Mark as respawning
                                resourceData.isRespawning = true;
                                resources[i] = resourceData;
                                set('resourceUsers', resources);
                                
                                -- Start harvest
                                performHarvest(player, resourceData);
                                
                                goto continue;
                            end
                        end
                        
                        ::continue::
                    end
                    
                    ::skip_player::
                end
            end
            
            wait(0.5);
        end
    end
end

function performHarvest(player, resourceData)
    if player == nil or resourceData == nil then
        return;
    end
    
    local resource = getUser(resourceData.resourceName);
    if resource == nil then
        return;
    end
    
    -- Set harvesting flag to prevent combat initiation
    player.saveUserData('is_harvesting', true);
    
    -- Player plays animation based on resource type
    if resourceData.type == 'ore' then
        player.runCommand('!pick');
    elseif resourceData.type == 'wood' then
        player.runCommand('!chop');
    else
        player.runCommand('!swing');
    end
    
    -- Resource plays harvesting animation
    resource.runCommand('!harvesting');
    
    -- Wait for harvest animation to complete (5 seconds)
    wait(5);
    
    -- Update player inventory
    local inventory = player.loadUserData('rpg_inventory');
    if inventory == nil then
        inventory = {
            wood = 0,
            stone = 0,
            ore = 0,
            fiber = 0,
            fish = 0
        };
    end
    
    inventory[resourceData.type] = inventory[resourceData.type] + 1;
    player.saveUserData('rpg_inventory', inventory);
    
    -- Debug message
    writeChat('✨ ' .. player.displayName .. ' harvested ' .. resourceData.type .. '! (Total: ' .. inventory[resourceData.type] .. ')');
    
    -- Resource plays destroyed animation
    resource.runCommand('!destroyed');
    
    wait(2);
    
    -- Move resource off-screen instead of deleting (prevents explode animation)
    resource.setPosition(-1000, -1000);
    
        -- Clear harvesting flag
        player.saveUserData('is_harvesting', false);
    
    -- Start respawn timer
    set('respawn_resource_index', resourceData.spawnPointIndex);
    set('respawn_resource_delay', resourceData.respawnTime);
    set('respawn_resource_name', resourceData.resourceName);
    async('respawnResourceAfterDelay');
end

function respawnResourceAfterDelay()
    local spawnIndex = get('respawn_resource_index');
    local delay = get('respawn_resource_delay');
    local resourceName = get('respawn_resource_name');
    
    if spawnIndex == nil or delay == nil then
        return;
    end
    
    wait(delay);
    
    -- Check if we're still on the correct background before respawning
    local currentBackground = getBackground();
    if currentBackground ~= 'brothers_crossing' then
        return; -- Don't respawn if we switched backgrounds
    end
    
    -- Remove respawning flag and re-enable for harvesting
    local resources = get('resourceUsers');
    if resources ~= nil then
        for i, r in ipairs(resources) do
            if r.resourceName == resourceName then
                r.isRespawning = false;
                resources[i] = r;
                set('resourceUsers', resources);
                break;
            end
        end
    end
    
    -- Now reposition the resource at the designated location
    local spawnPoint = resourceSpawnPoints[spawnIndex];
    if spawnPoint ~= nil then
        local resource = getUser(resourceName);
        if resource ~= nil then
            resource.setPosition(spawnPoint.x, spawnPoint.y);
        end
    end
end

function despawnAllResources()
    -- Check if already despawning to prevent concurrent calls
    local isCurrentlyDespawning = get('despawning_in_progress');
    if isCurrentlyDespawning then
        return; -- Already despawning, skip
    end
    
    local resources = get('resourceUsers');
    if resources == nil or #resources == 0 then
        return; -- Nothing to despawn
    end
    
    -- Set flag to prevent concurrent despawn operations
    set('despawning_in_progress', true);
    
    local app = getApp();
    
    -- Clear the resource list first to prevent respawn timers from re-adding them
    set('resourceUsers', {});
    
    -- Delete the users completely
    for _, resourceData in ipairs(resources) do
        local resource = getUser(resourceData.resourceName);
        if resource ~= nil then
            app.deleteUser(resource);
        end
    end
    
    -- Clear the flag
    set('despawning_in_progress', false);
end

function spawnAllResources()
    -- Check if already spawning to prevent concurrent calls
    local isCurrentlySpawning = get('spawning_in_progress');
    if isCurrentlySpawning then
        return;
    end
    
    -- Check if resources are already spawned
    local resources = get('resourceUsers');
    if resources ~= nil and #resources > 0 then
        return; -- Already spawned, don't spawn again
    end
    
    -- Set flag to prevent concurrent spawn operations
    set('spawning_in_progress', true);
    
    defineResourceSpawns();
    wait(1);
    
    writeChat('🌲 Resource Gatherer: Spawning resources...');
    for i = 1, #resourceSpawnPoints do
        spawnResourceAt(i);
        wait(0.5);
    end
    
    -- Clear the flag
    set('spawning_in_progress', false);
end

function onBackgroundSwitch(user, backgroundName)
    if backgroundName == 'brothers_crossing' then
        -- Correct background - spawn resources if not already spawned
        spawnAllResources();
    else
        -- Wrong background - despawn all resources
        despawnAllResources();
    end
end

return function()
    -- Guard against re-initialization on background change
    if get('resource_gatherer_initialized') then
        return;
    end
    set('resource_gatherer_initialized', true);
    
    writeChat('🌲 Resource Gatherer: ONLINE');
    wait(0.1);

    -- Check if we're on the correct background
    local currentBackground = getBackground();
    if currentBackground ~= 'brothers_crossing' then
        writeChat('⚠️ Resource Gatherer: Wrong background (' .. currentBackground .. '). Resources require brothers_crossing.');
    else
        spawnAllResources();
    end
    
    -- Register background switch event
    addEvent('backgroundSwitch', 'onBackgroundSwitch');

    -- Reposition resources after their avatar finishes initial spawn
    addEvent('spawn', 'onResourceAvatarSpawned');
    
    -- Start proximity checker for harvesting
    async('checkProximityForHarvest');
    
    -- Start position maintenance
    async('maintainResourcePositions');
    
    keepAlive();
end
