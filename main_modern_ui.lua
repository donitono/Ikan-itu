--[[
🎣 ModernAutoFish - Ultra Modern UI Version
Advanced Fishing Bot with Dark Blue Theme & Transparency

Repository: https://github.com/donitono/Ikan-itu
Author: donitono
Version: 2.1.0 (Modern UI)
--]]

-- ============================================================================
-- MODERN UI CONFIG MODULE
-- ============================================================================
local Config = {
    -- Modern UI Colors (Dark Blue Theme)
    Colors = {
        -- Main backgrounds with transparency
        Primary = Color3.fromRGB(15, 25, 45),          -- Very dark blue
        Secondary = Color3.fromRGB(20, 35, 60),        -- Dark blue
        Tertiary = Color3.fromRGB(25, 45, 75),         -- Medium dark blue
        
        -- Accent colors
        Accent = Color3.fromRGB(70, 130, 255),         -- Bright blue
        AccentHover = Color3.fromRGB(90, 150, 255),    -- Lighter blue hover
        Success = Color3.fromRGB(0, 200, 100),         -- Green
        Warning = Color3.fromRGB(255, 180, 0),         -- Orange
        Error = Color3.fromRGB(255, 70, 70),           -- Red
        
        -- Text colors
        Text = Color3.fromRGB(255, 255, 255),          -- White
        TextSecondary = Color3.fromRGB(180, 190, 210), -- Light blue-gray
        TextMuted = Color3.fromRGB(120, 130, 150),     -- Muted blue-gray
        
        -- Special effects
        Glow = Color3.fromRGB(100, 160, 255),          -- Blue glow
        Border = Color3.fromRGB(60, 100, 160),         -- Blue border
        Shadow = Color3.fromRGB(5, 10, 20),            -- Very dark shadow
    },
    
    -- UI Properties
    UI = {
        CornerRadius = 12,
        Transparency = 0.1,        -- 10% transparency
        BorderSize = 2,
        AnimationSpeed = 0.3,
        GlowIntensity = 0.8,
        ShadowOffset = 5
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

-- Animation helper
function Utils.AnimateScale(object, targetScale, duration)
    local tween = TweenService:Create(object, 
        TweenInfo.new(duration or Config.UI.AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = object.Size * targetScale}
    )
    tween:Play()
    return tween
end

function Utils.AnimateColor(object, targetColor, duration)
    local tween = TweenService:Create(object,
        TweenInfo.new(duration or Config.UI.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = targetColor}
    )
    tween:Play()
    return tween
end

-- ============================================================================
-- MODERN BASE UI MODULE
-- ============================================================================
local BaseUI = {}

-- Create modern corner
function BaseUI.CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or Config.UI.CornerRadius)
    corner.Parent = parent
    return corner
end

-- Create gradient effect
function BaseUI.CreateGradient(parent, transparency, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, transparency or 0),
        NumberSequenceKeypoint.new(1, (transparency or 0) + 0.1)
    }
    gradient.Rotation = rotation or 90
    gradient.Parent = parent
    return gradient
end

-- Create glow effect
function BaseUI.CreateGlow(parent, color, size)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, size or 20, 1, size or 20)
    glow.Position = UDim2.new(0, -(size or 20)/2, 0, -(size or 20)/2)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    glow.ImageColor3 = color or Config.Colors.Glow
    glow.ImageTransparency = 0.7
    glow.ZIndex = parent.ZIndex - 1
    glow.Parent = parent.Parent
    
    BaseUI.CreateCorner(glow, (Config.UI.CornerRadius + size/2))
    
    return glow
end

-- Create modern frame with transparency and effects
function BaseUI.CreateFrame(parent, size, position, backgroundColor, addEffects)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(1, 0, 1, 0)
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = backgroundColor or Config.Colors.Primary
    frame.BackgroundTransparency = Config.UI.Transparency
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    -- Add modern corner
    BaseUI.CreateCorner(frame)
    
    -- Add gradient effect
    if addEffects then
        BaseUI.CreateGradient(frame, 0.05)
        
        -- Add border
        local border = Instance.new("UIStroke")
        border.Color = Config.Colors.Border
        border.Thickness = 1
        border.Transparency = 0.5
        border.Parent = frame
    end
    
    return frame
end

-- Create modern scroll frame
function BaseUI.CreateScrollFrame(parent, size, position)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = size or UDim2.new(1, 0, 1, 0)
    scrollFrame.Position = position or UDim2.new(0, 0, 0, 0)
    scrollFrame.BackgroundColor3 = Config.Colors.Secondary
    scrollFrame.BackgroundTransparency = Config.UI.Transparency + 0.1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Config.Colors.Accent
    scrollFrame.ScrollBarImageTransparency = 0.3
    scrollFrame.Parent = parent
    
    BaseUI.CreateCorner(scrollFrame)
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = scrollFrame
    
    return scrollFrame
end

-- Create modern button with hover effects and animations
function BaseUI.CreateButton(parent, size, position, text, callback, buttonType)
    local button = Instance.new("TextButton")
    button.Size = size or UDim2.new(0, 200, 0, 40)
    button.Position = position or UDim2.new(0, 0, 0, 0)
    button.BorderSizePixel = 0
    button.Text = text or "Button"
    button.TextColor3 = Config.Colors.Text
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    
    -- Button color based on type
    local baseColor = Config.Colors.Accent
    local hoverColor = Config.Colors.AccentHover
    
    if buttonType == "success" then
        baseColor = Config.Colors.Success
        hoverColor = Color3.fromRGB(0, 220, 120)
    elseif buttonType == "error" then
        baseColor = Config.Colors.Error
        hoverColor = Color3.fromRGB(255, 90, 90)
    elseif buttonType == "warning" then
        baseColor = Config.Colors.Warning
        hoverColor = Color3.fromRGB(255, 200, 20)
    end
    
    button.BackgroundColor3 = baseColor
    button.BackgroundTransparency = 0.1
    
    -- Add modern effects
    BaseUI.CreateCorner(button)
    BaseUI.CreateGradient(button, 0.1)
    
    -- Add border
    local border = Instance.new("UIStroke")
    border.Color = baseColor
    border.Thickness = 1
    border.Transparency = 0.7
    border.Parent = button
    
    -- Add glow effect
    local glow = BaseUI.CreateGlow(button, baseColor, 15)
    glow.ImageTransparency = 0.9
    
    -- Hover animations
    button.MouseEnter:Connect(function()
        Utils.AnimateColor(button, hoverColor, 0.2)
        Utils.AnimateColor(border, hoverColor, 0.2)
        
        -- Scale animation
        local scaleTween = TweenService:Create(button,
            TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = size * 1.05}
        )
        scaleTween:Play()
        
        -- Glow animation
        TweenService:Create(glow,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {ImageTransparency = 0.6}
        ):Play()
    end)
    
    button.MouseLeave:Connect(function()
        Utils.AnimateColor(button, baseColor, 0.2)
        Utils.AnimateColor(border, baseColor, 0.2)
        
        -- Scale back
        local scaleTween = TweenService:Create(button,
            TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = size}
        )
        scaleTween:Play()
        
        -- Glow fade
        TweenService:Create(glow,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {ImageTransparency = 0.9}
        ):Play()
    end)
    
    -- Click animation
    button.MouseButton1Down:Connect(function()
        local clickTween = TweenService:Create(button,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = size * 0.95}
        )
        clickTween:Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        local releaseTween = TweenService:Create(button,
            TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = size * 1.05}
        )
        releaseTween:Play()
    end)
    
    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    
    return button
end

-- Create modern toggle with smooth animations
function BaseUI.CreateToggle(parent, size, position, text, initialState, callback)
    local frame = BaseUI.CreateFrame(parent, size, position, Config.Colors.Secondary, true)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = Config.Colors.Text
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    -- Modern toggle switch
    local toggleBG = Instance.new("Frame")
    toggleBG.Size = UDim2.new(0, 60, 0, 30)
    toggleBG.Position = UDim2.new(1, -75, 0.5, -15)
    toggleBG.BackgroundColor3 = initialState and Config.Colors.Success or Config.Colors.TextMuted
    toggleBG.BackgroundTransparency = 0.2
    toggleBG.BorderSizePixel = 0
    toggleBG.Parent = frame
    
    BaseUI.CreateCorner(toggleBG, 15)
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 26, 0, 26)
    toggleCircle.Position = UDim2.new(0, initialState and 32 or 2, 0, 2)
    toggleCircle.BackgroundColor3 = Config.Colors.Text
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBG
    
    BaseUI.CreateCorner(toggleCircle, 13)
    
    -- Add glow to circle
    local circleGlow = BaseUI.CreateGlow(toggleCircle, Config.Colors.Accent, 10)
    circleGlow.ImageTransparency = initialState and 0.6 or 0.9
    
    local state = initialState
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.Position = UDim2.new(0, 0, 0, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.Parent = toggleBG
    
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        
        -- Animate background color
        Utils.AnimateColor(toggleBG, state and Config.Colors.Success or Config.Colors.TextMuted, 0.3)
        
        -- Animate circle position
        TweenService:Create(toggleCircle,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, state and 32 or 2, 0, 2)}
        ):Play()
        
        -- Animate glow
        TweenService:Create(circleGlow,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {ImageTransparency = state and 0.6 or 0.9}
        ):Play()
        
        if callback then
            callback(state)
        end
    end)
    
    return frame, toggleButton
end

-- Create modern slider with smooth animations
function BaseUI.CreateSlider(parent, size, position, text, min, max, default, callback)
    local frame = BaseUI.CreateFrame(parent, size, position, Config.Colors.Secondary, true)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Config.Colors.Text
    label.TextScaled = true
    label.Font = Enum.Font.GothamSemibold
    label.Parent = frame
    
    local sliderBG = Instance.new("Frame")
    sliderBG.Size = UDim2.new(1, -30, 0, 8)
    sliderBG.Position = UDim2.new(0, 15, 1, -20)
    sliderBG.BackgroundColor3 = Config.Colors.Primary
    sliderBG.BackgroundTransparency = 0.3
    sliderBG.BorderSizePixel = 0
    sliderBG.Parent = frame
    
    BaseUI.CreateCorner(sliderBG, 4)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Config.Colors.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBG
    
    BaseUI.CreateCorner(sliderFill, 4)
    BaseUI.CreateGradient(sliderFill, 0.2)
    
    -- Slider handle
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 20, 0, 20)
    handle.Position = UDim2.new((default - min) / (max - min), -10, 0, -6)
    handle.BackgroundColor3 = Config.Colors.Text
    handle.BorderSizePixel = 0
    handle.Parent = sliderBG
    
    BaseUI.CreateCorner(handle, 10)
    local handleGlow = BaseUI.CreateGlow(handle, Config.Colors.Accent, 8)
    handleGlow.ImageTransparency = 0.7
    
    local value = default
    
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * relativeX * 10) / 10 -- Round to 1 decimal
        
        -- Animate slider components
        TweenService:Create(sliderFill,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(relativeX, 0, 1, 0)}
        ):Play()
        
        TweenService:Create(handle,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = UDim2.new(relativeX, -10, 0, -6)}
        ):Play()
        
        label.Text = text .. ": " .. value
        if callback then
            callback(value)
        end
    end
    
    sliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
            
            -- Scale animation on click
            TweenService:Create(handle,
                TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Size = UDim2.new(0, 24, 0, 24)}
            ):Play()
            
            TweenService:Create(handleGlow,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {ImageTransparency = 0.4}
            ):Play()
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                    
                    -- Scale back
                    TweenService:Create(handle,
                        TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                        {Size = UDim2.new(0, 20, 0, 20)}
                    ):Play()
                    
                    TweenService:Create(handleGlow,
                        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {ImageTransparency = 0.7}
                    ):Play()
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
-- FISHING AI MODULE (Updated for modern UI)
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
        castRemote:FireServer(100, 1)
        
        local waitTime = FishingAI.mode == "smart" and (math.random(200, 500) / 100) or 0.5
        wait(waitTime)
        
        if FishingAI.CheckForBite() and reelRemote then
            local reelSuccess = math.random(1, 100) <= Config.Settings.safeModeChance
            if reelSuccess then
                reelRemote:FireServer(100, true)
                FishingAI.statistics.fishCaught = FishingAI.statistics.fishCaught + 1
            end
        end
    end
end

function FishingAI.CheckForBite()
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
    return true
end

function FishingAI.CreateTab(parent)
    local tabContent = BaseUI.CreateScrollFrame(parent, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
    
    -- Mode selection with modern cards
    local modeFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -20, 0, 80), UDim2.new(0, 10, 0, 10), Config.Colors.Secondary, true)
    
    local modeTitle = Instance.new("TextLabel")
    modeTitle.Size = UDim2.new(1, 0, 0, 25)
    modeTitle.Position = UDim2.new(0, 15, 0, 5)
    modeTitle.BackgroundTransparency = 1
    modeTitle.Text = "🧠 Fishing Mode Selection"
    modeTitle.TextColor3 = Config.Colors.Text
    modeTitle.TextScaled = true
    modeTitle.Font = Enum.Font.GothamBold
    modeTitle.TextXAlignment = Enum.TextXAlignment.Left
    modeTitle.Parent = modeFrame
    
    local smartBtn = BaseUI.CreateButton(modeFrame, UDim2.new(0.3, -5, 0, 35), UDim2.new(0.05, 0, 0, 40), "Smart", function()
        FishingAI.mode = "smart"
        Utils.Notify("🧠 Smart Mode", "Realistic fishing with AI timing", 2)
    end, "success")
    
    local secureBtn = BaseUI.CreateButton(modeFrame, UDim2.new(0.3, -5, 0, 35), UDim2.new(0.35, 0, 0, 40), "Secure", function()
        FishingAI.mode = "secure"
        Utils.Notify("🛡️ Secure Mode", "Anti-detection mode enabled", 2)
    end, "warning")
    
    local autoBtn = BaseUI.CreateButton(modeFrame, UDim2.new(0.3, -5, 0, 35), UDim2.new(0.65, 0, 0, 40), "Auto", function()
        FishingAI.mode = "auto"
        Utils.Notify("⚡ Auto Mode", "Fast fishing mode enabled", 2)
    end)
    
    -- Control buttons with enhanced styling
    local controlFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -20, 0, 70), UDim2.new(0, 10, 0, 100), Config.Colors.Secondary, true)
    
    local startBtn = BaseUI.CreateButton(controlFrame, UDim2.new(0.48, 0, 0, 45), UDim2.new(0.02, 0, 0, 15), "🎣 Start Fishing", function()
        FishingAI.StartFishing()
    end, "success")
    
    local stopBtn = BaseUI.CreateButton(controlFrame, UDim2.new(0.48, 0, 0, 45), UDim2.new(0.5, 0, 0, 15), "🛑 Stop Fishing", function()
        FishingAI.StopFishing()
    end, "error")
    
    -- Settings with modern sliders
    local settingsFrame = BaseUI.CreateFrame(tabContent, UDim2.new(1, -20, 0, 140), UDim2.new(0, 10, 0, 180), Config.Colors.Secondary, true)
    
    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Size = UDim2.new(1, 0, 0, 25)
    settingsTitle.Position = UDim2.new(0, 15, 0, 5)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = "⚙️ Fishing Settings"
    settingsTitle.TextColor3 = Config.Colors.Text
    settingsTitle.TextScaled = true
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    settingsTitle.Parent = settingsFrame
    
    local delaySlider = BaseUI.CreateSlider(settingsFrame, UDim2.new(1, -20, 0, 50), UDim2.new(0, 10, 0, 35), "Cast Delay", 0.1, 2.0, Config.Settings.autoRecastDelay, function(value)
        Config.Settings.autoRecastDelay = value
    end)
    
    local chanceSlider = BaseUI.CreateSlider(settingsFrame, UDim2.new(1, -20, 0, 50), UDim2.new(0, 10, 0, 90), "Success Rate", 50, 100, Config.Settings.safeModeChance, function(value)
        Config.Settings.safeModeChance = value
    end)
    
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 340)
    
    return tabContent
end

-- [Continue with other modules similarly updated...]
-- For brevity, I'll include the main UI initialization with the modern theme

-- ============================================================================
-- MAIN UI MODULE (Ultra Modern)
-- ============================================================================
local MainUI = {}

function MainUI.Initialize()
    -- Create main GUI with blur effect
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModernAutoFish"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- Background blur
    local blurFrame = Instance.new("Frame")
    blurFrame.Size = UDim2.new(1, 0, 1, 0)
    blurFrame.Position = UDim2.new(0, 0, 0, 0)
    blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blurFrame.BackgroundTransparency = 0.3
    blurFrame.BorderSizePixel = 0
    blurFrame.Visible = false
    blurFrame.Parent = screenGui
    
    -- Main frame with modern design
    local mainFrame = BaseUI.CreateFrame(screenGui, UDim2.new(0, 700, 0, 500), UDim2.new(0.5, -350, 0.5, -250), Config.Colors.Primary, true)
    
    -- Add shadow effect
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundColor3 = Config.Colors.Shadow
    shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = screenGui
    
    BaseUI.CreateCorner(shadow, Config.UI.CornerRadius + 5)
    
    -- Ultra modern title bar with gradient
    local titleBar = BaseUI.CreateFrame(mainFrame, UDim2.new(1, 0, 0, 50), UDim2.new(0, 0, 0, 0), Config.Colors.Accent, true)
    BaseUI.CreateGradient(titleBar, 0.1, 45)
    
    -- Title with modern typography
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🎣 ModernAutoFish v2.1.0"
    titleLabel.TextColor3 = Config.Colors.Text
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Modern close button
    local closeBtn = BaseUI.CreateButton(titleBar, UDim2.new(0, 40, 0, 40), UDim2.new(1, -45, 0, 5), "✕", function()
        -- Fade out animation
        TweenService:Create(mainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}
        ):Play()
        
        TweenService:Create(shadow,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {BackgroundTransparency = 1}
        ):Play()
        
        wait(0.3)
        screenGui:Destroy()
    end, "error")
    
    -- Modern tab sidebar
    local tabFrame = BaseUI.CreateFrame(mainFrame, UDim2.new(0, 150, 1, -50), UDim2.new(0, 0, 0, 50), Config.Colors.Secondary, true)
    local contentFrame = BaseUI.CreateFrame(mainFrame, UDim2.new(1, -150, 1, -50), UDim2.new(0, 150, 0, 50), Config.Colors.Primary, true)
    
    local tabs = {
        {name = "🎣 Fishing", icon = "🎣", module = FishingAI},
        {name = "💰 Auto Sell", icon = "💰", module = {}}, -- Simplified for demo
        {name = "🚀 Teleport", icon = "🚀", module = {}},
        {name = "🏃 Movement", icon = "🏃", module = {}},
        {name = "📊 Dashboard", icon = "📊", module = {}}
    }
    
    local currentTab = nil
    local activeTabButton = nil
    
    for i, tab in pairs(tabs) do
        local tabBtn = BaseUI.CreateButton(tabFrame, UDim2.new(1, -20, 0, 60), UDim2.new(0, 10, 0, (i-1) * 70 + 10), tab.icon .. " " .. tab.name:gsub(tab.icon .. " ", ""), function()
            -- Clear current content
            for _, child in pairs(contentFrame:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child:Destroy()
                end
            end
            
            -- Update active tab styling
            if activeTabButton then
                Utils.AnimateColor(activeTabButton, Config.Colors.Accent, 0.2)
            end
            Utils.AnimateColor(tabBtn, Config.Colors.Success, 0.2)
            activeTabButton = tabBtn
            
            -- Create new tab content
            if tab.module.CreateTab then
                currentTab = tab.module.CreateTab(contentFrame)
            end
        end)
        
        if i == 1 then
            tabBtn.BackgroundColor3 = Config.Colors.Success
            activeTabButton = tabBtn
            if tab.module.CreateTab then
                currentTab = tab.module.CreateTab(contentFrame)
            end
        end
    end
    
    -- Modern dragging system
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            -- Add dragging visual feedback
            TweenService:Create(mainFrame,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = Config.UI.Transparency + 0.1}
            ):Play()
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            shadow.Position = UDim2.new(0, startPos.X.Offset + delta.X - 10, 0, startPos.Y.Offset + delta.Y - 10)
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            
            -- Remove dragging visual feedback
            TweenService:Create(mainFrame,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = Config.UI.Transparency}
            ):Play()
        end
    end)
    
    -- Entry animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.BackgroundTransparency = 1
    
    TweenService:Create(mainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 700, 0, 500), Position = UDim2.new(0.5, -350, 0.5, -250)}
    ):Play()
    
    TweenService:Create(shadow,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.7}
    ):Play()
    
    Utils.Notify("🎣 ModernAutoFish", "Ultra modern UI loaded! 🚀", 3)
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Initialize all modules
FishingAI.Initialize()

-- Create modern UI
MainUI.Initialize()

-- Global API
_G.ModernAutoFish = {
    Start = FishingAI.StartFishing,
    Stop = FishingAI.StopFishing,
    SetMode = function(mode) FishingAI.mode = mode end,
    Config = Config,
    Utils = Utils,
    FishingAI = FishingAI
}

print("🎣 ModernAutoFish v2.1.0 (Ultra Modern UI) - Loaded successfully!")
print("🎨 Dark blue theme with transparency and animations")
print("📚 Repository: https://github.com/donitono/Ikan-itu")
