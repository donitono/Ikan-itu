-- playerTab.lua
-- Player Tab Module for ModernAutoFish

local PlayerTab = {}

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load dependencies
local BaseUI = require(script.Parent.baseUI)
local Utils = require(script.Parent.Parent.core.utils)
local Config = require(script.Parent.Parent.core.config)

function PlayerTab.Create(contentContainer)
    local frame = Instance.new("Frame", contentContainer)
    frame.Name = "PlayerFrame"
    frame.Size = UDim2.new(1, 0, 1, -10)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false

    -- Search box for players
    local searchBox = Instance.new("TextBox", frame)
    searchBox.Size = UDim2.new(1, 0, 0, 28)
    searchBox.Position = UDim2.new(0, 0, 0, 30)
    searchBox.PlaceholderText = "Search player..."
    searchBox.Text = ""
    searchBox.Font = Enum.Font.GothamSemibold
    searchBox.TextSize = 12
    searchBox.BackgroundColor3 = Color3.fromRGB(45,45,52)
    searchBox.TextColor3 = Color3.fromRGB(255,255,255)
    searchBox.BorderSizePixel = 0
    Utils.CreateCorner(searchBox)

    local scrollFrame = BaseUI.CreateScrollFrame(
        frame, 
        UDim2.new(0, 0, 0, 65), 
        UDim2.new(1, 0, 1, -65)
    )

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
            if not filter or filter == "" or 
               string.lower(player.Name):find(string.lower(filter)) or 
               string.lower(player.DisplayName):find(string.lower(filter)) then
                
                local playerBtn = BaseUI.CreateButton(
                    scrollFrame,
                    UDim2.new(0, 5, 0, yPos),
                    UDim2.new(1, -10, 0, 32),
                    "🎮 " .. player.DisplayName .. " (@" .. player.Name .. ")",
                    player == LocalPlayer and Color3.fromRGB(100,150,100) or Color3.fromRGB(80,120,180),
                    function()
                        if player ~= LocalPlayer then
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and 
                               LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                Utils.TeleportTo(player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3))
                                Utils.Notify("Player Teleport", "Teleported to " .. player.DisplayName)
                            else
                                Utils.Notify("Player Teleport", "Cannot teleport to " .. player.DisplayName .. " - Character not found")
                            end
                        end
                    end
                )
                
                playerBtn.TextXAlignment = Enum.TextXAlignment.Left
                Utils.CreatePadding(playerBtn, 8)
                
                if player == LocalPlayer then
                    playerBtn.Text = "🎮 " .. player.DisplayName .. " (@" .. player.Name .. ") [YOU]"
                end
                
                table.insert(playerButtons, playerBtn)
                yPos = yPos + 37
            end
        end
        
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end

    -- Search functionality
    searchBox.Changed:Connect(function(property)
        if property == "Text" then
            updatePlayerList(searchBox.Text)
        end
    end)

    -- Auto-refresh player list every 5 seconds
    local function autoRefreshPlayers()
        while frame.Parent do
            if frame.Visible then
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
        if frame.Visible then
            updatePlayerList(searchBox.Text)
        end
    end)
    
    Players.PlayerRemoving:Connect(function()
        if frame.Visible then
            task.wait(0.1)
            updatePlayerList(searchBox.Text)
        end
    end)

    return frame, {
        updatePlayerList = updatePlayerList,
        searchBox = searchBox
    }
end

return PlayerTab
