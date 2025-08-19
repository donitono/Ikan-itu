--[[
🎯 Smart Enchant System Module
Advanced Target-Based Enchant Rolling for ModernAutoFish

Features:
- Smart target enchant selection
- Auto-stop when desired enchant found
- Multi-target support with priority system
- Real-time monitoring via chat/UI/inventory detection
- Test mode for safe experimentation
- Configurable max attempts and timeouts

Author: donitono
Repository: https://github.com/donitono/Ikan-itu
Version: 2.1.0
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- 🎯 SMART ENCHANT SYSTEM MODULE
local EnchantSystem = {
    -- Smart Enchant Configuration
    smartEnchantEnabled = false,
    targetEnchants = {}, -- Enchants yang user pilih sebagai target
    autoRollEnabled = false,
    rollAttempts = 0,
    maxRollAttempts = 100,
    currentRollSession = false,
    rollResults = {},
    smartEnchantUI = nil,
    lastEnchantCount = nil,
    
    -- Enchant Database
    availableEnchants = {
        -- 💰 MONEY ENCHANTS
        ["Leprechaun I"] = {
            type = "Money",
            description = "Increases coin drops from fish",
            multiplier = 1.25,
            cost = 500,
            level = 1,
            emoji = "🍀"
        },
        ["Leprechaun II"] = {
            type = "Money", 
            description = "Greatly increases coin drops from fish",
            multiplier = 1.5,
            cost = 1500,
            level = 2,
            emoji = "🍀"
        },
        ["Gold Digger I"] = {
            type = "Money",
            description = "Increases value of all catches",
            multiplier = 1.3,
            cost = 750,
            level = 1,
            emoji = "💰"
        },
        
        -- ⭐ LUCK ENCHANTS
        ["Prismatic I"] = {
            type = "Luck",
            description = "Increases chance of catching rare fish",
            luckBoost = 15,
            cost = 800,
            level = 1,
            emoji = "🌈"
        },
        ["Glistening I"] = {
            type = "Luck",
            description = "Increases shiny fish chance",
            shinyBoost = 20,
            cost = 600,
            level = 1,
            emoji = "✨"
        },
        ["Stargazer I"] = {
            type = "Luck",
            description = "Increases rare fish during night",
            nightBoost = 25,
            cost = 900,
            level = 1,
            emoji = "⭐"
        },
        
        -- 🎯 HUNTING ENCHANTS
        ["Mutation Hunter I"] = {
            type = "Hunting",
            description = "Increases mutated fish chance",
            mutationBoost = 30,
            cost = 1000,
            level = 1,
            emoji = "🧬"
        },
        ["Mutation Hunter II"] = {
            type = "Hunting",
            description = "Greatly increases mutated fish chance",
            mutationBoost = 50,
            cost = 2500,
            level = 2,
            emoji = "🧬"
        },
        ["Big Hunter I"] = {
            type = "Hunting",
            description = "Increases large fish chance",
            bigFishBoost = 35,
            cost = 1200,
            level = 1,
            emoji = "🐋"
        },
        ["Stormhunter I"] = {
            type = "Hunting",
            description = "Increases rare fish during storms",
            stormBoost = 40,
            cost = 1100,
            level = 1,
            emoji = "⛈️"
        },
        
        -- ⚡ PERFORMANCE ENCHANTS
        ["Reeler I"] = {
            type = "Performance",
            description = "Increases fishing speed",
            speedBoost = 20,
            cost = 700,
            level = 1,
            emoji = "⚡"
        },
        ["Empowered I"] = {
            type = "Performance", 
            description = "Increases rod power",
            powerBoost = 25,
            cost = 850,
            level = 1,
            emoji = "💪"
        },
        ["XPerienced I"] = {
            type = "Performance",
            description = "Increases XP gain from fishing",
            xpBoost = 50,
            cost = 650,
            level = 1,
            emoji = "📈"
        },
        
        -- 🔮 SPECIAL ENCHANTS
        ["Cursed I"] = {
            type = "Special",
            description = "Risk/reward enchant - higher chance for rare but also junk",
            rareBoost = 60,
            junkRisk = 30,
            cost = 2000,
            level = 1,
            emoji = "💀"
        }
    },
    
    currentEnchants = {},
    enchantSlots = 3,
    
    -- Remote Events untuk enchanting
    remotes = {
        activateAltar = "ReplicatedStorage/Packages/_Index/sleitnick_net@0.2.0/net/RE/ActivateEnchantingAltar",
        updateState = "ReplicatedStorage/Packages/_Index/sleitnick_net@0.2.0/net/RE/UpdateEnchantState", 
        rollEnchant = "ReplicatedStorage/Packages/_Index/sleitnick_net@0.2.0/net/RE/RollEnchant"
    }
}

-- 🔧 UTILITY FUNCTIONS
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 4})
    end)
    print("[Smart Enchant]", title, text)
end

local function findNet()
    local ok, net = pcall(function()
        local packages = ReplicatedStorage:FindFirstChild("Packages")
        if not packages then return nil end
        local idx = packages:FindFirstChild("_Index")
        if not idx then return nil end
        local sleit = idx:FindFirstChild("sleitnick_net@0.2.0")
        if not sleit then return nil end
        return sleit:FindFirstChild("net")
    end)
    return ok and net or nil
end

local function resolveRemote(name)
    local net = findNet()
    if not net then return nil end
    local ok, rem = pcall(function() return net:FindFirstChild(name) end)
    return ok and rem or nil
end

-- 🎯 SMART ENCHANT CORE FUNCTIONS

function EnchantSystem.AddTargetEnchant(enchantName)
    if not table.find(EnchantSystem.targetEnchants, enchantName) then
        table.insert(EnchantSystem.targetEnchants, enchantName)
        print("[Smart Enchant] Added target:", enchantName)
    end
end

function EnchantSystem.RemoveTargetEnchant(enchantName)
    local index = table.find(EnchantSystem.targetEnchants, enchantName)
    if index then
        table.remove(EnchantSystem.targetEnchants, index)
        print("[Smart Enchant] Removed target:", enchantName)
    end
end

function EnchantSystem.IsTargetEnchant(enchantName)
    return table.find(EnchantSystem.targetEnchants, enchantName) ~= nil
end

function EnchantSystem.StartSmartRoll()
    if #EnchantSystem.targetEnchants == 0 then
        notify("⚠️ Smart Enchant", "Please select target enchants first!")
        return false
    end
    
    EnchantSystem.smartEnchantEnabled = true
    EnchantSystem.autoRollEnabled = true
    EnchantSystem.rollAttempts = 0
    EnchantSystem.currentRollSession = true
    EnchantSystem.rollResults = {}
    
    notify("🎯 Smart Enchant", "Started rolling for target enchants!")
    
    -- Start monitoring enchant results
    EnchantSystem.MonitorEnchantResults()
    
    -- Start auto rolling
    task.spawn(function()
        EnchantSystem.AutoRollProcess()
    end)
    
    return true
end

function EnchantSystem.StopSmartRoll()
    EnchantSystem.smartEnchantEnabled = false
    EnchantSystem.autoRollEnabled = false
    EnchantSystem.currentRollSession = false
    
    notify("🛑 Smart Enchant", "Stopped smart enchant rolling")
end

function EnchantSystem.MonitorEnchantResults()
    task.spawn(function()
        local initialRodEnchants = EnchantSystem.GetCurrentRodEnchants()
        
        while EnchantSystem.currentRollSession do
            task.wait(1)
            
            -- Method 1: Check for target enchant in chat/UI
            local chatSuccess = EnchantSystem.CheckForTargetEnchant()
            if chatSuccess then
                EnchantSystem.StopSmartRoll()
                notify("🎉 Smart Enchant", "Target enchant found in chat! Stopping roll.")
                break
            end
            
            -- Method 2: Monitor fishing rod enchant changes
            local currentRodEnchants = EnchantSystem.GetCurrentRodEnchants()
            local newEnchant = EnchantSystem.CompareEnchants(initialRodEnchants, currentRodEnchants)
            
            if newEnchant and EnchantSystem.IsTargetEnchant(newEnchant) then
                EnchantSystem.StopSmartRoll()
                notify("🎉 Smart Enchant", "Target enchant '" .. newEnchant .. "' found on rod! Stopping roll.")
                break
            end
            
            -- Method 3: Monitor player data/stats changes
            if EnchantSystem.CheckPlayerDataForEnchant() then
                EnchantSystem.StopSmartRoll()
                notify("🎉 Smart Enchant", "Target enchant detected in player data! Stopping roll.")
                break
            end
            
            -- Update initial state for next comparison
            if newEnchant then
                initialRodEnchants = currentRodEnchants
                print("[Smart Enchant] Rod enchant changed to:", newEnchant)
            end
        end
    end)
end

function EnchantSystem.GetCurrentRodEnchants()
    local character = LocalPlayer.Character
    if not character then return {} end
    
    local equippedTool = character:FindFirstChildOfClass("Tool")
    if not equippedTool or not equippedTool.Name:lower():find("rod") then
        return {}
    end
    
    local enchants = {}
    
    -- Method 1: Check tool attributes/values
    for _, child in pairs(equippedTool:GetChildren()) do
        if child:IsA("StringValue") or child:IsA("ObjectValue") then
            if child.Name:lower():find("enchant") then
                table.insert(enchants, child.Value)
            end
        end
    end
    
    -- Method 2: Check tool configuration/ModuleScript
    local config = equippedTool:FindFirstChild("Configuration") or equippedTool:FindFirstChild("Settings")
    if config then
        for _, setting in pairs(config:GetChildren()) do
            if setting.Name:lower():find("enchant") and setting:IsA("StringValue") then
                table.insert(enchants, setting.Value)
            end
        end
    end
    
    return enchants
end

function EnchantSystem.CompareEnchants(oldEnchants, newEnchants)
    for _, newEnchant in pairs(newEnchants) do
        local isNew = true
        for _, oldEnchant in pairs(oldEnchants) do
            if newEnchant == oldEnchant then
                isNew = false
                break
            end
        end
        if isNew then
            return newEnchant
        end
    end
    return nil
end

function EnchantSystem.CheckPlayerDataForEnchant()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local enchantCount = leaderstats:FindFirstChild("Enchants") or leaderstats:FindFirstChild("TotalEnchants")
        if enchantCount and enchantCount:IsA("IntValue") then
            if not EnchantSystem.lastEnchantCount then
                EnchantSystem.lastEnchantCount = enchantCount.Value
                return false
            end
            
            if enchantCount.Value > EnchantSystem.lastEnchantCount then
                EnchantSystem.lastEnchantCount = enchantCount.Value
                return true
            end
        end
    end
    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local notifications = playerGui:FindFirstChild("Notifications") or playerGui:FindFirstChild("PopupNotifications")
    
    if notifications then
        for _, notification in pairs(notifications:GetDescendants()) do
            if notification:IsA("TextLabel") and notification.Visible then
                local text = notification.Text:lower()
                if string.find(text, "enchanted") or string.find(text, "enchant received") then
                    for _, targetEnchant in pairs(EnchantSystem.targetEnchants) do
                        if string.find(text, targetEnchant:lower()) then
                            return true
                        end
                    end
                end
            end
        end
    end
    
    return false
end

function EnchantSystem.CheckForTargetEnchant()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Check chat for enchant messages
    local chatGui = playerGui:FindFirstChild("Chat")
    if chatGui then
        local chatFrame = chatGui:FindFirstChild("Frame")
        if chatFrame and chatFrame:FindFirstChild("ChatChannelParentFrame") then
            local chatChannelParentFrame = chatFrame.ChatChannelParentFrame
            local chatFrame2 = chatChannelParentFrame:FindFirstChild("Frame_MessageLogDisplay")
            if chatFrame2 then
                local scroller = chatFrame2:FindFirstChild("Scroller")
                if scroller then
                    for _, child in pairs(scroller:GetChildren()) do
                        if child:IsA("Frame") and child:FindFirstChild("TextLabel") then
                            local message = child.TextLabel.Text:lower()
                            
                            if string.find(message, "enchanted") or 
                               string.find(message, "enchant") or
                               string.find(message, "received") then
                                
                                for _, targetEnchant in pairs(EnchantSystem.targetEnchants) do
                                    if string.find(message, targetEnchant:lower()) then
                                        print("[Smart Enchant] Found target enchant in chat:", targetEnchant)
                                        
                                        table.insert(EnchantSystem.rollResults, {
                                            enchant = targetEnchant,
                                            attempt = EnchantSystem.rollAttempts + 1,
                                            timestamp = tick()
                                        })
                                        
                                        return true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Check game notifications/announcements
    local announcements = playerGui:FindFirstChild("Announcements")
    if announcements then
        for _, child in pairs(announcements:GetDescendants()) do
            if child:IsA("TextLabel") and child.Text then
                local message = child.Text:lower()
                for _, targetEnchant in pairs(EnchantSystem.targetEnchants) do
                    if string.find(message, targetEnchant:lower()) then
                        print("[Smart Enchant] Found target enchant in announcement:", targetEnchant)
                        return true
                    end
                end
            end
        end
    end
    
    -- Check enchanting UI results
    local enchantingUI = playerGui:FindFirstChild("EnchantingInterface") or 
                        playerGui:FindFirstChild("EnchantingGUI") or
                        playerGui:FindFirstChild("EnchantUI")
    
    if enchantingUI then
        for _, child in pairs(enchantingUI:GetDescendants()) do
            if child:IsA("TextLabel") and child.Text then
                local text = child.Text:lower()
                for _, targetEnchant in pairs(EnchantSystem.targetEnchants) do
                    if string.find(text, targetEnchant:lower()) then
                        print("[Smart Enchant] Found target enchant in UI:", targetEnchant)
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

function EnchantSystem.AutoRollProcess()
    while EnchantSystem.autoRollEnabled and EnchantSystem.rollAttempts < EnchantSystem.maxRollAttempts do
        local success = EnchantSystem.PerformSingleRoll()
        
        if success then
            EnchantSystem.rollAttempts = EnchantSystem.rollAttempts + 1
            
            if EnchantSystem.smartEnchantUI then
                EnchantSystem.UpdateSmartEnchantUI()
            end
            
            task.wait(2)
        else
            task.wait(5)
        end
    end
    
    if EnchantSystem.rollAttempts >= EnchantSystem.maxRollAttempts then
        EnchantSystem.StopSmartRoll()
        notify("⏱️ Smart Enchant", "Reached maximum roll attempts!")
    end
end

function EnchantSystem.PerformSingleRoll()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    -- Teleport to enchant location if needed
    local currentPos = character.HumanoidRootPart.Position
    local enchantPos = Vector3.new(3237.61, -1302.33, 1398.04)
    local distance = (currentPos - enchantPos).Magnitude
    
    if distance > 20 then
        character.HumanoidRootPart.CFrame = CFrame.new(3237.61, -1302.33, 1398.04)
        task.wait(1)
    end
    
    -- Clear hotbar slots 2-4 first
    local equipRemote = resolveRemote("RE/EquipToolFromHotbar")
    for slot = 2, 4 do
        if equipRemote then
            pcall(function()
                equipRemote:FireServer(slot, nil)
            end)
        end
    end
    task.wait(0.5)
    
    -- Move enchant stones to hotbar if needed
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("enchant") then
                tool.Parent = character
                task.wait(0.2)
                if equipRemote then
                    pcall(function()
                        equipRemote:FireServer(2)
                    end)
                end
                break
            end
        end
    end
    
    task.wait(0.5)
    
    -- Ensure enchant stone equipped
    local equipped = character:FindFirstChildOfClass("Tool")
    if not equipped or not equipped.Name:lower():find("enchant") then
        if equipRemote then
            pcall(function()
                equipRemote:FireServer(2)
            end)
            task.wait(0.5)
        end
    end
    
    -- Update UI status
    if EnchantSystem.smartEnchantUI then
        local statusLabel = EnchantSystem.smartEnchantUI:FindFirstChild("StatusLabel")
        if statusLabel then
            statusLabel.Text = string.format("🔄 Rolling attempt #%d - Activating altar...", EnchantSystem.rollAttempts + 1)
        end
    end
    
    -- Activate enchant altar
    local altarRemote = resolveRemote("RE/ActivateEnchantingAltar")
    if altarRemote then
        pcall(function()
            altarRemote:FireServer()
        end)
        task.wait(1)
    end
    
    -- Update UI status
    if EnchantSystem.smartEnchantUI then
        local statusLabel = EnchantSystem.smartEnchantUI:FindFirstChild("StatusLabel")
        if statusLabel then
            statusLabel.Text = string.format("🎲 Rolling attempt #%d - Rolling enchant...", EnchantSystem.rollAttempts + 1)
        end
    end
    
    -- Perform enchant roll
    local rollRemote = resolveRemote("RE/RollEnchant")
    if rollRemote then
        pcall(function()
            rollRemote:FireServer()
        end)
        
        print("[Smart Enchant] Performed roll attempt #" .. (EnchantSystem.rollAttempts + 1))
        
        if EnchantSystem.smartEnchantUI then
            local statusLabel = EnchantSystem.smartEnchantUI:FindFirstChild("StatusLabel")
            if statusLabel then
                statusLabel.Text = string.format("⏳ Checking results for attempt #%d...", EnchantSystem.rollAttempts + 1)
            end
        end
        
        return true
    end
    
    return false
end

function EnchantSystem.UpdateSmartEnchantUI()
    if not EnchantSystem.smartEnchantUI then return end
    
    local statusLabel = EnchantSystem.smartEnchantUI:FindFirstChild("StatusLabel")
    if statusLabel then
        local targetList = table.concat(EnchantSystem.targetEnchants, ", ")
        statusLabel.Text = string.format("🎯 Rolling for: %s\n📊 Attempts: %d/%d", 
            targetList, EnchantSystem.rollAttempts, EnchantSystem.maxRollAttempts)
    end
end

-- 🧪 TESTING & UTILITY FUNCTIONS

function EnchantSystem.TestSmartEnchant()
    print("[Smart Enchant] Testing mode activated")
    notify("🧪 Smart Enchant Test", "Starting test mode - no actual rolling")
    
    task.spawn(function()
        for i = 1, 3 do
            task.wait(2)
            print("[Smart Enchant Test] Simulated roll attempt #" .. i)
            
            if EnchantSystem.smartEnchantUI then
                local statusLabel = EnchantSystem.smartEnchantUI:FindFirstChild("StatusLabel")
                if statusLabel then
                    statusLabel.Text = string.format("🧪 Test Mode - Simulated attempt #%d", i)
                end
            end
        end
        
        if #EnchantSystem.targetEnchants > 0 then
            local foundEnchant = EnchantSystem.targetEnchants[1]
            notify("🎉 Smart Enchant Test", "Simulated success! Found: " .. foundEnchant)
            
            if EnchantSystem.smartEnchantUI then
                local statusLabel = EnchantSystem.smartEnchantUI:FindFirstChild("StatusLabel")
                if statusLabel then
                    statusLabel.Text = "🎉 Test Complete - Simulated success: " .. foundEnchant
                end
            end
        end
    end)
end

function EnchantSystem.GetDetailedStatus()
    return {
        smartEnchantEnabled = EnchantSystem.smartEnchantEnabled,
        autoRollEnabled = EnchantSystem.autoRollEnabled,
        currentRollSession = EnchantSystem.currentRollSession,
        targetEnchants = EnchantSystem.targetEnchants,
        rollAttempts = EnchantSystem.rollAttempts,
        maxRollAttempts = EnchantSystem.maxRollAttempts,
        rollResults = EnchantSystem.rollResults
    }
end

-- 🔧 ENCHANT CALCULATION & OPTIMIZATION FUNCTIONS

function EnchantSystem.GetEnchantsByType(enchantType)
    local enchants = {}
    for name, data in pairs(EnchantSystem.availableEnchants) do
        if data.type == enchantType then
            table.insert(enchants, {name = name, data = data})
        end
    end
    return enchants
end

function EnchantSystem.GetBestEnchantsForGoal(goal)
    local recommendations = {}
    
    if goal == "Money" then
        table.insert(recommendations, "Leprechaun II")
        table.insert(recommendations, "Gold Digger I")
        table.insert(recommendations, "XPerienced I")
    elseif goal == "RareFish" then
        table.insert(recommendations, "Prismatic I")
        table.insert(recommendations, "Mutation Hunter II")
        table.insert(recommendations, "Stargazer I")
    elseif goal == "Speed" then
        table.insert(recommendations, "Reeler I")
        table.insert(recommendations, "Empowered I")
        table.insert(recommendations, "XPerienced I")
    elseif goal == "Events" then
        table.insert(recommendations, "Stormhunter I")
        table.insert(recommendations, "Stargazer I")
        table.insert(recommendations, "Mutation Hunter I")
    end
    
    return recommendations
end

function EnchantSystem.CalculateEnchantValue(enchantName)
    local enchant = EnchantSystem.availableEnchants[enchantName]
    if not enchant then return 0 end
    
    local value = 0
    
    if enchant.multiplier then
        value = value + (enchant.multiplier - 1) * 1000
    end
    if enchant.luckBoost then
        value = value + enchant.luckBoost * 20
    end
    if enchant.speedBoost then
        value = value + enchant.speedBoost * 15
    end
    if enchant.xpBoost then
        value = value + enchant.xpBoost * 10
    end
    
    local efficiency = value / enchant.cost
    
    return {
        totalValue = value,
        costEfficiency = efficiency,
        roi = (value - enchant.cost) / enchant.cost * 100
    }
end

function EnchantSystem.GetOptimalEnchantCombination(budget, goal)
    local available = {}
    for name, data in pairs(EnchantSystem.availableEnchants) do
        if data.cost <= budget then
            local value = EnchantSystem.CalculateEnchantValue(name)
            table.insert(available, {
                name = name,
                data = data,
                value = value,
                priority = EnchantSystem.GetEnchantPriority(name, goal)
            })
        end
    end
    
    table.sort(available, function(a, b)
        if a.priority == b.priority then
            return a.value.costEfficiency > b.value.costEfficiency
        end
        return a.priority > b.priority
    end)
    
    local combination = {}
    local totalCost = 0
    local slotsUsed = 0
    
    for _, enchant in ipairs(available) do
        if slotsUsed < EnchantSystem.enchantSlots and 
           totalCost + enchant.data.cost <= budget then
            table.insert(combination, enchant)
            totalCost = totalCost + enchant.data.cost
            slotsUsed = slotsUsed + 1
        end
    end
    
    return {
        enchants = combination,
        totalCost = totalCost,
        remainingBudget = budget - totalCost,
        slotsUsed = slotsUsed
    }
end

function EnchantSystem.GetEnchantPriority(enchantName, goal)
    local priorities = {
        Money = {
            ["Leprechaun II"] = 10,
            ["Leprechaun I"] = 8,
            ["Gold Digger I"] = 9,
            ["XPerienced I"] = 6
        },
        RareFish = {
            ["Prismatic I"] = 10,
            ["Mutation Hunter II"] = 9,
            ["Mutation Hunter I"] = 7,
            ["Stargazer I"] = 8,
            ["Big Hunter I"] = 7,
            ["Stormhunter I"] = 6
        },
        Speed = {
            ["Reeler I"] = 10,
            ["Empowered I"] = 8,
            ["XPerienced I"] = 6
        },
        Events = {
            ["Stormhunter I"] = 10,
            ["Stargazer I"] = 9,
            ["Mutation Hunter I"] = 8
        }
    }
    
    if priorities[goal] and priorities[goal][enchantName] then
        return priorities[goal][enchantName]
    end
    
    return 1
end

return EnchantSystem
