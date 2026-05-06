--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// SETTINGS
local Settings = {
    AimbotEnabled = false,
    FovChangeAim = false,
    EspEnabled = false,
    TeamCheck = true,
    AliveCheck = true,
    WallCheck = true,
    InvisibleCheck = true,
    ForceFieldCheck = true,
    Streamable = false,
    TracerEnabled = false,
    FovRadius = 100,
    PredictionAmount = 0.165, -- Adjusted for the new distance-based math
    SnapStrength = 0.15,
    StickyAim = 0.5,
    FovColor = Color3.fromRGB(0, 255, 200),
    AimPart = "Head",
    Platform = "PC"
}

-- Dynamically track FOV to detect zooming
local BaseFOV = Camera.FieldOfView
spawn(function()
    while task.wait(1) do
        -- Updates base FOV if player isn't aiming, to adapt to different games
        if not Settings.AimbotEnabled or not Settings.FovChangeAim then
            BaseFOV = Camera.FieldOfView
        end
    end
end)

--// THEME
local Theme = {
    Main = Color3.fromRGB(10, 10, 12),
    Secondary = Color3.fromRGB(18, 18, 22),
    Accent = Color3.fromRGB(0, 160, 255),
    AccentDark = Color3.fromRGB(0, 60, 150),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(160, 160, 160),
    Tracer = Color3.fromRGB(0, 200, 255)
}

--// UTILS
local function ApplyGradient(obj)
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentDark)
    })
    Gradient.Parent = obj
end

local function ProtectInstance(instance)
    pcall(function()
        if gethui then instance.Parent = gethui()
        elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then instance.Parent = game:GetService("CoreGui")
        else instance.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    end)
end

--// GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XzPremium_" .. math.random(100,999)
ScreenGui.ResetOnSpawn = false
ProtectInstance(ScreenGui)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 400)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
MainFrame.BackgroundColor3 = Theme.Main
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local RestoreBtn = Instance.new("TextButton")
RestoreBtn.Size = UDim2.new(0, 160, 0, 40)
RestoreBtn.Position = UDim2.new(0.5, -80, 0, 20)
RestoreBtn.BackgroundColor3 = Theme.Secondary
RestoreBtn.Text = "OPEN PREMIUM"
RestoreBtn.TextColor3 = Color3.new(1,1,1)
RestoreBtn.Font = Enum.Font.GothamBold
RestoreBtn.TextSize = 14
RestoreBtn.Visible = false
RestoreBtn.Parent = ScreenGui
Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(0, 8)
ApplyGradient(RestoreBtn)

local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Size = UDim2.new(0, 200, 0, 40)
HeaderLabel.Position = UDim2.new(0, 15, 0, 0)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Text = "XzshiroOfficials"
HeaderLabel.TextColor3 = Theme.Accent
HeaderLabel.Font = Enum.Font.LuckiestGuy
HeaderLabel.TextSize = 18
HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
HeaderLabel.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 8)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "Ã—"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.TextSize = 28
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 160, 1, -40)
SideBar.Position = UDim2.new(0, 0, 0, 40)
SideBar.BackgroundColor3 = Theme.Secondary
SideBar.Parent = MainFrame
Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 10)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -170, 1, -50)
ContentArea.Position = UDim2.new(0, 170, 0, 45)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Tabs = {}
local function CreateTab(name)
    local f = Instance.new("ScrollingFrame")
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.ScrollBarThickness = 2
    f.ScrollBarImageColor3 = Theme.Accent
    f.CanvasSize = UDim2.new(0,0,0,0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    f.Parent = ContentArea
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 8)
    l.Parent = f
    Tabs[name] = f
    return f
end

local CombatTab = CreateTab("Combat")
local VisualsTab = CreateTab("Visuals")
local InfoTab = CreateTab("Info")
CombatTab.Visible = true

--// COMPONENTS
local function CreateNav(name, tab, iconId)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    local count = 0
    for _, v in pairs(SideBar:GetChildren()) do if v:IsA("TextButton") then count = count + 1 end end
    btn.Position = UDim2.new(0, 10, 0, 10 + (count * 45))
    btn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    btn.BackgroundTransparency = 1
    btn.Text = "      " .. name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Theme.TextDark
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = SideBar
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 18, 0, 18)
    icon.Position = UDim2.new(0, 10, 0.5, -9)
    icon.Image = iconId
    icon.BackgroundTransparency = 1
    icon.ImageColor3 = Theme.TextDark
    icon.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        tab.Visible = true
    end)
end

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
    Instance.new("UICorner", t)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 30, 0, 15)
    indicator.Position = UDim2.new(1, -40, 0.5, -7)
    indicator.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(50,50,50)
    indicator.Parent = t
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    local state = default
    t.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50,50,50)}):Play()
        callback(state)
    end)
end

local function CreateSlider(name, min, max, default, callback, parent)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 50)
    container.BackgroundColor3 = Theme.Secondary
    container.Parent = parent
    Instance.new("UICorner", container)

    local label = Instance.new("TextLabel")
    label.Text = "  " .. name
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.TextDark
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 50, 0, 20)
    box.Position = UDim2.new(1, -60, 0, 5)
    box.BackgroundColor3 = Theme.Main
    box.Text = tostring(default)
    box.TextColor3 = Theme.Text
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.Parent = container
    Instance.new("UICorner", box)

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 4)
    sliderBar.Position = UDim2.new(0, 10, 0, 35)
    sliderBar.BackgroundColor3 = Theme.Main
    sliderBar.Parent = container
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp((default-min)/(max-min), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = sliderBar

    local function update(val)
        val = math.clamp(math.round(val * 100) / 100, min, max)
        box.Text = tostring(val)
        fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
        callback(val)
    end

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then update(n) else box.Text = tostring(min) end
    end)

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local mPos = UserInputService:GetMouseLocation().X
                local bPos = sliderBar.AbsolutePosition.X
                local bSize = sliderBar.AbsoluteSize.X
                local percent = math.clamp((mPos - bPos) / bSize, 0, 1)
                update(min + (max - min) * percent)
                if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then connection:Disconnect() end
            end)
        end
    end)
end

local function CreateSelector(name, options, callback, parent)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 35)
    container.BackgroundColor3 = Theme.Secondary
    container.Parent = parent
    Instance.new("UICorner", container)

    local label = Instance.new("TextLabel")
    label.Text = "  " .. name
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.TextDark
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, 0, 0.7, 0)
    btn.Position = UDim2.new(0.45, 0, 0.15, 0)
    btn.BackgroundColor3 = Theme.Main
    btn.Text = Settings.Platform
    btn.TextColor3 = Theme.Accent
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = container
    Instance.new("UICorner", btn)

    local current = 1
    btn.MouseButton1Click:Connect(function()
        current = current + 1
        if current > #options then current = 1 end
        btn.Text = options[current]
        callback(options[current])
    end)
end

--// POPULATE
CreateNav("COMBAT", CombatTab, "rbxassetid://10747373176")
CreateNav("VISUALS", VisualsTab, "rbxassetid://10709812534")
CreateNav("INFO", InfoTab, "rbxassetid://10723346959")

CreateSelector("Platform Mode", {"PC", "Mobile"}, function(v) Settings.Platform = v end, CombatTab)
CreateToggle("Enable Aimbot", Settings.AimbotEnabled, function(v) Settings.AimbotEnabled = v end, CombatTab)
CreateToggle("Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end, CombatTab)
CreateToggle("FOV-Change Activation", Settings.FovChangeAim, function(v) Settings.FovChangeAim = v end, CombatTab)
CreateSlider("FOV Radius", 10, 800, Settings.FovRadius, function(v) Settings.FovRadius = v end, CombatTab)
CreateSlider("Prediction", 0, 5, Settings.PredictionAmount, function(v) Settings.PredictionAmount = v end, CombatTab)
CreateSlider("Snap Strength", 0, 1, Settings.SnapStrength, function(v) Settings.SnapStrength = v end, CombatTab)
CreateToggle("Wall Check", Settings.WallCheck, function(v) Settings.WallCheck = v end, CombatTab)
CreateToggle("Invisible Check", Settings.InvisibleCheck, function(v) Settings.InvisibleCheck = v end, CombatTab)
CreateToggle("ForceField Check", Settings.ForceFieldCheck, function(v) Settings.ForceFieldCheck = v end, CombatTab)

CreateToggle("Enable ESP", Settings.EspEnabled, function(v) Settings.EspEnabled = v end, VisualsTab)
CreateToggle("Target Tracer", Settings.TracerEnabled, function(v) Settings.TracerEnabled = v end, VisualsTab) 
CreateToggle("Streamable (Hide FOV)", Settings.Streamable, function(v) Settings.Streamable = v end, VisualsTab)

-- Info Tab
local function AddInfo(txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 0, 30)
    l.BackgroundTransparency = 1
    l.Text = "  " .. txt
    l.TextColor3 = Theme.TextDark
    l.Font = Enum.Font.Gotham
    l.TextSize = 14
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = InfoTab
end
AddInfo("Owner: XzshiroOfficials")
AddInfo("Status: Active")
AddInfo("Version: Premium V4 Fixed")

--// AIMBOT & TRACER LOGIC
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1.5
FovCircle.Color = Theme.Accent
FovCircle.Filled = false

local TargetLine = Drawing.new("Line")
TargetLine.Thickness = 2
TargetLine.Transparency = 1
TargetLine.Color = Theme.Tracer

local function IsVisible(part, char)
    if not Settings.WallCheck then return true end
    local cast = Camera:GetPartsObscuringTarget({part.Position}, {LocalPlayer.Character, char})
    return #cast == 0
end

local function GetClosestPlayer()
    local target = nil
    local shortestDist = Settings.FovRadius
    local center = (Settings.Platform == "PC") and UserInputService:GetMouseLocation() or (Camera.ViewportSize / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.AimPart) then
            if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
            
            local char = p.Character
            if Settings.InvisibleCheck and char:FindFirstChild("Head") and char.Head.Transparency > 0.5 then continue end
            if Settings.ForceFieldCheck and char:FindFirstChildOfClass("ForceField") then continue end

            local part = char[Settings.AimPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if dist < shortestDist then
                    if IsVisible(part, char) then
                        shortestDist = dist
                        target = part
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    local center = (Settings.Platform == "PC") and UserInputService:GetMouseLocation() or (Camera.ViewportSize / 2)
    
    FovCircle.Visible = Settings.AimbotEnabled and not Settings.Streamable
    FovCircle.Radius = Settings.FovRadius
    FovCircle.Position = center

    local isActivated = false
    if Settings.AimbotEnabled then
        if Settings.FovChangeAim then
            -- FIXED: Detects if current FOV is significantly lower than base (Zoomed in)
            if Camera.FieldOfView < (BaseFOV - 5) then 
                isActivated = true 
            end
        else
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch) then
                isActivated = true
            end
        end
    end

    local foundTarget = GetClosestPlayer()
    
    -- Tracer Logic
    if Settings.TracerEnabled and foundTarget then
        local tPos, _ = Camera:WorldToViewportPoint(foundTarget.Position)
        TargetLine.Visible = true
        TargetLine.From = center
        TargetLine.To = Vector2.new(tPos.X, tPos.Y)
    else
        TargetLine.Visible = false
    end

    -- Aimbot Movement Logic
    if isActivated and foundTarget then
        local targetPos = foundTarget.Position
        local char = foundTarget.Parent
        
        -- FIXED: Speed-Based Prediction
        -- Distance matters: Further targets need more lead time.
        if char.PrimaryPart then
            local velocity = char.PrimaryPart.Velocity
            local distance = (Camera.CFrame.Position - targetPos).Magnitude
            -- Dynamic calculation: Velocity * Distance * Sensitivity Factor
            local predictionOffset = velocity * (distance / 100) * Settings.PredictionAmount
            targetPos = targetPos + predictionOffset
        end

        local screenPos, _ = Camera:WorldToViewportPoint(foundTarget.Position)
        local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        local power = (distToCenter < 20) and Settings.StickyAim or Settings.SnapStrength
        
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), power)
    end
end)

--// WINDOW TOGGLE
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    RestoreBtn.Visible = true
end)

RestoreBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    RestoreBtn.Visible = false
end)
