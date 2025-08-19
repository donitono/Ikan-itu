-- baseUI.lua
-- Base UI framework for ModernAutoFish

local BaseUI = {}

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load dependencies
local Utils = require(script.Parent.Parent.core.utils)
local Config = require(script.Parent.Parent.core.config)

function BaseUI.CreateMainFrame()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModernAutoFishUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(0, 480, 0, 380)
    panel.Position = UDim2.new(0, 18, 0, 70)
    panel.BackgroundColor3 = Config.Colors.Background
    panel.BorderSizePixel = 0
    panel.Parent = screenGui
    
    Utils.CreateCorner(panel)
    Utils.CreateStroke(panel, 1, Color3.fromRGB(40,40,48))

    return screenGui, panel
end

function BaseUI.CreateHeader(panel)
    local header = Instance.new("Frame", panel)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Active = true
    header.Selectable = true

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -130, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = "🐳Spinner_xxx AutoFish"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Config.Colors.Text
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Button container
    local btnContainer = Instance.new("Frame", header)
    btnContainer.Size = UDim2.new(0, 120, 1, 0)
    btnContainer.Position = UDim2.new(1, -125, 0, 0)
    btnContainer.BackgroundTransparency = 1

    return header, title, btnContainer
end

function BaseUI.CreateHeaderButtons(btnContainer, callbacks)
    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton", btnContainer)
    minimizeBtn.Size = UDim2.new(0, 32, 0, 26)
    minimizeBtn.Position = UDim2.new(0, 4, 0.5, -13)
    minimizeBtn.Text = "−"
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 16
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(60,60,66)
    minimizeBtn.TextColor3 = Color3.fromRGB(230,230,230)
    Utils.CreateCorner(minimizeBtn)

    -- Reload Button
    local reloadBtn = Instance.new("TextButton", btnContainer)
    reloadBtn.Size = UDim2.new(0, 32, 0, 26)
    reloadBtn.Position = UDim2.new(0, 42, 0.5, -13)
    reloadBtn.Text = "🔄"
    reloadBtn.Font = Enum.Font.GothamBold
    reloadBtn.TextSize = 14
    reloadBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    reloadBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Utils.CreateCorner(reloadBtn)

    -- Close Button
    local closeBtn = Instance.new("TextButton", btnContainer)
    closeBtn.Size = UDim2.new(0, 32, 0, 26)
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.Position = UDim2.new(1, -4, 0.5, -13)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Utils.CreateCorner(closeBtn)

    -- Connect callbacks
    if callbacks then
        if callbacks.onMinimize then
            minimizeBtn.MouseButton1Click:Connect(callbacks.onMinimize)
        end
        if callbacks.onReload then
            reloadBtn.MouseButton1Click:Connect(callbacks.onReload)
        end
        if callbacks.onClose then
            closeBtn.MouseButton1Click:Connect(callbacks.onClose)
        end
    end

    -- Hover effects
    BaseUI.AddHoverEffect(reloadBtn, Color3.fromRGB(90, 150, 220), Color3.fromRGB(70, 130, 200))

    return minimizeBtn, reloadBtn, closeBtn
end

function BaseUI.CreateSidebar(panel)
    local sidebar = Instance.new("Frame", panel)
    sidebar.Size = UDim2.new(0, 120, 1, -50)
    sidebar.Position = UDim2.new(0, 10, 0, 45)
    sidebar.BackgroundColor3 = Color3.fromRGB(22,22,28)
    sidebar.BorderSizePixel = 0
    Utils.CreateCorner(sidebar)

    return sidebar
end

function BaseUI.CreateTabButton(parent, position, text, isActive)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, position)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.BackgroundColor3 = isActive and Color3.fromRGB(45,45,50) or Color3.fromRGB(40,40,46)
    btn.TextColor3 = isActive and Color3.fromRGB(235,235,235) or Color3.fromRGB(200,200,200)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    Utils.CreateCorner(btn, 6)
    Utils.CreatePadding(btn, 10)

    return btn
end

function BaseUI.CreateContentArea(panel)
    local contentContainer = Instance.new("Frame", panel)
    contentContainer.Size = UDim2.new(1, -145, 1, -50)
    contentContainer.Position = UDim2.new(0, 140, 0, 45)
    contentContainer.BackgroundTransparency = 1

    local contentTitle = Instance.new("TextLabel", contentContainer)
    contentTitle.Size = UDim2.new(1, 0, 0, 24)
    contentTitle.Text = "Smart AI Fishing Configuration"
    contentTitle.Font = Enum.Font.GothamBold
    contentTitle.TextSize = 16
    contentTitle.TextColor3 = Config.Colors.Text
    contentTitle.BackgroundTransparency = 1
    contentTitle.TextXAlignment = Enum.TextXAlignment.Left

    return contentContainer, contentTitle
end

function BaseUI.CreateScrollFrame(parent, position, size)
    local scrollFrame = Instance.new("ScrollingFrame", parent)
    scrollFrame.Size = size or UDim2.new(1, 0, 1, -30)
    scrollFrame.Position = position or UDim2.new(0, 0, 0, 30)
    scrollFrame.BackgroundColor3 = Config.Colors.Panel
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80,80,80)
    Utils.CreateCorner(scrollFrame)

    return scrollFrame
end

function BaseUI.CreateSection(parent, position, size, title, titleColor)
    local section = Instance.new("Frame", parent)
    section.Size = size
    section.Position = position
    section.BackgroundColor3 = Color3.fromRGB(45,45,52)
    section.BorderSizePixel = 0
    Utils.CreateCorner(section)

    if title then
        local titleLabel = Instance.new("TextLabel", section)
        titleLabel.Size = UDim2.new(1, -20, 0, 25)
        titleLabel.Position = UDim2.new(0, 10, 0, 5)
        titleLabel.Text = title
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 14
        titleLabel.TextColor3 = titleColor or Config.Colors.Text
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    end

    return section
end

function BaseUI.CreateButton(parent, position, size, text, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = size
    btn.Position = position
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.BackgroundColor3 = color or Config.Colors.Button
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    Utils.CreateCorner(btn, 6)

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end

    return btn
end

function BaseUI.CreateToggleButton(parent, position, size, text, initialState, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = size
    btn.Position = position
    btn.Text = initialState and "🟢 " .. text or "🔴 " .. text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BackgroundColor3 = initialState and Config.Colors.Success or Color3.fromRGB(160,60,60)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    Utils.CreateCorner(btn)

    local isEnabled = initialState

    btn.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        btn.Text = isEnabled and "🟢 " .. text or "🔴 " .. text
        btn.BackgroundColor3 = isEnabled and Config.Colors.Success or Color3.fromRGB(160,60,60)
        
        if callback then
            callback(isEnabled)
        end
    end)

    return btn, function() return isEnabled end
end

function BaseUI.CreateFloatingButton(screenGui, callback)
    local floatBtn = Instance.new("TextButton", screenGui)
    floatBtn.Name = "FloatToggle"
    floatBtn.Size = UDim2.new(0,50,0,50)
    floatBtn.Position = UDim2.new(0,15,0,15)
    floatBtn.Text = "🎣"
    floatBtn.BackgroundColor3 = Color3.fromRGB(45,45,52)
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextSize = 20
    floatBtn.TextColor3 = Config.Colors.Accent
    floatBtn.Visible = false
    Utils.CreateCorner(floatBtn)
    
    BaseUI.AddHoverEffect(floatBtn, Color3.fromRGB(60,120,180), Color3.fromRGB(45,45,52))
    
    if callback then
        floatBtn.MouseButton1Click:Connect(callback)
    end
    
    return floatBtn
end

function BaseUI.AddHoverEffect(button, hoverColor, normalColor)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = hoverColor
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = normalColor
    end)
end

function BaseUI.AddDragFunctionality(header, panel)
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
end

return BaseUI
