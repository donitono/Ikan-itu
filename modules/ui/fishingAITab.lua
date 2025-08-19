-- fishingAITab.lua
-- Fishing AI Tab Module for ModernAutoFish

local FishingAITab = {}

-- Load dependencies
local BaseUI = require(script.Parent.baseUI)
local Utils = require(script.Parent.Parent.core.utils)
local Config = require(script.Parent.Parent.core.config)

function FishingAITab.Create(contentContainer, fishingCore, autoSell, antiAFK)
    local frame = Instance.new("Frame", contentContainer)
    frame.Name = "FishingAIFrame"
    frame.Size = UDim2.new(1, 0, 1, -85)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1

    local scrollFrame = BaseUI.CreateScrollFrame(frame)
    
    -- Secure Mode Section
    local secureSection = BaseUI.CreateSection(
        scrollFrame, 
        UDim2.new(0, 5, 0, 5), 
        UDim2.new(1, -10, 0, 120),
        "🔒 Secure Fishing Mode",
        Color3.fromRGB(100,255,150)
    )
    
    local secureButton = BaseUI.CreateButton(
        secureSection,
        UDim2.new(0, 10, 0, 35),
        UDim2.new(0.48, -5, 0, 35),
        "🔒 Start Secure",
        Color3.fromRGB(74,155,88),
        function()
            fishingCore.StartSecureMode()
        end
    )
    
    local secureStopButton = BaseUI.CreateButton(
        secureSection,
        UDim2.new(0.52, 5, 0, 35),
        UDim2.new(0.48, -5, 0, 35),
        "🛑 Stop Secure",
        Color3.fromRGB(190,60,60),
        function()
            fishingCore.StopSecureMode()
        end
    )
    
    local modeStatus = Instance.new("TextLabel", secureSection)
    modeStatus.Size = UDim2.new(1, -20, 0, 25)
    modeStatus.Position = UDim2.new(0, 10, 0, 80)
    modeStatus.Text = "🔒 Secure Mode Ready - Safe & Reliable Fishing"
    modeStatus.Font = Enum.Font.GothamSemibold
    modeStatus.TextSize = 12
    modeStatus.TextColor3 = Color3.fromRGB(100,255,150)
    modeStatus.BackgroundTransparency = 1
    modeStatus.TextXAlignment = Enum.TextXAlignment.Center

    -- Smart AI Mode Section
    local aiSection = BaseUI.CreateSection(
        scrollFrame,
        UDim2.new(0, 5, 0, 135),
        UDim2.new(1, -10, 0, 120),
        "🧠 Smart AI Fishing Modes",
        Color3.fromRGB(255,140,0)
    )
    
    local smartButton = BaseUI.CreateButton(
        aiSection,
        UDim2.new(0, 10, 0, 35),
        UDim2.new(0.48, -5, 0, 35),
        "🧠 Start Smart AI",
        Color3.fromRGB(255,140,0),
        function()
            fishingCore.StartSmartMode()
        end
    )
    
    local stopButton = BaseUI.CreateButton(
        aiSection,
        UDim2.new(0.52, 5, 0, 35),
        UDim2.new(0.48, -5, 0, 35),
        "🛑 Stop Smart AI",
        Color3.fromRGB(190,60,60),
        function()
            fishingCore.StopSmartMode()
        end
    )
    
    local aiStatusLabel = Instance.new("TextLabel", aiSection)
    aiStatusLabel.Size = UDim2.new(1, -20, 0, 25)
    aiStatusLabel.Position = UDim2.new(0, 10, 0, 80)
    aiStatusLabel.Text = "⏸️ Smart AI Ready (Click Start to begin)"
    aiStatusLabel.Font = Enum.Font.GothamSemibold
    aiStatusLabel.TextSize = 12
    aiStatusLabel.TextColor3 = Color3.fromRGB(200,200,200)
    aiStatusLabel.BackgroundTransparency = 1
    aiStatusLabel.TextXAlignment = Enum.TextXAlignment.Center

    -- Auto Mode Section
    local autoSection = BaseUI.CreateSection(
        scrollFrame,
        UDim2.new(0, 5, 0, 265),
        UDim2.new(1, -10, 0, 120),
        "🔥 Auto Mode (Loop Finish)",
        Color3.fromRGB(255, 80, 80)
    )
    
    local autoStartButton = BaseUI.CreateButton(
        autoSection,
        UDim2.new(0, 10, 0, 35),
        UDim2.new(0.48, -5, 0, 35),
        "🔥 Start Auto",
        Color3.fromRGB(220, 70, 70),
        function()
            fishingCore.StartAutoMode()
        end
    )
    
    local autoStopButton = BaseUI.CreateButton(
        autoSection,
        UDim2.new(0.52, 5, 0, 35),
        UDim2.new(0.48, -5, 0, 35),
        "🛑 Stop Auto",
        Color3.fromRGB(190,60,60),
        function()
            fishingCore.StopAutoMode()
        end
    )
    
    local autoStatus = Instance.new("TextLabel", autoSection)
    autoStatus.Size = UDim2.new(1, -20, 0, 25)
    autoStatus.Position = UDim2.new(0, 10, 0, 80)
    autoStatus.Text = "🔥 Auto Mode Ready"
    autoStatus.Font = Enum.Font.GothamSemibold
    autoStatus.TextSize = 12
    autoStatus.TextColor3 = Color3.fromRGB(220, 70, 70)
    autoStatus.BackgroundTransparency = 1
    autoStatus.TextXAlignment = Enum.TextXAlignment.Center

    -- AntiAFK Section
    local antiAfkSection = BaseUI.CreateSection(
        scrollFrame,
        UDim2.new(0, 5, 0, 395),
        UDim2.new(1, -10, 0, 60),
        "🛡️ AntiAFK Protection",
        Color3.fromRGB(100,200,255)
    )
    
    local antiAfkLabel = Instance.new("TextLabel", antiAfkSection)
    antiAfkLabel.Size = UDim2.new(0.65, -10, 0, 25)
    antiAfkLabel.Position = UDim2.new(0, 15, 0, 30)
    antiAfkLabel.Text = "🛡️ AntiAFK Protection: Disabled"
    antiAfkLabel.Font = Enum.Font.GothamSemibold
    antiAfkLabel.TextSize = 12
    antiAfkLabel.TextColor3 = Color3.fromRGB(200,200,200)
    antiAfkLabel.BackgroundTransparency = 1
    antiAfkLabel.TextXAlignment = Enum.TextXAlignment.Left
    antiAfkLabel.TextYAlignment = Enum.TextYAlignment.Center

    local antiAfkToggle = BaseUI.CreateToggleButton(
        antiAfkSection,
        UDim2.new(1, -80, 0, 31),
        UDim2.new(0, 70, 0, 24),
        "OFF",
        false,
        function(enabled)
            if enabled then
                antiAFK.Start()
                antiAfkLabel.Text = "🛡️ AntiAFK Protection: Enabled"
                antiAfkLabel.TextColor3 = Color3.fromRGB(100,255,150)
            else
                antiAFK.Stop()
                antiAfkLabel.Text = "🛡️ AntiAFK Protection: Disabled"
                antiAfkLabel.TextColor3 = Color3.fromRGB(200,200,200)
            end
        end
    )

    -- Auto Sell Section
    if autoSell then
        autoSell.CreateUI(scrollFrame, UDim2.new(0, 5, 0, 465))
    end

    -- Set canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 780)

    -- Return frame and status update functions
    return frame, {
        updateModeStatus = function(text, color)
            modeStatus.Text = text
            modeStatus.TextColor3 = color or Color3.fromRGB(100,255,150)
        end,
        updateAIStatus = function(text, color)
            aiStatusLabel.Text = text
            aiStatusLabel.TextColor3 = color or Color3.fromRGB(200,200,200)
        end,
        updateAutoStatus = function(text, color)
            autoStatus.Text = text
            autoStatus.TextColor3 = color or Color3.fromRGB(220, 70, 70)
        end
    }
end

return FishingAITab
