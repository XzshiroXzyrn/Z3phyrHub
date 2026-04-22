local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- UI Root
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Z3PHYR_HUB_V1"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- State Variables
local EspSettings = { 
    Names = false, Chams = false, Tracers = false, TeamCheck = false,
    EspColor = Color3.fromRGB(170, 0, 255),
    TracerThickness = 1,
    Whitelist = {} 
}
local AimSettings = { 
    Enabled = false, ShowFov = false, FovRadius = 100, Mode = "Center", Hollow = true, 
    TeamCheck = false, WallCheck = false, SnapStrength = 2.5,
    Whitelist = {} 
}
local TracerLines = {}

-- Utility: Visibility Check
local function IsVisible(targetPart)
    local char = LocalPlayer.Character
    if not char or not targetPart then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, ScreenGui, Camera}
    
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    local result = workspace:Raycast(origin, dir, params)
    if not result then return true end
    return result.Instance:IsDescendantOf(targetPart.Parent)
end

-- Utility: Partial Name Match
local function IsWhitelisted(playerName, list)
    local name = playerName:lower()
    for entry, _ in pairs(list) do
        if string.find(name, entry:lower()) then return true end
    end
    return false
end

-- Utility: Cleanup ESP for a player
local function CleanupEsp(p)
    local char = p.Character
    if char then
        local head = char:FindFirstChild("Head")
        if head and head:FindFirstChild("ZTag") then head.ZTag:Destroy() end
        if char:FindFirstChild("ZHighlight") then char.ZHighlight:Destroy() end
    end
    if TracerLines[p.Name] then
        TracerLines[p.Name]:Remove()
        TracerLines[p.Name] = nil
    end
end

-- Utility: Make UI Movable
local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = obj.Position
            input.Changed:Connect(function() 
                if input.UserInputState == Enum.UserInputState.End then dragging = false end 
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Open Button
local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0, 120, 0, 40)
OpenButton.Position = UDim2.new(0, 20, 0.5, -20)
OpenButton.Text = "Z3phyr Hub"
OpenButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
OpenButton.TextColor3 = Color3.new(1, 1, 1)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 14
Instance.new("UICorner", OpenButton)
MakeDraggable(OpenButton)

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 480, 0, 380)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame)

-- Title
local TitleBar = Instance.new("TextLabel", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.Text = "  Z3PHYR HUB  |  by Xzshiro"
TitleBar.TextColor3 = Color3.new(1, 1, 1)
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 18
Instance.new("UICorner", TitleBar)
MakeDraggable(TitleBar)

-- Close Btn
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.Size = UDim2.new(0, 120, 1, -40)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
local sLayout = Instance.new("UIListLayout", Sidebar)
sLayout.Padding = UDim.new(0, 5)
sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

-- Content Area
local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 130, 0, 50)
Content.Size = UDim2.new(1, -140, 1, -60)
Content.BackgroundTransparency = 1

local Pages = { 
    Esp = Instance.new("ScrollingFrame", Content), 
    Aimbot = Instance.new("ScrollingFrame", Content), 
    Info = Instance.new("ScrollingFrame", Content) 
}
for name, page in pairs(Pages) do
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = (name == "Esp")
    page.ScrollBarThickness = 3
    page.CanvasSize = UDim2.new(0, 0, 0, 500) 
    page.BorderSizePixel = 0
end

local function CreateTab(name, order)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Text = name
    btn.LayoutOrder = order
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Pages[name].Visible = true
    end)
end
CreateTab("Esp", 1); CreateTab("Aimbot", 2); CreateTab("Info", 3)

-- Toggle Helper
local function CreateToggle(parent, text, callback, extraRightElement)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, -10, 0, 35)
    holder.BackgroundTransparency = 1

    local btnWidth = extraRightElement and UDim2.new(0.72, 0, 1, 0) or UDim2.new(1, 0, 1, 0)
    local btn = Instance.new("TextButton", holder)
    btn.Size = btnWidth
    btn.Text = text .. " [OFF]"
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    Instance.new("UICorner", btn)
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = text .. (active and " [ON]" or " [OFF]")
        btn.TextColor3 = active and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
        callback(active)
    end)

    if extraRightElement then
        extraRightElement.Parent = holder
        extraRightElement.Size = UDim2.new(0.25, 0, 1, 0)
        extraRightElement.Position = UDim2.new(0.75, 0, 0, 0)
    end
    return btn
end

-- Slider Helper
local function CreateSlider(parent, text, min, max, default, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -10, 0, 45)
    container.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(1, 0, 0, 15)
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local bg = Instance.new("Frame", container)
    bg.Size = UDim2.new(0.7, 0, 0, 6)
    bg.Position = UDim2.new(0, 0, 0, 28)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local box = Instance.new("TextBox", container)
    box.Size = UDim2.new(0.25, 0, 0, 25)
    box.Position = UDim2.new(0.75, 0, 0, 18)
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    box.Text = tostring(default)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    Instance.new("UICorner", box)

    local function update(val)
        local n = tonumber(val) or default
        n = math.clamp(n, min, max)
        local rounded = math.round(n * 10) / 10
        box.Text = tostring(rounded)
        fill.Size = UDim2.new((n-min)/(max-min), 0, 1, 0)
        callback(n)
    end

    box.FocusLost:Connect(function() update(box.Text) end)

    local dragging = false
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            update(min + pos * (max - min))
        end
    end)
end

-- ============ ESP PAGE ============
local EspList = Instance.new("UIListLayout", Pages.Esp); EspList.Padding = UDim.new(0, 8)
Instance.new("UIPadding", Pages.Esp).PaddingTop = UDim.new(0, 5)

CreateToggle(Pages.Esp, "Name", function(v) EspSettings.Names = v end)
CreateToggle(Pages.Esp, "Chams", function(v) EspSettings.Chams = v end)

local ThicknessBox = Instance.new("TextBox")
ThicknessBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
ThicknessBox.Text = tostring(EspSettings.TracerThickness)
ThicknessBox.PlaceholderText = "Size"
ThicknessBox.TextColor3 = Color3.new(1, 1, 1)
ThicknessBox.Font = Enum.Font.Gotham
ThicknessBox.TextSize = 13
Instance.new("UICorner", ThicknessBox)

ThicknessBox.FocusLost:Connect(function()
    local n = tonumber(ThicknessBox.Text) or 1
    n = math.clamp(n, 0.5, 10)
    EspSettings.TracerThickness = n
    ThicknessBox.Text = tostring(n)
end)

CreateToggle(Pages.Esp, "Tracers", function(v) EspSettings.Tracers = v end, ThicknessBox)
CreateToggle(Pages.Esp, "Team Check", function(v) EspSettings.TeamCheck = v end)

-- ============ AIMBOT PAGE ============
local AimList = Instance.new("UIListLayout", Pages.Aimbot); AimList.Padding = UDim.new(0, 8)
Instance.new("UIPadding", Pages.Aimbot).PaddingTop = UDim.new(0, 5)

CreateToggle(Pages.Aimbot, "Turn on Aimbot", function(v) AimSettings.Enabled = v end)
CreateToggle(Pages.Aimbot, "Wall Check", function(v) AimSettings.WallCheck = v end)
CreateToggle(Pages.Aimbot, "Team Check", function(v) AimSettings.TeamCheck = v end)

CreateSlider(Pages.Aimbot, "Aim Snap Strength", 0.1, 5, 2.5, function(v) AimSettings.SnapStrength = v end)
CreateSlider(Pages.Aimbot, "FOV Radius", 20, 500, 100, function(v) AimSettings.FovRadius = v end)

CreateToggle(Pages.Aimbot, "Show Fov", function(v) AimSettings.ShowFov = v end)
CreateToggle(Pages.Aimbot, "Hollow Fov", function(v) AimSettings.Hollow = v end)

local modeBtn = Instance.new("TextButton", Pages.Aimbot)
modeBtn.Size = UDim2.new(1, -10, 0, 35)
modeBtn.Text = "FOV Mode: Center"
modeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
modeBtn.TextColor3 = Color3.new(1,1,1)
modeBtn.Font = Enum.Font.GothamSemibold
modeBtn.TextSize = 13
Instance.new("UICorner", modeBtn)
modeBtn.MouseButton1Click:Connect(function()
    AimSettings.Mode = (AimSettings.Mode == "Center") and "Mouse" or "Center"
    modeBtn.Text = "FOV Mode: " .. AimSettings.Mode
end)

-- ============ INFO PAGE ============
local InfoPadding = Instance.new("UIPadding", Pages.Info)
InfoPadding.PaddingTop = UDim.new(0, 10)
InfoPadding.PaddingLeft = UDim.new(0, 10)

local InfoLayout = Instance.new("UIListLayout", Pages.Info)
InfoLayout.Padding = UDim.new(0, 8)
InfoLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateInfoRow(labelText, valueText, valueColor, order)
    local row = Instance.new("Frame", Pages.Info)
    row.Size = UDim2.new(1, -20, 0, 32)
    row.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", row)
    val.Size = UDim2.new(0.6, -10, 1, 0)
    val.Position = UDim2.new(0.4, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = valueText
    val.TextColor3 = valueColor or Color3.new(1, 1, 1)
    val.Font = Enum.Font.GothamBold
    val.TextSize = 13
    val.TextXAlignment = Enum.TextXAlignment.Left
    return val
end

-- Header
local Header = Instance.new("TextLabel", Pages.Info)
Header.Size = UDim2.new(1, -20, 0, 40)
Header.BackgroundTransparency = 1
Header.Text = "Z3PHYR HUB"
Header.TextColor3 = Color3.fromRGB(170, 0, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 24
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.LayoutOrder = 0

-- Info Rows
CreateInfoRow("Owner:", "Xzshiro", Color3.fromRGB(255, 215, 0), 1)
CreateInfoRow("Version:", "V1.0", Color3.fromRGB(100, 200, 255), 2)
CreateInfoRow("Created:", "4/22/2026", Color3.fromRGB(255, 255, 255), 3)
CreateInfoRow("Last Updated:", "4/22/2026", Color3.fromRGB(255, 255, 255), 4)
local StatusVal = CreateInfoRow("Status:", "● Undetectable", Color3.fromRGB(0, 255, 100), 5)
CreateInfoRow("Discord:", "No discord yet", Color3.fromRGB(180, 180, 180), 6)

-- Description
local DescFrame = Instance.new("Frame", Pages.Info)
DescFrame.Size = UDim2.new(1, -20, 0, 140)
DescFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
DescFrame.BorderSizePixel = 0
DescFrame.LayoutOrder = 7
Instance.new("UICorner", DescFrame).CornerRadius = UDim.new(0, 6)

local DescPad = Instance.new("UIPadding", DescFrame)
DescPad.PaddingTop = UDim.new(0, 8)
DescPad.PaddingLeft = UDim.new(0, 10)
DescPad.PaddingRight = UDim.new(0, 10)

local DescLabel = Instance.new("TextLabel", DescFrame)
DescLabel.Size = UDim2.new(1, 0, 1, 0)
DescLabel.BackgroundTransparency = 1
DescLabel.TextColor3 = Color3.new(1, 1, 1)
DescLabel.Font = Enum.Font.Gotham
DescLabel.TextSize = 12
DescLabel.TextYAlignment = Enum.TextYAlignment.Top
DescLabel.TextXAlignment = Enum.TextXAlignment.Left
DescLabel.TextWrapped = true
DescLabel.RichText = true
DescLabel.Text = [[<b>About:</b>
Z3PHYR HUB is a custom Roblox UI made by <b><font color="rgb(255,215,0)">Xzshiro</font></b>.

<b>Features:</b>
• ESP (Names, Chams, Tracers w/ thickness)
• Aimbot (FOV, Snap, Wall/Team check)
• FOV Mode: Center or Mouse
• Draggable & closable UI

<i>Made for educational use only.</i>]]

-- Blinking Status Animation
task.spawn(function()
    while StatusVal and StatusVal.Parent do
        StatusVal.TextTransparency = 0
        task.wait(0.8)
        if StatusVal and StatusVal.Parent then
            StatusVal.TextTransparency = 0.4
            task.wait(0.8)
        end
    end
end)

-- ============ DRAWING LOGIC ============
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.new(1, 1, 1)
FovCircle.Transparency = 0.8

OpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

Players.PlayerRemoving:Connect(function(p)
    CleanupEsp(p)
end)

RunService.RenderStepped:Connect(function(dt)
    FovCircle.Visible = AimSettings.ShowFov
    FovCircle.Radius = AimSettings.FovRadius
    FovCircle.Filled = not AimSettings.Hollow
    FovCircle.Transparency = AimSettings.Hollow and 1 or 0.3
    FovCircle.Position = (AimSettings.Mode == "Center") 
        and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) 
        or UserInputService:GetMouseLocation()

    local Closest = nil
    local MinDist = math.huge

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local Char = p.Character
            local Head = Char:FindFirstChild("Head")
            local HRP = Char.HumanoidRootPart
            local IsTeammate = (p.Team == LocalPlayer.Team)
            local skipEsp = (EspSettings.TeamCheck and IsTeammate) or IsWhitelisted(p.Name, EspSettings.Whitelist)

            if EspSettings.Names and Head and not skipEsp then
                local tag = Head:FindFirstChild("ZTag")
                if not tag then
                    tag = Instance.new("BillboardGui", Head)
                    tag.Name = "ZTag"; tag.Size = UDim2.new(0, 100, 0, 25); tag.AlwaysOnTop = true
                    local f = Instance.new("Frame", tag)
                    f.Name = "F"; f.Size = UDim2.new(1,0,1,0); f.BackgroundColor3 = Color3.new(0,0,0); f.BackgroundTransparency = 0.5
                    Instance.new("UICorner", f)
                    local l = Instance.new("TextLabel", f)
                    l.Name = "L"; l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1; l.Text = p.Name
                    l.TextColor3 = Color3.new(1,1,1); l.Font = Enum.Font.GothamBold; l.TextSize = 11
                end
            elseif Head and Head:FindFirstChild("ZTag") then
                Head.ZTag:Destroy()
            end

            if EspSettings.Chams and not skipEsp then
                local h = Char:FindFirstChild("ZHighlight")
                if not h then
                    h = Instance.new("Highlight", Char)
                    h.Name = "ZHighlight"
                end
                h.FillColor = EspSettings.EspColor
            elseif Char:FindFirstChild("ZHighlight") then
                Char.ZHighlight:Destroy()
            end

            if EspSettings.Tracers and not skipEsp then
                local pos, onScreen = Camera:WorldToViewportPoint(HRP.Position)
                local line = TracerLines[p.Name]
                if not line then
                    line = Drawing.new("Line")
                    TracerLines[p.Name] = line
                end
                line.Visible = onScreen
                line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                line.To = Vector2.new(pos.X, pos.Y)
                line.Color = EspSettings.EspColor
                line.Thickness = EspSettings.TracerThickness
            elseif TracerLines[p.Name] then
                TracerLines[p.Name].Visible = false
            end

            if AimSettings.Enabled and Head then
                local skipAim = (AimSettings.TeamCheck and IsTeammate) or IsWhitelisted(p.Name, AimSettings.Whitelist)
                if not skipAim then
                    if not AimSettings.WallCheck or IsVisible(Head) then
                        local pos, onScreen = Camera:WorldToViewportPoint(HRP.Position)
                        if onScreen then
                            local dist = (V
