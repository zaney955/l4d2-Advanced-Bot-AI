# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an addon for Left 4 Dead 2 that uses VScript (Squirrel) to enhance survivor bot AI. The mod runs entirely on the local server and improves bot combat awareness, teamwork, and resource management through scripted AI behaviors.

## Language and Framework

- **Language**: Squirrel (VScript for Source Engine)
- **Game**: Left 4 Dead 2 (App ID 550)
- **File Extension**: `.nut`
- **Third-Party Library**: VSLib by Rayman1103 (MIT licensed)

## Architecture

### Core Components

**AIUpdateHandler.nut** (65KB, main entry point)
- Global `BotAI` table containing all AI state, configuration, and utility functions
- Initializes on `round_start_post_nav` event
- Sets up repeating timers for AI behaviors (0.1s to 20s intervals)
- Manages bot property maps, damage multipliers, and feature toggles

**Task System** (`ai_taskes/` directory)
- Object-oriented AI task system with base class `AITask`
- Two main task types:
  - `AITaskSingle`: Individual bot behaviors (combat, healing, item pickup)
  - `AITaskGroup`: Coordinated team behaviors (rescuing, sharing items)
- Tasks have order priority, tick rates, and compatibility constraints
- Tasks are sorted and executed based on priority order

**AI Libraries** (`ai_lib/` directory)
- `ai_utils.nut`: Core utilities (87KB) - entity validation, navigation, combat calculations
- `ai_command.nut`: Chat commands (`!botskill`, `!botmenu`, etc.)
- `ai_events.nut`: Game event hooks (damage, spawns, state changes)
- `ai_menu.nut`: HUD menu system for configuration
- `ai_timers.nut`: Timer-based task execution wrapper
- `ai_navigator.nut`: Custom pathfinding system
- `ai_localization.nut`: Multi-language support (Chinese/English)

**VSLib** (`rayman1103_vslib/` directory)
- Third-party library providing helper functions
- Key modules: `easylogic.nut`, `player.nut`, `entity.nut`, `timer.nut`, `hud.nut`
- **Do not modify** - preserve copyright notices

### Data Flow

1. **Initialization**: `director_base_addon.nut` → `AIUpdateHandler.nut` → task registration
2. **Game Loop**: Timers call task update functions every tick
3. **Task Execution**: Tasks check conditions (`shouldUpdate`) → execute logic (`playerUpdate`)
4. **Bot Actions**: Modify bot buttons, targets, movement vectors via NetProps

### Key Global Tables

- `BotAI.SurvivorBotList`: Array of bot entities
- `BotAI.SurvivorHumanList`: Array of human players
- `BotAI.SpecialList`: Active special infected
- `BotAI.projectileList`: Tracked projectiles (spitter spit, rocks)
- `BotAI.timerTask`: Named task functions for timer system
- `BotAI.BotPropertyMap`: Per-bot state storage

## Configuration System

### Skill Levels
BotCombatSkill (0-4, internally 0-indexed) controls:
- Vision range and detection capabilities
- Aiming accuracy and reaction speed
- Shove effectiveness against specials
- Damage output (via multipliers)

### Settings Storage
- Saved to `advanced bot ai/settings.txt`
- Loaded on round start
- Includes damage multipliers, toggleable features, combat skill

### Server Mode
When `ServerMode = true`, admin-only commands require:
- Steam ID verification via `ABA_IsAdmin()`
- Certain menu options restricted to administrators

## Common Development Tasks

### Adding a New AI Task

1. Create class in `ai_taskes/` extending `AITaskSingle` or `AITaskGroup`
2. Implement `singleUpdateChecker()` (Single) or `GroupUpdateChecker()` (Group)
3. Implement `playerUpdate()` with task logic
4. Register in `BotAI.loadAITask()` with order and tick rate
5. Add to `BotAI.timerTask` if timer-based execution needed

Example structure:
```squirrel
class ::AITaskMyTask extends AITaskSingle {
    constructor() {
        base.constructor(order, tickRate, compatible, force);
        name = "myTask";
    }

    function singleUpdateChecker(player) {
        // Return true if conditions met
        return BotAI.IsPlayerEntityValid(player) && <condition>;
    }

    function playerUpdate(player) {
        // Task implementation
    }
}
```

### Adding a Chat Command

1. Add function in `ai_lib/ai_command.nut`
2. Register in `ChatTriggers` table
3. Use `BotAI.SendPlayer()` for user feedback
4. Call `BotAI.SaveSetting()` if modifying persistent state

### Debugging

- Set `BotAI.BotDebugMode = true` for verbose logging
- Use `BotAI.EasyPrint()` for console output with delays
- Check `BotAI.debugPerformance` for task execution timing
- SCRIPT PERF WARNING warnings are expected and can be ignored

## Important Constraints

- **Only works on local servers** - not dedicated servers
- Timer intervals are critical: too fast causes perf warnings, too slow hurts responsiveness
- Entity validation: Always use `BotAI.IsEntityValid()` and `BotAI.IsPlayerEntityValid()`
- NetProps access: Use VSLib wrappers or `NetProps.GetProp*()` functions
- Navigation: Custom nav system via `BotAI.getNavigator(player)`
- **Do not break VSLib integration** - many utilities depend on it

## Damage System

Damage multipliers (1.0 = normal):
- `BotAI.WitchDamageMultiplier` vs Witches
- `BotAI.SpecialDamageMultiplier` vs Special Infected (except Tank)
- `BotAI.TankDamageMultiplier` vs Tanks
- `BotAI.CommonDamageMultiplier` vs Common Infected

Applied via `OnTakeDamage` event hooks in `ai_events.nut`

## Navigation and Movement

- Custom pathfinding: `BotAI.getNavigator(player).moveTo()`, `hasPath()`, `clearPath()`
- Movement vectors: `BotAI.botMoveMap[player]` sets velocity
- Edge detection: `BotAI.isEdge(player, vector)` prevents falls
- Ladders: Pre-cached in `BotAI.ladders` array on load

## Special Systems

**Gas Can Scavenge Mode**
- `BotAI.BotsNeedToFind` tracks target item (weapon_gascan, weapon_cola_bottles)
- Tasks: `AITaskTryTraceGascan`, `AITaskTryTakeGascan`
- Model mapping: `BotAI.modelMap` and `BotAI.takeElse` for prop recognition

**Ping System**
- Bound to `+alt2` key
- Stores selected bot and target in `BotAI.pingEntity` and `BotAI.pingPoint`
- Right-click item swap via `OnGameEvent_weapon_fire` event

**Combat Behavior**
- Target priority via `BotAI.getBotTarget()`, `setBotTarget()`
- Special infected shoving via `BotAI.getBotShoveTarget()`
- Avoidance system: `BotAI.getBotAvoid()`, `setBotAvoid()`
- Smoker tongue tracking: `BotAI.setSmokerTarget()`

## File Organization

```
scripts/vscripts/
├── AIUpdateHandler.nut          # Main entry point, global BotAI table
├── director_base_addon.nut      # Loads AI system
├── scriptedmode_addon.nut       # Script mode integration
├── ai_lib/                      # Supporting libraries
│   ├── ai_utils.nut             # Core utilities (largest file)
│   ├── ai_command.nut           # Chat commands
│   ├── ai_events.nut            # Game event hooks
│   ├── ai_menu.nut              # HUD menu
│   ├── ai_timers.nut            # Timer system
│   ├── ai_navigator.nut         # Pathfinding
│   └── ai_localization.nut      # Translations
├── ai_taskes/                   # AI task implementations
│   ├── ai-classBase.nut         # Base AITask class
│   ├── ai-classSingle.nut       # AITaskSingle (individual behaviors)
│   ├── ai-classGroup.nut        # AITaskGroup (team behaviors)
│   ├── ai-hitInfected.nut       # Combat targeting
│   ├── ai-heal.nut              # Healing logic
│   └── [17 other task files]
└── rayman1103_vslib/            # Third-party library (DO NOT MODIFY)
```

## Testing Changes

1. Load L4D2 and start a local server
2. Changes require map reload (`map <mapname>` in console)
3. Check console for `[Bot AI]` log messages
4. Use `!botmenu` or chat commands to test features
5. Monitor for SCRIPT PERF WARNING (expected, indicates high script load)

## Performance Considerations

- Task tick rates determine how often tasks run (higher = less frequent)
- Use `fillTick` for tasks that need to spread execution across ticks
- Cache entity lookups using `ChunkMap` spatial hashing
- Limit expensive operations (traces, navigation) with appropriate tick rates
- `BotAI.callCache` and `BotAI.areaCache` provide caching layers

## License

- Original code: MIT License
- VSLib: MIT License (preserve copyright notices)
- See LICENSE file for details
