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
    FovChangeAim = false,
    EspEnabled = false,
    TeamCheck = true,
    AliveCheck = true,
    WallCheck = true,
    Streamable = false,
    HideMyNickname = false, -- New Feature
    FovRadius = 100,
    PredictionAmount = 1.65, 
    SnapStrength = 0.15,
    FovColor = Color3.fromRGB(0, 255, 200),
    AimPart = "Head",
    Platform = "PC" 
}

local InitialFOV = Camera.FieldOfView
local EspTable = {}
local UserTags = {} -- Table to manage Nicknames
local Theme = {
    Main = Color3.fromRGB(15, 15, 17),
    Secondary = Color3.fromRGB(22, 22, 26),
    Accent = Color3.fromRGB(0, 180, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180)
}

--// Nickname Identity Marker
local function CreateIdentityMarker()
    local function mark(char)
        if not char:FindFirstChild("XzIdentity") then
            local marker = Instance.new("StringValue")
            marker.Name = "XzIdentity"
            marker.Parent = char
        end
    end
    if LocalPlayer.Character then mark(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(mark)
end
CreateIdentityMarker()

--// FOV Circle
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Thickness = 1.5
FovCircle.Color = Settings.FovColor
FovCircle.Filled = false
FovCircle.Radius = Settings.FovRadius

--// GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Xz_" .. math.random(1000, 9999)
ScreenGui.ResetOnSpawn = false
ProtectInstance(ScreenGui)

-- Restore Button
local RestoreButton = Instance.new("TextButton")
RestoreButton.Size = UDim2.new(0, 120, 0, 35)
RestoreButton.Position = UDim2.new(0.5, -60, 0, 10)
RestoreButton.BackgroundColor3 = Theme.Secondary
RestoreButton.Text = "OPEN MENU"
RestoreButton.TextColor3 = Theme.Accent
RestoreButton.Font = Enum.Font.GothamBold
RestoreButton.TextSize = 12
RestoreButton.Visible = false
RestoreButton.Parent = ScreenGui
Instance.new("UICorner", RestoreButton).CornerRadius = UDim.new(0, 6)

local function UpdateRestoreButtonVisuals()
    if Settings.Streamable then
        RestoreButton.BackgroundTransparency = 1
        RestoreButton.TextTransparency = 1
    else
        RestoreButton.BackgroundTransparency = 0
        RestoreButton.TextTransparency = 0
    end
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Theme.Main
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Theme.Secondary
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- Sidebar
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 140, 1, 0)
SideBar.BackgroundColor3 = Theme.Secondary
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 8)
SideCorner.Parent = SideBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "XZSHIRO"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Theme.Accent
Title.BackgroundTransparency = 1
Title.Parent = SideBar

-- Tab System
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -150, 1, -20)
ContentFrame.Position = UDim2.new(0, 150, 0, 10)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local function CreateTab(name)
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 2
    frame.Visible = false
    frame.Parent = ContentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = frame
    
    return frame
end

local Tabs = {
    Combat = CreateTab("Combat"),
    Visuals = CreateTab("Visuals"),
    Info = CreateTab("Info")
}
Tabs.Combat.Visible = true

local function CreateNav(name, frameTarget, iconId)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 35)
    local buttonCount = 0
    for _, v in pairs(SideBar:GetChildren()) do if v:IsA("TextButton") then buttonCount = buttonCount + 1 end end
    
    b.Position = UDim2.new(0, 10, 0, 60 + (buttonCount * 40))
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.BackgroundTransparency = 1
    b.Text = name
    b.Font = Enum.Font.GothamSemibold
    b.TextColor3 = Theme.TextDark
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextTruncate = Enum.TextTruncate.AtEnd
    b.Parent = SideBar
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 35)
    padding.Parent = b

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 18, 0, 18)
    icon.Position = UDim2.new(0, -25, 0.5, -9)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = Theme.TextDark
    icon.Parent = b
    
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        frameTarget.Visible = true
        for _, v in pairs(SideBar:GetChildren()) do
            if v:IsA("TextButton") then 
                v.TextColor3 = Theme.TextDark 
                if v:FindFirstChild("Icon") then v.Icon.ImageColor3 = Theme.TextDark end
            end
        end
        b.TextColor3 = Theme.Accent
        icon.ImageColor3 = Theme.Accent
    end)
end

CreateNav("COMBAT", Tabs.Combat, "rbxassetid://10747373176")
CreateNav("VISUALS", Tabs.Visuals, "rbxassetid://10709812534")
CreateNav("INFO", Tabs.Info, "rbxassetid://10723346959")

local function CreateToggle(name, default, callback, parent)
    local t = Instance.new("TextButton")
    t.Size = UDim2.new(1, -10, 0, 35)
    t.BackgroundColor3 = Theme.Secondary
    t.Text = "  " .. name
    t.Font = Enum.Font.Gotham
    t.TextSize = 13
    t.TextColor3 = Theme.TextDark
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = parent
    
    local corner = Instance.new("UICorner", t)
    corner.CornerRadius = UDim.new(0, 6)
    
    local status = Instance.new("Frame")
    status.Size = UDim2.new(0, 30, 0, 15)
    status.Position = UDim2.new(1, -40, 0.5, -7)
    status.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(50, 50, 50)
    status.Parent = t
    Instance.new("UICorner", status).CornerRadius = UDim.new(1, 0)
    
    local active = default
    t.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(status, TweenInfo.new(0.2), {BackgroundColor3 = active and Theme.Accent or Color3.fromRGB(50, 50, 50)}):Play()
        callback(active)
    end)
end

local function CreateInput(name, placeholder, callback, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Theme.Secondary
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Theme.TextDark
    label.TextSize = 13
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.5, 0, 0.7, 0)
    input.Position = UDim2.new(0.5, 0, 0.15, 0)
    input.BackgroundColor3 = Theme.Main
    input.TextColor3 = Theme.Text
    input.Text = placeholder
    input.Font = Enum.Font.Gotham
    input.TextSize = 12
    input.Parent = frame
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)
    
    input.FocusLost:Connect(function()
        callback(input.Text)
    end)
end

local function CreateInfoLabel(text, parent)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = "  " .. text
    label.Font = Enum.Font.GothamSemibold
    label.TextColor3 = Theme.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
end

--// POPULATE TABS
CreateToggle("Enable Aimbot", Settings.AimbotEnabled, function(v) Settings.AimbotEnabled = v end, Tabs.Combat)
CreateToggle("FOV Scale Aim", Settings.FovChangeAim, function(v) Settings.FovChangeAim = v end, Tabs.Combat)
CreateToggle("Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end, Tabs.Combat)
CreateToggle("Wall Check", Settings.WallCheck, function(v) Settings.WallCheck = v end, Tabs.Combat)
CreateToggle("Alive Check", Settings.AliveCheck, function(v) Settings.AliveCheck = v end, Tabs.Combat)
CreateInput("FOV Radius", tostring(Settings.FovRadius), function(v) 
    local n = tonumber(v) 
    if n then Settings.FovRadius = n FovCircle.Radius = n end 
end, Tabs.Combat)
CreateInput("Prediction", tostring(Settings.PredictionAmount), function(v) 
    local n = tonumber(v) if n then Settings.PredictionAmount = n end 
end, Tabs.Combat)
CreateInput("Snap Strength (0-0.7)", tostring(Settings.SnapStrength), function(v)
    local n = tonumber(v)
    if n then Settings.SnapStrength = math.clamp(n, 0, 0.7) end
end, Tabs.Combat)
CreateToggle("Mobile Mode", (Settings.Platform == "Mobile"), function(v) Settings.Platform = v and "Mobile" or "PC" end, Tabs.Combat)

CreateToggle("Enable ESP", Settings.EspEnabled, function(v) Settings.EspEnabled = v end, Tabs.Visuals)
CreateToggle("Streamable Mode", Settings.Streamable, function(v) 
    Settings.Streamable = v 
    UpdateRestoreButtonVisuals()
end, Tabs.Visuals)
CreateToggle("Hide Nickname (Just for you)", Settings.HideMyNickname, function(v) Settings.HideMyNickname = v end, Tabs.Visuals)

CreateInfoLabel("Owner: Xzshiro", Tabs.Info)
CreateInfoLabel("Made: 5/4/2026", Tabs.Info)
CreateInfoLabel("Status: Active", Tabs.Info)
CreateInfoLabel("Media: Nothing Yet", Tabs.Info)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.new(1,0,0)
CloseBtn.TextSize = 20
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function() 
    MainFrame.Visible = false 
    RestoreButton.Visible = true 
    UpdateRestoreButtonVisuals() 
end)

RestoreButton.MouseButton1Click:Connect(function() 
    MainFrame.Visible = true 
    RestoreButton.Visible = false 
end)

--// ESP & NICKNAME LOGIC
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
    
    -- Nickname GUI
    local nicknameGui = Instance.new("BillboardGui")
    nicknameGui.Name = "XzNickname"
    nicknameGui.Size = UDim2.new(0, 160, 0, 25)
    nicknameGui.AlwaysOnTop = true
    nicknameGui.ExtentsOffset = Vector3.new(0, 4.2, 0)
    nicknameGui.Enabled = false
    
    local nickFrame = Instance.new("Frame")
    nickFrame.Size = UDim2.new(1, 0, 1, 0)
    nickFrame.BackgroundColor3 = Color3.new(0,0,0)
    nickFrame.BackgroundTransparency = 0.5
    nickFrame.Parent = nicknameGui
    Instance.new("UICorner", nickFrame).CornerRadius = UDim.new(0, 4)
    
    local nickLabel = Instance.new("TextLabel")
    nickLabel.Size = UDim2.new(1, 0, 1, 0)
    nickLabel.BackgroundTransparency = 1
    nickLabel.Text = "Xzshiro Aimbot User"
    nickLabel.TextColor3 = Theme.Accent
    nickLabel.Font = Enum.Font.GothamBold
    nickLabel.TextSize = 12
    nickLabel.Parent = nickFrame
    
    EspTable[player] = {Highlight = highlight, Billboard = billboard, Nickname = nicknameGui}
end

local function RemoveEsp(player)
    if EspTable[player] then
        pcall(function()
            EspTable[player].Highlight:Destroy()
            EspTable[player].Billboard:Destroy()
            EspTable[player].Nickname:Destroy()
        end)
        EspTable[player] = nil
    end
end

Players.PlayerAdded:Connect(CreateEsp)
Players.PlayerRemoving:Connect(RemoveEsp)
for _, p in pairs(Players:GetPlayers()) do CreateEsp(p) end

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

-- Jump/Fall Tracking Variables
local fallTimer = 0
local isFalling = false

RunService.RenderStepped:Connect(function()
    local ScreenCenter = (Settings.Platform == "PC") and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Position = ScreenCenter
    FovCircle.Visible = Settings.AimbotEnabled and not Settings.Streamable
    
    for _, player in pairs(Players:GetPlayers()) do
        local char = player.Character
        local data = EspTable[player]
        if char and data then
            local hum = char:FindFirstChild("Humanoid")
            local head = char:FindFirstChild("Head")
            
            -- Nickname logic (Visible if they have the identity marker)
            if char:FindFirstChild("XzIdentity") and not Settings.Streamable then
                local isMe = (player == LocalPlayer)
                if isMe and Settings.HideMyNickname then
                    data.Nickname.Enabled = false
                else
                    data.Nickname.Enabled = true
                    data.Nickname.Parent = head
                end
            else
                data.Nickname.Enabled = false
            end

            -- ESP logic
            if player ~= LocalPlayer then
                if Settings.EspEnabled then
                    data.Highlight.Parent = char
                    data.Highlight.Enabled = not Settings.Streamable
                    data.Highlight.FillColor = (Settings.TeamCheck and player.Team == LocalPlayer.Team) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                    if head then
                        data.Billboard.Parent = head
                        data.Billboard.Enabled = not Settings.Streamable
                        if hum then data.Billboard.Frame.Bar.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0) end
                    else data.Billboard.Enabled = false end
                else data.Highlight.Enabled = false data.Billboard.Enabled = false end
            end
        elseif data then 
            data.Highlight.Enabled = false 
            data.Billboard.Enabled = false 
            data.Nickname.Enabled = false
        end
    end

    if Settings.AimbotEnabled then
        if Settings.FovChangeAim and math.abs(Camera.FieldOfView - InitialFOV) < 1 then return end
        local target = GetClosestPlayer()
        
        if target and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or Settings.Platform == "Mobile") then 
            local targetPos = target.Position
            local char = target.Parent
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            
            local currentPrediction = Settings.PredictionAmount
            local currentSnap = Settings.SnapStrength
            
            if hum and root then
                local velocityY = root.Velocity.Y
                local state = hum:GetState()
                
                if velocityY > 5 or state == Enum.HumanoidStateType.Jumping then
                    currentPrediction = 0
                    currentSnap = 1
                    isFalling = false
                elseif state == Enum.HumanoidStateType.Freefall or velocityY < -5 then
                    if not isFalling then
                        fallTimer = tick()
                        isFalling = true
                    end
                    
                    if (tick() - fallTimer) >= 1.34 then
                        currentPrediction = Settings.PredictionAmount
                        currentSnap = Settings.SnapStrength
                    else
                        currentPrediction = 0
                        currentSnap = 1
                    end
                else
                    isFalling = false
                end
            end
            
            if root and currentPrediction > 0 then
                local velocity = root.Velocity
                local distance = (target.Position - Camera.CFrame.Position).Magnitude
                if velocity.Magnitude > 0.1 then
                    local predictionOffset = velocity * (distance / (1000 / currentPrediction))
                    targetPos = targetPos + predictionOffset
                end
            end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
            if onScreen then
                local distToCrosshair = (Vector2.new(screenPos.X, screenPos.Y) - ScreenCenter).Magnitude
                if distToCrosshair < 10 then 
                    currentSnap = 1 
                end
            end
            
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), currentSnap)
        else
            isFalling = false
        end
    end
end)
