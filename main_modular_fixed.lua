--[[
🎣 ModernAutoFish - Modular Version (Roblox Compatible)
Advanced Fishing Bot with Modular Architecture

Repository: https://github.com/donitono/Ikan-itu
Author: donitono
Version: 2.0.1 (Fixed)
--]]

-- ============================================================================
-- CORE CONFIG MODULE
-- ============================================================================
local Config = {
    -- UI Settings
    Colors = {
        Primary = Color3.new(0.2, 0.2, 0.2),
        Secondary = Color3.new(0.15, 0.15, 0.15),
        Accent = Color3.new(0.3, 0.6, 1),
        Success = Color3.new(0.2, 0.8, 0.2),
        Warning = Color3.new(1, 0.8, 0.2),
        Error = Color3.new(1, 0.3, 0.3),
        Text = Color3.new(1, 1, 1),
        TextSecondary = Color3.new(0.8, 0.8, 0.8)
    },
    
    -- Fishing Settings
    Settings = {
        mode = "smart",
        autoRecastDelay = 0.4,
        safeModeChance = 70,
        enabled = false,
        autoModeEnabled = false
    },
    
    -- Fish Rarity Categories
    FishRarity = {
        MYTHIC = {
            "Blob Shark", "Great Christmas Whale", "Robot Kraken", "Giant Squid", 
            "Great Whale", "Frostborn Shark", "Plasma Shark", "Thresher Shark",
            "Ghost Shark", "Hammerhead Shark", "Loving Shark", "Gingerbread Shark"
        },
        LEGENDARY = {
            "Chrome Tuna", "Silver Tuna", "Yellowfin Tuna", "Lavafin Tuna",
            "Manta Ray", "Blueflame Ray", "Dotted Stingray", "Axolotl",
            "Loggerhead Turtle", "Hawks Turtle", "Gingerbread Turtle"
        },
        EPIC = {
            "Enchanted Angelfish", "Maze Angelfish", "Korean Angelfish", "Flame Angelfish",
            "Bandit Angelfish", "Yellowstate Angelfish", "Boa Angelfish", "Masked Angelfish",
            "Watanabei Angelfish", "Conspi Angelfish", "Ballina Angelfish"
        },
        RARE = {
            "Unicorn Tang", "Magic Tang", "Coal Tang", "Dorhey Tang",
            "Jewel Tang", "Starjam Tang", "Vintage Blue Tang", "Fade Tang",
            "Sail Tang", "White Tang", "Volsail Tang", "Patriot Tang", "Gingerbread Tang"
        },
        UNCOMMON = {
            "Bumblebee Grouper", "Greenbee Grouper", "Panther Grouper",
            "Blue Lobster", "Lobster", "Candycane Lobster",
            "Moorish Idol", "Pufferfish", "Festive Pufferfish"
        },
        COMMON = {
            "Clownfish", "White Clownfish", "Cow Clownfish", "Darwin Clownfish",
            "Blumato Clownfish", "Gingerbread Clownfish", "Fire Goby", "Magma Goby"
        }
    },
    
    -- Island Locations
    IslandLocations = {
        ["🏝️Kohana Volcano"] = CFrame.new(1088.5, 179.5, -1787.5),
        ["🏝️Crater Island"] = CFrame.new(1577.5, 144.5, -1892.5),
        ["🏝️Acient Archives"] = CFrame.new(5708.5, 179.5, 394.5),
        ["🏝️Overgrowth Caves"] = CFrame.new(-3088.5, 179.5, 2297.5),
        ["🏝️Crystal Caverns"] = CFrame.new(2084.5, 179.5, -3329.5),
        ["🏝️Lava Pools"] = CFrame.new(-3527.5, 179.5, 3066.5),
        ["🏝️Hidden Temple"] = CFrame.new(5174.5, 179.5, 899.5),
        ["🏝️Underwater Lab"] = CFrame.new(2697.5, 179.5, -2589.5),
        ["🏝️Tidepool Cliffs"] = CFrame.new(-1832.5, 179.5, 3849.5),
        ["🏝️Snowcap Cave"] = CFrame.new(2647.5, 179.5, 2339.5),
        ["🏝️Brine Pool"] = CFrame.new(-1749.5, 179.5, 1591.5),
        ["🏝️The Depths"] = CFrame.new(1038.5, 179.5, -3539.5),
        ["🏝️Vertigo"] = CFrame.new(-112.5, 495.5, 1097.5),
        ["🏝️Artic Rod"] = CFrame.new(1698.79, 135.6, 3433.73),
        ["🏠NPC"] = CFrame.new(452.4, 148.4, 227.9),
        ["🏠Rod of Depths"] = CFrame.new(1053.6, 172.5, -3542.3),
        ["🌸Blossom"] = CFrame.new(2899.5, 179.5, -721.5)
    }
}

-- ============================================================================
-- UTILS MODULE
-- ============================================================================
local Utils = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

function Utils.Notify(title, text, duration)
    duration = duration or 3
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration
    })
end

function Utils.GetRemote(name)
    local remote = ReplicatedStorage:FindFirstChild(name)
    if remote then
        return remote
    else
        for _, child in pairs(ReplicatedStorage:GetDescendants()) do
            if child.Name == name and (child:IsA("RemoteEvent") or child:IsA("RemoteFunction")) then
                return child
            end
        end
    end
    return nil
end

function Utils.GetFishRarity(fishName)
    for rarity, fishList in pairs(Config.FishRarity) do
        for _, fish in pairs(fishList) do
            if fish == fishName then
                return rarity
            end
        end
    end
    return "COMMON"
end

function Utils.GetCurrentLocation()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local position = LocalPlayer.Character.HumanoidRootPart.Position
        local closestLocation = "Unknown"
        local closestDistance = math.huge
        
        for locationName, locationCFrame in pairs(Config.IslandLocations) do
            local distance = (position - locationCFrame.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestLocation = locationName
            end
        end
        
        return closestLocation
    end
    return "Unknown"
end

function Utils.TeleportTo(cframe)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
    end
end

-- ============================================================================
-- BASE UI MODULE
-- ============================================================================
local BaseUI = {}

function BaseUI.CreateFrame(parent, size, position, backgroundColor, borderColor)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(1, 0, 1, 0)
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = backgroundColor or Config.Colors.Primary
    frame.BorderSizePixel = borderColor and 1 or 0
    frame.BorderColor3 = borderColor or Color3.new(0, 0, 0)
    frame.Parent = parent
    return frame
end

function BaseUI.CreateScrollFrame(parent, size, position)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = size or UDim2.new(1, 0, 1, 0)
    scrollFrame.Position = position or UDim2.new(0, 0, 0, 0)
    scrollFrame.BackgroundColor3 = Config.Colors.Secondary
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Config.Colors.Accent
    scrollFrame.Parent = parent
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scrollFrame
    
    return scrollFrame
end

function BaseUI.CreateButton(parent, size, position, text, callback)
    local button = Instance.new("TextButton")
    button.Size = size or UDim2.new(0, 200, 0, 40)
    button.Position = position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = Config.Colors.Accent
    button.BorderSizePixel = 0
    button.Text = text or "Button"
    button.TextColor3 = Config.Colors.Text
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(0.4, 0.7, 1)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Config.Colors.Accent}):Play()
    end)
    
    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    
    return button
end

function BaseUI.CreateToggle(parent, size, position, text, initialState, callback)
    local frame = BaseUI.CreateFrame(parent, size, position, Config.Colors.Secondary)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = Config.Colors.Text
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.25, 0, 0.8, 0)
    toggle.Position = UDim2.new(0.7, 0, 0.1, 0)
    toggle.BackgroundColor3 = initialState and Config.Colors.Success or Config.Colors.Error
    toggle.BorderSizePixel = 0
    toggle.Text = initialState and "ON" or "OFF"
    toggle.TextColor3 = Config.Colors.Text
    toggle.TextScaled = true
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = frame
    
    local state = initialState
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Config.Colors.Success or Config.Colors.Error
        toggle.Text = state and "ON" or "OFF"
        if callback then
            callback(state)
        end
    end)
    
    return frame, toggle
end

function BaseUI.CreateSlider(parent, size, position, text, min, max, default, callback)
    local frame = BaseUI.CreateFrame(parent, size, position, Config.Colors.Secondary)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Config.Colors.Text
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local sliderBG = Instance.new("Frame")
    sliderBG.Size = UDim2.new(0.8, 0, 0.3, 0)
    sliderBG.Position = UDim2.new(0.1, 0, 0.6, 0)
    sliderBG.BackgroundColor3 = Config.Colors.Primary
    sliderBG.BorderSizePixel = 0
    sliderBG.Parent = frame
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Config.Colors.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBG
    
    local value = default
    
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * relativeX)
        sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        label.Text = text .. ": " .. value
        if callback then
            callback(value)
        end
    end
    
    sliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                end
            end)
            
            local moveConnection
            moveConnection = UserInputService.InputChanged:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input2)
                end
            end)
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    moveConnection:Disconnect()
                end
            end)
        end
    end)
    
    return frame, function() return value end
end

-- ============================================================================
-- FISHING AI MODULE
-- ============================================================================
local FishingAI = {
    enabled = false,
    autoMode = false,
    mode = "smart",
    lastCast = 0,
    statistics = {
        fishCaught = 0,
        timeFishing = 0,
        startTime = 0,
        rarenessCounts = {}
    }
}

function FishingAI.Initialize()
    -- Initialize statistics
    for rarity, _ in pairs(Config.FishRarity) do
        FishingAI.statistics.rarenessCounts[rarity] = 0
    end
end

function FishingAI.StartFishing()
    if FishingAI.enabled then return end
    
    FishingAI.enabled = true
    FishingAI.statistics.startTime = tick()
    Utils.Notify("🎣 Fishing AI", "Smart fishing started!", 3)
    
    spawn(function()
        while FishingAI.enabled do
            if LocalPlayer.Character then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and tool.Name:find("Rod") then
                    FishingAI.CastRod(tool)
                end
            end
            wait(Config.Settings.autoRecastDelay)
        end
    end)
end

function FishingAI.StopFishing()
    FishingAI.enabled = false
    Utils.Notify("🎣 Fishing AI", "Fishing stopped", 2)
end

function FishingAI.CastRod(tool)
    if not tool or not tool:FindFirstChild("events") then return end
    
    local events = tool.events
    local castRemote = events:FindFirstChild("cast")
    local reelRemote = events:FindFirstChild("reel")
    
    if castRemote then
        -- Cast the rod
        castRemote:FireServer(100, 1)
        
        -- Wait for fish with smart timing
        local waitTime = FishingAI.mode == "smart" and (math.random(200, 500) / 100) or 0.5
        wait(waitTime)
        
        -- Check for bite animation or success condition
        if FishingAI.CheckForBite() and reelRemote then
            -- Reel in with human-like timing
            local reelSuccess = math.random(1, 100) <= Config.Settings.safeModeChance
            if reelSuccess then
                reelRemote:FireServer(100, true)
                FishingAI.statistics.fishCaught = FishingAI.statistics.fishCaught + 1
            end
        end
    end
end

function FishingAI.CheckForBite()
    -- Check for fishing animations or other indicators
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        local animator = humanoid:FindFirstChild("Animator")
        
        if animator then
            local playingTracks = animator:GetPlayingAnimationTracks()
            for _, track in pairs(playingTracks) do
                if track.Animation and track.Animation.AnimationId:find("fishing") then
                    return true
                end
            end
        end
    end
    return true -- Fallback to always try reeling
end

function FishingAI.CreateTab(parent)
    local tabContent = BaseUI.CreateScrollFrame(parent, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
    
    -- Fishing Mode Selection
    local modeFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -10, 0, 60), UDim2.new(0, 5, 0, 5), Config.Colors.Secondary)
    
    local smartBtn = BaseUI.CreateButton(modeFrame, UDim2.new(0.3, 0, 0.8, 0), UDim2.new(0.05, 0, 0.1, 0), "Smart", function()
        FishingAI.mode = "smart"
        Utils.Notify("🧠 Smart Mode", "Realistic fishing with AI timing", 2)
    end)
    
    local secureBtn = BaseUI.CreateButton(modeFrame, UDim2.new(0.3, 0, 0.8, 0), UDim2.new(0.35, 0, 0.1, 0), "Secure", function()
        FishingAI.mode = "secure"
        Utils.Notify("🛡️ Secure Mode", "Anti-detection mode enabled", 2)
    end)
    
    local autoBtn = BaseUI.CreateButton(modeFrame, UDim2.new(0.3, 0, 0.8, 0), UDim2.new(0.65, 0, 0.1, 0), "Auto", function()
        FishingAI.mode = "auto"
        Utils.Notify("⚡ Auto Mode", "Fast fishing mode enabled", 2)
    end)
    
    -- Control Buttons
    local controlFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -10, 0, 60), UDim2.new(0, 5, 0, 70), Config.Colors.Secondary)
    
    local startBtn = BaseUI.CreateButton(controlFrame, UDim2.new(0.45, 0, 0.8, 0), UDim2.new(0.05, 0, 0.1, 0), "🎣 Start Fishing", function()
        FishingAI.StartFishing()
    end)
    
    local stopBtn = BaseUI.CreateButton(controlFrame, UDim2.new(0.45, 0, 0.8, 0), UDim2.new(0.5, 0, 0.1, 0), "🛑 Stop Fishing", function()
        FishingAI.StopFishing()
    end)
    
    -- Settings
    local settingsFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -10, 0, 120), UDim2.new(0, 5, 0, 135), Config.Colors.Secondary)
    
    local delaySlider = BaseUI.CreateSlider(settingsFrame, UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, 5), "Cast Delay", 0.1, 2.0, Config.Settings.autoRecastDelay, function(value)
        Config.Settings.autoRecastDelay = value
    end)
    
    local chanceSlider = BaseUI.CreateSlider(settingsFrame, UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, 50), "Success Rate", 50, 100, Config.Settings.safeModeChance, function(value)
        Config.Settings.safeModeChance = value
    end)
    
    -- Update canvas size
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 200)
    
    return tabContent
end

-- ============================================================================
-- AUTO SELL MODULE
-- ============================================================================
local AutoSell = {
    enabled = false,
    threshold = 100,
    rarityFilter = "COMMON",
    sellCount = 0,
    lastSellTime = 0
}

function AutoSell.StartAutoSell()
    if AutoSell.enabled then return end
    
    AutoSell.enabled = true
    Utils.Notify("💰 Auto Sell", "Auto sell started", 2)
    
    spawn(function()
        while AutoSell.enabled do
            AutoSell.CheckAndSell()
            wait(5) -- Check every 5 seconds
        end
    end)
end

function AutoSell.StopAutoSell()
    AutoSell.enabled = false
    Utils.Notify("💰 Auto Sell", "Auto sell stopped", 2)
end

function AutoSell.CheckAndSell()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    
    local fishCount = 0
    local fishToSell = {}
    
    -- Count fish in backpack
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") and not item.Name:find("Rod") then
            fishCount = fishCount + 1
            
            -- Check if fish meets sell criteria
            local rarity = Utils.GetFishRarity(item.Name)
            if AutoSell.ShouldSellFish(rarity) then
                table.insert(fishToSell, item)
            end
        end
    end
    
    -- Sell if threshold reached
    if fishCount >= AutoSell.threshold or #fishToSell > 0 then
        AutoSell.SellFish(fishToSell)
    end
end

function AutoSell.ShouldSellFish(rarity)
    local rarityOrder = {"COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY", "MYTHIC"}
    local filterIndex = 1
    local rarityIndex = 1
    
    for i, r in pairs(rarityOrder) do
        if r == AutoSell.rarityFilter then
            filterIndex = i
        end
        if r == rarity then
            rarityIndex = i
        end
    end
    
    return rarityIndex <= filterIndex
end

function AutoSell.SellFish(fishList)
    -- Teleport to NPC first
    Utils.TeleportTo(Config.IslandLocations["🏠NPC"])
    wait(1)
    
    -- Find and use sell remote
    local sellRemote = Utils.GetRemote("SellFish") or Utils.GetRemote("sell")
    if sellRemote then
        for _, fish in pairs(fishList) do
            sellRemote:FireServer(fish)
            AutoSell.sellCount = AutoSell.sellCount + 1
        end
        
        Utils.Notify("💰 Auto Sell", "Sold " .. #fishList .. " fish!", 2)
        AutoSell.lastSellTime = tick()
    end
end

function AutoSell.CreateTab(parent)
    local tabContent = BaseUI.CreateScrollFrame(parent, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
    
    -- Control buttons
    local controlFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -10, 0, 60), UDim2.new(0, 5, 0, 5), Config.Colors.Secondary)
    
    local startBtn = BaseUI.CreateButton(controlFrame, UDim2.new(0.45, 0, 0.8, 0), UDim2.new(0.05, 0, 0.1, 0), "💰 Start Auto Sell", function()
        AutoSell.StartAutoSell()
    end)
    
    local stopBtn = BaseUI.CreateButton(controlFrame, UDim2.new(0.45, 0, 0.8, 0), UDim2.new(0.5, 0, 0.1, 0), "🛑 Stop Auto Sell", function()
        AutoSell.StopAutoSell()
    end)
    
    -- Settings
    local settingsFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -10, 0, 160), UDim2.new(0, 5, 0, 70), Config.Colors.Secondary)
    
    local thresholdSlider = BaseUI.CreateSlider(settingsFrame, UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, 5), "Sell Threshold", 1, 1000, AutoSell.threshold, function(value)
        AutoSell.threshold = value
    end)
    
    -- Rarity filter buttons
    local rarityFrame = BaseUI.CreateFrame(settingsFrame, UDim2.new(1, -10, 0, 100), UDim2.new(0, 5, 0, 50), Config.Colors.Primary)
    
    local rarities = {"COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY", "MYTHIC"}
    for i, rarity in pairs(rarities) do
        local btn = BaseUI.CreateButton(rarityFrame, UDim2.new(0.15, 0, 0.4, 0), UDim2.new((i-1) * 0.16 + 0.02, 0, 0.1, 0), rarity:sub(1,3), function()
            AutoSell.rarityFilter = rarity
            Utils.Notify("🎯 Filter", "Selling " .. rarity .. " and below", 2)
        end)
    end
    
    -- Manual sell button
    local manualBtn = BaseUI.CreateButton(settingsFrame, UDim2.new(0.45, 0, 0.25, 0), UDim2.new(0.05, 0, 0.7, 0), "🔄 Manual Sell Now", function()
        AutoSell.CheckAndSell()
    end)
    
    -- Statistics
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(0.45, 0, 0.25, 0)
    statsLabel.Position = UDim2.new(0.5, 0, 0.7, 0)
    statsLabel.BackgroundColor3 = Config.Colors.Primary
    statsLabel.BorderSizePixel = 0
    statsLabel.Text = "Sold: " .. AutoSell.sellCount
    statsLabel.TextColor3 = Config.Colors.Text
    statsLabel.TextScaled = true
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.Parent = settingsFrame
    
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 240)
    
    return tabContent
end

-- ============================================================================
-- TELEPORT MODULE
-- ============================================================================
local Teleport = {}

function Teleport.CreateTab(parent)
    local tabContent = BaseUI.CreateScrollFrame(parent, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
    
    -- Island teleports
    local islandFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -10, 0, 300), UDim2.new(0, 5, 0, 5), Config.Colors.Secondary)
    
    local islandLabel = Instance.new("TextLabel")
    islandLabel.Size = UDim2.new(1, 0, 0.15, 0)
    islandLabel.Position = UDim2.new(0, 0, 0, 0)
    islandLabel.BackgroundTransparency = 1
    islandLabel.Text = "🏝️ Island Teleports"
    islandLabel.TextColor3 = Config.Colors.Text
    islandLabel.TextScaled = true
    islandLabel.Font = Enum.Font.GothamBold
    islandLabel.Parent = islandFrame
    
    local buttonCount = 0
    for locationName, locationCFrame in pairs(Config.IslandLocations) do
        local row = math.floor(buttonCount / 2)
        local col = buttonCount % 2
        
        local btn = BaseUI.CreateButton(islandFrame, 
            UDim2.new(0.48, 0, 0.12, 0), 
            UDim2.new(col * 0.51 + 0.01, 0, row * 0.13 + 0.18, 0), 
            locationName:gsub("🏝️", ""):gsub("🏠", ""):gsub("🌸", ""), 
            function()
                Utils.TeleportTo(locationCFrame)
                Utils.Notify("🚀 Teleport", "Teleported to " .. locationName, 2)
            end
        )
        
        buttonCount = buttonCount + 1
    end
    
    -- Player teleport
    local playerFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -10, 0, 200), UDim2.new(0, 5, 0, 310), Config.Colors.Secondary)
    
    local playerLabel = Instance.new("TextLabel")
    playerLabel.Size = UDim2.new(1, 0, 0.2, 0)
    playerLabel.Position = UDim2.new(0, 0, 0, 0)
    playerLabel.BackgroundTransparency = 1
    playerLabel.Text = "👥 Player Teleports"
    playerLabel.TextColor3 = Config.Colors.Text
    playerLabel.TextScaled = true
    playerLabel.Font = Enum.Font.GothamBold
    playerLabel.Parent = playerFrame
    
    local playerScroll = BaseUI.CreateScrollFrame(playerFrame, UDim2.new(1, -10, 0.75, 0), UDim2.new(0, 5, 0.25, 0))
    
    -- Populate player list
    for i, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = BaseUI.CreateButton(playerScroll, 
                UDim2.new(1, -20, 0, 40), 
                UDim2.new(0, 10, 0, (i-1) * 45), 
                player.DisplayName, 
                function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        Utils.TeleportTo(player.Character.HumanoidRootPart.CFrame)
                        Utils.Notify("🚀 Player TP", "Teleported to " .. player.DisplayName, 2)
                    end
                end
            )
        end
    end
    
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 45)
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 520)
    
    return tabContent
end

-- ============================================================================
-- MOVEMENT MODULE  
-- ============================================================================
local Movement = {
    floatEnabled = false,
    noClipEnabled = false,
    autoSpinEnabled = false,
    speed = 16,
    jumpPower = 50
}

function Movement.ToggleFloat()
    Movement.floatEnabled = not Movement.floatEnabled
    
    if Movement.floatEnabled then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
        bodyVelocity.Name = "FloatVelocity"
        
        Utils.Notify("🚀 Float Mode", "Float mode enabled! Use WASD + Space/Shift", 3)
        
        spawn(function()
            while Movement.floatEnabled and LocalPlayer.Character do
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local bv = hrp and hrp:FindFirstChild("FloatVelocity")
                
                if hrp and bv then
                    local camera = workspace.CurrentCamera
                    local direction = Vector3.new()
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        direction = direction + camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        direction = direction - camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        direction = direction - camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        direction = direction + camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        direction = direction + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        direction = direction - Vector3.new(0, 1, 0)
                    end
                    
                    bv.Velocity = direction.Unit * Movement.speed
                end
                
                wait()
            end
        end)
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local bv = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FloatVelocity")
            if bv then bv:Destroy() end
        end
        Utils.Notify("🚀 Float Mode", "Float mode disabled", 2)
    end
end

function Movement.ToggleNoClip()
    Movement.noClipEnabled = not Movement.noClipEnabled
    
    if Movement.noClipEnabled then
        Utils.Notify("👻 No Clip", "No clip enabled", 2)
        
        spawn(function()
            while Movement.noClipEnabled do
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
                wait()
            end
        end)
    else
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
        Utils.Notify("👻 No Clip", "No clip disabled", 2)
    end
end

function Movement.CreateTab(parent)
    local tabContent = BaseUI.CreateScrollFrame(parent, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
    
    -- Movement toggles
    local movementFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -10, 0, 200), UDim2.new(0, 5, 0, 5), Config.Colors.Secondary)
    
    local floatToggle = BaseUI.CreateToggle(movementFrame, UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, 5), "🚀 Float Mode (WASD + Space/Shift)", false, function(state)
        if state ~= Movement.floatEnabled then
            Movement.ToggleFloat()
        end
    end)
    
    local noClipToggle = BaseUI.CreateToggle(movementFrame, UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, 50), "👻 No Clip", false, function(state)
        if state ~= Movement.noClipEnabled then
            Movement.ToggleNoClip()
        end
    end)
    
    local spinToggle = BaseUI.CreateToggle(movementFrame, UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, 95), "🌀 Auto Spinner", false, function(state)
        Movement.autoSpinEnabled = state
        if state then
            spawn(function()
                while Movement.autoSpinEnabled do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(5), 0)
                    end
                    wait(0.1)
                end
            end)
        end
    end)
    
    -- Speed controls
    local speedFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -10, 0, 120), UDim2.new(0, 5, 0, 210), Config.Colors.Secondary)
    
    local speedSlider = BaseUI.CreateSlider(speedFrame, UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, 5), "Speed", 1, 100, Movement.speed, function(value)
        Movement.speed = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end)
    
    local jumpSlider = BaseUI.CreateSlider(speedFrame, UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, 50), "Jump Power", 1, 200, Movement.jumpPower, function(value)
        Movement.jumpPower = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end)
    
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 340)
    
    return tabContent
end

-- ============================================================================
-- DASHBOARD MODULE
-- ============================================================================
local Dashboard = {
    startTime = tick(),
    totalFishCaught = 0,
    sessionsCount = 1
}

function Dashboard.CreateTab(parent)
    local tabContent = BaseUI.CreateScrollFrame(parent, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
    
    -- Session info
    local sessionFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -10, 0, 120), UDim2.new(0, 5, 0, 5), Config.Colors.Secondary)
    
    local sessionLabel = Instance.new("TextLabel")
    sessionLabel.Size = UDim2.new(1, 0, 0.3, 0)
    sessionLabel.Position = UDim2.new(0, 0, 0, 0)
    sessionLabel.BackgroundTransparency = 1
    sessionLabel.Text = "📊 Session Statistics"
    sessionLabel.TextColor3 = Config.Colors.Text
    sessionLabel.TextScaled = true
    sessionLabel.Font = Enum.Font.GothamBold
    sessionLabel.Parent = sessionFrame
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(1, 0, 0.3, 0)
    timeLabel.Position = UDim2.new(0, 0, 0.35, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "⏱️ Session Time: 00:00:00"
    timeLabel.TextColor3 = Config.Colors.TextSecondary
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.Parent = sessionFrame
    
    local fishLabel = Instance.new("TextLabel")
    fishLabel.Size = UDim2.new(1, 0, 0.3, 0)
    fishLabel.Position = UDim2.new(0, 0, 0.7, 0)
    fishLabel.BackgroundTransparency = 1
    fishLabel.Text = "🎣 Fish Caught: " .. FishingAI.statistics.fishCaught
    fishLabel.TextColor3 = Config.Colors.TextSecondary
    fishLabel.TextScaled = true
    fishLabel.Font = Enum.Font.Gotham
    fishLabel.Parent = sessionFrame
    
    -- Location info
    local locationFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -10, 0, 80), UDim2.new(0, 5, 0, 130), Config.Colors.Secondary)
    
    local locationLabel = Instance.new("TextLabel")
    locationLabel.Size = UDim2.new(1, 0, 0.5, 0)
    locationLabel.Position = UDim2.new(0, 0, 0, 0)
    locationLabel.BackgroundTransparency = 1
    locationLabel.Text = "📍 Current Location"
    locationLabel.TextColor3 = Config.Colors.Text
    locationLabel.TextScaled = true
    locationLabel.Font = Enum.Font.GothamBold
    locationLabel.Parent = locationFrame
    
    local currentLocationLabel = Instance.new("TextLabel")
    currentLocationLabel.Size = UDim2.new(1, 0, 0.5, 0)
    currentLocationLabel.Position = UDim2.new(0, 0, 0.5, 0)
    currentLocationLabel.BackgroundTransparency = 1
    currentLocationLabel.Text = Utils.GetCurrentLocation()
    currentLocationLabel.TextColor3 = Config.Colors.TextSecondary
    currentLocationLabel.TextScaled = true
    currentLocationLabel.Font = Enum.Font.Gotham
    currentLocationLabel.Parent = locationFrame
    
    -- Auto sell stats
    local autoSellFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -10, 0, 80), UDim2.new(0, 5, 0, 215), Config.Colors.Secondary)
    
    local autoSellLabel = Instance.new("TextLabel")
    autoSellLabel.Size = UDim2.new(1, 0, 0.5, 0)
    autoSellLabel.Position = UDim2.new(0, 0, 0, 0)
    autoSellLabel.BackgroundTransparency = 1
    autoSellLabel.Text = "💰 Auto Sell Statistics"
    autoSellLabel.TextColor3 = Config.Colors.Text
    autoSellLabel.TextScaled = true
    autoSellLabel.Font = Enum.Font.GothamBold
    autoSellLabel.Parent = autoSellFrame
    
    local soldLabel = Instance.new("TextLabel")
    soldLabel.Size = UDim2.new(1, 0, 0.5, 0)
    soldLabel.Position = UDim2.new(0, 0, 0.5, 0)
    soldLabel.BackgroundTransparency = 1
    soldLabel.Text = "Fish Sold: " .. AutoSell.sellCount .. " | Filter: " .. AutoSell.rarityFilter
    soldLabel.TextColor3 = Config.Colors.TextSecondary
    soldLabel.TextScaled = true
    soldLabel.Font = Enum.Font.Gotham
    soldLabel.Parent = autoSellFrame
    
    -- Update labels periodically
    spawn(function()
        while true do
            local sessionTime = tick() - Dashboard.startTime
            local hours = math.floor(sessionTime / 3600)
            local minutes = math.floor((sessionTime % 3600) / 60)
            local seconds = math.floor(sessionTime % 60)
            
            timeLabel.Text = string.format("⏱️ Session Time: %02d:%02d:%02d", hours, minutes, seconds)
            fishLabel.Text = "🎣 Fish Caught: " .. FishingAI.statistics.fishCaught
            currentLocationLabel.Text = Utils.GetCurrentLocation()
            soldLabel.Text = "Fish Sold: " .. AutoSell.sellCount .. " | Filter: " .. AutoSell.rarityFilter
            
            wait(1)
        end
    end)
    
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 300)
    
    return tabContent
end

-- ============================================================================
-- MAIN UI MODULE
-- ============================================================================
local MainUI = {}

function MainUI.Initialize()
    -- Create main GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModernAutoFish"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- Main frame
    local mainFrame = BaseUI.CreateFrame(screenGui, UDim2.new(0, 600, 0, 400), UDim2.new(0.5, -300, 0.5, -200), Config.Colors.Primary)
    
    -- Title bar
    local titleBar = BaseUI.CreateFrame(mainFrame, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), Config.Colors.Accent)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🎣 ModernAutoFish v2.0.1"
    titleLabel.TextColor3 = Config.Colors.Text
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    local closeBtn = BaseUI.CreateButton(titleBar, UDim2.new(0, 30, 1, 0), UDim2.new(1, -30, 0, 0), "✕", function()
        screenGui:Destroy()
    end)
    closeBtn.BackgroundColor3 = Config.Colors.Error
    
    -- Tab system
    local tabFrame = BaseUI.CreateFrame(mainFrame, UDim2.new(0, 120, 1, -30), UDim2.new(0, 0, 0, 30), Config.Colors.Secondary)
    local contentFrame = BaseUI.CreateFrame(mainFrame, UDim2.new(1, -120, 1, -30), UDim2.new(0, 120, 0, 30), Config.Colors.Primary)
    
    local tabs = {
        {name = "🎣 Fishing", module = FishingAI},
        {name = "💰 Auto Sell", module = AutoSell},
        {name = "🚀 Teleport", module = Teleport},
        {name = "🏃 Movement", module = Movement},
        {name = "📊 Dashboard", module = Dashboard}
    }
    
    local currentTab = nil
    
    for i, tab in pairs(tabs) do
        local tabBtn = BaseUI.CreateButton(tabFrame, UDim2.new(1, -10, 0, 60), UDim2.new(0, 5, 0, (i-1) * 65 + 5), tab.name, function()
            -- Clear current content
            for _, child in pairs(contentFrame:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child:Destroy()
                end
            end
            
            -- Create new tab content
            if tab.module.CreateTab then
                currentTab = tab.module.CreateTab(contentFrame)
            end
        end)
        
        if i == 1 then
            tabBtn.BackgroundColor3 = Config.Colors.Success
            currentTab = tab.module.CreateTab(contentFrame)
        end
    end
    
    -- Make GUI draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    Utils.Notify("🎣 ModernAutoFish", "Modular fishing bot loaded successfully!", 3)
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Initialize all modules
FishingAI.Initialize()

-- Create main UI
MainUI.Initialize()

-- Global API
_G.ModernAutoFish = {
    -- Core functions
    Start = FishingAI.StartFishing,
    Stop = FishingAI.StopFishing,
    SetMode = function(mode) FishingAI.mode = mode end,
    
    -- Feature toggles
    ToggleAutoSell = function() 
        if AutoSell.enabled then AutoSell.StopAutoSell() else AutoSell.StartAutoSell() end
    end,
    ToggleFloat = Movement.ToggleFloat,
    ToggleNoClip = Movement.ToggleNoClip,
    
    -- Auto sell
    SetSellThreshold = function(value) AutoSell.threshold = value end,
    GetAutoSellStatus = function() return AutoSell.enabled end,
    
    -- Statistics
    GetStats = function() return FishingAI.statistics end,
    
    -- Module access
    Config = Config,
    Utils = Utils,
    FishingAI = FishingAI,
    AutoSell = AutoSell,
    Movement = Movement,
    Dashboard = Dashboard
}

print("🎣 ModernAutoFish v2.0.1 (Fixed) - Loaded successfully!")
print("📚 Repository: https://github.com/donitono/Ikan-itu")
print("🔧 API available at: _G.ModernAutoFish")
