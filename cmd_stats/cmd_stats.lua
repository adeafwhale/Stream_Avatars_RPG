script_trigger_type = 'On Connect';

-- Copy of getGearStats function
function getGearStats(gearName)
    if gearName == nil or gearName == '' or gearName == 'none' then
        return { attack = 0, defense = 0, gathering = 0, luck = 0, health = 0, accuracy = 0, dodge = 0 };
    end
    
    local stats = { attack = 0, defense = 0, gathering = 0, luck = 0, health = 0, accuracy = 0, dodge = 0 };
    
    local rarityBonus = 0;
    if string.find(gearName, 'common') then
        rarityBonus = 1;
    elseif string.find(gearName, 'uncommon') then
        rarityBonus = 2;
    elseif string.find(gearName, 'rare') then
        rarityBonus = 3;
    elseif string.find(gearName, 'epic') then
        rarityBonus = 5;
    elseif string.find(gearName, 'legendary') then
        rarityBonus = 8;
    elseif string.find(gearName, 'mythic') then
        rarityBonus = 10;
    elseif string.find(gearName, 'special') then
        rarityBonus = 6;
    end
    
    if string.find(gearName, 'weapon_') then
        stats.attack = rarityBonus;
        if string.find(gearName, 'claymore') then
            stats.attack = stats.attack + 2;
        elseif string.find(gearName, 'shield') then
            stats.defense = rarityBonus;
            stats.attack = 0;
        end
    elseif string.find(gearName, 'tool_') then
        stats.gathering = rarityBonus;
    elseif string.find(gearName, 'outfit_') then
        stats.defense = rarityBonus;
        stats.health = rarityBonus * 10;
    elseif string.find(gearName, 'head_') then
        stats.luck = rarityBonus;
        stats.defense = math.floor(rarityBonus / 2);
    elseif string.find(gearName, 'pet_') then
        stats.luck = rarityBonus;
        stats.attack = math.floor(rarityBonus / 2);
    end
    
    return stats;
end

function showStatsForUser(targetUser)
    if targetUser == nil then
        writeChat('ERROR: No user found');
        return;
    end
    
    -- Early writeChat + wait for Stream Avatars quirk
    writeChat('📊 Calculating stats...');
    wait(0.1);
    
    -- Load base stats
    local playerData = targetUser.loadUserData('rpg_stats');
    
    if playerData == nil then
        -- Create new stats for first-time users
        playerData = {
            attack = 0,
            defense = 0,
            gathering = 0,
            luck = 0,
            health = 100,
            accuracy = 80,
            dodge = 5
        };
        targetUser.saveUserData('rpg_stats', playerData);
    else
        if playerData.attack == nil then playerData.attack = 0 end
        if playerData.defense == nil then playerData.defense = 0 end
        if playerData.gathering == nil then playerData.gathering = 0 end
        if playerData.luck == nil then playerData.luck = 0 end
        if playerData.health == nil then playerData.health = 100 end
        if playerData.accuracy == nil then playerData.accuracy = 80 end
        if playerData.dodge == nil then playerData.dodge = 5 end
        targetUser.saveUserData('rpg_stats', playerData);
    end
    
    -- Get equipped gear
    local equippedGear = targetUser.getGear();
    
    -- Calculate total stats from gear
    local gearBonus = {
        attack = 0,
        defense = 0,
        gathering = 0,
        luck = 0,
        health = 0,
        accuracy = 0,
        dodge = 0
    };
    
    -- Check each gear slot
    for slot, gearName in pairs(equippedGear) do
        local itemStats = getGearStats(gearName);
        gearBonus.attack = gearBonus.attack + itemStats.attack;
        gearBonus.defense = gearBonus.defense + itemStats.defense;
        gearBonus.gathering = gearBonus.gathering + itemStats.gathering;
        gearBonus.luck = gearBonus.luck + itemStats.luck;
        gearBonus.health = gearBonus.health + itemStats.health;
        gearBonus.accuracy = gearBonus.accuracy + itemStats.accuracy;
        gearBonus.dodge = gearBonus.dodge + itemStats.dodge;
    end
    
    -- Calculate total stats (base + gear bonuses)
    local totalStats = {
        attack = playerData.attack + gearBonus.attack,
        defense = playerData.defense + gearBonus.defense,
        gathering = playerData.gathering + gearBonus.gathering,
        luck = playerData.luck + gearBonus.luck,
        health = playerData.health + gearBonus.health,
        accuracy = playerData.accuracy + gearBonus.accuracy,
        dodge = playerData.dodge + gearBonus.dodge
    };
    
    -- Show the stats
    local message = '⚔️ ' .. targetUser.displayName .. ' | ';
    message = message .. 'ATK:' .. totalStats.attack .. ' ';
    message = message .. 'DEF:' .. totalStats.defense .. ' ';
    message = message .. 'GATHER:' .. totalStats.gathering .. ' ';
    message = message .. 'LUCK:' .. totalStats.luck .. ' ';
    message = message .. 'HP:' .. totalStats.health .. ' ';
    message = message .. 'ACC:' .. totalStats.accuracy .. ' ';
    message = message .. 'DODGE:' .. totalStats.dodge;
    
    writeChat(message);
end

function onChatMessage(user, string_message)
    if user == nil or string_message == nil then
        return;
    end
    
    local msg = string.lower(string_message);
    if msg == '!stats' or string.sub(msg, 1, 6) == '!stats' then
        showStatsForUser(user);
    end
end

return function()
    if commandUser ~= nil then
        showStatsForUser(commandUser);
        return;
    end
    
    addEvent('chatMessage', 'onChatMessage');
    keepAlive();
end