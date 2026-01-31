-- Copy of getGearStats function (included in this script)
function getGearStats(gearName)
    if gearName == nil or gearName == '' or gearName == 'none' then
        return { attack = 0, defense = 0, gathering = 0, luck = 0, health = 0 };
    end
    
    local stats = { attack = 0, defense = 0, gathering = 0, luck = 0, health = 0 };
    
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
        rarityBonus = 12;
    elseif string.find(gearName, 'special') then
        rarityBonus = 10;
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

return function()
    writeChat('Testing gear registry...');
    wait(0.1);
    
    local testGear = {
        'weapon_legendary_claymore',
        'tool_rare_bundle',
        'outfit_epic_ferralith',
        'head_common_cap',
        'pet_mythic_dragon'
    };
    
    for i, gearName in ipairs(testGear) do
        local stats = getGearStats(gearName);
        local msg = gearName .. ' | ATK:' .. stats.attack .. 
                    ' DEF:' .. stats.defense .. 
                    ' GATHER:' .. stats.gathering .. 
                    ' LUCK:' .. stats.luck .. 
                    ' HP:' .. stats.health;
        writeChat(msg);
        wait(0.3);
    end
    
    writeChat('✅ Test complete!');
end