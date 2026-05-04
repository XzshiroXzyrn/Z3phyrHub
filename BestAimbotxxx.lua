--// SAFE PROTECTION LAYER (Prevents detection without crashing)
local function ProtectInstance(instance)
    pcall(function()
        if gethui then
            instance.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(instance)
            instance.Parent = game:GetService("CoreGui")
        else
            instance.Parent = game:GetService("CoreGui")
        end
    end)
end

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Settings & Variables
local Settings = {
    AimbotEnabled = false,
    FovChangeAim = false,
    EspEnabled = false,
    TeamCheck = true,
    AliveCheck = true,
    WallCheck = true,
    Streamable = false,
    FovRadius = 100,
    PredictionAmount = 1.65, 
    SnapStrength = 1, 
    FovColor = Color3.fromRGB(255, 255, 255),
    AimPart = "Head",
    Platform = "PC" 
}

local InitialFOV = Camera.FieldOfView
local EspTable = {}

--// Create FOV Circle
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Thickness = 1
FovCircle.Color = Settings.FovColor
FovCircle.Filled = false
FovCircle.Radius = Settings.FovRadius
FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

--// GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Xz_" .. math.random(1000, 9999) -- Randomized Name
ScreenGui.ResetOnSpawn = false
ProtectInstance(ScreenGui) -- Protect the GUI from being seen by scripts

-- Restore Button
local RestoreButton = Instance.new("TextButton")
RestoreButton.Size = UDim2.new(0, 150, 0, 40)
RestoreButton.Position = UDim2.new(0.5, -75, 0, 20)
RestoreButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
RestoreButton.BackgroundTransparency = 0.4
RestoreButton.Text = "Xzshiro's Aimbot"
RestoreButton.TextColor3 = Color3.new(1, 1, 1)
RestoreButton.Font = Enum.Font.SourceSansBold
RestoreButton.TextSize = 16
RestoreButton.Visible = false
RestoreButton.Parent = ScreenGui
Instance.new("UICorner", RestoreButton).CornerRadius = UDim.new(0, 8)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 600) 
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- SCI-FI ANIMATED TITLE
local SciFiTitle = Instance.new("TextLabel")
SciFiTitle.Name = "SciFiTitle"
SciFiTitle.Size = UDim2.new(1, 0, 0, 40)
SciFiTitle.Position = UDim2.new(0, 0, 0, 35)
SciFiTitle.BackgroundTransparency = 1
SciFiTitle.Text = "Xzshiro Aimbot"
SciFiTitle.Font = Enum.Font.SciFi 
SciFiTitle.TextSize = 24
SciFiTitle.TextColor3 = Color3.new(1, 1, 1)
SciFiTitle.Parent = MainFrame

-- Decoration Dots
local function CreateDot(color, xOffset)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, xOffset, 0, 12)
    dot.BackgroundColor3 = color
    dot.Parent = MainFrame
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
end
CreateDot(Color3.fromRGB(255, 95, 87), 15)
CreateDot(Color3.fromRGB(255, 189, 46), 35)
CreateDot(Color3.fromRGB(40, 200, 64), 55)

-- Close Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 5)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "×"
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.TextSize = 25
MinimizeBtn.Parent = MainFrame

-- UI List Layout
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -40, 1, -100)
Container.Position = UDim2.new(0, 20, 0, 80)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Container
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateStyledButton(text, parent)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 38)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.BackgroundTransparency = 0.2
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.SourceSansSemibold
    b.TextSize = 16
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local function CreateStyledInput(text, placeholder, parent)
    local i = Instance.new("TextBox")
    i.Size = UDim2.new(1, 0, 0, 38)
    i.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    i.BackgroundTransparency = 0.2
    i.Text = text
    i.PlaceholderText = placeholder
    i.TextColor3 = Color3.new(1, 1, 1)
    i.Font = Enum.Font.SourceSans
    i.TextSize = 14
    i.Parent = parent
    Instance.new("UICorner", i).CornerRadius = UDim.new(0, 6)
    return i
end

-- Elements
local ToggleBtn = CreateStyledButton("Aimbot: Off", Container)
local FovChangeBtn = CreateStyledButton("FOV Change Aim: Off", Container)
local EspBtn = CreateStyledButton("ESP: Off", Container)
local TeamToggleBtn = CreateStyledButton("Team Check: On", Container)
local AliveToggleBtn = CreateStyledButton("Alive Check: On", Container)
local WallToggleBtn = CreateStyledButton("Wall Check: On", Container)
local StreamToggleBtn = CreateStyledButton("Streamable: Off", Container)

local FovInput = CreateStyledInput("FOV: " .. Settings.FovRadius, "Set FOV...", Container)

-- Pred and Snap Row
local PredSnapFrame = Instance.new("Frame")
PredSnapFrame.Size = UDim2.new(1, 0, 0, 38)
PredSnapFrame.BackgroundTransparency = 1
PredSnapFrame.Parent = Container

local PredictionInput = CreateStyledInput("Pred: " .. Settings.PredictionAmount, "Lead", PredSnapFrame)
PredictionInput.Size = UDim2.new(0.5, -5, 1, 0)
PredictionInput.Position = UDim2.new(0, 0, 0, 0)

local SnapInput = CreateStyledInput("Snap: " .. Settings.SnapStrength, "Snap (0.1-1)", PredSnapFrame)
SnapInput.Size = UDim2.new(0.5, -5, 1, 0)
SnapInput.Position = UDim2.new(0.5, 5, 0, 0)

-- Platform Switcher
local PlatformFrame = Instance.new("Frame")
PlatformFrame.Size = UDim2.new(1, 0, 0, 40)
PlatformFrame.BackgroundTransparency = 1
PlatformFrame.Parent = Container

local MobileBtn = CreateStyledButton("Mobile", PlatformFrame)
MobileBtn.Size = UDim2.new(0.5, -5, 1, 0)
MobileBtn.Position = UDim2.new(0, 0, 0, 0)

local PcBtn = CreateStyledButton("PC", PlatformFrame)
PcBtn.Size = UDim2.new(0.5, -5, 1, 0)
PcBtn.Position = UDim2.new(0.5, 5, 0, 0)

--// Logic
local function UpdatePlatformVisuals()
    PcBtn.BackgroundColor3 = Settings.Platform == "PC" and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(40, 40, 40)
    MobileBtn.BackgroundColor3 = Settings.Platform == "Mobile" and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(40, 40, 40)
end
UpdatePlatformVisuals()

PcBtn.MouseButton1Click:Connect(function() Settings.Platform = "PC" UpdatePlatformVisuals() end)
MobileBtn.MouseButton1Click:Connect(function() Settings.Platform = "Mobile" UpdatePlatformVisuals() end)

MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false RestoreButton.Visible = true end)
RestoreButton.MouseButton1Click:Connect(function() MainFrame.Visible = true RestoreButton.Visible = false end)

ToggleBtn.MouseButton1Click:Connect(function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    ToggleBtn.Text = "Aimbot: " .. (Settings.AimbotEnabled and "On" or "Off")
end)

FovChangeBtn.MouseButton1Click:Connect(function()
    Settings.FovChangeAim = not Settings.FovChangeAim
    FovChangeBtn.Text = "FOV Change Aim: " .. (Settings.FovChangeAim and "On" or "Off")
end)

EspBtn.MouseButton1Click:Connect(function()
    Settings.EspEnabled = not Settings.EspEnabled
    EspBtn.Text = "ESP: " .. (Settings.EspEnabled and "On" or "Off")
end)

TeamToggleBtn.MouseButton1Click:Connect(function()
    Settings.TeamCheck = not Settings.TeamCheck
    TeamToggleBtn.Text = "Team Check: " .. (Settings.TeamCheck and "On" or "Off")
end)

AliveToggleBtn.MouseButton1Click:Connect(function()
    Settings.AliveCheck = not Settings.AliveCheck
    AliveToggleBtn.Text = "Alive Check: " .. (Settings.AliveCheck and "On" or "Off")
end)

WallToggleBtn.MouseButton1Click:Connect(function()
    Settings.WallCheck = not Settings.WallCheck
    WallToggleBtn.Text = "Wall Check: " .. (Settings.WallCheck and "On" or "Off")
end)

StreamToggleBtn.MouseButton1Click:Connect(function()
    Settings.Streamable = not Settings.Streamable
    StreamToggleBtn.Text = "Streamable: " .. (Settings.Streamable and "On" or "Off")
end)

FovInput.FocusLost:Connect(function()
    local val = tonumber(FovInput.Text:match("%d+%.?%d*"))
    if val then Settings.FovRadius = val FovCircle.Radius = val end
    FovInput.Text = "FOV: " .. tostring(Settings.FovRadius)
end)

PredictionInput.FocusLost:Connect(function()
    local val = tonumber(PredictionInput.Text:match("%d+%.?%d*"))
    if val then Settings.PredictionAmount = val end
    PredictionInput.Text = "Pred: " .. tostring(Settings.PredictionAmount)
end)

SnapInput.FocusLost:Connect(function()
    local val = tonumber(SnapInput.Text:match("%d+%.?%d*"))
    if val then Settings.SnapStrength = math.clamp(val, 0.01, 1) end
    SnapInput.Text = "Snap: " .. tostring(Settings.SnapStrength)
end)

--// ESP Functions
local function CreateEsp(player)
    if EspTable[player] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "XzHighlight"
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "XzHealth"
    billboard.Size = UDim2.new(4, 0, 0.5, 0)
    billboard.AlwaysOnTop = true
    billboard.ExtentsOffset = Vector3.new(0, 3, 0)
    billboard.Enabled = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.Parent = billboard
    
    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(1, 0, 1, 0)
    bar.BackgroundColor3 = Color3.new(0, 1, 0)
    bar.BorderSizePixel = 0
    bar.Parent = frame

    EspTable[player] = {Highlight = highlight, Billboard = billboard}
end

local function RemoveEsp(player)
    if EspTable[player] then
        pcall(function()
            EspTable[player].Highlight:Destroy()
            EspTable[player].Billboard:Destroy()
        end)
        EspTable[player] = nil
    end
end

Players.PlayerAdded:Connect(CreateEsp)
Players.PlayerRemoving:Connect(RemoveEsp)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateEsp(p) end end

--// Aimbot Calculation
local function GetClosestPlayer()
    local closest = nil
    local shortestDist = Settings.FovRadius
    
    local ScreenCenter = (Settings.Platform == "PC") 
        and UserInputService:GetMouseLocation() 
        or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            local char = player.Character
            if char and char:FindFirstChild(Settings.AimPart) then
                local hum = char:FindFirstChild("Humanoid")
                if Settings.AliveCheck and hum and hum.Health <= 0 then continue end
                
                if Settings.WallCheck then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
                    local rayCast = workspace:Raycast(Camera.CFrame.Position, (char[Settings.AimPart].Position - Camera.CFrame.Position), rayParams)
                    if rayCast and rayCast.Instance and rayCast.Instance.CanCollide then continue end 
                end

                local pos, onScreen = Camera:WorldToViewportPoint(char[Settings.AimPart].Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - ScreenCenter).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = char[Settings.AimPart]
                    end
                end
            end
        end
    end
    return closest
end

--// Main Loop
RunService.RenderStepped:Connect(function()
    -- TITLE ANIMATION
    local t = (math.sin(tick() * 3) + 1) / 2 
    SciFiTitle.TextColor3 = Color3.new(1, 1, 1):Lerp(Color3.new(0, 1, 0), t)

    local ScreenCenter = (Settings.Platform == "PC") 
        and UserInputService:GetMouseLocation() 
        or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    FovCircle.Position = ScreenCenter
    FovCircle.Visible = Settings.AimbotEnabled and not Settings.Streamable
    
    -- ESP Logic
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        local data = EspTable[player]
        
        if char and data then
            local hum = char:FindFirstChild("Humanoid")
            local head = char:FindFirstChild("Head")

            if Settings.EspEnabled then
                data.Highlight.Parent = char
                data.Highlight.Enabled = true
                data.Highlight.FillColor = (Settings.TeamCheck and player.Team == LocalPlayer.Team) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                
                if head then
                    data.Billboard.Parent = head
                    data.Billboard.Enabled = true
                    if hum then
                        data.Billboard.Frame.Bar.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
                    end
                else
                    data.Billboard.Enabled = false
                end
            else
                data.Highlight.Enabled = false
                data.Billboard.Enabled = false
            end
        elseif data then
            data.Highlight.Enabled = false
            data.Billboard.Enabled = false
        end
    end

    -- Aimbot Execution
    if Settings.AimbotEnabled then
        if Settings.FovChangeAim and math.abs(Camera.FieldOfView - InitialFOV) < 1 then
            return
        end

        local target = GetClosestPlayer()
        if target and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or Settings.Platform == "Mobile") then 
            local targetPos = target.Position
            local root = target.Parent:FindFirstChild("HumanoidRootPart")
            if root then
                local velocity = root.Velocity
                local distance = (target.Position - Camera.CFrame.Position).Magnitude
                
                if velocity.Magnitude > 0.1 then
                    local predictionOffset = velocity * (distance / (1000 / Settings.PredictionAmount))
                    targetPos = targetPos + predictionOffset
                end
            end

            local currentSnapToUse = Settings.SnapStrength
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
            if onScreen then
                local distToCrosshair = (Vector2.new(screenPos.X, screenPos.Y) - ScreenCenter).Magnitude
                if distToCrosshair < 10 then currentSnapToUse = 1 end
            end
            
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, currentSnapToUse)
        end
    end
end)
