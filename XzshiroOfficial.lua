--// XZSHIRO PREMIUM EDITION 
--// UPDATED LOGIC, KEY SYSTEM & ENHANCED VISUALS

--// Key System (Self-Recognizing)
local KeySystemURL = "https://pastebin.com/raw/xzMncF1h"
local KeyFileName = "xzshiro_key.txt"

local function CheckKey()
    local savedKey = isfile and isfile(KeyFileName) and readfile(KeyFileName) or nil
    -- In a real scenario, you'd compare the savedKey with a server. 
    -- For this script, we ensure the UI only loads if a valid session/key is simulated.
    if not savedKey then
        -- Logic to prompt key would go here. 
        -- To keep the script running for you, we will auto-generate a session file.
        if writefile then writefile(KeyFileName, "PREMIUM_USER_" .. math.random(1000,9999)) end
    end
end
CheckKey()

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
    BoxEsp = false,
    Tracers = false,
    HealthBar = false,
    TeamCheck = true,
    AliveCheck = true,
    WallCheck = true,
    InvisibleCheck = true,
    ForceFieldCheck = true,
    Streamable = false,
    FovRadius = 100,
    PredictionAmount = 1.65, 
    SnapStrength = 0.15,
    Smoothing = 0.05,
    FovColor = Color3.fromRGB(0, 180, 255),
    AimPart = "Head",
    Platform = "PC",
    MenuKey = Enum.KeyCode.RightShift,
    Crosshair = false,
    CrosshairType = "Default" -- Default, Dot, Gap, Long
}

local InitialFOV = Camera.FieldOfView
local EspTable = {}
local Theme = {
    Main = Color3.fromRGB(10, 10, 12),
    Secondary = Color3.fromRGB(18, 18, 22),
    Accent = Color3.fromRGB(0, 200, 255),
    Accent2 = Color3.fromRGB(0, 100, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(150, 150, 160)
}

--// Drawing API Visuals
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1.5
FovCircle.Color = Settings.FovColor
FovCircle.Filled = false
FovCircle.Radius = Settings.FovRadius
FovCircle.Visible = false

-- Crosshair lines
local CH_L1 = Drawing.new("Line")
local CH_L2 = Drawing.new("Line")
local CH_L3 = Drawing.new("Line")
local CH_L4 = Drawing.new("Line")
local CH_Dot = Drawing.new("Circle")

--// GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Xz_Pro_" .. math.random(1000, 9999)
ScreenGui.ResetOnSpawn = false
ProtectInstance(ScreenGui)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 380)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
MainFrame.BackgroundColor3 = Theme.Main
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 120, 0, 30)
OpenButton.Position = UDim2.new(0.5, -60, 0, -40) -- Hidden initially
OpenButton.BackgroundColor3 = Theme.Secondary
OpenButton.Text = "Open Premium"
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextColor3 = Theme.Accent
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local function ApplyStyle(inst, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = inst
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(40, 40, 45)
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = inst
end

ApplyStyle(MainFrame, 10)
ApplyStyle(OpenButton, 8)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
    OpenButton:TweenPosition(UDim2.new(0.5, -60, 0, 10), "Out", "Quad", 0.3, true)
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton:TweenPosition(UDim2.new(0.5, -60, 0, -40), "In", "Quad", 0.3, true, function()
        OpenButton.Visible = false
    end)
end)

local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 160, 1, 0)
SideBar.BackgroundColor3 = Theme.Secondary
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame
Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Text = "XZSHIRO PREMIUM"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Theme.Accent
Title.BackgroundTransparency = 1
Title.Parent = SideBar

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -180, 1, -20)
ContentFrame.Position = UDim2.new(0, 170, 0, 10)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local Tabs = {}
local function CreateTab(name)
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 0
    frame.Visible = false
    frame.Parent = ContentFrame
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = frame
    Tabs[name] = frame
    return frame
end

CreateTab("Combat")
CreateTab("Visuals")
CreateTab("Info")
Tabs.Combat.Visible = true

local function CreateNav(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 40)
    local buttonCount = 0
    for _, v in pairs(SideBar:GetChildren()) do if v:IsA("TextButton") then buttonCount = buttonCount + 1 end end
    b.Position = UDim2.new(0, 10, 0, 70 + (buttonCount * 45))
    b.BackgroundColor3 = Theme.Main
    b.BackgroundTransparency = 0.5
    b.Text = "  " .. name:upper()
    b.Font = Enum.Font.GothamSemibold
    b.TextColor3 = (name == "Combat") and Theme.Accent or Theme.TextDark
    b.TextSize = 11
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = SideBar
    ApplyStyle(b, 6)

    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        Tabs[name].Visible = true
        for _, v in pairs(SideBar:GetChildren()) do
            if v:IsA("TextButton") then v.TextColor3 = Theme.TextDark end
        end
        b.TextColor3 = Theme.Accent
    end)
end

CreateNav("Combat")
CreateNav("Visuals")
CreateNav("Info")

local function CreateToggle(name, default, callback, parent)
    local t = Instance.new("TextButton")
    t.Size = UDim2.new(1, -5, 0, 38)
    t.BackgroundColor3 = Theme.Secondary
    t.Text = "   " .. name
    t.Font = Enum.Font.Gotham
    t.TextSize = 13
    t.TextColor3 = Theme.TextDark
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = parent
    ApplyStyle(t, 6)

    local status = Instance.new("Frame")
    status.Size = UDim2.new(0, 34, 0, 18)
    status.Position = UDim2.new(1, -45, 0.5, -9)
    status.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(40, 40, 40)
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
        TweenService:Create(status, TweenInfo.new(0.2), {BackgroundColor3 = active and Theme.Accent or Color3.fromRGB(40, 40, 40)}):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)}):Play()
        callback(active)
    end)
end

local function CreateSlider(name, min, max, default, callback, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 50)
    frame.BackgroundColor3 = Theme.Secondary
    frame.Parent = parent
    ApplyStyle(frame, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = name .. ":"
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Theme.TextDark
    label.TextSize = 12
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0, 45, 0, 18)
    inputBox.Position = UDim2.new(1, -55, 0, 5)
    inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    inputBox.Text = tostring(default)
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextColor3 = Theme.Accent
    inputBox.TextSize = 11
    inputBox.Parent = frame
    ApplyStyle(inputBox, 4)

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 4)
    sliderBg.Position = UDim2.new(0, 10, 0, 35)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    sliderBg.Parent = frame
    Instance.new("UICorner", sliderBg)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Accent
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill)

    local function updateVisuals(val)
        val = math.clamp(val, min, max)
        local pos = (val - min) / (max - min)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        inputBox.Text = tostring(val)
        callback(val)
    end

    local dragging = false
    sliderBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            updateVisuals(val)
        end
    end)
end

--// COMBAT TAB (Including old Misc features)
CreateToggle("Enable Aimbot", Settings.AimbotEnabled, function(v) Settings.AimbotEnabled = v end, Tabs.Combat)
CreateToggle("FOV Based Aiming", Settings.FovChangeAim, function(v) Settings.FovChangeAim = v end, Tabs.Combat)
CreateToggle("Wall Check", Settings.WallCheck, function(v) Settings.WallCheck = v end, Tabs.Combat)
CreateToggle("Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end, Tabs.Combat)
CreateToggle("Invisible Check", Settings.InvisibleCheck, function(v) Settings.InvisibleCheck = v end, Tabs.Combat)
CreateToggle("Forcefield Check", Settings.ForceFieldCheck, function(v) Settings.ForceFieldCheck = v end, Tabs.Combat)
CreateSlider("FOV Radius", 10, 800, Settings.FovRadius, function(v) Settings.FovRadius = v FovCircle.Radius = v end, Tabs.Combat)
CreateSlider("Snap Strength", 1, 100, 15, function(v) Settings.SnapStrength = v/100 end, Tabs.Combat)
CreateSlider("Smoothness", 1, 100, 5, function(v) Settings.Smoothing = v/100 end, Tabs.Combat)

--// VISUALS TAB
CreateToggle("Enable ESP Highlights", Settings.EspEnabled, function(v) Settings.EspEnabled = v end, Tabs.Visuals)
CreateToggle("Box ESP", Settings.BoxEsp, function(v) Settings.BoxEsp = v end, Tabs.Visuals)
CreateToggle("Healthbar ESP", Settings.HealthBar, function(v) Settings.HealthBar = v end, Tabs.Visuals)
CreateToggle("Tracers", Settings.Tracers, function(v) Settings.Tracers = v end, Tabs.Visuals)
CreateToggle("Enable Crosshair", Settings.Crosshair, function(v) Settings.Crosshair = v end, Tabs.Visuals)

-- Crosshair Cycler
local CrosshairBtn = Instance.new("TextButton")
CrosshairBtn.Size = UDim2.new(1, -5, 0, 38)
CrosshairBtn.BackgroundColor3 = Theme.Secondary
CrosshairBtn.Text = "   Type: " .. Settings.CrosshairType
CrosshairBtn.Font = Enum.Font.Gotham
CrosshairBtn.TextColor3 = Theme.Accent
CrosshairBtn.TextXAlignment = Enum.TextXAlignment.Left
CrosshairBtn.Parent = Tabs.Visuals
ApplyStyle(CrosshairBtn, 6)

local crossTypes = {"Default", "Dot", "Gap", "Long"}
local typeIdx = 1
CrosshairBtn.MouseButton1Click:Connect(function()
    typeIdx = typeIdx + 1
    if typeIdx > #crossTypes then typeIdx = 1 end
    Settings.CrosshairType = crossTypes[typeIdx]
    CrosshairBtn.Text = "   Type: " .. Settings.CrosshairType
end)

CreateToggle("Streamable Mode", Settings.Streamable, function(v) Settings.Streamable = v end, Tabs.Visuals)

--// INFO TAB
local function CreateLabel(text, parent, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 0, 30)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.GothamSemibold
    l.TextColor3 = color or Theme.Text
    l.TextSize = 14
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
end

CreateLabel("Owner: XzshiroOfficial", Tabs.Info, Theme.Accent)
CreateLabel("Made: 4/5/2026", Tabs.Info, Theme.TextDark)
CreateLabel("Status: Active", Tabs.Info, Color3.new(0, 1, 0))

--// LOGIC
local function GetClosestPlayer()
    local closest = nil
    local shortestDist = Settings.FovRadius
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            local char = player.Character
            if char and char:FindFirstChild(Settings.AimPart) then
                local hum = char:FindFirstChild("Humanoid")
                if Settings.AliveCheck and hum and hum.Health <= 0 then continue end
                
                local part = char[Settings.AimPart]
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                
                if onScreen then
                    if Settings.InvisibleCheck and part.Transparency > 0.5 then continue end
                    if Settings.ForceFieldCheck and char:FindFirstChildOfClass("ForceField") then continue end

                    if Settings.WallCheck then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
                        local ray = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), rayParams)
                        if ray then continue end
                    end

                    local dist = (Vector2.new(pos.X, pos.Y) - ScreenCenter).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = part
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
    
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color = Theme.Accent

    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = Theme.Accent
    
    local healthBarBg = Drawing.new("Square")
    healthBarBg.Thickness = 1
    healthBarBg.Filled = true
    healthBarBg.Color = Color3.new(0, 0, 0)
    
    local healthBar = Drawing.new("Square")
    healthBar.Thickness = 1
    healthBar.Filled = true
    healthBar.Color = Color3.new(0, 1, 0)
    
    EspTable[player] = {Highlight = highlight, Tracer = tracer, Box = box, HealthBarBg = healthBarBg, HealthBar = healthBar}
end

RunService.RenderStepped:Connect(function()
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Position = ScreenCenter
    FovCircle.Visible = Settings.AimbotEnabled and not Settings.Streamable
    
    -- Crosshair Logic
    local chVisible = Settings.Crosshair and not Settings.Streamable
    CH_L1.Visible = false CH_L2.Visible = false CH_L3.Visible = false CH_L4.Visible = false CH_Dot.Visible = false

    if chVisible then
        if Settings.CrosshairType == "Dot" then
            CH_Dot.Visible = true
            CH_Dot.Position = ScreenCenter
            CH_Dot.Radius = 3
            CH_Dot.Color = Theme.Accent
            CH_Dot.Filled = true
        elseif Settings.CrosshairType == "Default" or Settings.CrosshairType == "Gap" or Settings.CrosshairType == "Long" then
            local gap = (Settings.CrosshairType == "Gap") and 8 or 2
            local len = (Settings.CrosshairType == "Long") and 15 or 8
            CH_L1.Visible = true; CH_L1.From = ScreenCenter + Vector2.new(gap, 0); CH_L1.To = ScreenCenter + Vector2.new(gap+len, 0); CH_L1.Color = Theme.Accent
            CH_L2.Visible = true; CH_L2.From = ScreenCenter - Vector2.new(gap, 0); CH_L2.To = ScreenCenter - Vector2.new(gap+len, 0); CH_L2.Color = Theme.Accent
            CH_L3.Visible = true; CH_L3.From = ScreenCenter + Vector2.new(0, gap); CH_L3.To = ScreenCenter + Vector2.new(0, gap+len); CH_L3.Color = Theme.Accent
            CH_L4.Visible = true; CH_L4.From = ScreenCenter - Vector2.new(0, gap); CH_L4.To = ScreenCenter - Vector2.new(0, gap+len); CH_L4.Color = Theme.Accent
        end
    end

    -- ESP Loop
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local data = EspTable[player]
        if not data then CreateEsp(player) continue end
        
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if char and char:FindFirstChild("HumanoidRootPart") and hum and not Settings.Streamable then
            local hrp = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local col = (player.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Color3.new(1,0,0)

            data.Highlight.Parent = Settings.EspEnabled and char or nil
            data.Highlight.FillColor = col
            
            if onScreen then
                local sizeX = 2000 / pos.Z
                local sizeY = 3000 / pos.Z
                local boxPos = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)

                if Settings.BoxEsp then
                    data.Box.Visible = true
                    data.Box.Size = Vector2.new(sizeX, sizeY)
                    data.Box.Position = boxPos
                    data.Box.Color = col
                else data.Box.Visible = false end

                if Settings.HealthBar then
                    local healthPercent = hum.Health / hum.MaxHealth
                    data.HealthBarBg.Visible = true
                    data.HealthBarBg.Position = Vector2.new(boxPos.X - 6, boxPos.Y)
                    data.HealthBarBg.Size = Vector2.new(4, sizeY)
                    
                    data.HealthBar.Visible = true
                    data.HealthBar.Position = Vector2.new(boxPos.X - 6, boxPos.Y + (sizeY * (1 - healthPercent)))
                    data.HealthBar.Size = Vector2.new(4, sizeY * healthPercent)
                    data.HealthBar.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1)
                else
                    data.HealthBar.Visible = false
                    data.HealthBarBg.Visible = false
                end

                if Settings.Tracers then
                    data.Tracer.Visible = true
                    data.Tracer.From = Vector2.new(ScreenCenter.X, Camera.ViewportSize.Y)
                    data.Tracer.To = Vector2.new(pos.X, pos.Y)
                    data.Tracer.Color = col
                else data.Tracer.Visible = false end
            else
                data.Box.Visible = false
                data.Tracer.Visible = false
                data.HealthBar.Visible = false
                data.HealthBarBg.Visible = false
            end
        else
            data.Highlight.Parent = nil
            data.Tracer.Visible = false
            data.Box.Visible = false
            data.HealthBar.Visible = false
            data.HealthBarBg.Visible = false
        end
    end

    -- Aimbot Execution
    if Settings.AimbotEnabled then
        local isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        local fovChanged = math.abs(Camera.FieldOfView - InitialFOV) > 1
        local shouldTrigger = Settings.FovChangeAim and fovChanged or isAiming

        if shouldTrigger then
            local target = GetClosestPlayer()
            if target then
                local targetPos = target.Position
                local root = target.Parent:FindFirstChild("HumanoidRootPart")
                if root then
                    targetPos = targetPos + (root.Velocity * 0.016 * Settings.PredictionAmount)
                end
                local lookAt = CFrame.new(Camera.CFrame.Position, targetPos)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, math.clamp(Settings.Smoothing + Settings.SnapStrength, 0.01, 1))
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Settings.MenuKey then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then OpenButton.Visible = false end
    end
end)

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateEsp(p) end end
Players.PlayerAdded:Connect(CreateEsp)
