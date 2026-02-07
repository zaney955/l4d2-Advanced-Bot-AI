# CLAUDE.md

This file provides guidance to Claude Code (`claude.ai/code`) when working with this repository.

## Project Summary

This project is a Left 4 Dead 2 VScript addon that improves survivor bot AI on **local servers**.
It focuses on combat behavior, teamwork, navigation, rescue actions, and resource handling.

## Tech Stack

- Language: Squirrel (Source Engine VScript)
- Game: Left 4 Dead 2 (App ID 550)
- Script extension: `.nut`
- Third-party dependency: `rayman1103_vslib/` (MIT, do not modify)

## Repository Layout

```text
scripts/vscripts/
├── AIUpdateHandler.nut          # Main entry, global BotAI table, init + settings
├── director_base_addon.nut      # Script bootstrap
├── scriptedmode_addon.nut       # Script mode integration
├── ai_lib/
│   ├── ai_utils.nut             # Utility and combat helper functions
│   ├── ai_command.nut           # Chat commands and menu actions
│   ├── ai_events.nut            # Event hooks (damage, spawns, control)
│   ├── ai_menu.nut              # HUD menu
│   ├── ai_timers.nut            # Timer wrappers
│   ├── ai_navigator.nut         # Pathfinding and movement
│   └── ai_localization.nut      # i18n (EN/zh-CN/zh-TW)
├── ai_taskes/
│   ├── ai-classBase.nut         # AITask base
│   ├── ai-classSingle.nut       # Per-bot tasks
│   ├── ai-classGroup.nut        # Team/group tasks
│   └── ...                      # Task implementations
└── rayman1103_vslib/            # Third-party library (DO NOT MODIFY)
```

## Runtime Model

1. `director_base_addon.nut` loads AI scripts.
2. `AIUpdateHandler.nut` initializes `BotAI` on `round_start_post_nav`.
3. Timers drive periodic task checks/updates.
4. Task system (`AITaskSingle` / `AITaskGroup`) decides and executes bot actions.
5. Actions are applied via navigation helpers, button forcing, NetProps, and event hooks.

## Core Data Structures

- `BotAI.SurvivorBotList`: survivor bots
- `BotAI.SurvivorHumanList`: human survivors
- `BotAI.SpecialList`: active special infected
- `BotAI.projectileList`: tracked projectile entities
- `BotAI.timerTask`: timer-registered task callbacks
- `BotAI.BotPropertyMap`: per-bot state storage

## Critical Constraints

- Local server only; not designed for dedicated servers.
- Keep VSLib integration intact.
- Always validate entities before use:
  - `BotAI.IsEntityValid()`
  - `BotAI.IsPlayerEntityValid()`
- Be careful with tick frequency; over-frequent traces/path calls can cause script perf pressure.
- `SCRIPT PERF WARNING` may appear under heavy load; avoid unnecessary expensive calls.

## Configuration and Persistence

Settings are saved to `advanced bot ai/settings.txt`.

Key config fields include:
- `BotCombatSkill` (0-4 internal index)
- distance/tp controls (`FollowRange`, `TeleportDistance`, `SaveTeleport`)
- damage multipliers (`Witch/Special/Tank/Common/NonAlive`)
- behavior toggles (pathfinding, throwables, melee, etc.)
- combat mode toggles (`SpreadCompensation`, `OverpoweredCombatBoost`)

### Overpowered Combat Boost Mode

`OverpoweredCombatBoost` is a **master switch** for non-vanilla combat boosts.
When OFF, bots keep baseline behavior and no longer receive those boosted mechanics.
When ON, advanced boosts can activate (depending on skill/conditions), including:
- extra combat compensation and special handling
- enhanced shove/melee/reactive behavior
- damage/protection related boosted paths

Related helper APIs in `AIUpdateHandler.nut`:
- `BotAI.IsOverpoweredCombatBoostEnabled()`
- `BotAI.SetOverpoweredCombatBoostEnabled(enabled)`
- `BotAI.IsOverpoweredCombatBoostSkillAbove(skill)`

### Spread Compensation

`SpreadCompensation` only works in high-skill situations and is effectively gated by overpowered combat mode logic.

## Common Development Workflows

### Add a new AI task

1. Create class in `ai_taskes/` extending `AITaskSingle` or `AITaskGroup`.
2. Implement checker (`singleUpdateChecker` / `GroupUpdateChecker`).
3. Implement `playerUpdate`.
4. Register in `BotAI.loadAITask()` with order/tick policy.
5. Add timer registration if required.

Example:

```squirrel
class ::AITaskMyTask extends AITaskSingle {
    constructor() {
        base.constructor(order, tickRate, compatible, force);
        name = "myTask";
    }

    function singleUpdateChecker(player) {
        return BotAI.IsPlayerEntityValid(player) && <condition>;
    }

    function playerUpdate(player) {
        // task logic
    }
}
```

### Add a chat command

1. Add command handler in `ai_lib/ai_command.nut`.
2. Register in `ChatTriggers`.
3. Use `BotAI.SendPlayer()` for feedback.
4. If setting changed, call `BotAI.SaveSetting()`.

### Add/update menu option

1. Add localization keys in `ai_lib/ai_localization.nut`.
2. Add command callback in `ai_lib/ai_command.nut`.
3. Bind option in the menu construction flow.
4. Persist setting when toggled.

## Damage and Combat Notes

Damage multipliers are applied in event-based damage flow (`ai_events.nut`, `OnTakeDamage` path).

Main multipliers:
- `BotAI.WitchDamageMultiplier`
- `BotAI.SpecialDamageMultiplier`
- `BotAI.TankDamageMultiplier`
- `BotAI.CommonDamageMultiplier`
- `BotAI.NonAliveDamageMultiplier`

## Navigation Notes

- Use `BotAI.getNavigator(player)` for path control.
- Core methods: `moveTo`, `hasPath`, `clearPath`.
- Movement vectors may use `BotAI.botMoveMap`.
- Use edge safety checks before forcing movement.

## Debugging

- Enable `BotAI.BotDebugMode` for verbose outputs.
- Use helper print methods (e.g., delayed/easy prints) for readable diagnostics.
- Watch console for `[Bot AI]` lines during scenario validation.

## Test Checklist (In Game)

1. Launch L4D2 local server.
2. Reload map (`map <mapname>`).
3. Exercise `!botmenu` and relevant chat commands.
4. Verify settings persistence across map transition/round end.
5. Validate bot behavior under normal and high-pressure encounters.

## Performance Guidance

- Prefer cached lookups over repeated scans.
- Keep expensive operations on slower intervals where possible.
- Use fill-tick patterns for wide fan-out task workloads.
- Avoid introducing per-tick heavy traces for all bots simultaneously.

## License

- Project code: MIT License
- VSLib: MIT License (keep copyright notices)

