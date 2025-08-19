-- autoSell.lua
-- Auto Sell Feature Module for ModernAutoFish

local AutoSell = {}

-- Load dependencies
local BaseUI = require(script.Parent.Parent.ui.baseUI)
local Utils = require(script.Parent.Parent.core.utils)
local Config = require(script.Parent.Parent.core.config)

-- AutoSell State
local state = {
    enabled = false,
    threshold = 50,
    isCurrentlySelling = false,
    allowedRarities = {
        COMMON = true,
        UNCOMMON = true,
        RARE = false,
        EPIC = false,
        LEGENDARY = false,
        MYTHIC = false
    },
    sellCount = {
        COMMON = 0,
        UNCOMMON = 0,
        RARE = 0,
        EPIC = 0,
        LEGENDARY = 0,
        MYTHIC = 0
    },
    lastSellTime = 0,
    sellCooldown = 5,
    serverThreshold = 50,
    lastSyncTime = 0,
    syncCooldown = 2,
    isThresholdSynced = false,
    syncRetries = 0,
    maxSyncRetries = 3
}

function AutoSell.Initialize()
    -- Initialize AutoSell system
    task.spawn(AutoSell.InitializeServerSync)
end

function AutoSell.CreateUI(parent, position)
    local section = BaseUI.CreateSection(
        parent,
        position,
        UDim2.new(1, -10, 0, 200),
        "💰 Advanced Auto Sell System",
        Color3.fromRGB(255, 215, 0)
    )

    -- Threshold Input
    local thresholdFrame = Instance.new("Frame", section)
    thresholdFrame.Size = UDim2.new(1, -20, 0, 25)
    thresholdFrame.Position = UDim2.new(0, 10, 0, 35)
    thresholdFrame.BackgroundTransparency = 1

    local thresholdLabel = Instance.new("TextLabel", thresholdFrame)
    thresholdLabel.Size = UDim2.new(0.5, -5, 1, 0)
    thresholdLabel.Position = UDim2.new(0, 0, 0, 0)
    thresholdLabel.Text = "🎯 Threshold:"
    thresholdLabel.Font = Enum.Font.GothamSemibold
    thresholdLabel.TextSize = 12
    thresholdLabel.TextColor3 = Color3.fromRGB(255,255,255)
    thresholdLabel.BackgroundTransparency = 1
    thresholdLabel.TextXAlignment = Enum.TextXAlignment.Left
    thresholdLabel.TextYAlignment = Enum.TextYAlignment.Center

    local thresholdInput = Instance.new("TextBox", thresholdFrame)
    thresholdInput.Size = UDim2.new(0.5, -5, 0, 20)
    thresholdInput.Position = UDim2.new(0.5, 5, 0, 2)
    thresholdInput.PlaceholderText = "Fish count"
    thresholdInput.Text = tostring(state.threshold)
    thresholdInput.Font = Enum.Font.GothamSemibold
    thresholdInput.TextSize = 11
    thresholdInput.BackgroundColor3 = Color3.fromRGB(60,60,66)
    thresholdInput.TextColor3 = Color3.fromRGB(255,255,255)
    thresholdInput.BorderSizePixel = 0
    Utils.CreateCorner(thresholdInput)

    -- Rarity Checkboxes
    local rarityFrame = Instance.new("Frame", section)
    rarityFrame.Size = UDim2.new(1, -20, 0, 90)
    rarityFrame.Position = UDim2.new(0, 10, 0, 70)
    rarityFrame.BackgroundTransparency = 1

    local rarityTitle = Instance.new("TextLabel", rarityFrame)
    rarityTitle.Size = UDim2.new(1, 0, 0, 20)
    rarityTitle.Position = UDim2.new(0, 0, 0, 0)
    rarityTitle.Text = "🏆 Select Rarities to Auto Sell:"
    rarityTitle.Font = Enum.Font.GothamSemibold
    rarityTitle.TextSize = 11
    rarityTitle.TextColor3 = Color3.fromRGB(255,200,100)
    rarityTitle.BackgroundTransparency = 1
    rarityTitle.TextXAlignment = Enum.TextXAlignment.Left

    local rarityCheckboxes = AutoSell.CreateRarityCheckboxes(rarityFrame)

    -- Toggle and Status
    local autoSellToggle = BaseUI.CreateToggleButton(
        section,
        UDim2.new(0, 10, 0, 170),
        UDim2.new(0.48, -5, 0, 25),
        "AUTO SELL",
        state.enabled,
        function(enabled)
            AutoSell.SetEnabled(enabled)
        end
    )

    local statusLabel = Instance.new("TextLabel", section)
    statusLabel.Size = UDim2.new(0.48, -5, 0, 25)
    statusLabel.Position = UDim2.new(0.52, 5, 0, 170)
    statusLabel.Text = "Status: Disabled"
    statusLabel.Font = Enum.Font.GothamSemibold
    statusLabel.TextSize = 10
    statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
    statusLabel.BackgroundColor3 = Color3.fromRGB(35,35,42)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.TextYAlignment = Enum.TextYAlignment.Center
    Utils.CreateCorner(statusLabel)

    -- Event handlers
    AutoSell.SetupEventHandlers(thresholdInput, rarityCheckboxes, statusLabel)

    -- Update status periodically
    AutoSell.StartStatusUpdater(statusLabel)

    return section
end

function AutoSell.CreateRarityCheckboxes(parent)
    local rarityData = {
        {name = "COMMON", color = Color3.fromRGB(150,150,150), icon = "🐟"},
        {name = "UNCOMMON", color = Color3.fromRGB(0,255,200), icon = "💎"},
        {name = "RARE", color = Color3.fromRGB(100,150,255), icon = "⭐"},
        {name = "EPIC", color = Color3.fromRGB(150,50,200), icon = "💜"},
        {name = "LEGENDARY", color = Color3.fromRGB(255,100,255), icon = "✨"},
        {name = "MYTHIC", color = Color3.fromRGB(255,50,50), icon = "🔥"}
    }

    local checkboxes = {}

    for i, rarity in ipairs(rarityData) do
        local row = math.floor((i-1) / 3)
        local col = (i-1) % 3
        
        local checkbox = Instance.new("TextButton", parent)
        checkbox.Size = UDim2.new(0.33, -5, 0, 20)
        checkbox.Position = UDim2.new(col * 0.33, 2, 0, 25 + row * 25)
        checkbox.Text = (state.allowedRarities[rarity.name] and "☑️" or "☐") .. " " .. rarity.icon .. " " .. rarity.name
        checkbox.Font = Enum.Font.GothamSemibold
        checkbox.TextSize = 9
        checkbox.BackgroundColor3 = Color3.fromRGB(60,60,66)
        checkbox.TextColor3 = rarity.color
        checkbox.BorderSizePixel = 0
        Utils.CreateCorner(checkbox)
        
        checkboxes[rarity.name] = checkbox
    end

    return checkboxes
end

function AutoSell.SetupEventHandlers(thresholdInput, rarityCheckboxes, statusLabel)
    -- Threshold input handler
    thresholdInput.FocusLost:Connect(function(enterPressed)
        local num = tonumber(thresholdInput.Text)
        if num and num > 0 and num <= 1000 then
            AutoSell.SetThreshold(num)
        else
            Utils.Notify("Auto Sell", "❌ Invalid threshold! Use 1-1000")
            thresholdInput.Text = tostring(state.threshold)
        end
    end)

    -- Rarity checkbox handlers
    for rarityName, checkbox in pairs(rarityCheckboxes) do
        checkbox.MouseButton1Click:Connect(function()
            AutoSell.ToggleRarity(rarityName, checkbox)
        end)
    end
end

function AutoSell.ToggleRarity(rarityName, checkbox)
    state.allowedRarities[rarityName] = not state.allowedRarities[rarityName]
    
    local rarityData = {
        COMMON = {color = Color3.fromRGB(150,150,150), icon = "🐟"},
        UNCOMMON = {color = Color3.fromRGB(0,255,200), icon = "💎"},
        RARE = {color = Color3.fromRGB(100,150,255), icon = "⭐"},
        EPIC = {color = Color3.fromRGB(150,50,200), icon = "💜"},
        LEGENDARY = {color = Color3.fromRGB(255,100,255), icon = "✨"},
        MYTHIC = {color = Color3.fromRGB(255,50,50), icon = "🔥"}
    }
    
    local rarity = rarityData[rarityName]
    if rarity then
        checkbox.Text = (state.allowedRarities[rarityName] and "☑️" or "☐") .. " " .. rarity.icon .. " " .. rarityName
        Utils.Notify("Auto Sell", rarity.icon .. " " .. rarityName .. ": " .. (state.allowedRarities[rarityName] and "Enabled" or "Disabled"))
    end
end

function AutoSell.SetEnabled(enabled)
    state.enabled = enabled
    if enabled then
        AutoSell.ResetSellCounts()
        Utils.Notify("Auto Sell", "🚀 Advanced Auto Sell enabled!")
    else
        state.isCurrentlySelling = false
        Utils.Notify("Auto Sell", "🛑 Auto Sell disabled")
    end
end

function AutoSell.SetThreshold(threshold)
    if threshold == state.threshold then return end
    
    state.threshold = threshold
    
    -- Try to sync with server
    task.spawn(function()
        local success = AutoSell.SyncThresholdWithServer(threshold)
        local syncStatus = success and " (Synced)" or " (Local)"
        Utils.Notify("Auto Sell", "🎯 Threshold set to: " .. threshold .. " fish" .. syncStatus)
    end)
end

function AutoSell.GetTotalFishForSell()
    local total = 0
    for rarity, count in pairs(state.sellCount) do
        if state.allowedRarities[rarity] then
            total = total + count
        end
    end
    return total
end

function AutoSell.ResetSellCounts()
    for rarity, _ in pairs(state.sellCount) do
        state.sellCount[rarity] = 0
    end
end

function AutoSell.ShouldSellFish(rarity)
    return state.allowedRarities[rarity] or false
end

function AutoSell.CheckAndAutoSell()
    if not state.enabled or state.isCurrentlySelling then
        return
    end
    
    local totalFishToSell = AutoSell.GetTotalFishForSell()
    if totalFishToSell < state.threshold then
        return
    end
    
    -- Check cooldown
    local now = tick()
    if now - state.lastSellTime < state.sellCooldown then
        return
    end
    
    AutoSell.ExecuteSell(totalFishToSell)
end

function AutoSell.ExecuteSell(totalFishToSell)
    state.isCurrentlySelling = true
    state.lastSellTime = tick()
    
    task.spawn(function()
        local success = pcall(function()
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            
            if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then 
                state.isCurrentlySelling = false
                return 
            end

            -- Save original position
            local originalCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            
            -- Teleport to seller (fallback coordinates)
            Utils.TeleportTo(CFrame.new(-31.10, 4.84, 2899.03))
            Utils.Notify("Auto Sell", string.format("🚀 Auto selling %d fish (Threshold: %d)", totalFishToSell, state.threshold))
            
            task.wait(1.5)

            -- Execute sell
            local sellRemote = Utils.ResolveRemote("RF/SellAllItems")
            if sellRemote then
                local sellSuccess = Utils.SafeInvoke(sellRemote)
                
                if sellSuccess then
                    Utils.Notify("Auto Sell", "✅ Auto sell successful!")
                    AutoSell.ResetSellCounts()
                else
                    Utils.Notify("Auto Sell", "❌ Auto sell failed!")
                end
            else
                Utils.Notify("Auto Sell", "❌ Sell remote not found!")
            end

            task.wait(1.5)

            -- Return to original position
            Utils.TeleportTo(originalCFrame)
            Utils.Notify("Auto Sell", "🏠 Returned to fishing spot")
        end)
        
        state.isCurrentlySelling = false
        
        if not success then
            Utils.Notify("Auto Sell", "❌ Auto sell error occurred")
        end
    end)
end

function AutoSell.SyncThresholdWithServer(threshold)
    local now = tick()
    if now - state.lastSyncTime < state.syncCooldown then
        return false
    end
    
    local updateThresholdRemote = Utils.ResolveRemote("RF/UpdateAutoSellThreshold")
    if not updateThresholdRemote then
        return false
    end
    
    state.lastSyncTime = now
    
    local success, result = Utils.SafeInvoke(updateThresholdRemote, threshold)
    
    if success then
        state.serverThreshold = threshold
        state.isThresholdSynced = true
        state.syncRetries = 0
        return true
    else
        state.syncRetries = state.syncRetries + 1
        state.isThresholdSynced = false
        
        -- Retry logic
        if state.syncRetries < state.maxSyncRetries then
            task.spawn(function()
                task.wait(state.syncCooldown * 2)
                AutoSell.SyncThresholdWithServer(threshold)
            end)
        end
        
        return false
    end
end

function AutoSell.InitializeServerSync()
    task.wait(2) -- Wait for game to fully load
    
    local serverThreshold = AutoSell.GetServerThreshold()
    if serverThreshold then
        state.threshold = serverThreshold
        state.serverThreshold = serverThreshold
        state.isThresholdSynced = true
        Utils.Notify("Auto Sell Sync", string.format("📥 Retrieved server threshold: %d", serverThreshold))
    else
        Utils.Notify("Auto Sell Sync", "⚠️ Could not retrieve server threshold, using local: " .. state.threshold)
        AutoSell.SyncThresholdWithServer(state.threshold)
    end
end

function AutoSell.GetServerThreshold()
    local updateThresholdRemote = Utils.ResolveRemote("RF/UpdateAutoSellThreshold")
    if not updateThresholdRemote then
        return nil
    end
    
    local success, result = Utils.SafeInvoke(updateThresholdRemote, 0)
    
    if success and type(result) == "number" and result > 0 then
        state.serverThreshold = result
        return result
    else
        return nil
    end
end

function AutoSell.StartStatusUpdater(statusLabel)
    task.spawn(function()
        while statusLabel.Parent do
            if state.enabled and statusLabel then
                local totalFish = AutoSell.GetTotalFishForSell()
                local syncStatus = state.isThresholdSynced and "✅" or "⚠️"
                statusLabel.Text = string.format("Active: %d/%d fish %s", totalFish, state.threshold, syncStatus)
                
                -- Color coding based on progress
                local progress = totalFish / state.threshold
                if progress >= 1.0 then
                    statusLabel.TextColor3 = Color3.fromRGB(255,100,100) -- Red when ready to sell
                elseif progress >= 0.8 then
                    statusLabel.TextColor3 = Color3.fromRGB(255,200,100) -- Orange when close
                else
                    statusLabel.TextColor3 = Color3.fromRGB(100,255,150) -- Green when normal
                end
            end
            task.wait(2)
        end
    end)
end

-- Fish caught event handler
function AutoSell.OnFishCaught(fishName)
    if not state.enabled then return end
    
    local rarity = Utils.GetFishRarity(fishName, Config.FishRarity)
    if state.sellCount[rarity] then
        state.sellCount[rarity] = state.sellCount[rarity] + 1
    end
    
    -- Check if we should auto sell
    AutoSell.CheckAndAutoSell()
end

-- Public API
function AutoSell.GetState()
    return state
end

function AutoSell.ToggleEnabled()
    AutoSell.SetEnabled(not state.enabled)
end

function AutoSell.ForceAutoSell()
    if state.enabled then
        AutoSell.CheckAndAutoSell()
    end
end

return AutoSell
