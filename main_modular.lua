-- main_modular.lua
-- Modular version of ModernAutoFish
-- Entry point that loads all modules

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Must run on client
if not RunService:IsClient() then
    warn("modern_autofish: must run as a LocalScript on the client (StarterPlayerScripts). Aborting.")
    return
end

if not LocalPlayer then
    warn("modern_autofish: LocalPlayer missing. Run as LocalScript while in Play mode.")
    return
end

-- Load core modules
local Config = require(script.modules.core.config)
local Utils = require(script.modules.core.utils)

-- Load UI modules
local BaseUI = require(script.modules.ui.baseUI)
local FishingAITab = require(script.modules.ui.fishingAITab)
local TeleportTab = require(script.modules.ui.teleportTab)
local PlayerTab = require(script.modules.ui.playerTab)
local FeatureTab = require(script.modules.ui.featureTab)
local DashboardTab = require(script.modules.ui.dashboardTab)

-- Load feature modules
local AutoSell = require(script.modules.features.autoSell)

-- Initialize systems
local ModernAutoFish = {}

-- Session management
local sessionId = 0
local autoModeSessionId = 0

-- Core systems (simplified for modular structure)
local FishingCore = {
    enabled = false,
    mode = "smart"
}

local AntiAFK = {
    enabled = false,
    sessionId = 0
}

local Dashboard = {
    fishCaught = {},
    rareFishCaught = {},
    locationStats = {},
    sessionStats = {
        startTime = tick(),
        fishCount = 0,
        rareCount = 0,
        totalValue = 0,
        currentLocation = "Unknown"
    },
    heatmap = {},
    optimalTimes = {}
}

-- Simplified fishing core functions
function FishingCore.StartSecureMode()
    FishingCore.mode = "secure"
    FishingCore.enabled = true
    sessionId = sessionId + 1
    Utils.Notify("Fishing Core", "🔒 Secure Mode started")
    -- Add actual fishing logic here
end

function FishingCore.StopSecureMode()
    FishingCore.enabled = false
    sessionId = sessionId + 1
    Utils.Notify("Fishing Core", "🔒 Secure Mode stopped")
end

function FishingCore.StartSmartMode()
    FishingCore.mode = "smart"
    FishingCore.enabled = true
    sessionId = sessionId + 1
    Utils.Notify("Fishing Core", "🧠 Smart AI Mode started")
    -- Add actual fishing logic here
end

function FishingCore.StopSmartMode()
    FishingCore.enabled = false
    sessionId = sessionId + 1
    Utils.Notify("Fishing Core", "🧠 Smart AI Mode stopped")
end

function FishingCore.StartAutoMode()
    Config.Settings.autoModeEnabled = true
    autoModeSessionId = autoModeSessionId + 1
    Utils.Notify("Fishing Core", "🔥 Auto Mode started")
    -- Add auto mode logic here
end

function FishingCore.StopAutoMode()
    Config.Settings.autoModeEnabled = false
    autoModeSessionId = autoModeSessionId + 1
    Utils.Notify("Fishing Core", "🔥 Auto Mode stopped")
end

-- Simplified AntiAFK system
function AntiAFK.Start()
    AntiAFK.enabled = true
    AntiAFK.sessionId = AntiAFK.sessionId + 1
    Utils.Notify("AntiAFK", "🛡️ AntiAFK started")
    -- Add actual AntiAFK logic here
end

function AntiAFK.Stop()
    AntiAFK.enabled = false
    AntiAFK.sessionId = AntiAFK.sessionId + 1
    Utils.Notify("AntiAFK", "🛡️ AntiAFK stopped")
end

-- Movement system (simplified)
local MovementSystem = {
    floatEnabled = false,
    noClipEnabled = false,
    spinnerEnabled = false,
    spinnerSpeed = 2
}

function MovementSystem.EnableFloat()
    MovementSystem.floatEnabled = true
    Utils.Notify("Movement", "🚀 Float enabled")
    -- Add actual float logic here
end

function MovementSystem.DisableFloat()
    MovementSystem.floatEnabled = false
    Utils.Notify("Movement", "🚀 Float disabled")
end

function MovementSystem.EnableNoClip()
    MovementSystem.noClipEnabled = true
    Utils.Notify("Movement", "👻 No Clip enabled")
    -- Add actual no clip logic here
end

function MovementSystem.DisableNoClip()
    MovementSystem.noClipEnabled = false
    Utils.Notify("Movement", "👻 No Clip disabled")
end

function MovementSystem.EnableAutoSpinner()
    MovementSystem.spinnerEnabled = true
    Utils.Notify("Movement", "🌪️ Auto Spinner enabled")
    -- Add actual spinner logic here
end

function MovementSystem.DisableAutoSpinner()
    MovementSystem.spinnerEnabled = false
    Utils.Notify("Movement", "🌪️ Auto Spinner disabled")
end

function MovementSystem.SetSpinnerSpeed(speed)
    if speed and speed > 0 and speed <= 10 then
        MovementSystem.spinnerSpeed = speed
        Utils.Notify("Movement", "🌪️ Spinner speed set to: " .. speed)
    end
end

function MovementSystem.ToggleSpinnerDirection()
    Utils.Notify("Movement", "🌪️ Spinner direction toggled")
end

-- Enhancement system (simplified)
local EnhancementSystem = {}

-- Network system (simplified)
local NetworkSystem = {}

-- Build UI
function ModernAutoFish.BuildUI()
    -- Create main frame
    local screenGui, panel = BaseUI.CreateMainFrame()
    
    -- Create header with drag functionality
    local header, title, btnContainer = BaseUI.CreateHeader(panel)
    BaseUI.AddDragFunctionality(header, panel)
    
    -- Create header buttons
    local minimizeBtn, reloadBtn, closeBtn = BaseUI.CreateHeaderButtons(btnContainer, {
        onMinimize = function()
            panel.Visible = false
            floatBtn.Visible = true
            Utils.Notify("modern_autofish", "Minimized to floating mode")
        end,
        onReload = function()
            -- Add reload logic
            Utils.Notify("modern_autofish", "🔄 Reloading...")
            task.wait(1)
            -- Rejoin logic would go here
        end,
        onClose = function()
            FishingCore.enabled = false
            sessionId = sessionId + 1
            Config.Settings.autoModeEnabled = false
            autoModeSessionId = autoModeSessionId + 1
            AntiAFK.enabled = false
            Utils.Notify("modern_autofish", "ModernAutoFish closed")
            if screenGui and screenGui.Parent then 
                screenGui:Destroy() 
            end
        end
    })
    
    -- Create floating button
    local floatBtn = BaseUI.CreateFloatingButton(screenGui, function()
        panel.Visible = true
        floatBtn.Visible = false
        Utils.Notify("modern_autofish", "Restored from floating mode")
    end)
    
    -- Create sidebar
    local sidebar = BaseUI.CreateSidebar(panel)
    
    -- Create content area
    local contentContainer, contentTitle = BaseUI.CreateContentArea(panel)
    
    -- Create tab buttons
    local fishingAITabBtn = BaseUI.CreateTabButton(sidebar, 10, "🤖 Fishing AI", true)
    local teleportTabBtn = BaseUI.CreateTabButton(sidebar, 60, "🌍 Teleport", false)
    local playerTabBtn = BaseUI.CreateTabButton(sidebar, 110, "👥 Player", false)
    local featureTabBtn = BaseUI.CreateTabButton(sidebar, 160, "⚡ Fitur", false)
    local dashboardTabBtn = BaseUI.CreateTabButton(sidebar, 210, "📊 Dashboard", false)
    
    -- Create tab frames
    local fishingAIFrame, fishingAIStatusUpdaters = FishingAITab.Create(contentContainer, FishingCore, AutoSell, AntiAFK)
    local teleportFrame = TeleportTab.Create(contentContainer)
    local playerFrame = PlayerTab.Create(contentContainer)
    local featureFrame = FeatureTab.Create(contentContainer, MovementSystem, EnhancementSystem, NetworkSystem)
    local dashboardFrame, dashboardUpdater = DashboardTab.Create(contentContainer, Dashboard)
    
    -- Tab switching logic
    local tabs = {
        FishingAI = fishingAIFrame,
        Teleport = teleportFrame,
        Player = playerFrame,
        Feature = featureFrame,
        Dashboard = dashboardFrame
    }
    
    local tabButtons = {
        FishingAI = fishingAITabBtn,
        Teleport = teleportTabBtn,
        Player = playerTabBtn,
        Feature = featureTabBtn,
        Dashboard = dashboardTabBtn
    }
    
    local function SwitchTo(name)
        for k, v in pairs(tabs) do
            v.Visible = (k == name)
        end
        
        -- Update tab colors
        for k, btn in pairs(tabButtons) do
            if k == name then
                btn.BackgroundColor3 = Color3.fromRGB(45,45,50)
                btn.TextColor3 = Color3.fromRGB(235,235,235)
            else
                btn.BackgroundColor3 = Color3.fromRGB(40,40,46)
                btn.TextColor3 = Color3.fromRGB(200,200,200)
            end
        end
        
        -- Update content title
        local titles = {
            FishingAI = "Smart AI Fishing Configuration",
            Teleport = "Island Locations",
            Player = "Player Teleport",
            Feature = "Character Features",
            Dashboard = "Fishing Analytics"
        }
        contentTitle.Text = titles[name] or "ModernAutoFish"
    end
    
    -- Connect tab buttons
    fishingAITabBtn.MouseButton1Click:Connect(function() SwitchTo("FishingAI") end)
    teleportTabBtn.MouseButton1Click:Connect(function() SwitchTo("Teleport") end)
    playerTabBtn.MouseButton1Click:Connect(function() SwitchTo("Player") end)
    featureTabBtn.MouseButton1Click:Connect(function() SwitchTo("Feature") end)
    dashboardTabBtn.MouseButton1Click:Connect(function() SwitchTo("Dashboard") end)
    
    -- Start with Fishing AI tab
    SwitchTo("FishingAI")
    
    -- Start dashboard updater
    task.spawn(function()
        while screenGui.Parent do
            if dashboardFrame.Visible then
                dashboardUpdater()
            end
            task.wait(2)
        end
    end)
    
    Utils.Notify("modern_autofish", "Modular UI loaded successfully!")
    
    return screenGui
end

-- Initialize AutoSell
AutoSell.Initialize()

-- Build UI
ModernAutoFish.BuildUI()

-- Location tracker
task.spawn(function()
    while true do
        local newLocation = Utils.DetectCurrentLocation()
        if newLocation ~= Dashboard.sessionStats.currentLocation then
            Dashboard.sessionStats.currentLocation = newLocation
            print("[Dashboard] Location changed to:", newLocation)
        end
        task.wait(3)
    end
end)

-- Expose API
_G.ModernAutoFish = {
    Start = function() 
        FishingCore.StartSmartMode()
    end,
    Stop = function() 
        FishingCore.StopSmartMode()
    end,
    SetMode = function(mode) 
        FishingCore.mode = mode 
    end,
    ToggleAntiAFK = function() 
        if AntiAFK.enabled then
            AntiAFK.Stop()
        else
            AntiAFK.Start()
        end
    end,
    
    -- Dashboard API
    GetStats = function() return Dashboard end,
    ClearStats = function() 
        Dashboard.fishCaught = {}
        Dashboard.rareFishCaught = {}
        Dashboard.locationStats = {}
        Dashboard.heatmap = {}
        Dashboard.optimalTimes = {}
        Dashboard.sessionStats.fishCount = 0
        Dashboard.sessionStats.rareCount = 0
        Dashboard.sessionStats.startTime = tick()
    end,
    
    -- AutoSell API
    ToggleAutoSell = function() AutoSell.ToggleEnabled() end,
    SetSellThreshold = function(threshold) AutoSell.SetThreshold(threshold) end,
    GetAutoSellStatus = function() return AutoSell.GetState() end,
    ForceAutoSell = function() AutoSell.ForceAutoSell() end,
    
    -- Movement API
    ToggleFloat = function() 
        if MovementSystem.floatEnabled then 
            MovementSystem.DisableFloat() 
        else 
            MovementSystem.EnableFloat() 
        end 
    end,
    ToggleNoClip = function() 
        if MovementSystem.noClipEnabled then 
            MovementSystem.DisableNoClip() 
        else 
            MovementSystem.EnableNoClip() 
        end 
    end,
    
    -- Access to all systems
    Config = Config,
    Utils = Utils,
    FishingCore = FishingCore,
    AntiAFK = AntiAFK,
    Dashboard = Dashboard,
    AutoSell = AutoSell,
    MovementSystem = MovementSystem
}

print("ModernAutoFish (Modular) loaded - API available via _G.ModernAutoFish")
