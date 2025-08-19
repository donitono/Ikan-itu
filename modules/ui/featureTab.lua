-- featureTab.lua
-- Feature Tab Module for ModernAutoFish

local FeatureTab = {}

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load dependencies
local BaseUI = require(script.Parent.baseUI)
local Utils = require(script.Parent.Parent.core.utils)
local Config = require(script.Parent.Parent.core.config)

function FeatureTab.Create(contentContainer, movementSystem, enhancementSystem, networkSystem)
    local frame = Instance.new("Frame", contentContainer)
    frame.Name = "FeatureFrame"
    frame.Size = UDim2.new(1, 0, 1, -10)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false

    local scrollFrame = BaseUI.CreateScrollFrame(frame)

    -- Speed Control Section
    local speedSection = BaseUI.CreateSection(
        scrollFrame,
        UDim2.new(0, 5, 0, 5),
        UDim2.new(1, -10, 0, 80),
        nil
    )
    
    FeatureTab.CreateSpeedControl(speedSection)

    -- Jump Control Section
    local jumpSection = BaseUI.CreateSection(
        scrollFrame,
        UDim2.new(0, 5, 0, 95),
        UDim2.new(1, -10, 0, 80),
        nil
    )
    
    FeatureTab.CreateJumpControl(jumpSection)

    -- Movement Enhancement Section
    if movementSystem then
        local movementSection = BaseUI.CreateSection(
            scrollFrame,
            UDim2.new(0, 5, 0, 185),
            UDim2.new(1, -10, 0, 240),
            "🚀 Movement Enhancement",
            Color3.fromRGB(255,255,255)
        )
        
        FeatureTab.CreateMovementControls(movementSection, movementSystem)
    end

    -- Enhancement Section
    if enhancementSystem then
        local enhancementSection = BaseUI.CreateSection(
            scrollFrame,
            UDim2.new(0, 5, 0, 435),
            UDim2.new(1, -10, 0, 150),
            "🔮 Auto Enhancement System",
            Color3.fromRGB(255,140,255)
        )
        
        FeatureTab.CreateEnhancementControls(enhancementSection, enhancementSystem)
    end

    -- Network Section
    if networkSystem then
        local networkSection = BaseUI.CreateSection(
            scrollFrame,
            UDim2.new(0, 5, 0, 595),
            UDim2.new(1, -10, 0, 80),
            "🌐 Network Management",
            Color3.fromRGB(100,200,255)
        )
        
        FeatureTab.CreateNetworkControls(networkSection, networkSystem)
    end

    -- Set canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 700)

    return frame
end

function FeatureTab.CreateSpeedControl(parent)
    local speedLabel = Instance.new("TextLabel", parent)
    speedLabel.Size = UDim2.new(1, -20, 0, 20)
    speedLabel.Position = UDim2.new(0, 10, 0, 8)
    speedLabel.Text = "Walk Speed: 16"
    speedLabel.Font = Enum.Font.GothamSemibold
    speedLabel.TextSize = 14
    speedLabel.TextColor3 = Config.Colors.Text
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left

    local currentSpeed = 16
    
    -- Create slider
    local slider = FeatureTab.CreateSlider(
        parent,
        UDim2.new(0, 10, 0, 35),
        UDim2.new(1, -80, 0, 20),
        0.16, -- 16/100
        Color3.fromRGB(100,150,255),
        function(percentage)
            currentSpeed = math.floor(percentage * 100)
            speedLabel.Text = "Walk Speed: " .. currentSpeed
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed
            end
        end
    )

    local resetBtn = BaseUI.CreateButton(
        parent,
        UDim2.new(1, -70, 0, 58),
        UDim2.new(0, 60, 0, 18),
        "Reset",
        Color3.fromRGB(160,60,60),
        function()
            currentSpeed = 16
            speedLabel.Text = "Walk Speed: " .. currentSpeed
            slider.setPercentage(0.16)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed
            end
            Utils.Notify("Features", "Walk speed reset to 16")
        end
    )
end

function FeatureTab.CreateJumpControl(parent)
    local jumpLabel = Instance.new("TextLabel", parent)
    jumpLabel.Size = UDim2.new(1, -20, 0, 20)
    jumpLabel.Position = UDim2.new(0, 10, 0, 8)
    jumpLabel.Text = "Jump Power: 50"
    jumpLabel.Font = Enum.Font.GothamSemibold
    jumpLabel.TextSize = 14
    jumpLabel.TextColor3 = Config.Colors.Text
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left

    local currentJump = 50
    
    -- Create slider
    local slider = FeatureTab.CreateSlider(
        parent,
        UDim2.new(0, 10, 0, 35),
        UDim2.new(1, -80, 0, 20),
        0.1, -- 50/500
        Color3.fromRGB(100,255,150),
        function(percentage)
            currentJump = math.floor(percentage * 500)
            jumpLabel.Text = "Jump Power: " .. currentJump
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = currentJump
            end
        end
    )

    local resetBtn = BaseUI.CreateButton(
        parent,
        UDim2.new(1, -70, 0, 58),
        UDim2.new(0, 60, 0, 18),
        "Reset",
        Color3.fromRGB(160,60,60),
        function()
            currentJump = 50
            jumpLabel.Text = "Jump Power: " .. currentJump
            slider.setPercentage(0.1)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = currentJump
            end
            Utils.Notify("Features", "Jump power reset to 50")
        end
    )
end

function FeatureTab.CreateSlider(parent, position, size, initialPercentage, fillColor, callback)
    local sliderFrame = Instance.new("Frame", parent)
    sliderFrame.Size = size
    sliderFrame.Position = position
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,60)
    sliderFrame.BorderSizePixel = 0
    Utils.CreateCorner(sliderFrame)

    local fill = Instance.new("Frame", sliderFrame)
    fill.Size = UDim2.new(initialPercentage, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = fillColor
    fill.BorderSizePixel = 0
    Utils.CreateCorner(fill)

    local handle = Instance.new("TextButton", sliderFrame)
    handle.Size = UDim2.new(0, 20, 1, 0)
    handle.Position = UDim2.new(initialPercentage, -10, 0, 0)
    handle.Text = ""
    handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    handle.BorderSizePixel = 0
    Utils.CreateCorner(handle)

    -- Slider functionality
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local relativeX = input.Position.X - sliderFrame.AbsolutePosition.X
            local percentage = math.clamp(relativeX / sliderFrame.AbsoluteSize.X, 0, 1)
            
            fill.Size = UDim2.new(percentage, 0, 1, 0)
            handle.Position = UDim2.new(percentage, -10, 0, 0)
            
            if callback then
                callback(percentage)
            end
        end
    end)

    return {
        setPercentage = function(percentage)
            percentage = math.clamp(percentage, 0, 1)
            fill.Size = UDim2.new(percentage, 0, 1, 0)
            handle.Position = UDim2.new(percentage, -10, 0, 0)
        end
    }
end

function FeatureTab.CreateMovementControls(parent, movementSystem)
    local yPos = 30
    
    -- Float Controls
    FeatureTab.CreateMovementToggle(
        parent, yPos, "🚀 Float", "Enable Float (WASD + Space/Shift to move)",
        function(enabled)
            if enabled then
                movementSystem.EnableFloat()
            else
                movementSystem.DisableFloat()
            end
        end
    )
    yPos = yPos + 45
    
    -- No Clip Controls
    FeatureTab.CreateMovementToggle(
        parent, yPos, "👻 No Clip", "Walk through walls",
        function(enabled)
            if enabled then
                movementSystem.EnableNoClip()
            else
                movementSystem.DisableNoClip()
            end
        end
    )
    yPos = yPos + 45
    
    -- Auto Spinner Controls
    FeatureTab.CreateMovementToggle(
        parent, yPos, "🌪️ Auto Spinner", "Randomize fishing direction",
        function(enabled)
            if enabled then
                movementSystem.EnableAutoSpinner()
            else
                movementSystem.DisableAutoSpinner()
            end
        end
    )
    yPos = yPos + 30
    
    -- Spinner Controls
    FeatureTab.CreateSpinnerControls(parent, yPos, movementSystem)
end

function FeatureTab.CreateMovementToggle(parent, yPos, title, description, callback)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -20, 0, 15)
    label.Position = UDim2.new(0, 10, 0, yPos)
    label.Text = title .. " (" .. description .. ")"
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(200,200,200)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = BaseUI.CreateToggleButton(
        parent,
        UDim2.new(1, -70, 0, yPos + 20),
        UDim2.new(0, 60, 0, 20),
        "OFF",
        false,
        callback
    )
end

function FeatureTab.CreateSpinnerControls(parent, yPos, movementSystem)
    -- Speed Control
    local speedLabel = Instance.new("TextLabel", parent)
    speedLabel.Size = UDim2.new(0.4, -10, 0, 15)
    speedLabel.Position = UDim2.new(0, 10, 0, yPos)
    speedLabel.Text = "Speed:"
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 10
    speedLabel.TextColor3 = Color3.fromRGB(200,200,200)
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left

    local speedInput = Instance.new("TextBox", parent)
    speedInput.Size = UDim2.new(0, 40, 0, 20)
    speedInput.Position = UDim2.new(0, 50, 0, yPos + 15)
    speedInput.Text = "2"
    speedInput.Font = Enum.Font.Gotham
    speedInput.TextSize = 10
    speedInput.TextColor3 = Color3.fromRGB(255,255,255)
    speedInput.BackgroundColor3 = Color3.fromRGB(35,35,40)
    speedInput.BorderSizePixel = 0
    speedInput.TextXAlignment = Enum.TextXAlignment.Center
    Utils.CreateCorner(speedInput)

    speedInput.FocusLost:Connect(function()
        local speed = tonumber(speedInput.Text)
        if speed and speed > 0 and speed <= 10 then
            movementSystem.SetSpinnerSpeed(speed)
        else
            speedInput.Text = "2"
            Utils.Notify("Movement", "❌ Invalid speed! Use 0.1-10")
        end
    end)

    -- Direction Toggle
    local directionBtn = BaseUI.CreateButton(
        parent,
        UDim2.new(0, 100, 0, yPos + 15),
        UDim2.new(0, 80, 0, 20),
        "⟲ Clockwise",
        Color3.fromRGB(70,70,80),
        function()
            movementSystem.ToggleSpinnerDirection()
            -- Update button text would require additional state management
        end
    )
end

function FeatureTab.CreateEnhancementControls(parent, enhancementSystem)
    -- Implementation for enhancement controls
    -- Similar pattern to movement controls
end

function FeatureTab.CreateNetworkControls(parent, networkSystem)
    -- Implementation for network controls
    -- Similar pattern to other controls
end

return FeatureTab
