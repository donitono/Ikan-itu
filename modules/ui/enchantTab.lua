-- enchantTab.lua
-- Enchant Tab Module for ModernAutoFish

local EnchantTab = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Load dependencies
local BaseUI = require(script.Parent.baseUI)
local Utils = require(script.Parent.Parent.core.utils)
local Config = require(script.Parent.Parent.core.config)

-- Enchant System State
local EnchantSystem = {
    isActive = false,
    targetEnchants = {},
    currentRoll = nil,
    enchantStones = {},
    originalHotbar = {},
    rollCount = 0,
    maxRolls = 50
}

-- Enchant Types dari scan data
local ENCHANT_TYPES = {
    ["XPerienced I"] = {color = Color3.fromRGB(100, 255, 100), description = "Boost XP gain from fishing"},
    ["Stormhunter I"] = {color = Color3.fromRGB(100, 150, 255), description = "Better fishing during storm events"},
    ["Stargazer I"] = {color = Color3.fromRGB(255, 255, 100), description = "Night fishing bonus"},
    ["Reeler I"] = {color = Color3.fromRGB(255, 150, 100), description = "Faster reeling speed"},
    ["Prismatic I"] = {color = Color3.fromRGB(255, 100, 255), description = "Rainbow/colorful fish boost"},
    ["Mutation Hunter I"] = {color = Color3.fromRGB(150, 255, 150), description = "Increased mutated fish chance"},
    ["Mutation Hunter II"] = {color = Color3.fromRGB(100, 255, 100), description = "Higher mutated fish chance"},
    ["Leprechaun I"] = {color = Color3.fromRGB(100, 255, 100), description = "Better luck/rare fish chance"},
    ["Leprechaun II"] = {color = Color3.fromRGB(50, 255, 50), description = "Much better luck/rare fish chance"},
    ["Gold Digger I"] = {color = Color3.fromRGB(255, 215, 0), description = "More coins from fishing"},
    ["Glistening I"] = {color = Color3.fromRGB(255, 255, 255), description = "Shiny fish boost"},
    ["Empowered I"] = {color = Color3.fromRGB(255, 100, 100), description = "Overall fishing power increase"},
    ["Cursed I"] = {color = Color3.fromRGB(150, 0, 150), description = "High risk, high reward enchant"},
    ["Big Hunter I"] = {color = Color3.fromRGB(255, 150, 0), description = "Larger fish chance"}
}

-- Altar Location
local ALTAR_POSITION = CFrame.new(3237.61, -1302.33, 1398.04)

function EnchantTab.Create(contentContainer)
    local frame = Instance.new("Frame", contentContainer)
    frame.Name = "EnchantFrame"
    frame.Size = UDim2.new(1, 0, 1, -10)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false

    local scrollFrame = BaseUI.CreateScrollFrame(frame)

    -- Status Section
    local statusSection = BaseUI.CreateSection(
        scrollFrame,
        UDim2.new(0, 5, 0, 5),
        UDim2.new(1, -10, 0, 100),
        "✨ Enchant System Status",
        Color3.fromRGB(255, 215, 0)
    )
    
    EnchantTab.CreateStatusDisplay(statusSection)

    -- Location Section
    local locationSection = BaseUI.CreateSection(
        scrollFrame,
        UDim2.new(0, 5, 0, 115),
        UDim2.new(1, -10, 0, 80),
        "🏛️ Altar Navigation",
        Color3.fromRGB(150, 100, 255)
    )
    
    EnchantTab.CreateLocationControls(locationSection)

    -- Enchant Selection Section
    local selectionSection = BaseUI.CreateSection(
        scrollFrame,
        UDim2.new(0, 5, 0, 205),
        UDim2.new(1, -10, 0, 400),
        "🎯 Enchant Selection",
        Color3.fromRGB(100, 255, 150)
    )
    
    EnchantTab.CreateEnchantSelection(selectionSection)

    -- Control Section
    local controlSection = BaseUI.CreateSection(
        scrollFrame,
        UDim2.new(0, 5, 0, 615),
        UDim2.new(1, -10, 0, 120),
        "🎮 Enchant Controls",
        Color3.fromRGB(255, 100, 100)
    )
    
    EnchantTab.CreateEnchantControls(controlSection)

    -- Set canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 750)

    return frame
end

function EnchantTab.CreateStatusDisplay(parent)
    -- Status Label
    local statusLabel = Instance.new("TextLabel", parent)
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, 30)
    statusLabel.Text = "🔴 Inactive"
    statusLabel.Font = Enum.Font.GothamSemibold
    statusLabel.TextSize = 14
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Roll Counter
    local rollLabel = Instance.new("TextLabel", parent)
    rollLabel.Name = "RollLabel"
    rollLabel.Size = UDim2.new(1, -20, 0, 15)
    rollLabel.Position = UDim2.new(0, 10, 0, 55)
    rollLabel.Text = "Rolls: 0/50"
    rollLabel.Font = Enum.Font.Gotham
    rollLabel.TextSize = 12
    rollLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    rollLabel.BackgroundTransparency = 1
    rollLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Current Enchant Display
    local currentLabel = Instance.new("TextLabel", parent)
    currentLabel.Name = "CurrentLabel"
    currentLabel.Size = UDim2.new(1, -20, 0, 15)
    currentLabel.Position = UDim2.new(0, 10, 0, 75)
    currentLabel.Text = "Current Roll: None"
    currentLabel.Font = Enum.Font.Gotham
    currentLabel.TextSize = 12
    currentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    currentLabel.BackgroundTransparency = 1
    currentLabel.TextXAlignment = Enum.TextXAlignment.Left

    EnchantSystem.statusLabel = statusLabel
    EnchantSystem.rollLabel = rollLabel
    EnchantSystem.currentLabel = currentLabel
end

function EnchantTab.CreateLocationControls(parent)
    -- Distance Display
    local distanceLabel = Instance.new("TextLabel", parent)
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, -20, 0, 20)
    distanceLabel.Position = UDim2.new(0, 10, 0, 30)
    distanceLabel.Text = "Distance to Altar: Calculating..."
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 12
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Teleport Button
    local teleportBtn = BaseUI.CreateButton(
        parent,
        UDim2.new(0, 10, 0, 55),
        UDim2.new(0, 120, 0, 20),
        "🏛️ Go to Altar",
        Color3.fromRGB(150, 100, 255),
        function()
            EnchantTab.TeleportToAltar()
        end
    )

    -- Update distance
    spawn(function()
        while true do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - ALTAR_POSITION.Position).Magnitude
                distanceLabel.Text = string.format("Distance to Altar: %.1f studs", distance)
                
                if distance < 20 then
                    distanceLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                else
                    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
            wait(1)
        end
    end)
end

function EnchantTab.CreateEnchantSelection(parent)
    local yPos = 30
    local enchantFrames = {}
    
    for enchantName, enchantData in pairs(ENCHANT_TYPES) do
        local enchantFrame = Instance.new("Frame", parent)
        enchantFrame.Size = UDim2.new(1, -20, 0, 25)
        enchantFrame.Position = UDim2.new(0, 10, 0, yPos)
        enchantFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        enchantFrame.BorderSizePixel = 0
        Utils.CreateCorner(enchantFrame)

        -- Checkbox
        local checkbox = Instance.new("TextButton", enchantFrame)
        checkbox.Size = UDim2.new(0, 20, 0, 20)
        checkbox.Position = UDim2.new(0, 5, 0, 2.5)
        checkbox.Text = ""
        checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        checkbox.BorderSizePixel = 0
        Utils.CreateCorner(checkbox)

        local checkmark = Instance.new("TextLabel", checkbox)
        checkmark.Size = UDim2.new(1, 0, 1, 0)
        checkmark.Position = UDim2.new(0, 0, 0, 0)
        checkmark.Text = "✓"
        checkmark.Font = Enum.Font.GothamBold
        checkmark.TextSize = 14
        checkmark.TextColor3 = Color3.fromRGB(100, 255, 100)
        checkmark.BackgroundTransparency = 1
        checkmark.Visible = false

        -- Enchant Name
        local nameLabel = Instance.new("TextLabel", enchantFrame)
        nameLabel.Size = UDim2.new(0, 120, 0, 25)
        nameLabel.Position = UDim2.new(0, 30, 0, 0)
        nameLabel.Text = enchantName
        nameLabel.Font = Enum.Font.GothamSemibold
        nameLabel.TextSize = 12
        nameLabel.TextColor3 = enchantData.color
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left

        -- Description
        local descLabel = Instance.new("TextLabel", enchantFrame)
        descLabel.Size = UDim2.new(1, -160, 0, 25)
        descLabel.Position = UDim2.new(0, 155, 0, 0)
        descLabel.Text = enchantData.description
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 10
        descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        descLabel.BackgroundTransparency = 1
        descLabel.TextXAlignment = Enum.TextXAlignment.Left

        -- Checkbox functionality
        local isSelected = false
        checkbox.MouseButton1Click:Connect(function()
            isSelected = not isSelected
            checkmark.Visible = isSelected
            
            if isSelected then
                EnchantSystem.targetEnchants[enchantName] = true
                checkbox.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
            else
                EnchantSystem.targetEnchants[enchantName] = nil
                checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            end
            
            Utils.Notify("Enchant", (isSelected and "✓ Added: " or "✗ Removed: ") .. enchantName)
        end)

        enchantFrames[enchantName] = {
            frame = enchantFrame,
            checkbox = checkbox,
            checkmark = checkmark
        }

        yPos = yPos + 30
    end

    -- Select All / Deselect All buttons
    local selectAllBtn = BaseUI.CreateButton(
        parent,
        UDim2.new(0, 10, 0, yPos + 10),
        UDim2.new(0, 80, 0, 20),
        "Select All",
        Color3.fromRGB(100, 150, 255),
        function()
            for enchantName, frame in pairs(enchantFrames) do
                EnchantSystem.targetEnchants[enchantName] = true
                frame.checkmark.Visible = true
                frame.checkbox.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
            end
            Utils.Notify("Enchant", "✓ All enchants selected")
        end
    )

    local deselectAllBtn = BaseUI.CreateButton(
        parent,
        UDim2.new(0, 100, 0, yPos + 10),
        UDim2.new(0, 80, 0, 20),
        "Deselect All",
        Color3.fromRGB(255, 100, 100),
        function()
            for enchantName, frame in pairs(enchantFrames) do
                EnchantSystem.targetEnchants[enchantName] = nil
                frame.checkmark.Visible = false
                frame.checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            end
            Utils.Notify("Enchant", "✗ All enchants deselected")
        end
    )

    EnchantSystem.enchantFrames = enchantFrames
end

function EnchantTab.CreateEnchantControls(parent)
    -- Max Rolls Setting
    local rollsLabel = Instance.new("TextLabel", parent)
    rollsLabel.Size = UDim2.new(0, 80, 0, 20)
    rollsLabel.Position = UDim2.new(0, 10, 0, 30)
    rollsLabel.Text = "Max Rolls:"
    rollsLabel.Font = Enum.Font.Gotham
    rollsLabel.TextSize = 12
    rollsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    rollsLabel.BackgroundTransparency = 1
    rollsLabel.TextXAlignment = Enum.TextXAlignment.Left

    local rollsInput = Instance.new("TextBox", parent)
    rollsInput.Size = UDim2.new(0, 50, 0, 20)
    rollsInput.Position = UDim2.new(0, 95, 0, 30)
    rollsInput.Text = "50"
    rollsInput.Font = Enum.Font.Gotham
    rollsInput.TextSize = 12
    rollsInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    rollsInput.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    rollsInput.BorderSizePixel = 0
    rollsInput.TextXAlignment = Enum.TextXAlignment.Center
    Utils.CreateCorner(rollsInput)

    rollsInput.FocusLost:Connect(function()
        local maxRolls = tonumber(rollsInput.Text)
        if maxRolls and maxRolls > 0 and maxRolls <= 200 then
            EnchantSystem.maxRolls = maxRolls
        else
            rollsInput.Text = tostring(EnchantSystem.maxRolls)
            Utils.Notify("Enchant", "❌ Invalid max rolls! Use 1-200")
        end
    end)

    -- Start Button
    local startBtn = BaseUI.CreateButton(
        parent,
        UDim2.new(0, 10, 0, 60),
        UDim2.new(0, 100, 0, 25),
        "🎯 Start Rolling",
        Color3.fromRGB(100, 255, 100),
        function()
            EnchantTab.StartEnchanting()
        end
    )

    -- Stop Button
    local stopBtn = BaseUI.CreateButton(
        parent,
        UDim2.new(0, 120, 0, 60),
        UDim2.new(0, 100, 0, 25),
        "🛑 Stop Rolling",
        Color3.fromRGB(255, 100, 100),
        function()
            EnchantTab.StopEnchanting()
        end
    )

    -- Emergency Reset Button
    local resetBtn = BaseUI.CreateButton(
        parent,
        UDim2.new(0, 230, 0, 60),
        UDim2.new(0, 100, 0, 25),
        "🔄 Reset Hotbar",
        Color3.fromRGB(255, 150, 50),
        function()
            EnchantTab.ResetHotbar()
        end
    )

    EnchantSystem.startBtn = startBtn
    EnchantSystem.stopBtn = stopBtn
end

-- Core Enchanting Functions
function EnchantTab.TeleportToAltar()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = ALTAR_POSITION
        Utils.Notify("Enchant", "🏛️ Teleported to Enchanting Altar")
    end
end

function EnchantTab.PrepareHotbar()
    -- Save original hotbar
    local backpack = LocalPlayer.Backpack
    local character = LocalPlayer.Character
    
    if not character then return false end
    
    -- Clear hotbar slots 2, 3, 4, 5
    for i = 2, 5 do
        local tool = character:FindFirstChild("Slot" .. i)
        if tool then
            tool.Parent = backpack
        end
    end
    
    -- Find Enchant Stones in backpack
    local enchantStones = {}
    for _, item in pairs(backpack:GetChildren()) do
        if item.Name == "Enchant Stone" or item.Name == "Super Enchant Stone" then
            table.insert(enchantStones, item)
        end
    end
    
    if #enchantStones < 4 then
        Utils.Notify("Enchant", "❌ Need at least 4 Enchant Stones!")
        return false
    end
    
    -- Equip enchant stones to slots 2, 3, 4, 5
    for i = 1, 4 do
        if enchantStones[i] then
            enchantStones[i].Parent = character
            -- Set to specific hotbar slot if possible
        end
    end
    
    EnchantSystem.enchantStones = enchantStones
    Utils.Notify("Enchant", "✅ Hotbar prepared with Enchant Stones")
    return true
end

function EnchantTab.StartEnchanting()
    if EnchantSystem.isActive then
        Utils.Notify("Enchant", "❌ Enchanting already active!")
        return
    end
    
    -- Validate target enchants
    local targetCount = 0
    for _ in pairs(EnchantSystem.targetEnchants) do
        targetCount = targetCount + 1
    end
    
    if targetCount == 0 then
        Utils.Notify("Enchant", "❌ No target enchants selected!")
        return
    end
    
    -- Check distance to altar
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - ALTAR_POSITION.Position).Magnitude
        if distance > 30 then
            Utils.Notify("Enchant", "❌ Too far from altar! Distance: " .. math.floor(distance))
            return
        end
    end
    
    -- Prepare hotbar
    if not EnchantTab.PrepareHotbar() then
        return
    end
    
    -- Start enchanting process
    EnchantSystem.isActive = true
    EnchantSystem.rollCount = 0
    EnchantTab.UpdateStatus("🟡 Starting enchanting process...")
    
    Utils.Notify("Enchant", "🎯 Starting enchant rolling!")
    
    -- Start the enchanting loop
    spawn(function()
        EnchantTab.EnchantingLoop()
    end)
end

function EnchantTab.EnchantingLoop()
    while EnchantSystem.isActive and EnchantSystem.rollCount < EnchantSystem.maxRolls do
        -- Equip hotbar slot 2 (first enchant stone)
        if LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChild("Enchant Stone") or LocalPlayer.Character:FindFirstChild("Super Enchant Stone")
            if tool and tool:FindFirstChild("Handle") then
                -- Activate enchanting altar
                local activateRemote = ReplicatedStorage:FindFirstChild("Packages")
                if activateRemote then
                    activateRemote = activateRemote:FindFirstChild("_Index")
                    if activateRemote then
                        activateRemote = activateRemote:FindFirstChild("sleitnick_net@0.2.0")
                        if activateRemote then
                            activateRemote = activateRemote:FindFirstChild("net")
                            if activateRemote then
                                activateRemote = activateRemote:FindFirstChild("RE")
                                if activateRemote then
                                    activateRemote = activateRemote:FindFirstChild("ActivateEnchantingAltar")
                                    if activateRemote then
                                        activateRemote:FireServer()
                                        EnchantSystem.rollCount = EnchantSystem.rollCount + 1
                                        EnchantTab.UpdateRollCount()
                                        
                                        -- Wait for enchant result and check if it matches target
                                        wait(2) -- Wait for server response
                                        
                                        -- Check if we got a target enchant (this would need actual enchant detection)
                                        -- For now, we'll simulate random enchant detection
                                        local gotTargetEnchant = EnchantTab.CheckForTargetEnchant()
                                        
                                        if gotTargetEnchant then
                                            EnchantTab.StopEnchanting()
                                            Utils.Notify("Enchant", "🎉 Target enchant obtained: " .. gotTargetEnchant)
                                            return
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        wait(3) -- Wait between rolls
    end
    
    if EnchantSystem.rollCount >= EnchantSystem.maxRolls then
        EnchantTab.StopEnchanting()
        Utils.Notify("Enchant", "🛑 Max rolls reached without target enchant")
    end
end

function EnchantTab.CheckForTargetEnchant()
    -- This function would need to read the enchant UI or game state
    -- For demonstration, we'll return false (no target enchant found)
    -- In a real implementation, you'd check the enchanting interface
    
    -- Simulate random enchant result for testing
    local enchantNames = {}
    for name in pairs(ENCHANT_TYPES) do
        table.insert(enchantNames, name)
    end
    
    local randomEnchant = enchantNames[math.random(#enchantNames)]
    EnchantTab.UpdateCurrentRoll(randomEnchant)
    
    -- Check if this matches our targets
    if EnchantSystem.targetEnchants[randomEnchant] then
        return randomEnchant
    end
    
    return false
end

function EnchantTab.StopEnchanting()
    EnchantSystem.isActive = false
    EnchantTab.UpdateStatus("🔴 Stopped")
    EnchantTab.ResetHotbar()
    Utils.Notify("Enchant", "🛑 Enchanting stopped")
end

function EnchantTab.ResetHotbar()
    -- Restore original hotbar configuration
    local backpack = LocalPlayer.Backpack
    local character = LocalPlayer.Character
    
    if character then
        -- Move all tools back to backpack
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = backpack
            end
        end
    end
    
    Utils.Notify("Enchant", "🔄 Hotbar reset")
end

-- UI Update Functions
function EnchantTab.UpdateStatus(status)
    if EnchantSystem.statusLabel then
        EnchantSystem.statusLabel.Text = status
        
        if string.find(status, "🟢") then
            EnchantSystem.statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        elseif string.find(status, "🟡") then
            EnchantSystem.statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        else
            EnchantSystem.statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end

function EnchantTab.UpdateRollCount()
    if EnchantSystem.rollLabel then
        EnchantSystem.rollLabel.Text = string.format("Rolls: %d/%d", EnchantSystem.rollCount, EnchantSystem.maxRolls)
    end
end

function EnchantTab.UpdateCurrentRoll(enchantName)
    if EnchantSystem.currentLabel then
        EnchantSystem.currentLabel.Text = "Current Roll: " .. (enchantName or "None")
        
        if enchantName and ENCHANT_TYPES[enchantName] then
            EnchantSystem.currentLabel.TextColor3 = ENCHANT_TYPES[enchantName].color
        else
            EnchantSystem.currentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end

return EnchantTab
