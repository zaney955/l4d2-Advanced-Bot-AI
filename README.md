# L4D2 Advanced Bot AI

> A comprehensive VScript addon that enhances survivor bot AI in Left 4 Dead 2 with improved combat awareness, teamwork, and resource management.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![L4D2](https://img.shields.io/badge/Game-L4D2-blue.svg)](https://store.steampowered.com/app/550/)

## 📖 Overview

This addon uses VScript (Squirrel) to significantly improve survivor bot behavior in Left 4 Dead 2. It runs entirely on local servers and provides intelligent bot actions through scripted AI behaviors, making single-player or coop games more enjoyable without requiring human teammates.

### Key Features

- **🎯 Enhanced Combat AI**
  - Improved vision range and target detection
  - Better aiming accuracy and reaction speed
  - Smart special infected shoving and prioritization
  - Configurable damage multipliers per enemy type

- **🤝 Teamwork Coordination**
  - Coordinated rescue operations
  - Item sharing between survivors
  - Group-based tactics for horde events
  - Intelligent healing priorities

- **🎒 Resource Management**
  - Smart item pickup and usage
  - Backpack system for carrying items
  - Ammo and equipment management
  - Gas can scavenge mode support

- **⚙️ Highly Configurable**
  - 5 skill levels (0-4) for different playstyles
  - Extensive chat commands (`!botskill`, `!botmenu`, etc.)
  - Per-feature toggles and damage adjustments
  - Settings persistence across sessions

- **🌐 Multi-Language Support**
  - English and Chinese localization
  - Easy to extend for other languages

## 📊 Project Statistics

- **39 VScript files** (~1.0MB total)
- **65KB** main AI handler with 20+ AI tasks
- **Object-oriented task system** with priority-based execution
- **Real-time timers** running at 0.1s to 20s intervals
- **Third-party library**: VSLib by Rayman1103 (MIT licensed)

## 🚀 Installation

### Requirements

- Left 4 Dead 2 (Steam App ID 550)
- Local server (does **not** work on dedicated servers)

### Steps

1. **Download or clone this repository**
   ```bash
   git clone https://github.com/yourusername/l4d2-Advanced-Bot-AI.git
   ```

2. **Copy files to your L4D2 directory**
   ```
   l4d2-Advanced-Bot-AI/
   └── addons/
       └── left4dead2/
           └── scripts/
               └── vscripts/
                   ├── AIUpdateHandler.nut
                   ├── director_base_addon.nut
                   ├── ai_lib/
                   ├── ai_taskes/
                   └── rayman1103_vslib/
   ```

3. **Launch L4D2 and start a local server**
   - Main Menu → Play Campaign → Select any campaign
   - Or use console: `map <mapname>`

4. **Verify installation**
   - Open console with `~` key
   - Type: `script BotAI`
   - Should see a large table output indicating successful load

## ⚙️ Configuration

### Skill Levels

Set bot combat skill (0-4):

```
!botskill 0  # Beginner (reduced capabilities)
!botskill 1  # Easy
!botskill 2  # Normal (default)
!botskill 3  # Hard
!botskill 4  # Expert (maximum capabilities)
```

**What changes per level:**
- Vision and detection range
- Aiming accuracy and reaction time
- Shove effectiveness against specials
- Damage output (via multipliers)

### Menu System

Access the configuration menu:

```
!botmenu
```

Navigate with arrow keys or number keys. Options include:
- Damage multipliers (Witch, Special, Tank, Common)
- Feature toggles (scavenge mode, teleport, etc.)
- Combat behavior adjustments
- Debug and performance options

### Settings Persistence

Settings are automatically saved to:
```
advanced bot ai/settings.txt
```

This file is created in your L4D2 directory and loaded on each round start.

### Server Mode

For multiplayer servers with admin control:

1. Set `ServerMode = true` in AIUpdateHandler.nut
2. Configure admin Steam IDs via `ABA_IsAdmin()` function
3. Admin-only commands will require verification

## 🎮 Chat Commands

### Basic Commands

| Command | Description |
|---------|-------------|
| `!botskill <0-4>` | Set bot combat skill level |
| `!botmenu` | Open configuration menu |
| `!botdebug` | Toggle debug mode (verbose logging) |
| `!bothelp` | Show command help |

### Advanced Commands

See `ai_lib/ai_command.nut` for full list. Most commands support tab completion in console.

## 🏗️ Architecture

### Core Components

```
scripts/vscripts/
├── AIUpdateHandler.nut          # Main entry point (65KB)
├── director_base_addon.nut      # Loads AI system
├── scriptedmode_addon.nut       # Script mode integration
├── ai_lib/                      # Supporting libraries
│   ├── ai_utils.nut             # Core utilities (87KB)
│   ├── ai_command.nut           # Chat commands
│   ├── ai_events.nut            # Game event hooks
│   ├── ai_menu.nut              # HUD menu system
│   ├── ai_timers.nut            # Timer wrapper
│   ├── ai_navigator.nut         # Pathfinding
│   └── ai_localization.nut      # Translations
├── ai_taskes/                   # AI task implementations
│   ├── ai-classBase.nut         # Base AITask class
│   ├── ai-classSingle.nut       # Individual behaviors
│   ├── ai-classGroup.nut        # Team behaviors
│   ├── ai-hitInfected.nut       # Combat targeting
│   ├── ai-heal.nut              # Healing logic
│   └── [17 more task files]
└── rayman1103_vslib/            # Third-party library (DO NOT MODIFY)
```

### Data Flow

1. **Initialization**: `director_base_addon.nut` → `AIUpdateHandler.nut` → task registration
2. **Game Loop**: Timers call task update functions every tick (0.1s - 20s intervals)
3. **Task Execution**: Tasks check conditions (`shouldUpdate`) → execute logic (`playerUpdate`)
4. **Bot Actions**: Modify bot buttons, targets, movement vectors via NetProps

### Task System

**Object-oriented AI tasks with priority-based execution:**

- **AITaskSingle**: Individual bot behaviors
  - Combat targeting and shooting
  - Healing and item pickup
  - Throwable usage (molotov, pipe bomb)
  - Weapon upgrades and management

- **AITaskGroup**: Coordinated team behaviors
  - Rescue operations
  - Item sharing
  - Revive coordination
  - Defensive formations

Each task has:
- **Order priority**: Higher = executed first
- **Tick rate**: How often to run (higher = less frequent)
- **Compatibility constraints**: Which tasks can run together

## 🔧 Development

### Adding a New AI Task

1. Create a class in `ai_taskes/` extending `AITaskSingle` or `AITaskGroup`

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

2. Register in `BotAI.loadAITask()` with order and tick rate
3. Add to `BotAI.timerTask` if timer-based execution needed

### Adding a Chat Command

1. Add function in `ai_lib/ai_command.nut`
2. Register in `ChatTriggers` table
3. Use `BotAI.SendPlayer()` for user feedback
4. Call `BotAI.SaveSetting()` if modifying persistent state

### Debugging

- Enable debug mode: `BotAI.BotDebugMode = true`
- Use `BotAI.EasyPrint()` for console output with delays
- Check `BotAI.debugPerformance` for task execution timing
- **Note**: SCRIPT PERF WARNING messages are expected and can be ignored

### Important Constraints

- **Only works on local servers** - not dedicated servers
- Timer intervals are critical: too fast causes perf warnings, too slow hurts responsiveness
- Entity validation: Always use `BotAI.IsEntityValid()` and `BotAI.IsPlayerEntityValid()`
- NetProps access: Use VSLib wrappers or `NetProps.GetProp*()` functions
- **Do not break VSLib integration** - many utilities depend on it

## 🐛 Known Issues

- Bot pathfinding may be suboptimal in custom maps with poor nav mesh
- SCRIPT PERF WARNING messages are expected (high script load is normal)
- Some features may conflict with other AI-altering mods
- Bot decision-making can sometimes appear suboptimal (complex tradeoffs)

## 🤝 Contributing

Contributions are welcome! Areas for improvement:

- **Performance optimization** - Reduce script perf warnings
- **New AI tasks** - Add behaviors for specific situations
- **Localization** - Add translations for other languages
- **Bug fixes** - See Issues section

### Development Setup

1. Read `CLAUDE.md` for detailed project documentation
2. Test changes in local server (`map <mapname>` in console)
3. Check console for `[Bot AI]` log messages
4. Use `!botmenu` to test features
5. Preserve VSLib copyright notices

## 📄 License

- **Original Code**: [MIT License](LICENSE)
- **Third-Party Code**:
  - **VSLib by Rayman1103**: Retains its original [MIT License](scripts/vscripts/rayman1103_vslib/easylogic.nut)
  - You **must preserve** Rayman1103's copyright notices in all copies or derivatives

## 🙏 Credits

- **Rayman1103** for [VSLib](https://github.com/Rayman1103/VSLib) - Essential VScript helper library
- **Valve** for Left 4 Dead 2 and the VScript system
- **Community contributors** for testing and feedback

## 📞 Support

- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: See `CLAUDE.md` for developer documentation

---

**Made with ❤️ for the L4D2 community**

*Enhancing bot AI one script at a time since 2024*
