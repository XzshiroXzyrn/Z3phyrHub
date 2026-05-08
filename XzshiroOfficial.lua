--- START OF FILE ai_studio_code (33).txt ---

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// SETTINGS CONFIGURATION
local Settings = {
    -- Combat Logic
    AimbotEnabled = false,
    NpcAimbotEnabled = true, 
    AimPart = "Head",
    PredictionAmount = 0.165,
    SnapStrength = 0.15,
    StickyAim = 0.5,
    
    -- Activation Settings
    Platform = "PC",
    FovChangeAim = false, 
    CustomBoxEnabled = false,
    CustomBoxLocked = false,
    CustomBoxShape = "Rounded",
    CustomBoxSizeX = 110,
    CustomBoxSizeY = 110,
    
    -- FOV & Visuals
    FovRadius = 100,
    FovColor = Color3.fromRGB(0, 255, 200),
    Streamable = false, 
    TracerEnabled = false,
    EspEnabled = false,
    
    -- NEW ESP SUB-FEATURES
    EspHighlight = false,
    EspHealthBar = false,
    EspSkeleton = false,
    EspBox = false,
    EspNames = false,
    
    RainbowMode = false, 
    RainbowSpeed = 0.5,
    ShowStats = false, 
    
    -- UI Custom Settings
    ThemeR = 0,
    ThemeG = 160,
    ThemeB = 255,
    
    -- Filters/Checks
    TeamCheck = true,
    AliveCheck = true,
    WallCheck = true,
    InvisibleCheck = true,
    ForceFieldCheck = true
}

--// CONFIG SAVE/LOAD SYSTEM
local ConfigName = "XzPremium_Config.json"

local function SaveConfig()
    pcall(function()
        if writefile then
            writefile(ConfigName, HttpService:JSONEncode(Settings))
        end
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile and isfile(ConfigName) and readfile then
            local data = HttpService:JSONDecode(readfile(ConfigName))
            for k, v in pairs(data) do
                if Settings[k] ~= nil then
                    Settings[k] = v
                end
            end
        end
    end)
end

LoadConfig()

--// THEME CONFIGURATION
local Theme = {
    Main = Color3.fromRGB(20, 20, 24),
    Secondary = Color3.fromRGB(28, 28, 34),
    Tertiary = Color3.fromRGB(35, 35, 42),
    Accent = Color3.fromRGB(Settings.ThemeR, Settings.ThemeG, Settings.ThemeB),
    AccentDark = Color3.fromRGB(0, 80, 180),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(160, 160, 170),
    Tracer = Color3.fromRGB(0, 200, 255),
    Success = Color3.fromRGB(40, 200, 110)
}

--// UTILS & TRACKING
local BaseFOV = Camera.FieldOfView
local RainbowElements = { Strokes = {}, Backgrounds = {}, Texts = {} }
local CustomBoxActive = false
local ResizeModeActive = false
local EspCache = {}

local function ProtectInstance(instance)
    pcall(function()
        if gethui then instance.Parent = gethui()
        elseif CoreGui:FindFirstChild("RobloxGui") then instance.Parent = CoreGui
        else instance.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    end)
end

--// GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XzPremium_V5_" .. math.random(100,999)
ScreenGui.ResetOnSpawn = false
ProtectInstance(ScreenGui)

-- Trigger Box
local TriggerBox = Instance.new("Frame")
TriggerBox.Size = UDim2.new(0, Settings.CustomBoxSizeX, 0, Settings.CustomBoxSizeY)
TriggerBox.Position = UDim2.new(1, -150, 0.5, 0)
TriggerBox.BackgroundColor3 = Color3.new(1, 1, 1)
TriggerBox.BackgroundTransparency = 0.8
TriggerBox.Visible = Settings.CustomBoxEnabled
TriggerBox.Active = true
TriggerBox.Parent = ScreenGui

local TriggerCorner = Instance.new("UICorner", TriggerBox)
local TriggerImage = Instance.new("ImageLabel", TriggerBox)
TriggerImage.Size = UDim2.new(1, 0, 1, 0)
TriggerImage.BackgroundTransparency = 1
TriggerImage.Visible = false
TriggerImage.ImageColor3 = Color3.new(1,1,1)
TriggerImage.ImageTransparency = 0.8

local function UpdateBoxShape()
    if Settings.CustomBoxShape == "Rounded" then
        TriggerCorner.CornerRadius = UDim.new(0, 16)
        TriggerBox.BackgroundTransparency = 0.8
        TriggerImage.Visible = false
    elseif Settings.CustomBoxShape == "Square" then
        TriggerCorner.CornerRadius = UDim.new(0, 0)
        TriggerBox.BackgroundTransparency = 0.8
        TriggerImage.Visible = false
    elseif Settings.CustomBoxShape == "Circle" then
        TriggerCorner.CornerRadius = UDim.new(1, 0)
        TriggerBox.BackgroundTransparency = 0.8
        TriggerImage.Visible = false
    elseif Settings.CustomBoxShape == "Triangle" then
        TriggerCorner.CornerRadius = UDim.new(0, 0)
        TriggerBox.BackgroundTransparency = 1
        TriggerImage.Visible = true
        TriggerImage.Image = "rbxassetid://13192072120"
    elseif Settings.CustomBoxShape == "Heart" then
        TriggerCorner.CornerRadius = UDim.new(0, 0)
        TriggerBox.BackgroundTransparency = 1
        TriggerImage.Visible = true
        TriggerImage.Image = "rbxassetid://10651167735"
    end
end
UpdateBoxShape()

local TriggerStroke = Instance.new("UIStroke", TriggerBox)
TriggerStroke.Thickness = 2
TriggerStroke.Color = Settings.CustomBoxLocked and Theme.Success or Color3.new(1, 1, 1)
TriggerStroke.Transparency = 0.5
TriggerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local customClickCount = 0
local lastCustomClick = 0
local tbDragging, tbResizing, tbDragInput, tbDragStart, tbStartPos, tbStartSize

TriggerBox.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        CustomBoxActive = true
        local currentClick = tick()
        if currentClick - lastCustomClick < 0.4 then customClickCount = customClickCount + 1 else customClickCount = 1 end
        lastCustomClick = currentClick
        if customClickCount >= 10 then
            Settings.CustomBoxLocked = not Settings.CustomBoxLocked
            customClickCount = 0
            TriggerStroke.Color = Settings.CustomBoxLocked and Theme.Success or Color3.new(1, 1, 1)
            SaveConfig()
        end
        if not Settings.CustomBoxLocked then
            if ResizeModeActive then tbResizing = true else tbDragging = true end
            tbDragStart = input.Position; tbStartPos = TriggerBox.Position; tbStartSize = TriggerBox.Size
        end
        local endConn
        endConn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                tbDragging = false; tbResizing = false; CustomBoxActive = false
                if endConn then endConn:Disconnect() end
                SaveConfig()
            end
        end)
    end
end)
TriggerBox.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then tbDragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == tbDragInput and not Settings.CustomBoxLocked then
        if tbDragging then
            local delta = input.Position - tbDragStart
            TriggerBox.Position = UDim2.new(tbStartPos.X.Scale, tbStartPos.X.Offset + delta.X, tbStartPos.Y.Scale, tbStartPos.Y.Offset + delta.Y)
        elseif tbResizing then
            local delta = input.Position - tbDragStart
            local newX = math.clamp(tbStartSize.X.Offset + delta.X, 30, 500)
            local newY = math.clamp(tbStartSize.Y.Offset + delta.Y, 30, 500)
            TriggerBox.Size = UDim2.new(0, newX, 0, newY)
            Settings.CustomBoxSizeX = newX; Settings.CustomBoxSizeY = newY
        end
    end
end)

-- Main Frame
local Shadow = Instance.new("ImageLabel")
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(0, 560, 0, 420)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://7912134082"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.4
Shadow.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 530, 0, 390)
MainFrame.Position = UDim2.new(0.5, -265, 0.5, -195)
MainFrame.BackgroundColor3 = Theme.Main
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Dragging
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Shadow.Position = UDim2.new(0, MainFrame.AbsolutePosition.X + (MainFrame.AbsoluteSize.X/2), 0, MainFrame.AbsolutePosition.Y + (MainFrame.AbsoluteSize.Y/2))
    end
end)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
MainStroke.Color = Theme.Accent
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
table.insert(RainbowElements.Strokes, MainStroke)

-- Open Premium Button
local RestoreBtn = Instance.new("TextButton")
RestoreBtn.Size = UDim2.new(0, 140, 0, 32)
RestoreBtn.Position = UDim2.new(0.5, -70, 0, 15)
RestoreBtn.BackgroundColor3 = Theme.Main
RestoreBtn.Text = "OPEN PREMIUM"
RestoreBtn.TextColor3 = Color3.new(1,1,1)
RestoreBtn.Font = Enum.Font.JosefinSans
RestoreBtn.TextSize = 13
RestoreBtn.Visible = false -- Will be managed by logic
RestoreBtn.Parent = ScreenGui
Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(0, 6)
local RestoreStroke = Instance.new("UIStroke", RestoreBtn)
RestoreStroke.Thickness = 1.5
RestoreStroke.Color = Theme.Accent
RestoreStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
table.insert(RainbowElements.Strokes, RestoreStroke)

-- Stats HUD
local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(0, 150, 0, 30)
StatsFrame.Position = UDim2.new(0.5, -75, 0.1, 0)
StatsFrame.BackgroundColor3 = Theme.Secondary
StatsFrame.Visible = Settings.ShowStats
StatsFrame.Active = true
StatsFrame.Parent = ScreenGui
Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 8)
local StatsStroke = Instance.new("UIStroke", StatsFrame)
StatsStroke.Thickness = 2
StatsStroke.Color = Theme.Accent
StatsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
table.insert(RainbowElements.Strokes, StatsStroke)
local StatsLabel = Instance.new("TextLabel", StatsFrame)
StatsLabel.Size = UDim2.new(1, 0, 1, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS: 0 | Ping: 0ms"
StatsLabel.TextColor3 = Theme.Text
StatsLabel.Font = Enum.Font.JosefinSans
StatsLabel.TextSize = 12

local statsLocked = false
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 150, 1, -20)
SideBar.Position = UDim2.new(0, 10, 0, 10)
SideBar.BackgroundColor3 = Theme.Secondary
SideBar.Parent = MainFrame
Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 10)

local SideBarLayout = Instance.new("UIListLayout", SideBar)
SideBarLayout.Padding = UDim.new(0, 8); SideBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; SideBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", SideBar).PaddingTop = UDim.new(0, 15)

local HeaderLabel = Instance.new("TextLabel", SideBar)
HeaderLabel.Size = UDim2.new(0, 130, 0, 30); HeaderLabel.BackgroundTransparency = 1; HeaderLabel.Text = "XZSHIRO"; HeaderLabel.TextColor3 = Theme.Accent; HeaderLabel.Font = Enum.Font.JosefinSans; HeaderLabel.TextSize = 20
table.insert(RainbowElements.Texts, HeaderLabel)
local HeaderSub = Instance.new("TextLabel", SideBar)
HeaderSub.Size = UDim2.new(0, 130, 0, 15); HeaderSub.BackgroundTransparency = 1; HeaderSub.Text = "Premium V5"; HeaderSub.TextColor3 = Theme.TextDark; HeaderSub.Font = Enum.Font.JosefinSans; HeaderSub.TextSize = 11

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -170, 1, -20); ContentArea.Position = UDim2.new(0, 160, 0, 10); ContentArea.BackgroundTransparency = 1; ContentArea.Parent = MainFrame

--// UI COMPONENT CREATORS
local Tabs = {}; local NavButtons = {}
local function CreateTab(name)
    local f = Instance.new("ScrollingFrame")
    f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 1; f.Visible = false; f.ScrollBarThickness = 4; f.ScrollBarImageColor3 = Theme.Accent; f.CanvasSize = UDim2.new(0,0,0,0); f.AutomaticCanvasSize = Enum.AutomaticSize.Y; f.Parent = ContentArea
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 12)
    local pad = Instance.new("UIPadding", f); pad.PaddingRight = UDim.new(0, 10); pad.PaddingTop = UDim.new(0, 5); pad.PaddingBottom = UDim.new(0, 10)
    Tabs[name] = f
    return f
end

local function UpdateNavStates(activeTab)
    for _, nav in pairs(NavButtons) do
        local isSelected = (nav.Tab == activeTab)
        TweenService:Create(nav.Btn, TweenInfo.new(0.3), {BackgroundColor3 = isSelected and Theme.Tertiary or Theme.Secondary}):Play()
        TweenService:Create(nav.Txt, TweenInfo.new(0.3), {TextColor3 = isSelected and Theme.Text or Theme.TextDark}):Play()
        TweenService:Create(nav.Icon, TweenInfo.new(0.3), {ImageColor3 = isSelected and Theme.Accent or Theme.TextDark}):Play()
    end
end

local function CreateNav(name, tab, iconId)
    local btn = Instance.new("TextButton", SideBar)
    btn.Size = UDim2.new(1, -16, 0, 36); btn.BackgroundColor3 = Theme.Secondary; btn.Text = ""; btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local icon = Instance.new("ImageLabel", btn); icon.Size = UDim2.new(0, 18, 0, 18); icon.Position = UDim2.new(0, 10, 0.5, -9); icon.Image = iconId; icon.BackgroundTransparency = 1; icon.ImageColor3 = Theme.TextDark
    local txt = Instance.new("TextLabel", btn); txt.Size = UDim2.new(1, -35, 1, 0); txt.Position = UDim2.new(0, 35, 0, 0); txt.BackgroundTransparency = 1; txt.Text = name; txt.Font = Enum.Font.JosefinSans; txt.TextSize = 13; txt.TextColor3 = Theme.TextDark; txt.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(NavButtons, {Btn = btn, Icon = icon, Txt = txt, Tab = tab})
    btn.MouseButton1Click:Connect(function() for _, t in pairs(Tabs) do t.Visible = false end; tab.Visible = true; UpdateNavStates(tab) end)
end

local function CreateToggle(name, default, callback, parent, isSmall)
    local t = Instance.new("TextButton", parent)
    t.Size = UDim2.new(1, 0, 0, isSmall and 30 or 38)
    t.BackgroundColor3 = Theme.Secondary
    t.Text = (isSmall and "      " or "   ") .. name
    t.Font = Enum.Font.JosefinSans
    t.TextSize = isSmall and 12 or 14
    t.TextColor3 = isSmall and Theme.TextDark or Theme.Text
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.AutoButtonColor = false
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)

    local indicatorBG = Instance.new("Frame", t)
    indicatorBG.Size = UDim2.new(0, isSmall and 26 or 32, 0, isSmall and 14 or 18)
    indicatorBG.Position = UDim2.new(1, -44, 0.5, isSmall and -7 or -9)
    indicatorBG.BackgroundColor3 = default and Theme.Accent or Theme.Tertiary
    Instance.new("UICorner", indicatorBG).CornerRadius = UDim.new(1, 0)
    if default then table.insert(RainbowElements.Backgrounds, indicatorBG) end

    local indicator = Instance.new("Frame", indicatorBG)
    indicator.Size = UDim2.new(0, isSmall and 10 or 12, 0, isSmall and 10 or 12)
    indicator.Position = UDim2.new(default and 1 or 0, default and (isSmall and -12 or -15) or 3, 0.5, isSmall and -5 or -6)
    indicator.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    local state = default
    t.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.new(state and 1 or 0, state and (isSmall and -12 or -15) or 3, 0.5, isSmall and -5 or -6)}):Play()
        TweenService:Create(indicatorBG, TweenInfo.new(0.25), {BackgroundColor3 = state and Theme.Accent or Theme.Tertiary}):Play()
        if state then table.insert(RainbowElements.Backgrounds, indicatorBG) else
            for i, v in ipairs(RainbowElements.Backgrounds) do if v == indicatorBG then table.remove(RainbowElements.Backgrounds, i) break end end
        end
        callback(state)
        SaveConfig()
    end)
    return t
end

local function CreateSlider(name, min, max, default, callback, parent)
    local container = Instance.new("Frame", parent); container.Size = UDim2.new(1, 0, 0, 55); container.BackgroundColor3 = Theme.Secondary; Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    local label = Instance.new("TextLabel", container); label.Text = "   " .. name; label.Size = UDim2.new(1, 0, 0, 28); label.BackgroundTransparency = 1; label.TextColor3 = Theme.Text; label.Font = Enum.Font.JosefinSans; label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left
    local box = Instance.new("TextBox", container); box.Size = UDim2.new(0, 40, 0, 22); box.Position = UDim2.new(1, -50, 0, 4); box.BackgroundColor3 = Theme.Tertiary; box.Text = tostring(default); box.TextColor3 = Theme.Text; box.Font = Enum.Font.JosefinSans; box.TextSize = 12; Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    local sliderBar = Instance.new("Frame", container); sliderBar.Size = UDim2.new(1, -24, 0, 6); sliderBar.Position = UDim2.new(0, 12, 0, 38); sliderBar.BackgroundColor3 = Theme.Tertiary; Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", sliderBar); fill.Size = UDim2.new(math.clamp((default-min)/(max-min), 0, 1), 0, 1, 0); fill.BackgroundColor3 = Theme.Accent; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0); table.insert(RainbowElements.Backgrounds, fill)
    local function update(val) val = math.clamp(math.round(val * 100) / 100, min, max); box.Text = tostring(val); TweenService:Create(fill, TweenInfo.new(0.15), {Size = UDim2.new((val-min)/(max-min), 0, 1, 0)}):Play(); callback(val); SaveConfig() end
    sliderBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local connection; connection = RunService.RenderStepped:Connect(function() local mPos = UserInputService:GetMouseLocation().X; local bPos = sliderBar.AbsolutePosition.X; local bSize = sliderBar.AbsoluteSize.X; update(min + (max - min) * math.clamp((mPos - bPos) / bSize, 0, 1)); if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then connection:Disconnect() end end) end end)
end

local function CreateButton(name, callback, parent)
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, 0, 0, 38); btn.BackgroundColor3 = Theme.Tertiary; btn.Text = name; btn.Font = Enum.Font.JosefinSans; btn.TextSize = 14; btn.TextColor3 = Theme.Text; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8); btn.MouseButton1Click:Connect(callback); return btn
end

local function CreateSelector(name, options, default, callback, parent)
    local container = Instance.new("Frame", parent); container.Size = UDim2.new(1, 0, 0, 40); container.BackgroundColor3 = Theme.Secondary; Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    local label = Instance.new("TextLabel", container); label.Text = "   " .. name; label.Size = UDim2.new(0.5, 0, 1, 0); label.BackgroundTransparency = 1; label.TextColor3 = Theme.Text; label.Font = Enum.Font.JosefinSans; label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", container); btn.Size = UDim2.new(0.4, 0, 0.7, 0); btn.Position = UDim2.new(0.55, 0, 0.15, 0); btn.BackgroundColor3 = Theme.Tertiary; btn.Text = default; btn.TextColor3 = Theme.Accent; btn.Font = Enum.Font.JosefinSans; btn.TextSize = 12; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6); table.insert(RainbowElements.Texts, btn)
    local current = table.find(options, default) or 1; btn.MouseButton1Click:Connect(function() current = (current >= #options) and 1 or current + 1; btn.Text = options[current]; callback(options[current]); SaveConfig() end)
end

local function UpdateThemeColor()
    Theme.Accent = Color3.fromRGB(Settings.ThemeR, Settings.ThemeG, Settings.ThemeB)
    if not Settings.RainbowMode then
        for _, element in pairs(RainbowElements.Strokes) do pcall(function() if element == StatsStroke and statsLocked then element.Color = Theme.Success else element.Color = Theme.Accent end end) end
        for _, element in pairs(RainbowElements.Backgrounds) do pcall(function() element.BackgroundColor3 = Theme.Accent end) end
        for _, element in pairs(RainbowElements.Texts) do pcall(function() element.TextColor3 = Theme.Accent end) end
    end
end

--// TABS POPULATION
local CombatTab = CreateTab("Combat"); local VisualsTab = CreateTab("Visuals"); local SettingsTab = CreateTab("Settings"); local CustomTab = CreateTab("Custom"); local UiCustomTab = CreateTab("UI Custom"); local InfoTab = CreateTab("Info")
CreateNav("COMBAT", CombatTab, "rbxassetid://7733674079"); CreateNav("VISUALS", VisualsTab, "rbxassetid://7733779610"); CreateNav("FILTERS", SettingsTab, "rbxassetid://7734053495"); CreateNav("CUSTOM", CustomTab, "rbxassetid://8997385940"); CreateNav("UI CUSTOM", UiCustomTab, "rbxassetid://7734068321"); CreateNav("INFO", InfoTab, "rbxassetid://7733770136")

-- Combat Tab
CreateToggle("Enable Aimbot", Settings.AimbotEnabled, function(v) Settings.AimbotEnabled = v end, CombatTab)
CreateToggle("Target NPCs/Bots", Settings.NpcAimbotEnabled, function(v) Settings.NpcAimbotEnabled = v end, CombatTab)
CreateSelector("Aim Part", {"Head", "UpperTorso", "HumanoidRootPart"}, Settings.AimPart, function(v) Settings.AimPart = v end, CombatTab)
CreateSlider("FOV Radius", 10, 800, Settings.FovRadius, function(v) Settings.FovRadius = v end, CombatTab)
CreateSlider("Prediction Lead", 0, 5, Settings.PredictionAmount, function(v) Settings.PredictionAmount = v end, CombatTab)
CreateSlider("Snap Strength", 0, 1, Settings.SnapStrength, function(v) Settings.SnapStrength = v end, CombatTab)
CreateSlider("Sticky Power", 0, 1, Settings.StickyAim, function(v) Settings.StickyAim = v end, CombatTab)

-- Visuals Tab
local EspSubFrame = Instance.new("Frame", VisualsTab)
EspSubFrame.Size = UDim2.new(1, 0, 0, 0); EspSubFrame.BackgroundTransparency = 1; EspSubFrame.ClipsDescendants = true
local EspSubLayout = Instance.new("UIListLayout", EspSubFrame); EspSubLayout.Padding = UDim.new(0, 5)

local function UpdateEspSubVisibility(v)
    local targetSize = v and (5 * 35) or 0
    TweenService:Create(EspSubFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, targetSize)}):Play()
end

CreateToggle("Enable ESP", Settings.EspEnabled, function(v) Settings.EspEnabled = v; UpdateEspSubVisibility(v) end, VisualsTab)
CreateToggle("Highlight", Settings.EspHighlight, function(v) Settings.EspHighlight = v end, EspSubFrame, true)
CreateToggle("Healthbar", Settings.EspHealthBar, function(v) Settings.EspHealthBar = v end, EspSubFrame, true)
CreateToggle("Skeleton", Settings.EspSkeleton, function(v) Settings.EspSkeleton = v end, EspSubFrame, true)
CreateToggle("Box", Settings.EspBox, function(v) Settings.EspBox = v end, EspSubFrame, true)
CreateToggle("Name", Settings.EspNames, function(v) Settings.EspNames = v end, EspSubFrame, true)
UpdateEspSubVisibility(Settings.EspEnabled)

CreateToggle("Rainbow Mode", Settings.RainbowMode, function(v) Settings.RainbowMode = v end, VisualsTab)
CreateToggle("Target Tracer", Settings.TracerEnabled, function(v) Settings.TracerEnabled = v end, VisualsTab) 
CreateToggle("Streamable (Hide FOV/HUD)", Settings.Streamable, function(v) Settings.Streamable = v end, VisualsTab)
CreateToggle("Show FPS & Ping HUD", Settings.ShowStats, function(v) Settings.ShowStats = v end, VisualsTab)

-- Settings/Filters
CreateSelector("Platform Mode", {"PC", "Mobile"}, Settings.Platform, function(v) Settings.Platform = v end, SettingsTab)
CreateToggle("FOV-Change Activation", Settings.FovChangeAim, function(v) Settings.FovChangeAim = v end, SettingsTab)
CreateToggle("Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end, SettingsTab)
CreateToggle("Wall Check", Settings.WallCheck, function(v) Settings.WallCheck = v end, SettingsTab)
CreateToggle("Invisible Check", Settings.InvisibleCheck, function(v) Settings.InvisibleCheck = v end, SettingsTab)
CreateToggle("ForceField Check", Settings.ForceFieldCheck, function(v) Settings.ForceFieldCheck = v end, SettingsTab)

-- Custom Tab
CreateToggle("Custom Trigger Box", Settings.CustomBoxEnabled, function(v) Settings.CustomBoxEnabled = v; TriggerBox.Visible = v end, CustomTab)
CreateToggle("Resize Mode", false, function(v) ResizeModeActive = v end, CustomTab)
CreateSelector("Trigger Box Shape", {"Rounded", "Square", "Circle", "Triangle", "Heart"}, Settings.CustomBoxShape, function(v) Settings.CustomBoxShape = v; UpdateBoxShape() end, CustomTab)
CreateButton("Reset Trigger Box", function() TriggerBox.Position = UDim2.new(1, -150, 0.5, 0); Settings.CustomBoxLocked = false; customClickCount = 0; TriggerStroke.Color = Color3.new(1, 1, 1); SaveConfig() end, CustomTab)

-- UI Custom
CreateSlider("Outline Color (Red)", 0, 255, Settings.ThemeR, function(v) Settings.ThemeR = v; UpdateThemeColor() end, UiCustomTab)
CreateSlider("Outline Color (Green)", 0, 255, Settings.ThemeG, function(v) Settings.ThemeG = v; UpdateThemeColor() end, UiCustomTab)
CreateSlider("Outline Color (Blue)", 0, 255, Settings.ThemeB, function(v) Settings.ThemeB = v; UpdateThemeColor() end, UiCustomTab)

CombatTab.Visible = true; UpdateNavStates(CombatTab)

--// ESP LOGIC MODULE
local function CreateEspObjects(player)
    if EspCache[player] then return end
    local objects = {
        Highlight = Instance.new("Highlight"),
        Box = Drawing.new("Square"),
        Skeleton = {},
        HealthBarBG = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Name = Drawing.new("Text")
    }
    objects.Highlight.Enabled = false
    objects.Box.Thickness = 1; objects.Box.Filled = false
    objects.HealthBarBG.Thickness = 1; objects.HealthBarBG.Filled = true; objects.HealthBarBG.Color = Color3.new(0,0,0)
    objects.HealthBar.Thickness = 1; objects.HealthBar.Filled = true; objects.HealthBar.Color = Color3.new(0,1,0)
    objects.Name.Size = 14; objects.Name.Center = true; objects.Name.Outline = true; objects.Name.Font = 2
    for i=1, 6 do objects.Skeleton[i] = Drawing.new("Line"); objects.Skeleton[i].Thickness = 1 end
    EspCache[player] = objects
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        CreateEspObjects(player)
        local data = EspCache[player]
        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local visible = Settings.EspEnabled and char and head and hum and hum.Health > 0
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then visible = false end
        data.Highlight.Enabled = visible and Settings.EspHighlight
        data.Highlight.Parent = visible and char or nil
        data.Highlight.FillColor = Theme.Accent
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if visible and hrp then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local size = (Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.6, 0)).Y)
                local xSize = size / 2
                data.Box.Visible = Settings.EspBox; data.Box.Size = Vector2.new(xSize, size); data.Box.Position = Vector2.new(pos.X - xSize/2, pos.Y - size/2); data.Box.Color = Theme.Accent
                data.HealthBarBG.Visible = Settings.EspHealthBar; data.HealthBarBG.Size = Vector2.new(xSize, 4); data.HealthBarBG.Position = Vector2.new(pos.X - xSize/2, pos.Y - size/2 - 8)
                data.HealthBar.Visible = Settings.EspHealthBar; data.HealthBar.Size = Vector2.new((hum.Health/hum.MaxHealth) * xSize, 4); data.HealthBar.Position = data.HealthBarBG.Position; data.HealthBar.Color = Color3.fromHSV(hum.Health/hum.MaxHealth * 0.3, 1, 1)
                data.Name.Visible = Settings.EspNames; data.Name.Text = player.Name; data.Name.Position = Vector2.new(pos.X, pos.Y - size/2 - 24); data.Name.Color = Color3.new(1,1,1)
            else visible = false end
        else visible = false end
        if not visible then data.Box.Visible = false; data.HealthBar.Visible = false; data.HealthBarBG.Visible = false; data.Name.Visible = false; for _, l in pairs(data.Skeleton) do l.Visible = false end end
    end
end

--// AIM LOGIC
local FovCircle = Drawing.new("Circle"); FovCircle.Thickness = 1.5; FovCircle.Filled = false
local TargetLine = Drawing.new("Line"); TargetLine.Thickness = 2; TargetLine.Transparency = 1

local function IsVisible(part, char)
    if not Settings.WallCheck then return true end
    return #Camera:GetPartsObscuringTarget({part.Position}, {LocalPlayer.Character, char}) == 0
end

local function GetClosestTarget()
    local target = nil; local shortestDist = Settings.FovRadius
    local center = (Settings.Platform == "PC") and UserInputService:GetMouseLocation() or (Camera.ViewportSize / 2)
    local potential = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then table.insert(potential, p.Character) end end
    if Settings.NpcAimbotEnabled then for _, v in pairs(workspace:GetDescendants()) do if v:IsA("Humanoid") and v.Parent and v.Parent ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(v.Parent) then table.insert(potential, v.Parent) end end end
    for _, char in pairs(potential) do
        local part = char:FindFirstChild(Settings.AimPart); local hum = char:FindFirstChildOfClass("Humanoid")
        if part and hum and (not Settings.AliveCheck or hum.Health > 0) then
            local pObj = Players:GetPlayerFromCharacter(char)
            if Settings.TeamCheck and pObj and pObj.Team == LocalPlayer.Team then continue end
            if Settings.InvisibleCheck and char:FindFirstChild("Head") and char.Head.Transparency > 0.5 then continue end
            if Settings.ForceFieldCheck and char:FindFirstChildOfClass("ForceField") then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if dist < shortestDist and IsVisible(part, char) then shortestDist = dist; target = part end
            end
        end
    end
    return target
end

--// WINDOW CONTROLS (Updated for interactable-invisible)
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -30, 0, 5); CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "Ã—"; CloseBtn.TextColor3 = Color3.fromRGB(220, 80, 80); CloseBtn.TextSize = 26

CloseBtn.MouseButton1Click:Connect(function() 
    MainFrame.Visible = false; 
    Shadow.Visible = false; 
    -- Instead of just visible, we ensure it's always ready to be clicked
end)

RestoreBtn.MouseButton1Click:Connect(function() 
    MainFrame.Visible = true; 
    Shadow.Visible = true; 
end)

--// MAIN LOOP
local fpsCounter = 0; local lastFpsTick = tick()
RunService.RenderStepped:Connect(function()
    local center = (Settings.Platform == "PC") and UserInputService:GetMouseLocation() or (Camera.ViewportSize / 2)
    fpsCounter = fpsCounter + 1
    if tick() - lastFpsTick >= 1 then
        local currentPing = 0; pcall(function() currentPing = math.round(LocalPlayer:GetNetworkPing() * 1000) end)
        StatsLabel.Text = "FPS: " .. fpsCounter .. " | Ping: " .. currentPing .. "ms"
        fpsCounter = 0; lastFpsTick = tick()
    end
    
    -- Handle Streamable HUD Visibility (Invisible but Interactable)
    local streamAlpha = Settings.Streamable and 1 or 0
    
    -- Stats Logic
    StatsFrame.Visible = Settings.ShowStats -- Keeps interaction logic tied to toggle
    StatsFrame.BackgroundTransparency = streamAlpha == 1 and 1 or 0
    StatsLabel.TextTransparency = streamAlpha
    StatsStroke.Transparency = streamAlpha

    -- Open Button Logic
    local shouldRestoreBeActive = not MainFrame.Visible
    RestoreBtn.Visible = shouldRestoreBeActive -- Only exists when menu closed
    RestoreBtn.BackgroundTransparency = streamAlpha == 1 and 1 or 0
    RestoreBtn.TextTransparency = streamAlpha
    RestoreStroke.Transparency = streamAlpha

    local currentColor = Theme.Accent
    if Settings.RainbowMode then
        currentColor = Color3.fromHSV((tick() * Settings.RainbowSpeed) % 1, 0.8, 1)
        for _, e in pairs(RainbowElements.Strokes) do e.Color = currentColor end
        for _, e in pairs(RainbowElements.Backgrounds) do e.BackgroundColor3 = currentColor end
        for _, e in pairs(RainbowElements.Texts) do e.TextColor3 = currentColor end
    else
        for _, e in pairs(RainbowElements.Strokes) do if e == StatsStroke then e.Color = statsLocked and Theme.Success or Theme.Accent else e.Color = Theme.Accent end end
        for _, e in pairs(RainbowElements.Backgrounds) do e.BackgroundColor3 = Theme.Accent end
        for _, e in pairs(RainbowElements.Texts) do e.TextColor3 = Theme.Accent end
    end
    
    FovCircle.Color = currentColor; TargetLine.Color = currentColor; FovCircle.Visible = Settings.AimbotEnabled and not Settings.Streamable; FovCircle.Radius = Settings.FovRadius; FovCircle.Position = center

    local isActivated = false
    if Settings.AimbotEnabled then
        if Settings.FovChangeAim then if Camera.FieldOfView < (BaseFOV - 5) then isActivated = true end
        else if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch) then isActivated = true end end
        if Settings.CustomBoxEnabled and CustomBoxActive then isActivated = true end
    end

    local foundTarget = GetClosestTarget()
    if Settings.TracerEnabled and foundTarget then
        local tPos, _ = Camera:WorldToViewportPoint(foundTarget.Position)
        TargetLine.Visible = true; TargetLine.From = center; TargetLine.To = Vector2.new(tPos.X, tPos.Y)
    else TargetLine.Visible = false end

    if isActivated and foundTarget then
        local targetPos = foundTarget.Position
        if foundTarget.Parent.PrimaryPart then targetPos = targetPos + (foundTarget.Parent.PrimaryPart.Velocity * ((Camera.CFrame.Position - targetPos).Magnitude / 100) * Settings.PredictionAmount) end
        local screenPos, _ = Camera:WorldToViewportPoint(foundTarget.Position)
        local power = ((Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude < 20) and Settings.StickyAim or Settings.SnapStrength
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), power)
    end
    
    UpdateESP()
end)
