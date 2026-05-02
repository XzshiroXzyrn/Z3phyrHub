-- [[ Z3PHYR V5 - ENHANCED SKELETON & SMART WHITELIST ]] --
-- Owner: Xzsh1r0 | Updated: 4/24/2026 | Executor: Delta

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // SETTINGS
local Z3PHYR_State = {
    Master = false,
    TeamCheck = false,
    DeadCheck = false,
    Tracer = false,
    TracerMode = "Bottom", 
    Skeleton = false,
    Box = false,
    HealthBox = false,
    Names = false, 
    Chams = false,
    WhitelistNames = {},
    -- NEW: Hitbox Settings
    Hitbox = false,
    HitboxSize = 2,
    HitboxMaterial = "Plastic",
    HitboxShape = "Block"
}

local UI_FONT = Enum.Font.Arcade -- Minecraft Font

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Z3PHYR_V5"
ScreenGui.Parent = (gethui and gethui()) or CoreGui
ScreenGui.ResetOnSpawn = false

local function addCorner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
end

-- // MOVEABLE OPEN BUTTON
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 140, 0, 40)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -20)
OpenBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
OpenBtn.Text = "Open Z3PHYR"
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Font = UI_FONT
OpenBtn.TextSize = 14
OpenBtn.Parent = ScreenGui
addCorner(OpenBtn, 10)

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = OpenBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
OpenBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        OpenBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 400)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
addCorner(MainFrame, 12)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 110, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Sidebar.Parent = MainFrame
addCorner(Sidebar, 12)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -120, 1, -10)
Content.Position = UDim2.new(0, 115, 0, 5)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local VisualsPage = Instance.new("ScrollingFrame")
VisualsPage.Size = UDim2.new(1, 0, 1, 0)
VisualsPage.BackgroundTransparency = 1
VisualsPage.ScrollBarThickness = 2
VisualsPage.CanvasSize = UDim2.new(0,0,2.2,0) -- Increased canvas size for new features
VisualsPage.Parent = Content

local InfoPage = Instance.new("Frame")
InfoPage.Size = UDim2.new(1, 0, 1, 0)
InfoPage.BackgroundTransparency = 1
InfoPage.Visible = false
InfoPage.Parent = Content

local UIList = Instance.new("UIListLayout")
UIList.Parent = VisualsPage
UIList.Padding = UDim.new(0, 5)

local MasterBtn = Instance.new("TextButton")
MasterBtn.Size = UDim2.new(0.95, 0, 0, 40)
MasterBtn.Text = "Visuals: Off"
MasterBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
MasterBtn.TextColor3 = Color3.new(1,1,1)
MasterBtn.Font = UI_FONT
MasterBtn.TextSize = 14
MasterBtn.Parent = VisualsPage
addCorner(MasterBtn, 8)

-- // FEATURE LOGIC
local Btns = {}

local function updateButtonVisuals(name)
    local b = Btns[name]
    if not b then return end
    
    if name == "HealthBox" and not Z3PHYR_State.Box then
        b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        b.TextColor3 = Color3.fromRGB(80, 80, 80)
        b.Text = "HealthBox: (Requires Box)"
        return
    end

    if name == "TracerMode" then
        if not Z3PHYR_State.Tracer or not Z3PHYR_State.Master then
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            b.TextColor3 = Color3.fromRGB(80, 80, 80)
            b.Text = "Tracer Mode: (Requires Tracer)"
        else
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            b.TextColor3 = Color3.new(1,1,1)
            b.Text = "Tracer Mode: " .. Z3PHYR_State.TracerMode
        end
        return
    end
    
    if Z3PHYR_State.Master then
        b.BackgroundColor3 = Z3PHYR_State[name] and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(40, 40, 40)
        b.TextColor3 = Color3.new(1,1,1)
    else
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        b.TextColor3 = Color3.fromRGB(130, 130, 130)
    end
    b.Text = name .. (Z3PHYR_State[name] and ": On" or ": Off")
end

local function makeFeature(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95, 0, 0, 30)
    b.Font = UI_FONT
    b.TextSize = 14
    b.Parent = VisualsPage
    addCorner(b, 6)
    Btns[name] = b
    updateButtonVisuals(name)

    b.MouseButton1Click:Connect(function()
        if not Z3PHYR_State.Master then return end
        if name == "TracerMode" then
            if not Z3PHYR_State.Tracer then return end
            if Z3PHYR_State.TracerMode == "Bottom" then Z3PHYR_State.TracerMode = "Middle"
            elseif Z3PHYR_State.TracerMode == "Middle" then Z3PHYR_State.TracerMode = "Top"
            else Z3PHYR_State.TracerMode = "Bottom" end
            updateButtonVisuals("TracerMode")
            return
        end
        if name == "HealthBox" and not Z3PHYR_State.Box then return end
        Z3PHYR_State[name] = not Z3PHYR_State[name]
        if name == "Box" and not Z3PHYR_State.Box then Z3PHYR_State.HealthBox = false end
        updateButtonVisuals(name)
        if name == "Box" then updateButtonVisuals("HealthBox") end
        if name == "Tracer" then updateButtonVisuals("TracerMode") end
    end)
end

local list = {"TeamCheck", "DeadCheck", "Tracer", "TracerMode", "Skeleton", "Box", "HealthBox", "Names", "Chams", "Hitbox"}
for _, v in pairs(list) do makeFeature(v) end

-- // NEW: HITBOX EXPANDER INPUTS
local HitboxTitle = Instance.new("TextLabel")
HitboxTitle.Size = UDim2.new(0.95, 0, 0, 25)
HitboxTitle.Text = "Hitbox Configuration"
HitboxTitle.TextColor3 = Color3.new(1,1,1)
HitboxTitle.BackgroundTransparency = 1
HitboxTitle.Font = UI_FONT
HitboxTitle.TextSize = 14
HitboxTitle.Parent = VisualsPage

local function makeHitboxInput(placeholder, stateKey, isNumeric)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(0.95, 0, 0, 30)
    tb.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tb.PlaceholderText = placeholder
    tb.Text = ""
    tb.Font = UI_FONT
    tb.TextSize = 14
    tb.TextColor3 = Color3.new(1,1,1)
    tb.Parent = VisualsPage
    addCorner(tb, 6)
    
    tb.FocusLost:Connect(function()
        local val = tb.Text
        if isNumeric then
            local n = tonumber(val)
            if n then Z3PHYR_State[stateKey] = math.clamp(n, 0, 150) end
        else
            if val ~= "" then Z3PHYR_State[stateKey] = val end
        end
        tb.Text = ""
        tb.PlaceholderText = placeholder .. ": " .. tostring(Z3PHYR_State[stateKey])
    end)
end

makeHitboxInput("Size (0-150)", "HitboxSize", true)
makeHitboxInput("Material (Plastic, ForceField...)", "HitboxMaterial", false)
makeHitboxInput("Shape (Cube, Sphere, Capsule)", "HitboxShape", false)

-- // WHITELIST SYSTEM
local WLContainer = Instance.new("Frame")
WLContainer.Size = UDim2.new(0.95, 0, 0, 180)
WLContainer.BackgroundTransparency = 1
WLContainer.Parent = VisualsPage

local WLTitle = Instance.new("TextLabel")
WLTitle.Size = UDim2.new(1, 0, 0, 20)
WLTitle.Text = "Whitelist System"
WLTitle.TextColor3 = Color3.new(1,1,1)
WLTitle.BackgroundTransparency = 1
WLTitle.Font = UI_FONT
WLTitle.TextSize = 16
WLTitle.Parent = WLContainer

local WLInput = Instance.new("TextBox")
WLInput.Size = UDim2.new(0.5, -5, 0, 30)
WLInput.Position = UDim2.new(0, 0, 0, 25)
WLInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
WLInput.PlaceholderText = "Username..."
WLInput.Text = ""
WLInput.Font = UI_FONT
WLInput.TextSize = 14
WLInput.TextColor3 = Color3.new(1,1,1)
WLInput.Parent = WLContainer
addCorner(WLInput, 5)

local WLAdd = Instance.new("TextButton")
WLAdd.Size = UDim2.new(0.25, -5, 0, 30)
WLAdd.Position = UDim2.new(0.5, 5, 0, 25)
WLAdd.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
WLAdd.Text = "Add"
WLAdd.Font = UI_FONT
WLAdd.TextSize = 14
WLAdd.TextColor3 = Color3.new(1,1,1)
WLAdd.Parent = WLContainer
addCorner(WLAdd, 5)

local WLRefresh = Instance.new("TextButton")
WLRefresh.Size = UDim2.new(0.25, -5, 0, 30)
WLRefresh.Position = UDim2.new(0.75, 5, 0, 25)
WLRefresh.BackgroundColor3 = Color3.fromRGB(40, 40, 120)
WLRefresh.Text = "Clear"
WLRefresh.Font = UI_FONT
WLRefresh.TextSize = 14
WLRefresh.TextColor3 = Color3.new(1,1,1)
WLRefresh.Parent = WLContainer
addCorner(WLRefresh, 5)

local WLListFrame = Instance.new("ScrollingFrame")
WLListFrame.Size = UDim2.new(1, 0, 0, 90)
WLListFrame.Position = UDim2.new(0, 0, 0, 70)
WLListFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
WLListFrame.BorderSizePixel = 0
WLListFrame.ScrollBarThickness = 2
WLListFrame.Parent = WLContainer
addCorner(WLListFrame, 5)

local function updateWhitelistUI()
    for _, child in pairs(WLListFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    Instance.new("UIListLayout", WLListFrame)
    for i, name in pairs(Z3PHYR_State.WhitelistNames) do
        local Entry = Instance.new("Frame")
        Entry.Size = UDim2.new(0.95, 0, 0, 25)
        Entry.BackgroundTransparency = 1
        Entry.Parent = WLListFrame
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(0.7, 0, 1, 0)
        NameLabel.Text = " " .. name
        NameLabel.TextColor3 = Color3.new(1, 1, 1)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Font = UI_FONT
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = Entry
        local RemoveBtn = Instance.new("TextButton")
        RemoveBtn.Size = UDim2.new(0.25, 0, 0.8, 0)
        RemoveBtn.Position = UDim2.new(0.75, 0, 0.1, 0)
        RemoveBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
        RemoveBtn.Text = "X"
        RemoveBtn.Font = UI_FONT
        RemoveBtn.TextColor3 = Color3.new(1,1,1)
        RemoveBtn.Parent = Entry
        addCorner(RemoveBtn, 4)
        RemoveBtn.MouseButton1Click:Connect(function() table.remove(Z3PHYR_State.WhitelistNames, i) updateWhitelistUI() end)
    end
end

WLAdd.MouseButton1Click:Connect(function()
    local text = WLInput.Text:lower():gsub("%s+", "")
    if text ~= "" then table.insert(Z3PHYR_State.WhitelistNames, text) WLInput.Text = "" updateWhitelistUI() end
end)

WLRefresh.MouseButton1Click:Connect(function() Z3PHYR_State.WhitelistNames = {} updateWhitelistUI() end)

local function isWhitelisted(plr)
    for _, wlName in pairs(Z3PHYR_State.WhitelistNames) do
        if string.find(plr.Name:lower(), wlName) or string.find(plr.DisplayName:lower(), wlName) then return true end
    end
    return false
end

-- // INFO TAB (ENHANCED BACKGROUND)
local infoBg = Instance.new("Frame")
infoBg.Size = UDim2.new(0.95, 0, 0, 150)
infoBg.Position = UDim2.new(0, 0, 0, 10)
infoBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
infoBg.Parent = InfoPage
addCorner(infoBg, 8)

local infoTxt = Instance.new("TextLabel")
infoTxt.Size = UDim2.new(1, -20, 1, -20)
infoTxt.Position = UDim2.new(0, 10, 0, 10)
infoTxt.BackgroundTransparency = 1
infoTxt.TextColor3 = Color3.new(1,1,1)
infoTxt.TextSize = 15
infoTxt.Font = UI_FONT
infoTxt.TextXAlignment = Enum.TextXAlignment.Left
infoTxt.TextYAlignment = Enum.TextYAlignment.Top
infoTxt.Text = "Owner: Xzsh1r0\nVersion: V5 (Enhanced)\nUpdated: 4/24/2026\n\n- Health bar requires Box.\n- Tracer Mode requires Tracer.\n- Whitelist hides ESP targets.\n- Hitbox Expander added."
infoTxt.Parent = infoBg

-- // TABS
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
MasterBtn.MouseButton1Click:Connect(function()
    Z3PHYR_State.Master = not Z3PHYR_State.Master
    MasterBtn.Text = Z3PHYR_State.Master and "Visuals: On" or "Visuals: Off"
    MasterBtn.BackgroundColor3 = Z3PHYR_State.Master and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    for name, _ in pairs(Btns) do updateButtonVisuals(name) end
end)

local vTab = Instance.new("TextButton")
vTab.Size = UDim2.new(0.9, 0, 0, 35)
vTab.Position = UDim2.new(0.05, 0, 0, 10)
vTab.Text = "Visuals"
vTab.Font = UI_FONT
vTab.Parent = Sidebar
addCorner(vTab, 5)

local iTab = Instance.new("TextButton")
iTab.Size = UDim2.new(0.9, 0, 0, 35)
iTab.Position = UDim2.new(0.05, 0, 0, 50)
iTab.Text = "Info"
iTab.Font = UI_FONT
iTab.Parent = Sidebar
addCorner(iTab, 5)

vTab.MouseButton1Click:Connect(function() VisualsPage.Visible = true InfoPage.Visible = false end)
iTab.MouseButton1Click:Connect(function() VisualsPage.Visible = false InfoPage.Visible = true end)

-- // ESP RENDERING
local function createESP(plr)
    local Box = Drawing.new("Square")
    Box.Thickness = 1
    Box.Filled = false
    local Tracer = Drawing.new("Line")
    local HealthOutline = Drawing.new("Line")
    HealthOutline.Thickness = 5
    HealthOutline.Color = Color3.new(0, 0, 0)
    local HealthLine = Drawing.new("Line")
    HealthLine.Thickness = 3
    local NameBg = Drawing.new("Square")
    NameBg.Filled = true
    NameBg.Transparency = 0.5
    NameBg.Color = Color3.new(0, 0, 0)
    local NameText = Drawing.new("Text")
    NameText.Size = 16
    NameText.Center = true
    NameText.Outline = true
    NameText.Font = 2 -- Monospace (Closest to pixel/Minecraft style for Drawing API)
    NameText.Color = Color3.new(1,1,1)

    local SkeletonLines = {}
    for i = 1, 15 do
        local l = Drawing.new("Line")
        l.Color = Color3.new(1, 0, 0)
        l.Thickness = 1
        SkeletonLines[i] = l
    end

    RunService.RenderStepped:Connect(function()
        if Z3PHYR_State.Master and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr ~= LocalPlayer then
            local Char = plr.Character
            local Hum = Char:FindFirstChildOfClass("Humanoid")
            local HRP = Char.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
            
            local Active = OnScreen
            if Z3PHYR_State.TeamCheck and plr.Team == LocalPlayer.Team then Active = false end
            if Z3PHYR_State.DeadCheck and Hum and Hum.Health <= 0 then Active = false end
            if isWhitelisted(plr) then Active = false end

            local SizeY = (Camera:WorldToViewportPoint(HRP.Position + Vector3.new(0, 3.3, 0)).Y - Camera:WorldToViewportPoint(HRP.Position - Vector3.new(0, 4.2, 0)).Y)
            local BoxPos = Vector2.new(Pos.X - (SizeY / 1.5) / 2, Pos.Y - SizeY / 2)

            if Active and Z3PHYR_State.Box then
                Box.Size = Vector2.new(SizeY / 1.5, SizeY)
                Box.Position = BoxPos
                Box.Visible = true
                Box.Color = Color3.new(1,1,1)
            else Box.Visible = false end

            if Active and Z3PHYR_State.Tracer then
                Tracer.Visible = true
                if Z3PHYR_State.TracerMode == "Bottom" then Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                elseif Z3PHYR_State.TracerMode == "Middle" then Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                elseif Z3PHYR_State.TracerMode == "Top" then Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0) end
                Tracer.To = Vector2.new(Pos.X, Pos.Y)
                Tracer.Color = (plr.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Color3.new(1,0,0)
            else Tracer.Visible = false end

            if Active and Z3PHYR_State.HealthBox and Z3PHYR_State.Box and Hum then
                local HealthPct = math.clamp(Hum.Health / Hum.MaxHealth, 0, 1)
                local BarX = BoxPos.X - 6
                HealthOutline.Visible = true
                HealthOutline.From = Vector2.new(BarX, BoxPos.Y + SizeY)
                HealthOutline.To = Vector2.new(BarX, BoxPos.Y)
                HealthLine.Visible = true
                HealthLine.From = Vector2.new(BarX, BoxPos.Y + SizeY)
                HealthLine.To = Vector2.new(BarX, BoxPos.Y + SizeY - (SizeY * HealthPct))
                HealthLine.Color = Color3.new(1, 0, 0):Lerp(Color3.new(0, 1, 0), HealthPct)
            else HealthLine.Visible = false HealthOutline.Visible = false end

            if Active and Z3PHYR_State.Names then
                local HeadPos = Camera:WorldToViewportPoint(Char.Head.Position + Vector3.new(0, 2, 0))
                NameText.Visible = true
                NameText.Position = Vector2.new(HeadPos.X, HeadPos.Y - 20)
                NameText.Text = plr.DisplayName or plr.Name
                NameBg.Visible = true
                NameBg.Size = Vector2.new(NameText.TextBounds.X + 10, NameText.TextBounds.Y + 4)
                NameBg.Position = Vector2.new(NameText.Position.X - NameBg.Size.X / 2, NameText.Position.Y - 2)
            else NameText.Visible = false NameBg.Visible = false end

            if Active and Z3PHYR_State.Skeleton then
                local function SetLine(line, p1Name, p2Name)
                    local p1, p2 = Char:FindFirstChild(p1Name), Char:FindFirstChild(p2Name)
                    if p1 and p2 then
                        local sp1, on1 = Camera:WorldToViewportPoint(p1.Position)
                        local sp2, on2 = Camera:WorldToViewportPoint(p2.Position)
                        if on1 and on2 then
                            line.Visible = true
                            line.From = Vector2.new(sp1.X, sp1.Y)
                            line.To = Vector2.new(sp2.X, sp2.Y)
                            return
                        end
                    end
                    line.Visible = false
                end
                if Hum.RigType == Enum.HumanoidRigType.R15 then
                    SetLine(SkeletonLines[1], "Head", "UpperTorso")
                    SetLine(SkeletonLines[2], "UpperTorso", "LowerTorso")
                    SetLine(SkeletonLines[3], "UpperTorso", "LeftUpperArm")
                    SetLine(SkeletonLines[4], "LeftUpperArm", "LeftLowerArm")
                    SetLine(SkeletonLines[5], "LeftLowerArm", "LeftHand")
                    SetLine(SkeletonLines[6], "UpperTorso", "RightUpperArm")
                    SetLine(SkeletonLines[7], "RightUpperArm", "RightLowerArm")
                    SetLine(SkeletonLines[8], "RightLowerArm", "RightHand")
                    SetLine(SkeletonLines[9], "LowerTorso", "LeftUpperLeg")
                    SetLine(SkeletonLines[10], "LeftUpperLeg", "LeftLowerLeg")
                    SetLine(SkeletonLines[11], "LeftLowerLeg", "LeftFoot")
                    SetLine(SkeletonLines[12], "LowerTorso", "RightUpperLeg")
                    SetLine(SkeletonLines[13], "RightUpperLeg", "RightLowerLeg")
                    SetLine(SkeletonLines[14], "RightLowerLeg", "RightFoot")
                else
                    SetLine(SkeletonLines[1], "Head", "Torso")
                    SetLine(SkeletonLines[2], "Torso", "Left Arm")
                    SetLine(SkeletonLines[3], "Torso", "Right Arm")
                    SetLine(SkeletonLines[4], "Torso", "Left Leg")
                    SetLine(SkeletonLines[5], "Torso", "Right Le
