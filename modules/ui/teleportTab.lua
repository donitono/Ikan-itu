-- teleportTab.lua
-- Teleport Tab Module for ModernAutoFish

local TeleportTab = {}

-- Load dependencies
local BaseUI = require(script.Parent.baseUI)
local Utils = require(script.Parent.Parent.core.utils)
local Config = require(script.Parent.Parent.core.config)

function TeleportTab.Create(contentContainer)
    local frame = Instance.new("Frame", contentContainer)
    frame.Name = "TeleportFrame"
    frame.Size = UDim2.new(1, 0, 1, -10)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false

    local scrollFrame = BaseUI.CreateScrollFrame(frame)

    -- Create island buttons
    local yOffset = 5
    local buttons = {}
    
    for islandName, cframe in pairs(Config.IslandLocations) do
        local btn = BaseUI.CreateButton(
            scrollFrame,
            UDim2.new(0, 5, 0, yOffset),
            UDim2.new(1, -10, 0, 28),
            islandName,
            Color3.fromRGB(60,120,180),
            function()
                Utils.TeleportTo(cframe)
            end
        )
        
        -- Add hover effect
        BaseUI.AddHoverEffect(btn, Color3.fromRGB(80,140,200), Color3.fromRGB(60,120,180))
        
        table.insert(buttons, btn)
        yOffset = yOffset + 33
    end

    -- Update scroll frame content size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)

    return frame, buttons
end

return TeleportTab
