--// XZSHIRO PREMIUM EDITION 
--// UPDATED LOGIC & GUI (Box ESP & Smart Aim Fixed)

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
    CrosshairType = "Classic", -- Classic, Dot, T-Shape, Diamond
    IgnoredPlayers = {} -- Whitelist System
}

local InitialFOV = Camera.FieldOfView
local EspTable = {}
local Theme = {
    Main = Color3.fromRGB(10, 10, 12),
    Secondary = Color3.fromRGB(18, 18, 22),
    Accent = Color3.fromRGB(0, 200, 255),
    Accent2 = Color3.fromRGB(0, 100, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(150, 150, 160),
    Red = Color3.fromRGB(255, 60, 60)
}

--// Drawing API Visuals
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1.5
FovCircle.Color = Settings.FovColor
FovCircle.Filled = false
FovCircle.Radius = Settings.FovRadius
FovCircle.Visible = false

local CrosshairLines = {
    L1 = Drawing.new("Line"),
    L2 = Drawing.new("Line"),
    L3 = Drawing.new("Line"),
    L4 = Drawing.new("Line"),
    Dot = Drawing.new("Circle")
}

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

-- Close Button (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.TextDark
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame

-- Open Button (Top Center)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 140, 0, 35)
OpenBtn.Position = UDim2.new(0.5, -70, 0, -40) -- Hidden initially
OpenBtn.BackgroundColor3 = Theme.Secondary
OpenBtn.Text = "Open Premium"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextColor3 = Theme.Accent
OpenBtn.TextSize = 13
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui
ApplyStyle(OpenBtn, 6)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
    OpenBtn:TweenPosition(UDim2.new(0.5, -70, 0, 10), "Out", "Back", 0.3, true)
end)

OpenBtn.MouseButton1Click:Connect(function()
    OpenBtn:TweenPosition(UDim2.new(0.5, -70, 0, -40), "In", "Quad", 0.2, true, function()
        OpenBtn.Visible = false
        MainFrame.Visible = true
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
    frame.ScrollBarThickness = 2
    frame.ScrollBarImageColor3 = Theme.Accent
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
CreateTab("Misc")
Tabs.Combat.Visible = true

local function CreateNav(name, iconId)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 40)
    local buttonCount = 0
    for _, v in pairs(SideBar:GetChildren()) do if v:IsA("TextButton") then buttonCount = buttonCount + 1 end end
    b.Position = UDim2.new(0, 10, 0, 70 + (buttonCount * 45))
    b.BackgroundColor3 = Theme.Main
    b.BackgroundTransparency = 0.5
    b.Text = "  " .. name:upper()
    b.Font = Enum.Font.GothamSemibold
    b.TextColor3 = name == "Combat" and Theme.Accent or Theme.TextDark
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

CreateNav("Combat", "")
CreateNav("Visuals", "")
CreateNav("Misc", "")

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
    local function updateFromMouse(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        updateVisuals(val)
    end

    sliderBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateFromMouse(input) end end)

    inputBox.FocusLost:Connect(function()
        local val = tonumber(inputBox.Text)
        if val then updateVisuals(val) else inputBox.Text = tostring(default) end
    end)
end

--// Whitelist System UI
local function CreateWhitelistSystem(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 120)
    frame.BackgroundColor3 = Theme.Secondary
    frame.Parent = parent
    ApplyStyle(frame, 6)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 25)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "AIMBOT WHITELIST"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Theme.Accent
    title.TextSize = 11
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -80, 0, 30)
    input.Position = UDim2.new(0, 10, 0, 30)
    input.BackgroundColor3 = Theme.Main
    input.PlaceholderText = "Player Name..."
    input.Text = ""
    input.Font = Enum.Font.Gotham
    input.TextColor3 = Theme.Text
    input.TextSize = 12
    input.Parent = frame
    ApplyStyle(input, 4)

    local add = Instance.new("TextButton")
    add.Size = UDim2.new(0, 60, 0, 30)
    add.Position = UDim2.new(1, -70, 0, 30)
    add.BackgroundColor3 = Theme.Accent
    add.Text = "Add"
    add.Font = Enum.Font.GothamBold
    add.TextColor3 = Theme.Main
    add.TextSize = 12
    add.Parent = frame
    ApplyStyle(add, 4)

    local listScroll = Instance.new("ScrollingFrame")
    listScroll.Size = UDim2.new(1, -20, 0, 50)
    listScroll.Position = UDim2.new(0, 10, 0, 65)
    listScroll.BackgroundTransparency = 1
    listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    listScroll.ScrollBarThickness = 2
    listScroll.Parent = frame
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = listScroll

    local function updateList()
        for _, v in pairs(listScroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
        for i, name in pairs(Settings.IgnoredPlayers) do
            local item = Instance.new("Frame")
            item.Size = UDim2.new(1, -5, 0, 25)
            item.BackgroundColor3 = Theme.Main
            item.Parent = listScroll
            ApplyStyle(item, 4)

            local n = Instance.new("TextLabel")
            n.Size = UDim2.new(1, -40, 1, 0)
            n.Position = UDim2.new(0, 8, 0, 0)
            n.Text = name
            n.Font = Enum.Font.Gotham
            n.TextColor3 = Theme.TextDark
            n.TextSize = 11
            n.BackgroundTransparency = 1
            n.TextXAlignment = Enum.TextXAlignment.Left
            n.Parent = item

            local rem = Instance.new("TextButton")
            rem.Size = UDim2.new(0, 35, 0, 20)
            rem.Position = UDim2.new(1, -38, 0.5, -10)
            rem.BackgroundColor3 = Theme.Red
            rem.Text = "X"
            rem.Font = Enum.Font.GothamBold
            rem.TextColor3 = Theme.Text
            rem.Parent = item
            ApplyStyle(rem, 4)

            rem.MouseButton1Click:Connect(function()
                table.remove(Settings.IgnoredPlayers, i)
                updateList()
            end)
        end
        listScroll.CanvasSize = UDim2.new(0,0,0, listLayout.AbsoluteContentSize.Y)
    end

    add.MouseButton1Click:Connect(function()
        if input.Text ~= "" and not table.find(Settings.IgnoredPlayers, input.Text) then
            table.insert(Settings.IgnoredPlayers, input.Text)
            input.Text = ""
            updateList()
        end
    end)
end

--// Crosshair Selector
local function CreateCrosshairSelector(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 45)
    frame.BackgroundColor3 = Theme.Secondary
    frame.Parent = parent
    ApplyStyle(frame, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = "Crosshair Style:"
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Theme.TextDark
    label.TextSize = 12
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local nextBtn = Instance.new("TextButton")
    nextBtn.Size = UDim2.new(0, 100, 0, 30)
    nextBtn.Position = UDim2.new(1, -110, 0.5, -15)
    nextBtn.BackgroundColor3 = Theme.Main
    nextBtn.Text = Settings.CrosshairType
    nextBtn.Font = Enum.Font.GothamBold
    nextBtn.TextColor3 = Theme.Accent
    nextBtn.TextSize = 11
    nextBtn.Parent = frame
    ApplyStyle(nextBtn, 4)

    local styles = {"Classic", "Dot", "T-Shape", "Diamond", "Gap"}
    local currentIdx = 1
    nextBtn.MouseButton1Click:Connect(function()
        currentIdx = currentIdx + 1
        if currentIdx > #styles then currentIdx = 1 end
        Settings.CrosshairType = styles[currentIdx]
        nextBtn.Text = Settings.CrosshairType
    end)
end

--// Populate Tabs
CreateToggle("Enable Aimbot", Settings.AimbotEnabled, function(v) Settings.AimbotEnabled = v end, Tabs.Combat)
CreateToggle("FOV Based Aiming", Settings.FovChangeAim, function(v) Settings.FovChangeAim = v end, Tabs.Combat)
CreateToggle("Wall Check", Settings.WallCheck, function(v) Settings.WallCheck = v end, Tabs.Combat)
CreateToggle("Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end, Tabs.Combat)
CreateSlider("FOV Radius", 10, 800, Settings.FovRadius, function(v) Settings.FovRadius = v FovCircle.Radius = v end, Tabs.Combat)
CreateSlider("Snap Strength", 1, 100, 15, function(v) Settings.SnapStrength = v/100 end, Tabs.Combat)
CreateSlider("Smoothness", 1, 100, 5, function(v) Settings.Smoothing = v/100 end, Tabs.Combat)
CreateWhitelistSystem(Tabs.Combat)

CreateToggle("Enable ESP Highlights", Settings.EspEnabled, function(v) Settings.EspEnabled = v end, Tabs.Visuals)
CreateToggle("Box ESP", Settings.BoxEsp, function(v) Settings.BoxEsp = v end, Tabs.Visuals)
CreateToggle("Tracers", Settings.Tracers, function(v) Settings.Tracers = v end, Tabs.Visuals)
CreateToggle("Custom Crosshair", Settings.Crosshair, function(v) Settings.Crosshair = v end, Tabs.Visuals)
CreateCrosshairSelector(Tabs.Visuals)
CreateToggle("Streamable Mode", Settings.Streamable, function(v) Settings.Streamable = v end, Tabs.Visuals)

CreateToggle("Forcefield Check", Settings.ForceFieldCheck, function(v) Settings.ForceFieldCheck = v end, Tabs.Misc)
CreateToggle("Invisible Check", Settings.InvisibleCheck, function(v) Settings.InvisibleCheck = v end, Tabs.Misc)

--// SMART LOGIC IMPLEMENTATION
local function GetClosestPlayer()
    local closest = nil
    local shortestDist = Settings.FovRadius
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Whitelist Check
            if table.find(Settings.IgnoredPlayers, player.Name) then continue end
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
    EspTable[player] = {Highlight = highlight, Tracer = tracer, Box = box}
end

--// Main Loop
RunService.RenderStepped:Connect(function()
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Position = ScreenCenter
    FovCircle.Visible = Settings.AimbotEnabled and not Settings.Streamable
    
    -- Crosshair Drawing Logic
    for _, v in pairs(CrosshairLines) do v.Visible = false end
    if Settings.Crosshair and not Settings.Streamable then
        local color = Theme.Accent
        if Settings.CrosshairType == "Classic" then
            CrosshairLines.L1.Visible = true; CrosshairLines.L1.From = ScreenCenter - Vector2.new(10, 0); CrosshairLines.L1.To = ScreenCenter + Vector2.new(10, 0); CrosshairLines.L1.Color = color
            CrosshairLines.L2.Visible = true; CrosshairLines.L2.From = ScreenCenter - Vector2.new(0, 10); CrosshairLines.L2.To = ScreenCenter + Vector2.new(0, 10); CrosshairLines.L2.Color = color
        elseif Settings.CrosshairType == "Dot" then
            CrosshairLines.Dot.Visible = true; CrosshairLines.Dot.Position = ScreenCenter; CrosshairLines.Dot.Radius = 3; CrosshairLines.Dot.Filled = true; CrosshairLines.Dot.Color = color
        elseif Settings.CrosshairType == "T-Shape" then
            CrosshairLines.L1.Visible = true; CrosshairLines.L1.From = ScreenCenter - Vector2.new(10, 0); CrosshairLines.L1.To = ScreenCenter + Vector2.new(10, 0); CrosshairLines.L1.Color = color
            CrosshairLines.L2.Visible = true; CrosshairLines.L2.From = ScreenCenter; CrosshairLines.L2.To = ScreenCenter + Vector2.new(0, 10); CrosshairLines.L2.Color = color
        elseif Settings.CrosshairType == "Diamond" then
            CrosshairLines.L1.Visible = true; CrosshairLines.L1.From = ScreenCenter + Vector2.new(0, -8); CrosshairLines.L1.To = ScreenCenter + Vector2.new(8, 0); CrosshairLines.L1.Color = color
            CrosshairLines.L2.Visible = true; CrosshairLines.L2.From = ScreenCenter + Vector2.new(8, 0); CrosshairLines.L2.To = ScreenCenter + Vector2.new(0, 8); CrosshairLines.L2.Color = color
            CrosshairLines.L3.Visible = true; CrosshairLines.L3.From = ScreenCenter + Vector2.new(0, 8); CrosshairLines.L3.To = ScreenCenter + Vector2.new(-8, 0); CrosshairLines.L3.Color = color
            CrosshairLines.L4.Visible = true; CrosshairLines.L4.From = ScreenCenter + Vector2.new(-8, 0); CrosshairLines.L4.To = ScreenCenter + Vector2.new(0, -8); CrosshairLines.L4.Color = color
        elseif Settings.CrosshairType == "Gap" then
            CrosshairLines.L1.Visible = true; CrosshairLines.L1.From = ScreenCenter + Vector2.new(4, 0); CrosshairLines.L1.To = ScreenCenter + Vector2.new(12, 0); CrosshairLines.L1.Color = color
            CrosshairLines.L2.Visible = true; CrosshairLines.L2.From = ScreenCenter - Vector2.new(4, 0); CrosshairLines.L2.To = ScreenCenter - Vector2.new(12, 0); CrosshairLines.L2.Color = color
            CrosshairLines.L3.Visible = true; CrosshairLines.L3.From = ScreenCenter + Vector2.new(0, 4); CrosshairLines.L3.To = ScreenCenter + Vector2.new(0, 12); CrosshairLines.L3.Color = color
            CrosshairLines.L4.Visible = true; CrosshairLines.L4.From = ScreenCenter - Vector2.new(0, 4); CrosshairLines.L4.To = ScreenCenter - Vector2.new(0, 12); CrosshairLines.L4.Color = color
        end
    end

    -- Update ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local data = EspTable[player]
        if not data then CreateEsp(player) continue end
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and not Settings.Streamable then
            local hrp = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            data.Highlight.Parent = Settings.EspEnabled and char or nil
            data.Highlight.FillColor = (player.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Color3.new(1,0,0)
            if Settings.BoxEsp and onScreen then
                local sizeX, sizeY = 2000 / pos.Z, 3000 / pos.Z
                data.Box.Visible = true; data.Box.Size = Vector2.new(sizeX, sizeY); data.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2); data.Box.Color = (player.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Color3.new(1,0,0)
            else data.Box.Visible = false end
            if Settings.Tracers and onScreen then
                data.Tracer.Visible = true; data.Tracer.From = Vector2.new(ScreenCenter.X, Camera.ViewportSize.Y); data.Tracer.To = Vector2.new(pos.X, pos.Y); data.Tracer.Color = (player.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Color3.new(1,0,0)
            else data.Tracer.Visible = false end
        else data.Highlight.Parent = nil; data.Tracer.Visible = false; data.Box.Visible = false end
    end

    -- Aimbot Execution
    if Settings.AimbotEnabled then
        local shouldTrigger = Settings.FovChangeAim and (math.abs(Camera.FieldOfView - InitialFOV) > 1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if shouldTrigger then
            local target = GetClosestPlayer()
            if target then
                local targetPos = target.Position
                local root = target.Parent:FindFirstChild("HumanoidRootPart")
                if root then
                    targetPos = targetPos + (root.Velocity * ( (target.Position - Camera.CFrame.Position).Magnitude / 1000 ) * Settings.PredictionAmount)
                end
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), math.clamp(Settings.Smoothing + Settings.SnapStrength, 0.01, 1))
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Settings.MenuKey then MainFrame.Visible = not MainFrame.Visible end
end)

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateEsp(p) end end
Players.PlayerAdded:Connect(CreateEsp)
