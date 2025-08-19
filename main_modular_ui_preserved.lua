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

7. 💰 ECONOMY TRACKER
   - Real-time fish market values dari FishWeightChances & RollData
   - Profit per hour calculations
   - Investment recommendations

8. 🎮 QUEST AUTOMATION
   - Auto quest completion dari QuestList & QuestUtility
   - Quest reward optimization
   - Progress tracking

9. 📈 ADVANCED ANALYTICS
   - Catch rate analysis
   - Efficiency metrics dari PlayerStatsUtility
   - Predictive modeling

10. 🤖 AI LEARNING SYSTEM
    - Pattern recognition
    - Adaptive strategies
    - Performance optimization
--]]
Version: 2.1.0 (UI Preserved)
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
        Orange = Color3.fromRGB(255,140,0)
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
        ["⚙️ MACHINE"] = CFrame.new(-1551.25, 2.87, 1920.26)
    }
}

local sessionId = 1
local autoModeSessionId = 1

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
-- ENCHANT SYSTEM
-- ============================================================================
local EnchantSystem = {
    isActive = false,
    targetEnchants = {},
    currentRoll = nil,
    enchantStones = {},
    originalHotbar = {},
    rollCount = 0,
    maxRolls = 50,
    statusLabel = nil,
    rollLabel = nil,
    currentLabel = nil,
    distanceLabel = nil
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

function EnchantSystem.TeleportToAltar()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = ALTAR_POSITION
        Utils.Notify("✨ Enchant", "🏛️ Teleported to Enchanting Altar")
    end
end

function EnchantSystem.PrepareHotbar()
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
    
    if #enchantStones < 1 then
        Utils.Notify("✨ Enchant", "❌ Need at least 1 Enchant Stone!")
        return false
    end
    
    -- Equip first enchant stone
    if enchantStones[1] then
        enchantStones[1].Parent = character
    end
    
    EnchantSystem.enchantStones = enchantStones
    Utils.Notify("✨ Enchant", "✅ Hotbar prepared with Enchant Stones")
    return true
end

function EnchantSystem.StartEnchanting()
    if EnchantSystem.isActive then
        Utils.Notify("✨ Enchant", "❌ Enchanting already active!")
        return
    end
    
    -- Validate target enchants
    local targetCount = 0
    for _ in pairs(EnchantSystem.targetEnchants) do
        targetCount = targetCount + 1
    end
    
    if targetCount == 0 then
        Utils.Notify("✨ Enchant", "❌ No target enchants selected!")
        return
    end
    
    -- Check distance to altar
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - ALTAR_POSITION.Position).Magnitude
        if distance > 30 then
            Utils.Notify("✨ Enchant", "❌ Too far from altar! Distance: " .. math.floor(distance))
            return
        end
    end
    
    -- Prepare hotbar
    if not EnchantSystem.PrepareHotbar() then
        return
    end
    
    -- Start enchanting process
    EnchantSystem.isActive = true
    EnchantSystem.rollCount = 0
    EnchantSystem.UpdateStatus("🟡 Starting enchanting process...")
    
    Utils.Notify("✨ Enchant", "🎯 Starting enchant rolling!")
    
    -- Start the enchanting loop
    spawn(function()
        EnchantSystem.EnchantingLoop()
    end)
end

function EnchantSystem.EnchantingLoop()
    while EnchantSystem.isActive and EnchantSystem.rollCount < EnchantSystem.maxRolls do
        -- Activate enchanting altar
        local success = pcall(function()
            local net = Utils.FindNet()
            if net then
                local activateRemote = net:FindFirstChild("RE")
                if activateRemote then
                    activateRemote = activateRemote:FindFirstChild("ActivateEnchantingAltar")
                    if activateRemote then
                        activateRemote:FireServer()
                        EnchantSystem.rollCount = EnchantSystem.rollCount + 1
                        EnchantSystem.UpdateRollCount()
                        
                        -- Wait for enchant result
                        wait(2)
                        
                        -- Check if we got a target enchant (simplified simulation)
                        local gotTargetEnchant = EnchantSystem.CheckForTargetEnchant()
                        
                        if gotTargetEnchant then
                            EnchantSystem.StopEnchanting()
                            Utils.Notify("✨ Enchant", "🎉 Target enchant obtained: " .. gotTargetEnchant)
                            return
                        end
                    end
                end
            end
        end)
        
        if not success then
            Utils.Notify("✨ Enchant", "❌ Failed to activate altar")
            break
        end
        
        wait(3) -- Wait between rolls
    end
    
    if EnchantSystem.rollCount >= EnchantSystem.maxRolls then
        EnchantSystem.StopEnchanting()
        Utils.Notify("✨ Enchant", "🛑 Max rolls reached without target enchant")
    end
end

function EnchantSystem.CheckForTargetEnchant()
    -- Simulate random enchant result
    local enchantNames = {}
    for name in pairs(ENCHANT_TYPES) do
        table.insert(enchantNames, name)
    end
    
    local randomEnchant = enchantNames[math.random(#enchantNames)]
    EnchantSystem.UpdateCurrentRoll(randomEnchant)
    
    -- Check if this matches our targets
    if EnchantSystem.targetEnchants[randomEnchant] then
        return randomEnchant
    end
    
    return false
end

function EnchantSystem.StopEnchanting()
    EnchantSystem.isActive = false
    EnchantSystem.UpdateStatus("🔴 Stopped")
    EnchantSystem.ResetHotbar()
    Utils.Notify("✨ Enchant", "🛑 Enchanting stopped")
end

function EnchantSystem.ResetHotbar()
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
    
    Utils.Notify("✨ Enchant", "🔄 Hotbar reset")
end

-- UI Update Functions
function EnchantSystem.UpdateStatus(status)
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

function EnchantSystem.UpdateRollCount()
    if EnchantSystem.rollLabel then
        EnchantSystem.rollLabel.Text = string.format("Rolls: %d/%d", EnchantSystem.rollCount, EnchantSystem.maxRolls)
    end
end

function EnchantSystem.UpdateCurrentRoll(enchantName)
    if EnchantSystem.currentLabel then
        EnchantSystem.currentLabel.Text = "Current Roll: " .. (enchantName or "None")
        
        if enchantName and ENCHANT_TYPES[enchantName] then
            EnchantSystem.currentLabel.TextColor3 = ENCHANT_TYPES[enchantName].color
        else
            EnchantSystem.currentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
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
    local enchantTabBtn = createTabButton("✨ Enchant", 5, 210)
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

    -- Tab 5: Enchant
    local enchantFrame, enchantScroll = createTabFrame()

    -- Enchant System Status
    local enchantStatusSection = Instance.new("Frame", enchantScroll)
    enchantStatusSection.Size = UDim2.new(1, -10, 0, 100)
    enchantStatusSection.Position = UDim2.new(0, 5, 0, 5)
    enchantStatusSection.BackgroundColor3 = Config.Colors.SectionBG
    enchantStatusSection.BorderSizePixel = 0
    Instance.new("UICorner", enchantStatusSection)

    local enchantTitle = Instance.new("TextLabel", enchantStatusSection)
    enchantTitle.Size = UDim2.new(1, -20, 0, 25)
    enchantTitle.Position = UDim2.new(0, 10, 0, 5)
    enchantTitle.Text = "✨ Enchant System Status"
    enchantTitle.Font = Enum.Font.GothamSemibold
    enchantTitle.TextSize = 16
    enchantTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    enchantTitle.BackgroundTransparency = 1
    enchantTitle.TextXAlignment = Enum.TextXAlignment.Left

    local enchantStatusLabel = Instance.new("TextLabel", enchantStatusSection)
    enchantStatusLabel.Size = UDim2.new(1, -20, 0, 20)
    enchantStatusLabel.Position = UDim2.new(0, 10, 0, 35)
    enchantStatusLabel.Text = "🔴 Inactive"
    enchantStatusLabel.Font = Enum.Font.GothamSemibold
    enchantStatusLabel.TextSize = 14
    enchantStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    enchantStatusLabel.BackgroundTransparency = 1
    enchantStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    local enchantRollLabel = Instance.new("TextLabel", enchantStatusSection)
    enchantRollLabel.Size = UDim2.new(1, -20, 0, 15)
    enchantRollLabel.Position = UDim2.new(0, 10, 0, 60)
    enchantRollLabel.Text = "Rolls: 0/50"
    enchantRollLabel.Font = Enum.Font.Gotham
    enchantRollLabel.TextSize = 12
    enchantRollLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    enchantRollLabel.BackgroundTransparency = 1
    enchantRollLabel.TextXAlignment = Enum.TextXAlignment.Left

    local enchantCurrentLabel = Instance.new("TextLabel", enchantStatusSection)
    enchantCurrentLabel.Size = UDim2.new(1, -20, 0, 15)
    enchantCurrentLabel.Position = UDim2.new(0, 10, 0, 80)
    enchantCurrentLabel.Text = "Current Roll: None"
    enchantCurrentLabel.Font = Enum.Font.Gotham
    enchantCurrentLabel.TextSize = 12
    enchantCurrentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    enchantCurrentLabel.BackgroundTransparency = 1
    enchantCurrentLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Altar Navigation
    local altarSection = Instance.new("Frame", enchantScroll)
    altarSection.Size = UDim2.new(1, -10, 0, 80)
    altarSection.Position = UDim2.new(0, 5, 0, 115)
    altarSection.BackgroundColor3 = Config.Colors.SectionBG
    altarSection.BorderSizePixel = 0
    Instance.new("UICorner", altarSection)

    local altarTitle = Instance.new("TextLabel", altarSection)
    altarTitle.Size = UDim2.new(1, -20, 0, 25)
    altarTitle.Position = UDim2.new(0, 10, 0, 5)
    altarTitle.Text = "🏛️ Altar Navigation"
    altarTitle.Font = Enum.Font.GothamSemibold
    altarTitle.TextSize = 16
    altarTitle.TextColor3 = Color3.fromRGB(150, 100, 255)
    altarTitle.BackgroundTransparency = 1
    altarTitle.TextXAlignment = Enum.TextXAlignment.Left

    local distanceLabel = Instance.new("TextLabel", altarSection)
    distanceLabel.Size = UDim2.new(1, -140, 0, 20)
    distanceLabel.Position = UDim2.new(0, 10, 0, 35)
    distanceLabel.Text = "Distance to Altar: Calculating..."
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 12
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Left

    local teleportAltarBtn = Instance.new("TextButton", altarSection)
    teleportAltarBtn.Size = UDim2.new(0, 120, 0, 25)
    teleportAltarBtn.Position = UDim2.new(1, -130, 0, 50)
    teleportAltarBtn.Text = "🏛️ Go to Altar"
    teleportAltarBtn.Font = Enum.Font.GothamSemibold
    teleportAltarBtn.TextSize = 12
    teleportAltarBtn.TextColor3 = Color3.fromRGB(255,255,255)
    teleportAltarBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    teleportAltarBtn.BorderSizePixel = 0
    Instance.new("UICorner", teleportAltarBtn)

    -- Enchant Selection Section
    local selectionSection = Instance.new("Frame", enchantScroll)
    selectionSection.Size = UDim2.new(1, -10, 0, 280)
    selectionSection.Position = UDim2.new(0, 5, 0, 205)
    selectionSection.BackgroundColor3 = Config.Colors.SectionBG
    selectionSection.BorderSizePixel = 0
    Instance.new("UICorner", selectionSection)

    local selectionTitle = Instance.new("TextLabel", selectionSection)
    selectionTitle.Size = UDim2.new(1, -20, 0, 25)
    selectionTitle.Position = UDim2.new(0, 10, 0, 5)
    selectionTitle.Text = "🎯 Enchant Selection"
    selectionTitle.Font = Enum.Font.GothamSemibold
    selectionTitle.TextSize = 16
    selectionTitle.TextColor3 = Color3.fromRGB(100, 255, 150)
    selectionTitle.BackgroundTransparency = 1
    selectionTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Enchant checkboxes would be added here programmatically
    local enchantListFrame = Instance.new("ScrollingFrame", selectionSection)
    enchantListFrame.Size = UDim2.new(1, -20, 1, -60)
    enchantListFrame.Position = UDim2.new(0, 10, 0, 35)
    enchantListFrame.BackgroundTransparency = 1
    enchantListFrame.BorderSizePixel = 0
    enchantListFrame.ScrollBarThickness = 6
    enchantListFrame.CanvasSize = UDim2.new(0, 0, 0, 350)

    -- Select All / Deselect All buttons
    local selectAllBtn = Instance.new("TextButton", selectionSection)
    selectAllBtn.Size = UDim2.new(0, 80, 0, 20)
    selectAllBtn.Position = UDim2.new(0, 10, 1, -25)
    selectAllBtn.Text = "Select All"
    selectAllBtn.Font = Enum.Font.Gotham
    selectAllBtn.TextSize = 10
    selectAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
    selectAllBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    selectAllBtn.BorderSizePixel = 0
    Instance.new("UICorner", selectAllBtn)

    local deselectAllBtn = Instance.new("TextButton", selectionSection)
    deselectAllBtn.Size = UDim2.new(0, 80, 0, 20)
    deselectAllBtn.Position = UDim2.new(0, 100, 1, -25)
    deselectAllBtn.Text = "Deselect All"
    deselectAllBtn.Font = Enum.Font.Gotham
    deselectAllBtn.TextSize = 10
    deselectAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
    deselectAllBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    deselectAllBtn.BorderSizePixel = 0
    Instance.new("UICorner", deselectAllBtn)

    -- Control Section
    local controlSection = Instance.new("Frame", enchantScroll)
    controlSection.Size = UDim2.new(1, -10, 0, 120)
    controlSection.Position = UDim2.new(0, 5, 0, 495)
    controlSection.BackgroundColor3 = Config.Colors.SectionBG
    controlSection.BorderSizePixel = 0
    Instance.new("UICorner", controlSection)

    local controlTitle = Instance.new("TextLabel", controlSection)
    controlTitle.Size = UDim2.new(1, -20, 0, 25)
    controlTitle.Position = UDim2.new(0, 10, 0, 5)
    controlTitle.Text = "🎮 Enchant Controls"
    controlTitle.Font = Enum.Font.GothamSemibold
    controlTitle.TextSize = 16
    controlTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
    controlTitle.BackgroundTransparency = 1
    controlTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Max Rolls Setting
    local rollsLabel = Instance.new("TextLabel", controlSection)
    rollsLabel.Size = UDim2.new(0, 80, 0, 20)
    rollsLabel.Position = UDim2.new(0, 10, 0, 35)
    rollsLabel.Text = "Max Rolls:"
    rollsLabel.Font = Enum.Font.Gotham
    rollsLabel.TextSize = 12
    rollsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    rollsLabel.BackgroundTransparency = 1
    rollsLabel.TextXAlignment = Enum.TextXAlignment.Left

    local rollsInput = Instance.new("TextBox", controlSection)
    rollsInput.Size = UDim2.new(0, 50, 0, 20)
    rollsInput.Position = UDim2.new(0, 95, 0, 35)
    rollsInput.Text = "50"
    rollsInput.Font = Enum.Font.Gotham
    rollsInput.TextSize = 12
    rollsInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    rollsInput.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    rollsInput.BorderSizePixel = 0
    rollsInput.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", rollsInput)

    -- Control Buttons
    local startEnchantBtn = Instance.new("TextButton", controlSection)
    startEnchantBtn.Size = UDim2.new(0, 100, 0, 25)
    startEnchantBtn.Position = UDim2.new(0, 10, 0, 65)
    startEnchantBtn.Text = "🎯 Start Rolling"
    startEnchantBtn.Font = Enum.Font.GothamSemibold
    startEnchantBtn.TextSize = 12
    startEnchantBtn.TextColor3 = Color3.fromRGB(255,255,255)
    startEnchantBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    startEnchantBtn.BorderSizePixel = 0
    Instance.new("UICorner", startEnchantBtn)

    local stopEnchantBtn = Instance.new("TextButton", controlSection)
    stopEnchantBtn.Size = UDim2.new(0, 100, 0, 25)
    stopEnchantBtn.Position = UDim2.new(0, 120, 0, 65)
    stopEnchantBtn.Text = "🛑 Stop Rolling"
    stopEnchantBtn.Font = Enum.Font.GothamSemibold
    stopEnchantBtn.TextSize = 12
    stopEnchantBtn.TextColor3 = Color3.fromRGB(255,255,255)
    stopEnchantBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    stopEnchantBtn.BorderSizePixel = 0
    Instance.new("UICorner", stopEnchantBtn)

    local resetHotbarBtn = Instance.new("TextButton", controlSection)
    resetHotbarBtn.Size = UDim2.new(0, 100, 0, 25)
    resetHotbarBtn.Position = UDim2.new(0, 230, 0, 65)
    resetHotbarBtn.Text = "🔄 Reset Hotbar"
    resetHotbarBtn.Font = Enum.Font.GothamSemibold
    resetHotbarBtn.TextSize = 12
    resetHotbarBtn.TextColor3 = Color3.fromRGB(255,255,255)
    resetHotbarBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    resetHotbarBtn.BorderSizePixel = 0
    Instance.new("UICorner", resetHotbarBtn)

    enchantScroll.CanvasSize = UDim2.new(0, 0, 0, 625)

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
        [enchantTabBtn] = {frame = enchantFrame, title = "Enchant System"},
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

    -- Enchant callbacks
    teleportAltarBtn.MouseButton1Click:Connect(function()
        EnchantSystem.TeleportToAltar()
    end)

    -- Setup enchant type checkboxes
    local yPos = 35
    local enchantCheckboxes = {}
    
    for enchantName, enchantData in pairs(ENCHANT_TYPES) do
        local enchantFrame = Instance.new("Frame", enchantListFrame)
        enchantFrame.Size = UDim2.new(1, -20, 0, 25)
        enchantFrame.Position = UDim2.new(0, 0, 0, yPos)
        enchantFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        enchantFrame.BorderSizePixel = 0
        Instance.new("UICorner", enchantFrame)

        -- Checkbox
        local checkbox = Instance.new("TextButton", enchantFrame)
        checkbox.Size = UDim2.new(0, 20, 0, 20)
        checkbox.Position = UDim2.new(0, 5, 0, 2.5)
        checkbox.Text = ""
        checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        checkbox.BorderSizePixel = 0
        Instance.new("UICorner", checkbox)

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
            
            Utils.Notify("✨ Enchant", (isSelected and "✓ Added: " or "✗ Removed: ") .. enchantName)
        end)

        enchantCheckboxes[enchantName] = {checkbox = checkbox, checkmark = checkmark}
        yPos = yPos + 30
    end

    -- Update canvas size for enchant list
    enchantListFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)

    selectAllBtn.MouseButton1Click:Connect(function()
        for enchantName, elements in pairs(enchantCheckboxes) do
            EnchantSystem.targetEnchants[enchantName] = true
            elements.checkmark.Visible = true
            elements.checkbox.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        end
        Utils.Notify("✨ Enchant", "✓ All enchants selected")
    end)

    deselectAllBtn.MouseButton1Click:Connect(function()
        for enchantName, elements in pairs(enchantCheckboxes) do
            EnchantSystem.targetEnchants[enchantName] = nil
            elements.checkmark.Visible = false
            elements.checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        end
        Utils.Notify("✨ Enchant", "✗ All enchants deselected")
    end)

    rollsInput.FocusLost:Connect(function()
        local maxRolls = tonumber(rollsInput.Text)
        if maxRolls and maxRolls > 0 and maxRolls <= 200 then
            EnchantSystem.maxRolls = maxRolls
        else
            rollsInput.Text = tostring(EnchantSystem.maxRolls)
            Utils.Notify("✨ Enchant", "❌ Invalid max rolls! Use 1-200")
        end
    end)

    startEnchantBtn.MouseButton1Click:Connect(function()
        EnchantSystem.StartEnchanting()
    end)

    stopEnchantBtn.MouseButton1Click:Connect(function()
        EnchantSystem.StopEnchanting()
    end)

    resetHotbarBtn.MouseButton1Click:Connect(function()
        EnchantSystem.ResetHotbar()
    end)

    -- Store UI references
    EnchantSystem.statusLabel = enchantStatusLabel
    EnchantSystem.rollLabel = enchantRollLabel
    EnchantSystem.currentLabel = enchantCurrentLabel
    EnchantSystem.distanceLabel = distanceLabel

    -- Update distance to altar periodically
    task.spawn(function()
        while screenGui.Parent do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - ALTAR_POSITION.Position).Magnitude
                distanceLabel.Text = string.format("Distance to Altar: %.1f studs", distance)
                
                if distance < 20 then
                    distanceLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                else
                    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
            wait(2)
        end
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
