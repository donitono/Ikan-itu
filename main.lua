-- modern_autofish.lua
-- Cleaned modern UI + Dual-mode AutoFishing (smart & secure)
-- Added new feature: Auto Mode by Spinner_xxx

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- Must run on client
if not RunService:IsClient() then
    warn("modern_autofish: must run as a LocalScript on the client (StarterPlayerScripts). Aborting.")
    return
end

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("modern_autofish: LocalPlayer missing. Run as LocalScript while in Play mode.")
    return
end

-- Rod Orientation Fix
local RodFix = {
    enabled = true,
    lastFixTime = 0,
    isCharging = false,
    chargingConnection = nil
}

-- Monitor charging phase untuk fix yang lebih aktif
local function MonitorChargingPhase()
    if RodFix.chargingConnection then
        RodFix.chargingConnection:Disconnect()
    end
    
    -- Monitor setiap frame selama charging untuk fix real-time
    RodFix.chargingConnection = RunService.Heartbeat:Connect(function()
        if not RodFix.enabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- Deteksi charging animation
        local isCurrentlyCharging = false
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            local animName = track.Name:lower()
            if animName:find("charge") or animName:find("cast") or animName:find("rod") then
                isCurrentlyCharging = true
                break
            end
        end
        
        -- Jika dalam phase charging, lakukan fix lebih sering
        if isCurrentlyCharging then
            RodFix.isCharging = true
            FixRodOrientation() -- Fix setiap frame selama charging
        else
            if RodFix.isCharging then
                -- Setelah charging selesai, lakukan fix final
                RodFix.isCharging = false
                task.wait(0.1)
                FixRodOrientation()
            end
        end
    end)
end

local function FixRodOrientation()
    if not RodFix.enabled then return end
    
    local now = tick()
    if now - RodFix.lastFixTime < 0.05 then return end -- Faster throttle for charging phase
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
    
    -- Method 1: Fix Motor6D during charging phase (paling efektif)
    local rightArm = character:FindFirstChild("Right Arm")
    if rightArm then
        local rightGrip = rightArm:FindFirstChild("RightGrip")
        if rightGrip and rightGrip:IsA("Motor6D") then
            -- Orientasi normal untuk rod menghadap depan SELAMA charging
            -- C0 mengontrol posisi/orientasi di right arm
            -- C1 mengontrol posisi/orientasi di handle
            rightGrip.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            rightGrip.C1 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
            return
        end
    end
    
    -- Method 2: Fix Tool Grip Value (untuk tools dengan custom grip)
    local handle = equippedTool:FindFirstChild("Handle")
    if handle then
        -- Fix grip value yang ada
        local toolGrip = equippedTool:FindFirstChild("Grip")
        if toolGrip and toolGrip:IsA("CFrameValue") then
            -- Grip value untuk rod menghadap depan
            toolGrip.Value = CFrame.new(0, -1.5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            return
        end
        
        -- Jika tidak ada grip value, buat yang baru
        if not toolGrip then
            toolGrip = Instance.new("CFrameValue")
            toolGrip.Name = "Grip"
            toolGrip.Value = CFrame.new(0, -1.5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            toolGrip.Parent = equippedTool
        end
    end
end

-- Simple notifier
local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 4})
    end)
    print("[modern_autofish]", title, text)
end

-- Remote helper (best-effort)
local function FindNet()
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

local net = FindNet()
local function ResolveRemote(name)
    if not net then return nil end
    local ok, rem = pcall(function() return net:FindFirstChild(name) end)
    return ok and rem or nil
end

local rodRemote = ResolveRemote("RF/ChargeFishingRod")
local miniGameRemote = ResolveRemote("RF/RequestFishingMinigameStarted")
local finishRemote = ResolveRemote("RE/FishingCompleted")
local equipRemote = ResolveRemote("RE/EquipToolFromHotbar")
local fishCaughtRemote = ResolveRemote("RE/FishCaught")
local autoFishStateRemote = ResolveRemote("RF/UpdateAutoFishingState")

-- Additional remotes for enhanced detection
local baitSpawnedRemote = ResolveRemote("RE/BaitSpawned")
local fishingStoppedRemote = ResolveRemote("RE/FishingStopped")
local newFishNotificationRemote = ResolveRemote("RE/ObtainedNewFishNotification")
local playFishingEffectRemote = ResolveRemote("RE/PlayFishingEffect")
local fishingMinigameChangedRemote = ResolveRemote("RE/FishingMinigameChanged")

-- Equipment remotes for auto unequip
local unequipRemote = ResolveRemote("RE/UnequipToolFromHotbar")
local unequipItemRemote = ResolveRemote("RE/UnequipItem")
local cancelFishingInputsRemote = ResolveRemote("RF/CancelFishingInputs")

-- Network & Connection remotes
local reconnectPlayerRemote = ResolveRemote("RE/ReconnectPlayer")

-- Enhancement remotes
local activateEnchantingAltarRemote = ResolveRemote("RE/ActivateEnchantingAltar")
local updateEnchantStateRemote = ResolveRemote("RE/UpdateEnchantState")
local rollEnchantRemote = ResolveRemote("RE/RollEnchant")

-- Weather remotes
local purchaseWeatherEventRemote = ResolveRemote("RF/PurchaseWeatherEvent")

-- Animation-Based Fishing System (defined early to avoid nil errors)
local AnimationMonitor = {
    isMonitoring = false,
    currentState = "idle",
    lastAnimationTime = 0,
    animationSequence = {},
    fishingSuccess = false
}

-- Enhanced Fish Detection System menggunakan semua 20 remotes
local FishDetection = {
    lastCatchTime = 0,
    recentCatches = {}
}

-- Event listeners untuk enhanced detection (setelah AnimationMonitor didefinisikan)
if newFishNotificationRemote then
    newFishNotificationRemote.OnClientEvent:Connect(function(fishData)
        if fishData and fishData.name and Dashboard and Dashboard.LogFishCatch then
            Dashboard.LogFishCatch(fishData.name, Dashboard.sessionStats.currentLocation)
            Notify("New Fish!", "🎣 Caught: " .. fishData.name)
        elseif fishData and fishData.name then
            Notify("New Fish!", "🎣 Caught: " .. fishData.name)
        end
    end)
end

if baitSpawnedRemote then
    baitSpawnedRemote.OnClientEvent:Connect(function()
        -- Bait spawned - good time for rod orientation fix
        task.wait(0.1)
        FixRodOrientation()
    end)
end

if fishingStoppedRemote then
    fishingStoppedRemote.OnClientEvent:Connect(function()
        -- Fishing stopped - reset animation state
        if AnimationMonitor then
            AnimationMonitor.currentState = "idle"
            AnimationMonitor.fishingSuccess = false
        end
    end)
end

if playFishingEffectRemote then
    playFishingEffectRemote.OnClientEvent:Connect(function()
        -- Visual effect played - likely successful action
        if AnimationMonitor then
            AnimationMonitor.fishingSuccess = true
        end
    end)
end

if fishingMinigameChangedRemote then
    fishingMinigameChangedRemote.OnClientEvent:Connect(function()
        -- Mini-game state changed - fix rod orientation
        FixRodOrientation()
    end)
end
LocalPlayer.CharacterAdded:Connect(function(character)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.1) -- Wait for tool to fully load
            FixRodOrientation()
            MonitorChargingPhase() -- Start monitoring charging phase
        end
    end)
    
    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and RodFix.chargingConnection then
            RodFix.chargingConnection:Disconnect()
            RodFix.chargingConnection = nil
        end
    end)
end)

-- Fix current tool if character already exists
if LocalPlayer.Character then
    LocalPlayer.Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.1)
            FixRodOrientation()
            MonitorChargingPhase()
        end
    end)
    
    LocalPlayer.Character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and RodFix.chargingConnection then
            RodFix.chargingConnection:Disconnect()
            RodFix.chargingConnection = nil
        end
    end)
    
    -- Check if rod is already equipped
    local currentTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if currentTool then
        FixRodOrientation()
        MonitorChargingPhase()
    end
end

local function safeInvoke(remote, ...)
    if not remote then return false, "nil_remote" end
    if remote:IsA("RemoteFunction") then
        return pcall(function(...) return remote:InvokeServer(...) end, ...)
    else
        return pcall(function(...) remote:FireServer(...) return true end, ...)
    end
end

-- Auto Unequip Rod Function
local function AutoUnequipRod()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local equippedTool = character:FindFirstChildOfClass("Tool")
    if not equippedTool then return false end
    
    -- Check if it's a fishing rod
    local isRod = equippedTool.Name:lower():find("rod") or 
                  equippedTool:FindFirstChild("Rod") or
                  equippedTool:FindFirstChild("Handle")
    if not isRod then return false end
    
    print("Auto unequipping rod:", equippedTool.Name)
    
    -- Try multiple unequip methods
    local success = false
    
    -- Method 1: Use UnequipToolFromHotbar remote
    if unequipRemote then
        local ok = pcall(function() unequipRemote:FireServer() end)
        if ok then success = true end
    end
    
    -- Method 2: Use UnequipItem remote as backup
    if not success and unequipItemRemote then
        local ok = pcall(function() unequipItemRemote:FireServer() end)
        if ok then success = true end
    end
    
    -- Method 3: Cancel fishing inputs
    if cancelFishingInputsRemote then
        pcall(function() cancelFishingInputsRemote:InvokeServer() end)
    end
    
    -- Method 4: Manual unequip as last resort
    if not success then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            pcall(function() humanoid:UnequipTools() end)
        end
    end
    
    return true
end

-- Auto Reconnect Function
local function AutoReconnect()
    if not NetworkManager.autoReconnect then return end
    if not reconnectPlayerRemote then return end
    
    if NetworkManager.currentAttempts >= NetworkManager.maxReconnectAttempts then
        print("Max reconnect attempts reached")
        Notify("Network", "❌ Max reconnect attempts reached")
        return
    end
    
    NetworkManager.currentAttempts = NetworkManager.currentAttempts + 1
    NetworkManager.lastDisconnectTime = tick()
    
    print("Attempting auto reconnect... (Attempt " .. NetworkManager.currentAttempts .. "/" .. NetworkManager.maxReconnectAttempts .. ")")
    Notify("Network", "🔄 Auto reconnecting... (Attempt " .. NetworkManager.currentAttempts .. ")")
    
    -- Wait before reconnecting
    task.wait(NetworkManager.reconnectDelay)
    
    local success = pcall(function()
        reconnectPlayerRemote:FireServer()
    end)
    
    if success then
        print("Reconnect signal sent successfully")
        Notify("Network", "✅ Reconnect signal sent")
    else
        print("Failed to send reconnect signal")
        Notify("Network", "❌ Failed to reconnect")
    end
end

-- Monitor Network Connection
local function MonitorConnection()
    -- Monitor for disconnections and trigger auto reconnect
    local lastHeartbeat = tick()
    
    RunService.Heartbeat:Connect(function()
        lastHeartbeat = tick()
    end)
    
    -- Check for connection issues
    task.spawn(function()
        while true do
            task.wait(10) -- Check every 10 seconds
            
            if NetworkManager.autoReconnect then
                local timeSinceHeartbeat = tick() - lastHeartbeat
                
                -- If no heartbeat for 15 seconds, might be disconnected
                if timeSinceHeartbeat > 15 then
                    print("Potential connection issue detected")
                    AutoReconnect()
                    break
                end
            end
        end
    end)
end

-- Config
local Config = {
    mode = "smart",  -- Default to smart mode
    autoRecastDelay = 0.4,
    safeModeChance = 70,
    secure_max_actions_per_minute = 12000000,
    secure_detection_cooldown = 5,
    enabled = false,
    antiAfkEnabled = false,
    enhancementEnabled = false,
    autoReconnectEnabled = false,
    autoModeEnabled = false -- New state for Auto Mode
}

-- ====================================================================
-- MOVEMENT ENHANCEMENT SYSTEM
-- ====================================================================
local MovementEnhancement = {
    floatEnabled = false,
    noClipEnabled = false,
    floatHeight = 16,
    floatSpeed = 0.1,
    floatConnection = nil,
    noClipConnections = {},
    originalProperties = {},
    
    -- Auto Spinner System
    spinnerEnabled = false,
    spinnerSpeed = 2, -- Rotation speed (1-10)
    spinnerDirection = 1, -- 1 for clockwise, -1 for counter-clockwise
    spinnerConnection = nil,
    currentRotation = 0
}

local function EnableFloat()
    if MovementEnhancement.floatEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then 
        Notify("Movement", "❌ Character not found!")
        return 
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then
        Notify("Movement", "❌ Character components missing!")
        return
    end
    
    MovementEnhancement.floatEnabled = true
    
    -- Store original properties
    MovementEnhancement.originalProperties.PlatformStand = humanoid.PlatformStand
    MovementEnhancement.originalProperties.WalkSpeed = humanoid.WalkSpeed
    
    -- Create BodyVelocity for floating
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart
    
    -- Create BodyPosition for height control
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(0, math.huge, 0)
    bodyPosition.Position = rootPart.Position + Vector3.new(0, MovementEnhancement.floatHeight, 0)
    bodyPosition.Parent = rootPart
    
    -- Enable platform stand
    humanoid.PlatformStand = true
    
    -- Float control loop
    MovementEnhancement.floatConnection = RunService.Heartbeat:Connect(function()
        if not MovementEnhancement.floatEnabled then return end
        
        local camera = workspace.CurrentCamera
        if not camera then return end
        
        local moveVector = Vector3.new(0, 0, 0)
        
        -- WASD movement
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + camera.CFrame.RightVector
        end
        
        -- Up/Down movement
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector = moveVector - Vector3.new(0, 1, 0)
        end
        
        -- Apply movement
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * humanoid.WalkSpeed
            bodyVelocity.Velocity = moveVector
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Update height
        bodyPosition.Position = Vector3.new(rootPart.Position.X, rootPart.Position.Y, rootPart.Position.Z)
    end)
    
    Notify("Movement", "🚀 Float enabled! Use WASD + Space/Shift to move")
end

local function DisableFloat()
    if not MovementEnhancement.floatEnabled then return end
    
    MovementEnhancement.floatEnabled = false
    
    -- Disconnect float loop
    if MovementEnhancement.floatConnection then
        MovementEnhancement.floatConnection:Disconnect()
        MovementEnhancement.floatConnection = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid then
            -- Restore original properties
            humanoid.PlatformStand = MovementEnhancement.originalProperties.PlatformStand or false
        end
        
        if rootPart then
            -- Remove float objects
            local bodyVelocity = rootPart:FindFirstChild("BodyVelocity")
            local bodyPosition = rootPart:FindFirstChild("BodyPosition")
            
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyPosition then bodyPosition:Destroy() end
        end
    end
    
    Notify("Movement", "🛑 Float disabled")
end

local function EnableNoClip()
    if MovementEnhancement.noClipEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then 
        Notify("Movement", "❌ Character not found!")
        return 
    end
    
    MovementEnhancement.noClipEnabled = true
    
    -- Function to make part non-collidable
    local function makeNonCollidable(part)
        if part:IsA("BasePart") then
            MovementEnhancement.originalProperties[part] = part.CanCollide
            part.CanCollide = false
        end
    end
    
    -- Apply to all current parts
    for _, part in pairs(character:GetChildren()) do
        makeNonCollidable(part)
    end
    
    -- Monitor for new parts
    MovementEnhancement.noClipConnections[#MovementEnhancement.noClipConnections + 1] = 
        character.ChildAdded:Connect(makeNonCollidable)
    
    -- Continuous no-clip maintenance
    MovementEnhancement.noClipConnections[#MovementEnhancement.noClipConnections + 1] = 
        RunService.Stepped:Connect(function()
            if not MovementEnhancement.noClipEnabled then return end
            
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    
    Notify("Movement", "👻 No Clip enabled! Walk through walls")
end

local function DisableNoClip()
    if not MovementEnhancement.noClipEnabled then return end
    
    MovementEnhancement.noClipEnabled = false
    
    -- Disconnect all connections
    for _, connection in pairs(MovementEnhancement.noClipConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    MovementEnhancement.noClipConnections = {}
    
    local character = LocalPlayer.Character
    if character then
        -- Restore collision for all parts
        for part, originalValue in pairs(MovementEnhancement.originalProperties) do
            if part and part.Parent and typeof(originalValue) == "boolean" then
                part.CanCollide = originalValue
            end
        end
    end
    
    MovementEnhancement.originalProperties = {}
    Notify("Movement", "🛑 No Clip disabled")
end

local function EnableAutoSpinner()
    if MovementEnhancement.spinnerEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then 
        Notify("Movement", "❌ Character not found!")
        return 
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        Notify("Movement", "❌ HumanoidRootPart not found!")
        return
    end
    
    MovementEnhancement.spinnerEnabled = true
    MovementEnhancement.currentRotation = 0
    
    -- Create smooth spinner loop
    MovementEnhancement.spinnerConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not MovementEnhancement.spinnerEnabled then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        -- Calculate rotation increment
        local rotationSpeed = MovementEnhancement.spinnerSpeed * MovementEnhancement.spinnerDirection
        local rotationIncrement = math.rad(rotationSpeed * 60) * deltaTime -- Convert to radians per frame
        
        MovementEnhancement.currentRotation = MovementEnhancement.currentRotation + rotationIncrement
        
        -- Apply rotation
        local currentCFrame = rootPart.CFrame
        local position = currentCFrame.Position
        local newCFrame = CFrame.new(position) * CFrame.Angles(0, MovementEnhancement.currentRotation, 0)
        
        rootPart.CFrame = newCFrame
    end)
    
    Notify("Movement", "🌪️ Auto Spinner enabled! Player will rotate while fishing")
end

local function DisableAutoSpinner()
    if not MovementEnhancement.spinnerEnabled then return end
    
    MovementEnhancement.spinnerEnabled = false
    
    -- Disconnect spinner loop
    if MovementEnhancement.spinnerConnection then
        MovementEnhancement.spinnerConnection:Disconnect()
        MovementEnhancement.spinnerConnection = nil
    end
    
    MovementEnhancement.currentRotation = 0
    Notify("Movement", "🛑 Auto Spinner disabled")
end

local function SetSpinnerSpeed(speed)
    if speed and speed >= 0.5 and speed <= 10 then
        MovementEnhancement.spinnerSpeed = speed
        Notify("Movement", "🌪️ Spinner speed set to: " .. speed)
    end
end

local function ToggleSpinnerDirection()
    MovementEnhancement.spinnerDirection = MovementEnhancement.spinnerDirection * -1
    local direction = MovementEnhancement.spinnerDirection > 0 and "Clockwise" or "Counter-Clockwise"
    Notify("Movement", "🔄 Spinner direction: " .. direction)
end

-- Handle character respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1) -- Wait for character to load
    
    -- Re-enable float if it was enabled
    if MovementEnhancement.floatEnabled then
        MovementEnhancement.floatEnabled = false
        EnableFloat()
    end
    
    -- Re-enable no-clip if it was enabled
    if MovementEnhancement.noClipEnabled then
        MovementEnhancement.noClipEnabled = false
        EnableNoClip()
    end
    
    -- Re-enable spinner if it was enabled
    if MovementEnhancement.spinnerEnabled then
        MovementEnhancement.spinnerEnabled = false
        EnableAutoSpinner()
    end
end)

-- Network & Connection System
local NetworkManager = {
    autoReconnect = false,
    reconnectOnDisconnect = true,
    maxReconnectAttempts = 3,
    currentAttempts = 0,
    lastDisconnectTime = 0,
    reconnectDelay = 5
}

-- Enhancement System
local Enhancement = {
    enabled = false,
    autoActivateAltar = false,
    autoRollEnchant = false,
    maxRolls = 5,
    currentRolls = 0,
    isEnchanting = false,
    lastActivateTime = 0,
    cooldownTime = 2
}

-- Weather System
local Weather = {
    enabled = false,
    autoPurchase = false,
    weatherTypes = {
        "All", "Rain", "Storm", "Sunny", "Cloudy", "Fog", "Wind"
    },
    selectedWeather = "All",
    lastPurchaseTime = 0,
    cooldownTime = 5
}

-- Dashboard & Statistics System
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

-- Fish Rarity Categories (Updated from fishname.txt)
local FishRarity = {
    MYTHIC = {
        "Hawks Turtle", "Dotted Stingray", "Hammerhead Shark", "Manta Ray", 
        "Abyss Seahorse", "Blueflame Ray", "Prismy Seahorse", "Loggerhead Turtle"
    },
    LEGENDARY = {
        "Blue Lobster", "Greenbee Grouper", "Starjam Tang", "Yellowfin Tuna",
        "Chrome Tuna", "Magic Tang", "Enchanted Angelfish", "Lavafin Tuna", 
        "Lobster", "Bumblebee Grouper"
    },
    EPIC = {
        "Domino Damsel", "Panther Grouper", "Unicorn Tang", "Dorhey Tang",
        "Moorish Idol", "Cow Clownfish", "Astra Damsel", "Firecoal Damsel",
        "Longnose Butterfly", "Sushi Cardinal"
    },
    RARE = {
        "Scissortail Dartfish", "White Clownfish", "Darwin Clownfish", 
        "Korean Angelfish", "Candy Butterfly", "Jewel Tang", "Charmed Tang",
        "Kau Cardinal", "Fire Goby"
    },
    UNCOMMON = {
        "Maze Angelfish", "Tricolore Butterfly", "Flame Angelfish", 
        "Yello Damselfish", "Vintage Damsel", "Coal Tang", "Magma Goby",
        "Banded Butterfly", "Shrimp Goby"
    },
    COMMON = {
        "Orangy Goby", "Specked Butterfly", "Corazon Damse", "Copperband Butterfly",
        "Strawberry Dotty", "Azure Damsel", "Clownfish", "Skunk Tilefish",
        "Yellowstate Angelfish", "Vintage Blue Tang", "Ash Basslet", 
        "Volcanic Basslet", "Boa Angelfish", "Jennifer Dottyback", "Reef Chromis"
    }
}

-- Location mapping for heatmap
local LocationMap = {
    ["Kohana Volcano"] = {x = -594, z = 149},
    ["Crater Island"] = {x = 1010, z = 5078},
    ["Kohana"] = {x = -650, z = 711},
    ["Lost Isle"] = {x = -3618, z = -1317},
    ["Stingray Shores"] = {x = 45, z = 2987},
    ["Esoteric Depths"] = {x = 1944, z = 1371},
    ["Weather Machine"] = {x = -1488, z = 1876},
    ["Tropical Grove"] = {x = -2095, z = 3718},
    ["Coral Reefs"] = {x = -3023, z = 2195}
}

-- Statistics Functions
local function GetFishRarity(fishName)
    for rarity, fishList in pairs(FishRarity) do
        for _, fish in pairs(fishList) do
            if string.find(string.lower(fishName), string.lower(fish)) then
                return rarity
            end
        end
    end
    return "COMMON"
end

-- ====================================================================
-- DASHBOARD COUNTING SYSTEM
-- ====================================================================
-- LogFishCatch() - ONLY for real fish caught from game events
-- Smart/Secure mode simulations - Count separately without LogFishCatch
-- This prevents double counting when real fish events occur during automation
-- ====================================================================

local function LogFishCatch(fishName, location)
    local currentTime = tick()
    local rarity = GetFishRarity(fishName)
    
    -- Debug: Print to confirm function is called
    print("[Dashboard] Fish caught:", fishName, "Rarity:", rarity, "Location:", location or "Unknown")
    
    -- Log to main fish database
    table.insert(Dashboard.fishCaught, {
        name = fishName,
        rarity = rarity,
        location = location or Dashboard.sessionStats.currentLocation,
        timestamp = currentTime,
        hour = tonumber(os.date("%H", currentTime))
    })
    
    -- Log rare fish separately
    if rarity ~= "COMMON" then
        table.insert(Dashboard.rareFishCaught, {
            name = fishName,
            rarity = rarity,
            location = location or Dashboard.sessionStats.currentLocation,
            timestamp = currentTime
        })
        Dashboard.sessionStats.rareCount = Dashboard.sessionStats.rareCount + 1
    end
    
    -- Update location stats
    local loc = location or Dashboard.sessionStats.currentLocation
    if not Dashboard.locationStats[loc] then
        Dashboard.locationStats[loc] = {total = 0, rare = 0, common = 0, lastCatch = 0}
    end
    Dashboard.locationStats[loc].total = Dashboard.locationStats[loc].total + 1
    Dashboard.locationStats[loc].lastCatch = currentTime
    
    if rarity ~= "COMMON" then
        Dashboard.locationStats[loc].rare = Dashboard.locationStats[loc].rare + 1
    else
        Dashboard.locationStats[loc].common = Dashboard.locationStats[loc].common + 1
    end
    
    -- Update session stats (REAL FISH COUNT)
    Dashboard.sessionStats.fishCount = Dashboard.sessionStats.fishCount + 1
    print("[Real Fish] Count updated:", Dashboard.sessionStats.fishCount, "Fish:", fishName)
    
    -- Update heatmap data
    if LocationMap[loc] then
        local key = loc
        if not Dashboard.heatmap[key] then
            Dashboard.heatmap[key] = {count = 0, rare = 0, efficiency = 0}
        end
        Dashboard.heatmap[key].count = Dashboard.heatmap[key].count + 1
        if rarity ~= "COMMON" then
            Dashboard.heatmap[key].rare = Dashboard.heatmap[key].rare + 1
        end
        Dashboard.heatmap[key].efficiency = Dashboard.heatmap[key].rare / Dashboard.heatmap[key].count
    end
    
    -- Update optimal times
    local hour = tonumber(os.date("%H", currentTime))
    if not Dashboard.optimalTimes[hour] then
        Dashboard.optimalTimes[hour] = {total = 0, rare = 0}
    end
    Dashboard.optimalTimes[hour].total = Dashboard.optimalTimes[hour].total + 1
    if rarity ~= "COMMON" then
        Dashboard.optimalTimes[hour].rare = Dashboard.optimalTimes[hour].rare + 1
    end
end

-- Assign function to Dashboard for external access
Dashboard.LogFishCatch = LogFishCatch

-- Location detection based on player position
local function DetectCurrentLocation()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return "Unknown"
    end
    
    local pos = LocalPlayer.Character.HumanoidRootPart.Position
    
    -- Location detection based on position ranges (from logdebug.txt analysis)
    if pos.Z > 4500 then
        return "Crater Island"
    elseif pos.Z > 2500 then
        return "Stingray Shores"
    elseif pos.Z > 1500 then
        return "Esoteric Depths"
    elseif pos.Z > 700 then
        return "Kohana"
    elseif pos.Z > 3000 and pos.X < -2000 then
        return "Tropical Grove"
    elseif pos.Z > 1800 and pos.X < -3000 then
        return "Coral Reefs"
    elseif pos.X < -3500 then
        return "Lost Isle"
    elseif pos.X < -1400 and pos.Z > 1500 then
        return "Weather Machine"
    elseif pos.Z < 500 and pos.X < -500 then
        return "Kohana Volcano"
    else
        return "Unknown Area"
    end
end

-- Update current location every few seconds
local function LocationTracker()
    while true do
        local newLocation = DetectCurrentLocation()
        if newLocation ~= Dashboard.sessionStats.currentLocation then
            Dashboard.sessionStats.currentLocation = newLocation
            print("[Dashboard] Location changed to:", newLocation)
        end
        task.wait(3) -- Check every 3 seconds
    end
end

-- Animation tracking for realistic timing (AnimationMonitor sudah didefinisikan di atas)
local function MonitorCharacterAnimations()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then
        return
    end
    
    local humanoid = LocalPlayer.Character.Humanoid
    local animator = humanoid:FindFirstChild("Animator")
    if not animator then return end
    
    -- Track animation changes for fishing detection
    humanoid.AnimationPlayed:Connect(function(animationTrack)
        local animName = animationTrack.Animation.Name
        local currentTime = tick()
        
        -- Log fishing-related animations
        if string.find(animName, "Fish") or string.find(animName, "Rod") or string.find(animName, "Reel") or string.find(animName, "Caught") then
            print("[Animation] Detected:", animName, "at", math.floor(currentTime - AnimationMonitor.lastAnimationTime, 2), "seconds")
            
            table.insert(AnimationMonitor.animationSequence, {
                name = animName,
                timestamp = currentTime,
                duration = currentTime - AnimationMonitor.lastAnimationTime
            })
            
            -- Update fishing state based on animation
            if string.find(animName, "StartCharging") then
                AnimationMonitor.currentState = "charging"
            elseif string.find(animName, "Cast") then
                AnimationMonitor.currentState = "casting"
            elseif string.find(animName, "Reel") then
                AnimationMonitor.currentState = "reeling"
            elseif string.find(animName, "CaughtFish") or string.find(animName, "HoldFish") then
                AnimationMonitor.currentState = "caught"
                AnimationMonitor.fishingSuccess = true
                print("[Animation] FISH CAUGHT DETECTED via animation!")
            elseif string.find(animName, "Failure") then
                AnimationMonitor.currentState = "failed"
                AnimationMonitor.fishingSuccess = false
            end
            
            AnimationMonitor.lastAnimationTime = currentTime
        end
    end)
end

-- Smart timing based on animation patterns
local function GetRealisticTiming(phase)
    local timings = {
        charging = {min = 0.8, max = 1.5},    -- Rod charging time
        casting = {min = 0.2, max = 0.4},     -- Cast animation
        waiting = {min = 2.0, max = 4.0},     -- Wait for fish
        reeling = {min = 1.0, max = 2.5},     -- Reel animation
        holding = {min = 0.5, max = 1.0}      -- Hold fish animation
    }
    
    local timing = timings[phase] or {min = 0.5, max = 1.0}
    return timing.min + math.random() * (timing.max - timing.min)
end
local function SetupFishCaughtListener()
    if fishCaughtRemote and fishCaughtRemote:IsA("RemoteEvent") then
        fishCaughtRemote.OnClientEvent:Connect(function(fishData)
            -- Real fish caught event
            local fishName = "Unknown Fish"
            local location = DetectCurrentLocation()
            
            -- Extract fish name from various possible data formats
            if type(fishData) == "string" then
                fishName = fishData
            elseif type(fishData) == "table" then
                fishName = fishData.name or fishData.fishName or fishData.Fish or "Unknown Fish"
            end
            
            print("[Dashboard] Real fish caught via event:", fishName, "at", location)
            LogFishCatch(fishName, location)
        end)
        print("[Dashboard] FishCaught event listener setup successfully")
    else
        print("[Dashboard] Warning: FishCaught remote not found - using simulation mode")
    end
end

local function GetLocationEfficiency(location)
    local stats = Dashboard.locationStats[location]
    if not stats or stats.total == 0 then return 0 end
    return math.floor((stats.rare / stats.total) * 100)
end

local function GetBestFishingTime()
    local bestHour = 0
    local bestRatio = 0
    for hour, data in pairs(Dashboard.optimalTimes) do
        if data.total > 0 then
            local ratio = data.rare / data.total
            if ratio > bestRatio then
                bestRatio = ratio
                bestHour = hour
            end
        end
    end
    return bestHour, math.floor(bestRatio * 100)
end

local function GetLocationEfficiency(location)
    local stats = Dashboard.locationStats[location]
    if not stats or stats.total == 0 then return 0 end
    return math.floor((stats.rare / stats.total) * 100)
end

local function GetBestFishingTime()
    local bestHour = 0
    local bestRatio = 0
    for hour, data in pairs(Dashboard.optimalTimes) do
        if data.total > 5 then -- Minimum sample size
            local ratio = data.rare / data.total
            if ratio > bestRatio then
                bestRatio = ratio
                bestHour = hour
            end
        end
    end
    return bestHour, math.floor(bestRatio * 100)
end

-- AntiAFK System
local AntiAFK = {
    enabled = false,
    lastJumpTime = 0,
    nextJumpTime = 0,
    sessionId = 0
}

local function generateRandomJumpTime()
    -- Random time between 5-10 minutes (300-600 seconds)
    return math.random(100, 600)
end

local function performAntiAfkJump()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Jump = true
        local currentTime = tick()
        AntiAFK.lastJumpTime = currentTime
        AntiAFK.nextJumpTime = currentTime + generateRandomJumpTime()
        
        local nextJumpMinutes = math.floor((AntiAFK.nextJumpTime - currentTime) / 60)
        local nextJumpSeconds = math.floor((AntiAFK.nextJumpTime - currentTime) % 60)
        Notify("AntiAFK", string.format("Jump performed! Next jump in %dm %ds", nextJumpMinutes, nextJumpSeconds))
    end
end

local function AntiAfkRunner(mySessionId)
    AntiAFK.nextJumpTime = tick() + generateRandomJumpTime()
    Notify("AntiAFK", "AntiAFK system started")
    
    while AntiAFK.enabled and AntiAFK.sessionId == mySessionId do
        local currentTime = tick()
        
        if currentTime >= AntiAFK.nextJumpTime then
            performAntiAfkJump()
        end
        
        task.wait(1) -- Check every second
    end
    
    Notify("AntiAFK", "AntiAFK system stopped")
end

-- Enhancement Functions
local function TeleportToAltar()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Notify("Teleport", "❌ Character not found!")
        return false
    end
    
    local altarPosition = CFrame.new(3237.61, -1302.33, 1398.04)
    local success = pcall(function()
        LocalPlayer.Character.HumanoidRootPart.CFrame = altarPosition
    end)
    
    if success then
        Notify("Teleport", "✅ Teleported to Altar!")
        return true
    else
        Notify("Teleport", "❌ Teleport failed!")
        return false
    end
end

local function ActivateEnchantingAltar()
    if not Enhancement.enabled or not activateEnchantingAltarRemote then return false end
    
    local now = tick()
    if now - Enhancement.lastActivateTime < Enhancement.cooldownTime then return false end
    Enhancement.lastActivateTime = now
    
    local ok, res = pcall(function()
        activateEnchantingAltarRemote:FireServer()
        return true
    end)
    
    if ok then
        Notify("Enhancement", "🔮 Enchanting Altar activated")
        Enhancement.isEnchanting = true
        Enhancement.currentRolls = 0
        return true
    else
        Notify("Enhancement", "❌ Failed to activate altar: " .. tostring(res))
        return false
    end
end

local function RollEnchant()
    if not Enhancement.enabled or not rollEnchantRemote then return false end
    if not Enhancement.isEnchanting then return false end
    if Enhancement.currentRolls >= Enhancement.maxRolls then return false end
    
    local ok, res = pcall(function()
        rollEnchantRemote:FireServer()
        return true
    end)
    
    if ok then
        Enhancement.currentRolls = Enhancement.currentRolls + 1
        Notify("Enhancement", string.format("🎲 Enchant roll %d/%d", Enhancement.currentRolls, Enhancement.maxRolls))
        return true
    else
        Notify("Enhancement", "❌ Failed to roll enchant: " .. tostring(res))
        return false
    end
end

local function EnhancementRunner(mySessionId)
    Notify("Enhancement", "🔮 Auto Enhancement started")
    while Enhancement.enabled and Enhancement.sessionId == mySessionId do        
        local ok, err = pcall(function()
            if Enhancement.autoActivateAltar and not Enhancement.isEnchanting then
                ActivateEnchantingAltar()
                task.wait(1) -- Wait for altar activation
            end
            
            if Enhancement.autoRollEnchant and Enhancement.isEnchanting then
                if Enhancement.currentRolls < Enhancement.maxRolls then
                    RollEnchant()
                    task.wait(0.5 + math.random() * 0.5) -- Random delay between rolls
                else
                    Enhancement.isEnchanting = false
                    Enhancement.currentRolls = 0
                    task.wait(3) -- Wait before next altar activation
                end
            end
        end)
        
        if not ok then
            warn("Enhancement error:", err)
            task.wait(1)
        end
        
        task.wait(0.1)
    end
    Notify("Enhancement", "🔮 Auto Enhancement stopped")
end

-- Weather Functions
local function PurchaseWeatherEvent(weatherType)
    if not Weather.enabled or not purchaseWeatherEventRemote then return false end
    
    local now = tick()
    if now - Weather.lastPurchaseTime < Weather.cooldownTime then return false end
    Weather.lastPurchaseTime = now
    
    local ok, res = pcall(function()
        return purchaseWeatherEventRemote:InvokeServer(weatherType)
    end)
    
    if ok then
        Notify("Weather", "🌦️ Weather Event purchased: " .. weatherType)
        return true
    else
        Notify("Weather", "❌ Failed to purchase weather: " .. tostring(res))
        return false
    end
end

local function PurchaseAllWeatherEvents()
    if not Weather.enabled or not purchaseWeatherEventRemote then return false end
    
    local allWeatherTypes = {"Rain", "Storm", "Sunny", "Cloudy", "Fog", "Wind"}
    local successCount = 0
    local totalCount = #allWeatherTypes
    
    Notify("Weather", "🌈 Starting to purchase all weather types...")
    
    for i, weatherType in ipairs(allWeatherTypes) do
        local now = tick()
        if now - Weather.lastPurchaseTime >= Weather.cooldownTime then
            Weather.lastPurchaseTime = now
            
            local ok, res = pcall(function()
                return purchaseWeatherEventRemote:InvokeServer(weatherType)
            end)
            
            if ok then
                successCount = successCount + 1
                Notify("Weather", string.format("✅ %s purchased (%d/%d)", weatherType, successCount, totalCount))
            else
                Notify("Weather", string.format("❌ Failed to purchase %s: %s", weatherType, tostring(res)))
            end
            
            -- Wait between purchases to avoid rate limiting
            if i < totalCount then
                task.wait(Weather.cooldownTime + 0.5)
            end
        else
            task.wait(Weather.cooldownTime)
            i = i - 1 -- Retry this weather type
        end
    end
    
    Notify("Weather", string.format("🌈 All weather purchase completed! Success: %d/%d", successCount, totalCount))
    return successCount == totalCount
end

local function WeatherRunner(mySessionId)
    Notify("Weather", "🌦️ Auto Weather started")
    while Weather.enabled and Weather.sessionId == mySessionId do
        local ok, err = pcall(function()
            if Weather.autoPurchase then
                if Weather.selectedWeather == "All" then
                    PurchaseAllWeatherEvents()
                    task.wait(60) -- Wait 1 minute after purchasing all weather types
                else
                    PurchaseWeatherEvent(Weather.selectedWeather)
                    task.wait(10) -- Wait 10 seconds between single purchases
                end
            end
        end)
        
        if not ok then
            warn("Weather error:", err)
            task.wait(1)
        end
        
        task.wait(0.1)
    end
    Notify("Weather", "🌦️ Auto Weather stopped")
end

-- Enhancement event listeners
if updateEnchantStateRemote then
    updateEnchantStateRemote.OnClientEvent:Connect(function(state)
        if state then
            Enhancement.isEnchanting = state.isEnchanting or false
            Enhancement.currentRolls = state.currentRolls or 0
            print("[Enhancement] State updated:", state)
        end
    end)
end

-- ====================================================================
-- AUTO SELL SYSTEM VARIABLES
-- ====================================================================
local AutoSell = {
    enabled = false,
    threshold = 50, -- Default threshold
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
    sellCooldown = 5, -- 5 seconds cooldown between sells
    -- NEW: Server sync variables
    serverThreshold = 50, -- Server-side threshold
    lastSyncTime = 0,
    syncCooldown = 2, -- 2 seconds between sync attempts
    isThresholdSynced = false,
    syncRetries = 0,
    maxSyncRetries = 3
}
-- ====================================================================

local Security = { actionsThisMinute = 0, lastMinuteReset = tick(), isInCooldown = false, suspicion = 0 }
local sessionId = 0
local autoModeSessionId = 0 -- New session ID for Auto Mode

-- New: Auto Mode Runner
local function AutoModeRunner(mySessionId)
    Notify("Auto Mode", "🔥 Auto Mode Started! Looping FishingCompleted.")
    while Config.autoModeEnabled and autoModeSessionId == mySessionId do
        if finishRemote then
            pcall(function()
                finishRemote:FireServer()
            end)
        else
            warn("Auto Mode: finishRemote not found!")
            Config.autoModeEnabled = false -- Stop if remote is missing
            break
        end
        task.wait(1) -- Wait for 1 second
    end
    if autoModeSessionId == mySessionId then -- Only notify if it's the same session stopping
        Notify("Auto Mode", "🔥 Auto Mode Stopped.")
    end
end


-- ====================================================================
-- AUTO SELL FUNCTIONS
-- ====================================================================

-- NEW: Server Sync Functions
local function SyncAutoSellThresholdWithServer(newThreshold)
    local now = tick()
    if now - AutoSell.lastSyncTime < AutoSell.syncCooldown then
        return false, "sync_cooldown"
    end
    
    local updateThresholdRemote = ResolveRemote("RF/UpdateAutoSellThreshold")
    if not updateThresholdRemote then
        return false, "remote_not_found"
    end
    
    AutoSell.lastSyncTime = now
    
    local success, result = pcall(function()
        return updateThresholdRemote:InvokeServer(newThreshold)
    end)
    
    if success then
        AutoSell.serverThreshold = newThreshold
        AutoSell.isThresholdSynced = true
        AutoSell.syncRetries = 0
        Notify("Auto Sell Sync", string.format("✅ Threshold synced with server: %d", newThreshold))
        return true, result
    else
        AutoSell.syncRetries = AutoSell.syncRetries + 1
        AutoSell.isThresholdSynced = false
        Notify("Auto Sell Sync", string.format("❌ Sync failed (Attempt %d/%d): %s", AutoSell.syncRetries, AutoSell.maxSyncRetries, tostring(result)))
        
        -- Retry logic
        if AutoSell.syncRetries < AutoSell.maxSyncRetries then
            task.spawn(function()
                task.wait(AutoSell.syncCooldown * 2) -- Wait longer for retry
                SyncAutoSellThresholdWithServer(newThreshold)
            end)
        end
        
        return false, result
    end
end

local function GetServerAutoSellThreshold()
    local updateThresholdRemote = ResolveRemote("RF/UpdateAutoSellThreshold")
    if not updateThresholdRemote then
        return nil, "remote_not_found"
    end
    
    local success, result = pcall(function()
        -- Try to get current server threshold (pass nil or 0 to query)
        return updateThresholdRemote:InvokeServer(0)
    end)
    
    if success and type(result) == "number" and result > 0 then
        AutoSell.serverThreshold = result
        return result, "success"
    else
        return nil, result
    end
end

local function InitializeAutoSellSync()
    -- Try to get server threshold on initialization
    task.spawn(function()
        task.wait(2) -- Wait for game to fully load
        
        local serverThreshold, err = GetServerAutoSellThreshold()
        if serverThreshold then
            AutoSell.threshold = serverThreshold
            AutoSell.serverThreshold = serverThreshold
            AutoSell.isThresholdSynced = true
            Notify("Auto Sell Sync", string.format("📥 Retrieved server threshold: %d", serverThreshold))
        else
            Notify("Auto Sell Sync", "⚠️ Could not retrieve server threshold, using local: " .. AutoSell.threshold)
            -- Try to sync current local threshold with server
            SyncAutoSellThresholdWithServer(AutoSell.threshold)
        end
    end)
end

local function GetTotalFishForSell()
    local total = 0
    for rarity, count in pairs(AutoSell.sellCount) do
        if AutoSell.allowedRarities[rarity] then
            total = total + count
        end
    end
    return total
end

local function ResetSellCounts()
    for rarity, _ in pairs(AutoSell.sellCount) do
        AutoSell.sellCount[rarity] = 0
    end
end

local function ShouldSellFish(rarity)
    return AutoSell.allowedRarities[rarity] or false
end

local function CheckAndAutoSell()
    if not AutoSell.enabled or AutoSell.isCurrentlySelling then
        return
    end
    
    local totalFishToSell = GetTotalFishForSell()
    if totalFishToSell < AutoSell.threshold then
        return
    end
    
    -- Check cooldown
    local now = tick()
    if now - AutoSell.lastSellTime < AutoSell.sellCooldown then
        return
    end
    
    AutoSell.isCurrentlySelling = true
    AutoSell.lastSellTime = now
    
    pcall(function()
        if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then 
            AutoSell.isCurrentlySelling = false
            return 
        end

        -- Save original position
        local originalCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        
        -- Try to find NPC or use fallback coordinates
        local sellNpc = nil
        local npcContainer = ReplicatedStorage:FindFirstChild("NPC")
        if npcContainer then
            sellNpc = npcContainer:FindFirstChild("Alex") or npcContainer:FindFirstChild("Shop")
        end

        -- Teleport to seller
        if sellNpc and sellNpc.WorldPivot then
            LocalPlayer.Character.HumanoidRootPart.CFrame = sellNpc.WorldPivot
        else
            -- Fallback coordinates for shop
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-31.10, 4.84, 2899.03)
        end

        Notify("Auto Sell", string.format("🚀 Auto selling %d fish (Threshold: %d)", totalFishToSell, AutoSell.threshold))
        task.wait(1.5)

        -- Execute sell
        local sellRemote = ResolveRemote("RF/SellAllItems")
        if sellRemote then
            local success = pcall(function()
                if sellRemote:IsA("RemoteFunction") then 
                    return sellRemote:InvokeServer() 
                else 
                    sellRemote:FireServer() 
                end
            end)
            
            if success then
                Notify("Auto Sell", "✅ Auto sell successful!")
                ResetSellCounts()
            else
                Notify("Auto Sell", "❌ Auto sell failed!")
            end
        else
            Notify("Auto Sell", "❌ Sell remote not found!")
        end

        task.wait(1.5)

        -- Return to original position
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = originalCFrame
        end
        
        Notify("Auto Sell", "🏠 Returned to fishing spot")
        AutoSell.isCurrentlySelling = false
    end)
end

-- Update LogFishCatch to include AutoSell tracking
local originalLogFishCatch = LogFishCatch
LogFishCatch = function(fishName, location)
    -- Call original function
    originalLogFishCatch(fishName, location)
    
    -- Add to AutoSell tracking
    if AutoSell.enabled then
        local rarity = GetFishRarity(fishName)
        if AutoSell.sellCount[rarity] then
            AutoSell.sellCount[rarity] = AutoSell.sellCount[rarity] + 1
        end
        
        -- Check if we should auto sell
        CheckAndAutoSell()
    end
end
-- ====================================================================

local function inCooldown()
    local now = tick()
    if now - Security.lastMinuteReset > 60 then
        Security.actionsThisMinute = 0
        Security.lastMinuteReset = now
    end
    if Security.actionsThisMinute >= Config.secure_max_actions_per_minute then
        Security.isInCooldown = true
        return true
    end
    return Security.isInCooldown
end

local function secureInvoke(remote, ...)
    if inCooldown() then return false, "cooldown" end
    Security.actionsThisMinute = Security.actionsThisMinute + 1
    task.wait(0.01 + math.random() * 0.05)
    local ok, res = safeInvoke(remote, ...)
    if not ok then
        Security.suspicion = Security.suspicion + 1
        if Security.suspicion > 8 then
            Security.isInCooldown = true
            task.spawn(function()
                Notify("modern_autofish", "Entering cooldown due to repeated errors")
                task.wait(Config.secure_detection_cooldown)
                Security.suspicion = 0
                Security.isInCooldown = false
            end)
        end
    end
    return ok, res
end

local function GetServerTime()
    local ok, st = pcall(function() return workspace:GetServerTimeNow() end)
    if ok and type(st) == "number" then return st end
    return tick()
end

-- Enhanced Smart Fishing Cycle with Animation Awareness
local function DoSmartCycle()
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
    local timestamp = usePerfect and GetServerTime() or GetServerTime() + math.random()*0.5
    
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
    
    -- Check if fish was caught via animation or simulate
    if not AnimationMonitor.fishingSuccess and not fishCaughtRemote then
        -- Fallback: Use location-based simulation
        local fishByLocation = {
            ["Coral Reefs"] = {"Hawks Turtle", "Blue Lobster", "Greenbee Grouper", "Starjam Tang", "Domino Damsel", "Panther Grouper", "Scissortail Dartfish", "White Clownfish", "Maze Angelfish", "Tricolore Butterfly", "Orangy Goby", "Specked Butterfly", "Corazon Damse"},
            ["Stingray Shores"] = {"Dotted Stingray", "Yellowfin Tuna", "Unicorn Tang", "Dorhey Tang", "Darwin Clownfish", "Korean Angelfish", "Flame Angelfish", "Yello Damselfish", "Copperband Butterfly", "Strawberry Dotty", "Azure Damsel", "Clownfish"},
            ["Ocean"] = {"Hammerhead Shark", "Manta Ray", "Chrome Tuna", "Moorish Idol", "Cow Clownfish", "Candy Butterfly", "Jewel Tang", "Vintage Damsel", "Tricolore Butterfly", "Skunk Tilefish", "Yellowstate Angelfish", "Vintage Blue Tang"},
            ["Esoteric Depths"] = {"Abyss Seahorse", "Magic Tang", "Enchanted Angelfish", "Astra Damsel", "Charmed Tang", "Coal Tang", "Ash Basslet"},
            ["Kohana Volcano"] = {"Blueflame Ray", "Lavafin Tuna", "Firecoal Damsel", "Magma Goby", "Volcanic Basslet"},
            ["Kohana"] = {"Prismy Seahorse", "Loggerhead Turtle", "Lobster", "Bumblebee Grouper", "Longnose Butterfly", "Sushi Cardinal", "Kau Cardinal", "Fire Goby", "Banded Butterfly", "Shrimp Goby", "Boa Angelfish", "Jennifer Dottyback", "Reef Chromis"}
        }
        
        local currentLocation = DetectCurrentLocation()
        local locationFish = fishByLocation[currentLocation] or fishByLocation["Ocean"]
        local randomFish = locationFish[math.random(1, #locationFish)]
        -- Removed LogFishCatch - only count simulated stats, not actual fish logs
        print("[Smart Cycle] Simulated catch:", randomFish, "at", currentLocation)
    end
    
    AnimationMonitor.currentState = "idle"
end

local function DoSecureCycle()
    if inCooldown() then task.wait(1); return end
    
    -- Equip rod first
    if equipRemote then 
        local ok = pcall(function() equipRemote:FireServer(1) end)
        if not ok then print("[Secure Mode] Failed to equip") end
    end
    
    -- Safe mode logic: random between perfect and normal cast
    local usePerfect = math.random(1,100) <= Config.safeModeChance
    
    -- Charge rod with proper timing
    local timestamp = usePerfect and 9999999999 or (tick() + math.random())
    if rodRemote then
        local ok = pcall(function() rodRemote:InvokeServer(timestamp) end)
        if not ok then print("[Secure Mode] Failed to charge") end
    end
    
    task.wait(0.1) -- Standard charge wait
    
    -- Minigame with safe mode values
    local x = usePerfect and -1.238 or (math.random(-1000,1000)/1000)
    local y = usePerfect and 0.969 or (math.random(0,1000)/1000)
    
    if miniGameRemote then
        local ok = pcall(function() miniGameRemote:InvokeServer(x, y) end)
        if not ok then print("[Secure Mode] Failed minigame") end
    end
    
    task.wait(1.3) -- Standard fishing wait
    
    -- Complete fishing
    if finishRemote then 
        local ok = pcall(function() finishRemote:FireServer() end)
        if not ok then print("[Secure Mode] Failed to finish") end
    end
    
    -- Real fish simulation for dashboard  
    local fishByLocation = {
        ["Ocean"] = {"Hammerhead Shark", "Manta Ray", "Chrome Tuna", "Moorish Idol", "Cow Clownfish", "Candy Butterfly", "Jewel Tang", "Vintage Damsel", "Tricolore Butterfly", "Skunk Tilefish", "Yellowstate Angelfish", "Vintage Blue Tang"}
    }
    
    local currentLocation = Dashboard.sessionStats.currentLocation
    local locationFish = fishByLocation[currentLocation] or fishByLocation["Ocean"]
    local randomFish = locationFish[math.random(1, #locationFish)]
    -- Removed LogFishCatch - only for real fish, not simulated
end

local function smartFastLogic()
    -- Smart fishing logic for fast mode
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    -- Check if we're in a good state for fishing
    if humanoid.Health < 30 then
        return false -- Skip if low health
    end
    
    -- Random chance to skip for more natural behavior (10% chance)
    if math.random(1, 10) == 1 then
        return false
    end
    
    return true
end

local function calculateFastRarity()
    local roll = math.random()
    
    if roll <= 0.001 then -- 0.1% for mythical
        return "Mythical", Color3.fromRGB(255, 0, 255)
    elseif roll <= 0.01 then -- 1% for legendary  
        return "Legendary", Color3.fromRGB(255, 215, 0)
    elseif roll <= 0.05 then -- 5% for rare
        return "Rare", Color3.fromRGB(128, 0, 255)
    elseif roll <= 0.15 then -- 15% for uncommon
        return "Uncommon", Color3.fromRGB(0, 255, 0)
    else
        return "Common", Color3.fromRGB(255, 255, 255)
    end
end

local function simulateFastFishValue(rarity)
    local baseValues = {
        Common = {min = 10, max = 50},
        Uncommon = {min = 40, max = 120},
        Rare = {min = 100, max = 300},
        Legendary = {min = 250, max = 800},
        Mythical = {min = 500, max = 2000}
    }
    
    local range = baseValues[rarity]
    if range then
        return math.random(range.min, range.max)
    end
    return 25
end

local function DoFastCycle()
    if inCooldown() then task.wait(0.3); return end
    
    -- Enhanced Fast mode with old.lua style safety and smart features
    
    -- Safety check - stop if player is in danger
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health < 20 then
            warn("⚠️ [Fast Mode] Low health detected! Stopping for safety.")
            task.wait(3)
            return
        end
    end
    
    -- Smart fishing check
    if not smartFastLogic() then
        task.wait(getFastDelay() * 3) -- Wait longer during bad conditions
        return
    end
    
    -- Add random delays to avoid detection (fast but still random)
    task.wait(getFastDelay())
    
    -- Check if rod is equipped, if not equip it
    if character then
        local equippedTool = character:FindFirstChildOfClass("Tool")
        if not equippedTool then
            -- Cancel any existing fishing first
            if cancelRemote then
                pcall(function() cancelRemote:InvokeServer() end)
            end
            task.wait(getFastDelay())
            
            -- Equip rod
            if equipRemote then
                local ok = pcall(function() equipRemote:FireServer(1) end)
                if not ok then 
                    warn("[Fast Mode] Failed to equip rod")
                    return
                end
            end
            task.wait(getFastDelay() * 2) -- Wait for equip
        end
    end
    
    -- Random delay before charging
    task.wait(getFastDelay())
    
    -- Fast charge with server time
    if rodRemote then
        local ok = pcall(function() rodRemote:InvokeServer(workspace:GetServerTimeNow()) end)
        if not ok then 
            warn("[Fast Mode] Failed to charge rod")
            return
        end
    end
    
    -- Quick charge wait with randomness
    task.wait(getFastDelay() + 0.05)
    
    -- Cast with slight variations for natural behavior
    if miniGameRemote then
        local baseX = -1.2379989624023438
        local baseY = 0.9800224985802423
        
        -- Add small random variations to cast values (still very accurate)
        local varX = baseX + (math.random(-5, 5) / 10000)
        local varY = baseY + (math.random(-5, 5) / 10000)
        
        local ok = pcall(function() miniGameRemote:InvokeServer(varX, varY) end)
        if not ok then 
            warn("[Fast Mode] Failed minigame")
            return
        end
    end
    
    -- Fast fishing wait with small randomness
    task.wait(0.3 + getFastDelay())
    
    -- Complete fishing
    if finishRemote then
        local ok = pcall(function() finishRemote:FireServer() end)
        if not ok then 
            warn("[Fast Mode] Failed to finish")
            return
        end
    end
    
    -- Enhanced fish simulation with rarity system
    local rarity, color = calculateFastRarity()
    local fishValue = simulateFastFishValue(rarity)
    
    -- Safety check untuk dashboard stats
    if not Dashboard.sessionStats.totalValue then
        Dashboard.sessionStats.totalValue = 0
    end
    
    -- Update dashboard stats (SIMULATION ONLY - real fish handled by LogFishCatch)
    Dashboard.sessionStats.fishCount = Dashboard.sessionStats.fishCount + 1
    Dashboard.sessionStats.totalValue = Dashboard.sessionStats.totalValue + (fishValue or 0)
    print("[Fast Mode] Simulated fish count +1, Total:", Dashboard.sessionStats.fishCount)
    
    if rarity == "Rare" or rarity == "Legendary" or rarity == "Mythical" then
        Dashboard.sessionStats.rareCount = Dashboard.sessionStats.rareCount + 1
    end
    
    -- Show notification for rare fish
    if rarity ~= "Common" then
        Notify("Fast Mode", "🎣 Caught " .. rarity .. " fish! (₡" .. fishValue .. ")")
    end
    
    -- Real fish simulation for dashboard with enhanced variety
    local fishByLocation = {
        ["Ocean"] = {"Hammerhead Shark", "Manta Ray", "Chrome Tuna", "Moorish Idol", "Cow Clownfish", "Candy Butterfly", "Jewel Tang", "Vintage Damsel", "Tricolore Butterfly", "Skunk Tilefish", "Yellowstate Angelfish", "Vintage Blue Tang"},
        ["Lake"] = {"Bass", "Trout", "Pike", "Catfish", "Perch", "Carp"},
        ["River"] = {"Salmon", "Rainbow Trout", "Grayling", "Barbel", "Dace"},
        ["Pond"] = {"Goldfish", "Koi", "Bluegill", "Sunfish"}
    }
    
    -- Only simulate fish data for display, but don't call LogFishCatch 
    -- (that's only for real fish from game events)
    local currentLocation = Dashboard.sessionStats.currentLocation
    local locationFish = fishByLocation[currentLocation] or fishByLocation["Ocean"]
    local randomFish = locationFish[math.random(1, #locationFish)]
    
    -- Add simulated fish to recent catches list for display (without logging)
    print("[Fast Mode] Simulated fish:", randomFish, "at", currentLocation)
    
    -- Small delay at end of cycle for natural timing
    task.wait(getFastDelay())
end

local function AutofishRunner(mySession)
    Dashboard.sessionStats.startTime = tick()
    Dashboard.sessionStats.fishCount = 0
    Dashboard.sessionStats.rareCount = 0
    Dashboard.sessionStats.totalValue = 0  -- Initialize totalValue
    
    -- Start animation monitoring
    AnimationMonitor.isMonitoring = true
    MonitorCharacterAnimations()
    
    -- Auto-fix rod orientation at start
    FixRodOrientation()
    
    Notify("modern_autofish", "Smart AutoFishing started (mode: " .. Config.mode .. ")")
    while Config.enabled and sessionId == mySession do
        local ok, err = pcall(function()
            -- Fix rod orientation before each cycle
            FixRodOrientation()
            
            if Config.mode == "secure" then 
                DoSecureCycle() 
            else 
                DoSmartCycle() -- Default to smart mode
            end
        end)
        if not ok then
            warn("modern_autofish: cycle error:", err)
            Notify("modern_autofish", "Cycle error: " .. tostring(err))
            task.wait(0.4 + math.random()*0.5)
        end
        
        -- Smart delay based on mode
        local baseDelay = Config.autoRecastDelay
        local delay = baseDelay
        
        -- Mode-specific delays
        if Config.mode == "secure" then
            delay = 0.6 + math.random()*0.4 -- Variable delay for secure mode
        else
            -- Smart mode with animation-based timing
            local smartDelay = baseDelay + GetRealisticTiming("waiting") * 0.3
            delay = smartDelay + (math.random()*0.2 - 0.1)
        end
        
        if delay < 0.15 then delay = 0.15 end -- Minimum delay
        
        local elapsed = 0
        while elapsed < delay do
            if not Config.enabled or sessionId ~= mySession then break end
            task.wait(0.05)
            elapsed = elapsed + 0.05
        end
    end
    
    AnimationMonitor.isMonitoring = false
    Notify("modern_autofish", "Smart AutoFishing stopped")
end

-- UI builder
local function BuildUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModernAutoFishUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(0, 480, 0, 380)
    panel.Position = UDim2.new(0, 18, 0, 70)
    panel.BackgroundColor3 = Color3.fromRGB(28,28,34)
    panel.BorderSizePixel = 0
    panel.Parent = screenGui
    Instance.new("UICorner", panel)
    local stroke = Instance.new("UIStroke", panel); stroke.Thickness = 1; stroke.Color = Color3.fromRGB(40,40,48)

    -- header (drag)
    local header = Instance.new("Frame", panel)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Active = true; header.Selectable = true

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = "🐳Spinner_xxx AutoFish"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(235,235,235)
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Button container with responsive padding (expanded for reload button)
    local btnContainer = Instance.new("Frame", header)
    btnContainer.Size = UDim2.new(0, 120, 1, 0)  -- Increased width for 3 buttons
    -- place container near right edge but keep a small margin so it's not flush
    btnContainer.Position = UDim2.new(1, -125, 0, 0)  -- Adjusted position
    btnContainer.BackgroundTransparency = 1

    -- Minimize: keep a small left padding inside container so it isn't flush
    local minimizeBtn = Instance.new("TextButton", btnContainer)
    minimizeBtn.Size = UDim2.new(0, 32, 0, 26)
    minimizeBtn.Position = UDim2.new(0, 4, 0.5, -13)
    minimizeBtn.Text = "−"
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 16
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(60,60,66); minimizeBtn.TextColor3 = Color3.fromRGB(230,230,230)
    Instance.new("UICorner", minimizeBtn)

    -- Reload/Rejoin Button: positioned between minimize and close
    local reloadBtn = Instance.new("TextButton", btnContainer)
    reloadBtn.Size = UDim2.new(0, 32, 0, 26)
    reloadBtn.Position = UDim2.new(0, 42, 0.5, -13)  -- Middle position
    reloadBtn.Text = "🔄"
    reloadBtn.Font = Enum.Font.GothamBold
    reloadBtn.TextSize = 14
    reloadBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)  -- Blue color
    reloadBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", reloadBtn)
    
    -- Reload button functionality
    reloadBtn.MouseButton1Click:Connect(function()
        -- Show confirmation and reload
        Notify("🔄 Reloading...", "Restarting script in 2 seconds...")
        task.wait(2)
        
        -- Clean shutdown of all systems
        Config.enabled = false
        sessionId = sessionId + 1
        Config.autoModeEnabled = false
        autoModeSessionId = autoModeSessionId + 1
        
        -- Stop Anti-AFK system
        if AntiAFK then
            AntiAFK.enabled = false
            AntiAFK.sessionId = (AntiAFK.sessionId or 0) + 1
        end
        
        -- Stop Enhancement system
        if Enhancement then
            Enhancement.enabled = false
            Enhancement.sessionId = (Enhancement.sessionId or 0) + 1
        end
        
        -- Stop Weather system
        if Weather then
            Weather.enabled = false
            Weather.sessionId = (Weather.sessionId or 0) + 1
        end
        
        -- Send fishing stopped signal to server if exists
        if fishingStoppedRemote then
            pcall(function() fishingStoppedRemote:FireServer() end)
        end
        
        -- Auto unequip rod when reloading
        if AutoUnequipRod then
            pcall(function() AutoUnequipRod() end)
        end
        
        -- Destroy UI
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
        
        -- Small delay before rejoin
        task.wait(0.5)
        
        -- Show final notification
        Notify("🔄 Rejoining...", "Joining server now...")
        
        -- Rejoin server
        local TeleportService = game:GetService("TeleportService")
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end)
    
    -- Hover effect for reload button
    reloadBtn.MouseEnter:Connect(function()
        reloadBtn.BackgroundColor3 = Color3.fromRGB(90, 150, 220)
    end)
    reloadBtn.MouseLeave:Connect(function()
        reloadBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    end)

    -- Close: anchored to right of container with right padding
    local closeBtn = Instance.new("TextButton", btnContainer)
    closeBtn.Size = UDim2.new(0, 32, 0, 26)
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.Position = UDim2.new(1, -4, 0.5, -13)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.BackgroundColor3 = Color3.fromRGB(160,60,60); closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", closeBtn)

    -- drag logic (with viewport clamping)
    local dragging = false; local dragStart = Vector2.new(0,0); local startPos = Vector2.new(0,0); local dragInput
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
            dragging = true; dragStart = input.Position; startPos = panel.AbsolutePosition; dragInput = input
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    header.InputChanged:Connect(function(input) if input == dragInput and dragging then updateDrag(input) end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then updateDrag(input) end end)

    -- Left sidebar for tabs
    local sidebar = Instance.new("Frame", panel)
    sidebar.Size = UDim2.new(0, 120, 1, -50)
    sidebar.Position = UDim2.new(0, 10, 0, 45)
    sidebar.BackgroundColor3 = Color3.fromRGB(22,22,28)
    sidebar.BorderSizePixel = 0
    Instance.new("UICorner", sidebar)

    -- Tab buttons in sidebar
    local fishingAITabBtn = Instance.new("TextButton", sidebar)
    fishingAITabBtn.Size = UDim2.new(1, -10, 0, 40)
    fishingAITabBtn.Position = UDim2.new(0, 5, 0, 10)
    fishingAITabBtn.Text = "🤖 Fishing AI"
    fishingAITabBtn.Font = Enum.Font.GothamSemibold
    fishingAITabBtn.TextSize = 14
    fishingAITabBtn.BackgroundColor3 = Color3.fromRGB(45,45,50)
    fishingAITabBtn.TextColor3 = Color3.fromRGB(235,235,235)
    fishingAITabBtn.TextXAlignment = Enum.TextXAlignment.Left
    local fishingAITabCorner = Instance.new("UICorner", fishingAITabBtn)
    fishingAITabCorner.CornerRadius = UDim.new(0, 6)
    local fishingAITabPadding = Instance.new("UIPadding", fishingAITabBtn)
    fishingAITabPadding.PaddingLeft = UDim.new(0, 10)

    local teleportTabBtn = Instance.new("TextButton", sidebar)
    teleportTabBtn.Size = UDim2.new(1, -10, 0, 40)
    teleportTabBtn.Position = UDim2.new(0, 5, 0, 60)
    teleportTabBtn.Text = "🌍 Teleport"
    teleportTabBtn.Font = Enum.Font.GothamSemibold
    teleportTabBtn.TextSize = 14
    teleportTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
    teleportTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
    teleportTabBtn.TextXAlignment = Enum.TextXAlignment.Left
    local teleportTabCorner = Instance.new("UICorner", teleportTabBtn)
    teleportTabCorner.CornerRadius = UDim.new(0, 6)
    local teleportTabPadding = Instance.new("UIPadding", teleportTabBtn)
    teleportTabPadding.PaddingLeft = UDim.new(0, 10)

    local playerTabBtn = Instance.new("TextButton", sidebar)
    playerTabBtn.Size = UDim2.new(1, -10, 0, 40)
    playerTabBtn.Position = UDim2.new(0, 5, 0, 110)
    playerTabBtn.Text = "👥 Player"
    playerTabBtn.Font = Enum.Font.GothamSemibold
    playerTabBtn.TextSize = 14
    playerTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
    playerTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
    playerTabBtn.TextXAlignment = Enum.TextXAlignment.Left
    local playerTabCorner = Instance.new("UICorner", playerTabBtn)
    playerTabCorner.CornerRadius = UDim.new(0, 6)
    local playerTabPadding = Instance.new("UIPadding", playerTabBtn)
    playerTabPadding.PaddingLeft = UDim.new(0, 10)

    local featureTabBtn = Instance.new("TextButton", sidebar)
    featureTabBtn.Size = UDim2.new(1, -10, 0, 40)
    featureTabBtn.Position = UDim2.new(0, 5, 0, 160)
    featureTabBtn.Text = "⚡ Fitur"
    featureTabBtn.Font = Enum.Font.GothamSemibold
    featureTabBtn.TextSize = 14
    featureTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
    featureTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
    featureTabBtn.TextXAlignment = Enum.TextXAlignment.Left
    local featureTabCorner = Instance.new("UICorner", featureTabBtn)
    featureTabCorner.CornerRadius = UDim.new(0, 6)
    local featureTabPadding = Instance.new("UIPadding", featureTabBtn)
    featureTabPadding.PaddingLeft = UDim.new(0, 10)

    local dashboardTabBtn = Instance.new("TextButton", sidebar)
    dashboardTabBtn.Size = UDim2.new(1, -10, 0, 40)
    dashboardTabBtn.Position = UDim2.new(0, 5, 0, 210)
    dashboardTabBtn.Text = "📊 Dashboard"
    dashboardTabBtn.Font = Enum.Font.GothamSemibold
    dashboardTabBtn.TextSize = 14
    dashboardTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
    dashboardTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
    dashboardTabBtn.TextXAlignment = Enum.TextXAlignment.Left
    local dashboardTabCorner = Instance.new("UICorner", dashboardTabBtn)
    dashboardTabCorner.CornerRadius = UDim.new(0, 6)
    local dashboardTabPadding = Instance.new("UIPadding", dashboardTabBtn)
    dashboardTabPadding.PaddingLeft = UDim.new(0, 10)

    -- Content area on the right
    local contentContainer = Instance.new("Frame", panel)
    contentContainer.Size = UDim2.new(1, -145, 1, -50)
    contentContainer.Position = UDim2.new(0, 140, 0, 45)
    contentContainer.BackgroundTransparency = 1

    -- Fishing AI Tab Content (Now the main content)
    local fishingAIFrame = Instance.new("Frame", contentContainer)
    fishingAIFrame.Size = UDim2.new(1, 0, 1, -85)
    fishingAIFrame.Position = UDim2.new(0, 0, 0, 0)
    fishingAIFrame.BackgroundTransparency = 1

    -- Title for current tab
    local contentTitle = Instance.new("TextLabel", fishingAIFrame)
    contentTitle.Size = UDim2.new(1, 0, 0, 24)
    contentTitle.Text = "Smart AI Fishing Configuration"
    contentTitle.Font = Enum.Font.GothamBold
    contentTitle.TextSize = 16
    contentTitle.TextColor3 = Color3.fromRGB(235,235,235)
    contentTitle.BackgroundTransparency = 1
    contentTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Create scrollable frame for Fishing AI content
    local fishingAIScrollFrame = Instance.new("ScrollingFrame", fishingAIFrame)
    fishingAIScrollFrame.Size = UDim2.new(1, 0, 1, -30)
    fishingAIScrollFrame.Position = UDim2.new(0, 0, 0, 30)
    fishingAIScrollFrame.BackgroundColor3 = Color3.fromRGB(35,35,42)
    fishingAIScrollFrame.BorderSizePixel = 0
    fishingAIScrollFrame.ScrollBarThickness = 6
    fishingAIScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80,80,80)
    Instance.new("UICorner", fishingAIScrollFrame)

    -- Secure Mode Section (moved from Main tab)
    local secureModeSection = Instance.new("Frame", fishingAIScrollFrame)
    secureModeSection.Size = UDim2.new(1, -10, 0, 120)
    secureModeSection.Position = UDim2.new(0, 5, 0, 5)
    secureModeSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    secureModeSection.BorderSizePixel = 0
    Instance.new("UICorner", secureModeSection)

    local secureModeLabel = Instance.new("TextLabel", secureModeSection)
    secureModeLabel.Size = UDim2.new(1, -20, 0, 25)
    secureModeLabel.Position = UDim2.new(0, 10, 0, 5)
    secureModeLabel.Text = "🔒 Secure Fishing Mode"
    secureModeLabel.Font = Enum.Font.GothamBold
    secureModeLabel.TextSize = 14
    secureModeLabel.TextColor3 = Color3.fromRGB(100,255,150)
    secureModeLabel.BackgroundTransparency = 1
    secureModeLabel.TextXAlignment = Enum.TextXAlignment.Left

    local secureButton = Instance.new("TextButton", secureModeSection)
    secureButton.Size = UDim2.new(0.48, -5, 0, 35)
    secureButton.Position = UDim2.new(0, 10, 0, 35)
    secureButton.Text = "🔒 Start Secure"
    secureButton.Font = Enum.Font.GothamSemibold
    secureButton.TextSize = 12
    secureButton.BackgroundColor3 = Color3.fromRGB(74,155,88)
    secureButton.TextColor3 = Color3.fromRGB(255,255,255)
    local secureCorner = Instance.new("UICorner", secureButton)
    secureCorner.CornerRadius = UDim.new(0,6)

    local secureStopButton = Instance.new("TextButton", secureModeSection)
    secureStopButton.Size = UDim2.new(0.48, -5, 0, 35)
    secureStopButton.Position = UDim2.new(0.52, 5, 0, 35)
    secureStopButton.Text = "🛑 Stop Secure"
    secureStopButton.Font = Enum.Font.GothamSemibold
    secureStopButton.TextSize = 12
    secureStopButton.BackgroundColor3 = Color3.fromRGB(190,60,60)
    secureStopButton.TextColor3 = Color3.fromRGB(255,255,255)
    local secureStopCorner = Instance.new("UICorner", secureStopButton)
    secureStopCorner.CornerRadius = UDim.new(0,6)

    local modeStatus = Instance.new("TextLabel", secureModeSection)
    modeStatus.Size = UDim2.new(1, -20, 0, 25)
    modeStatus.Position = UDim2.new(0, 10, 0, 80)
    modeStatus.Text = "🔒 Secure Mode Ready - Safe & Reliable Fishing"
    modeStatus.Font = Enum.Font.GothamSemibold
    modeStatus.TextSize = 12
    modeStatus.TextColor3 = Color3.fromRGB(100,255,150)
    modeStatus.BackgroundTransparency = 1
    modeStatus.TextXAlignment = Enum.TextXAlignment.Center

    -- Smart AI Mode Selection Section  
    local aiModeSection = Instance.new("Frame", fishingAIScrollFrame)
    aiModeSection.Size = UDim2.new(1, -10, 0, 120)
    aiModeSection.Position = UDim2.new(0, 5, 0, 135)
    aiModeSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    aiModeSection.BorderSizePixel = 0
    Instance.new("UICorner", aiModeSection)

    local aiModeLabel = Instance.new("TextLabel", aiModeSection)
    aiModeLabel.Size = UDim2.new(1, -20, 0, 25)
    aiModeLabel.Position = UDim2.new(0, 10, 0, 5)
    aiModeLabel.Text = "🧠 Smart AI Fishing Modes"
    aiModeLabel.Font = Enum.Font.GothamBold
    aiModeLabel.TextSize = 14
    aiModeLabel.TextColor3 = Color3.fromRGB(255,140,0)
    aiModeLabel.BackgroundTransparency = 1
    aiModeLabel.TextXAlignment = Enum.TextXAlignment.Left

    local smartButtonAI = Instance.new("TextButton", aiModeSection)
    smartButtonAI.Size = UDim2.new(0.48, -5, 0, 35)
    smartButtonAI.Position = UDim2.new(0, 10, 0, 35)
    smartButtonAI.Text = "🧠 Start Smart AI"
    smartButtonAI.Font = Enum.Font.GothamSemibold
    smartButtonAI.TextSize = 12
    smartButtonAI.BackgroundColor3 = Color3.fromRGB(255,140,0)
    smartButtonAI.TextColor3 = Color3.fromRGB(255,255,255)
    local smartCornerAI = Instance.new("UICorner", smartButtonAI)
    smartCornerAI.CornerRadius = UDim.new(0,6)

    local stopButtonAI = Instance.new("TextButton", aiModeSection)
    stopButtonAI.Size = UDim2.new(0.48, -5, 0, 35)
    stopButtonAI.Position = UDim2.new(0.52, 5, 0, 35)
    stopButtonAI.Text = "🛑 Stop Smart AI"
    stopButtonAI.Font = Enum.Font.GothamSemibold
    stopButtonAI.TextSize = 12
    stopButtonAI.BackgroundColor3 = Color3.fromRGB(190,60,60)
    stopButtonAI.TextColor3 = Color3.fromRGB(255,255,255)
    local stopCornerAI = Instance.new("UICorner", stopButtonAI)
    stopCornerAI.CornerRadius = UDim.new(0,6)

    local aiStatusLabel = Instance.new("TextLabel", aiModeSection)
    aiStatusLabel.Size = UDim2.new(1, -20, 0, 25)
    aiStatusLabel.Position = UDim2.new(0, 10, 0, 80)
    aiStatusLabel.Text = "⏸️ Smart AI Ready (Click Start to begin)"
    aiStatusLabel.Font = Enum.Font.GothamSemibold
    aiStatusLabel.TextSize = 12
    aiStatusLabel.TextColor3 = Color3.fromRGB(200,200,200)
    aiStatusLabel.BackgroundTransparency = 1
    aiStatusLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    -- New: Auto Mode Section
    local autoModeSection = Instance.new("Frame", fishingAIScrollFrame)
    autoModeSection.Size = UDim2.new(1, -10, 0, 120)
    autoModeSection.Position = UDim2.new(0, 5, 0, 265) -- Positioned after Smart AI
    autoModeSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    autoModeSection.BorderSizePixel = 0
    Instance.new("UICorner", autoModeSection)

    local autoModeTitle = Instance.new("TextLabel", autoModeSection)
    autoModeTitle.Size = UDim2.new(1, -20, 0, 25)
    autoModeTitle.Position = UDim2.new(0, 10, 0, 5)
    autoModeTitle.Text = "🔥 Auto Mode (Loop Finish)"
    autoModeTitle.Font = Enum.Font.GothamBold
    autoModeTitle.TextSize = 14
    autoModeTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
    autoModeTitle.BackgroundTransparency = 1
    autoModeTitle.TextXAlignment = Enum.TextXAlignment.Left

    local autoModeStartButton = Instance.new("TextButton", autoModeSection)
    autoModeStartButton.Size = UDim2.new(0.48, -5, 0, 35)
    autoModeStartButton.Position = UDim2.new(0, 10, 0, 35)
    autoModeStartButton.Text = "🔥 Start Auto"
    autoModeStartButton.Font = Enum.Font.GothamSemibold
    autoModeStartButton.TextSize = 12
    autoModeStartButton.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
    autoModeStartButton.TextColor3 = Color3.fromRGB(255,255,255)
    local autoModeStartCorner = Instance.new("UICorner", autoModeStartButton)
    autoModeStartCorner.CornerRadius = UDim.new(0,6)

    local autoModeStopButton = Instance.new("TextButton", autoModeSection)
    autoModeStopButton.Size = UDim2.new(0.48, -5, 0, 35)
    autoModeStopButton.Position = UDim2.new(0.52, 5, 0, 35)
    autoModeStopButton.Text = "🛑 Stop Auto"
    autoModeStopButton.Font = Enum.Font.GothamSemibold
    autoModeStopButton.TextSize = 12
    autoModeStopButton.BackgroundColor3 = Color3.fromRGB(190,60,60)
    autoModeStopButton.TextColor3 = Color3.fromRGB(255,255,255)
    local autoModeStopCorner = Instance.new("UICorner", autoModeStopButton)
    autoModeStopCorner.CornerRadius = UDim.new(0,6)

    local autoModeStatus = Instance.new("TextLabel", autoModeSection)
    autoModeStatus.Size = UDim2.new(1, -20, 0, 25)
    autoModeStatus.Position = UDim2.new(0, 10, 0, 80)
    autoModeStatus.Text = "🔥 Auto Mode Ready"
    autoModeStatus.Font = Enum.Font.GothamSemibold
    autoModeStatus.TextSize = 12
    autoModeStatus.TextColor3 = Color3.fromRGB(220, 70, 70)
    autoModeStatus.BackgroundTransparency = 1
    autoModeStatus.TextXAlignment = Enum.TextXAlignment.Center

    -- AntiAFK Section in Fishing AI Tab
    local antiAfkSection = Instance.new("Frame", fishingAIScrollFrame)
    antiAfkSection.Size = UDim2.new(1, -10, 0, 60)
    antiAfkSection.Position = UDim2.new(0, 5, 0, 395) -- Adjusted position
    antiAfkSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    antiAfkSection.BorderSizePixel = 0
    Instance.new("UICorner", antiAfkSection)

    local antiAfkTitle = Instance.new("TextLabel", antiAfkSection)
    antiAfkTitle.Size = UDim2.new(1, -20, 0, 20)
    antiAfkTitle.Position = UDim2.new(0, 10, 0, 5)
    antiAfkTitle.Text = "🛡️ AntiAFK Protection"
    antiAfkTitle.Font = Enum.Font.GothamBold
    antiAfkTitle.TextSize = 14
    antiAfkTitle.TextColor3 = Color3.fromRGB(100,200,255)
    antiAfkTitle.BackgroundTransparency = 1
    antiAfkTitle.TextXAlignment = Enum.TextXAlignment.Left

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

    local antiAfkToggle = Instance.new("TextButton", antiAfkSection)
    antiAfkToggle.Size = UDim2.new(0, 70, 0, 24)
    antiAfkToggle.Position = UDim2.new(1, -80, 0, 31)
    antiAfkToggle.Text = "🔴 OFF"
    antiAfkToggle.Font = Enum.Font.GothamBold
    antiAfkToggle.TextSize = 11
    antiAfkToggle.BackgroundColor3 = Color3.fromRGB(160,60,60)
    antiAfkToggle.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", antiAfkToggle)

    -- ====================================================================
    -- AUTO SELL SECTION - ADVANCED VERSION
    -- ====================================================================
    local autoSellSection = Instance.new("Frame", fishingAIScrollFrame)
    autoSellSection.Size = UDim2.new(1, -10, 0, 200)
    autoSellSection.Position = UDim2.new(0, 5, 0, 465) -- After AntiAFK
    autoSellSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    autoSellSection.BorderSizePixel = 0
    Instance.new("UICorner", autoSellSection)

    local autoSellTitle = Instance.new("TextLabel", autoSellSection)
    autoSellTitle.Size = UDim2.new(1, -20, 0, 25)
    autoSellTitle.Position = UDim2.new(0, 10, 0, 5)
    autoSellTitle.Text = "💰 Advanced Auto Sell System"
    autoSellTitle.Font = Enum.Font.GothamBold
    autoSellTitle.TextSize = 14
    autoSellTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    autoSellTitle.BackgroundTransparency = 1
    autoSellTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Threshold Input
    local thresholdFrame = Instance.new("Frame", autoSellSection)
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
    thresholdInput.Text = tostring(AutoSell.threshold)
    thresholdInput.Font = Enum.Font.GothamSemibold
    thresholdInput.TextSize = 11
    thresholdInput.BackgroundColor3 = Color3.fromRGB(60,60,66)
    thresholdInput.TextColor3 = Color3.fromRGB(255,255,255)
    thresholdInput.BorderSizePixel = 0
    Instance.new("UICorner", thresholdInput)

    -- Rarity Checkboxes
    local rarityFrame = Instance.new("Frame", autoSellSection)
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

    -- Create checkboxes for each rarity
    local rarityData = {
        {name = "COMMON", color = Color3.fromRGB(150,150,150), icon = "🐟"},
        {name = "UNCOMMON", color = Color3.fromRGB(0,255,200), icon = "💎"},
        {name = "RARE", color = Color3.fromRGB(100,150,255), icon = "⭐"}
    }
    
    local rarityData2 = {
        {name = "EPIC", color = Color3.fromRGB(150,50,200), icon = "💜"},
        {name = "LEGENDARY", color = Color3.fromRGB(255,100,255), icon = "✨"},
        {name = "MYTHIC", color = Color3.fromRGB(255,50,50), icon = "🔥"}
    }

    local rarityCheckboxes = {}

    -- First row of checkboxes
    for i, rarity in ipairs(rarityData) do
        local checkbox = Instance.new("TextButton", rarityFrame)
        checkbox.Size = UDim2.new(0.33, -5, 0, 20)
        checkbox.Position = UDim2.new((i-1) * 0.33, 2, 0, 25)
        checkbox.Text = (AutoSell.allowedRarities[rarity.name] and "☑️" or "☐") .. " " .. rarity.icon .. " " .. rarity.name
        checkbox.Font = Enum.Font.GothamSemibold
        checkbox.TextSize = 9
        checkbox.BackgroundColor3 = Color3.fromRGB(60,60,66)
        checkbox.TextColor3 = rarity.color
        checkbox.BorderSizePixel = 0
        Instance.new("UICorner", checkbox)
        
        rarityCheckboxes[rarity.name] = checkbox
    end

    -- Second row of checkboxes
    for i, rarity in ipairs(rarityData2) do
        local checkbox = Instance.new("TextButton", rarityFrame)
        checkbox.Size = UDim2.new(0.33, -5, 0, 20)
        checkbox.Position = UDim2.new((i-1) * 0.33, 2, 0, 50)
        checkbox.Text = (AutoSell.allowedRarities[rarity.name] and "☑️" or "☐") .. " " .. rarity.icon .. " " .. rarity.name
        checkbox.Font = Enum.Font.GothamSemibold
        checkbox.TextSize = 9
        checkbox.BackgroundColor3 = Color3.fromRGB(60,60,66)
        checkbox.TextColor3 = rarity.color
        checkbox.BorderSizePixel = 0
        Instance.new("UICorner", checkbox)
        
        rarityCheckboxes[rarity.name] = checkbox
    end

    -- Enable/Disable Toggle
    local autoSellToggle = Instance.new("TextButton", autoSellSection)
    autoSellToggle.Size = UDim2.new(0.48, -5, 0, 25)
    autoSellToggle.Position = UDim2.new(0, 10, 0, 170)
    autoSellToggle.Text = AutoSell.enabled and "🟢 AUTO SELL ON" or "🔴 AUTO SELL OFF"
    autoSellToggle.Font = Enum.Font.GothamBold
    autoSellToggle.TextSize = 11
    autoSellToggle.BackgroundColor3 = AutoSell.enabled and Color3.fromRGB(70,170,90) or Color3.fromRGB(160,60,60)
    autoSellToggle.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", autoSellToggle)

    -- Status Label
    local autoSellStatus = Instance.new("TextLabel", autoSellSection)
    autoSellStatus.Size = UDim2.new(0.48, -5, 0, 25)
    autoSellStatus.Position = UDim2.new(0.52, 5, 0, 170)
    autoSellStatus.Text = "Status: Disabled"
    autoSellStatus.Font = Enum.Font.GothamSemibold
    autoSellStatus.TextSize = 10
    autoSellStatus.TextColor3 = Color3.fromRGB(200,200,200)
    autoSellStatus.BackgroundColor3 = Color3.fromRGB(35,35,42)
    autoSellStatus.TextXAlignment = Enum.TextXAlignment.Center
    autoSellStatus.TextYAlignment = Enum.TextYAlignment.Center
    Instance.new("UICorner", autoSellStatus)

    -- ====================================================================
    -- AUTO SELL EVENT HANDLERS
    -- ====================================================================
    
    -- Threshold input handler with server sync
    thresholdInput.FocusLost:Connect(function(enterPressed)
        local num = tonumber(thresholdInput.Text)
        if num and num > 0 and num <= 1000 then
            -- Check if threshold actually changed
            if num == AutoSell.threshold then
                return
            end
            
            -- Update local threshold
            AutoSell.threshold = num
            
            -- Try to sync with server
            task.spawn(function()
                local success, result = SyncAutoSellThresholdWithServer(num)
                local syncStatus = success and " (Synced)" or " (Local)"
                Notify("Auto Sell", "🎯 Threshold set to: " .. num .. " fish" .. syncStatus)
                
                if AutoSell.enabled then
                    autoSellStatus.Text = string.format("Active: %d/%d fish%s", 
                        GetTotalFishForSell(), AutoSell.threshold, 
                        AutoSell.isThresholdSynced and " ✅" or " ⚠️")
                end
            end)
        else
            Notify("Auto Sell", "❌ Invalid threshold! Use 1-1000")
            thresholdInput.Text = tostring(AutoSell.threshold)
        end
    end)

    -- Rarity checkbox handlers
    for rarityName, checkbox in pairs(rarityCheckboxes) do
        checkbox.MouseButton1Click:Connect(function()
            AutoSell.allowedRarities[rarityName] = not AutoSell.allowedRarities[rarityName]
            local rarityInfo = nil
            for _, r in ipairs(rarityData) do
                if r.name == rarityName then rarityInfo = r break end
            end
            for _, r in ipairs(rarityData2) do
                if r.name == rarityName then rarityInfo = r break end
            end
            
            if rarityInfo then
                checkbox.Text = (AutoSell.allowedRarities[rarityName] and "☑️" or "☐") .. " " .. rarityInfo.icon .. " " .. rarityName
                Notify("Auto Sell", rarityInfo.icon .. " " .. rarityName .. ": " .. (AutoSell.allowedRarities[rarityName] and "Enabled" or "Disabled"))
            end
        end)
    end

    -- Main toggle handler
    autoSellToggle.MouseButton1Click:Connect(function()
        AutoSell.enabled = not AutoSell.enabled
        autoSellToggle.Text = AutoSell.enabled and "🟢 AUTO SELL ON" or "🔴 AUTO SELL OFF"
        autoSellToggle.BackgroundColor3 = AutoSell.enabled and Color3.fromRGB(70,170,90) or Color3.fromRGB(160,60,60)
        
        if AutoSell.enabled then
            autoSellStatus.Text = string.format("Active: %d/%d fish", GetTotalFishForSell(), AutoSell.threshold)
            autoSellStatus.TextColor3 = Color3.fromRGB(100,255,150)
            ResetSellCounts() -- Reset counts when enabling
            Notify("Auto Sell", "🚀 Advanced Auto Sell enabled!")
        else
            autoSellStatus.Text = "Status: Disabled"
            autoSellStatus.TextColor3 = Color3.fromRGB(200,200,200)
            AutoSell.isCurrentlySelling = false
            Notify("Auto Sell", "🛑 Auto Sell disabled")
        end
    end)

    -- Update status periodically with sync indicators
    task.spawn(function()
        while true do
            if AutoSell.enabled and autoSellStatus then
                local totalFish = GetTotalFishForSell()
                local syncStatus = AutoSell.isThresholdSynced and "✅" or "⚠️"
                autoSellStatus.Text = string.format("Active: %d/%d fish %s", totalFish, AutoSell.threshold, syncStatus)
                
                -- Color coding based on progress
                local progress = totalFish / AutoSell.threshold
                if progress >= 1.0 then
                    autoSellStatus.TextColor3 = Color3.fromRGB(255,100,100) -- Red when ready to sell
                elseif progress >= 0.8 then
                    autoSellStatus.TextColor3 = Color3.fromRGB(255,200,100) -- Orange when close
                else
                    autoSellStatus.TextColor3 = Color3.fromRGB(100,255,150) -- Green when normal
                end
            end
            task.wait(2)
        end
    end)
    
    -- ====================================================================

    -- Future Features Section (placeholder for upcoming features)
    local futureSection = Instance.new("Frame", fishingAIScrollFrame)
    futureSection.Size = UDim2.new(1, -10, 0, 80)
    futureSection.Position = UDim2.new(0, 5, 0, 675) -- Adjusted position after AutoSell
    futureSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    futureSection.BorderSizePixel = 0
    Instance.new("UICorner", futureSection)

    local futureLabel = Instance.new("TextLabel", futureSection)
    futureLabel.Size = UDim2.new(1, -20, 0, 25)
    futureLabel.Position = UDim2.new(0, 10, 0, 5)
    futureLabel.Text = "🚀 Future Features"
    futureLabel.Font = Enum.Font.GothamBold
    futureLabel.TextSize = 14
    futureLabel.TextColor3 = Color3.fromRGB(150,150,255)
    futureLabel.BackgroundTransparency = 1
    futureLabel.TextXAlignment = Enum.TextXAlignment.Left

    local futureInfo = Instance.new("TextLabel", futureSection)
    futureInfo.Size = UDim2.new(1, -20, 0, 40)
    futureInfo.Position = UDim2.new(0, 10, 0, 30)
    futureInfo.Text = "💡 Space reserved for upcoming fishing enhancements,\nauto-sell improvements, and advanced AI features!"
    futureInfo.Font = Enum.Font.GothamSemibold
    futureInfo.TextSize = 11
    futureInfo.TextColor3 = Color3.fromRGB(180,180,180)
    futureInfo.BackgroundTransparency = 1
    futureInfo.TextXAlignment = Enum.TextXAlignment.Left
    futureInfo.TextYAlignment = Enum.TextYAlignment.Top

    -- Set canvas size for fishing AI scroll (current content + space for future)
    fishingAIScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 780) -- Increased for AutoSell section

    -- Teleport Tab Content
    local teleportFrame = Instance.new("Frame", contentContainer)
    teleportFrame.Size = UDim2.new(1, 0, 1, -10)
    teleportFrame.Position = UDim2.new(0, 0, 0, 0)
    teleportFrame.BackgroundTransparency = 1
    teleportFrame.Visible = false

    local teleportTitle = Instance.new("TextLabel", teleportFrame)
    teleportTitle.Size = UDim2.new(1, 0, 0, 24)
    teleportTitle.Text = "Island Locations"
    teleportTitle.Font = Enum.Font.GothamBold
    teleportTitle.TextSize = 16
    teleportTitle.TextColor3 = Color3.fromRGB(235,235,235)
    teleportTitle.BackgroundTransparency = 1
    teleportTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Create scrollable frame for islands
    local scrollFrame = Instance.new("ScrollingFrame", teleportFrame)
    scrollFrame.Size = UDim2.new(1, 0, 1, -30)
    scrollFrame.Position = UDim2.new(0, 0, 0, 30)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(35,35,42)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80,80,80)
    Instance.new("UICorner", scrollFrame)

    -- Island locations data
    local islandLocations = {
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

    -- Create island buttons
    local yOffset = 5
    local buttons = {}
    for islandName, cframe in pairs(islandLocations) do
        local btn = Instance.new("TextButton", scrollFrame)
        btn.Size = UDim2.new(1, -10, 0, 28)
        btn.Position = UDim2.new(0, 5, 0, yOffset)
        btn.Text = islandName
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 12
        btn.BackgroundColor3 = Color3.fromRGB(60,120,180)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        Instance.new("UICorner", btn)
        
        -- Store the CFrame for teleportation
        btn.MouseButton1Click:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
                Notify("Teleport", "Teleported to " .. islandName)
            else
                Notify("Teleport", "Character not found")
            end
        end)
        
        table.insert(buttons, btn)
        yOffset = yOffset + 33
    end

    -- Update scroll frame content size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)

    -- Player Tab Content
    local playerFrame = Instance.new("Frame", contentContainer)
    playerFrame.Size = UDim2.new(1, 0, 1, -10)
    playerFrame.Position = UDim2.new(0, 0, 0, 0)
    playerFrame.BackgroundTransparency = 1
    playerFrame.Visible = false

    local playerTitle = Instance.new("TextLabel", playerFrame)
    playerTitle.Size = UDim2.new(1, 0, 0, 24)
    playerTitle.Text = "Player List"
    playerTitle.Font = Enum.Font.GothamBold
    playerTitle.TextSize = 16
    playerTitle.TextColor3 = Color3.fromRGB(235,235,235)
    playerTitle.BackgroundTransparency = 1
    playerTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Search box for players
    local searchBox = Instance.new("TextBox", playerFrame)
    searchBox.Size = UDim2.new(1, 0, 0, 28)
    searchBox.Position = UDim2.new(0, 0, 0, 30)
    searchBox.PlaceholderText = "Search player..."
    searchBox.Text = ""
    searchBox.Font = Enum.Font.GothamSemibold
    searchBox.TextSize = 12
    searchBox.BackgroundColor3 = Color3.fromRGB(45,45,52)
    searchBox.TextColor3 = Color3.fromRGB(255,255,255)
    searchBox.BorderSizePixel = 0
    Instance.new("UICorner", searchBox)

    -- Create scrollable frame for players
    local playerScrollFrame = Instance.new("ScrollingFrame", playerFrame)
    playerScrollFrame.Size = UDim2.new(1, 0, 1, -65)
    playerScrollFrame.Position = UDim2.new(0, 0, 0, 65)
    playerScrollFrame.BackgroundColor3 = Color3.fromRGB(35,35,42)
    playerScrollFrame.BorderSizePixel = 0
    playerScrollFrame.ScrollBarThickness = 6
    playerScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80,80,80)
    Instance.new("UICorner", playerScrollFrame)

    -- Player list management
    local playerButtons = {}
    local function updatePlayerList(filter)
        -- Clear existing buttons
        for _, btn in pairs(playerButtons) do
            btn:Destroy()
        end
        playerButtons = {}
        
        local yPos = 5
        local players = Players:GetPlayers()
        
        for _, player in pairs(players) do
            if not filter or filter == "" or string.lower(player.Name):find(string.lower(filter)) or string.lower(player.DisplayName):find(string.lower(filter)) then
                local playerBtn = Instance.new("TextButton", playerScrollFrame)
                playerBtn.Size = UDim2.new(1, -10, 0, 32)
                playerBtn.Position = UDim2.new(0, 5, 0, yPos)
                playerBtn.Text = "🎮 " .. player.DisplayName .. " (@" .. player.Name .. ")"
                playerBtn.Font = Enum.Font.GothamSemibold
                playerBtn.TextSize = 11
                playerBtn.BackgroundColor3 = player == LocalPlayer and Color3.fromRGB(100,150,100) or Color3.fromRGB(80,120,180)
                playerBtn.TextColor3 = Color3.fromRGB(255,255,255)
                playerBtn.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", playerBtn)
                
                local btnPadding = Instance.new("UIPadding", playerBtn)
                btnPadding.PaddingLeft = UDim.new(0, 8)
                
                -- Teleport to player functionality
                if player ~= LocalPlayer then
                    playerBtn.MouseButton1Click:Connect(function()
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and 
                           LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                            Notify("Player Teleport", "Teleported to " .. player.DisplayName)
                        else
                            Notify("Player Teleport", "Cannot teleport to " .. player.DisplayName .. " - Character not found")
                        end
                    end)
                else
                    playerBtn.Text = "🎮 " .. player.DisplayName .. " (@" .. player.Name .. ") [YOU]"
                end
                
                table.insert(playerButtons, playerBtn)
                yPos = yPos + 37
            end
        end
        
        playerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end

    -- Search functionality
    searchBox.Changed:Connect(function(property)
        if property == "Text" then
            updatePlayerList(searchBox.Text)
        end
    end)

    -- Auto-refresh player list every 5 seconds
    local function autoRefreshPlayers()
        while true do
            if playerFrame.Visible then
                updatePlayerList(searchBox.Text)
            end
            task.wait(5)
        end
    end
    
    task.spawn(autoRefreshPlayers)

    -- Initial player list load
    updatePlayerList()
    
    -- Player join/leave events
    Players.PlayerAdded:Connect(function()
        if playerFrame.Visible then
            updatePlayerList(searchBox.Text)
        end
    end)
    
    Players.PlayerRemoving:Connect(function()
        if playerFrame.Visible then
            task.wait(0.1) -- Small delay to ensure player is removed
            updatePlayerList(searchBox.Text)
        end
    end)

    -- Feature Tab Content
    local featureFrame = Instance.new("Frame", contentContainer)
    featureFrame.Size = UDim2.new(1, 0, 1, -10)
    featureFrame.Position = UDim2.new(0, 0, 0, 0)
    featureFrame.BackgroundTransparency = 1
    featureFrame.Visible = false

    local featureTitle = Instance.new("TextLabel", featureFrame)
    featureTitle.Size = UDim2.new(1, 0, 0, 24)
    featureTitle.Text = "Character Features"
    featureTitle.Font = Enum.Font.GothamBold
    featureTitle.TextSize = 16
    featureTitle.TextColor3 = Color3.fromRGB(235,235,235)
    featureTitle.BackgroundTransparency = 1
    featureTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Create scrollable frame for features
    local featureScrollFrame = Instance.new("ScrollingFrame", featureFrame)
    featureScrollFrame.Size = UDim2.new(1, 0, 1, -30)
    featureScrollFrame.Position = UDim2.new(0, 0, 0, 30)
    featureScrollFrame.BackgroundColor3 = Color3.fromRGB(35,35,42)
    featureScrollFrame.BorderSizePixel = 0
    featureScrollFrame.ScrollBarThickness = 6
    featureScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80,80,80)
    Instance.new("UICorner", featureScrollFrame)

    -- Speed Control Section
    local speedSection = Instance.new("Frame", featureScrollFrame)
    speedSection.Size = UDim2.new(1, -10, 0, 80)
    speedSection.Position = UDim2.new(0, 5, 0, 5)
    speedSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    speedSection.BorderSizePixel = 0
    Instance.new("UICorner", speedSection)

    local speedLabel = Instance.new("TextLabel", speedSection)
    speedLabel.Size = UDim2.new(1, -20, 0, 20)
    speedLabel.Position = UDim2.new(0, 10, 0, 8)
    speedLabel.Text = "Walk Speed: 16"
    speedLabel.Font = Enum.Font.GothamSemibold
    speedLabel.TextSize = 14
    speedLabel.TextColor3 = Color3.fromRGB(235,235,235)
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left

    local speedSlider = Instance.new("Frame", speedSection)
    speedSlider.Size = UDim2.new(1, -20, 0, 20)
    speedSlider.Position = UDim2.new(0, 10, 0, 35)
    speedSlider.BackgroundColor3 = Color3.fromRGB(50,50,60)
    speedSlider.BorderSizePixel = 0
    Instance.new("UICorner", speedSlider)

    local speedFill = Instance.new("Frame", speedSlider)
    speedFill.Size = UDim2.new(0.16, 0, 1, 0) -- 16/100 = 0.16
    speedFill.Position = UDim2.new(0, 0, 0, 0)
    speedFill.BackgroundColor3 = Color3.fromRGB(100,150,255)
    speedFill.BorderSizePixel = 0
    Instance.new("UICorner", speedFill)

    local speedHandle = Instance.new("TextButton", speedSlider)
    speedHandle.Size = UDim2.new(0, 20, 1, 0)
    speedHandle.Position = UDim2.new(0.16, -10, 0, 0)
    speedHandle.Text = ""
    speedHandle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    speedHandle.BorderSizePixel = 0
    Instance.new("UICorner", speedHandle)

    local speedResetBtn = Instance.new("TextButton", speedSection)
    speedResetBtn.Size = UDim2.new(0, 60, 0, 18)
    speedResetBtn.Position = UDim2.new(1, -70, 0, 58)
    speedResetBtn.Text = "Reset"
    speedResetBtn.Font = Enum.Font.GothamSemibold
    speedResetBtn.TextSize = 10
    speedResetBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
    speedResetBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", speedResetBtn)

    -- Jump Control Section
    local jumpSection = Instance.new("Frame", featureScrollFrame)
    jumpSection.Size = UDim2.new(1, -10, 0, 80)
    jumpSection.Position = UDim2.new(0, 5, 0, 95)
    jumpSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    jumpSection.BorderSizePixel = 0
    Instance.new("UICorner", jumpSection)

    local jumpLabel = Instance.new("TextLabel", jumpSection)
    jumpLabel.Size = UDim2.new(1, -20, 0, 20)
    jumpLabel.Position = UDim2.new(0, 10, 0, 8)
    jumpLabel.Text = "Jump Power: 50"
    jumpLabel.Font = Enum.Font.GothamSemibold
    jumpLabel.TextSize = 14
    jumpLabel.TextColor3 = Color3.fromRGB(235,235,235)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left

    local jumpSlider = Instance.new("Frame", jumpSection)
    jumpSlider.Size = UDim2.new(1, -20, 0, 20)
    jumpSlider.Position = UDim2.new(0, 10, 0, 35)
    jumpSlider.BackgroundColor3 = Color3.fromRGB(50,50,60)
    jumpSlider.BorderSizePixel = 0
    Instance.new("UICorner", jumpSlider)

    local jumpFill = Instance.new("Frame", jumpSlider)
    jumpFill.Size = UDim2.new(0.1, 0, 1, 0) -- 50/500 = 0.1
    jumpFill.Position = UDim2.new(0, 0, 0, 0)
    jumpFill.BackgroundColor3 = Color3.fromRGB(100,255,150)
    jumpFill.BorderSizePixel = 0
    Instance.new("UICorner", jumpFill)

    local jumpHandle = Instance.new("TextButton", jumpSlider)
    jumpHandle.Size = UDim2.new(0, 20, 1, 0)
    jumpHandle.Position = UDim2.new(0.1, -10, 0, 0)
    jumpHandle.Text = ""
    jumpHandle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    jumpHandle.BorderSizePixel = 0
    Instance.new("UICorner", jumpHandle)

    local jumpResetBtn = Instance.new("TextButton", jumpSection)
    jumpResetBtn.Size = UDim2.new(0, 60, 0, 18)
    jumpResetBtn.Position = UDim2.new(1, -70, 0, 58)
    jumpResetBtn.Text = "Reset"
    jumpResetBtn.Font = Enum.Font.GothamSemibold
    jumpResetBtn.TextSize = 10
    jumpResetBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
    jumpResetBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", jumpResetBtn)

    -- Rod Orientation Fix Section
    local rodFixSection = Instance.new("Frame", featureScrollFrame)
    rodFixSection.Size = UDim2.new(1, -10, 0, 60)
    rodFixSection.Position = UDim2.new(0, 5, 0, 185)
    rodFixSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    rodFixSection.BorderSizePixel = 0
    Instance.new("UICorner", rodFixSection)

    local rodFixLabel = Instance.new("TextLabel", rodFixSection)
    rodFixLabel.Size = UDim2.new(0.7, -10, 1, 0)
    rodFixLabel.Position = UDim2.new(0, 10, 0, 0)
    rodFixLabel.Text = "🎣 Rod Orientation Fix\nFix rod facing backwards"
    rodFixLabel.Font = Enum.Font.GothamSemibold
    rodFixLabel.TextSize = 13
    rodFixLabel.TextColor3 = Color3.fromRGB(235,235,235)
    rodFixLabel.BackgroundTransparency = 1
    rodFixLabel.TextXAlignment = Enum.TextXAlignment.Left
    rodFixLabel.TextYAlignment = Enum.TextYAlignment.Center

    local rodFixToggle = Instance.new("TextButton", rodFixSection)
    rodFixToggle.Size = UDim2.new(0, 60, 0, 25)
    rodFixToggle.Position = UDim2.new(1, -70, 0, 18)
    rodFixToggle.Text = RodFix.enabled and "ON" or "OFF"
    rodFixToggle.Font = Enum.Font.GothamBold
    rodFixToggle.TextSize = 12
    rodFixToggle.BackgroundColor3 = RodFix.enabled and Color3.fromRGB(100,200,100) or Color3.fromRGB(200,100,100)
    rodFixToggle.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", rodFixToggle)

    rodFixToggle.MouseButton1Click:Connect(function()
        RodFix.enabled = not RodFix.enabled
        rodFixToggle.Text = RodFix.enabled and "ON" or "OFF"
        rodFixToggle.BackgroundColor3 = RodFix.enabled and Color3.fromRGB(100,200,100) or Color3.fromRGB(200,100,100)
        
        if RodFix.enabled then
            FixRodOrientation()
            Notify("Rod Fix", "🎣 Rod orientation fix enabled")
        else
            Notify("Rod Fix", "🎣 Rod orientation fix disabled")
        end
    end)

    -- Sell All Items Section
    local sellAllSection = Instance.new("Frame", featureScrollFrame)
    sellAllSection.Size = UDim2.new(1, -10, 0, 60)
    sellAllSection.Position = UDim2.new(0, 5, 0, 255)
    sellAllSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    sellAllSection.BorderSizePixel = 0
    Instance.new("UICorner", sellAllSection)

    local sellAllLabel = Instance.new("TextLabel", sellAllSection)
    sellAllLabel.Size = UDim2.new(0.6, -10, 1, 0)
    sellAllLabel.Position = UDim2.new(0, 10, 0, 0)
    sellAllLabel.Text = "💰 Sell All Items\nSell all fish in inventory"
    sellAllLabel.Font = Enum.Font.GothamSemibold
    sellAllLabel.TextSize = 13
    sellAllLabel.TextColor3 = Color3.fromRGB(235,235,235)
    sellAllLabel.BackgroundTransparency = 1
    sellAllLabel.TextXAlignment = Enum.TextXAlignment.Left
    sellAllLabel.TextYAlignment = Enum.TextYAlignment.Center

    local sellBtn = Instance.new("TextButton", sellAllSection)
    sellBtn.Size = UDim2.new(0, 80, 0, 30)
    sellBtn.Position = UDim2.new(1, -90, 0, 15)
    sellBtn.Text = "💰 SELL ALL"
    sellBtn.Font = Enum.Font.GothamBold
    sellBtn.TextSize = 11
    sellBtn.BackgroundColor3 = Color3.fromRGB(255,140,0)
    sellBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", sellBtn)

    -- Auto Reconnect Section
    local reconnectSection = Instance.new("Frame", featureScrollFrame)
    reconnectSection.Size = UDim2.new(1, -10, 0, 80)
    reconnectSection.Position = UDim2.new(0, 5, 0, 325)
    reconnectSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    reconnectSection.BorderSizePixel = 0
    Instance.new("UICorner", reconnectSection)

    local reconnectLabel = Instance.new("TextLabel", reconnectSection)
    reconnectLabel.Size = UDim2.new(0.7, -10, 0, 35)
    reconnectLabel.Position = UDim2.new(0, 10, 0, 5)
    reconnectLabel.Text = "🌐 Auto Reconnect\nAuto rejoin on disconnect"
    reconnectLabel.Font = Enum.Font.GothamSemibold
    reconnectLabel.TextSize = 13
    reconnectLabel.TextColor3 = Color3.fromRGB(235,235,235)
    reconnectLabel.BackgroundTransparency = 1
    reconnectLabel.TextXAlignment = Enum.TextXAlignment.Left
    reconnectLabel.TextYAlignment = Enum.TextYAlignment.Top

    local reconnectToggle = Instance.new("TextButton", reconnectSection)
    reconnectToggle.Size = UDim2.new(0, 60, 0, 25)
    reconnectToggle.Position = UDim2.new(1, -70, 0, 8)
    reconnectToggle.Text = "OFF"
    reconnectToggle.Font = Enum.Font.GothamBold
    reconnectToggle.TextSize = 12
    reconnectToggle.BackgroundColor3 = Color3.fromRGB(80,80,80)
    reconnectToggle.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", reconnectToggle)

    local reconnectStatus = Instance.new("TextLabel", reconnectSection)
    reconnectStatus.Size = UDim2.new(1, -20, 0, 15)
    reconnectStatus.Position = UDim2.new(0, 10, 0, 45)
    reconnectStatus.Text = "Status: Disabled"
    reconnectStatus.Font = Enum.Font.Gotham
    reconnectStatus.TextSize = 11
    reconnectStatus.TextColor3 = Color3.fromRGB(150,150,150)
    reconnectStatus.BackgroundTransparency = 1
    reconnectStatus.TextXAlignment = Enum.TextXAlignment.Left

    local reconnectManualBtn = Instance.new("TextButton", reconnectSection)
    reconnectManualBtn.Size = UDim2.new(0, 80, 0, 20)
    reconnectManualBtn.Position = UDim2.new(1, -90, 0, 50)
    reconnectManualBtn.Text = "🔄 Reconnect"
    reconnectManualBtn.Font = Enum.Font.GothamSemibold
    reconnectManualBtn.TextSize = 10
    reconnectManualBtn.BackgroundColor3 = Color3.fromRGB(70,130,255)
    reconnectManualBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", reconnectManualBtn)

    -- Enhancement Section
    local enhancementSection = Instance.new("Frame", featureScrollFrame)
    enhancementSection.Size = UDim2.new(1, -10, 0, 150)
    enhancementSection.Position = UDim2.new(0, 5, 0, 415) -- Moved down to accommodate reconnect section
    enhancementSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    enhancementSection.BorderSizePixel = 0
    Instance.new("UICorner", enhancementSection)

    local enhancementTitle = Instance.new("TextLabel", enhancementSection)
    enhancementTitle.Size = UDim2.new(1, -20, 0, 20)
    enhancementTitle.Position = UDim2.new(0, 10, 0, 5)
    enhancementTitle.Text = "🔮 Auto Enhancement System"
    enhancementTitle.Font = Enum.Font.GothamBold
    enhancementTitle.TextSize = 14
    enhancementTitle.TextColor3 = Color3.fromRGB(255,140,255)
    enhancementTitle.BackgroundTransparency = 1
    enhancementTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Teleport to Altar Section
    local teleportSection = Instance.new("Frame", enhancementSection)
    teleportSection.Size = UDim2.new(1, -20, 0, 25)
    teleportSection.Position = UDim2.new(0, 10, 0, 30)
    teleportSection.BackgroundTransparency = 1

    local teleportLabel = Instance.new("TextLabel", teleportSection)
    teleportLabel.Size = UDim2.new(0.7, -10, 1, 0)
    teleportLabel.Position = UDim2.new(0, 0, 0, 0)
    teleportLabel.Text = "📍 Teleport to Altar"
    teleportLabel.Font = Enum.Font.GothamSemibold
    teleportLabel.TextSize = 12
    teleportLabel.TextColor3 = Color3.fromRGB(255,255,255)
    teleportLabel.BackgroundTransparency = 1
    teleportLabel.TextXAlignment = Enum.TextXAlignment.Left
    teleportLabel.TextYAlignment = Enum.TextYAlignment.Center

    local teleportBtn = Instance.new("TextButton", teleportSection)
    teleportBtn.Size = UDim2.new(0, 50, 0, 20)
    teleportBtn.Position = UDim2.new(1, -55, 0, 2)
    teleportBtn.Text = "GO"
    teleportBtn.Font = Enum.Font.GothamBold
    teleportBtn.TextSize = 10
    teleportBtn.BackgroundColor3 = Color3.fromRGB(60,160,60)
    teleportBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", teleportBtn)

    -- Auto Activate Altar Toggle
    local autoAltarToggle = Instance.new("Frame", enhancementSection)
    autoAltarToggle.Size = UDim2.new(1, -20, 0, 25)
    autoAltarToggle.Position = UDim2.new(0, 10, 0, 60)
    autoAltarToggle.BackgroundTransparency = 1

    local altarLabel = Instance.new("TextLabel", autoAltarToggle)
    altarLabel.Size = UDim2.new(0.7, -10, 1, 0)
    altarLabel.Position = UDim2.new(0, 0, 0, 0)
    altarLabel.Text = "🏛️ Auto Activate Altar"
    altarLabel.Font = Enum.Font.GothamSemibold
    altarLabel.TextSize = 12
    altarLabel.TextColor3 = Color3.fromRGB(255,255,255)
    altarLabel.BackgroundTransparency = 1
    altarLabel.TextXAlignment = Enum.TextXAlignment.Left
    altarLabel.TextYAlignment = Enum.TextYAlignment.Center

    local altarToggleBtn = Instance.new("TextButton", autoAltarToggle)
    altarToggleBtn.Size = UDim2.new(0, 50, 0, 20)
    altarToggleBtn.Position = UDim2.new(1, -55, 0, 2)
    altarToggleBtn.Text = "OFF"
    altarToggleBtn.Font = Enum.Font.GothamBold
    altarToggleBtn.TextSize = 10
    altarToggleBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
    altarToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", altarToggleBtn)

    -- Auto Roll Enchant Toggle
    local autoRollToggle = Instance.new("Frame", enhancementSection)
    autoRollToggle.Size = UDim2.new(1, -20, 0, 25)
    autoRollToggle.Position = UDim2.new(0, 10, 0, 90)
    autoRollToggle.BackgroundTransparency = 1

    local rollLabel = Instance.new("TextLabel", autoRollToggle)
    rollLabel.Size = UDim2.new(0.7, -10, 1, 0)
    rollLabel.Position = UDim2.new(0, 0, 0, 0)
    rollLabel.Text = "🎲 Auto Roll Enchant"
    rollLabel.Font = Enum.Font.GothamSemibold
    rollLabel.TextSize = 12
    rollLabel.TextColor3 = Color3.fromRGB(255,255,255)
    rollLabel.BackgroundTransparency = 1
    rollLabel.TextXAlignment = Enum.TextXAlignment.Left
    rollLabel.TextYAlignment = Enum.TextYAlignment.Center

    local rollToggleBtn = Instance.new("TextButton", autoRollToggle)
    rollToggleBtn.Size = UDim2.new(0, 50, 0, 20)
    rollToggleBtn.Position = UDim2.new(1, -55, 0, 2)
    rollToggleBtn.Text = "OFF"
    rollToggleBtn.Font = Enum.Font.GothamBold
    rollToggleBtn.TextSize = 10
    rollToggleBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
    rollToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", rollToggleBtn)

    -- Enhancement Start/Stop Buttons
    local enhancementStartBtn = Instance.new("TextButton", enhancementSection)
    enhancementStartBtn.Size = UDim2.new(0.48, -5, 0, 25)
    enhancementStartBtn.Position = UDim2.new(0, 10, 0, 120)
    enhancementStartBtn.Text = "🔮 Start Enhancement"
    enhancementStartBtn.Font = Enum.Font.GothamBold
    enhancementStartBtn.TextSize = 11
    enhancementStartBtn.BackgroundColor3 = Color3.fromRGB(140,60,255)
    enhancementStartBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", enhancementStartBtn)

    local enhancementStopBtn = Instance.new("TextButton", enhancementSection)
    enhancementStopBtn.Size = UDim2.new(0.48, -5, 0, 25)
    enhancementStopBtn.Position = UDim2.new(0.52, 5, 0, 120)
    enhancementStopBtn.Text = "🛑 Stop Enhancement"
    enhancementStopBtn.Font = Enum.Font.GothamBold
    enhancementStopBtn.TextSize = 11
    enhancementStopBtn.BackgroundColor3 = Color3.fromRGB(190,60,60)
    enhancementStopBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", enhancementStopBtn)

    -- Movement Enhancement Section
    local movementSection = Instance.new("Frame", featureScrollFrame)
    movementSection.Size = UDim2.new(1, -10, 0, 240)
    movementSection.Position = UDim2.new(0, 5, 0, 575)
    movementSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    movementSection.BorderSizePixel = 0
    Instance.new("UICorner", movementSection)

    local movementTitle = Instance.new("TextLabel", movementSection)
    movementTitle.Size = UDim2.new(1, -20, 0, 20)
    movementTitle.Position = UDim2.new(0, 10, 0, 5)
    movementTitle.Text = "🚀 Movement Enhancement"
    movementTitle.Font = Enum.Font.GothamBold
    movementTitle.TextSize = 14
    movementTitle.TextColor3 = Color3.fromRGB(255,255,255)
    movementTitle.BackgroundTransparency = 1
    movementTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Float Controls
    local floatLabel = Instance.new("TextLabel", movementSection)
    floatLabel.Size = UDim2.new(1, -20, 0, 15)
    floatLabel.Position = UDim2.new(0, 10, 0, 30)
    floatLabel.Text = "🚀 Enable Float (WASD + Space/Shift to move)"
    floatLabel.Font = Enum.Font.Gotham
    floatLabel.TextSize = 11
    floatLabel.TextColor3 = Color3.fromRGB(200,200,200)
    floatLabel.BackgroundTransparency = 1
    floatLabel.TextXAlignment = Enum.TextXAlignment.Left

    local floatToggleBtn = Instance.new("TextButton", movementSection)
    floatToggleBtn.Size = UDim2.new(0, 60, 0, 20)
    floatToggleBtn.Position = UDim2.new(1, -70, 0, 50)
    floatToggleBtn.Text = "OFF"
    floatToggleBtn.Font = Enum.Font.GothamBold
    floatToggleBtn.TextSize = 10
    floatToggleBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
    floatToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", floatToggleBtn)

    -- No Clip Controls
    local noClipLabel = Instance.new("TextLabel", movementSection)
    noClipLabel.Size = UDim2.new(1, -20, 0, 15)
    noClipLabel.Position = UDim2.new(0, 10, 0, 75)
    noClipLabel.Text = "👻 Universal No Clip (Walk through walls)"
    noClipLabel.Font = Enum.Font.Gotham
    noClipLabel.TextSize = 11
    noClipLabel.TextColor3 = Color3.fromRGB(200,200,200)
    noClipLabel.BackgroundTransparency = 1
    noClipLabel.TextXAlignment = Enum.TextXAlignment.Left

    local noClipToggleBtn = Instance.new("TextButton", movementSection)
    noClipToggleBtn.Size = UDim2.new(0, 60, 0, 20)
    noClipToggleBtn.Position = UDim2.new(1, -70, 0, 95)
    noClipToggleBtn.Text = "OFF"
    noClipToggleBtn.Font = Enum.Font.GothamBold
    noClipToggleBtn.TextSize = 10
    noClipToggleBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
    noClipToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", noClipToggleBtn)

    -- Auto Spinner Controls
    local spinnerLabel = Instance.new("TextLabel", movementSection)
    spinnerLabel.Size = UDim2.new(1, -20, 0, 15)
    spinnerLabel.Position = UDim2.new(0, 10, 0, 120)
    spinnerLabel.Text = "🌪️ Auto Spinner (Randomize fishing direction)"
    spinnerLabel.Font = Enum.Font.Gotham
    spinnerLabel.TextSize = 11
    spinnerLabel.TextColor3 = Color3.fromRGB(200,200,200)
    spinnerLabel.BackgroundTransparency = 1
    spinnerLabel.TextXAlignment = Enum.TextXAlignment.Left

    local spinnerToggleBtn = Instance.new("TextButton", movementSection)
    spinnerToggleBtn.Size = UDim2.new(0, 60, 0, 20)
    spinnerToggleBtn.Position = UDim2.new(1, -70, 0, 140)
    spinnerToggleBtn.Text = "OFF"
    spinnerToggleBtn.Font = Enum.Font.GothamBold
    spinnerToggleBtn.TextSize = 10
    spinnerToggleBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
    spinnerToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", spinnerToggleBtn)

    -- Spinner Speed Control
    local speedLabel = Instance.new("TextLabel", movementSection)
    speedLabel.Size = UDim2.new(0.4, -10, 0, 15)
    speedLabel.Position = UDim2.new(0, 10, 0, 165)
    speedLabel.Text = "Speed:"
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 10
    speedLabel.TextColor3 = Color3.fromRGB(200,200,200)
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left

    local speedInput = Instance.new("TextBox", movementSection)
    speedInput.Size = UDim2.new(0, 40, 0, 20)
    speedInput.Position = UDim2.new(0, 50, 0, 180)
    speedInput.Text = "2"
    speedInput.Font = Enum.Font.Gotham
    speedInput.TextSize = 10
    speedInput.TextColor3 = Color3.fromRGB(255,255,255)
    speedInput.BackgroundColor3 = Color3.fromRGB(35,35,40)
    speedInput.BorderSizePixel = 0
    speedInput.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", speedInput)

    -- Direction Toggle Button
    local directionBtn = Instance.new("TextButton", movementSection)
    directionBtn.Size = UDim2.new(0, 80, 0, 20)
    directionBtn.Position = UDim2.new(0, 100, 0, 180)
    directionBtn.Text = "⟲ Clockwise"
    directionBtn.Font = Enum.Font.Gotham
    directionBtn.TextSize = 9
    directionBtn.BackgroundColor3 = Color3.fromRGB(70,70,80)
    directionBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", directionBtn)

    -- Float Height Control
    local heightLabel = Instance.new("TextLabel", movementSection)
    heightLabel.Size = UDim2.new(0.5, -10, 0, 15)
    heightLabel.Position = UDim2.new(0, 10, 0, 205)
    heightLabel.Text = "Float Height:"
    heightLabel.Font = Enum.Font.Gotham
    heightLabel.TextSize = 10
    heightLabel.TextColor3 = Color3.fromRGB(200,200,200)
    heightLabel.BackgroundTransparency = 1
    heightLabel.TextXAlignment = Enum.TextXAlignment.Left

    local heightInput = Instance.new("TextBox", movementSection)
    heightInput.Size = UDim2.new(0, 60, 0, 20)
    heightInput.Position = UDim2.new(0, 80, 0, 215)
    heightInput.Text = "16"
    heightInput.Font = Enum.Font.Gotham
    heightInput.TextSize = 10
    heightInput.TextColor3 = Color3.fromRGB(255,255,255)
    heightInput.BackgroundColor3 = Color3.fromRGB(35,35,40)
    heightInput.BorderSizePixel = 0
    heightInput.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", heightInput)

    -- Weather Section
    local weatherSection = Instance.new("Frame", featureScrollFrame)
    weatherSection.Size = UDim2.new(1, -10, 0, 120)
    weatherSection.Position = UDim2.new(0, 5, 0, 825) -- Moved down to accommodate larger movement section
    weatherSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    weatherSection.BorderSizePixel = 0
    Instance.new("UICorner", weatherSection)

    local weatherTitle = Instance.new("TextLabel", weatherSection)
    weatherTitle.Size = UDim2.new(1, -20, 0, 20)
    weatherTitle.Position = UDim2.new(0, 10, 0, 5)
    weatherTitle.Text = "🌦️ Auto Weather System"
    weatherTitle.Font = Enum.Font.GothamBold
    weatherTitle.TextSize = 14
    weatherTitle.TextColor3 = Color3.fromRGB(135,206,235)
    weatherTitle.BackgroundTransparency = 1
    weatherTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Weather Type Selection
    local weatherTypeFrame = Instance.new("Frame", weatherSection)
    weatherTypeFrame.Size = UDim2.new(1, -20, 0, 25)
    weatherTypeFrame.Position = UDim2.new(0, 10, 0, 30)
    weatherTypeFrame.BackgroundTransparency = 1

    local weatherTypeLabel = Instance.new("TextLabel", weatherTypeFrame)
    weatherTypeLabel.Size = UDim2.new(0.4, -10, 1, 0)
    weatherTypeLabel.Position = UDim2.new(0, 0, 0, 0)
    weatherTypeLabel.Text = "🌡️ Weather Type:"
    weatherTypeLabel.Font = Enum.Font.GothamSemibold
    weatherTypeLabel.TextSize = 12
    weatherTypeLabel.TextColor3 = Color3.fromRGB(255,255,255)
    weatherTypeLabel.BackgroundTransparency = 1
    weatherTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
    weatherTypeLabel.TextYAlignment = Enum.TextYAlignment.Center

    local weatherDropdown = Instance.new("TextButton", weatherTypeFrame)
    weatherDropdown.Size = UDim2.new(0.6, -10, 0, 20)
    weatherDropdown.Position = UDim2.new(0.4, 5, 0, 2)
    weatherDropdown.Text = Weather.selectedWeather .. " ▼"
    weatherDropdown.Font = Enum.Font.GothamSemibold
    weatherDropdown.TextSize = 10
    weatherDropdown.BackgroundColor3 = Color3.fromRGB(60,60,66)
    weatherDropdown.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", weatherDropdown)

    -- Auto Purchase Toggle
    local autoPurchaseToggle = Instance.new("Frame", weatherSection)
    autoPurchaseToggle.Size = UDim2.new(1, -20, 0, 25)
    autoPurchaseToggle.Position = UDim2.new(0, 10, 0, 60)
    autoPurchaseToggle.BackgroundTransparency = 1

    local purchaseLabel = Instance.new("TextLabel", autoPurchaseToggle)
    purchaseLabel.Size = UDim2.new(0.7, -10, 1, 0)
    purchaseLabel.Position = UDim2.new(0, 0, 0, 0)
    purchaseLabel.Text = "💰 Auto Purchase Weather"
    purchaseLabel.Font = Enum.Font.GothamSemibold
    purchaseLabel.TextSize = 11
    purchaseLabel.TextColor3 = Color3.fromRGB(255,255,255)
    purchaseLabel.BackgroundTransparency = 1
    purchaseLabel.TextXAlignment = Enum.TextXAlignment.Left
    purchaseLabel.TextYAlignment = Enum.TextYAlignment.Center

    local purchaseToggleBtn = Instance.new("TextButton", autoPurchaseToggle)
    purchaseToggleBtn.Size = UDim2.new(0, 50, 0, 20)
    purchaseToggleBtn.Position = UDim2.new(1, -55, 0, 2)
    purchaseToggleBtn.Text = "OFF"
    purchaseToggleBtn.Font = Enum.Font.GothamBold
    purchaseToggleBtn.TextSize = 10
    purchaseToggleBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
    purchaseToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", purchaseToggleBtn)

    -- Weather Start/Stop Buttons
    local weatherStartBtn = Instance.new("TextButton", weatherSection)
    weatherStartBtn.Size = UDim2.new(0.48, -5, 0, 25)
    weatherStartBtn.Position = UDim2.new(0, 10, 0, 90)
    weatherStartBtn.Text = "🌦️ Start Weather"
    weatherStartBtn.Font = Enum.Font.GothamBold
    weatherStartBtn.TextSize = 11
    weatherStartBtn.BackgroundColor3 = Color3.fromRGB(60,140,255)
    weatherStartBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", weatherStartBtn)

    local weatherStopBtn = Instance.new("TextButton", weatherSection)
    weatherStopBtn.Size = UDim2.new(0.48, -5, 0, 25)
    weatherStopBtn.Position = UDim2.new(0.52, 5, 0, 90)
    weatherStopBtn.Text = "🛑 Stop Weather"
    weatherStopBtn.Font = Enum.Font.GothamBold
    weatherStopBtn.TextSize = 11
    weatherStopBtn.BackgroundColor3 = Color3.fromRGB(190,60,60)
    weatherStopBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", weatherStopBtn)

    -- Buy All Weather Button (Manual)
    local buyAllBtn = Instance.new("TextButton", weatherSection)
    buyAllBtn.Size = UDim2.new(1, -20, 0, 20)
    buyAllBtn.Position = UDim2.new(0, 10, 0, 115)
    buyAllBtn.Text = "🌈 Buy All Weather Now"
    buyAllBtn.Font = Enum.Font.GothamBold
    buyAllBtn.TextSize = 10
    buyAllBtn.BackgroundColor3 = Color3.fromRGB(255,140,0)
    buyAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
    buyAllBtn.Visible = true -- Show by default since "All" is default selection
    Instance.new("UICorner", buyAllBtn)

    -- Set canvas size for feature scroll frame
    featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 960) -- Increased to accommodate larger movement section with Auto Spinner

    -- Feature variables
    local currentSpeed = 16
    local currentJump = 50

    -- Speed slider functionality
    local draggingSpeed = false
    speedHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSpeed = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSpeed = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and draggingSpeed then
            local relativeX = input.Position.X - speedSlider.AbsolutePosition.X
            local percentage = math.clamp(relativeX / speedSlider.AbsoluteSize.X, 0, 1)
            currentSpeed = math.floor(percentage * 100)
            speedLabel.Text = "Walk Speed: " .. currentSpeed
            speedFill.Size = UDim2.new(percentage, 0, 1, 0)
            speedHandle.Position = UDim2.new(percentage, -10, 0, 0)
            
            -- Apply speed to character
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed
            end
        end
    end)

    -- Jump slider functionality
    local draggingJump = false
    jumpHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingJump = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingJump = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and draggingJump then
            local relativeX = input.Position.X - jumpSlider.AbsolutePosition.X
            local percentage = math.clamp(relativeX / jumpSlider.AbsoluteSize.X, 0, 1)
            currentJump = math.floor(percentage * 500)
            jumpLabel.Text = "Jump Power: " .. currentJump
            jumpFill.Size = UDim2.new(percentage, 0, 1, 0)
            jumpHandle.Position = UDim2.new(percentage, -10, 0, 0)
            
            -- Apply jump power to character
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = currentJump
            end
        end
    end)

    -- Reset buttons
    speedResetBtn.MouseButton1Click:Connect(function()
        currentSpeed = 16
        speedLabel.Text = "Walk Speed: " .. currentSpeed
        speedFill.Size = UDim2.new(0.16, 0, 1, 0)
        speedHandle.Position = UDim2.new(0.16, -10, 0, 0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed
        end
        Notify("Features", "Walk speed reset to 16")
    end)

    jumpResetBtn.MouseButton1Click:Connect(function()
        currentJump = 50
        jumpLabel.Text = "Jump Power: " .. currentJump
        jumpFill.Size = UDim2.new(0.1, 0, 1, 0)
        jumpHandle.Position = UDim2.new(0.1, -10, 0, 0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = currentJump
        end
        Notify("Features", "Jump power reset to 50")
    end)

    -- Enhancement callbacks
    altarToggleBtn.MouseButton1Click:Connect(function()
        Enhancement.autoActivateAltar = not Enhancement.autoActivateAltar
        altarToggleBtn.Text = Enhancement.autoActivateAltar and "ON" or "OFF"
        altarToggleBtn.BackgroundColor3 = Enhancement.autoActivateAltar and Color3.fromRGB(100,200,100) or Color3.fromRGB(160,60,60)
        Notify("Enhancement", "🏛️ Auto Activate Altar: " .. (Enhancement.autoActivateAltar and "Enabled" or "Disabled"))
    end)

    rollToggleBtn.MouseButton1Click:Connect(function()
        Enhancement.autoRollEnchant = not Enhancement.autoRollEnchant
        rollToggleBtn.Text = Enhancement.autoRollEnchant and "ON" or "OFF"
        rollToggleBtn.BackgroundColor3 = Enhancement.autoRollEnchant and Color3.fromRGB(100,200,100) or Color3.fromRGB(160,60,60)
        Notify("Enhancement", "🎲 Auto Roll Enchant: " .. (Enhancement.autoRollEnchant and "Enabled" or "Disabled"))
    end)

    -- Teleport Button Callback
    teleportBtn.MouseButton1Click:Connect(function()
        TeleportToAltar()
    end)

    enhancementStartBtn.MouseButton1Click:Connect(function()
        if Enhancement.enabled then
            Notify("Enhancement", "Enhancement already running")
            return
        end
        Enhancement.enabled = true
        Enhancement.sessionId = (Enhancement.sessionId or 0) + 1
        task.spawn(function() EnhancementRunner(Enhancement.sessionId) end)
    end)

    enhancementStopBtn.MouseButton1Click:Connect(function()
        Enhancement.enabled = false
        Enhancement.sessionId = (Enhancement.sessionId or 0) + 1
        Enhancement.isEnchanting = false
        Enhancement.currentRolls = 0
        Notify("Enhancement", "🛑 Enhancement stopped")
    end)

    -- Movement Enhancement Button Callbacks
    floatToggleBtn.MouseButton1Click:Connect(function()
        if MovementEnhancement.floatEnabled then
            DisableFloat()
            floatToggleBtn.Text = "OFF"
            floatToggleBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
        else
            EnableFloat()
            floatToggleBtn.Text = "ON"
            floatToggleBtn.BackgroundColor3 = Color3.fromRGB(60,160,60)
        end
    end)

    noClipToggleBtn.MouseButton1Click:Connect(function()
        if MovementEnhancement.noClipEnabled then
            DisableNoClip()
            noClipToggleBtn.Text = "OFF"
            noClipToggleBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
        else
            EnableNoClip()
            noClipToggleBtn.Text = "ON"
            noClipToggleBtn.BackgroundColor3 = Color3.fromRGB(60,160,60)
        end
    end)

    heightInput.FocusLost:Connect(function()
        local height = tonumber(heightInput.Text)
        if height and height >= 5 and height <= 100 then
            MovementEnhancement.floatHeight = height
            Notify("Movement", "🚀 Float height set to: " .. height)
        else
            heightInput.Text = tostring(MovementEnhancement.floatHeight)
            Notify("Movement", "❌ Invalid height! Use 5-100")
        end
    end)

    -- Auto Spinner Toggle Event
    spinnerToggleBtn.MouseButton1Click:Connect(function()
        if MovementEnhancement.spinnerEnabled then
            DisableAutoSpinner()
            spinnerToggleBtn.Text = "OFF"
            spinnerToggleBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
        else
            EnableAutoSpinner()
            spinnerToggleBtn.Text = "ON"
            spinnerToggleBtn.BackgroundColor3 = Color3.fromRGB(60,160,60)
        end
    end)

    -- Spinner Speed Input Event
    speedInput.FocusLost:Connect(function()
        local speed = tonumber(speedInput.Text)
        if speed and speed > 0 and speed <= 10 then
            MovementEnhancement.spinnerSpeed = speed
            Notify("Movement", "🌪️ Spinner speed set to: " .. speed)
        else
            speedInput.Text = tostring(MovementEnhancement.spinnerSpeed)
            Notify("Movement", "❌ Invalid speed! Use 0.1-10")
        end
    end)

    -- Direction Toggle Event
    directionBtn.MouseButton1Click:Connect(function()
        MovementEnhancement.spinnerDirection = MovementEnhancement.spinnerDirection * -1
        if MovementEnhancement.spinnerDirection == 1 then
            directionBtn.Text = "⟲ Clockwise"
        else
            directionBtn.Text = "⟳ Counter-CW"
        end
        Notify("Movement", "🌪️ Spinner direction changed")
    end)

    -- Weather Callbacks
    -- Weather dropdown functionality (simplified)
    local currentWeatherIndex = 1
    weatherDropdown.MouseButton1Click:Connect(function()
        -- Cycle through weather types
        currentWeatherIndex = currentWeatherIndex + 1
        if currentWeatherIndex > #Weather.weatherTypes then
            currentWeatherIndex = 1
        end
        
        Weather.selectedWeather = Weather.weatherTypes[currentWeatherIndex]
        weatherDropdown.Text = Weather.selectedWeather .. " ▼"
        
        -- Show/hide Buy All button based on selection
        buyAllBtn.Visible = (Weather.selectedWeather == "All")
        
        Notify("Weather", "Selected weather: " .. Weather.selectedWeather)
    end)

    -- Auto Purchase toggle
    purchaseToggleBtn.MouseButton1Click:Connect(function()
        Weather.autoPurchase = not Weather.autoPurchase
        purchaseToggleBtn.Text = Weather.autoPurchase and "ON" or "OFF"
        purchaseToggleBtn.BackgroundColor3 = Weather.autoPurchase and Color3.fromRGB(100,200,100) or Color3.fromRGB(160,60,60)
        Notify("Weather", "💰 Auto Purchase Weather: " .. (Weather.autoPurchase and "Enabled" or "Disabled"))
    end)

    -- Weather Start button
    weatherStartBtn.MouseButton1Click:Connect(function()
        if Weather.enabled then
            Notify("Weather", "Weather system already running")
            return
        end
        Weather.enabled = true
        Weather.sessionId = (Weather.sessionId or 0) + 1
        task.spawn(function() WeatherRunner(Weather.sessionId) end)
    end)

    -- Weather Stop button
    weatherStopBtn.MouseButton1Click:Connect(function()
        Weather.enabled = false
        Weather.sessionId = (Weather.sessionId or 0) + 1
        Notify("Weather", "🛑 Weather system stopped")
    end)

    -- Buy All Weather button (Manual Purchase)
    buyAllBtn.MouseButton1Click:Connect(function()
        if not purchaseWeatherEventRemote then
            Notify("Weather", "❌ Weather purchase remote not available")
            return
        end
        
        -- Disable button temporarily to prevent spam
        buyAllBtn.Text = "🔄 Purchasing..."
        buyAllBtn.BackgroundColor3 = Color3.fromRGB(128,128,128)
        
        task.spawn(function()
            local allWeatherTypes = {"Rain", "Storm", "Sunny", "Cloudy", "Fog", "Wind"}
            local successCount = 0
            local totalCount = #allWeatherTypes
            
            Notify("Weather", "🌈 Starting manual purchase of all weather types...")
            
            for i, weatherType in ipairs(allWeatherTypes) do
                local ok, res = pcall(function()
                    return purchaseWeatherEventRemote:InvokeServer(weatherType)
                end)
                
                if ok then
                    successCount = successCount + 1
                    Notify("Weather", string.format("✅ %s purchased (%d/%d)", weatherType, successCount, totalCount))
                else
                    Notify("Weather", string.format("❌ Failed to purchase %s", weatherType))
                end
                
                -- Wait between purchases
                if i < totalCount then
                    task.wait(1)
                end
            end
            
            Notify("Weather", string.format("🌈 Manual purchase completed! Success: %d/%d", successCount, totalCount))
            
            -- Re-enable button
            buyAllBtn.Text = "🌈 Buy All Weather Now"
            buyAllBtn.BackgroundColor3 = Color3.fromRGB(255,140,0)
        end)
    end)

    -- Auto-apply features when character spawns
    local function applyFeaturesToCharacter()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed
            LocalPlayer.Character.Humanoid.JumpPower = currentJump
        end
    end

    -- Apply features when character spawns
    LocalPlayer.CharacterAdded:Connect(function()
        LocalPlayer.Character:WaitForChild("Humanoid")
        task.wait(0.1)
        applyFeaturesToCharacter()
    end)

    -- Dashboard Tab Content
    local dashboardFrame = Instance.new("Frame", contentContainer)
    dashboardFrame.Size = UDim2.new(1, 0, 1, -10)
    dashboardFrame.Position = UDim2.new(0, 0, 0, 0)
    dashboardFrame.BackgroundTransparency = 1
    dashboardFrame.Visible = false

    local dashboardTitle = Instance.new("TextLabel", dashboardFrame)
    dashboardTitle.Size = UDim2.new(1, 0, 0, 24)
    dashboardTitle.Text = "Fishing Analytics & Statistics"
    dashboardTitle.Font = Enum.Font.GothamBold
    dashboardTitle.TextSize = 16
    dashboardTitle.TextColor3 = Color3.fromRGB(235,235,235)
    dashboardTitle.BackgroundTransparency = 1
    dashboardTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Create scrollable frame for dashboard
    local dashboardScrollFrame = Instance.new("ScrollingFrame", dashboardFrame)
    dashboardScrollFrame.Size = UDim2.new(1, 0, 1, -30)
    dashboardScrollFrame.Position = UDim2.new(0, 0, 0, 30)
    dashboardScrollFrame.BackgroundColor3 = Color3.fromRGB(35,35,42)
    dashboardScrollFrame.BorderSizePixel = 0
    dashboardScrollFrame.ScrollBarThickness = 6
    dashboardScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80,80,80)
    Instance.new("UICorner", dashboardScrollFrame)

    -- Session Stats Section
    local sessionSection = Instance.new("Frame", dashboardScrollFrame)
    sessionSection.Size = UDim2.new(1, -10, 0, 120)
    sessionSection.Position = UDim2.new(0, 5, 0, 5)
    sessionSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    sessionSection.BorderSizePixel = 0
    Instance.new("UICorner", sessionSection)

    local sessionTitle = Instance.new("TextLabel", sessionSection)
    sessionTitle.Size = UDim2.new(1, -20, 0, 25)
    sessionTitle.Position = UDim2.new(0, 10, 0, 5)
    sessionTitle.Text = "📈 Current Session Stats"
    sessionTitle.Font = Enum.Font.GothamBold
    sessionTitle.TextSize = 14
    sessionTitle.TextColor3 = Color3.fromRGB(100,200,255)
    sessionTitle.BackgroundTransparency = 1
    sessionTitle.TextXAlignment = Enum.TextXAlignment.Left

    local sessionFishCount = Instance.new("TextLabel", sessionSection)
    sessionFishCount.Size = UDim2.new(0.5, -15, 0, 20)
    sessionFishCount.Position = UDim2.new(0, 10, 0, 35)
    sessionFishCount.Text = "🎣 Total Fish: 0"
    sessionFishCount.Font = Enum.Font.GothamSemibold
    sessionFishCount.TextSize = 12
    sessionFishCount.TextColor3 = Color3.fromRGB(255,255,255)
    sessionFishCount.BackgroundTransparency = 1
    sessionFishCount.TextXAlignment = Enum.TextXAlignment.Left

    local sessionRareCount = Instance.new("TextLabel", sessionSection)
    sessionRareCount.Size = UDim2.new(0.5, -15, 0, 20)
    sessionRareCount.Position = UDim2.new(0.5, 5, 0, 35)
    sessionRareCount.Text = "✨ Rare Fish: 0"
    sessionRareCount.Font = Enum.Font.GothamSemibold
    sessionRareCount.TextSize = 12
    sessionRareCount.TextColor3 = Color3.fromRGB(255,215,0)
    sessionRareCount.BackgroundTransparency = 1
    sessionRareCount.TextXAlignment = Enum.TextXAlignment.Left

    local sessionTime = Instance.new("TextLabel", sessionSection)
    sessionTime.Size = UDim2.new(0.5, -15, 0, 20)
    sessionTime.Position = UDim2.new(0, 10, 0, 60)
    sessionTime.Text = "⏱️ Session: 0m 0s"
    sessionTime.Font = Enum.Font.GothamSemibold
    sessionTime.TextSize = 12
    sessionTime.TextColor3 = Color3.fromRGB(200,200,200)
    sessionTime.BackgroundTransparency = 1
    sessionTime.TextXAlignment = Enum.TextXAlignment.Left

    local sessionLocation = Instance.new("TextLabel", sessionSection)
    sessionLocation.Size = UDim2.new(0.5, -15, 0, 20)
    sessionLocation.Position = UDim2.new(0.5, 5, 0, 60)
    sessionLocation.Text = "🗺️ Location: Unknown"
    sessionLocation.Font = Enum.Font.GothamSemibold
    sessionLocation.TextSize = 12
    sessionLocation.TextColor3 = Color3.fromRGB(150,255,150)
    sessionLocation.BackgroundTransparency = 1
    sessionLocation.TextXAlignment = Enum.TextXAlignment.Left

    local sessionEfficiency = Instance.new("TextLabel", sessionSection)
    sessionEfficiency.Size = UDim2.new(1, -20, 0, 20)
    sessionEfficiency.Position = UDim2.new(0, 10, 0, 85)
    sessionEfficiency.Text = "🎯 Rare Rate: 0% | ⚡ Fish/Min: 0.0"
    sessionEfficiency.Font = Enum.Font.GothamSemibold
    sessionEfficiency.TextSize = 12
    sessionEfficiency.TextColor3 = Color3.fromRGB(255,165,0)
    sessionEfficiency.BackgroundTransparency = 1
    sessionEfficiency.TextXAlignment = Enum.TextXAlignment.Left

    -- Fish Rarity Tracker Section
    local raritySection = Instance.new("Frame", dashboardScrollFrame)
    raritySection.Size = UDim2.new(1, -10, 0, 180)
    raritySection.Position = UDim2.new(0, 5, 0, 135)
    raritySection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    raritySection.BorderSizePixel = 0
    Instance.new("UICorner", raritySection)

    local rarityTitle = Instance.new("TextLabel", raritySection)
    rarityTitle.Size = UDim2.new(1, -20, 0, 25)
    rarityTitle.Position = UDim2.new(0, 10, 0, 5)
    rarityTitle.Text = "🏆 Fish Rarity Tracker"
    rarityTitle.Font = Enum.Font.GothamBold
    rarityTitle.TextSize = 14
    rarityTitle.TextColor3 = Color3.fromRGB(255,200,100)
    rarityTitle.BackgroundTransparency = 1
    rarityTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Rarity bars (Updated for real fish data)
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
        
        local rarityLabel = Instance.new("TextLabel", raritySection)
        rarityLabel.Size = UDim2.new(0.3, -10, 0, 18)
        rarityLabel.Position = UDim2.new(0, 10, 0, yPos)
        rarityLabel.Text = rarity.icon .. " " .. rarity.name
        rarityLabel.Font = Enum.Font.GothamSemibold
        rarityLabel.TextSize = 10
        rarityLabel.TextColor3 = rarity.color
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.TextXAlignment = Enum.TextXAlignment.Left

        local rarityBar = Instance.new("Frame", raritySection)
        rarityBar.Size = UDim2.new(0.5, -10, 0, 12)
        rarityBar.Position = UDim2.new(0.3, 5, 0, yPos + 3)
        rarityBar.BackgroundColor3 = Color3.fromRGB(60,60,70)
        rarityBar.BorderSizePixel = 0
        Instance.new("UICorner", rarityBar)

        local rarityFill = Instance.new("Frame", rarityBar)
        rarityFill.Size = UDim2.new(0, 0, 1, 0)
        rarityFill.Position = UDim2.new(0, 0, 0, 0)
        rarityFill.BackgroundColor3 = rarity.color
        rarityFill.BorderSizePixel = 0
        Instance.new("UICorner", rarityFill)

        local rarityCount = Instance.new("TextLabel", raritySection)
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

    -- Location Heatmap Section
    local heatmapSection = Instance.new("Frame", dashboardScrollFrame)
    heatmapSection.Size = UDim2.new(1, -10, 0, 200)
    heatmapSection.Position = UDim2.new(0, 5, 0, 325)
    heatmapSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    heatmapSection.BorderSizePixel = 0
    Instance.new("UICorner", heatmapSection)

    local heatmapTitle = Instance.new("TextLabel", heatmapSection)
    heatmapTitle.Size = UDim2.new(1, -20, 0, 25)
    heatmapTitle.Position = UDim2.new(0, 10, 0, 5)
    heatmapTitle.Text = "🗺️ Location Efficiency Heatmap"
    heatmapTitle.Font = Enum.Font.GothamBold
    heatmapTitle.TextSize = 14
    heatmapTitle.TextColor3 = Color3.fromRGB(100,255,150)
    heatmapTitle.BackgroundTransparency = 1
    heatmapTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Create location efficiency display
    local locationList = Instance.new("ScrollingFrame", heatmapSection)
    locationList.Size = UDim2.new(1, -20, 1, -35)
    locationList.Position = UDim2.new(0, 10, 0, 30)
    locationList.BackgroundColor3 = Color3.fromRGB(35,35,42)
    locationList.BorderSizePixel = 0
    locationList.ScrollBarThickness = 4
    locationList.ScrollBarImageColor3 = Color3.fromRGB(80,80,80)
    Instance.new("UICorner", locationList)

    -- Optimal Times Section
    local timesSection = Instance.new("Frame", dashboardScrollFrame)
    timesSection.Size = UDim2.new(1, -10, 0, 160)
    timesSection.Position = UDim2.new(0, 5, 0, 535)
    timesSection.BackgroundColor3 = Color3.fromRGB(45,45,52)
    timesSection.BorderSizePixel = 0
    Instance.new("UICorner", timesSection)

    local timesTitle = Instance.new("TextLabel", timesSection)
    timesTitle.Size = UDim2.new(1, -20, 0, 25)
    timesTitle.Position = UDim2.new(0, 10, 0, 5)
    timesTitle.Text = "⏰ Optimal Fishing Times"
    timesTitle.Font = Enum.Font.GothamBold
    timesTitle.TextSize = 14
    timesTitle.TextColor3 = Color3.fromRGB(255,200,100)
    timesTitle.BackgroundTransparency = 1
    timesTitle.TextXAlignment = Enum.TextXAlignment.Left

    local bestTimeLabel = Instance.new("TextLabel", timesSection)
    bestTimeLabel.Size = UDim2.new(1, -20, 0, 20)
    bestTimeLabel.Position = UDim2.new(0, 10, 0, 35)
    bestTimeLabel.Text = "🏆 Best Time: Not enough data"
    bestTimeLabel.Font = Enum.Font.GothamSemibold
    bestTimeLabel.TextSize = 12
    bestTimeLabel.TextColor3 = Color3.fromRGB(255,215,0)
    bestTimeLabel.BackgroundTransparency = 1
    bestTimeLabel.TextXAlignment = Enum.TextXAlignment.Left

    local currentTimeLabel = Instance.new("TextLabel", timesSection)
    currentTimeLabel.Size = UDim2.new(1, -20, 0, 20)
    currentTimeLabel.Position = UDim2.new(0, 10, 0, 60)
    currentTimeLabel.Text = "🕐 Current Hour: " .. os.date("%H:00")
    currentTimeLabel.Font = Enum.Font.GothamSemibold
    currentTimeLabel.TextSize = 12
    currentTimeLabel.TextColor3 = Color3.fromRGB(150,255,150)
    currentTimeLabel.BackgroundTransparency = 1
    currentTimeLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Time efficiency chart (simplified bars)
    local timeChart = Instance.new("Frame", timesSection)
    timeChart.Size = UDim2.new(1, -20, 0, 70)
    timeChart.Position = UDim2.new(0, 10, 0, 85)
    timeChart.BackgroundColor3 = Color3.fromRGB(35,35,42)
    timeChart.BorderSizePixel = 0
    Instance.new("UICorner", timeChart)

    -- Create time bars for 24 hours
    local timeBars = {}
    for hour = 0, 23 do
        local x = (hour / 24) * (timeChart.AbsoluteSize.X - 20) + 10
        local timeBar = Instance.new("Frame", timeChart)
        timeBar.Size = UDim2.new(0, 8, 0, 2)
        timeBar.Position = UDim2.new(hour/24, 2, 1, -15)
        timeBar.BackgroundColor3 = Color3.fromRGB(100,100,120)
        timeBar.BorderSizePixel = 0
        timeBars[hour] = timeBar
    end

    -- Set canvas size for dashboard scroll
    dashboardScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 720)

    -- floating toggle
    -- Floating toggle: keep margin so it doesn't overlap header on small screens
    local floatBtn = Instance.new("TextButton", screenGui); floatBtn.Name = "FloatToggle"; floatBtn.Size = UDim2.new(0,50,0,50); floatBtn.Position = UDim2.new(0,15,0,15); floatBtn.Text = "🎣"; Instance.new("UICorner", floatBtn)
    floatBtn.BackgroundColor3 = Color3.fromRGB(45,45,52); floatBtn.Font = Enum.Font.GothamBold; floatBtn.TextSize = 20; floatBtn.TextColor3 = Color3.fromRGB(100,200,255)
    floatBtn.Visible = false  -- Initially hidden
    
    -- Hover effects for floating button
    floatBtn.MouseEnter:Connect(function()
        floatBtn.BackgroundColor3 = Color3.fromRGB(60,120,180)
        floatBtn.TextColor3 = Color3.fromRGB(255,255,255)
    end)
    floatBtn.MouseLeave:Connect(function()
        floatBtn.BackgroundColor3 = Color3.fromRGB(45,45,52)
        floatBtn.TextColor3 = Color3.fromRGB(100,200,255)
    end)
    
    floatBtn.MouseButton1Click:Connect(function() 
        panel.Visible = true  -- Show main panel
        floatBtn.Visible = false  -- Hide floating button
        Notify("modern_autofish", "Restored from floating mode")
    end)

    -- Teleport functions
    local function TeleportTo(position)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
            Notify("Teleport", "Teleported successfully")
        else
            Notify("Teleport", "Character not found")
        end
    end

    -- Sell All behavior: call remote if present
    sellBtn.MouseButton1Click:Connect(function()
        local sellRemote = ResolveRemote("RF/SellAllItems")
        if not sellRemote then
            Notify("SellAll", "Sell remote not found")
            return
        end
        local ok, res = pcall(function()
            if sellRemote:IsA("RemoteFunction") then return sellRemote:InvokeServer() else sellRemote:FireServer() end
        end)
        if ok then Notify("SellAll", "SellAll invoked") else Notify("SellAll", "SellAll failed: " .. tostring(res)) end
    end)

    -- Auto Reconnect Toggle
    reconnectToggle.MouseButton1Click:Connect(function()
        NetworkManager.autoReconnect = not NetworkManager.autoReconnect
        if NetworkManager.autoReconnect then
            reconnectToggle.Text = "ON"
            reconnectToggle.BackgroundColor3 = Color3.fromRGB(80,200,80)
            reconnectStatus.Text = "Status: Enabled - Monitoring connection"
            reconnectStatus.TextColor3 = Color3.fromRGB(80,200,80)
            Notify("Network", "🌐 Auto Reconnect enabled")
            -- Start monitoring
            MonitorConnection()
        else
            reconnectToggle.Text = "OFF"
            reconnectToggle.BackgroundColor3 = Color3.fromRGB(80,80,80)
            reconnectStatus.Text = "Status: Disabled"
            reconnectStatus.TextColor3 = Color3.fromRGB(150,150,150)
            NetworkManager.currentAttempts = 0 -- Reset attempts
            Notify("Network", "🌐 Auto Reconnect disabled")
        end
    end)

    -- Manual Reconnect Button
    reconnectManualBtn.MouseButton1Click:Connect(function()
        if not reconnectPlayerRemote then
            Notify("Network", "❌ Reconnect remote not available")
            return
        end
        
        reconnectManualBtn.Text = "🔄 Connecting..."
        reconnectManualBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
        
        task.spawn(function()
            local success = pcall(function()
                reconnectPlayerRemote:FireServer()
            end)
            
            task.wait(2) -- Wait for reconnect attempt
            
            if success then
                Notify("Network", "✅ Manual reconnect signal sent")
                reconnectStatus.Text = "Status: Reconnect signal sent"
                reconnectStatus.TextColor3 = Color3.fromRGB(80,200,80)
            else
                Notify("Network", "❌ Failed to send reconnect signal")
                reconnectStatus.Text = "Status: Reconnect failed"
                reconnectStatus.TextColor3 = Color3.fromRGB(200,80,80)
            end
            
            -- Reset button
            reconnectManualBtn.Text = "🔄 Reconnect"
            reconnectManualBtn.BackgroundColor3 = Color3.fromRGB(70,130,255)
        end)
    end)

    -- Robust tab switching: collect tabs and provide SwitchTo
    local Tabs = { FishingAI = fishingAIFrame, Teleport = teleportFrame, Player = playerFrame, Feature = featureFrame, Dashboard = dashboardFrame }
    local function SwitchTo(name)
        for k, v in pairs(Tabs) do
            v.Visible = (k == name)
        end
        
        -- Update tab colors and content title
        if name == "FishingAI" then
            fishingAITabBtn.BackgroundColor3 = Color3.fromRGB(45,45,50)
            fishingAITabBtn.TextColor3 = Color3.fromRGB(235,235,235)
            teleportTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            teleportTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            playerTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            playerTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            featureTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            featureTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            dashboardTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            dashboardTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            contentTitle.Text = "Smart AI Fishing Configuration"
        elseif name == "Teleport" then
            teleportTabBtn.BackgroundColor3 = Color3.fromRGB(45,45,50)
            teleportTabBtn.TextColor3 = Color3.fromRGB(235,235,235)
            fishingAITabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            fishingAITabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            playerTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            playerTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            featureTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            featureTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            dashboardTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            dashboardTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            contentTitle.Text = "Island Locations"
        elseif name == "Player" then
            playerTabBtn.BackgroundColor3 = Color3.fromRGB(45,45,50)
            playerTabBtn.TextColor3 = Color3.fromRGB(235,235,235)
            fishingAITabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            fishingAITabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            teleportTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            teleportTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            featureTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            featureTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            dashboardTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            dashboardTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            contentTitle.Text = "Player Teleport"
            updatePlayerList(searchBox.Text) -- Refresh when switching to player tab
        elseif name == "Feature" then
            featureTabBtn.BackgroundColor3 = Color3.fromRGB(45,45,50)
            featureTabBtn.TextColor3 = Color3.fromRGB(235,235,235)
            fishingAITabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            fishingAITabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            teleportTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            teleportTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            playerTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            playerTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            dashboardTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            dashboardTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            contentTitle.Text = "Character Features"
        else -- Dashboard
            dashboardTabBtn.BackgroundColor3 = Color3.fromRGB(45,45,50)
            dashboardTabBtn.TextColor3 = Color3.fromRGB(235,235,235)
            fishingAITabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            fishingAITabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            teleportTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            teleportTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            playerTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            playerTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            featureTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
            featureTabBtn.TextColor3 = Color3.fromRGB(200,200,200)
            contentTitle.Text = "Fishing Analytics"
        end
    end

    fishingAITabBtn.MouseButton1Click:Connect(function() SwitchTo("FishingAI") end)
    teleportTabBtn.MouseButton1Click:Connect(function() SwitchTo("Teleport") end)
    playerTabBtn.MouseButton1Click:Connect(function() SwitchTo("Player") end)
    featureTabBtn.MouseButton1Click:Connect(function() SwitchTo("Feature") end)
    dashboardTabBtn.MouseButton1Click:Connect(function() SwitchTo("Dashboard") end)

    -- Start with FishingAI visible (replaces Main)
    SwitchTo("FishingAI")

    -- Secure mode button callback
    secureButton.MouseButton1Click:Connect(function() 
        Config.mode = "secure"
        modeStatus.Text = "🔒 Current: Secure Mode Active"
        modeStatus.TextColor3 = Color3.fromRGB(100,255,150)
        Notify("modern_autofish", "🔒 Secure Mode activated - Safe & reliable fishing!") 
    end)

    -- Secure stop button callback
    secureStopButton.MouseButton1Click:Connect(function()
        Config.enabled = false
        sessionId = sessionId + 1
        modeStatus.Text = "🔒 Secure Mode Ready - Safe & Reliable Fishing"
        modeStatus.TextColor3 = Color3.fromRGB(100,255,150)
        Notify("modern_autofish", "🛑 Secure Mode stopped")
    end)

    -- New: Auto Mode button callbacks
    autoModeStartButton.MouseButton1Click:Connect(function()
        if Config.autoModeEnabled then return end -- Prevent multiple loops
        Config.autoModeEnabled = true
        autoModeSessionId = autoModeSessionId + 1
        autoModeStatus.Text = "🔥 Auto Mode Running..."
        autoModeStatus.TextColor3 = Color3.fromRGB(100, 255, 150)
        task.spawn(function() AutoModeRunner(autoModeSessionId) end)
    end)

    autoModeStopButton.MouseButton1Click:Connect(function()
        if not Config.autoModeEnabled then return end
        Config.autoModeEnabled = false
        autoModeSessionId = autoModeSessionId + 1 -- Invalidate current loop
        autoModeStatus.Text = "🔥 Auto Mode Ready"
        autoModeStatus.TextColor3 = Color3.fromRGB(220, 70, 70)
    end)

    -- AntiAFK toggle
    antiAfkToggle.MouseButton1Click:Connect(function()
        AntiAFK.enabled = not AntiAFK.enabled
        Config.antiAfkEnabled = AntiAFK.enabled
        
        if AntiAFK.enabled then
            antiAfkToggle.Text = "🟢 ON"
            antiAfkToggle.BackgroundColor3 = Color3.fromRGB(70,170,90)
            antiAfkLabel.Text = "🛡️ AntiAFK Protection: Enabled"
            antiAfkLabel.TextColor3 = Color3.fromRGB(100,255,150)
            
            AntiAFK.sessionId = AntiAFK.sessionId + 1
            task.spawn(function() AntiAfkRunner(AntiAFK.sessionId) end)
        else
            antiAfkToggle.Text = "🔴 OFF"
            antiAfkToggle.BackgroundColor3 = Color3.fromRGB(160,60,60)
            antiAfkLabel.Text = "🛡️ AntiAFK Protection: Disabled"
            antiAfkLabel.TextColor3 = Color3.fromRGB(200,200,200)
            
            AntiAFK.sessionId = AntiAFK.sessionId + 1
        end
    end)

    -- Smart AI button callback
    smartButtonAI.MouseButton1Click:Connect(function()
        if Config.enabled then
            -- Jika sudah running, stop dulu
            Config.enabled = false
            sessionId = sessionId + 1
            task.wait(0.1) -- Wait for current cycle to stop
        end
        
        -- Set ke Smart AI mode
        Config.mode = "smart"
        aiStatusLabel.Text = "🧠 Smart AI Mode Running..."
        aiStatusLabel.TextColor3 = Color3.fromRGB(100,255,150)
        
        -- Auto start Smart AI fishing
        Config.enabled = true
        sessionId = sessionId + 1
        task.spawn(function() AutofishRunner(sessionId) end)
        
        Notify("modern_autofish", "🧠 Smart AI Mode activated and started!")
    end)

    -- Stop Smart AI button callback
    stopButtonAI.MouseButton1Click:Connect(function()
        Config.enabled = false
        sessionId = sessionId + 1
        -- Send fishing stopped signal to server
        if fishingStoppedRemote then
            pcall(function() fishingStoppedRemote:FireServer() end)
        end
        -- Auto unequip rod when stopping
        AutoUnequipRod()
        aiStatusLabel.Text = "⏸️ Smart AI Ready (Click Start to begin)"
        aiStatusLabel.TextColor3 = Color3.fromRGB(200,200,200)
        Notify("modern_autofish", "🛑 Smart AI stopped and rod unequipped!")
    end)

    -- Minimize to floating mode
    minimizeBtn.MouseButton1Click:Connect(function()
        panel.Visible = false  -- Hide main panel
        floatBtn.Visible = true  -- Show floating button
        Notify("modern_autofish", "Minimized to floating mode")
    end)

    closeBtn.MouseButton1Click:Connect(function()
        Config.enabled = false; sessionId = sessionId + 1
        Config.autoModeEnabled = false; autoModeSessionId = autoModeSessionId + 1
        AntiAFK.enabled = false; AntiAFK.sessionId = AntiAFK.sessionId + 1
        -- Send fishing stopped signal to server when closing
        if fishingStoppedRemote then
            pcall(function() fishingStoppedRemote:FireServer() end)
        end
        -- Auto unequip rod when closing
        AutoUnequipRod()
        Notify("modern_autofish", "ModernAutoFish closed and rod unequipped")
        if screenGui and screenGui.Parent then screenGui:Destroy() end
    end)

    -- Secure mode button callbacks
    secureButton.MouseButton1Click:Connect(function() 
        Config.mode = "secure"
        Config.enabled = true
        sessionId = sessionId + 1
        modeStatus.Text = "🔒 Secure Mode Running..."
        modeStatus.TextColor3 = Color3.fromRGB(100,255,150)
        task.spawn(function() AutofishRunner(sessionId) end)
        Notify("modern_autofish", "🔒 Secure Mode started - Safe & reliable fishing!") 
    end)

    secureStopButton.MouseButton1Click:Connect(function()
        Config.enabled = false
        sessionId = sessionId + 1
        -- Send fishing stopped signal to server
        if fishingStoppedRemote then
            pcall(function() fishingStoppedRemote:FireServer() end)
        end
        -- Auto unequip rod when stopping
        AutoUnequipRod()
        modeStatus.Text = "🔒 Secure Mode Ready - Safe & Reliable Fishing"
        modeStatus.TextColor3 = Color3.fromRGB(100,255,150)
        Notify("modern_autofish", "🛑 Secure Mode stopped and rod unequipped")
    end)

    -- Note: Old start/stop and control buttons removed - now using Secure mode buttons in Fishing AI tab

    Notify("modern_autofish", "UI ready - Secure Mode available in Fishing AI tab")

    -- Dashboard Update Functions
    local function UpdateDashboard()
        if not dashboardFrame.Visible then return end
        
        -- Debug: Print current stats
        print("[Dashboard] Updating stats - Fish:", Dashboard.sessionStats.fishCount, "Rare:", Dashboard.sessionStats.rareCount)
        
        -- Update session stats
        local currentTime = tick()
        local sessionDuration = currentTime - Dashboard.sessionStats.startTime
        local minutes = math.floor(sessionDuration / 60)
        local seconds = math.floor(sessionDuration % 60)
        
        sessionFishCount.Text = "🎣 Total Fish: " .. Dashboard.sessionStats.fishCount
        sessionRareCount.Text = "✨ Rare Fish: " .. Dashboard.sessionStats.rareCount
        sessionTime.Text = string.format("⏱️ Session: %dm %ds", minutes, seconds)
        sessionLocation.Text = "🗺️ Location: " .. Dashboard.sessionStats.currentLocation
        
        -- Calculate efficiency
        local rareRate = Dashboard.sessionStats.fishCount > 0 and 
                        math.floor((Dashboard.sessionStats.rareCount / Dashboard.sessionStats.fishCount) * 100) or 0
        local fishPerMin = sessionDuration > 0 and (Dashboard.sessionStats.fishCount / (sessionDuration / 60)) or 0
        sessionEfficiency.Text = string.format("🎯 Rare Rate: %d%% | ⚡ Fish/Min: %.1f", rareRate, fishPerMin)
        
        -- Update rarity bars
        local rarityCounts = {}
        for rarityName, fishList in pairs(FishRarity) do
            rarityCounts[rarityName] = 0
        end
        
        for _, fish in pairs(Dashboard.fishCaught) do
            rarityCounts[fish.rarity] = (rarityCounts[fish.rarity] or 0) + 1
        end
        
        local maxCount = math.max(1, Dashboard.sessionStats.fishCount)
        for rarityName, bar in pairs(rarityBars) do
            local count = rarityCounts[rarityName] or 0
            local percentage = count / maxCount
            bar.fill.Size = UDim2.new(percentage, 0, 1, 0)
            bar.count.Text = tostring(count)
        end
        
        -- Update location efficiency list
        for _, child in pairs(locationList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        local yPos = 5
        for location, stats in pairs(Dashboard.locationStats) do
            local efficiency = GetLocationEfficiency(location)
            local locationFrame = Instance.new("Frame", locationList)
            locationFrame.Size = UDim2.new(1, -10, 0, 25)
            locationFrame.Position = UDim2.new(0, 5, 0, yPos)
            locationFrame.BackgroundColor3 = Color3.fromRGB(50,50,60)
            locationFrame.BorderSizePixel = 0
            Instance.new("UICorner", locationFrame)
            
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
        local bestHour, bestPercent = GetBestFishingTime()
        if bestPercent > 0 then
            bestTimeLabel.Text = string.format("🏆 Best Time: %02d:00 (%d%% rare rate)", bestHour, bestPercent)
        else
            bestTimeLabel.Text = "🏆 Best Time: Not enough data"
        end
        
        currentTimeLabel.Text = "🕐 Current Hour: " .. os.date("%H:00")
        
        -- Update time bars
        for hour, bar in pairs(timeBars) do
            local data = Dashboard.optimalTimes[hour]
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

    -- Auto-update dashboard every 2 seconds
    local function DashboardUpdater()
        while true do
            if dashboardFrame and dashboardFrame.Visible then
                pcall(UpdateDashboard)
            end
            task.wait(2)
        end
    end
    task.spawn(DashboardUpdater)

    -- Update current location when teleporting
    for islandName, cframe in pairs(islandLocations) do
        -- Find existing teleport button and wrap its click function
        for _, btn in pairs(buttons) do
            if btn.Text == islandName then
                local originalClick = btn.MouseButton1Click
                btn.MouseButton1Click:Connect(function()
                    Dashboard.sessionStats.currentLocation = islandName:gsub("🏝️", ""):gsub("🦈 ", ""):gsub("🎣 ", ""):gsub("❄️ ", ""):gsub("🌋 ", ""):gsub("🌴 ", ""):gsub("🗿 ", ""):gsub("⚙️ ", "")
                end)
                break
            end
        end
    end
end

-- Build UI and ready
BuildUI()

-- Setup real fish event listener
SetupFishCaughtListener()

-- Start location tracker
task.spawn(LocationTracker)

-- Expose quick API on _G for convenience
_G.ModernAutoFish = {
    Start = function() if not Config.enabled then Config.enabled = true; sessionId = sessionId + 1; task.spawn(function() AutofishRunner(sessionId) end) end end,
    Stop = function() Config.enabled = false; sessionId = sessionId + 1 end,
    SetMode = function(m) if m == "secure" or m == "smart" then Config.mode = m end end,
    ToggleAntiAFK = function() 
        AntiAFK.enabled = not AntiAFK.enabled
        if AntiAFK.enabled then
            AntiAFK.sessionId = AntiAFK.sessionId + 1
            task.spawn(function() AntiAfkRunner(AntiAFK.sessionId) end)
        else
            AntiAFK.sessionId = AntiAFK.sessionId + 1
        end
    end,
    
    -- Dashboard API
    LogFish = LogFishCatch,
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
    SetLocation = function(loc) Dashboard.sessionStats.currentLocation = loc end,
    
    -- AutoSell API
    ToggleAutoSell = function() AutoSell.enabled = not AutoSell.enabled end,
    SetSellThreshold = function(threshold) 
        if threshold > 0 and threshold <= 1000 then 
            AutoSell.threshold = threshold
            -- Sync with server
            task.spawn(function()
                SyncAutoSellThresholdWithServer(threshold)
            end)
        end 
    end,
    GetSellThreshold = function() return AutoSell.threshold end,
    GetServerThreshold = function() return AutoSell.serverThreshold end,
    IsThresholdSynced = function() return AutoSell.isThresholdSynced end,
    SyncThreshold = function(threshold) 
        if threshold then
            return SyncAutoSellThresholdWithServer(threshold)
        else
            return SyncAutoSellThresholdWithServer(AutoSell.threshold)
        end
    end,
    GetSyncStatus = function() 
        return {
            isThresholdSynced = AutoSell.isThresholdSynced,
            serverThreshold = AutoSell.serverThreshold,
            localThreshold = AutoSell.threshold,
            lastSyncTime = AutoSell.lastSyncTime,
            syncRetries = AutoSell.syncRetries
        }
    end,
    SetRarityFilter = function(rarity, enabled) if AutoSell.allowedRarities[rarity] ~= nil then AutoSell.allowedRarities[rarity] = enabled end end,
    GetAutoSellStatus = function() return AutoSell end,
    ForceAutoSell = function() if AutoSell.enabled then CheckAndAutoSell() end end,
    
    Config = Config,
    AntiAFK = AntiAFK,
    Dashboard = Dashboard,
    Enhancement = Enhancement,
    AutoSell = AutoSell,
    MovementEnhancement = MovementEnhancement,
    
    -- Enhancement API
    StartEnhancement = function() 
        Enhancement.enabled = true
        Enhancement.sessionId = (Enhancement.sessionId or 0) + 1
        task.spawn(function() EnhancementRunner(Enhancement.sessionId) end)
    end,
    StopEnhancement = function() 
        Enhancement.enabled = false
        Enhancement.sessionId = (Enhancement.sessionId or 0) + 1
    end,
    ActivateAltar = ActivateEnchantingAltar,
    RollEnchant = RollEnchant,
    
    -- Movement Enhancement API
    EnableFloat = EnableFloat,
    DisableFloat = DisableFloat,
    EnableNoClip = EnableNoClip,
    DisableNoClip = DisableNoClip,
    ToggleFloat = function() 
        if MovementEnhancement.floatEnabled then 
            DisableFloat() 
        else 
            EnableFloat() 
        end 
    end,
    ToggleNoClip = function() 
        if MovementEnhancement.noClipEnabled then 
            DisableNoClip() 
        else 
            EnableNoClip() 
        end 
    end,
    SetFloatHeight = function(height) 
        if height and height >= 5 and height <= 100 then 
            MovementEnhancement.floatHeight = height 
        end 
    end,
    GetMovementStatus = function() 
        return {
            floatEnabled = MovementEnhancement.floatEnabled,
            noClipEnabled = MovementEnhancement.noClipEnabled,
            floatHeight = MovementEnhancement.floatHeight,
            spinnerEnabled = MovementEnhancement.spinnerEnabled,
            spinnerSpeed = MovementEnhancement.spinnerSpeed,
            spinnerDirection = MovementEnhancement.spinnerDirection
        }
    end,

    -- Auto Spinner API
    EnableAutoSpinner = EnableAutoSpinner,
    DisableAutoSpinner = DisableAutoSpinner,
    ToggleAutoSpinner = function()
        if MovementEnhancement.spinnerEnabled then
            DisableAutoSpinner()
        else
            EnableAutoSpinner()
        end
    end,
    SetSpinnerSpeed = function(speed)
        if speed and speed > 0 and speed <= 10 then
            MovementEnhancement.spinnerSpeed = speed
        end
    end,
    ToggleSpinnerDirection = function()
        MovementEnhancement.spinnerDirection = MovementEnhancement.spinnerDirection * -1
    end,
    GetSpinnerStatus = function()
        return {
            enabled = MovementEnhancement.spinnerEnabled,
            speed = MovementEnhancement.spinnerSpeed,
            direction = MovementEnhancement.spinnerDirection
        }
    end
}

-- Initialize AutoSell server sync
InitializeAutoSellSync()

print("modern_autofish loaded - UI created and API available via _G.ModernAutoFish")