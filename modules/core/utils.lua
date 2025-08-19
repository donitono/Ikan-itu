-- utils.lua
-- Utility functions for ModernAutoFish

local Utils = {}

-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- Simple notifier
function Utils.Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 4})
    end)
    print("[modern_autofish]", title, text)
end

-- Remote helper (best-effort)
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

function Utils.ResolveRemote(name)
    local net = Utils.FindNet()
    if not net then return nil end
    local ok, rem = pcall(function() return net:FindFirstChild(name) end)
    return ok and rem or nil
end

function Utils.SafeInvoke(remote, ...)
    if not remote then return false, "nil_remote" end
    if remote:IsA("RemoteFunction") then
        return pcall(function(...) return remote:InvokeServer(...) end, ...)
    else
        return pcall(function(...) remote:FireServer(...) return true end, ...)
    end
end

-- Get fish rarity
function Utils.GetFishRarity(fishName, fishRarity)
    for rarity, fishList in pairs(fishRarity) do
        for _, fish in pairs(fishList) do
            if string.find(string.lower(fishName), string.lower(fish)) then
                return rarity
            end
        end
    end
    return "COMMON"
end

-- Location detection based on player position
function Utils.DetectCurrentLocation()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return "Unknown"
    end
    
    local pos = LocalPlayer.Character.HumanoidRootPart.Position
    
    -- Location detection based on position ranges
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

-- Create UI Corner
function Utils.CreateCorner(parent, radius)
    local corner = Instance.new("UICorner", parent)
    if radius then
        corner.CornerRadius = UDim.new(0, radius)
    end
    return corner
end

-- Create UI Stroke
function Utils.CreateStroke(parent, thickness, color)
    local stroke = Instance.new("UIStroke", parent)
    stroke.Thickness = thickness or 1
    stroke.Color = color or Color3.fromRGB(40,40,48)
    return stroke
end

-- Create UI Padding
function Utils.CreatePadding(parent, left, right, top, bottom)
    local padding = Instance.new("UIPadding", parent)
    if left then padding.PaddingLeft = UDim.new(0, left) end
    if right then padding.PaddingRight = UDim.new(0, right) end
    if top then padding.PaddingTop = UDim.new(0, top) end
    if bottom then padding.PaddingBottom = UDim.new(0, bottom) end
    return padding
end

-- Teleport function
function Utils.TeleportTo(position)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = position
        Utils.Notify("Teleport", "Teleported successfully")
        return true
    else
        Utils.Notify("Teleport", "Character not found")
        return false
    end
end

-- Get server time
function Utils.GetServerTime()
    local ok, st = pcall(function() return workspace:GetServerTimeNow() end)
    if ok and type(st) == "number" then return st end
    return tick()
end

-- Generate random timing for realistic behavior
function Utils.GetRealisticTiming(phase)
    local timings = {
        charging = {min = 0.8, max = 1.5},
        casting = {min = 0.2, max = 0.4},
        waiting = {min = 2.0, max = 4.0},
        reeling = {min = 1.0, max = 2.5},
        holding = {min = 0.5, max = 1.0}
    }
    
    local timing = timings[phase] or {min = 0.5, max = 1.0}
    return timing.min + math.random() * (timing.max - timing.min)
end

-- Format time for display
function Utils.FormatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%dm %ds", minutes, secs)
end

return Utils
