resourceObjects = {};
spawnPoints = {};

function defineSpawnPoints()
    local points = {};
    
    -- Wood spawns (left side) - 30 second respawn
    table.insert(points, {
        type = 'wood',
        x = 0.2,
        y = 110,
        respawnTime = 30
    });
    
    table.insert(points, {
        type = 'wood',
        x = 0.25,
        y = 110,
        respawnTime = 30
    });
    
    -- Stone spawns (right side) - 45 second respawn
    table.insert(points, {
        type = 'stone',
        x = 0.8,
        y = 20,
        respawnTime = 45
    });
    
    table.insert(points, {
        type = 'stone',
        x = 0.75,
        y = 20,
        respawnTime = 45
    });
    
    -- Ore spawns (top corners) - 60 second respawn
    table.insert(points, {
        type = 'ore',
        x = 0.85,
        y = 40,
        respawnTime = 60
    });
    
    table.insert(points, {
        type = 'ore',
        x = 0.15,
        y = 40
    ,
        respawnTime = 60
    });
    
    -- Fiber spawns (bottom) - 30 second respawn
    table.insert(points, {
        type = 'fiber',
        x = 0.5,
        y = 20,
        respawnTime = 30
    });
    
    table.insert(points, {
        type = 'fiber',
        x = 0.6,
        y = 20,
        respawnTime = 30
    });
    
    -- Fish spawns (center-ish, rare) - 90 second respawn
    table.insert(points, {
        type = 'fish',
        x = 0.5,
        y = 20,
        respawnTime = 90
    });
    
    spawnPoints = points;
    set('spawnPoints', points);
end

function spawnResourceAt(spawnPointIndex)
    local spawnPoint = spawnPoints[spawnPointIndex];
    if spawnPoint == nil then
        return;
    end
    
    local app = getApp();
    -- Convert X from percentage, but use Y as direct world coordinate
    local percentPos = app.convertPercentToPosition(spawnPoint.x, 0.5);
    
    local resourceObj = app.createGameObject();
    local imageName = 'resource_' .. spawnPoint.type;
    applyImage(resourceObj, imageName);
    
    -- 50% chance to flip on X axis
    if math.random() > 0.5 then
        resourceObj.image.flipX();
    end
    
    resourceObj.setPosition(percentPos.x, spawnPoint.y);
    resourceObj.physics.addCircleTrigger();
    
    local resources = get('resourceObjects');
    if resources == nil then
        resources = {};
    end
    
    table.insert(resources, {
        objectId = resourceObj.id,
        type = spawnPoint.type,
        spawnPointIndex = spawnPointIndex
    });
    
    set('resourceObjects', resources);
end

function respawnAfterDelay()
    local spawnIndex = get('respawn_spawnIndex');
    local delaySeconds = get('respawn_delay');
    
    wait(delaySeconds);
    
    local points = get('spawnPoints');
    if points == nil then
        return;
    end
    
    local spawnPoint = points[spawnIndex];
    if spawnPoint == nil then
        return;
    end
    
    local app = getApp();
    -- Convert X from percentage, but use Y as direct world coordinate
    local percentPos = app.convertPercentToPosition(spawnPoint.x, 0.5);
    
    local resourceObj = app.createGameObject();
    local imageName = 'resource_' .. spawnPoint.type;
    applyImage(resourceObj, imageName);
    resourceObj.image.sorting(-1000, 'background');
    
    -- 50% chance to flip on X axis
    if math.random() > 0.5 then
        resourceObj.image.flipX();
    end
    
    resourceObj.setPosition(percentPos.x, spawnPoint.y);
    resourceObj.physics.addCircleTrigger();
    
    local resources = get('resourceObjects');
    if resources == nil then
        resources = {};
    end
    
    table.insert(resources, {
        objectId = resourceObj.id,
        type = spawnPoint.type,
        spawnPointIndex = spawnIndex
    });
    
    set('resourceObjects', resources);
end

function collectResourceWithDelay()
    wait(5);
    
    local userId = get('collect_userId');
    local resourceType = get('collect_resourceType');
    local user = getUser(userId);
    
    if user ~= nil then
        local inventory = user.loadUserData('rpg_inventory');
        if inventory == nil then
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
        
        inventory[resourceType] = inventory[resourceType] + 1;
        user.saveUserData('rpg_inventory', inventory);
        
        writeChat('✨ ' .. user.displayName .. ' harvested ' .. resourceType .. '!');
    end
    
    local resourceObjectId = get('destroy_resourceObjectId');
    local app = getApp();
    local gameObj = app.getGameObject(resourceObjectId);
    if gameObj ~= nil then
        gameObj.destroy();
    end
end

function onResourceTrigger(user, object, eventType)
    if eventType ~= 'enter' or user == nil then
        return;
    end
    
    local resources = get('resourceObjects');
    if resources == nil then
        return;
    end
    
    local touchedResource = nil;
    local touchedIndex = nil;
    
    for i, res in ipairs(resources) do
        if res.objectId == object.id then
            touchedResource = res;
            touchedIndex = i;
            break;
        end
    end
    
    if touchedResource == nil then
        return;
    end
    
    -- Store data and run async
    set('collect_userId', user.id);
    set('collect_resourceType', touchedResource.type);
    set('destroy_resourceObjectId', touchedResource.objectId);
    
    -- Get respawn time from spawn point
    local points = get('spawnPoints');
    local respawnTime = 30;
    if points ~= nil and points[touchedResource.spawnPointIndex] ~= nil then
        respawnTime = points[touchedResource.spawnPointIndex].respawnTime;
    end
    
    set('respawn_spawnIndex', touchedResource.spawnPointIndex);
    set('respawn_delay', respawnTime);
    
    -- Start collection and respawn async
    async('collectResourceWithDelay');
    async('respawnAfterDelay');
    
    -- Remove immediately from active resources
    table.remove(resources, touchedIndex);
    set('resourceObjects', resources);
end

return function()
    writeChat('🌲 Resource Spawner: ONLINE');
    wait(0.1);
    
    defineSpawnPoints();
    addEvent('triggerObject', 'onResourceTrigger');
    
    -- Spawn all resources
    for i = 1, #spawnPoints do
        spawnResourceAt(i);
        wait(0.1);
    end
    
    writeChat('✅ ' .. #spawnPoints .. ' resources spawned! Happy gathering!');
    
    keepAlive();
end