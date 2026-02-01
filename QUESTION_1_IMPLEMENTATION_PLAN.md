# Question #1 Implementation Plan - Visual Damage Feedback

## Requirements
- **Flash Effect**: Both enemy and player flash WHITE when taking damage
- **Damage Display**: Show exact damage number via chat bubble
- **Critical Strikes**: Display "⭐ CRIT! [damage]" (chat bubbles do not support size/color)
- **Misses**: Display "MISS" when attack fails
- **Dodges**: Display "DODGE" when attack is avoided

**Note:** `user.chatBubble()` does not support custom size or color, so crit emphasis uses emoji + text only.

## Implementation Strategy

### 1. Create Visual Feedback Functions

#### Function: `flashDamageEffect(user, effectType)`
Temporarily changes avatar color to WHITE for damage impact.

```lua
function flashDamageEffect(user, effectType)
    if user == nil then
        return
    end
    
    if effectType == 'damage' then
        user.setTemporaryColor('white', 0.25)  -- White flash for 0.25 seconds on hit
    end
end
```

#### Function: `displayCombatResult(defender, result)`
Shows combat outcome via chat bubble with proper formatting.

```lua
function displayCombatResult(defender, result)
    if defender == nil or result == nil then
        return
    end
    
    local displayText = ''
    
    if not result.hit then
        if result.dodged == true then
            displayText = 'DODGE'
        else
            displayText = 'MISS'
        end
    elseif result.crit then
        -- Critical hit - use emoji to make it stand out (size/color not supported)
        displayText = '⭐ CRIT! ' .. result.damage
    else
        -- Normal hit
        displayText = result.damage
    end
    
    -- Show damage number/text above defender's head
    defender.chatBubble(displayText)
end
```

### 2. Integration Points in Combat Loop

The combat loop has two attack phases:

**Phase 1: Player Attacks Enemy**
- Line ~514: Resolve player attack
- Add visual feedback here

**Phase 2: Enemy Attacks Player**
- Line ~534: Resolve enemy attack  
- Add visual feedback here

### 3. Integration Code

#### After Player Attack (around line 514):
```lua
-- Player's attack resolution
local playerAttack = resolveAttack(playerStats, enemyStats)
if playerAttack.hit then
    enemyHP = enemyHP - playerAttack.damage
    stats.playerHits = stats.playerHits + 1
    stats.playerDamage = stats.playerDamage + playerAttack.damage
else
    stats.playerMisses = stats.playerMisses + 1
end

if playerAttack.crit then
    stats.playerCrits = stats.playerCrits + 1
end

-- NEW: Visual feedback for player's attack
if activeEnemy ~= nil and activeEnemy.isActive ~= false then
    if playerAttack.hit then
        flashDamageEffect(activeEnemy, 'damage')
    end
    displayCombatResult(activeEnemy, playerAttack)
end

roundEntry.player = playerAttack
```

#### After Enemy Attack (around line 534):
```lua
-- Enemy's attack resolution
local enemyAttack = resolveAttack(enemyStats, playerStats)
if enemyAttack.hit then
    playerHP = playerHP - enemyAttack.damage
    stats.enemyHits = stats.enemyHits + 1
    stats.enemyDamage = stats.enemyDamage + enemyAttack.damage
else
    stats.enemyMisses = stats.enemyMisses + 1
end

if enemyAttack.crit then
    stats.enemyCrits = stats.enemyCrits + 1
end

-- NEW: Visual feedback for enemy's attack
if activePlayer ~= nil and activePlayer.isActive ~= false then
    if enemyAttack.hit then
        flashDamageEffect(activePlayer, 'damage')
    end
    displayCombatResult(activePlayer, enemyAttack)
end

roundEntry.enemy = enemyAttack
```

## Expected Visual Output

### Normal Hit:
```
Enemy flashes WHITE
Chat bubble above enemy: "15"
```

### Critical Hit:
```
Enemy flashes WHITE
Chat bubble above enemy: "⭐ CRIT! 25"
```

### Miss:
```
No white flash
Chat bubble above enemy: "MISS"
```

### Dodge:
```
No white flash
Chat bubble above enemy: "DODGE"
```

## Notes

- Chat bubbles automatically disappear after a few seconds
- White color provides clear visual impact without covering details
- Emoji (⭐) makes critical hits visually distinct
- No chat spam - only appears above avatars, not in chat
- Works perfectly during streaming without interrupting chat

## Testing Checklist
- [ ] White flash appears when avatar is hit
- [ ] Damage numbers display correctly
- [ ] Critical hits show with emoji and correct damage
- [ ] Misses display "MISS"
- [ ] Dodges display "DODGE" (when implemented)
- [ ] Timing: Flash and chat bubble appear together
- [ ] No visual overlap issues
