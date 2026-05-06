--// SIMPLIFIED PROTECTION LAYER
local function ProtectInstance(instance)
    pcall(function()
        if gethui then
            instance.Parent = gethui()
        elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
            instance.Parent = game:GetService("CoreGui")
        else
            instance.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
end

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Settings
local Settings = {
    AimbotEnabled = false,
    OnlyAimOnZoom = false, -- New Feature
    EspEnabled = false,
    TeamCheck = true,
    AliveCheck = true,
    WallCheck = true,
    InvisibleCheck = true,
    ForceFieldCheck = true,
    Streamable = false,
    FovRadius = 100,
    PredictionAmount = 1.65, 
    SnapStrength = 0.15,
    FovColor = Color3.fromRGB(0, 180, 255),
    AimPart = "Head",
    Platform = "PC" 
}

local InitialFOV = Camera.FieldOfView
local EspTable = {}
local Theme = {
    Main = Color3.fromRGB(13, 13, 15),
    Secondary = Color3.fromRGB(20, 20, 23),
    Accent = Color3.fromRGB(0, 180, 255),
    AccentDark = Color3.fromRGB(0, 80, 180), -- For Gradient
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(160, 160, 160),
    Danger = Color3.fromRGB(255, 65, 65)
}

--// User Tag Logic
local function CreateUserTag(Character)
    if not Character then return end
    local Head = Character:WaitForChild("Head", 5)
    if not Head then return end
    
    local Tag = Instance.new("BillboardGui")
    Tag.Name = "XzUserTag"
    Tag.Size = UDim2.new(0, 200, 0, 50)
    Tag.Adornee = Head
    Tag.AlwaysOnTop = true
    Tag.ExtentsOffset = Vector3.new(0, 3, 0)
    
    local Label = Instance.new("TextLabel")
    Label.Parent = Tag
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 0.6
    Label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Label.TextColor3 = Theme.Accent
    Label.Text = "PREMIUM USER"
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    
    Instance.new("UICorner", Label).CornerRadius = UDim.new(0, 8)
    Tag.Parent = Head
end

LocalPlayer.CharacterAdded:Connect(CreateUserTag)
if LocalPlayer.Character then CreateUserTag(LocalPlayer.Character) end

--// FOV Circle
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Thickness = 1.5
FovCircle.Color = Settings.FovColor
FovCircle.Filled = false
FovCircle.Radius = Settings.FovRadius

--// GUI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XzPremium_" .. math.random(1000, 9999)
ScreenGui.ResetOnSpawn = false
ProtectInstance(ScreenGui)

-- Restore Button
local RestoreButton = Instance.new("TextButton")
RestoreButton.Size = UDim2.new(0, 140, 0, 40)
RestoreButton.Position = UDim2.new(0.5, -70, 0, 20)
RestoreButton.BackgroundColor3 = Color3.new(1, 1, 1) -- Set to white so gradient shows
RestoreButton.Text = "OPEN PREMIUM"
RestoreButton.TextColor3 = Color3.new(1, 1, 1) -- White text looks better on blue gradient
RestoreButton.Font = Enum.Font.GothamBold
RestoreButton.TextSize = 13
RestoreButton.Visible = false
RestoreButton.Parent = ScreenGui
Instance.new("UICorner", RestoreButton).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", RestoreButton).Color = Theme.Accent

-- Gradient for Restore Button
local RestoreGradient = Instance.new("UIGradient")
RestoreGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(1, Theme.AccentDark)
})
RestoreGradient.Rotation = 90
RestoreGradient.Parent = RestoreButton

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 380)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
MainFrame.BackgroundColor3 = Theme.Main
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 45)
MainStroke.Thickness = 1.5

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.Secondary
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "XZSHIRO PREMIUM"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = Theme.Accent
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Theme.Danger
CloseBtn.TextSize = 24
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

-- Navigation Sidebar
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 140, 1, -40)
SideBar.Position = UDim2.new(0, 0, 0, 40)
SideBar.BackgroundColor3 = Theme.Secondary
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -155, 1, -55)
ContentFrame.Position = UDim2.new(0, 150, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Tab System Logic
local Tabs = {}
local function CreateTab(name)
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 2
    frame.Visible = false
    frame.Parent = ContentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = frame
    
    Tabs[name] = frame
    return frame
end

local function CreateSectionLabel(text, parent)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.95, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text:upper()
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Theme.Accent
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
end

-- Navigation Buttons
local function CreateNav(name, frameTarget)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 35)
    local buttonCount = 0
    for _, v in pairs(SideBar:GetChildren()) do if v:IsA("TextButton") then buttonCount = buttonCount + 1 end end
    b.Position = UDim2.new(0, 10, 0, 10 + (buttonCount * 40))
    b.BackgroundColor3 = Theme.Main
    b.BackgroundTransparency = 1
    b.Text = name
    b.Font = Enum.Font.GothamSemibold
    b.TextColor3 = Theme.TextDark
    b.TextSize = 11
    b.Parent = SideBar
    
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        frameTarget.Visible = true
        for _, v in pairs(SideBar:GetChildren()) do
            if v:IsA("TextButton") then v.TextColor3 = Theme.TextDark v.BackgroundTransparency = 1 end
        end
        b.TextColor3 = Theme.Accent
        b.BackgroundTransparency = 0.9
    end)
end

-- Helper Components
local function CreateToggle(name, default, callback, parent)
    local t = Instance.new("TextButton")
    t.Size = UDim2.new(0.95, 0, 0, 38)
    t.BackgroundColor3 = Theme.Secondary
    t.Text = "  " .. name
    t.Font = Enum.Font.Gotham
    t.TextSize = 12
    t.TextColor3 = Theme.Text
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = parent
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 6)
    
    local status = Instance.new("Frame")
    status.Size = UDim2.new(0, 34, 0, 18)
    status.Position = UDim2.new(1, -44, 0.5, -9)
    status.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(40, 40, 45)
    status.Parent = t
    Instance.new("UICorner", status).CornerRadius = UDim.new(1, 0)
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = default and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    dot.BackgroundColor3 = Color3.new(1,1,1)
    dot.Parent = status
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local active = default
    t.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(status, TweenInfo.new(0.2), {BackgroundColor3 = active and Theme.Accent or Color3.fromRGB(40, 40, 45)}):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)}):Play()
        callback(active)
    end)
end

local function CreateInput(name, placeholder, callback, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 38)
    frame.BackgroundColor3 = Theme.Secondary
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Theme.Text
    label.TextSize = 12
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0, 80, 0, 24)
    input.Position = UDim2.new(1, -90, 0.5, -12)
    input.BackgroundColor3 = Theme.Main
    input.TextColor3 = Theme.Accent
    input.Text = placeholder
    input.Font = Enum.Font.GothamBold
    input.TextSize = 11
    input.Parent = frame
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)
    input.FocusLost:Connect(function() callback(input.Text) end)
end

-- Initialize Tabs
local CombatTab = CreateTab("Combat")
local VisualsTab = CreateTab("Visuals")
local SettingsTab = CreateTab("Settings")

CreateNav("COMBAT", CombatTab)
CreateNav("VISUALS", VisualsTab)
CreateNav("SETTINGS", SettingsTab)

-- Populate Combat
CreateSectionLabel("Aimbot Master", CombatTab)
CreateToggle("Enable Aimbot", Settings.AimbotEnabled, function(v) Settings.AimbotEnabled = v end, CombatTab)
CreateToggle("Only Aim On Zoom", Settings.OnlyAimOnZoom, function(v) Settings.OnlyAimOnZoom = v end, CombatTab)
CreateToggle("Mobile Mode (Auto-Lock)", (Settings.Platform == "Mobile"), function(v) Settings.Platform = v and "Mobile" or "PC" end, CombatTab)

CreateSectionLabel("Checks & Safety", CombatTab)
CreateToggle("Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end, CombatTab)
CreateToggle("Wall Check", Settings.WallCheck, function(v) Settings.WallCheck = v end, CombatTab)
CreateToggle("Visibility Check", Settings.InvisibleCheck, function(v) Settings.InvisibleCheck = v end, CombatTab)
CreateToggle("Forcefield Check", Settings.ForceFieldCheck, function(v) Settings.ForceFieldCheck = v end, CombatTab)

CreateSectionLabel("Accuracy Tuning", CombatTab)
CreateInput("FOV Radius", tostring(Settings.FovRadius), function(v) 
    local n = tonumber(v) 
    if n then Settings.FovRadius = n FovCircle.Radius = n end 
end, CombatTab)
CreateInput("Prediction", tostring(Settings.PredictionAmount), function(v) 
    local n = tonumber(v) if n then Settings.PredictionAmount = n end 
end, CombatTab)
CreateInput("Smoothness (0.1-0.7)", tostring(Settings.SnapStrength), function(v)
    local n = tonumber(v)
    if n then Settings.SnapStrength = math.clamp(n, 0, 0.7) end
end, CombatTab)

-- Populate Visuals
CreateSectionLabel("ESP Features", VisualsTab)
CreateToggle("Enable ESP Highlights", Settings.EspEnabled, function(v) Settings.EspEnabled = v end, VisualsTab)
CreateToggle("Streamer Mode (Hidden)", Settings.Streamable, function(v) Settings.Streamable = v end, VisualsTab)

-- Populate Settings/Info
CreateSectionLabel("System Info", SettingsTab)
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(0.95, 0, 0, 100)
Info.BackgroundTransparency = 1
Info.TextColor3 = Theme.TextDark
Info.TextSize = 12
Info.Font = Enum.Font.Gotham
Info.Text = "Version: 2.0 Premium\nStatus: Undetected\nOwner: Xzshiro\nLast Update: 2025"
Info.Parent = SettingsTab

-- Handle Close/Open
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    RestoreButton.Visible = true
end)

RestoreButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    RestoreButton.Visible = false
end)

-- Default Tab
Tabs.Combat.Visible = true
SideBar:FindFirstChild("TextButton").TextColor3 = Theme.Accent

--// AIMBOT & ESP LOGIC CORE
local function GetClosestPlayer()
    local closest = nil
    local shortestDist = Settings.FovRadius
    local ScreenCenter = (Settings.Platform == "PC") and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            local char = player.Character
            if char and char:FindFirstChild(Settings.AimPart) then
                local hum = char:FindFirstChild("Humanoid")
                if Settings.AliveCheck and hum and hum.Health <= 0 then continue end
                if Settings.InvisibleCheck and char:FindFirstChild("Head") and char.Head.Transparency > 0.5 then continue end
                if Settings.ForceFieldCheck and char:FindFirstChildOfClass("ForceField") then continue end

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

local function CreateEsp(player)
    if EspTable[player] then return end
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(4, 0, 0.5, 0)
    billboard.AlwaysOnTop = true
    billboard.ExtentsOffset = Vector3.new(0, 3, 0)
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.Parent = billboard
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 1, 0)
    bar.BackgroundColor3 = Color3.new(0, 1, 0)
    bar.BorderSizePixel = 0
    bar.Parent = frame
    
    EspTable[player] = {Highlight = highlight, Billboard = billboard}
end

Players.PlayerAdded:Connect(CreateEsp)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateEsp(p) end end

local fallTimer = 0
local isFalling = false

RunService.RenderStepped:Connect(function()
    local ScreenCenter = (Settings.Platform == "PC") and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Position = ScreenCenter
    FovCircle.Visible = Settings.AimbotEnabled and not Settings.Streamable
    
    -- Update ESP
    for player, data in pairs(EspTable) do
        local char = player.Character
        if char and Settings.EspEnabled and not Settings.Streamable then
            data.Highlight.Parent = char
            data.Highlight.Enabled = true
            data.Highlight.FillColor = (player.Team == LocalPlayer.Team) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
            local head = char:FindFirstChild("Head")
            if head then
                data.Billboard.Parent = head
                data.Billboard.Enabled = true
            end
        else
            data.Highlight.Enabled = false
            data.Billboard.Enabled = false
        end
    end

    -- Update Aimbot
    if Settings.AimbotEnabled then
        -- Logic for "Only Aim On Zoom"
        local ZoomActive = true
        if Settings.OnlyAimOnZoom then
            ZoomActive = Camera.FieldOfView < (InitialFOV - 2) -- If FOV is lower than normal, you are zoomed
        end

        if ZoomActive then
            local target = GetClosestPlayer()
            if target and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or Settings.Platform == "Mobile") then 
                local targetPos = target.Position
                local char = target.Parent
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                
                local currentPrediction = Settings.PredictionAmount
                local currentSnap = Settings.SnapStrength
                
                -- Dynamic Snap
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                if onScreen then
                    local distToCrosshair = (Vector2.new(screenPos.X, screenPos.Y) - ScreenCenter).Magnitude
                    if distToCrosshair < 15 then currentSnap = 0.9 end
                end

                -- Physics Check
                if hum and root then
                    local velocityY = root.Velocity.Y
                    if velocityY > 5 or hum:GetState() == Enum.HumanoidStateType.Jumping then
                        currentPrediction = 0
                        currentSnap = 1
                    elseif velocityY < -5 then
                        if not isFalling then fallTimer = tick() isFalling = true end
                        if (tick() - fallTimer) < 1.34 then currentPrediction = 0 currentSnap = 1 end
                    else isFalling = false end
                end
                
                if root and currentPrediction > 0 then
                    local distance = (target.Position - Camera.CFrame.Position).Magnitude
                    targetPos = targetPos + (root.Velocity * (distance / (1000 / currentPrediction)))
                end
                
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), currentSnap)
            end
        end
    end
end)
