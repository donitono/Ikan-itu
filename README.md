# 🐳 ModernAutoFish - Advanced Roblox Fishing Bot

<div align="center">

![ModernAutoFish Logo](https://img.shields.io/badge/ModernAutoFish-v2.0-blue?style=for-the-badge)
![Roblox](https://img.shields.io/badge/Platform-Roblox-00A2FF?style=for-the-badge&logo=roblox)
![Lua](https://img.shields.io/badge/Language-Lua-2C2D72?style=for-the-badge&logo=lua)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**The most advanced and feature-rich auto-fishing script for Roblox fishing games**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [API](#-api) • [Contributing](#-contributing)

</div>

---

## 🌟 Features

### 🎣 **Intelligent Fishing AI**
- **Smart Mode**: Advanced AI with realistic timing and human-like behavior
- **Secure Mode**: Anti-detection algorithms for safe botting
- **Auto Mode**: Continuous fishing with loop optimization
- **Animation-Aware**: Monitors game animations for perfect timing

### 🎯 **Auto Sell System**
- **Smart Filtering**: Sell by fish rarity (Common, Uncommon, Rare, Epic, Legendary, Mythic)
- **Threshold Management**: Auto-sell when inventory reaches specified count
- **Server Sync**: Synchronizes settings across game sessions
- **Teleport Integration**: Auto-teleports to NPC sellers

### ✨ **Enchant System** *(NEW!)*
- **14 Enchant Types**: XPerienced, Leprechaun, Gold Digger, Mutation Hunter, dan lainnya
- **Smart Selection**: Multi-select target enchants dengan descriptions
- **Auto Rolling**: Automated enchanting dengan detection system
- **Altar Navigation**: Auto teleport ke enchanting altar
- **Hotbar Management**: Auto setup enchant stones
- **Safety Features**: Distance checks, max rolls, emergency stop

### 📊 **Advanced Analytics Dashboard**
- **Real-time Statistics**: Fish count, rare catches, session time
- **Location Heatmap**: Efficiency tracking for different fishing spots
- **Optimal Time Analysis**: Best hours for rare fish catches
- **Rarity Distribution**: Visual breakdown of catch types

### 🚀 **Movement Enhancement**
- **Float Mode**: Fly with WASD + Space/Shift controls
- **No Clip**: Walk through walls and obstacles
- **Auto Spinner**: Randomize character rotation while fishing
- **Speed/Jump Control**: Customizable movement parameters

### 🌍 **Teleportation System**
- **Island Quick Travel**: One-click teleport to all major locations
- **Player Teleport**: Jump to any player in the server
- **Enhancement Altar**: Direct teleport to enchanting locations
- **Smart Coordinates**: Pre-configured optimal positions

### ⚡ **Quality of Life Features**
- **AntiAFK System**: Prevents idle disconnection
- **Auto Enhancement**: Automated enchanting altar interactions
- **Weather Control**: Auto-purchase weather events
- **Network Management**: Auto-reconnect on disconnection
- **Rod Orientation Fix**: Fixes backwards fishing rod glitch

### 🎨 **Modern UI Design**
- **Tabbed Interface**: Organized feature categories
- **Responsive Design**: Works on all screen sizes
- **Floating Mode**: Minimizable to small floating button
- **Dark Theme**: Easy on the eyes during long sessions
- **Real-time Updates**: Live status indicators and statistics

---

## 📁 Project Structure

```
ModernAutoFish/
├── main.lua                    # Original monolithic version
├── main_modular.lua           # New modular entry point
├── main_modular_ui_preserved.lua # UI Preserved version with Enchant System
├── modules/
│   ├── core/
│   │   ├── config.lua         # Configuration and constants
│   │   └── utils.lua          # Utility functions
│   ├── ui/
│   │   ├── baseUI.lua         # Base UI framework
│   │   ├── fishingAITab.lua   # Fishing AI tab module
│   │   ├── teleportTab.lua    # Teleport tab module
│   │   ├── playerTab.lua      # Player tab module
│   │   ├── featureTab.lua     # Feature tab module
│   │   ├── enchantTab.lua     # Enchant system tab module ⭐NEW
│   │   └── dashboardTab.lua   # Dashboard tab module
│   └── features/
│       ├── autoSell.lua       # Auto sell system
│       ├── antiAFK.lua        # Anti-AFK system
│       ├── movement.lua       # Movement enhancements
│       ├── enhancement.lua    # Auto enhancement
│       └── networking.lua     # Network management
├── README.md
└── LICENSE
```

---

## 🚀 Installation

### Method 1: Load from GitHub (Recommended)

**Standard Version:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/Ikan-itu/main/main_modular.lua"))()
```

**Enhanced Version with Enchant System:** ⭐NEW
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/Ikan-itu/main/main_modular_ui_preserved.lua"))()
```

### Method 2: Manual Installation
1. Copy the content of your preferred version from above
2. Paste into your Roblox executor
3. Execute the script

### Method 3: Development Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/donitono/Ikan-itu.git
   ```
2. Use the modular version for easier customization
3. Modify individual modules as needed

---

## 🎮 Usage

### Basic Usage
1. Execute the script in your fishing game
2. The UI will appear automatically
3. Navigate between tabs using the sidebar
4. Configure settings in each tab
5. Start fishing with your preferred mode

### Quick Start Commands
```lua
-- Start Smart AI fishing
_G.ModernAutoFish.Start()

-- Stop fishing
_G.ModernAutoFish.Stop()

-- Toggle Auto Sell
_G.ModernAutoFish.ToggleAutoSell()

-- Enable Float Mode
_G.ModernAutoFish.ToggleFloat()

-- View statistics
print(_G.ModernAutoFish.GetStats())
```

---

## 🛠 API Reference

### Core Functions
```lua
_G.ModernAutoFish = {
    -- Fishing Control
    Start()                     -- Start smart fishing
    Stop()                      -- Stop fishing
    SetMode(mode)              -- Set fishing mode ("smart", "secure", "auto")
    
    -- Feature Toggles
    ToggleAntiAFK()            -- Toggle anti-AFK system
    ToggleAutoSell()           -- Toggle auto sell
    ToggleFloat()              -- Toggle float mode
    ToggleNoClip()             -- Toggle no clip
    
    -- Auto Sell Management
    SetSellThreshold(number)   -- Set auto sell threshold (1-1000)
    GetAutoSellStatus()        -- Get auto sell state
    ForceAutoSell()            -- Force immediate auto sell
    
    -- Statistics
    GetStats()                 -- Get dashboard statistics
    ClearStats()               -- Clear all statistics
    
    -- System Access
    Config                     -- Configuration module
    Utils                      -- Utility functions
    FishingCore               -- Core fishing system
    Dashboard                 -- Analytics system
    AutoSell                  -- Auto sell system
    MovementSystem            -- Movement enhancements
}
```

### Configuration Options
```lua
-- Fishing Settings
Config.Settings = {
    mode = "smart",                    -- Fishing mode
    autoRecastDelay = 0.4,            -- Delay between casts
    safeModeChance = 70,              -- Perfect cast percentage
    enabled = false,                   -- Auto fishing enabled
    autoModeEnabled = false           -- Auto mode enabled
}

-- Fish Rarity Categories
Config.FishRarity = {
    MYTHIC = {...},
    LEGENDARY = {...},
    EPIC = {...},
    RARE = {...},
    UNCOMMON = {...},
    COMMON = {...}
}

-- Island Locations
Config.IslandLocations = {
    ["🏝️Kohana Volcano"] = CFrame.new(...),
    ["🏝️Crater Island"] = CFrame.new(...),
    -- ... more locations
}
```

---

## 🎯 Game Compatibility

### Supported Games
- **Fisch** (Primary target)
- Most Roblox fishing games with similar mechanics

### Requirements
- Roblox Executor (Synapse X, Krnl, etc.)
- Game with fishing mechanics
- Remote events for fishing actions

---

## 🔒 Safety Features

### Anti-Detection
- **Randomized Timing**: Human-like delays and variations
- **Smart Mode**: Realistic fishing patterns
- **Rate Limiting**: Prevents spam detection
- **Error Handling**: Graceful failure recovery

### Secure Operation
- **Local Processing**: Most logic runs client-side
- **Minimal Network Calls**: Reduces detection risk
- **Fallback Systems**: Multiple methods for each action
- **Safe Defaults**: Conservative settings out of the box

---

## 🔧 Customization

### Adding New Features
1. Create a new module in the appropriate folder:
   ```lua
   -- modules/features/myFeature.lua
   local MyFeature = {}
   
   function MyFeature.Initialize()
       -- Initialization code
   end
   
   function MyFeature.CreateUI(parent, position)
       -- UI creation code
   end
   
   return MyFeature
   ```

2. Import and initialize in `main_modular.lua`:
   ```lua
   local MyFeature = require(script.modules.features.myFeature)
   MyFeature.Initialize()
   ```

### Modifying Existing Features
- Edit individual module files
- Changes are isolated and don't affect other systems
- Easy to test and debug

### UI Customization
- Modify `Config.Colors` for theme changes
- Edit individual tab modules for layout changes
- Use `BaseUI` components for consistency

---

## 📊 Performance

### Optimizations
- **Modular Loading**: Only load needed components
- **Efficient Updates**: 2-second refresh cycles for non-critical data
- **Memory Management**: Proper cleanup and garbage collection
- **Network Optimization**: Batched requests and caching

### Resource Usage
- **CPU**: Minimal impact during normal operation
- **Memory**: ~5-10MB depending on features used
- **Network**: Low bandwidth usage with smart caching

---

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test thoroughly
5. Commit: `git commit -m 'Add amazing feature'`
6. Push: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Coding Standards
- Use descriptive variable names
- Comment complex logic
- Follow existing code style
- Test all changes thoroughly
- Update documentation as needed

### Bug Reports
- Use the GitHub issue tracker
- Provide detailed reproduction steps
- Include error messages and logs
- Specify game and executor used

---

## 📝 Changelog

### v2.0.0 (Latest)
- ✨ Complete modular rewrite
- 🎯 Advanced auto sell system with server sync
- 📊 Enhanced analytics dashboard
- 🚀 Movement enhancement system
- 🎨 Modern UI with improved navigation
- 🔒 Better anti-detection mechanisms

### v1.0.0
- 🎣 Basic auto fishing functionality
- 🌍 Teleportation system
- 📈 Simple statistics tracking
- 🛡️ AntiAFK system

---

## � Changelog

### v2.2.0 - Enchant System Update ⭐
- ✨ **NEW: Complete Enchant System**
  - 14 enchant types with descriptions
  - Auto teleport to enchanting altar
  - Smart hotbar management 
  - Target enchant selection with checkboxes
  - Auto rolling with max attempts setting
  - Real-time status monitoring
  - Safety features and emergency stop
- 🎣 **Enhanced Fish Database**
  - 150+ authentic fish names from game data
  - Complete variant system (Galaxy, Corrupt, etc.)
  - Improved rarity categories
  - Special item detection (plaques, rods, enchant items)
- 🎨 **UI Improvements**
  - New Enchant tab in main interface
  - Distance tracking to altar
  - Roll progress indicators
  - Enhanced visual feedback

### v2.1.0 - UI Preserved
- 🎨 Preserved original modern UI design
- 🔧 Modular architecture implementation
- 📊 Enhanced dashboard system
- 🚀 Movement enhancements (Float/NoClip)

### v2.0.0 - Major Rewrite
- 🏗️ Complete modular architecture
- 🤖 Smart AI fishing algorithms
- 🎯 Advanced auto-sell system
- 🌍 Comprehensive teleport system

---

## �📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⚠️ Disclaimer

This script is for educational purposes only. Use at your own risk. The developers are not responsible for any consequences resulting from the use of this script, including but not limited to account bans or data loss.

---

## 🙏 Acknowledgments

- Thanks to the Roblox scripting community
- Special thanks to contributors and testers
- Inspired by various open-source Roblox scripts

---

<div align="center">

**Star ⭐ this repository if you found it helpful!**

[Report Bug](https://github.com/donitono/Ikan-itu/issues) • [Request Feature](https://github.com/donitono/Ikan-itu/issues) • [Join Discord](https://discord.gg/your-invite)

</div>
