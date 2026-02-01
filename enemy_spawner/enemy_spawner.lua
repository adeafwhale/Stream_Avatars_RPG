enemyUsers = {};
enemySpawnPoints = {};

function flashDamageEffect(user, effectType)
    if user == nil then
        return;
    end
    
    if effectType == 'damage' then
        user.setTemporaryColor('white', 0.25);
    end
end

function displayCombatResult(defender, result)
    if defender == nil or result == nil then
        return;
    end
    
    local displayText = '';
    
    if not result.hit then
        if result.dodged == true then
            displayText = 'DODGE';
        else
            displayText = 'MISS';
        end
    elseif result.crit then
        displayText = 'CRIT! ' .. result.damage;
    else
        displayText = result.damage;
    end
    
    defender.chatBubble(displayText);
end
function defineEnemySpawns()
    local points = {};
    local app = getApp();
    local res = app.getResolution();
    
    local spawnY = 20;
    local screenWidth = res.x;
    
    -- Jakyl spawns
    table.insert(points, {
        type = 'jakyl',
        enemyName = 'Enemy_Jakyl_1',
        blockId = 657,
        x = screenWidth * 0.15,
        y = spawnY + 50,
        hp = 30,
        attack = 6,
        defense = 1,
        respawnTime = 15
    });
    
    table.insert(points, {
        type = 'jakyl',
        enemyName = 'Enemy_Jakyl_2',
        blockId = 656,
        x = screenWidth * 0.3,
        y = spawnY + 50,
        hp = 30,
        attack = 6,
        defense = 1,
        respawnTime = 15
    });

    enemySpawnPoints = points;
    set('enemySpawnPoints', points);
end

function resolveEnemySpawnPosition(spawnPoint)
    if spawnPoint == nil then
        return nil, nil;
    end

    local level = getBackground();
    if level == 'brothers_crossing' and spawnPoint.blockId ~= nil then
        local blocks = getScriptableBlocks();
        for _, block in pairs(blocks) do
            if block.id == spawnPoint.blockId then
                return block.position.x, block.position.y;
            end
        end
    end

    return spawnPoint.x, spawnPoint.y;
end

function getEnemySpawnPointByName(enemyName)
    if enemyName == nil then
        return nil;
    end

    for i, spawnPoint in ipairs(enemySpawnPoints) do
        if spawnPoint.enemyName == enemyName then
            return spawnPoint;
        end
    end

    return nil;
end

function onAvatarSpawned(user)
    if user == nil then
        return;
    end

    if not isEnemyUser(user) then
        return;
    end

    local spawnPoint = getEnemySpawnPointByName(user.displayName);
    if spawnPoint == nil then
        return;
    end

    local spawnX, spawnY = resolveEnemySpawnPosition(spawnPoint);
    if spawnX ~= nil and spawnY ~= nil then
        user.setPosition(spawnX, spawnY);
    end
end

function maintainEnemyPositions()
    while true do
        yield();

        local enemies = get('enemyUsers');
        if enemies ~= nil and #enemies > 0 then
            for _, enemyData in ipairs(enemies) do
                local enemy = getUser(enemyData.enemyName);
                if enemy ~= nil then
                    local spawnPoint = enemySpawnPoints[enemyData.spawnPointIndex];
                    local spawnX, spawnY = resolveEnemySpawnPosition(spawnPoint);
                    if spawnX ~= nil and spawnY ~= nil then
                        local pos = enemy.getPosition();
                        if math.abs(pos.x - spawnX) > 5 or math.abs(pos.y - spawnY) > 5 then
                            enemy.setPosition(spawnX, spawnY);
                        end
                    end
                end
            end
        end

        wait(0.5);
    end
end

function spawnEnemyAt(spawnPointIndex)
    local spawnPoint = enemySpawnPoints[spawnPointIndex];
    if spawnPoint == nil then
        return;
    end
    
    -- Use the built-in spawn command
    runCommand('!spawn ' .. spawnPoint.enemyName, true);
    
    wait(1);
    
    -- Get the spawned enemy
    local enemyUser = getUser(spawnPoint.enemyName);
    
    if enemyUser == nil then
        return;
    end

    -- Use setTemporaryAvatar to bypass ownership check (set to 0 for permanent until app restart)
    enemyUser.setTemporaryAvatar('enemy_jakyl', 0);
    
    -- Position the enemy
    local spawnX, spawnY = resolveEnemySpawnPosition(spawnPoint);
    if spawnX ~= nil and spawnY ~= nil then
        enemyUser.setPosition(spawnX, spawnY);
    end

    -- Tag this user as an enemy (persists per user)
    enemyUser.saveUserData('enemy_tag', {
        isEnemy = true,
        source = 'enemy_spawner'
    });
    
    -- Store enemy data
    local enemies = get('enemyUsers');
    if enemies == nil then
        enemies = {};
    end
    
    table.insert(enemies, {
        enemyName = spawnPoint.enemyName,
        type = spawnPoint.type,
        hp = spawnPoint.hp,
        attack = spawnPoint.attack,
        defense = spawnPoint.defense,
        spawnPointIndex = spawnPointIndex,
        respawnTime = spawnPoint.respawnTime,
        lastCombatTime = 0
    });
    
    set('enemyUsers', enemies);
    
    
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

function checkCombatProximity()
    -- This runs continuously to check for combat
    while true do
        yield();
        
        local enemies = get('enemyUsers');
        if enemies == nil or #enemies == 0 then
            wait(1);
        else
            local allUsers = getUsers();
            
            for _, player in ipairs(allUsers) do
                -- Skip enemies (tagged users)
                if not isEnemyUser(player) then
                    local playerPos = player.getPosition();
                    
                    -- Check if player is on combat cooldown after losing/timing out
                    local currentTime = os.time();
                    local playerCombatCooldown = player.loadUserData('player_combat_cooldown');
                    local timeSinceLastCombat = currentTime - (playerCombatCooldown or 0);
                    
                    if timeSinceLastCombat >= 62 then
                        for i, enemyData in ipairs(enemies) do
                        local enemy = getUser(enemyData.enemyName);
                        
                        if enemy ~= nil then
                            -- Skip enemies that are currently respawning or in combat
                            if enemyData.isRespawning == true then
                                goto continue;
                            end
                            
                            -- Check combat cooldown (5 seconds between fights)
                            local currentTime = os.time();
                            local timeSinceCombat = currentTime - (enemyData.lastCombatTime or 0);
                            
                            if timeSinceCombat >= 5 then
                                local enemyPos = enemy.getPosition();
                                
                                -- Calculate distance
                                local dx = playerPos.x - enemyPos.x;
                                local dy = playerPos.y - enemyPos.y;
                                local distance = math.sqrt(dx * dx + dy * dy);
                                
                                -- If within 190 pixels, start walking toward player
                                if distance < 190 and distance >= 150 then
                                    -- Make enemy walk toward player and both face each other
                                    if playerPos.x > enemyPos.x then
                                        enemy.runCommand('!walk');
                                        enemy.look(1); -- Face right toward player
                                        player.look(-1); -- Player faces left toward enemy
                                    else
                                        enemy.runCommand('!walk');
                                        enemy.look(-1); -- Face left toward player
                                        player.look(1); -- Player faces right toward enemy
                                    end
                                elseif distance < 150 and distance >= 10 then
                                    -- Close enough - stop walking but keep facing each other
                                    enemy.runCommand('!idle');
                                    if playerPos.x > enemyPos.x then
                                        enemy.look(1);
                                        player.look(-1);
                                    else
                                        enemy.look(-1);
                                        player.look(1);
                                    end
                                end
                                
                                -- If within 90 pixels, start combat
                                if distance < 90 then
                                    -- Mark enemy as in combat IMMEDIATELY to prevent other players from engaging
                                    enemyData.isRespawning = true;
                                    enemyData.lastCombatTime = currentTime;
                                    enemies[i] = enemyData;
                                    set('enemyUsers', enemies);
                                    
                                    startCombat(player, enemy, enemyData);
                                    break;
                                end
                            end
                        end
                        
                        ::continue::
                    end
                    end
                end
            end
            
            wait(0.5);
        end
    end
end

function startCombat(player, enemy, enemyData)
    -- Make avatars face each other
    if player ~= nil and enemy ~= nil then
        local playerPos = player.getPosition();
        local enemyPos = enemy.getPosition();
        
        if playerPos ~= nil and enemyPos ~= nil then
            -- If enemy is to the right of player, player faces right (1)
            if enemyPos.x > playerPos.x then
                player.look(1);
            else
                player.look(-1);
            end
            
            -- Enemy faces opposite direction
            if playerPos.x > enemyPos.x then
                enemy.look(1);
            else
                enemy.look(-1);
            end
        end
    end

    local combatResult = runCombatBattle(player, enemy, enemyData);
    if combatResult == nil then
        return;
    end

    announceCombatSummary(combatResult);

    if combatResult.outcome == 'player' then
        onPlayerVictory(player, enemy, enemyData, combatResult);
    elseif combatResult.outcome == 'enemy' then
        onPlayerDefeat(player, enemy, enemyData, combatResult);
    else
        onCombatDraw(player, enemy, enemyData, combatResult);
    end
end

function resolveUserByName(userName)
    if userName == nil or userName == '' then
        return nil;
    end

    local user = getUser(userName);
    if user ~= nil then
        return user;
    end

    local app = getApp();
    return app.getUserFromData(userName);
end

function ensureBaseStats(data)
    if data.attack == nil then data.attack = 0 end
    if data.defense == nil then data.defense = 0 end
    if data.gathering == nil then data.gathering = 0 end
    if data.luck == nil then data.luck = 0 end
    if data.health == nil then data.health = 100 end
    if data.accuracy == nil then data.accuracy = 80 end
    if data.dodge == nil then data.dodge = 5 end
    return data
end

function getPlayerCombatStats(player)
    local playerData = player.loadUserData('rpg_stats');
    if playerData == nil then
        playerData = {
            attack = 0,
            defense = 0,
            gathering = 0,
            luck = 0,
            health = 100,
            accuracy = 80,
            dodge = 5
        };
    else
        playerData = ensureBaseStats(playerData);
    end

    local equippedGear = player.getGear();
    local gearBonus = {
        attack = 0,
        defense = 0,
        gathering = 0,
        luck = 0,
        health = 0,
        accuracy = 0,
        dodge = 0
    };

    for slot, gearName in pairs(equippedGear) do
        local itemStats = getGearStatsForCombat(gearName);
        gearBonus.attack = gearBonus.attack + (itemStats.attack or 0);
        gearBonus.defense = gearBonus.defense + (itemStats.defense or 0);
        gearBonus.health = gearBonus.health + (itemStats.health or 0);
        gearBonus.luck = gearBonus.luck + (itemStats.luck or 0);
        gearBonus.accuracy = gearBonus.accuracy + (itemStats.accuracy or 0);
        gearBonus.dodge = gearBonus.dodge + (itemStats.dodge or 0);
    end

    return {
        attack = playerData.attack + gearBonus.attack,
        defense = playerData.defense + gearBonus.defense,
        health = playerData.health + gearBonus.health,
        luck = playerData.luck + gearBonus.luck,
        accuracy = playerData.accuracy + gearBonus.accuracy,
        dodge = playerData.dodge + gearBonus.dodge
    };
end

function getEnemyCombatStats(enemyData)
    return {
        attack = enemyData.attack or 0,
        defense = enemyData.defense or 0,
        health = enemyData.hp or 1,
        luck = enemyData.luck or 0,
        accuracy = enemyData.accuracy or 70,
        dodge = enemyData.dodge or 5
    };
end

function clampPercent(val)

    if val < 5 then return 5 end
    if val > 95 then return 95 end
    return val
end

function flashDamageEffect(user, effectType)
    if user == nil then
        return;
    end

    if effectType == 'damage' then
        user.setTemporaryColor('white', 0.25);
    end
end

function displayCombatResult(defender, result)
    if defender == nil or result == nil then
        return;
    end

    local displayText = '';

    if not result.hit then
        if result.dodged == true then
            displayText = 'DODGE';
        else
            displayText = 'MISS';
        end
    elseif result.crit then
        displayText = '⭐ CRIT! ' .. result.damage;
    else
        displayText = result.damage;
    end

    defender.chatBubble(displayText);
end

function resolveAttack(attackerStats, defenderStats)
    local hitChance = clampPercent(attackerStats.accuracy - defenderStats.dodge);
    local hitRoll = math.random(1, 100);
    local hit = hitRoll <= hitChance;

    local crit = false;
    local damage = 0;
    local dodged = false;

    if hit then
        local critChance = math.min(75, 5 + (attackerStats.luck * 2));
        local critRoll = math.random(1, 100);
        crit = critRoll <= critChance;

        local baseDamage = math.max(1, attackerStats.attack - defenderStats.defense);
        if crit then
            local critMultiplier = 1.5 + (attackerStats.luck * 0.015);
            damage = math.floor((baseDamage * critMultiplier) + 0.5);
        else
            damage = baseDamage;
        end
    end

    if not hit then
        local accuracyValue = attackerStats.accuracy or 0;
        if hitRoll > accuracyValue then
            dodged = false;
        else
            dodged = (defenderStats.dodge or 0) > 0;
        end
    end

    return {
        hit = hit,
        crit = crit,
        damage = damage,
        hitChance = hitChance,
        dodged = dodged
    };
end

function lockIfActive(user, pos)
    if user == nil or pos == nil then
        return;
    end
    if user.isActive == false then
        return;
    end
    user.setPosition(pos.x, pos.y);
end

function getAttackStandoffDistance()
    return 90;
end

function prepareForAttack(attacker, defender)
    if attacker == nil or defender == nil then
        return;
    end

    local attackerPos = attacker.getPosition();
    local defenderPos = defender.getPosition();

    if attackerPos == nil or defenderPos == nil then
        return;
    end

    local dx = defenderPos.x - attackerPos.x;
    local distance = math.abs(dx);
    local targetDistance = getAttackStandoffDistance();

    if distance == targetDistance then
        return;
    end

    local newX = attackerPos.x;
    if dx > 0 then
        newX = defenderPos.x - targetDistance;
    else
        newX = defenderPos.x + targetDistance;
    end

    attacker.setPosition(newX, attackerPos.y);
    wait(0.05);
end

function normalizeCombatPositions(player, enemy, playerPos, enemyPos)
    if playerPos == nil or enemyPos == nil then
        return playerPos, enemyPos;
    end

    local targetDistance = getAttackStandoffDistance();
    local dx = enemyPos.x - playerPos.x;

    if dx == 0 then
        dx = 1;
    end

    local desiredEnemyX = playerPos.x + (dx > 0 and targetDistance or -targetDistance);
    enemyPos = { x = desiredEnemyX, y = enemyPos.y };

    if player ~= nil and player.isActive ~= false then
        player.setPosition(playerPos.x, playerPos.y);
    end

    if enemy ~= nil and enemy.isActive ~= false then
        enemy.setPosition(enemyPos.x, enemyPos.y);
    end

    return playerPos, enemyPos;
end

function runCombatBattle(player, enemy, enemyData)
    if player == nil or enemyData == nil then
        return nil;
    end

    local playerName = player.displayName;
    local enemyName = enemyData.enemyName;

    local playerStats = getPlayerCombatStats(player);
    local enemyStats = getEnemyCombatStats(enemyData);

    local playerHP = playerStats.health;
    local enemyHP = enemyStats.health;

    local playerPos = nil;
    local enemyPos = nil;

    local activePlayer = resolveUserByName(playerName);
    if activePlayer ~= nil and activePlayer.isActive ~= false then
        playerPos = activePlayer.getPosition();
    end

    local activeEnemy = resolveUserByName(enemyName);
    if activeEnemy ~= nil and activeEnemy.isActive ~= false then
        enemyPos = activeEnemy.getPosition();
    end

    playerPos, enemyPos = normalizeCombatPositions(activePlayer, activeEnemy, playerPos, enemyPos);

    local maxRounds = 8;
    local rounds = 0;

    local roundLog = {};
    local stats = {
        playerHits = 0,
        playerMisses = 0,
        playerCrits = 0,
        playerDamage = 0,
        enemyHits = 0,
        enemyMisses = 0,
        enemyCrits = 0,
        enemyDamage = 0
    };

    for round = 1, maxRounds do
        rounds = round;

        local roundEntry = { round = round };

        activePlayer = resolveUserByName(playerName);
        activeEnemy = resolveUserByName(enemyName);
        lockIfActive(activePlayer, playerPos);
        lockIfActive(activeEnemy, enemyPos);

        -- Player's turn: play attack animation
        if activePlayer ~= nil and activePlayer.isActive ~= false then
            activePlayer.runCommand('!swing');
            wait(0.5); -- Wait for swing animation to play
        end

        local playerAttack = resolveAttack(playerStats, enemyStats);
        if playerAttack.hit then
            enemyHP = enemyHP - playerAttack.damage;
            stats.playerHits = stats.playerHits + 1;
            stats.playerDamage = stats.playerDamage + playerAttack.damage;
        else
            stats.playerMisses = stats.playerMisses + 1;
        end

        if playerAttack.crit then
            stats.playerCrits = stats.playerCrits + 1;
        end

        roundEntry.player = playerAttack;

        -- Visual feedback for player's attack
        if activeEnemy ~= nil and activeEnemy.isActive ~= false then
            if playerAttack.hit then
                flashDamageEffect(activeEnemy, 'damage');
            end
            displayCombatResult(activeEnemy, playerAttack);
        end

        if enemyHP <= 0 then
            table.insert(roundLog, roundEntry);
            break;
        end

        wait(0.3);

        activePlayer = resolveUserByName(playerName);
        activeEnemy = resolveUserByName(enemyName);
        lockIfActive(activePlayer, playerPos);
        lockIfActive(activeEnemy, enemyPos);

        -- Enemy's turn: play attack animation
        if activeEnemy ~= nil and activeEnemy.isActive ~= false then
            activeEnemy.runCommand('!bite');
            wait(0.5); -- Wait for bite animation to play
        end

        local enemyAttack = resolveAttack(enemyStats, playerStats);
        if enemyAttack.hit then
            playerHP = playerHP - enemyAttack.damage;
            stats.enemyHits = stats.enemyHits + 1;
            stats.enemyDamage = stats.enemyDamage + enemyAttack.damage;
        else
            stats.enemyMisses = stats.enemyMisses + 1;
        end

        if enemyAttack.crit then
            stats.enemyCrits = stats.enemyCrits + 1;
        end

        roundEntry.enemy = enemyAttack;

        -- Visual feedback for enemy's attack
        if activePlayer ~= nil and activePlayer.isActive ~= false then
            if enemyAttack.hit then
                flashDamageEffect(activePlayer, 'damage');
            end
            displayCombatResult(activePlayer, enemyAttack);
        end

        table.insert(roundLog, roundEntry);

        if playerHP <= 0 then
            break;
        end

        wait(0.1);
    end

    local outcome = 'enemy';
    if playerHP <= 0 and enemyHP <= 0 then
        outcome = 'draw';
    elseif enemyHP <= 0 then
        outcome = 'player';
    elseif playerHP <= 0 then
        outcome = 'enemy';
    else
        -- If time runs out, enemy wins by default
        outcome = 'enemy';
    end

    return {
        outcome = outcome,
        rounds = rounds,
        playerName = playerName,
        enemyName = enemyName,
        enemyType = enemyData.type,
        playerHP = math.max(0, playerHP),
        enemyHP = math.max(0, enemyHP),
        playerMaxHP = playerStats.health,
        enemyMaxHP = enemyStats.health,
        stats = stats,
        roundsLog = roundLog
    };
end

function formatAttackLine(label, attack)
    if attack == nil then
        return label .. ' did not act';
    end

    if not attack.hit then
        return label .. ' missed';
    end

    if attack.crit then
        return label .. ' crit for ' .. attack.damage;
    end

    return label .. ' hit for ' .. attack.damage;
end

function announceCombatSummary(result)
    if result == nil then
        return;
    end

    
end

function getGearStatsForCombat(gearName)
    if gearName == nil or gearName == '' or gearName == 'none' then
        return { attack = 0, defense = 0, health = 0, luck = 0, accuracy = 0, dodge = 0 };
    end
    
    local stats = { attack = 0, defense = 0, health = 0, luck = 0, accuracy = 0, dodge = 0 };
    
    local rarityBonus = 0;
    if string.find(gearName, 'common') then
        rarityBonus = 2;
    elseif string.find(gearName, 'uncommon') then
        rarityBonus = 3;
    elseif string.find(gearName, 'rare') then
        rarityBonus = 4;
    elseif string.find(gearName, 'epic') then
        rarityBonus = 5;
    elseif string.find(gearName, 'legendary') then
        rarityBonus = 8;
    elseif string.find(gearName, 'mythic') then
        rarityBonus = 12;
    elseif string.find(gearName, 'special') then
        rarityBonus = 10;
    end
    
    -- Check specific weapon types first
    if string.find(gearName, 'spear_and_shield') or string.find(gearName, 'spear') then
        -- Spear and shield gives balanced attack and defense (80% of weapon attack)
        stats.attack = math.floor(rarityBonus * 5 * 0.8);
        stats.defense = math.floor(rarityBonus * 0.7);
    elseif string.find(gearName, 'claymore') then
        -- Claymore gives very high attack, no defense
        stats.attack = (rarityBonus * 5) + 3;
    elseif string.find(gearName, 'spear_and_shield') then
        stats.attack = rarityBonus * 5;
        if string.find(gearName, 'claymore') then
            stats.attack = stats.attack + 3;
        elseif string.find(gearName, 'shield') then
            stats.defense = rarityBonus;
            stats.attack = 0;
        end
    elseif string.find(gearName, 'tool_') then
        -- Tools don't help in combat
    elseif string.find(gearName, 'outfit_') then
        stats.defense = rarityBonus;
        stats.health = rarityBonus * 10;
    elseif string.find(gearName, 'head_') then
        stats.defense = math.floor(rarityBonus / 2);
        stats.luck = rarityBonus;
    elseif string.find(gearName, 'croaklin') then
        -- Pets only influence luck, but give double the rarity bonus
        stats.luck = rarityBonus * 2;
    end
    
    return stats;
end

function onPlayerVictory(player, enemy, enemyData, combatResult)
    -- Base gold range: 3-6
    local baseGold = math.random(3, 6);
    
    -- Get player's luck stat to influence loot
    local playerStats = getPlayerCombatStats(player);
    local luckBonus = math.floor(playerStats.luck * 0.5); -- 0.5 gold per luck point
    
    local goldReward = baseGold + luckBonus;
    
    local success, newBalance = addCurrency(player, goldReward);
    
    -- Play built-in death/respawn via explode for visual effect
    if enemy ~= nil then
        runCommand('!explode ' .. enemyData.enemyName, true);
    end
    
    -- Mark enemy as respawning to prevent re-engagement
    local enemies = get('enemyUsers');
    if enemies ~= nil then
        for i, e in ipairs(enemies) do
            if e.enemyName == enemyData.enemyName then
                e.isRespawning = true;
                enemies[i] = e;
                set('enemyUsers', enemies);
                break;
            end
        end
    end
    
    -- Start respawn timer in async to avoid blocking combat
    set('respawn_enemy_index', enemyData.spawnPointIndex);
    set('respawn_enemy_delay', enemyData.respawnTime);
    set('respawn_enemy_name', enemyData.enemyName);
    async('respawnEnemyAfterDelay');
end

function onPlayerDefeat(player, enemy, enemyData, combatResult)
    -- Play built-in death/respawn via explode for defeated player
    if player ~= nil then
        runCommand('!explode ' .. player.displayName, true);
        
        -- Wait for explosion to complete before changing to ghost
        wait(2);
        
        -- Convert player to ghost form (60 second duration)
        player.setTemporaryAvatar('ghost', 60);
        
        -- Set 62 second cooldown (60 for ghost + 2 second grace period after returning)
        player.saveUserData('player_combat_cooldown', os.time());
    end
    
    -- Mark enemy as respawning (even though they won, prevent re-engagement for cooldown)
    local enemies = get('enemyUsers');
    if enemies ~= nil then
        for i, e in ipairs(enemies) do
            if e.enemyName == enemyData.enemyName then
                e.isRespawning = true;
                e.lastCombatTime = os.time();
                enemies[i] = e;
                set('enemyUsers', enemies);
                break;
            end
        end
    end
    
    -- Brief respawn timer even on victory to prevent immediate re-engagement
    set('respawn_enemy_index', enemyData.spawnPointIndex);
    set('respawn_enemy_delay', 5); -- 5 second cooldown after defeating player
    set('respawn_enemy_name', enemyData.enemyName);
    async('respawnEnemyAfterDelay');
end

function onCombatDraw(player, enemy, enemyData, combatResult)
    if player ~= nil then
        runCommand('!explode ' .. player.displayName, true);
    end
    if enemyData ~= nil and enemyData.enemyName ~= nil then
        runCommand('!explode ' .. enemyData.enemyName, true);
    end
    
    -- Mark enemy as respawning
    local enemies = get('enemyUsers');
    if enemies ~= nil then
        for i, e in ipairs(enemies) do
            if e.enemyName == enemyData.enemyName then
                e.isRespawning = true;
                e.lastCombatTime = os.time();
                enemies[i] = e;
                set('enemyUsers', enemies);
                break;
            end
        end
    end
    
    -- Respawn both after draw
    set('respawn_enemy_index', enemyData.spawnPointIndex);
    set('respawn_enemy_delay', 10); -- 10 second cooldown after draw
    set('respawn_enemy_name', enemyData.enemyName);
    async('respawnEnemyAfterDelay');
end

function respawnEnemyAfterDelay()
    local spawnIndex = get('respawn_enemy_index');
    local delay = get('respawn_enemy_delay');
    local enemyName = get('respawn_enemy_name');
    
    if spawnIndex == nil or delay == nil then
        return;
    end
    
    wait(delay);
    
    -- Remove respawning flag and re-enable for combat
    local enemies = get('enemyUsers');
    if enemies ~= nil then
        for i, e in ipairs(enemies) do
            if e.enemyName == enemyName then
                e.isRespawning = false;
                enemies[i] = e;
                set('enemyUsers', enemies);
                break;
            end
        end
    end
    
    -- Now spawn the enemy at the designated location
    local spawnPoint = enemySpawnPoints[spawnIndex];
    if spawnPoint ~= nil then
        local spawnX, spawnY = resolveEnemySpawnPosition(spawnPoint);
        if spawnX ~= nil and spawnY ~= nil then
            local respawnedEnemy = getUser(enemyName);
            if respawnedEnemy ~= nil then
                respawnedEnemy.setPosition(spawnX, spawnY);
                
            end
        end
    end
end

return function()
    writeChat('👹 Enemy Spawner: ONLINE');
    wait(0.1);

    
    
    defineEnemySpawns();
    
    wait(1);
    
    -- Spawn all enemies
    for i = 1, #enemySpawnPoints do
        spawnEnemyAt(i);
        wait(0.5);
    end
    
    
    
    -- Start combat proximity checker
    async('checkCombatProximity');
    
    keepAlive();
end