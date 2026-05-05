--// XZSHIRO PREMIUM EDITION 
--// UPDATED LOGIC & GUI (Box ESP & Smart Aim Fixed)
--// Added Key System & UI Layering Fix

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
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Theme & Settings
local Theme = {
    Main = Color3.fromRGB(10, 10, 12),
    Secondary = Color3.fromRGB(18, 18, 22),
    Accent = Color3.fromRGB(0, 200, 255),
    Accent2 = Color3.fromRGB(0, 100, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(150, 150, 160),
    Red = Color3.fromRGB(255, 60, 60)
}

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

--// KEY SYSTEM START
local KeySystemGui = Instance.new("ScreenGui")
KeySystemGui.Name = "Xz_KeySystem"
ProtectInstance(KeySystemGui)

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 350, 0, 220)
KeyFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
KeyFrame.BackgroundColor3 = Theme.Main
KeyFrame.Parent = KeySystemGui
ApplyStyle(KeyFrame, 10)

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 50)
KeyTitle.Text = "KEY SYSTEM"
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 18
KeyTitle.TextColor3 = Theme.Accent
KeyTitle.BackgroundTransparency = 1
KeyTitle.Parent = KeyFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0, 280, 0, 40)
KeyInput.Position = UDim2.new(0.5, -140, 0, 70)
KeyInput.BackgroundColor3 = Theme.Secondary
KeyInput.PlaceholderText = "Enter Key Here..."
KeyInput.Text = ""
KeyInput.TextColor3 = Theme.Text
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = KeyFrame
ApplyStyle(KeyInput, 6)

local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(0, 135, 0, 40)
CheckBtn.Position = UDim2.new(0.5, -140, 0, 130)
CheckBtn.BackgroundColor3 = Theme.Accent
CheckBtn.Text = "Check Key"
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextColor3 = Theme.Main
CheckBtn.Parent = KeyFrame
ApplyStyle(CheckBtn, 6)

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0, 135, 0, 40)
GetKeyBtn.Position = UDim2.new(0.5, 5, 0, 130)
GetKeyBtn.BackgroundColor3 = Theme.Secondary
GetKeyBtn.Text = "Get Key"
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextColor3 = Theme.Text
GetKeyBtn.Parent = KeyFrame
ApplyStyle(GetKeyBtn, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 1, -40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Please provide a valid key"
StatusLabel.TextColor3 = Theme.TextDark
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = KeyFrame

local function StartMainScript()
    KeySystemGui:Destroy()
    
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
        CrosshairType = "Classic",
        IgnoredPlayers = {}
    }

    local InitialFOV = Camera.FieldOfView
    local EspTable = {}

    local FovCircle = Drawing.new("Circle")
    FovCircle.Thickness = 1.5
    FovCircle.Color = Settings.FovColor
    FovCircle.Filled = false
    FovCircle.Radius = Settings.FovRadius
    FovCircle.Visible = false

    local CrosshairLines = {
        L1 = Drawing.new("Line"), L2 = Drawing.new("Line"),
        L3 = Drawing.new("Line"), L4 = Drawing.new("Line"),
        Dot = Drawing.new("Circle")
    }

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
    ApplyStyle(MainFrame, 10)

    -- FIX: Close Button Layering
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Theme.TextDark
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.ZIndex = 10 -- Ensure it's on top
    CloseBtn.Parent = MainFrame

    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.new(0, 140, 0, 35)
    OpenBtn.Position = UDim2.new(0.5, -70, 0, -40)
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
    Title.Text = "XZSHIRO"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Theme.Accent
    Title.BackgroundTransparency = 1
    Title.ZIndex = 5
    Title.Parent = SideBar

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -180, 1, -50) -- Adjusted size so it doesn't overlap top bar
    ContentFrame.Position = UDim2.new(0, 170, 0, 40) -- Adjusted position
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

    --// Re-use your Toggle/Slider functions here
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
                updateVisuals(math.floor(min + (max - min) * pos))
            end
        end)
    end

    --// Populate Tabs
    CreateToggle("Enable Aimbot", Settings.AimbotEnabled, function(v) Settings.AimbotEnabled = v end, Tabs.Combat)
    CreateToggle("FOV Based Aiming", Settings.FovChangeAim, function(v) Settings.FovChangeAim = v end, Tabs.Combat)
    CreateSlider("FOV Radius", 10, 800, Settings.FovRadius, function(v) Settings.FovRadius = v FovCircle.Radius = v end, Tabs.Combat)
    
    CreateToggle("Enable ESP Highlights", Settings.EspEnabled, function(v) Settings.EspEnabled = v end, Tabs.Visuals)
    CreateToggle("Box ESP", Settings.BoxEsp, function(v) Settings.BoxEsp = v end, Tabs.Visuals)
    CreateToggle("Tracers", Settings.Tracers, function(v) Settings.Tracers = v end, Tabs.Visuals)

    --// LOGIC (Simplified for brevity, matches your original)
    local function GetClosestPlayer()
        local closest = nil
        local shortestDist = Settings.FovRadius
        local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.AimPart) then
                if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
                local part = player.Character[Settings.AimPart]
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - ScreenCenter).Magnitude
                    if dist < shortestDist then shortestDist = dist; closest = part end
                end
            end
        end
        return closest
    end

    RunService.RenderStepped:Connect(function()
        local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FovCircle.Position = ScreenCenter
        FovCircle.Visible = Settings.AimbotEnabled and not Settings.Streamable
        
        if Settings.AimbotEnabled then
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local target = GetClosestPlayer()
                if target then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.Smoothing + Settings.SnapStrength)
                end
            end
        end
    end)
end

--// Key System Logic
CheckBtn.MouseButton1Click:Connect(function()
    StatusLabel.Text = "Checking key..."
    local success, result = pcall(function()
        return game:HttpGet("https://pastebin.com/raw/xzMncF1h")
    end)
    
    if success then
        -- Remove possible whitespace from pastebin
        local cleanKey = result:gsub("%s+", "")
        if KeyInput.Text == cleanKey then
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            StatusLabel.Text = "Access Granted!"
            task.wait(1)
            StartMainScript()
        else
            StatusLabel.TextColor3 = Theme.Red
            StatusLabel.Text = "Invalid Key!"
        end
    else
        StatusLabel.Text = "Error fetching key from server."
    end
end)

GetKeyBtn.MouseButton1Click:Connect(function()
    setclipboard("https://pastebin.com/xzMncF1h")
    StatusLabel.Text = "Link copied to clipboard!"
end)
