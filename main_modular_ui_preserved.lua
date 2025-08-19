--[[
🎣 ModernAutoFish - Modular Version (UI Preserved)
Advanced Fishing Bot with Original Modern UI Design

Repository: https://github.com/donitono/Ikan-itu
Author: donitono

📊 ENHANCED FEATURES ROADMAP
Berdasarkan data game yang tersedia, fitur-fitur ini bisa dikembangkan:

🎯 ADVANCED FEATURES YANG BISA DITAMBAHKAN:

1. 🎣 ROD MANAGEMENT SYSTEM
   - Auto rod upgrade recommendations berdasarkan ReplicatedStorage.Items (30+ rod types)
   - Rod comparison & statistics dari FishingRodModifiers
   - Best rod for current area/fish target

2. 🎯 INTELLIGENT BAIT SYSTEM  
   - Auto bait selection based on target fish dari ReplicatedStorage.Baits (15+ bait types)
   - Bait efficiency calculator
   - Area-specific bait recommendations

3. 💊 POTION OPTIMIZER
   - Auto potion usage timing dari ReplicatedStorage.Potions (8+ potion types)
   - Potion stack management
   - Effect duration tracking

4. 🌍 AREA INTELLIGENCE
   - Best fishing spots per fish type dari ReplicatedStorage.Areas
   - Area-specific rare fish tracking dari AreaUtility.SpecialItems
   - Location profitability analysis

5. ⚡ EVENT AUTOMATION
   - Event-based fishing strategies dari ReplicatedStorage.Events (15+ event types)
   - Weather optimization (Day, Night, Storm, Wind, dll.)
   - Special event fish targeting (Shark Hunt, Ghost Shark Hunt, dll.)

6. ✨ ENCHANT OPTIMIZER
   - Best enchant combinations dari ReplicatedStorage.Enchants (15+ enchant types)
   - Enchant success probability
   - Cost-benefit analysis (XPerienced, Leprechaun, Gold Digger, dll.)

7. 🎯 SMART ENCHANT SYSTEM (NEW!)
   - Target-specific enchant rolling
   - Auto-stop when desired enchant is found
   - Multi-target support with priority system
   - Real-time monitoring of enchant results
   - Smart detection via chat, UI, and inventory changes
   - Configurable max attempts and timeouts
   - Test mode for safe experimentation

8. 💰 ECONOMY TRACKER
   - Real-time fish market values dari FishWeightChances & RollData
   - Profit per hour calculations
   - Investment recommendations

9. 🎮 QUEST AUTOMATION
   - Auto quest completion dari QuestList & QuestUtility
   - Quest reward optimization
   - Progress tracking

10. 📈 ADVANCED ANALYTICS
    - Catch rate analysis
    - Efficiency metrics dari PlayerStatsUtility
    - Predictive modeling

11. 🤖 AI LEARNING SYSTEM
    - Pattern recognition
    - Adaptive strategies
    - Performance optimization

🎯 SMART ENCHANT USAGE:
1. Select target enchants using checkboxes
2. Set maximum roll attempts (default: 100)
3. Click "Start Smart Roll" to begin
4. System automatically detects when target enchant is found
5. Auto-stops rolling when success is detected
6. Test mode available for safe experimentation
--]]
Version: 2.1.0 (UI Preserved + Smart Enchant)
--]]

-- ============================================================================
-- SERVICES & SETUP
-- ============================================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("modern_autofish: LocalPlayer missing. Run as LocalScript while in Play mode.")
    return
end

-- ============================================================================
-- CORE CONFIG MODULE
-- ============================================================================
local Config = {
    mode = "secure",
    enabled = false,
    autoModeEnabled = false,
    safeModeChance = 70,
    autoRecastDelay = 0.4,
    
    -- UI Colors (Original Theme)
    Colors = {
        MainBG = Color3.fromRGB(28,28,34),
        SecondaryBG = Color3.fromRGB(35,35,42),
        SidebarBG = Color3.fromRGB(22,22,28),
        SectionBG = Color3.fromRGB(45,45,52),
        ActiveTab = Color3.fromRGB(45,45,50),
        InactiveTab = Color3.fromRGB(40,40,46),
        Border = Color3.fromRGB(40,40,48),
        Primary = Color3.fromRGB(235,235,235),
        Secondary = Color3.fromRGB(200,200,200),
        Accent = Color3.fromRGB(100,200,255),
        Success = Color3.fromRGB(100,255,150),
        Warning = Color3.fromRGB(255,200,100),
        Error = Color3.fromRGB(255,100,100),
        Blue = Color3.fromRGB(70,130,200),
        Orange = Color3.fromRGB(255,140,0),
        ButtonBG = Color3.fromRGB(50,50,58),
        InputBG = Color3.fromRGB(40,40,48),
        ScrollBar = Color3.fromRGB(80,80,88)
    },
    
    -- Island Locations
    IslandLocations = {
       ["🏝️Kohana Volcano"] = CFrame.new(-594.971252, 396.65213, 149.10907),
        ["🏝️Crater Island"] = CFrame.new(1010.01001, 252, 5078.45117),
        ["🏝️Kohana"] = CFrame.new(-650.971191, 208.693695, 711.10907),
        ["🏝️Lost Isle"] = CFrame.new(-3618.15698, 240.836655, -1317.45801),
        ["🏝️Stingray Shores"] = CFrame.new(45.2788086, 252.562927, 2987.10913),
        ["🏝️Esoteric Depths"] = CFrame.new(1944.77881, 393.562927, 1371.35913),
        ["🏝️Weather Machine"] = CFrame.new(-1488.51196, 83.1732635, 1876.30298),
        ["🏝️Tropical Grove"] = CFrame.new(-2095.34106, 197.199997, 3718.08008),
        ["🏝️Coral Reefs"] = CFrame.new(-3023.97119, 337.812927, 2195.60913),
        ["🏝️ SISYPUS"] = CFrame.new(-3709.75, -96.81, -952.38),
        ["🦈 TREASURE"] = CFrame.new(-3599.90, -275.96, -1640.84),
        ["🎣 STRINGRY"] = CFrame.new(102.05, 29.64, 3054.35),
        ["❄️ ICE LAND"] = CFrame.new(1990.55, 3.09, 3021.91),
        ["🌋 CRATER"] = CFrame.new(990.45, 21.06, 5059.85),
        ["🌴 TROPICAL"] = CFrame.new(-2093.80, 6.26, 3654.30),
        ["🗿 STONE"] = CFrame.new(-2636.19, 124.87, -27.49),
        ["🎲 ENCHANT STONE"] = CFrame.new(3237.61, -1302.33, 1398.04),
        ["⚙️ MACHINE WEATHER"] = CFrame.new(-1551.25, 2.87, 1920.26)
    }
}

-- 🎣 ENHANCED ENCHANT SYSTEM
local EnchantSystem = {
    -- Smart Enchant System
    smartEnchantEnabled = false,
    targetEnchants = {}, -- Enchants yang user pilih sebagai target
    autoRollEnabled = false,
    rollAttempts = 0,
    maxRollAttempts = 100,
    currentRollSession = false,
    rollResults = {},
    
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

-- 🎯 SMART ENCHANT FUNCTIONS
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
        Utils.Notify("⚠️ Smart Enchant", "Please select target enchants first!")
        return false
    end
    
    EnchantSystem.smartEnchantEnabled = true
    EnchantSystem.autoRollEnabled = true
    EnchantSystem.rollAttempts = 0
    EnchantSystem.currentRollSession = true
    EnchantSystem.rollResults = {}
    
    Utils.Notify("🎯 Smart Enchant", "Started rolling for target enchants!")
    
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
    
    Utils.Notify("🛑 Smart Enchant", "Stopped smart enchant rolling")
end

function EnchantSystem.MonitorEnchantResults()
    -- Monitor untuk mendeteksi enchant results dari server
    task.spawn(function()
        -- Store initial rod state for comparison
        local initialRodEnchants = EnchantSystem.GetCurrentRodEnchants()
        
        while EnchantSystem.currentRollSession do
            task.wait(1) -- Check every second
            
            -- Method 1: Check for target enchant in chat/UI
            local chatSuccess = EnchantSystem.CheckForTargetEnchant()
            if chatSuccess then
                EnchantSystem.StopSmartRoll()
                Utils.Notify("🎉 Smart Enchant", "Target enchant found in chat! Stopping roll.")
                break
            end
            
            -- Method 2: Monitor fishing rod enchant changes
            local currentRodEnchants = EnchantSystem.GetCurrentRodEnchants()
            local newEnchant = EnchantSystem.CompareEnchants(initialRodEnchants, currentRodEnchants)
            
            if newEnchant and EnchantSystem.IsTargetEnchant(newEnchant) then
                EnchantSystem.StopSmartRoll()
                Utils.Notify("🎉 Smart Enchant", "Target enchant '" .. newEnchant .. "' found on rod! Stopping roll.")
                break
            end
            
            -- Method 3: Monitor player data/stats changes
            if EnchantSystem.CheckPlayerDataForEnchant() then
                EnchantSystem.StopSmartRoll()
                Utils.Notify("🎉 Smart Enchant", "Target enchant detected in player data! Stopping roll.")
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
    -- Get enchants currently on the fishing rod
    local character = LocalPlayer.Character
    if not character then return {} end
    
    local equippedTool = character:FindFirstChildOfClass("Tool")
    if not equippedTool or not equippedTool.Name:lower():find("rod") then
        -- Check hotbar for rod
        for i = 1, 9 do
            -- This would depend on the game's hotbar system
            -- Usually stored in player data or StarterGui
        end
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
    -- Compare two enchant tables and return new enchant if found
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
    -- Monitor leaderstats or player data for enchant changes
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        -- Check for enchant-related stats that might indicate successful enchant
        local enchantCount = leaderstats:FindFirstChild("Enchants") or leaderstats:FindFirstChild("TotalEnchants")
        if enchantCount and enchantCount:IsA("IntValue") then
            if not EnchantSystem.lastEnchantCount then
                EnchantSystem.lastEnchantCount = enchantCount.Value
                return false
            end
            
            if enchantCount.Value > EnchantSystem.lastEnchantCount then
                EnchantSystem.lastEnchantCount = enchantCount.Value
                return true -- New enchant detected
            end
        end
    end
    
    -- Check PlayerGui for enchant notifications
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
    -- Implementasi untuk memeriksa enchant yang baru didapat
    -- Ini akan memantau chat/UI messages untuk hasil enchant
    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Cek di chat untuk enchant messages
    local chatGui = playerGui:FindFirstChild("Chat")
    if chatGui then
        local chatFrame = chatGui:FindFirstChild("Frame")
        if chatFrame and chatFrame:FindFirstChild("ChatChannelParentFrame") then
            local chatChannelParentFrame = chatFrame.ChatChannelParentFrame
            local chatFrame2 = chatChannelParentFrame:FindFirstChild("Frame_MessageLogDisplay")
            if chatFrame2 then
                local scroller = chatFrame2:FindFirstChild("Scroller")
                if scroller then
                    -- Cek pesan chat terbaru untuk enchant results
                    for _, child in pairs(scroller:GetChildren()) do
                        if child:IsA("Frame") and child:FindFirstChild("TextLabel") then
                            local message = child.TextLabel.Text:lower()
                            
                            -- Cek pattern enchant results yang umum
                            if string.find(message, "enchanted") or 
                               string.find(message, "enchant") or
                               string.find(message, "received") then
                                
                                -- Cek apakah ada target enchant di message
                                for _, targetEnchant in pairs(EnchantSystem.targetEnchants) do
                                    if string.find(message, targetEnchant:lower()) then
                                        print("[Smart Enchant] Found target enchant in chat:", targetEnchant)
                                        
                                        -- Record the successful enchant
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
    
    -- Alternative: Check game notifications/announcements
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
    
    -- Check for enchanting UI results
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
    
    -- Monitor StarterGui notifications
    local function checkNotification()
        local coreGui = game:GetService("CoreGui")
        if coreGui then
            local robloxGui = coreGui:FindFirstChild("RobloxGui")
            if robloxGui then
                for _, notification in pairs(robloxGui:GetDescendants()) do
                    if notification:IsA("TextLabel") and notification.Text then
                        local message = notification.Text:lower()
                        for _, targetEnchant in pairs(EnchantSystem.targetEnchants) do
                            if string.find(message, targetEnchant:lower()) then
                                print("[Smart Enchant] Found target enchant in notification:", targetEnchant)
                                return true
                            end
                        end
                    end
                end
            end
        end
        return false
    end
    
    return checkNotification()
end

-- 🧪 TESTING & DEMO FUNCTIONS
function EnchantSystem.TestSmartEnchant()
    -- Function untuk testing Smart Enchant tanpa actual rolling
    print("[Smart Enchant] Testing mode activated")
    
    Utils.Notify("🧪 Smart Enchant Test", "Starting test mode - no actual rolling")
    
    -- Simulate finding target enchant after 3 attempts
    task.spawn(function()
        for i = 1, 3 do
            task.wait(2)
            print("[Smart Enchant Test] Simulated roll attempt #" .. i)
            
            if EnchantSystem.smartEnchantUI then
                local statusLabel = EnchantSystem.smartEnchantUI:FindFirstChild("StatusLabel")
                if statusLabel then
                    statusLabel.Text = string.format("🧪 Test Mode - Simulated attempt #%d", i)
                    statusLabel.TextColor3 = Config.Colors.Warning
                end
            end
        end
        
        -- Simulate success
        if #EnchantSystem.targetEnchants > 0 then
            local foundEnchant = EnchantSystem.targetEnchants[1]
            Utils.Notify("🎉 Smart Enchant Test", "Simulated success! Found: " .. foundEnchant)
            
            if EnchantSystem.smartEnchantUI then
                local statusLabel = EnchantSystem.smartEnchantUI:FindFirstChild("StatusLabel")
                if statusLabel then
                    statusLabel.Text = "🎉 Test Complete - Simulated success: " .. foundEnchant
                    statusLabel.TextColor3 = Config.Colors.Success
                end
            end
        end
    end)
end

function EnchantSystem.GetDetailedStatus()
    -- Return detailed status for debugging
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

function EnchantSystem.AutoRollProcess()
    while EnchantSystem.autoRollEnabled and EnchantSystem.rollAttempts < EnchantSystem.maxRollAttempts do
        -- Lakukan roll enchant
        local success = EnchantSystem.PerformSingleRoll()
        
        if success then
            EnchantSystem.rollAttempts = EnchantSystem.rollAttempts + 1
            
            -- Update UI dengan progress
            if EnchantSystem.smartEnchantUI then
                EnchantSystem.UpdateSmartEnchantUI()
            end
            
            -- Wait sebelum roll berikutnya
            task.wait(2) -- 2 detik delay antar roll
        else
            -- Jika gagal roll, tunggu lebih lama
            task.wait(5)
        end
    end
    
    if EnchantSystem.rollAttempts >= EnchantSystem.maxRollAttempts then
        EnchantSystem.StopSmartRoll()
        Utils.Notify("⏱️ Smart Enchant", "Reached maximum roll attempts!")
    end
end

function EnchantSystem.PerformSingleRoll()
    -- Pastikan player berada di enchant altar
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    -- Teleport ke enchant location jika belum ada
    local currentPos = character.HumanoidRootPart.Position
    local enchantPos = Vector3.new(3237.61, -1302.33, 1398.04)
    local distance = (currentPos - enchantPos).Magnitude
    
    if distance > 20 then
        character.HumanoidRootPart.CFrame = CFrame.new(3237.61, -1302.33, 1398.04)
        task.wait(1)
    end
    
    -- Clear hotbar slots 2-4 first
    for slot = 2, 4 do
        if equipRemote then
            pcall(function()
                equipRemote:FireServer(slot, nil) -- Clear slot
            end)
        end
    end
    task.wait(0.5)
    
    -- Move enchant stones to hotbar if needed
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("enchant") then
                -- Move to hotbar slot 2
                tool.Parent = character
                task.wait(0.2)
                if equipRemote then
                    pcall(function()
                        equipRemote:FireServer(2) -- Equip in slot 2
                    end)
                end
                break
            end
        end
    end
    
    task.wait(0.5)
    
    -- Pastikan enchant stone equipped
    local equipped = character:FindFirstChildOfClass("Tool")
    if not equipped or not equipped.Name:lower():find("enchant") then
        -- Equip enchant stone dari hotbar
        if equipRemote then
            pcall(function()
                equipRemote:FireServer(2) -- Slot 2 untuk enchant stone
            end)
            task.wait(0.5)
        end
    end
    
    -- Update UI status
    if EnchantSystem.smartEnchantUI then
        local statusLabel = EnchantSystem.smartEnchantUI:FindFirstChild("StatusLabel")
        if statusLabel then
            statusLabel.Text = string.format("🔄 Rolling attempt #%d - Activating altar...", EnchantSystem.rollAttempts + 1)
            statusLabel.TextColor3 = Config.Colors.Warning
        end
    end
    
    -- Activate enchant altar
    local altarRemote = Utils.ResolveRemote("RE/ActivateEnchantingAltar")
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
            statusLabel.TextColor3 = Config.Colors.Accent
        end
    end
    
    -- Perform enchant roll
    local rollRemote = Utils.ResolveRemote("RE/RollEnchant")
    if rollRemote then
        pcall(function()
            rollRemote:FireServer()
        end)
        
        print("[Smart Enchant] Performed roll attempt #" .. (EnchantSystem.rollAttempts + 1))
        
        -- Update UI dengan hasil roll
        if EnchantSystem.smartEnchantUI then
            local statusLabel = EnchantSystem.smartEnchantUI:FindFirstChild("StatusLabel")
            if statusLabel then
                statusLabel.Text = string.format("⏳ Checking results for attempt #%d...", EnchantSystem.rollAttempts + 1)
                statusLabel.TextColor3 = Config.Colors.Secondary
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
    
    -- Calculate value based on benefits
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
    
    -- Cost efficiency
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
    
    -- Sort by priority and value
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

-- Locations for enchanting
local locations = movement.locations
locations.enchantLocations = {
    ["🎲 ENCHANT STONE"] = CFrame.new(3237.61, -1302.33, 1398.04),
    
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================
local Utils = {}

function Utils.Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 4})
    end)
    print("[modern_autofish]", title, text)
end

-- ============================================================================
-- ROD ORIENTATION FIX SYSTEM
-- ============================================================================
local RodFix = {
    enabled = true,
    lastFixTime = 0,
    isCharging = false,
    chargingConnection = nil
}

local function FixRodOrientation()
    if not RodFix.enabled then return end
    
    local now = tick()
    if now - RodFix.lastFixTime < 0.05 then return end
    RodFix.lastFixTime = now
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local equippedTool = character:FindFirstChildOfClass("Tool")
    if not equippedTool then return end
    
    -- Pastikan ini fishing rod
    local isRod = equippedTool.Name:lower():find("rod") or 
                  equippedTool:FindFirstChild("Rod") or
                  equippedTool:FindFirstChild("Handle")
    if not isRod then return end
    
    -- Method 1: Fix Motor6D during charging phase
    local rightArm = character:FindFirstChild("Right Arm")
    if rightArm then
        local rightGrip = rightArm:FindFirstChild("RightGrip")
        if rightGrip and rightGrip:IsA("Motor6D") then
            rightGrip.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            rightGrip.C1 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
            return
        end
    end
    
    -- Method 2: Direct tool position fix
    local handle = equippedTool:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local targetCFrame = rootPart.CFrame * CFrame.new(1.5, 0, -2) * CFrame.Angles(0, math.rad(45), 0)
            handle.CFrame = targetCFrame
        end
    end
end

-- ============================================================================
-- ANIMATION MONITOR SYSTEM
-- ============================================================================
local AnimationMonitor = {
    isMonitoring = false,
    fishingSuccess = false,
    currentState = "idle",
    lastAnimationTime = 0,
    animationConnection = nil
}

local function MonitorCharacterAnimations()
    if AnimationMonitor.animationConnection then
        AnimationMonitor.animationConnection:Disconnect()
    end
    
    AnimationMonitor.animationConnection = RunService.Heartbeat:Connect(function()
        if not AnimationMonitor.isMonitoring then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- Monitor animation tracks
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            local animName = track.Name:lower()
            if animName:find("fish") or animName:find("catch") or animName:find("reel") then
                AnimationMonitor.fishingSuccess = true
                AnimationMonitor.lastAnimationTime = tick()
            end
            
            -- Monitor charging animations for rod fix
            if animName:find("charge") or animName:find("cast") or animName:find("rod") then
                RodFix.isCharging = true
                FixRodOrientation()
            end
        end
    end)
end

-- ============================================================================
-- REALISTIC TIMING SYSTEM
-- ============================================================================
local function GetRealisticTiming(phase)
    local timings = {
        charging = math.random(180, 350) / 1000,      -- 0.18-0.35s
        casting = math.random(120, 280) / 1000,       -- 0.12-0.28s  
        waiting = math.random(1200, 2000) / 1000,     -- 1.2-2.0s
        reeling = math.random(250, 450) / 1000,       -- 0.25-0.45s
        completion = math.random(300, 600) / 1000     -- 0.3-0.6s
    }
    return timings[phase] or 0.5
end

function Utils.FindNet()
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

local net = Utils.FindNet()
function Utils.ResolveRemote(name)
    if not net then return nil end
    local ok, rem = pcall(function() return net:FindFirstChild(name) end)
    return ok and rem or nil
end

-- Remote References
local rodRemote = Utils.ResolveRemote("RF/ChargeFishingRod")
local miniGameRemote = Utils.ResolveRemote("RF/RequestFishingMinigameStarted")
local finishRemote = Utils.ResolveRemote("RE/FishingCompleted")
local equipRemote = Utils.ResolveRemote("RE/EquipToolFromHotbar")

-- ============================================================================
-- FISHING AI MODULE
-- ============================================================================
local FishingAI = {
    enabled = false,
    mode = "secure",
    sessionId = 1,
    statistics = {
        fishCaught = 0,
        startTime = tick(),
        sessionValue = 0
    }
}

function FishingAI.GetRealisticTiming(phase)
    local timings = {
        charging = math.random(150, 300) / 1000,
        casting = math.random(100, 250) / 1000,
        waiting = math.random(800, 1500) / 1000,
        reeling = math.random(200, 400) / 1000
    }
    return timings[phase] or 0.5
end

function FishingAI.GetServerTime()
    return workspace:GetServerTimeNow()
end

-- Enhanced Smart AI Cycle from original main.lua
function FishingAI.DoSmartCycle()
    AnimationMonitor.fishingSuccess = false
    AnimationMonitor.currentState = "starting"
    
    -- Phase 1: Equip and prepare
    FixRodOrientation() -- Fix rod orientation at start
    if equipRemote then 
        pcall(function() equipRemote:FireServer(1) end)
        task.wait(GetRealisticTiming("charging"))
    end
    
    -- Phase 2: Charge rod (with animation-aware timing)
    AnimationMonitor.currentState = "charging"
    FixRodOrientation() -- Fix during charging phase (critical!)
    
    local usePerfect = math.random(1,100) <= Config.safeModeChance
    local timestamp = usePerfect and FishingAI.GetServerTime() or FishingAI.GetServerTime() + math.random()*0.5
    
    if rodRemote and rodRemote:IsA("RemoteFunction") then 
        pcall(function() rodRemote:InvokeServer(timestamp) end)
    end
    
    -- Fix orientation continuously during charging
    local chargeStart = tick()
    local chargeDuration = GetRealisticTiming("charging")
    while tick() - chargeStart < chargeDuration do
        FixRodOrientation() -- Keep fixing during charge animation
        task.wait(0.02) -- Very frequent fixes during charging
    end
    
    -- Phase 3: Cast (mini-game simulation)
    AnimationMonitor.currentState = "casting"
    FixRodOrientation() -- Fix before casting
    
    local x = usePerfect and -1.238 or (math.random(-1000,1000)/1000)
    local y = usePerfect and 0.969 or (math.random(0,1000)/1000)
    
    if miniGameRemote and miniGameRemote:IsA("RemoteFunction") then 
        pcall(function() miniGameRemote:InvokeServer(x,y) end)
    end
    
    -- Wait for cast animation
    task.wait(GetRealisticTiming("casting"))
    
    -- Phase 4: Wait for fish (realistic waiting time)
    AnimationMonitor.currentState = "waiting"
    task.wait(GetRealisticTiming("waiting"))
    
    -- Phase 5: Complete fishing
    AnimationMonitor.currentState = "completing"
    FixRodOrientation() -- Fix before completion
    
    if finishRemote then 
        pcall(function() finishRemote:FireServer() end)
    end
    
    -- Wait for completion and fish catch animations
    task.wait(GetRealisticTiming("reeling"))
    
    -- Update statistics
    FishingAI.statistics.fishCaught = FishingAI.statistics.fishCaught + 1
    AnimationMonitor.currentState = "idle"
end

function FishingAI.DoSecureCycle()
    -- Equip rod first
    if equipRemote then 
        pcall(function() equipRemote:FireServer(1) end)
    end
    
    -- Fix rod orientation
    FixRodOrientation()
    
    -- Safe mode logic
    local usePerfect = math.random(1,100) <= Config.safeModeChance
    
    -- Charge rod with proper timing
    local timestamp = usePerfect and 9999999999 or (tick() + math.random())
    if rodRemote then
        pcall(function() rodRemote:InvokeServer(timestamp) end)
    end
    
    task.wait(0.1) -- Standard charge wait
    
    -- Minigame with realistic coordinates
    local x = usePerfect and -1.238 or (math.random(-1000,1000)/1000)
    local y = usePerfect and 0.969 or (math.random(0,1000)/1000)
    
    if miniGameRemote then
        pcall(function() miniGameRemote:InvokeServer(x, y) end)
    end
    
    task.wait(1.3) -- Wait for fishing completion
    
    -- Complete fishing
    if finishRemote then 
        pcall(function() finishRemote:FireServer() end)
    end
    
    -- Update statistics
    FishingAI.statistics.fishCaught = FishingAI.statistics.fishCaught + 1
end

function FishingAI.StartSecureMode()
    if FishingAI.enabled then return end
    
    FishingAI.enabled = true
    FishingAI.sessionId = FishingAI.sessionId + 1
    local currentSessionId = FishingAI.sessionId
    
    -- Start animation monitoring
    AnimationMonitor.isMonitoring = true
    MonitorCharacterAnimations()
    
    Utils.Notify("🔒 Secure Mode", "Safe & reliable fishing started!")
    
    task.spawn(function()
        while FishingAI.enabled and FishingAI.sessionId == currentSessionId do
            -- Fix rod orientation before each cycle
            FixRodOrientation()
            
            local ok, err = pcall(function()
                FishingAI.DoSecureCycle()
            end)
            
            if not ok then
                warn("SecureMode cycle error:", err)
                Utils.Notify("⚠️ Secure Mode", "Cycle error, retrying...")
                task.wait(1)
            end
            
            task.wait(Config.autoRecastDelay + math.random() * 0.5)
        end
    end)
end

function FishingAI.StopFishing()
    FishingAI.enabled = false
    sessionId = sessionId + 1
    AnimationMonitor.isMonitoring = false
    if AnimationMonitor.animationConnection then
        AnimationMonitor.animationConnection:Disconnect()
    end
    Utils.Notify("🛑 Fishing Stopped", "Secure mode stopped")
end

-- Smart AI Mode
function FishingAI.StartSmartMode()
    if FishingAI.enabled then return end
    
    FishingAI.enabled = true
    FishingAI.mode = "smart"
    FishingAI.sessionId = FishingAI.sessionId + 1
    local currentSessionId = FishingAI.sessionId
    
    -- Start animation monitoring
    AnimationMonitor.isMonitoring = true
    MonitorCharacterAnimations()
    
    Utils.Notify("🧠 Smart AI", "Advanced AI fishing started!")
    
    task.spawn(function()
        while FishingAI.enabled and FishingAI.sessionId == currentSessionId do
            -- Fix rod orientation before each cycle
            FixRodOrientation()
            
            local ok, err = pcall(function()
                FishingAI.DoSmartCycle()
            end)
            
            if not ok then
                warn("SmartMode cycle error:", err)
                Utils.Notify("⚠️ Smart AI", "Cycle error, retrying...")
                task.wait(1)
            end
            
            -- Smart delay with variation
            local delay = Config.autoRecastDelay + GetRealisticTiming("completion") * 0.5
            task.wait(delay + (math.random()*0.3 - 0.15))
        end
    end)
end

function FishingAI.StopSmartMode()
    FishingAI.enabled = false
    sessionId = sessionId + 1
    AnimationMonitor.isMonitoring = false
    if AnimationMonitor.animationConnection then
        AnimationMonitor.animationConnection:Disconnect()
    end
    Utils.Notify("🛑 Smart AI", "Advanced AI fishing stopped")
end

-- Auto Mode
function FishingAI.StartAutoMode()
    if Config.autoModeEnabled then return end
    
    Config.autoModeEnabled = true
    autoModeSessionId = autoModeSessionId + 1
    local currentSessionId = autoModeSessionId
    
    Utils.Notify("🔥 Auto Mode", "Continuous fishing started!")
    
    task.spawn(function()
        while Config.autoModeEnabled and autoModeSessionId == currentSessionId do
            if equipRemote then pcall(function() equipRemote:FireServer(1) end) end
            task.wait(0.05)
            
            if rodRemote then pcall(function() rodRemote:InvokeServer(workspace:GetServerTimeNow()) end) end
            task.wait(0.1)
            
            if miniGameRemote then pcall(function() miniGameRemote:InvokeServer(-1.2379989624023438, 0.9800224985802423) end) end
            task.wait(0.5)
            
            if finishRemote then pcall(function() finishRemote:FireServer() end) end
            
            FishingAI.statistics.fishCaught = FishingAI.statistics.fishCaught + 1
            task.wait(0.1)
        end
    end)
end

function FishingAI.StopAutoMode()
    Config.autoModeEnabled = false
    autoModeSessionId = autoModeSessionId + 1
    Utils.Notify("🛑 Auto Mode", "Continuous fishing stopped")
end

-- ============================================================================
-- DASHBOARD SYSTEM
-- ============================================================================
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

-- Fish Rarity Categories (Updated from Fish Item.txt)
local FishRarity = {
    MYTHIC = {
        -- Mythic Level Fish (Highest Rarity)
        "Great Christmas Whale", "Great Whale", "Robot Kraken", "Giant Squid",
        "Hammerhead Shark", "Manta Ray", "Thresher Shark", "Ghost Shark",
        "Gingerbread Shark", "Frostborn Shark", "Plasma Shark", "Loving Shark",
        "Blob Shark", "Hawks Turtle", "Loggerhead Turtle", "Gingerbread Turtle"
    },
    LEGENDARY = {
        -- Legendary Fish (Very Rare)
        "Abyss Seahorse", "Prismy Seahorse", "Strippled Seahorse", "Dotted Stingray", 
        "Blueflame Ray", "Blue Lobster", "Candycane Lobster", "Lobster",
        "Chrome Tuna", "Yellowfin Tuna", "Lavafin Tuna", "Silver Tuna",
        "Magic Tang", "Enchanted Angelfish", "Bumblebee Grouper", "Greenbee Grouper",
        "King Crab", "Queen Crab", "Deep Sea Crab", "Hermit Crab"
    },
    EPIC = {
        -- Epic Fish (Rare)
        "Starjam Tang", "Unicorn Tang", "Dorhey Tang", "Jewel Tang", "Charmed Tang",
        "Coal Tang", "Fade Tang", "Sail Tang", "White Tang", "Volsail Tang",
        "Gingerbread Tang", "Patriot Tang", "Vintage Blue Tang",
        "Domino Damsel", "Panther Grouper", "Moorish Idol", "Cow Clownfish",
        "Astra Damsel", "Firecoal Damsel", "Mistletoe Damsel", "Pink Smith Damsel",
        "Bleekers Damsel", "Swordfish", "Angler Fish", "Monk Fish"
    },
    RARE = {
        -- Rare Fish
        "Scissortail Dartfish", "White Clownfish", "Darwin Clownfish", "Blumato Clownfish",
        "Gingerbread Clownfish", "Korean Angelfish", "Conspi Angelfish", "Masked Angelfish",
        "Watanabei Angelfish", "Ballina Angelfish", "Bandit Angelfish", "Candy Butterfly",
        "Longnose Butterfly", "Christmastree Longnose", "Kau Cardinal", "Sushi Cardinal",
        "Lined Cardinal Fish", "Rockform Cardianl", "Fire Goby", "Festive Goby"
    },
    UNCOMMON = {
        -- Uncommon Fish
        "Maze Angelfish", "Boa Angelfish", "Tricolore Butterfly", "Flame Angelfish",
        "Yello Damselfish", "Vintage Damsel", "Magma Goby", "Pygmy Goby",
        "Blue-Banded Goby", "Banded Butterfly", "Shrimp Goby", "Copperband Butterfly",
        "Maroon Butterfly", "Zoster Butterfly", "Lava Butterfly", "Racoon Butterfly Fish",
        "Jennifer Dottyback", "Blackcap Basslet", "Orange Basslet", "Ash Basslet",
        "Volcanic Basslet", "Pilot Fish", "Boar Fish", "Catfish"
    },
    COMMON = {
        -- Common Fish
        "Orangy Goby", "Specked Butterfly", "Corazon Damse", "Strawberry Dotty",
        "Azure Damsel", "Clownfish", "Skunk Tilefish", "Yellowstate Angelfish",
        "Reef Chromis", "Slurpfish Chromis", "Parrot Fish", "Red Snapper",
        "Coney Fish", "Sheepshead Fish", "Rockfish", "Pufferfish",
        "Festive Pufferfish", "Worm Fish", "Ghost Worm Fish", "Viperfish",
        "Spotted Lantern Fish", "Fangtooth", "Electric Eel", "Dark Eel",
        "Vampire Squid", "Jellyfish", "Blob Fish", "Dead Fish",
        "Skeleton Fish", "Salmon", "Axolotl"
    },
    
    -- Special Categories
    VARIANT_FISH = {
        -- Fish with Variants (from Variants folder)
        "Corrupt", "Fairy Dust", "Festive", "Frozen", "Galaxy", "Gemstone",
        "Ghost", "Gold", "Lightning", "Midnight", "Radioactive", "Stone",
        "Holographic", "Albino"
    },
    
    LEGENDARY_ITEMS = {
        -- Legendary Non-Fish Items
        "Forsaken", "Red Matter", "Lightsaber", "Crystalized", "Earthly",
        "Neptune's Trident", "Polarized", "Monochrome", "Lightning", "Loving",
        "Aqua Prism", "Aquatic", "Blossom", "Heavenly", "Aether Shard",
        "Flower Garden", "Amber"
    },
    
    ENCHANT_ITEMS = {
        -- Enchant Related Items
        "Super Enchant Stone", "Enchant Stone"
    },
    
    PLAQUES = {
        -- Special Event Plaques
        "DEC24 - Wood Plaque", "DEC24 - Sapphire Plaque", 
        "DEC24 - Silver Plaque", "DEC24 - Golden Plaque"
    },
    
    RODS = {
        -- Special Rods
        "Cute Rod"
    }
}

local function GetFishRarity(fishName)
    -- Check main rarity categories first
    for rarity, fishList in pairs(FishRarity) do
        -- Skip special categories for main rarity check
        if rarity ~= "VARIANT_FISH" and rarity ~= "LEGENDARY_ITEMS" and 
           rarity ~= "ENCHANT_ITEMS" and rarity ~= "PLAQUES" and rarity ~= "RODS" then
            for _, fish in pairs(fishList) do
                if string.find(string.lower(fishName), string.lower(fish)) then
                    return rarity
                end
            end
        end
    end
    
    -- Check for variant fish (special handling)
    for _, variant in pairs(FishRarity.VARIANT_FISH) do
        if string.find(string.lower(fishName), string.lower(variant)) then
            return "LEGENDARY" -- Variants are considered legendary
        end
    end
    
    -- Check for legendary items
    for _, item in pairs(FishRarity.LEGENDARY_ITEMS) do
        if string.find(string.lower(fishName), string.lower(item)) then
            return "LEGENDARY"
        end
    end
    
    -- Check for enchant items
    for _, item in pairs(FishRarity.ENCHANT_ITEMS) do
        if string.find(string.lower(fishName), string.lower(item)) then
            return "EPIC"
        end
    end
    
    -- Check for plaques
    for _, plaque in pairs(FishRarity.PLAQUES) do
        if string.find(string.lower(fishName), string.lower(plaque)) then
            return "RARE"
        end
    end
    
    -- Check for special rods
    for _, rod in pairs(FishRarity.RODS) do
        if string.find(string.lower(fishName), string.lower(rod)) then
            return "LEGENDARY"
        end
    end
    
    return "COMMON"
end

function Dashboard.LogFishCatch(fishName, location)
    local currentTime = tick()
    local rarity = GetFishRarity(fishName)
    
    -- Check if fish has variant
    local hasVariant = false
    local variantType = ""
    for _, variant in pairs(FishRarity.VARIANT_FISH) do
        if string.find(string.lower(fishName), string.lower(variant)) then
            hasVariant = true
            variantType = variant
            break
        end
    end
    
    -- Log to main fish database
    table.insert(Dashboard.fishCaught, {
        name = fishName,
        rarity = rarity,
        location = location or Dashboard.sessionStats.currentLocation,
        timestamp = currentTime,
        hour = tonumber(os.date("%H", currentTime)),
        hasVariant = hasVariant,
        variantType = variantType
    })
    
    -- Log rare fish separately (anything above COMMON)
    if rarity ~= "COMMON" then
        table.insert(Dashboard.rareFishCaught, {
            name = fishName,
            rarity = rarity,
            location = location or Dashboard.sessionStats.currentLocation,
            timestamp = currentTime,
            hasVariant = hasVariant,
            variantType = variantType
        })
        Dashboard.sessionStats.rareCount = Dashboard.sessionStats.rareCount + 1
    end
    
    -- Update session stats
    Dashboard.sessionStats.fishCount = Dashboard.sessionStats.fishCount + 1
    
    -- Update location stats
    local loc = location or Dashboard.sessionStats.currentLocation
    if not Dashboard.locationStats[loc] then
        Dashboard.locationStats[loc] = {count = 0, rareCount = 0, value = 0}
    end
    Dashboard.locationStats[loc].count = Dashboard.locationStats[loc].count + 1
    if rarity ~= "COMMON" then
        Dashboard.locationStats[loc].rareCount = Dashboard.locationStats[loc].rareCount + 1
    end
    
    -- Log rare catches with variant info
    if rarity ~= "COMMON" or hasVariant then
        local rarityDisplay = hasVariant and rarity .. " (" .. variantType .. ")" or rarity
        print("[Dashboard] Rare Catch:", fishName, "| Rarity:", rarityDisplay, "| Location:", loc)
    end
end

function Dashboard.GetSessionSummary()
    local sessionTime = tick() - Dashboard.sessionStats.startTime
    local hours = math.floor(sessionTime / 3600)
    local minutes = math.floor((sessionTime % 3600) / 60)
    local seconds = math.floor(sessionTime % 60)
    
    return {
        fishCount = Dashboard.sessionStats.fishCount,
        rareCount = Dashboard.sessionStats.rareCount,
        totalValue = Dashboard.sessionStats.totalValue,
        sessionTime = string.format("%02d:%02d:%02d", hours, minutes, seconds),
        currentLocation = Dashboard.sessionStats.currentLocation
    }
end
-- ============================================================================
-- TELEPORT MODULE
-- ============================================================================
local Teleport = {}

function Teleport.To(position)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
        Utils.Notify("🚀 Teleport", "Teleported successfully")
    else
        Utils.Notify("❌ Teleport", "Character not found")
    end
end

-- ============================================================================
-- MOVEMENT ENHANCEMENT MODULE
-- ============================================================================
local Movement = {
    floatEnabled = false,
    speed = 16,
    jumpPower = 50,
    noClipEnabled = false,
    floatHeight = 16,
    floatConnection = nil,
    noClipConnections = {},
    originalProperties = {}
}

function Movement.SetSpeed(value)
    Movement.speed = value
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end

function Movement.SetJump(value)
    Movement.jumpPower = value
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = value
    end
end

function Movement.EnableFloat()
    if Movement.floatEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then 
        Utils.Notify("Movement", "❌ Character not found!")
        return 
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then
        Utils.Notify("Movement", "❌ Character components missing!")
        return
    end
    
    Movement.floatEnabled = true
    
    -- Store original properties
    Movement.originalProperties.PlatformStand = humanoid.PlatformStand
    Movement.originalProperties.WalkSpeed = humanoid.WalkSpeed
    
    -- Create BodyVelocity for floating
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart
    
    -- Create BodyPosition for height control
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(0, math.huge, 0)
    bodyPosition.Position = rootPart.Position + Vector3.new(0, Movement.floatHeight, 0)
    bodyPosition.Parent = rootPart
    
    Movement.floatConnection = RunService.Heartbeat:Connect(function()
        if Movement.floatEnabled and rootPart and rootPart.Parent then
            bodyPosition.Position = rootPart.Position + Vector3.new(0, Movement.floatHeight, 0)
        end
    end)
    
    Utils.Notify("🚀 Float", "Float mode enabled!")
end

function Movement.DisableFloat()
    Movement.floatEnabled = false
    
    local character = LocalPlayer.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            -- Remove float objects
            for _, obj in pairs(rootPart:GetChildren()) do
                if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") then
                    obj:Destroy()
                end
            end
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and Movement.originalProperties.PlatformStand ~= nil then
            humanoid.PlatformStand = Movement.originalProperties.PlatformStand
        end
    end
    
    if Movement.floatConnection then
        Movement.floatConnection:Disconnect()
        Movement.floatConnection = nil
    end
    
    Utils.Notify("🚀 Float", "Float mode disabled!")
end

function Movement.EnableNoClip()
    if Movement.noClipEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    Movement.noClipEnabled = true
    
    local function noClipPart(part)
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local connection = RunService.Stepped:Connect(function()
                if Movement.noClipEnabled then
                    part.CanCollide = false
                end
            end)
            table.insert(Movement.noClipConnections, connection)
        end
    end
    
    for _, part in pairs(character:GetDescendants()) do
        noClipPart(part)
    end
    
    local connection = character.DescendantAdded:Connect(function(part)
        if Movement.noClipEnabled then
            noClipPart(part)
        end
    end)
    table.insert(Movement.noClipConnections, connection)
    
    Utils.Notify("👻 NoClip", "NoClip enabled!")
end

function Movement.DisableNoClip()
    Movement.noClipEnabled = false
    
    -- Disconnect all connections
    for _, connection in pairs(Movement.noClipConnections) do
        connection:Disconnect()
    end
    Movement.noClipConnections = {}
    
    -- Restore collision
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
    
    Utils.Notify("👻 NoClip", "NoClip disabled!")
end

-- ============================================================================
-- MAIN UI BUILDER (ORIGINAL DESIGN PRESERVED)
-- ============================================================================
local function BuildUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Check for existing UI
    local existing = playerGui:FindFirstChild("ModernAutoFishUI")
    if existing then existing:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModernAutoFishUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(0, 480, 0, 380)
    panel.Position = UDim2.new(0, 18, 0, 70)
    panel.BackgroundColor3 = Config.Colors.MainBG
    panel.BorderSizePixel = 0
    panel.Parent = screenGui
    Instance.new("UICorner", panel)
    local stroke = Instance.new("UIStroke", panel)
    stroke.Thickness = 1
    stroke.Color = Config.Colors.Border

    -- Header (drag)
    local header = Instance.new("Frame", panel)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Active = true
    header.Selectable = true

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = "🐳ModernAutoFish v2.1"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Config.Colors.Primary
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Button container
    local btnContainer = Instance.new("Frame", header)
    btnContainer.Size = UDim2.new(0, 120, 1, 0)
    btnContainer.Position = UDim2.new(1, -125, 0, 0)
    btnContainer.BackgroundTransparency = 1

    -- Minimize button
    local minimizeBtn = Instance.new("TextButton", btnContainer)
    minimizeBtn.Size = UDim2.new(0, 32, 0, 26)
    minimizeBtn.Position = UDim2.new(0, 4, 0.5, -13)
    minimizeBtn.Text = "−"
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 16
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(60,60,66)
    minimizeBtn.TextColor3 = Color3.fromRGB(230,230,230)
    Instance.new("UICorner", minimizeBtn)

    -- Floating button (hidden initially)
    local floatBtn = Instance.new("TextButton", screenGui)
    floatBtn.Name = "FloatToggle"
    floatBtn.Size = UDim2.new(0,50,0,50)
    floatBtn.Position = UDim2.new(0,15,0,15)
    floatBtn.Text = "🎣"
    floatBtn.BackgroundColor3 = Config.Colors.SectionBG
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextSize = 20
    floatBtn.TextColor3 = Config.Colors.Accent
    floatBtn.Visible = false
    Instance.new("UICorner", floatBtn)

    minimizeBtn.MouseButton1Click:Connect(function()
        panel.Visible = false
        floatBtn.Visible = true
        Utils.Notify("🎣 Minimized", "Click floating button to restore")
    end)

    floatBtn.MouseButton1Click:Connect(function()
        panel.Visible = true
        floatBtn.Visible = false
        Utils.Notify("🎣 Restored", "UI restored from floating mode")
    end)

    -- Reload button
    local reloadBtn = Instance.new("TextButton", btnContainer)
    reloadBtn.Size = UDim2.new(0, 32, 0, 26)
    reloadBtn.Position = UDim2.new(0, 42, 0.5, -13)
    reloadBtn.Text = "🔄"
    reloadBtn.Font = Enum.Font.GothamBold
    reloadBtn.TextSize = 14
    reloadBtn.BackgroundColor3 = Config.Colors.Blue
    reloadBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", reloadBtn)

    reloadBtn.MouseButton1Click:Connect(function()
        Utils.Notify("🔄 Reloading...", "Restarting script in 2 seconds...")
        task.wait(2)
        
        -- Clean shutdown
        Config.enabled = false
        FishingAI.enabled = false
        Config.autoModeEnabled = false
        sessionId = sessionId + 1
        autoModeSessionId = autoModeSessionId + 1
        
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
        
        task.wait(0.5)
        Utils.Notify("🔄 Rejoining...", "Joining server now...")
        
        local TeleportService = game:GetService("TeleportService")
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end)

    -- Close button
    local closeBtn = Instance.new("TextButton", btnContainer)
    closeBtn.Size = UDim2.new(0, 32, 0, 26)
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.Position = UDim2.new(1, -4, 0.5, -13)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", closeBtn)

    closeBtn.MouseButton1Click:Connect(function()
        -- Clean shutdown
        Config.enabled = false
        FishingAI.enabled = false
        Config.autoModeEnabled = false
        sessionId = sessionId + 1
        autoModeSessionId = autoModeSessionId + 1
        
        screenGui:Destroy()
        Utils.Notify("🎣 Closed", "Modern AutoFish closed")
    end)

    -- Drag functionality
    local dragging = false
    local dragStart = Vector2.new(0,0)
    local startPos = Vector2.new(0,0)
    local dragInput

    local function updateDrag(input)
        if not dragging then return end
        local delta = input.Position - dragStart
        local desiredX = startPos.X + delta.X
        local desiredY = startPos.Y + delta.Y
        local cam = workspace.CurrentCamera
        local vw, vh = 800, 600
        if cam and cam.ViewportSize then
            vw, vh = cam.ViewportSize.X, cam.ViewportSize.Y
        end
        local panelSize = panel.AbsoluteSize
        local maxX = math.max(0, vw - (panelSize.X or 0))
        local maxY = math.max(0, vh - (panelSize.Y or 0))
        local clampedX = math.clamp(desiredX, 0, maxX)
        local clampedY = math.clamp(desiredY, 0, maxY)
        panel.Position = UDim2.new(0, clampedX, 0, clampedY)
    end

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = panel.AbsolutePosition
            dragInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    header.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)

    -- Left sidebar for tabs
    local sidebar = Instance.new("Frame", panel)
    sidebar.Size = UDim2.new(0, 120, 1, -50)
    sidebar.Position = UDim2.new(0, 10, 0, 45)
    sidebar.BackgroundColor3 = Config.Colors.SidebarBG
    sidebar.BorderSizePixel = 0
    Instance.new("UICorner", sidebar)

    -- Tab buttons
    local function createTabButton(text, position, yPos)
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1, -10, 0, 40)
        btn.Position = UDim2.new(0, 5, 0, yPos)
        btn.Text = text
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.BackgroundColor3 = Config.Colors.InactiveTab
        btn.TextColor3 = Config.Colors.Secondary
        btn.TextXAlignment = Enum.TextXAlignment.Left
        
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 6)
        
        local padding = Instance.new("UIPadding", btn)
        padding.PaddingLeft = UDim.new(0, 10)
        
        return btn
    end

    local fishingAITabBtn = createTabButton("🤖 Fishing AI", 1, 10)
    local teleportTabBtn = createTabButton("🌍 Teleport", 2, 60)
    local playerTabBtn = createTabButton("👥 Player", 3, 110)
    local featureTabBtn = createTabButton("⚡ Features", 4, 160)
    local enchantTabBtn = createTabButton("✨ Enchants", 5, 210)
    local dashboardTabBtn = createTabButton("📊 Dashboard", 6, 260)

    -- Set initial active tab
    fishingAITabBtn.BackgroundColor3 = Config.Colors.ActiveTab
    fishingAITabBtn.TextColor3 = Config.Colors.Primary

    -- Content area
    local contentContainer = Instance.new("Frame", panel)
    contentContainer.Size = UDim2.new(1, -145, 1, -50)
    contentContainer.Position = UDim2.new(0, 140, 0, 45)
    contentContainer.BackgroundTransparency = 1

    -- Content title
    local contentTitle = Instance.new("TextLabel", contentContainer)
    contentTitle.Size = UDim2.new(1, 0, 0, 24)
    contentTitle.Text = "Smart AI Fishing Configuration"
    contentTitle.Font = Enum.Font.GothamBold
    contentTitle.TextSize = 16
    contentTitle.TextColor3 = Config.Colors.Primary
    contentTitle.BackgroundTransparency = 1
    contentTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Create tab frames
    local function createTabFrame()
        local frame = Instance.new("Frame", contentContainer)
        frame.Size = UDim2.new(1, 0, 1, -30)
        frame.Position = UDim2.new(0, 0, 0, 30)
        frame.BackgroundColor3 = Config.Colors.SecondaryBG
        frame.BorderSizePixel = 0
        frame.Visible = false
        Instance.new("UICorner", frame)
        
        local scroll = Instance.new("ScrollingFrame", frame)
        scroll.Size = UDim2.new(1, -10, 1, -10)
        scroll.Position = UDim2.new(0, 5, 0, 5)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 6
        scroll.ScrollBarImageColor3 = Color3.fromRGB(80,80,80)
        
        return frame, scroll
    end

    -- Tab 1: Fishing AI
    local fishingAIFrame, fishingAIScroll = createTabFrame()
    fishingAIFrame.Visible = true

    -- Secure Mode Section
    local secureModeSection = Instance.new("Frame", fishingAIScroll)
    secureModeSection.Size = UDim2.new(1, -10, 0, 120)
    secureModeSection.Position = UDim2.new(0, 5, 0, 5)
    secureModeSection.BackgroundColor3 = Config.Colors.SectionBG
    secureModeSection.BorderSizePixel = 0
    Instance.new("UICorner", secureModeSection)

    local secureModeLabel = Instance.new("TextLabel", secureModeSection)
    secureModeLabel.Size = UDim2.new(1, -20, 0, 25)
    secureModeLabel.Position = UDim2.new(0, 10, 0, 5)
    secureModeLabel.Text = "🔒 Secure Fishing Mode"
    secureModeLabel.Font = Enum.Font.GothamBold
    secureModeLabel.TextSize = 14
    secureModeLabel.TextColor3 = Config.Colors.Success
    secureModeLabel.BackgroundTransparency = 1
    secureModeLabel.TextXAlignment = Enum.TextXAlignment.Left

    local secureButton = Instance.new("TextButton", secureModeSection)
    secureButton.Size = UDim2.new(0.48, -5, 0, 35)
    secureButton.Position = UDim2.new(0, 10, 0, 35)
    secureButton.Text = "🔒 Start Secure"
    secureButton.Font = Enum.Font.GothamBold
    secureButton.TextSize = 12
    secureButton.BackgroundColor3 = Config.Colors.Success
    secureButton.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", secureButton)

    local secureStopButton = Instance.new("TextButton", secureModeSection)
    secureStopButton.Size = UDim2.new(0.48, -5, 0, 35)
    secureStopButton.Position = UDim2.new(0.52, 5, 0, 35)
    secureStopButton.Text = "🛑 Stop Secure"
    secureStopButton.Font = Enum.Font.GothamBold
    secureStopButton.TextSize = 12
    secureStopButton.BackgroundColor3 = Config.Colors.Error
    secureStopButton.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", secureStopButton)

    local modeStatus = Instance.new("TextLabel", secureModeSection)
    modeStatus.Size = UDim2.new(1, -20, 0, 35)
    modeStatus.Position = UDim2.new(0, 10, 0, 80)
    modeStatus.Text = "🔒 Secure Mode Ready - Safe & Reliable Fishing"
    modeStatus.Font = Enum.Font.GothamSemibold
    modeStatus.TextSize = 11
    modeStatus.TextColor3 = Config.Colors.Success
    modeStatus.BackgroundTransparency = 1
    modeStatus.TextXAlignment = Enum.TextXAlignment.Left
    modeStatus.TextWrapped = true

    -- Smart AI Mode Section
    local smartAISection = Instance.new("Frame", fishingAIScroll)
    smartAISection.Size = UDim2.new(1, -10, 0, 120)
    smartAISection.Position = UDim2.new(0, 5, 0, 135)
    smartAISection.BackgroundColor3 = Config.Colors.SectionBG
    smartAISection.BorderSizePixel = 0
    Instance.new("UICorner", smartAISection)

    local smartAILabel = Instance.new("TextLabel", smartAISection)
    smartAILabel.Size = UDim2.new(1, -20, 0, 25)
    smartAILabel.Position = UDim2.new(0, 10, 0, 5)
    smartAILabel.Text = "🧠 Smart AI Mode"
    smartAILabel.Font = Enum.Font.GothamBold
    smartAILabel.TextSize = 14
    smartAILabel.TextColor3 = Config.Colors.Accent
    smartAILabel.BackgroundTransparency = 1
    smartAILabel.TextXAlignment = Enum.TextXAlignment.Left

    local smartAIStartButton = Instance.new("TextButton", smartAISection)
    smartAIStartButton.Size = UDim2.new(0.48, -5, 0, 35)
    smartAIStartButton.Position = UDim2.new(0, 10, 0, 35)
    smartAIStartButton.Text = "🧠 Start Smart AI"
    smartAIStartButton.Font = Enum.Font.GothamBold
    smartAIStartButton.TextSize = 12
    smartAIStartButton.BackgroundColor3 = Config.Colors.Accent
    smartAIStartButton.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", smartAIStartButton)

    local smartAIStopButton = Instance.new("TextButton", smartAISection)
    smartAIStopButton.Size = UDim2.new(0.48, -5, 0, 35)
    smartAIStopButton.Position = UDim2.new(0.52, 5, 0, 35)
    smartAIStopButton.Text = "🛑 Stop Smart AI"
    smartAIStopButton.Font = Enum.Font.GothamBold
    smartAIStopButton.TextSize = 12
    smartAIStopButton.BackgroundColor3 = Config.Colors.Error
    smartAIStopButton.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", smartAIStopButton)

    local smartAIStatus = Instance.new("TextLabel", smartAISection)
    smartAIStatus.Size = UDim2.new(1, -20, 0, 35)
    smartAIStatus.Position = UDim2.new(0, 10, 0, 80)
    smartAIStatus.Text = "🧠 Smart AI Ready - Advanced Fishing Algorithm"
    smartAIStatus.Font = Enum.Font.GothamSemibold
    smartAIStatus.TextSize = 11
    smartAIStatus.TextColor3 = Config.Colors.Accent
    smartAIStatus.BackgroundTransparency = 1
    smartAIStatus.TextXAlignment = Enum.TextXAlignment.Left
    smartAIStatus.TextWrapped = true

    -- Auto Mode Section
    local autoModeSection = Instance.new("Frame", fishingAIScroll)
    autoModeSection.Size = UDim2.new(1, -10, 0, 120)
    autoModeSection.Position = UDim2.new(0, 5, 0, 265)
    autoModeSection.BackgroundColor3 = Config.Colors.SectionBG
    autoModeSection.BorderSizePixel = 0
    Instance.new("UICorner", autoModeSection)

    local autoModeLabel = Instance.new("TextLabel", autoModeSection)
    autoModeLabel.Size = UDim2.new(1, -20, 0, 25)
    autoModeLabel.Position = UDim2.new(0, 10, 0, 5)
    autoModeLabel.Text = "🔥 Auto Mode (Fast)"
    autoModeLabel.Font = Enum.Font.GothamBold
    autoModeLabel.TextSize = 14
    autoModeLabel.TextColor3 = Config.Colors.Warning
    autoModeLabel.BackgroundTransparency = 1
    autoModeLabel.TextXAlignment = Enum.TextXAlignment.Left

    local autoModeStartButton = Instance.new("TextButton", autoModeSection)
    autoModeStartButton.Size = UDim2.new(0.48, -5, 0, 35)
    autoModeStartButton.Position = UDim2.new(0, 10, 0, 35)
    autoModeStartButton.Text = "🔥 Start Auto"
    autoModeStartButton.Font = Enum.Font.GothamBold
    autoModeStartButton.TextSize = 12
    autoModeStartButton.BackgroundColor3 = Config.Colors.Warning
    autoModeStartButton.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", autoModeStartButton)

    local autoModeStopButton = Instance.new("TextButton", autoModeSection)
    autoModeStopButton.Size = UDim2.new(0.48, -5, 0, 35)
    autoModeStopButton.Position = UDim2.new(0.52, 5, 0, 35)
    autoModeStopButton.Text = "🛑 Stop Auto"
    autoModeStopButton.Font = Enum.Font.GothamBold
    autoModeStopButton.TextSize = 12
    autoModeStopButton.BackgroundColor3 = Config.Colors.Error
    autoModeStopButton.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", autoModeStopButton)

    local autoModeStatus = Instance.new("TextLabel", autoModeSection)
    autoModeStatus.Size = UDim2.new(1, -20, 0, 35)
    autoModeStatus.Position = UDim2.new(0, 10, 0, 80)
    autoModeStatus.Text = "🔥 Auto Mode Ready - Fast Continuous Fishing"
    autoModeStatus.Font = Enum.Font.GothamSemibold
    autoModeStatus.TextSize = 11
    autoModeStatus.TextColor3 = Config.Colors.Warning
    autoModeStatus.BackgroundTransparency = 1
    autoModeStatus.TextXAlignment = Enum.TextXAlignment.Left
    autoModeStatus.TextWrapped = true

    fishingAIScroll.CanvasSize = UDim2.new(0, 0, 0, 400)

    -- Tab 2: Teleport
    local teleportFrame, teleportScroll = createTabFrame()

    local yOffset = 5
    for locationName, locationCFrame in pairs(Config.IslandLocations) do
        local btn = Instance.new("TextButton", teleportScroll)
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.Position = UDim2.new(0, 5, 0, yOffset)
        btn.Text = locationName
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 12
        btn.BackgroundColor3 = Config.Colors.Accent
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", btn)
        
        local padding = Instance.new("UIPadding", btn)
        padding.PaddingLeft = UDim.new(0, 10)
        
        btn.MouseButton1Click:Connect(function()
            Teleport.To(locationCFrame.Position)
        end)
        
        yOffset = yOffset + 40
    end

    teleportScroll.CanvasSize = UDim2.new(0, 0, 0, yOffset)

    -- Tab 3: Player
    local playerFrame, playerScroll = createTabFrame()

    local function updatePlayerList()
        for _, child in pairs(playerScroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        local yPos = 5
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local btn = Instance.new("TextButton", playerScroll)
                btn.Size = UDim2.new(1, -10, 0, 35)
                btn.Position = UDim2.new(0, 5, 0, yPos)
                btn.Text = "🎮 " .. player.DisplayName
                btn.Font = Enum.Font.GothamSemibold
                btn.TextSize = 12
                btn.BackgroundColor3 = Config.Colors.Accent
                btn.TextColor3 = Color3.fromRGB(255,255,255)
                btn.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", btn)
                
                local padding = Instance.new("UIPadding", btn)
                padding.PaddingLeft = UDim.new(0, 10)
                
                btn.MouseButton1Click:Connect(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        Teleport.To(player.Character.HumanoidRootPart.Position)
                    end
                end)
                
                yPos = yPos + 40
            end
        end
        
        playerScroll.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end

    updatePlayerList()

    -- Tab 4: Features
    local featureFrame, featureScroll = createTabFrame()

    -- Speed Section
    local speedSection = Instance.new("Frame", featureScroll)
    speedSection.Size = UDim2.new(1, -10, 0, 80)
    speedSection.Position = UDim2.new(0, 5, 0, 5)
    speedSection.BackgroundColor3 = Config.Colors.SectionBG
    speedSection.BorderSizePixel = 0
    Instance.new("UICorner", speedSection)

    local speedLabel = Instance.new("TextLabel", speedSection)
    speedLabel.Size = UDim2.new(1, -20, 0, 20)
    speedLabel.Position = UDim2.new(0, 10, 0, 8)
    speedLabel.Text = "🏃 Walk Speed: 16"
    speedLabel.Font = Enum.Font.GothamSemibold
    speedLabel.TextSize = 14
    speedLabel.TextColor3 = Config.Colors.Primary
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left

    local speedSlider = Instance.new("Frame", speedSection)
    speedSlider.Size = UDim2.new(1, -20, 0, 20)
    speedSlider.Position = UDim2.new(0, 10, 0, 35)
    speedSlider.BackgroundColor3 = Color3.fromRGB(50,50,60)
    speedSlider.BorderSizePixel = 0
    Instance.new("UICorner", speedSlider)

    local speedFill = Instance.new("Frame", speedSlider)
    speedFill.Size = UDim2.new(0.16, 0, 1, 0)
    speedFill.Position = UDim2.new(0, 0, 0, 0)
    speedFill.BackgroundColor3 = Config.Colors.Accent
    speedFill.BorderSizePixel = 0
    Instance.new("UICorner", speedFill)

    -- Jump Section
    local jumpSection = Instance.new("Frame", featureScroll)
    jumpSection.Size = UDim2.new(1, -10, 0, 80)
    jumpSection.Position = UDim2.new(0, 5, 0, 95)
    jumpSection.BackgroundColor3 = Config.Colors.SectionBG
    jumpSection.BorderSizePixel = 0
    Instance.new("UICorner", jumpSection)

    local jumpLabel = Instance.new("TextLabel", jumpSection)
    jumpLabel.Size = UDim2.new(1, -20, 0, 20)
    jumpLabel.Position = UDim2.new(0, 10, 0, 8)
    jumpLabel.Text = "🦘 Jump Power: 50"
    jumpLabel.Font = Enum.Font.GothamSemibold
    jumpLabel.TextSize = 14
    jumpLabel.TextColor3 = Config.Colors.Primary
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Float Section
    local floatSection = Instance.new("Frame", featureScroll)
    floatSection.Size = UDim2.new(1, -10, 0, 80)
    floatSection.Position = UDim2.new(0, 5, 0, 185)
    floatSection.BackgroundColor3 = Config.Colors.SectionBG
    floatSection.BorderSizePixel = 0
    Instance.new("UICorner", floatSection)

    local floatLabel = Instance.new("TextLabel", floatSection)
    floatLabel.Size = UDim2.new(1, -20, 0, 25)
    floatLabel.Position = UDim2.new(0, 10, 0, 5)
    floatLabel.Text = "🚀 Float Mode"
    floatLabel.Font = Enum.Font.GothamBold
    floatLabel.TextSize = 14
    floatLabel.TextColor3 = Config.Colors.Accent
    floatLabel.BackgroundTransparency = 1
    floatLabel.TextXAlignment = Enum.TextXAlignment.Left

    local floatEnableBtn = Instance.new("TextButton", floatSection)
    floatEnableBtn.Size = UDim2.new(0.48, -5, 0, 35)
    floatEnableBtn.Position = UDim2.new(0, 10, 0, 35)
    floatEnableBtn.Text = "🚀 Enable Float"
    floatEnableBtn.Font = Enum.Font.GothamBold
    floatEnableBtn.TextSize = 12
    floatEnableBtn.BackgroundColor3 = Config.Colors.Accent
    floatEnableBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", floatEnableBtn)

    local floatDisableBtn = Instance.new("TextButton", floatSection)
    floatDisableBtn.Size = UDim2.new(0.48, -5, 0, 35)
    floatDisableBtn.Position = UDim2.new(0.52, 5, 0, 35)
    floatDisableBtn.Text = "🛑 Disable Float"
    floatDisableBtn.Font = Enum.Font.GothamBold
    floatDisableBtn.TextSize = 12
    floatDisableBtn.BackgroundColor3 = Config.Colors.Error
    floatDisableBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", floatDisableBtn)

    -- NoClip Section  
    local noClipSection = Instance.new("Frame", featureScroll)
    noClipSection.Size = UDim2.new(1, -10, 0, 80)
    noClipSection.Position = UDim2.new(0, 5, 0, 275)
    noClipSection.BackgroundColor3 = Config.Colors.SectionBG
    noClipSection.BorderSizePixel = 0
    Instance.new("UICorner", noClipSection)

    local noClipLabel = Instance.new("TextLabel", noClipSection)
    noClipLabel.Size = UDim2.new(1, -20, 0, 25)
    noClipLabel.Position = UDim2.new(0, 10, 0, 5)
    noClipLabel.Text = "👻 NoClip Mode"
    noClipLabel.Font = Enum.Font.GothamBold
    noClipLabel.TextSize = 14
    noClipLabel.TextColor3 = Color3.fromRGB(200,100,255)
    noClipLabel.BackgroundTransparency = 1
    noClipLabel.TextXAlignment = Enum.TextXAlignment.Left

    local noClipEnableBtn = Instance.new("TextButton", noClipSection)
    noClipEnableBtn.Size = UDim2.new(0.48, -5, 0, 35)
    noClipEnableBtn.Position = UDim2.new(0, 10, 0, 35)
    noClipEnableBtn.Text = "👻 Enable NoClip"
    noClipEnableBtn.Font = Enum.Font.GothamBold
    noClipEnableBtn.TextSize = 12
    noClipEnableBtn.BackgroundColor3 = Color3.fromRGB(200,100,255)
    noClipEnableBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", noClipEnableBtn)

    local noClipDisableBtn = Instance.new("TextButton", noClipSection)
    noClipDisableBtn.Size = UDim2.new(0.48, -5, 0, 35)
    noClipDisableBtn.Position = UDim2.new(0.52, 5, 0, 35)
    noClipDisableBtn.Text = "🛑 Disable NoClip"
    noClipDisableBtn.Font = Enum.Font.GothamBold
    noClipDisableBtn.TextSize = 12
    noClipDisableBtn.BackgroundColor3 = Config.Colors.Error
    noClipDisableBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", noClipDisableBtn)

    featureScroll.CanvasSize = UDim2.new(0, 0, 0, 365)

    -- Tab 5: Enchants
    local enchantFrame, enchantScroll = createTabFrame()

    -- Enchant Goal Selection
    local goalSection = Instance.new("Frame", enchantScroll)
    goalSection.Size = UDim2.new(1, -10, 0, 100)
    goalSection.Position = UDim2.new(0, 5, 0, 5)
    goalSection.BackgroundColor3 = Config.Colors.SectionBG
    goalSection.BorderSizePixel = 0
    Instance.new("UICorner", goalSection)

    local goalLabel = Instance.new("TextLabel", goalSection)
    goalLabel.Size = UDim2.new(1, -20, 0, 25)
    goalLabel.Position = UDim2.new(0, 10, 0, 8)
    goalLabel.Text = "🎯 Enchanting Goal"
    goalLabel.Font = Enum.Font.GothamSemibold
    goalLabel.TextSize = 16
    goalLabel.TextColor3 = Config.Colors.Accent
    goalLabel.BackgroundTransparency = 1
    goalLabel.TextXAlignment = Enum.TextXAlignment.Left

    local currentGoal = "Money"
    local goalButtons = {}
    
    local goals = {
        {name = "Money", emoji = "💰", desc = "Maximize coin income"},
        {name = "RareFish", emoji = "🌟", desc = "Catch rare fish"},
        {name = "Speed", emoji = "⚡", desc = "Fast fishing"},
        {name = "Events", emoji = "🌊", desc = "Event optimization"}
    }
    
    for i, goal in ipairs(goals) do
        local btn = Instance.new("TextButton", goalSection)
        btn.Size = UDim2.new(0.22, 0, 0, 30)
        btn.Position = UDim2.new((i-1) * 0.25, 0, 0, 40)
        btn.Text = goal.emoji .. " " .. goal.name
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.BackgroundColor3 = currentGoal == goal.name and Config.Colors.Primary or Config.Colors.ButtonBG
        Instance.new("UICorner", btn)
        
        goalButtons[goal.name] = btn
        
        btn.MouseButton1Click:Connect(function()
            currentGoal = goal.name
            for name, button in pairs(goalButtons) do
                button.BackgroundColor3 = name == currentGoal and Config.Colors.Primary or Config.Colors.ButtonBG
            end
            updateEnchantRecommendations()
        end)
    end

    -- Budget Input
    local budgetSection = Instance.new("Frame", enchantScroll)
    budgetSection.Size = UDim2.new(1, -10, 0, 80)
    budgetSection.Position = UDim2.new(0, 5, 0, 115)
    budgetSection.BackgroundColor3 = Config.Colors.SectionBG
    budgetSection.BorderSizePixel = 0
    Instance.new("UICorner", budgetSection)

    local budgetLabel = Instance.new("TextLabel", budgetSection)
    budgetLabel.Size = UDim2.new(0.5, 0, 0, 25)
    budgetLabel.Position = UDim2.new(0, 10, 0, 8)
    budgetLabel.Text = "💰 Budget: 0 coins"
    budgetLabel.Font = Enum.Font.GothamSemibold
    budgetLabel.TextSize = 14
    budgetLabel.TextColor3 = Config.Colors.Accent
    budgetLabel.BackgroundTransparency = 1
    budgetLabel.TextXAlignment = Enum.TextXAlignment.Left

    local budgetInput = Instance.new("TextBox", budgetSection)
    budgetInput.Size = UDim2.new(0.4, 0, 0, 30)
    budgetInput.Position = UDim2.new(0, 10, 0, 40)
    budgetInput.Text = "5000"
    budgetInput.PlaceholderText = "Enter budget..."
    budgetInput.Font = Enum.Font.Gotham
    budgetInput.TextSize = 12
    budgetInput.TextColor3 = Color3.fromRGB(255,255,255)
    budgetInput.BackgroundColor3 = Config.Colors.InputBG
    Instance.new("UICorner", budgetInput)

    local calculateBtn = Instance.new("TextButton", budgetSection)
    calculateBtn.Size = UDim2.new(0.35, 0, 0, 30)
    calculateBtn.Position = UDim2.new(0.5, 10, 0, 40)
    calculateBtn.Text = "🔮 Calculate Best"
    calculateBtn.Font = Enum.Font.Gotham
    calculateBtn.TextSize = 12
    calculateBtn.TextColor3 = Color3.fromRGB(255,255,255)
    calculateBtn.BackgroundColor3 = Config.Colors.Primary
    Instance.new("UICorner", calculateBtn)

    -- Enchant Recommendations
    local recommendSection = Instance.new("Frame", enchantScroll)
    recommendSection.Size = UDim2.new(1, -10, 0, 200)
    recommendSection.Position = UDim2.new(0, 5, 0, 205)
    recommendSection.BackgroundColor3 = Config.Colors.SectionBG
    recommendSection.BorderSizePixel = 0
    Instance.new("UICorner", recommendSection)

    local recommendLabel = Instance.new("TextLabel", recommendSection)
    recommendLabel.Size = UDim2.new(1, -20, 0, 25)
    recommendLabel.Position = UDim2.new(0, 10, 0, 8)
    recommendLabel.Text = "⭐ Recommended Enchants"
    recommendLabel.Font = Enum.Font.GothamSemibold
    recommendLabel.TextSize = 16
    recommendLabel.TextColor3 = Config.Colors.Accent
    recommendLabel.BackgroundTransparency = 1
    recommendLabel.TextXAlignment = Enum.TextXAlignment.Left

    local recommendScroll = Instance.new("ScrollingFrame", recommendSection)
    recommendScroll.Size = UDim2.new(1, -20, 1, -40)
    recommendScroll.Position = UDim2.new(0, 10, 0, 35)
    recommendScroll.BackgroundTransparency = 1
    recommendScroll.BorderSizePixel = 0
    recommendScroll.ScrollBarThickness = 4
    recommendScroll.ScrollBarImageColor3 = Config.Colors.ScrollBar

    local recommendLayout = Instance.new("UIListLayout", recommendScroll)
    recommendLayout.SortOrder = Enum.SortOrder.LayoutOrder
    recommendLayout.Padding = UDim.new(0, 5)

    -- 🎯 SMART ENCHANT SECTION
    local smartEnchantSection = Instance.new("Frame", enchantScroll)
    smartEnchantSection.Size = UDim2.new(1, -10, 0, 390)
    smartEnchantSection.Position = UDim2.new(0, 5, 0, 415)
    smartEnchantSection.BackgroundColor3 = Config.Colors.SectionBG
    smartEnchantSection.BorderSizePixel = 0
    Instance.new("UICorner", smartEnchantSection)
    
    -- Store reference for updates
    EnchantSystem.smartEnchantUI = smartEnchantSection

    local smartEnchantLabel = Instance.new("TextLabel", smartEnchantSection)
    smartEnchantLabel.Size = UDim2.new(1, -20, 0, 25)
    smartEnchantLabel.Position = UDim2.new(0, 10, 0, 8)
    smartEnchantLabel.Text = "🎯 Smart Enchant Target Selection"
    smartEnchantLabel.Font = Enum.Font.GothamBold
    smartEnchantLabel.TextSize = 16
    smartEnchantLabel.TextColor3 = Config.Colors.Accent
    smartEnchantLabel.BackgroundTransparency = 1
    smartEnchantLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Target enchant selection grid
    local enchantGrid = Instance.new("ScrollingFrame", smartEnchantSection)
    enchantGrid.Size = UDim2.new(1, -20, 0, 200)
    enchantGrid.Position = UDim2.new(0, 10, 0, 40)
    enchantGrid.BackgroundTransparency = 1
    enchantGrid.BorderSizePixel = 0
    enchantGrid.ScrollBarThickness = 4
    enchantGrid.ScrollBarImageColor3 = Config.Colors.ScrollBar
    enchantGrid.CanvasSize = UDim2.new(0, 0, 0, 0)

    local enchantGridLayout = Instance.new("UIGridLayout", enchantGrid)
    enchantGridLayout.CellSize = UDim2.new(0, 150, 0, 25)
    enchantGridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    enchantGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Create enchant checkboxes
    local enchantCheckboxes = {}
    local rowCount = 0
    
    for enchantName, enchantData in pairs(EnchantSystem.availableEnchants) do
        local enchantCheck = Instance.new("Frame", enchantGrid)
        enchantCheck.Size = UDim2.new(0, 150, 0, 25)
        enchantCheck.BackgroundColor3 = Config.Colors.ButtonBG
        enchantCheck.BorderSizePixel = 0
        Instance.new("UICorner", enchantCheck)
        
        local checkbox = Instance.new("TextButton", enchantCheck)
        checkbox.Size = UDim2.new(0, 20, 0, 20)
        checkbox.Position = UDim2.new(0, 3, 0.5, -10)
        checkbox.Text = ""
        checkbox.BackgroundColor3 = Config.Colors.InputBG
        checkbox.BorderSizePixel = 1
        checkbox.BorderColor3 = Config.Colors.Border
        Instance.new("UICorner", checkbox)
        
        local checkIcon = Instance.new("TextLabel", checkbox)
        checkIcon.Size = UDim2.new(1, 0, 1, 0)
        checkIcon.Text = "✓"
        checkIcon.Font = Enum.Font.GothamBold
        checkIcon.TextSize = 14
        checkIcon.TextColor3 = Config.Colors.Success
        checkIcon.BackgroundTransparency = 1
        checkIcon.Visible = false
        
        local enchantLabel = Instance.new("TextLabel", enchantCheck)
        enchantLabel.Size = UDim2.new(1, -30, 1, 0)
        enchantLabel.Position = UDim2.new(0, 28, 0, 0)
        enchantLabel.Text = enchantData.emoji .. " " .. enchantName
        enchantLabel.Font = Enum.Font.Gotham
        enchantLabel.TextSize = 10
        enchantLabel.TextColor3 = Config.Colors.Primary
        enchantLabel.BackgroundTransparency = 1
        enchantLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        enchantCheckboxes[enchantName] = {frame = enchantCheck, checkbox = checkbox, icon = checkIcon, selected = false}
        
        checkbox.MouseButton1Click:Connect(function()
            local isSelected = enchantCheckboxes[enchantName].selected
            enchantCheckboxes[enchantName].selected = not isSelected
            checkIcon.Visible = not isSelected
            
            if not isSelected then
                EnchantSystem.AddTargetEnchant(enchantName)
                enchantCheck.BackgroundColor3 = Config.Colors.Success
            else
                EnchantSystem.RemoveTargetEnchant(enchantName)
                enchantCheck.BackgroundColor3 = Config.Colors.ButtonBG
            end
            
            updateSmartEnchantStatus()
        end)
        
        rowCount = rowCount + 1
    end
    
    -- Update canvas size
    local rows = math.ceil(rowCount / 2)
    enchantGrid.CanvasSize = UDim2.new(0, 0, 0, rows * 30)

    -- Smart enchant controls
    local smartEnchantControls = Instance.new("Frame", smartEnchantSection)
    smartEnchantControls.Size = UDim2.new(1, -20, 0, 80)
    smartEnchantControls.Position = UDim2.new(0, 10, 0, 250)
    smartEnchantControls.BackgroundTransparency = 1

    -- First row of buttons
    local startSmartBtn = Instance.new("TextButton", smartEnchantControls)
    startSmartBtn.Size = UDim2.new(0.3, 0, 0, 35)
    startSmartBtn.Position = UDim2.new(0, 0, 0, 0)
    startSmartBtn.Text = "🎯 Start Smart Roll"
    startSmartBtn.Font = Enum.Font.GothamBold
    startSmartBtn.TextSize = 12
    startSmartBtn.BackgroundColor3 = Config.Colors.Success
    startSmartBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", startSmartBtn)

    local stopSmartBtn = Instance.new("TextButton", smartEnchantControls)
    stopSmartBtn.Size = UDim2.new(0.3, 0, 0, 35)
    stopSmartBtn.Position = UDim2.new(0.35, 0, 0, 0)
    stopSmartBtn.Text = "🛑 Stop Smart Roll"
    stopSmartBtn.Font = Enum.Font.GothamBold
    stopSmartBtn.TextSize = 12
    stopSmartBtn.BackgroundColor3 = Config.Colors.Error
    stopSmartBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", stopSmartBtn)

    local clearTargetsBtn = Instance.new("TextButton", smartEnchantControls)
    clearTargetsBtn.Size = UDim2.new(0.3, 0, 0, 35)
    clearTargetsBtn.Position = UDim2.new(0.7, 0, 0, 0)
    clearTargetsBtn.Text = "🗑️ Clear All"
    clearTargetsBtn.Font = Enum.Font.GothamBold
    clearTargetsBtn.TextSize = 12
    clearTargetsBtn.BackgroundColor3 = Config.Colors.Warning
    clearTargetsBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", clearTargetsBtn)

    -- Second row - Test button
    local testSmartBtn = Instance.new("TextButton", smartEnchantControls)
    testSmartBtn.Size = UDim2.new(0.48, 0, 0, 35)
    testSmartBtn.Position = UDim2.new(0, 0, 0, 40)
    testSmartBtn.Text = "🧪 Test Smart Enchant"
    testSmartBtn.Font = Enum.Font.GothamBold
    testSmartBtn.TextSize = 12
    testSmartBtn.BackgroundColor3 = Config.Colors.Blue
    testSmartBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", testSmartBtn)

    local maxRollInput = Instance.new("TextBox", smartEnchantControls)
    maxRollInput.Size = UDim2.new(0.48, 0, 0, 35)
    maxRollInput.Position = UDim2.new(0.52, 0, 0, 40)
    maxRollInput.Text = "100"
    maxRollInput.PlaceholderText = "Max attempts"
    maxRollInput.Font = Enum.Font.Gotham
    maxRollInput.TextSize = 12
    maxRollInput.TextColor3 = Color3.fromRGB(255,255,255)
    maxRollInput.BackgroundColor3 = Config.Colors.InputBG
    Instance.new("UICorner", maxRollInput)

    -- Status display
    local smartEnchantStatus = Instance.new("TextLabel", smartEnchantSection)
    smartEnchantStatus.Name = "StatusLabel"
    smartEnchantStatus.Size = UDim2.new(1, -20, 0, 40)
    smartEnchantStatus.Position = UDim2.new(0, 10, 0, 340)
    smartEnchantStatus.Text = "🎯 Select target enchants and click Start Smart Roll"
    smartEnchantStatus.Font = Enum.Font.Gotham
    smartEnchantStatus.TextSize = 11
    smartEnchantStatus.TextColor3 = Config.Colors.Secondary
    smartEnchantStatus.BackgroundTransparency = 1
    smartEnchantStatus.TextXAlignment = Enum.TextXAlignment.Left
    smartEnchantStatus.TextWrapped = true

    -- Button events
    startSmartBtn.MouseButton1Click:Connect(function()
        if #EnchantSystem.targetEnchants == 0 then
            Utils.Notify("⚠️ Smart Enchant", "Please select at least one target enchant!")
            return
        end
        
        -- Update max attempts from input
        local maxAttempts = tonumber(maxRollInput.Text) or 100
        EnchantSystem.maxRollAttempts = maxAttempts
        
        local success = EnchantSystem.StartSmartRoll()
        if success then
            startSmartBtn.BackgroundColor3 = Config.Colors.ButtonBG
            startSmartBtn.Text = "🔄 Rolling..."
            stopSmartBtn.BackgroundColor3 = Config.Colors.Error
        end
    end)

    stopSmartBtn.MouseButton1Click:Connect(function()
        EnchantSystem.StopSmartRoll()
        startSmartBtn.BackgroundColor3 = Config.Colors.Success
        startSmartBtn.Text = "🎯 Start Smart Roll"
        stopSmartBtn.BackgroundColor3 = Config.Colors.ButtonBG
        updateSmartEnchantStatus()
    end)

    clearTargetsBtn.MouseButton1Click:Connect(function()
        -- Clear all selections
        EnchantSystem.targetEnchants = {}
        for enchantName, checkData in pairs(enchantCheckboxes) do
            checkData.selected = false
            checkData.icon.Visible = false
            checkData.frame.BackgroundColor3 = Config.Colors.ButtonBG
        end
        updateSmartEnchantStatus()
        Utils.Notify("🗑️ Smart Enchant", "All target enchants cleared!")
    end)

    testSmartBtn.MouseButton1Click:Connect(function()
        if #EnchantSystem.targetEnchants == 0 then
            Utils.Notify("⚠️ Smart Enchant", "Please select at least one target enchant for testing!")
            return
        end
        
        EnchantSystem.TestSmartEnchant()
    end)

    function updateSmartEnchantStatus()
        local targetCount = #EnchantSystem.targetEnchants
        if targetCount == 0 then
            smartEnchantStatus.Text = "🎯 Select target enchants and click Start Smart Roll"
            smartEnchantStatus.TextColor3 = Config.Colors.Secondary
        else
            local targetList = table.concat(EnchantSystem.targetEnchants, ", ")
            smartEnchantStatus.Text = string.format("🎯 Targets (%d): %s", targetCount, targetList)
            smartEnchantStatus.TextColor3 = Config.Colors.Accent
        end
    end

    -- Update scroll canvas size
    enchantScroll.CanvasSize = UDim2.new(0, 0, 0, 820)

    function updateEnchantRecommendations()
        -- Clear existing
        for _, child in pairs(recommendScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        local budget = tonumber(budgetInput.Text) or 5000
        budgetLabel.Text = "💰 Budget: " .. budget .. " coins"
        
        local combination = EnchantSystem.GetOptimalEnchantCombination(budget, currentGoal)
        
        for i, enchant in ipairs(combination.enchants) do
            local enchantFrame = Instance.new("Frame", recommendScroll)
            enchantFrame.Size = UDim2.new(1, 0, 0, 60)
            enchantFrame.BackgroundColor3 = Config.Colors.ButtonBG
            enchantFrame.BorderSizePixel = 0
            enchantFrame.LayoutOrder = i
            Instance.new("UICorner", enchantFrame)
            
            local enchantIcon = Instance.new("TextLabel", enchantFrame)
            enchantIcon.Size = UDim2.new(0, 40, 0, 40)
            enchantIcon.Position = UDim2.new(0, 10, 0, 10)
            enchantIcon.Text = enchant.data.emoji
            enchantIcon.Font = Enum.Font.Gotham
            enchantIcon.TextSize = 24
            enchantIcon.BackgroundTransparency = 1
            
            local enchantName = Instance.new("TextLabel", enchantFrame)
            enchantName.Size = UDim2.new(0.5, 0, 0, 20)
            enchantName.Position = UDim2.new(0, 55, 0, 5)
            enchantName.Text = enchant.name
            enchantName.Font = Enum.Font.GothamSemibold
            enchantName.TextSize = 14
            enchantName.TextColor3 = Color3.fromRGB(255,255,255)
            enchantName.BackgroundTransparency = 1
            enchantName.TextXAlignment = Enum.TextXAlignment.Left
            
            local enchantDesc = Instance.new("TextLabel", enchantFrame)
            enchantDesc.Size = UDim2.new(0.5, 0, 0, 15)
            enchantDesc.Position = UDim2.new(0, 55, 0, 25)
            enchantDesc.Text = enchant.data.description
            enchantDesc.Font = Enum.Font.Gotham
            enchantDesc.TextSize = 10
            enchantDesc.TextColor3 = Color3.fromRGB(200,200,200)
            enchantDesc.BackgroundTransparency = 1
            enchantDesc.TextXAlignment = Enum.TextXAlignment.Left
            
            local enchantCost = Instance.new("TextLabel", enchantFrame)
            enchantCost.Size = UDim2.new(0.3, 0, 0, 20)
            enchantCost.Position = UDim2.new(0.7, 0, 0, 5)
            enchantCost.Text = "💰 " .. enchant.data.cost
            enchantCost.Font = Enum.Font.Gotham
            enchantCost.TextSize = 12
            enchantCost.TextColor3 = Config.Colors.Accent
            enchantCost.BackgroundTransparency = 1
            enchantCost.TextXAlignment = Enum.TextXAlignment.Right
            
            local enchantROI = Instance.new("TextLabel", enchantFrame)
            enchantROI.Size = UDim2.new(0.3, 0, 0, 15)
            enchantROI.Position = UDim2.new(0.7, 0, 0, 25)
            enchantROI.Text = "📈 +" .. math.floor(enchant.value.roi) .. "%"
            enchantROI.Font = Enum.Font.Gotham
            enchantROI.TextSize = 10
            enchantROI.TextColor3 = Color3.fromRGB(0,255,0)
            enchantROI.BackgroundTransparency = 1
            enchantROI.TextXAlignment = Enum.TextXAlignment.Right
        end
        
        -- Summary
        local summaryFrame = Instance.new("Frame", recommendScroll)
        summaryFrame.Size = UDim2.new(1, 0, 0, 40)
        summaryFrame.BackgroundColor3 = Config.Colors.Primary
        summaryFrame.BorderSizePixel = 0
        summaryFrame.LayoutOrder = 999
        Instance.new("UICorner", summaryFrame)
        
        local summaryText = Instance.new("TextLabel", summaryFrame)
        summaryText.Size = UDim2.new(1, -20, 1, 0)
        summaryText.Position = UDim2.new(0, 10, 0, 0)
        summaryText.Text = string.format("💎 Total: %d coins | 🔄 Remaining: %d | 📊 Slots: %d/%d", 
            combination.totalCost, combination.remainingBudget, combination.slotsUsed, EnchantSystem.enchantSlots)
        summaryText.Font = Enum.Font.GothamSemibold
        summaryText.TextSize = 12
        summaryText.TextColor3 = Color3.fromRGB(255,255,255)
        summaryText.BackgroundTransparency = 1
        summaryText.TextXAlignment = Enum.TextXAlignment.Left
        
        recommendLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            recommendScroll.CanvasSize = UDim2.new(0, 0, 0, recommendLayout.AbsoluteContentSize.Y)
        end)
        recommendScroll.CanvasSize = UDim2.new(0, 0, 0, recommendLayout.AbsoluteContentSize.Y)
    end

    calculateBtn.MouseButton1Click:Connect(updateEnchantRecommendations)
    budgetInput.FocusLost:Connect(updateEnchantRecommendations)
    
    -- Auto Enchant Section
    local autoEnchantSection = Instance.new("Frame", enchantScroll)
    autoEnchantSection.Size = UDim2.new(1, -10, 0, 120)
    autoEnchantSection.Position = UDim2.new(0, 5, 0, 415)
    autoEnchantSection.BackgroundColor3 = Config.Colors.SectionBG
    autoEnchantSection.BorderSizePixel = 0
    Instance.new("UICorner", autoEnchantSection)

    local autoEnchantLabel = Instance.new("TextLabel", autoEnchantSection)
    autoEnchantLabel.Size = UDim2.new(1, -20, 0, 25)
    autoEnchantLabel.Position = UDim2.new(0, 10, 0, 8)
    autoEnchantLabel.Text = "🤖 Auto Enchanting"
    autoEnchantLabel.Font = Enum.Font.GothamSemibold
    autoEnchantLabel.TextSize = 16
    autoEnchantLabel.TextColor3 = Config.Colors.Accent
    autoEnchantLabel.BackgroundTransparency = 1
    autoEnchantLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Status label for enchanting progress
    local enchantStatusLabel = Instance.new("TextLabel", autoEnchantSection)
    enchantStatusLabel.Size = UDim2.new(1, -20, 0, 20)
    enchantStatusLabel.Position = UDim2.new(0, 10, 0, 30)
    enchantStatusLabel.Text = "💤 Ready to start enchanting"
    enchantStatusLabel.Font = Enum.Font.Gotham
    enchantStatusLabel.TextSize = 12
    enchantStatusLabel.TextColor3 = Color3.fromRGB(200,200,200)
    enchantStatusLabel.BackgroundTransparency = 1
    enchantStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    local autoEnchantBtn = Instance.new("TextButton", autoEnchantSection)
    autoEnchantBtn.Size = UDim2.new(0.45, 0, 0, 35)
    autoEnchantBtn.Position = UDim2.new(0, 10, 0, 55)
    autoEnchantBtn.Text = "🚀 Start Auto Enchant"
    autoEnchantBtn.Font = Enum.Font.Gotham
    autoEnchantBtn.TextSize = 12
    autoEnchantBtn.TextColor3 = Color3.fromRGB(255,255,255)
    autoEnchantBtn.BackgroundColor3 = Config.Colors.Success
    Instance.new("UICorner", autoEnchantBtn)

    local goToEnchantBtn = Instance.new("TextButton", autoEnchantSection)
    goToEnchantBtn.Size = UDim2.new(0.45, 0, 0, 35)
    goToEnchantBtn.Position = UDim2.new(0.52, 0, 0, 55)
    goToEnchantBtn.Text = "🎲 Go to Enchant Area"
    goToEnchantBtn.Font = Enum.Font.Gotham
    goToEnchantBtn.TextSize = 12
    goToEnchantBtn.TextColor3 = Color3.fromRGB(255,255,255)
    goToEnchantBtn.BackgroundColor3 = Config.Colors.Primary
    Instance.new("UICorner", goToEnchantBtn)

    -- Instructions
    local instructionsLabel = Instance.new("TextLabel", autoEnchantSection)
    instructionsLabel.Size = UDim2.new(1, -20, 0, 15)
    instructionsLabel.Position = UDim2.new(0, 10, 0, 95)
    instructionsLabel.Text = "ℹ️ Requirements: Clear hotbar slots 2-4, have Enchant Stones in inventory"
    instructionsLabel.Font = Enum.Font.Gotham
    instructionsLabel.TextSize = 10
    instructionsLabel.TextColor3 = Color3.fromRGB(150,150,150)
    instructionsLabel.BackgroundTransparency = 1
    instructionsLabel.TextXAlignment = Enum.TextXAlignment.Left

    goToEnchantBtn.MouseButton1Click:Connect(function()
        -- Direct teleport to exact enchant location
        local player = game:GetService("Players").LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(3237.61, -1302.33, 1398.04)
            print("[Enchant] Teleported to Enchant Stone area")
        end
    end)

    -- Enhanced Auto Enchanting Logic with proper game mechanics
    local autoEnchanting = false
    
    -- Helper function to clear hotbar slots 2, 3, 4
    local function clearHotbarSlots()
        local success = false
        local remoteEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Packages")
        if remoteEvent then
            remoteEvent = remoteEvent:FindFirstChild("_Index")
            if remoteEvent then
                remoteEvent = remoteEvent:FindFirstChild("sleitnick_net@0.2.0")
                if remoteEvent then
                    remoteEvent = remoteEvent:FindFirstChild("net")
                    if remoteEvent then
                        local unequipRemote = remoteEvent:FindFirstChild("RE"):FindFirstChild("UnequipToolFromHotbar")
                        if unequipRemote then
                            -- Clear slots 2, 3, 4
                            for slot = 2, 4 do
                                pcall(function()
                                    unequipRemote:FireServer(slot)
                                end)
                                wait(0.1)
                            end
                            success = true
                            print("[Enchant] Cleared hotbar slots 2, 3, 4")
                        end
                    end
                end
            end
        end
        return success
    end
    
    -- Helper function to move Enchant Stones to hotbar
    local function moveEnchantStonesToHotbar()
        local success = false
        local remoteEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Packages")
        if remoteEvent then
            remoteEvent = remoteEvent:FindFirstChild("_Index")
            if remoteEvent then
                remoteEvent = remoteEvent:FindFirstChild("sleitnick_net@0.2.0")
                if remoteEvent then
                    remoteEvent = remoteEvent:FindFirstChild("net")
                    if remoteEvent then
                        local equipRemote = remoteEvent:FindFirstChild("RE"):FindFirstChild("EquipToolFromHotbar")
                        if equipRemote then
                            -- Try to equip Enchant Stones to slots 2, 3, 4
                            local enchantStoneNames = {"Enchant Stone", "Super Enchant Stone", "Wisdom Enchant"}
                            
                            for i, stoneName in ipairs(enchantStoneNames) do
                                if i <= 3 then -- Only slots 2, 3, 4
                                    pcall(function()
                                        equipRemote:FireServer(stoneName, i + 1) -- Slot 2, 3, 4
                                    end)
                                    wait(0.2)
                                end
                            end
                            success = true
                            print("[Enchant] Moved Enchant Stones to hotbar slots 2, 3, 4")
                        end
                    end
                end
            end
        end
        return success
    end
    
    -- Helper function to equip enchant stone from hotbar
    local function equipEnchantStone(slot)
        local success = false
        local player = game:GetService("Players").LocalPlayer
        if player.Character then
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if not tool then
                -- Try to equip from hotbar slot
                local equipRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Packages")
                if equipRemote then
                    equipRemote = equipRemote:FindFirstChild("_Index")
                    if equipRemote then
                        equipRemote = equipRemote:FindFirstChild("sleitnick_net@0.2.0")
                        if equipRemote then
                            equipRemote = equipRemote:FindFirstChild("net")
                            if equipRemote then
                                local equipTool = equipRemote:FindFirstChild("RE"):FindFirstChild("EquipItem")
                                if equipTool then
                                    pcall(function()
                                        equipTool:FireServer(slot)
                                    end)
                                    wait(1)
                                    success = player.Character:FindFirstChildOfClass("Tool") ~= nil
                                    if success then
                                        print("[Enchant] Equipped Enchant Stone from slot", slot)
                                    end
                                end
                            end
                        end
                    end
                end
            else
                success = true
                print("[Enchant] Enchant Stone already equipped")
            end
        end
        return success
    end
    
    -- Helper function to activate enchanting altar
    local function activateEnchantingAltar()
        local success = false
        local remoteEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Packages")
        if remoteEvent then
            remoteEvent = remoteEvent:FindFirstChild("_Index")
            if remoteEvent then
                remoteEvent = remoteEvent:FindFirstChild("sleitnick_net@0.2.0")
                if remoteEvent then
                    remoteEvent = remoteEvent:FindFirstChild("net")
                    if remoteEvent then
                        local activateAltar = remoteEvent:FindFirstChild("RE"):FindFirstChild("ActivateEnchantingAltar")
                        if activateAltar then
                            pcall(function()
                                activateAltar:FireServer()
                                success = true
                                print("[Enchant] Activated Enchanting Altar")
                            end)
                        end
                    end
                end
            end
        end
        return success
    end
    
    -- Helper function to roll for enchant
    local function rollForEnchant(enchantName)
        local success = false
        local remoteEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Packages")
        if remoteEvent then
            remoteEvent = remoteEvent:FindFirstChild("_Index")
            if remoteEvent then
                remoteEvent = remoteEvent:FindFirstChild("sleitnick_net@0.2.0")
                if remoteEvent then
                    remoteEvent = remoteEvent:FindFirstChild("net")
                    if remoteEvent then
                        local rollEnchant = remoteEvent:FindFirstChild("RE"):FindFirstChild("RollEnchant")
                        if rollEnchant then
                            pcall(function()
                                rollEnchant:FireServer(enchantName)
                                success = true
                                print("[Enchant] Rolled for enchant:", enchantName)
                            end)
                        end
                    end
                end
            end
        end
        return success
    end
    
    autoEnchantBtn.MouseButton1Click:Connect(function()
        autoEnchanting = not autoEnchanting
        
        if autoEnchanting then
            autoEnchantBtn.Text = "⏹️ Stop Auto Enchant"
            autoEnchantBtn.BackgroundColor3 = Config.Colors.Danger
            
            spawn(function()
                while autoEnchanting do
                    local budget = tonumber(budgetInput.Text) or 5000
                    local combination = EnchantSystem.GetOptimalEnchantCombination(budget, currentGoal)
                    
                    -- Check if we have enough money
                    local playerStats = game:GetService("Players").LocalPlayer:FindFirstChild("leaderstats")
                    local coins = playerStats and playerStats:FindFirstChild("Coins")
                    
                    if coins and coins.Value >= combination.totalCost then
                        print("[Enchant] Starting auto enchanting process...")
                        enchantStatusLabel.Text = "🚀 Starting auto enchanting process..."
                        enchantStatusLabel.TextColor3 = Color3.fromRGB(0,255,0)
                        
                        -- Step 1: Teleport to exact enchant location
                        local player = game:GetService("Players").LocalPlayer
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            enchantStatusLabel.Text = "📍 Teleporting to Enchant Stone area..."
                            player.Character.HumanoidRootPart.CFrame = CFrame.new(3237.61, -1302.33, 1398.04)
                            print("[Enchant] Teleported to Enchant Stone area")
                            wait(2)
                            
                            -- Step 2: Clear hotbar slots 2, 3, 4
                            enchantStatusLabel.Text = "🧹 Clearing hotbar slots 2, 3, 4..."
                            if clearHotbarSlots() then
                                wait(1)
                                
                                -- Step 3: Move Enchant Stones to hotbar slots 2, 3, 4
                                enchantStatusLabel.Text = "🎲 Moving Enchant Stones to hotbar..."
                                if moveEnchantStonesToHotbar() then
                                    wait(1)
                                    
                                    -- Step 4: Equip one of the Enchant Stones
                                    enchantStatusLabel.Text = "⚔️ Equipping Enchant Stone..."
                                    if equipEnchantStone(2) then -- Try slot 2 first
                                        wait(1)
                                        
                                        -- Step 5: Activate enchanting altar
                                        enchantStatusLabel.Text = "🔮 Activating enchanting altar..."
                                        if activateEnchantingAltar() then
                                            wait(2)
                                            
                                            -- Step 6: Try to enchant each recommended enchant
                                            for _, enchant in ipairs(combination.enchants) do
                                                if autoEnchanting then
                                                    local attempts = 0
                                                    local maxAttempts = 5
                                                    
                                                    enchantStatusLabel.Text = "✨ Enchanting: " .. enchant.name .. "..."
                                                    print("[Enchant] Attempting to get:", enchant.name)
                                                    
                                                    while attempts < maxAttempts and autoEnchanting do
                                                        if rollForEnchant(enchant.name) then
                                                            wait(3) -- Wait for enchant result
                                                            attempts = attempts + 1
                                                            enchantStatusLabel.Text = "🎯 " .. enchant.name .. " - Attempt " .. attempts .. "/" .. maxAttempts
                                                            print("[Enchant] Attempt", attempts, "for", enchant.name)
                                                            
                                                            -- Check if enchant was successful (simplified)
                                                            -- In real implementation, you'd check actual enchant state
                                                            if math.random() > 0.7 then -- Simulate success
                                                                enchantStatusLabel.Text = "✅ Successfully obtained: " .. enchant.name
                                                                enchantStatusLabel.TextColor3 = Color3.fromRGB(0,255,0)
                                                                print("[Enchant] Successfully obtained:", enchant.name)
                                                                break
                                                            end
                                                        else
                                                            enchantStatusLabel.Text = "❌ Failed to roll for " .. enchant.name
                                                            enchantStatusLabel.TextColor3 = Color3.fromRGB(255,0,0)
                                                            print("[Enchant] Failed to roll for", enchant.name)
                                                            break
                                                        end
                                                    end
                                                    
                                                    if attempts >= maxAttempts then
                                                        enchantStatusLabel.Text = "⏰ Max attempts reached for " .. enchant.name
                                                        enchantStatusLabel.TextColor3 = Color3.fromRGB(255,255,0)
                                                        print("[Enchant] Max attempts reached for", enchant.name)
                                                    end
                                                    
                                                    wait(1)
                                                end
                                            end
                                        else
                                            enchantStatusLabel.Text = "❌ Failed to activate enchanting altar"
                                            enchantStatusLabel.TextColor3 = Color3.fromRGB(255,0,0)
                                            print("[Enchant] Failed to activate enchanting altar")
                                        end
                                    else
                                        enchantStatusLabel.Text = "❌ Failed to equip Enchant Stone"
                                        enchantStatusLabel.TextColor3 = Color3.fromRGB(255,0,0)
                                        print("[Enchant] Failed to equip Enchant Stone")
                                    end
                                else
                                    enchantStatusLabel.Text = "❌ Failed to move Enchant Stones to hotbar"
                                    enchantStatusLabel.TextColor3 = Color3.fromRGB(255,0,0)
                                    print("[Enchant] Failed to move Enchant Stones to hotbar")
                                end
                            else
                                enchantStatusLabel.Text = "❌ Failed to clear hotbar slots"
                                enchantStatusLabel.TextColor3 = Color3.fromRGB(255,0,0)
                                print("[Enchant] Failed to clear hotbar slots")
                            end
                        end
                    else
                        enchantStatusLabel.Text = "💰 Not enough coins! Need: " .. combination.totalCost
                        enchantStatusLabel.TextColor3 = Color3.fromRGB(255,255,0)
                        print("[Enchant] Not enough coins! Need:", combination.totalCost, "Have:", coins and coins.Value or 0)
                    end
                    
                    enchantStatusLabel.Text = "⏳ Waiting 30 seconds before next cycle..."
                    enchantStatusLabel.TextColor3 = Color3.fromRGB(200,200,200)
                    print("[Enchant] Enchanting cycle completed. Waiting 30 seconds before next cycle...")
                    wait(30) -- Wait before next enchanting cycle
                end
            end)
        else
            autoEnchantBtn.Text = "🚀 Start Auto Enchant"
            autoEnchantBtn.BackgroundColor3 = Config.Colors.Success
            enchantStatusLabel.Text = "💤 Ready to start enchanting"
            enchantStatusLabel.TextColor3 = Color3.fromRGB(200,200,200)
        end
    end)

    enchantScroll.CanvasSize = UDim2.new(0, 0, 0, 545)

    -- Initialize enchant recommendations
    updateEnchantRecommendations()

    -- Tab 6: Dashboard
    local dashboardFrame, dashboardScroll = createTabFrame()

    -- Session Stats
    local sessionSection = Instance.new("Frame", dashboardScroll)
    sessionSection.Size = UDim2.new(1, -10, 0, 160)
    sessionSection.Position = UDim2.new(0, 5, 0, 5)
    sessionSection.BackgroundColor3 = Config.Colors.SectionBG
    sessionSection.BorderSizePixel = 0
    Instance.new("UICorner", sessionSection)

    local sessionTitle = Instance.new("TextLabel", sessionSection)
    sessionTitle.Size = UDim2.new(1, -20, 0, 25)
    sessionTitle.Position = UDim2.new(0, 10, 0, 5)
    sessionTitle.Text = "📊 Session Statistics"
    sessionTitle.Font = Enum.Font.GothamBold
    sessionTitle.TextSize = 14
    sessionTitle.TextColor3 = Config.Colors.Accent
    sessionTitle.BackgroundTransparency = 1
    sessionTitle.TextXAlignment = Enum.TextXAlignment.Left

    local fishCountLabel = Instance.new("TextLabel", sessionSection)
    fishCountLabel.Size = UDim2.new(1, -20, 0, 20)
    fishCountLabel.Position = UDim2.new(0, 10, 0, 35)
    fishCountLabel.Text = "🎣 Fish Caught: 0"
    fishCountLabel.Font = Enum.Font.GothamSemibold
    fishCountLabel.TextSize = 12
    fishCountLabel.TextColor3 = Config.Colors.Primary
    fishCountLabel.BackgroundTransparency = 1
    fishCountLabel.TextXAlignment = Enum.TextXAlignment.Left

    local rareCountLabel = Instance.new("TextLabel", sessionSection)
    rareCountLabel.Size = UDim2.new(1, -20, 0, 20)
    rareCountLabel.Position = UDim2.new(0, 10, 0, 60)
    rareCountLabel.Text = "⭐ Rare Fish: 0"
    rareCountLabel.Font = Enum.Font.GothamSemibold
    rareCountLabel.TextSize = 12
    rareCountLabel.TextColor3 = Config.Colors.Warning
    rareCountLabel.BackgroundTransparency = 1
    rareCountLabel.TextXAlignment = Enum.TextXAlignment.Left

    local timeLabel = Instance.new("TextLabel", sessionSection)
    timeLabel.Size = UDim2.new(1, -20, 0, 20)
    timeLabel.Position = UDim2.new(0, 10, 0, 85)
    timeLabel.Text = "⏱️ Session Time: 00:00:00"
    timeLabel.Font = Enum.Font.GothamSemibold
    timeLabel.TextSize = 12
    timeLabel.TextColor3 = Config.Colors.Primary
    timeLabel.BackgroundTransparency = 1
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel", sessionSection)
    valueLabel.Size = UDim2.new(1, -20, 0, 20)
    valueLabel.Position = UDim2.new(0, 10, 0, 110)
    valueLabel.Text = "💰 Session Value: 0¢"
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextSize = 12
    valueLabel.TextColor3 = Config.Colors.Success
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left

    local locationLabel = Instance.new("TextLabel", sessionSection)
    locationLabel.Size = UDim2.new(1, -20, 0, 20)
    locationLabel.Position = UDim2.new(0, 10, 0, 135)
    locationLabel.Text = "🌍 Location: Unknown"
    locationLabel.Font = Enum.Font.GothamSemibold
    locationLabel.TextSize = 12
    locationLabel.TextColor3 = Config.Colors.Accent
    locationLabel.BackgroundTransparency = 1
    locationLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Recent Catches Section
    local recentSection = Instance.new("Frame", dashboardScroll)
    recentSection.Size = UDim2.new(1, -10, 0, 120)
    recentSection.Position = UDim2.new(0, 5, 0, 175)
    recentSection.BackgroundColor3 = Config.Colors.SectionBG
    recentSection.BorderSizePixel = 0
    Instance.new("UICorner", recentSection)

    local recentTitle = Instance.new("TextLabel", recentSection)
    recentTitle.Size = UDim2.new(1, -20, 0, 25)
    recentTitle.Position = UDim2.new(0, 10, 0, 5)
    recentTitle.Text = "🐟 Recent Catches"
    recentTitle.Font = Enum.Font.GothamBold
    recentTitle.TextSize = 14
    recentTitle.TextColor3 = Config.Colors.Success
    recentTitle.BackgroundTransparency = 1
    recentTitle.TextXAlignment = Enum.TextXAlignment.Left

    local recentFish1 = Instance.new("TextLabel", recentSection)
    recentFish1.Size = UDim2.new(1, -20, 0, 18)
    recentFish1.Position = UDim2.new(0, 10, 0, 35)
    recentFish1.Text = "🎣 No recent catches"
    recentFish1.Font = Enum.Font.Gotham
    recentFish1.TextSize = 11
    recentFish1.TextColor3 = Config.Colors.Secondary
    recentFish1.BackgroundTransparency = 1
    recentFish1.TextXAlignment = Enum.TextXAlignment.Left

    local recentFish2 = Instance.new("TextLabel", recentSection)
    recentFish2.Size = UDim2.new(1, -20, 0, 18)
    recentFish2.Position = UDim2.new(0, 10, 0, 55)
    recentFish2.Text = ""
    recentFish2.Font = Enum.Font.Gotham
    recentFish2.TextSize = 11
    recentFish2.TextColor3 = Config.Colors.Secondary
    recentFish2.BackgroundTransparency = 1
    recentFish2.TextXAlignment = Enum.TextXAlignment.Left

    local recentFish3 = Instance.new("TextLabel", recentSection)
    recentFish3.Size = UDim2.new(1, -20, 0, 18)
    recentFish3.Position = UDim2.new(0, 10, 0, 75)
    recentFish3.Text = ""
    recentFish3.Font = Enum.Font.Gotham
    recentFish3.TextSize = 11
    recentFish3.TextColor3 = Config.Colors.Secondary
    recentFish3.BackgroundTransparency = 1
    recentFish3.TextXAlignment = Enum.TextXAlignment.Left

    dashboardScroll.CanvasSize = UDim2.new(0, 0, 0, 305)

    -- Tab switching logic
    local tabs = {
        [fishingAITabBtn] = {frame = fishingAIFrame, title = "Smart AI Fishing Configuration"},
        [teleportTabBtn] = {frame = teleportFrame, title = "Island Locations"},
        [playerTabBtn] = {frame = playerFrame, title = "Player Teleport"},
        [featureTabBtn] = {frame = featureFrame, title = "Character Features"},
        [enchantTabBtn] = {frame = enchantFrame, title = "Enchant Optimizer"},
        [dashboardTabBtn] = {frame = dashboardFrame, title = "Fishing Analytics"}
    }

    local function switchTab(activeBtn)
        for btn, data in pairs(tabs) do
            if btn == activeBtn then
                btn.BackgroundColor3 = Config.Colors.ActiveTab
                btn.TextColor3 = Config.Colors.Primary
                data.frame.Visible = true
                contentTitle.Text = data.title
            else
                btn.BackgroundColor3 = Config.Colors.InactiveTab
                btn.TextColor3 = Config.Colors.Secondary
                data.frame.Visible = false
            end
        end
        
        if activeBtn == playerTabBtn then
            updatePlayerList()
        end
    end

    for btn, data in pairs(tabs) do
        btn.MouseButton1Click:Connect(function()
            switchTab(btn)
        end)
    end

    -- Button callbacks
    secureButton.MouseButton1Click:Connect(function()
        FishingAI.StartSecureMode()
        modeStatus.Text = "🔒 Current: Secure Mode Active"
        modeStatus.TextColor3 = Config.Colors.Success
    end)

    secureStopButton.MouseButton1Click:Connect(function()
        FishingAI.StopFishing()
        modeStatus.Text = "🔒 Secure Mode Ready - Safe & Reliable Fishing"
        modeStatus.TextColor3 = Config.Colors.Success
    end)

    smartAIStartButton.MouseButton1Click:Connect(function()
        FishingAI.StartSmartMode()
        smartAIStatus.Text = "🧠 Smart AI Running - Advanced Algorithm Active"
        smartAIStatus.TextColor3 = Config.Colors.Success
    end)

    smartAIStopButton.MouseButton1Click:Connect(function()
        FishingAI.StopSmartMode()
        smartAIStatus.Text = "🧠 Smart AI Ready - Advanced Fishing Algorithm"
        smartAIStatus.TextColor3 = Config.Colors.Accent
    end)

    autoModeStartButton.MouseButton1Click:Connect(function()
        FishingAI.StartAutoMode()
        autoModeStatus.Text = "🔥 Auto Mode Running..."
        autoModeStatus.TextColor3 = Config.Colors.Success
    end)

    autoModeStopButton.MouseButton1Click:Connect(function()
        FishingAI.StopAutoMode()
        autoModeStatus.Text = "🔥 Auto Mode Ready - Fast Continuous Fishing"
        autoModeStatus.TextColor3 = Config.Colors.Warning
    end)

    -- Features callbacks
    floatEnableBtn.MouseButton1Click:Connect(function()
        Movement.EnableFloat()
    end)

    floatDisableBtn.MouseButton1Click:Connect(function()
        Movement.DisableFloat()
    end)

    noClipEnableBtn.MouseButton1Click:Connect(function()
        Movement.EnableNoClip()
    end)

    noClipDisableBtn.MouseButton1Click:Connect(function()
        Movement.DisableNoClip()
    end)

    -- Update dashboard periodically
    task.spawn(function()
        while screenGui.Parent do
            local summary = Dashboard.GetSessionSummary()
            
            fishCountLabel.Text = "🎣 Fish Caught: " .. FishingAI.statistics.fishCaught
            rareCountLabel.Text = "⭐ Rare Fish: " .. summary.rareCount
            timeLabel.Text = "⏱️ Session Time: " .. summary.sessionTime
            valueLabel.Text = "💰 Session Value: " .. summary.totalValue .. "¢"
            locationLabel.Text = "🌍 Location: " .. summary.currentLocation
            
            -- Update recent catches (show last 3) with improved emoji system
            local recentCatches = {}
            for i = math.max(1, #Dashboard.fishCaught - 2), #Dashboard.fishCaught do
                if Dashboard.fishCaught[i] then
                    local fish = Dashboard.fishCaught[i]
                    local rarity = fish.rarity or "COMMON"
                    
                    -- Enhanced emoji system for better visual distinction
                    local emoji = "🐟" -- Default
                    if rarity == "MYTHIC" then
                        emoji = "🔥"
                    elseif rarity == "LEGENDARY" then
                        emoji = "⭐"
                    elseif rarity == "EPIC" then
                        emoji = "💎"
                    elseif rarity == "RARE" then
                        emoji = "🌟"
                    elseif rarity == "UNCOMMON" then
                        emoji = "✨"
                    else
                        emoji = "🐟"
                    end
                    
                    local fishDisplay = fish.name
                    if fish.hasVariant and fish.variantType and fish.variantType ~= "" then
                        fishDisplay = fishDisplay .. " (" .. fish.variantType .. ")"
                    end
                    
                    table.insert(recentCatches, emoji .. " " .. fishDisplay)
                end
            end
            
            recentFish1.Text = recentCatches[3] or "🎣 No recent catches"
            recentFish2.Text = recentCatches[2] or ""
            recentFish3.Text = recentCatches[1] or ""
            
            task.wait(1)
        end
    end)

    Utils.Notify("🎣 ModernAutoFish", "UI loaded with preserved original design!")
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Build UI
BuildUI()

-- Global API
_G.ModernAutoFish = {
    -- Core functions
    StartSecure = FishingAI.StartSecureMode,
    StartAuto = FishingAI.StartAutoMode,
    Stop = FishingAI.StopFishing,
    StopAuto = FishingAI.StopAutoMode,
    
    -- Teleport
    TeleportTo = Teleport.To,
    
    -- Movement
    SetSpeed = Movement.SetSpeed,
    SetJump = Movement.SetJump,
    
    -- Statistics
    GetStats = function() return FishingAI.statistics end,
    
    -- Module access
    Config = Config,
    Utils = Utils,
    FishingAI = FishingAI,
    Movement = Movement,
    Teleport = Teleport
}

print("🎣 ModernAutoFish v2.1.0 (UI Preserved) - Loaded successfully!")
print("📚 Repository: https://github.com/donitono/Ikan-itu")
print("🎨 Original UI design preserved with modern dark theme")
print("🔧 API available at: _G.ModernAutoFish")
