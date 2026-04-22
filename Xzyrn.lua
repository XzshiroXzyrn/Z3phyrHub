local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Prevent double loading
if game:GetService("CoreGui"):FindFirstChild("Z3PHYR_HUB_V1") then
    game:GetService("CoreGui").Z3PHYR_HUB_V1:Destroy()
end

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
local SilentSettings = {
    Enabled = false, ShowFov = false, FovRadius = 100, Mode = "Center", Hollow = true,
    TeamCheck = false,
    Prediction = 0.165, -- default smart prediction strength (0-5 scale from user, scaled internally)
    Whitelist = {}
}
local TracerLines = {}
local LastPositions = {}  -- for smart prediction velocity tracking

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

local function IsWhitelisted(playerName, list)
    local name = playerName:lower()
    for entry, _ in pairs(list) do
        if string.find(name, entry:lower()) then return true end
    end
    return false
end

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
    LastPositions[p.Name] = nil
end

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
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame)

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

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
local sLayout = Instance.new("UIListLayout", Sidebar)
sLayout.Padding = UDim.new(0, 5)
sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 150, 0, 50)
Content.Size = UDim2.new(1, -160, 1, -60)
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
    page.CanvasSize = UDim2.new(0, 0, 0, 1000)
    page.BorderSizePixel = 0
end

local TabButtons = {}
local function CreateTab(name, displayText, order)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Text = displayText
    btn.LayoutOrder = order
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.TextWrapped = true
    Instance.new("UICorner", btn)
    TabButtons[name] = btn
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Pages[name].Visible = true
        for n, b in pairs(TabButtons) do
            b.BackgroundColor3 = (n == name) and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(35, 35, 40)
        end
    end)
end
CreateTab("Esp", "Esp", 1)
CreateTab("Aimbot", "Aimbot and Silent aim", 2)
CreateTab("Info", "Info", 3)
TabButtons.Esp.BackgroundColor3 = Color3.fromRGB(170, 0, 255)

-- Helpers
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

local function CreateModeToggle(parent, labelText, settingsTable)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Text = labelText .. ": Center"
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        settingsTable.Mode = (settingsTable.Mode == "Center") and "Cursor" or "Center"
        btn.Text = labelText .. ": " .. settingsTable.Mode
    end)
end

local function CreateWhitelistUI(parent, listTable, labelText)
    local header = Instance.new("TextLabel", parent)
    header.Size = UDim2.new(1, -10, 0, 20)
    header.BackgroundTransparency = 1
    header.Text = labelText
    header.TextColor3 = Color3.fromRGB(200, 200, 200)
    header.Font = Enum.Font.GothamSemibold
    header.TextSize = 12
    header.TextXAlignment = Enum.TextXAlignment.Left

    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, -10, 0, 30)
    holder.BackgroundTransparency = 1

    local box = Instance.new("TextBox", holder)
    box.Size = UDim2.new(0.65, 0, 1, 0)
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    box.PlaceholderText = "Enter player name..."
    box.Text = ""
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box)

    local addBtn = Instance.new("TextButton", holder)
    addBtn.Size = UDim2.new(0.15, -2, 1, 0)
    addBtn.Position = UDim2.new(0.66, 0, 0, 0)
    addBtn.Text = "Add"
    addBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    addBtn.TextColor3 = Color3.new(1,1,1)
    addBtn.Font = Enum.Font.GothamSemibold
    addBtn.TextSize = 12
    Instance.new("UICorner", addBtn)

    local removeBtn = Instance.new("TextButton", holder)
    removeBtn.Size = UDim2.new(0.18, -2, 1, 0)
    removeBtn.Position = UDim2.new(0.82, 0, 0, 0)
    removeBtn.Text = "Remove"
    removeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    removeBtn.TextColor3 = Color3.new(1,1,1)
    removeBtn.Font = Enum.Font.GothamSemibold
    removeBtn.TextSize = 12
    Instance.new("UICorner", removeBtn)

    local listLabel = Instance.new("TextLabel", parent)
    listLabel.Size = UDim2.new(1, -10, 0, 20)
    listLabel.BackgroundTransparency = 1
    listLabel.Text = "Whitelisted: (none)"
    listLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    listLabel.Font = Enum.Font.Gotham
    listLabel.TextSize = 11
    listLabel.TextXAlignment = Enum.TextXAlignment.Left
    listLabel.TextWrapped = true

    local function refreshList()
        local names = {}
        for k, _ in pairs(listTable) do table.insert(names, k) end
        if #names == 0 then
            listLabel.Text = "Whitelisted: (none)"
        else
            listLabel.Text = "Whitelisted: " .. table.concat(names, ", ")
        end
    end

    addBtn.MouseButton1Click:Connect(function()
        local name = box.Text:gsub("%s", "")
        if name ~= "" then
            listTable[name] = true
            box.Text = ""
            refreshList()
        end
    end)

    removeBtn.MouseButton1Click:Connect(function()
        local name = box.Text:gsub("%s", "")
        if name ~= "" then
            listTable[name] = nil
            box.Text = ""
            refreshList()
        end
    end)
end

local function CreateDivider(parent, labelText)
    local divider = Instance.new("Frame", parent)
    divider.Size = UDim2.new(1, -10, 0, 2)
    divider.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
    divider.BorderSizePixel = 0

    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(170, 0, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
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

-- ============ AIMBOT + SILENT AIM PAGE ============
local AimList = Instance.new("UIListLayout", Pages.Aimbot); AimList.Padding = UDim.new(0, 8)
Instance.new("UIPadding", Pages.Aimbot).PaddingTop = UDim.new(0, 5)

CreateDivider(Pages.Aimbot, "— Aimbot —")
CreateToggle(Pages.Aimbot, "Turn on Aimbot", function(v) AimSettings.Enabled = v end)
CreateToggle(Pages.Aimbot, "Wall Check", function(v) AimSettings.WallCheck = v end)
CreateToggle(Pages.Aimbot, "Team Check", function(v) AimSettings.TeamCheck = v end)
CreateSlider(Pages.Aimbot, "Aim Snap Strength", 0.1, 5, 2.5, function(v) AimSettings.SnapStrength = v end)
CreateSlider(Pages.Aimbot, "FOV Radius (Aimbot)", 20, 500, 100, function(v) AimSettings.FovRadius = v end)
CreateToggle(Pages.Aimbot, "Show Fov", function(v) AimSettings.ShowFov = v end)
CreateToggle(Pages.Aimbot, "Hollow Fov", function(v) AimSettings.Hollow = v end)
CreateModeToggle(Pages.Aimbot, "FOV Mode", AimSettings)
CreateWhitelistUI(Pages.Aimbot, AimSettings.Whitelist, "Aimbot Whitelist:")

CreateDivider(Pages.Aimbot, "— Silent Aim —")

-- Prediction box (right-side element for Silent Aim toggle)
local PredictionBox = Instance.new("TextBox")
PredictionBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
PredictionBox.Text = "1"
PredictionBox.PlaceholderText = "Pred 0-5"
PredictionBox.TextColor3 = Color3.new(1, 1, 1)
PredictionBox.Font = Enum.Font.Gotham
PredictionBox.TextSize = 13
Instance.new("UICorner", PredictionBox)

PredictionBox.FocusLost:Connect(function()
    local n = tonumber(PredictionBox.Text) or 1
    n = math.clamp(n, 0, 5)
    -- Scale 0-5 slider input to actual prediction multiplier (0 to ~0.33s lookahead)
    SilentSettings.Prediction = n * 0.066
    PredictionBox.Text = tostring(n)
end)

CreateToggle(Pages.Aimbot, "Turn on Silent Aim", function(v) SilentSettings.Enabled = v end, PredictionBox)
CreateToggle(Pages.Aimbot, "Team Check (Silent)", function(v) SilentSettings.TeamCheck = v end)
CreateSlider(Pages.Aimbot, "FOV Radius (Silent Aim)", 20, 500, 100, function(v) SilentSettings.FovRadius = v end)
CreateToggle(Pages.Aimbot, "Show Fov (Silent)", function(v) SilentSettings.ShowFov = v end)
CreateToggle(Pages.Aimbot, "Hollow Fov (Silent)", function(v) SilentSettings.Hollow = v end)
CreateModeToggle(Pages.Aimbot, "FOV Mode (Silent)", SilentSettings)
CreateWhitelistUI(Pages.Aimbot, SilentSettings.Whitelist, "Silent Aim Whitelist:")

-- ============ INFO PAGE ============
Instance.new("UIPadding", Pages.Info).PaddingTop = UDim.new(0, 10)
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

local Header = Instance.new("TextLabel", Pages.Info)
Header.Size = UDim2.new(1, -20, 0, 40)
Header.BackgroundTransparency = 1
Header.Text = "Z3PHYR HUB"
Header.TextColor3 = Color3.fromRGB(170, 0, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 24
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.LayoutOrder = 0

CreateInfoRow("Owner:", "Xzshiro", Color3.fromRGB(255, 215, 0), 1)
Cr
