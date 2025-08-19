-- dashboardTab.lua
-- Dashboard Tab Module for ModernAutoFish

local DashboardTab = {}

-- Load dependencies
local BaseUI = require(script.Parent.baseUI)
local Utils = require(script.Parent.Parent.core.utils)
local Config = require(script.Parent.Parent.core.config)

function DashboardTab.Create(contentContainer, dashboardSystem)
    local frame = Instance.new("Frame", contentContainer)
    frame.Name = "DashboardFrame"
    frame.Size = UDim2.new(1, 0, 1, -10)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false

    local scrollFrame = BaseUI.CreateScrollFrame(frame)

    -- Session Stats Section
    local sessionSection = BaseUI.CreateSection(
        scrollFrame,
        UDim2.new(0, 5, 0, 5),
        UDim2.new(1, -10, 0, 120),
        "📈 Current Session Stats",
        Color3.fromRGB(100,200,255)
    )
    
    local sessionLabels = DashboardTab.CreateSessionStats(sessionSection)

    -- Fish Rarity Tracker Section
    local raritySection = BaseUI.CreateSection(
        scrollFrame,
        UDim2.new(0, 5, 0, 135),
        UDim2.new(1, -10, 0, 180),
        "🏆 Fish Rarity Tracker",
        Color3.fromRGB(255,200,100)
    )
    
    local rarityBars = DashboardTab.CreateRarityTracker(raritySection)

    -- Location Heatmap Section
    local heatmapSection = BaseUI.CreateSection(
        scrollFrame,
        UDim2.new(0, 5, 0, 325),
        UDim2.new(1, -10, 0, 200),
        "🗺️ Location Efficiency Heatmap",
        Color3.fromRGB(100,255,150)
    )
    
    local locationList = DashboardTab.CreateLocationHeatmap(heatmapSection)

    -- Optimal Times Section
    local timesSection = BaseUI.CreateSection(
        scrollFrame,
        UDim2.new(0, 5, 0, 535),
        UDim2.new(1, -10, 0, 160),
        "⏰ Optimal Fishing Times",
        Color3.fromRGB(255,200,100)
    )
    
    local timeLabels, timeBars = DashboardTab.CreateOptimalTimes(timesSection)

    -- Set canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 720)

    -- Return frame and update function
    return frame, function()
        DashboardTab.UpdateDashboard(dashboardSystem, sessionLabels, rarityBars, locationList, timeLabels, timeBars)
    end
end

function DashboardTab.CreateSessionStats(parent)
    local labels = {}
    
    labels.fishCount = Instance.new("TextLabel", parent)
    labels.fishCount.Size = UDim2.new(0.5, -15, 0, 20)
    labels.fishCount.Position = UDim2.new(0, 10, 0, 35)
    labels.fishCount.Text = "🎣 Total Fish: 0"
    labels.fishCount.Font = Enum.Font.GothamSemibold
    labels.fishCount.TextSize = 12
    labels.fishCount.TextColor3 = Color3.fromRGB(255,255,255)
    labels.fishCount.BackgroundTransparency = 1
    labels.fishCount.TextXAlignment = Enum.TextXAlignment.Left

    labels.rareCount = Instance.new("TextLabel", parent)
    labels.rareCount.Size = UDim2.new(0.5, -15, 0, 20)
    labels.rareCount.Position = UDim2.new(0.5, 5, 0, 35)
    labels.rareCount.Text = "✨ Rare Fish: 0"
    labels.rareCount.Font = Enum.Font.GothamSemibold
    labels.rareCount.TextSize = 12
    labels.rareCount.TextColor3 = Color3.fromRGB(255,215,0)
    labels.rareCount.BackgroundTransparency = 1
    labels.rareCount.TextXAlignment = Enum.TextXAlignment.Left

    labels.sessionTime = Instance.new("TextLabel", parent)
    labels.sessionTime.Size = UDim2.new(0.5, -15, 0, 20)
    labels.sessionTime.Position = UDim2.new(0, 10, 0, 60)
    labels.sessionTime.Text = "⏱️ Session: 0m 0s"
    labels.sessionTime.Font = Enum.Font.GothamSemibold
    labels.sessionTime.TextSize = 12
    labels.sessionTime.TextColor3 = Color3.fromRGB(200,200,200)
    labels.sessionTime.BackgroundTransparency = 1
    labels.sessionTime.TextXAlignment = Enum.TextXAlignment.Left

    labels.location = Instance.new("TextLabel", parent)
    labels.location.Size = UDim2.new(0.5, -15, 0, 20)
    labels.location.Position = UDim2.new(0.5, 5, 0, 60)
    labels.location.Text = "🗺️ Location: Unknown"
    labels.location.Font = Enum.Font.GothamSemibold
    labels.location.TextSize = 12
    labels.location.TextColor3 = Color3.fromRGB(150,255,150)
    labels.location.BackgroundTransparency = 1
    labels.location.TextXAlignment = Enum.TextXAlignment.Left

    labels.efficiency = Instance.new("TextLabel", parent)
    labels.efficiency.Size = UDim2.new(1, -20, 0, 20)
    labels.efficiency.Position = UDim2.new(0, 10, 0, 85)
    labels.efficiency.Text = "🎯 Rare Rate: 0% | ⚡ Fish/Min: 0.0"
    labels.efficiency.Font = Enum.Font.GothamSemibold
    labels.efficiency.TextSize = 12
    labels.efficiency.TextColor3 = Color3.fromRGB(255,165,0)
    labels.efficiency.BackgroundTransparency = 1
    labels.efficiency.TextXAlignment = Enum.TextXAlignment.Left

    return labels
end

function DashboardTab.CreateRarityTracker(parent)
    local rarityTypes = {
        {name = "MYTHIC", color = Color3.fromRGB(255,50,50), icon = "🔥"},
        {name = "LEGENDARY", color = Color3.fromRGB(255,100,255), icon = "✨"},
        {name = "EPIC", color = Color3.fromRGB(150,50,200), icon = "💜"},
        {name = "RARE", color = Color3.fromRGB(100,150,255), icon = "⭐"},
        {name = "UNCOMMON", color = Color3.fromRGB(0,255,200), icon = "💎"},
        {name = "COMMON", color = Color3.fromRGB(150,150,150), icon = "🐟"}
    }

    local rarityBars = {}
    
    for i, rarity in ipairs(rarityTypes) do
        local yPos = 30 + (i - 1) * 22
        
        local rarityLabel = Instance.new("TextLabel", parent)
        rarityLabel.Size = UDim2.new(0.3, -10, 0, 18)
        rarityLabel.Position = UDim2.new(0, 10, 0, yPos)
        rarityLabel.Text = rarity.icon .. " " .. rarity.name
        rarityLabel.Font = Enum.Font.GothamSemibold
        rarityLabel.TextSize = 10
        rarityLabel.TextColor3 = rarity.color
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.TextXAlignment = Enum.TextXAlignment.Left

        local rarityBar = Instance.new("Frame", parent)
        rarityBar.Size = UDim2.new(0.5, -10, 0, 12)
        rarityBar.Position = UDim2.new(0.3, 5, 0, yPos + 3)
        rarityBar.BackgroundColor3 = Color3.fromRGB(60,60,70)
        rarityBar.BorderSizePixel = 0
        Utils.CreateCorner(rarityBar)

        local rarityFill = Instance.new("Frame", rarityBar)
        rarityFill.Size = UDim2.new(0, 0, 1, 0)
        rarityFill.Position = UDim2.new(0, 0, 0, 0)
        rarityFill.BackgroundColor3 = rarity.color
        rarityFill.BorderSizePixel = 0
        Utils.CreateCorner(rarityFill)

        local rarityCount = Instance.new("TextLabel", parent)
        rarityCount.Size = UDim2.new(0.2, -10, 0, 18)
        rarityCount.Position = UDim2.new(0.8, 5, 0, yPos)
        rarityCount.Text = "0"
        rarityCount.Font = Enum.Font.GothamBold
        rarityCount.TextSize = 11
        rarityCount.TextColor3 = Color3.fromRGB(255,255,255)
        rarityCount.BackgroundTransparency = 1
        rarityCount.TextXAlignment = Enum.TextXAlignment.Center

        rarityBars[rarity.name] = {fill = rarityFill, count = rarityCount}
    end

    return rarityBars
end

function DashboardTab.CreateLocationHeatmap(parent)
    local locationList = BaseUI.CreateScrollFrame(
        parent,
        UDim2.new(0, 10, 0, 30),
        UDim2.new(1, -20, 1, -35)
    )
    locationList.ScrollBarThickness = 4

    return locationList
end

function DashboardTab.CreateOptimalTimes(parent)
    local labels = {}
    
    labels.bestTime = Instance.new("TextLabel", parent)
    labels.bestTime.Size = UDim2.new(1, -20, 0, 20)
    labels.bestTime.Position = UDim2.new(0, 10, 0, 35)
    labels.bestTime.Text = "🏆 Best Time: Not enough data"
    labels.bestTime.Font = Enum.Font.GothamSemibold
    labels.bestTime.TextSize = 12
    labels.bestTime.TextColor3 = Color3.fromRGB(255,215,0)
    labels.bestTime.BackgroundTransparency = 1
    labels.bestTime.TextXAlignment = Enum.TextXAlignment.Left

    labels.currentTime = Instance.new("TextLabel", parent)
    labels.currentTime.Size = UDim2.new(1, -20, 0, 20)
    labels.currentTime.Position = UDim2.new(0, 10, 0, 60)
    labels.currentTime.Text = "🕐 Current Hour: " .. os.date("%H:00")
    labels.currentTime.Font = Enum.Font.GothamSemibold
    labels.currentTime.TextSize = 12
    labels.currentTime.TextColor3 = Color3.fromRGB(150,255,150)
    labels.currentTime.BackgroundTransparency = 1
    labels.currentTime.TextXAlignment = Enum.TextXAlignment.Left

    -- Time chart
    local timeChart = Instance.new("Frame", parent)
    timeChart.Size = UDim2.new(1, -20, 0, 70)
    timeChart.Position = UDim2.new(0, 10, 0, 85)
    timeChart.BackgroundColor3 = Color3.fromRGB(35,35,42)
    timeChart.BorderSizePixel = 0
    Utils.CreateCorner(timeChart)

    -- Create time bars for 24 hours
    local timeBars = {}
    for hour = 0, 23 do
        local timeBar = Instance.new("Frame", timeChart)
        timeBar.Size = UDim2.new(0, 8, 0, 2)
        timeBar.Position = UDim2.new(hour/24, 2, 1, -15)
        timeBar.BackgroundColor3 = Color3.fromRGB(100,100,120)
        timeBar.BorderSizePixel = 0
        timeBars[hour] = timeBar
    end

    return labels, timeBars
end

function DashboardTab.UpdateDashboard(dashboardSystem, sessionLabels, rarityBars, locationList, timeLabels, timeBars)
    if not dashboardSystem then return end
    
    -- Update session stats
    local sessionStats = dashboardSystem.sessionStats
    local currentTime = tick()
    local sessionDuration = currentTime - sessionStats.startTime
    
    sessionLabels.fishCount.Text = "🎣 Total Fish: " .. sessionStats.fishCount
    sessionLabels.rareCount.Text = "✨ Rare Fish: " .. sessionStats.rareCount
    sessionLabels.sessionTime.Text = "⏱️ Session: " .. Utils.FormatTime(sessionDuration)
    sessionLabels.location.Text = "🗺️ Location: " .. sessionStats.currentLocation
    
    -- Calculate efficiency
    local rareRate = sessionStats.fishCount > 0 and 
                    math.floor((sessionStats.rareCount / sessionStats.fishCount) * 100) or 0
    local fishPerMin = sessionDuration > 0 and (sessionStats.fishCount / (sessionDuration / 60)) or 0
    sessionLabels.efficiency.Text = string.format("🎯 Rare Rate: %d%% | ⚡ Fish/Min: %.1f", rareRate, fishPerMin)
    
    -- Update rarity bars
    local rarityCounts = {}
    for rarityName, _ in pairs(Config.FishRarity) do
        rarityCounts[rarityName] = 0
    end
    
    for _, fish in pairs(dashboardSystem.fishCaught) do
        rarityCounts[fish.rarity] = (rarityCounts[fish.rarity] or 0) + 1
    end
    
    local maxCount = math.max(1, sessionStats.fishCount)
    for rarityName, bar in pairs(rarityBars) do
        local count = rarityCounts[rarityName] or 0
        local percentage = count / maxCount
        bar.fill.Size = UDim2.new(percentage, 0, 1, 0)
        bar.count.Text = tostring(count)
    end
    
    -- Update location list
    for _, child in pairs(locationList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local yPos = 5
    for location, stats in pairs(dashboardSystem.locationStats) do
        local efficiency = stats.total > 0 and math.floor((stats.rare / stats.total) * 100) or 0
        
        local locationFrame = Instance.new("Frame", locationList)
        locationFrame.Size = UDim2.new(1, -10, 0, 25)
        locationFrame.Position = UDim2.new(0, 5, 0, yPos)
        locationFrame.BackgroundColor3 = Color3.fromRGB(50,50,60)
        locationFrame.BorderSizePixel = 0
        Utils.CreateCorner(locationFrame)
        
        local locationLabel = Instance.new("TextLabel", locationFrame)
        locationLabel.Size = UDim2.new(0.6, -10, 1, 0)
        locationLabel.Position = UDim2.new(0, 5, 0, 0)
        locationLabel.Text = "🏝️ " .. location
        locationLabel.Font = Enum.Font.GothamSemibold
        locationLabel.TextSize = 10
        locationLabel.TextColor3 = Color3.fromRGB(255,255,255)
        locationLabel.BackgroundTransparency = 1
        locationLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local efficiencyLabel = Instance.new("TextLabel", locationFrame)
        efficiencyLabel.Size = UDim2.new(0.4, -10, 1, 0)
        efficiencyLabel.Position = UDim2.new(0.6, 5, 0, 0)
        efficiencyLabel.Text = string.format("%d%% (%d/%d)", efficiency, stats.rare, stats.total)
        efficiencyLabel.Font = Enum.Font.GothamBold
        efficiencyLabel.TextSize = 10
        local effColor = efficiency > 15 and Color3.fromRGB(100,255,100) or 
                       efficiency > 5 and Color3.fromRGB(255,255,100) or Color3.fromRGB(255,100,100)
        efficiencyLabel.TextColor3 = effColor
        efficiencyLabel.BackgroundTransparency = 1
        efficiencyLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        yPos = yPos + 30
    end
    locationList.CanvasSize = UDim2.new(0, 0, 0, yPos)
    
    -- Update optimal times
    if dashboardSystem.GetBestFishingTime then
        local bestHour, bestPercent = dashboardSystem.GetBestFishingTime()
        if bestPercent > 0 then
            timeLabels.bestTime.Text = string.format("🏆 Best Time: %02d:00 (%d%% rare rate)", bestHour, bestPercent)
        else
            timeLabels.bestTime.Text = "🏆 Best Time: Not enough data"
        end
    end
    
    timeLabels.currentTime.Text = "🕐 Current Hour: " .. os.date("%H:00")
    
    -- Update time bars
    for hour, bar in pairs(timeBars) do
        local data = dashboardSystem.optimalTimes[hour]
        if data and data.total > 0 then
            local efficiency = data.rare / data.total
            local height = math.max(2, efficiency * 50)
            bar.Size = UDim2.new(0, 8, 0, height)
            bar.Position = UDim2.new(hour/24, 2, 1, -15 - height + 2)
            local color = efficiency > 0.2 and Color3.fromRGB(100,255,100) or 
                         efficiency > 0.1 and Color3.fromRGB(255,255,100) or Color3.fromRGB(255,100,100)
            bar.BackgroundColor3 = color
        end
    end
end

return DashboardTab
