--[[
🔧 Configuration Module for FISH-IT
Centralized configuration for all systems

Author: donitono
Repository: https://github.com/donitono/Ikan-itu
Version: 2.1.0
--]]

local Config = {
    -- Core fishing settings
    mode = "smart",  -- "smart", "secure", "fast"
    autoRecastDelay = 0.4,
    safeModeChance = 70,
    secure_max_actions_per_minute = 12000000,
    secure_detection_cooldown = 5,
    enabled = false,
    
    -- Feature toggles
    antiAfkEnabled = false,
    enhancementEnabled = false,
    autoReconnectEnabled = false,
    autoModeEnabled = false,
    
    -- Smart Enchant settings
    smartEnchantEnabled = false,
    smartEnchantMaxAttempts = 100,
    
    -- UI settings
    uiTheme = "dark",
    showNotifications = true,
    
    -- Performance settings
    updateRate = 60, -- Hz
    maxLogEntries = 1000
}

return Config
