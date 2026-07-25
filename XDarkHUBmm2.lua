-- ═══════════════════════════════════════════════════════════
--  XDarkHUB v7.0 · MM2 Autofarm
-- ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local character = player.Character
local rootPart = character and character:FindFirstChild("HumanoidRootPart")

local visitedPositions = {}
local isActive = false
local flySpeed = 15
local collected = 0
local startTime = 0
local antiAFK = false
local isMurderer = false
local isSheriff = false
local bagFull = false
local farmStopped = false
local espEnabled = false
local espHighlights = {}
local MAX_BAG = 40

local collectSound = Instance.new("Sound")
collectSound.SoundId = "rbxassetid://12221967"
collectSound.Volume = 1

local killSound = Instance.new("Sound")
killSound.SoundId = "rbxassetid://9120392731"
killSound.Volume = 0.8

local deathSound = Instance.new("Sound")
deathSound.SoundId = "rbxassetid://9120392731"
deathSound.Volume = 0.6

local function notify(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = duration or 3
        })
    end)
end

local function getPlayerRole(p)
    if p.Character then
        if p.Character:FindFirstChild("Knife") or p.Character:FindFirstChild("MurdererSword") then return "Murderer" end
        if p.Character:FindFirstChild("Gun") or p.Character:FindFirstChild("SheriffGun") then return "Sheriff" end
    end
    if p:FindFirstChild("Backpack") then
        local bp = p.Backpack
        if bp:FindFirstChild("Knife") or bp:FindFirstChild("MurdererSword") then return "Murderer" end
        if bp:FindFirstChild("Gun") or bp:FindFirstChild("SheriffGun") then return "Sheriff" end
    end
    local ls = p:FindFirstChild("leaderstats")
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            if v.Name == "Role" and v.Value then return v.Value end
            if v.Value == "Murderer" or v.Value == "murderer" then return "Murderer" end
            if v.Value == "Sheriff" or v.Value == "sheriff" then return "Sheriff" end
        end
    end
    return "Innocent"
end

local function getPlayerCoins(p)
    local ls = p:FindFirstChild("leaderstats")
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            if (v:IsA("IntValue") or v:IsA("NumberValue")) then
                if v.Name:lower():find("coin") or v.Name:lower():find("money") or v.Name:lower():find("cash") then
                    return v.Value
                end
            end
        end
        for _, v in ipairs(ls:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                return v.Value
            end
        end
    end
    return 0
end

local function checkRole()
    local role = getPlayerRole(player)
    isMurderer = (role == "Murderer")
    isSheriff = (role == "Sheriff")
end

-- ═══════════════════════════════════════════════════════════
--  ЦВЕТА
-- ═══════════════════════════════════════════════════════════

local COL = {
    bg = Color3.fromRGB(2, 2, 5),
    panel = Color3.fromRGB(8, 8, 12),
    card = Color3.fromRGB(14, 14, 20),
    cardHov = Color3.fromRGB(22, 22, 30),
    border = Color3.fromRGB(35, 35, 45),
    text = Color3.fromRGB(250, 248, 255),
    muted = Color3.fromRGB(100, 100, 115),
    white = Color3.fromRGB(255, 255, 255),
}

local ACCENT = {
    base = Color3.fromRGB(230, 25, 55),
    dim = Color3.fromRGB(70, 10, 20),
    light = Color3.fromRGB(255, 85, 105),
    glow = Color3.fromRGB(255, 45, 65),
    dark = Color3.fromRGB(45, 6, 15),
    neon = Color3.fromRGB(255, 30, 60),
}

local function corner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r)
    return c
end

local function stroke(obj, color, th, trans)
    local s = Instance.new("UIStroke", obj)
    s.Color = color
    s.Thickness = th or 1
    s.Transparency = trans or 0
    return s
end

local function tw(obj, props, t, style)
    local info = TweenInfo.new(t or 0.3, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    return TweenService:Create(obj, info, props)
end

local function animate(obj, props, t, style)
    tw(obj, props, t, style):Play()
end

-- Очистка
do
    local old = player:WaitForChild("PlayerGui"):FindFirstChild("AutoFarmGui")
    if old then old:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

collectSound.Parent = gui
killSound.Parent = gui
deathSound.Parent = gui

-- ═══════════════════════════════════════════════════════════
--  УЛУЧШЕННЫЕ ЧАСТИЦЫ (с анимацией свечения)
-- ═══════════════════════════════════════════════════════════

local bgFrame = Instance.new("Frame")
bgFrame.Size = UDim2.new(1, 0, 1, 0)
bgFrame.BackgroundColor3 = COL.bg
bgFrame.BackgroundTransparency = 0.15
bgFrame.BorderSizePixel = 0
bgFrame.ZIndex = 0
bgFrame.Parent = gui

local bgGrad = Instance.new("UIGradient", bgFrame)
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 2, 8)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(2, 2, 5)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 2, 5)),
})
bgGrad.Rotation = 45

local particleColors = {
    ACCENT.base, ACCENT.neon, ACCENT.glow, ACCENT.light,
    Color3.fromRGB(255, 20, 40), Color3.fromRGB(255, 100, 120)
}

for i = 1, 35 do
    local particle = Instance.new("Frame")
    local size = math.random(3, 14)
    particle.Size = UDim2.new(0, size, 0, size)
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    particle.BackgroundColor3 = particleColors[math.random(1, #particleColors)]
    particle.BackgroundTransparency = math.random(40, 80) / 100
    particle.BorderSizePixel = 0
    particle.ZIndex = 0
    particle.Parent = bgFrame
    corner(particle, math.random(2, 7))
    
    task.spawn(function()
        while particle.Parent do
            local targetPos = UDim2.new(math.random(), 0, math.random(), 0)
            local duration = math.random(12, 28)
            animate(particle, {
                Position = targetPos,
                BackgroundTransparency = math.random(30, 85) / 100
            }, duration, Enum.EasingStyle.Sine)
            task.wait(duration)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  ГЛАВНЫЙ ФРЕЙМ
-- ═══════════════════════════════════════════════════════════

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 700, 0, 600)
frame.Position = UDim2.new(0.5, -350, 0.5, -300)
frame.BackgroundColor3 = COL.bg
frame.BackgroundTransparency = 0.03
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.ZIndex = 1
frame.Parent = gui
corner(frame, 20)

local outerGlow = stroke(frame, ACCENT.neon, 2, 0.5)
local innerBorder = stroke(frame, ACCENT.base, 1, 0.2)

task.spawn(function()
    while frame.Parent do
        animate(outerGlow, {Transparency = 0.3, Thickness = 3}, 2.5, Enum.EasingStyle.Sine)
        task.wait(2.5)
        animate(outerGlow, {Transparency = 0.7, Thickness = 2}, 2.5, Enum.EasingStyle.Sine)
        task.wait(2.5)
    end
end)

-- ═══════════════════════════════════════════════════════════
--  ЗАГОЛОВОК
-- ═══════════════════════════════════════════════════════════

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 70)
titleBar.BackgroundColor3 = COL.panel
titleBar.BackgroundTransparency = 0.05
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.ZIndex = 2
titleBar.Parent = frame
corner(titleBar, 20)

local titleGrad = Instance.new("UIGradient", titleBar)
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 12, 25)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 6, 12)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 12, 25)),
})

task.spawn(function()
    local rotation = 0
    while frame.Parent do
        rotation = rotation + 0.4
        titleGrad.Rotation = rotation
        task.wait(0.05)
    end
end)

local logo = Instance.new("Frame")
logo.Size = UDim2.new(0, 50, 0, 50)
logo.Position = UDim2.new(0, 20, 0.5, -25)
logo.BackgroundColor3 = ACCENT.base
logo.BorderSizePixel = 0
logo.ZIndex = 3
logo.Parent = titleBar
corner(logo, 15)

local logoStroke = stroke(logo, ACCENT.neon, 2, 0.3)

task.spawn(function()
    while frame.Parent do
        animate(logo, {Size = UDim2.new(0, 54, 0, 54)}, 1.5, Enum.EasingStyle.Sine)
        animate(logoStroke, {Transparency = 0.1}, 1.5, Enum.EasingStyle.Sine)
        task.wait(1.5)
        animate(logo, {Size = UDim2.new(0, 50, 0, 50)}, 1.5, Enum.EasingStyle.Sine)
        animate(logoStroke, {Transparency = 0.5}, 1.5, Enum.EasingStyle.Sine)
        task.wait(1.5)
    end
end)

local logoX = Instance.new("TextLabel")
logoX.Size = UDim2.new(1, 0, 1, 0)
logoX.BackgroundTransparency = 1
logoX.Text = "X"
logoX.Font = Enum.Font.GothamBlack
logoX.TextSize = 32
logoX.TextColor3 = COL.white
logoX.ZIndex = 4
logoX.Parent = logo

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -90, 1, 0)
titleLbl.Position = UDim2.new(0, 85, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "XDarkHUB"
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 32
titleLbl.TextColor3 = ACCENT.light
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 3
titleLbl.Parent = titleBar

local textGrad = Instance.new("UIGradient", titleLbl)
textGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ACCENT.neon),
    ColorSequenceKeypoint.new(0.5, COL.white),
    ColorSequenceKeypoint.new(1, ACCENT.neon),
})

task.spawn(function()
    local offset = 0
    while frame.Parent do
        offset = offset + 0.01
        if offset > 1 then offset = 0 end
        textGrad.Offset = Vector2.new(offset, 0)
        task.wait(0.05)
    end
end)

local versionLbl = Instance.new("TextLabel")
versionLbl.Size = UDim2.new(0, 140, 1, 0)
versionLbl.Position = UDim2.new(1, -150, 0, 0)
versionLbl.BackgroundTransparency = 1
versionLbl.Text = "v7.0 · PREMIUM"
versionLbl.Font = Enum.Font.GothamBold
versionLbl.TextSize = 12
versionLbl.TextColor3 = ACCENT.light
versionLbl.TextXAlignment = Enum.TextXAlignment.Right
versionLbl.TextTransparency = 0.3
versionLbl.ZIndex = 3
versionLbl.Parent = titleBar

local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -50, 0, 2)
sep.Position = UDim2.new(0, 25, 0, 70)
sep.BorderSizePixel = 0
sep.ZIndex = 2
sep.Parent = frame
corner(sep, 1)

local sepGrad = Instance.new("UIGradient", sep)
sepGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(2, 2, 5)),
    ColorSequenceKeypoint.new(0.5, ACCENT.neon),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 2, 5)),
})

-- Перетаскивание
do
    local dragging, dragStart, startPos = false, nil, nil
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local delta = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  КОНТЕЙНЕР
-- ═══════════════════════════════════════════════════════════

local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 1, -75)
container.Position = UDim2.new(0, 0, 0, 75)
container.BackgroundTransparency = 1
container.Parent = frame

frame.Size = UDim2.new(0, 0, 0, 0)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
animate(frame, {
    Size = UDim2.new(0, 700, 0, 600),
    Position = UDim2.new(0.5, -350, 0.5, -300)
}, 0.7, Enum.EasingStyle.Back)

-- ═══════════════════════════════════════════════════════════
--  ПАНЕЛИ
-- ═══════════════════════════════════════════════════════════

local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 190, 1, 0)
leftPanel.BackgroundColor3 = COL.panel
leftPanel.BackgroundTransparency = 0.05
leftPanel.BorderSizePixel = 0
leftPanel.ZIndex = 2
leftPanel.Parent = container

local leftGrad = Instance.new("UIGradient", leftPanel)
leftGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 10, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 5, 8)),
})

local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(1, -190, 1, 0)
rightPanel.Position = UDim2.new(0, 190, 0, 0)
rightPanel.BackgroundTransparency = 1
rightPanel.ZIndex = 2
rightPanel.Parent = container

-- ═══════════════════════════════════════════════════════════
--  ВКЛАДКИ
-- ═══════════════════════════════════════════════════════════

local tabs = {}
local tabContents = {}
local currentTab = nil

local function createTab(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -28, 0, 56)
    btn.Position = UDim2.new(0, 14, 0, 20 + (order - 1) * 62)
    btn.BackgroundColor3 = COL.card
    btn.BackgroundTransparency = 0.05
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.ZIndex = 3
    btn.Parent = leftPanel
    corner(btn, 15)
    local btnStroke = stroke(btn, COL.border, 1)

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 50, 1, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextSize = 26
    iconLbl.TextColor3 = ACCENT.light
    iconLbl.ZIndex = 3
    iconLbl.Parent = btn

    local textLbl = Instance.new("TextLabel")
    textLbl.Size = UDim2.new(1, -54, 1, 0)
    textLbl.Position = UDim2.new(0, 54, 0, 0)
    textLbl.BackgroundTransparency = 1
    textLbl.Text = name
    textLbl.Font = Enum.Font.GothamBold
    textLbl.TextSize = 15
    textLbl.TextColor3 = COL.text
    textLbl.TextXAlignment = Enum.TextXAlignment.Left
    textLbl.ZIndex = 3
    textLbl.Parent = btn

    tabs[name] = {button = btn, icon = iconLbl, text = textLbl, stroke = btnStroke}
    return btn
end

local function createTabContent(name)
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = ACCENT.base
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ScrollingEnabled = true
    content.Visible = false
    content.ZIndex = 2
    content.Parent = rightPanel

    local p = Instance.new("UIPadding", content)
    p.PaddingLeft = UDim.new(0, 22)
    p.PaddingRight = UDim.new(0, 22)
    p.PaddingTop = UDim.new(0, 22)
    p.PaddingBottom = UDim.new(0, 22)

    local l = Instance.new("UIListLayout", content)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 14)

    tabContents[name] = content
    return content
end

local function switchTab(name)
    for n, tab in pairs(tabs) do
        animate(tab.button, {BackgroundColor3 = COL.card, BackgroundTransparency = 0.05}, 0.3)
        animate(tab.stroke, {Color = COL.border}, 0.3)
        tab.icon.TextColor3 = ACCENT.light
        tab.text.TextColor3 = COL.text
    end
    
    if tabs[name] then
        animate(tabs[name].button, {BackgroundColor3 = ACCENT.dark, BackgroundTransparency = 0}, 0.3)
        animate(tabs[name].stroke, {Color = ACCENT.neon}, 0.3)
        tabs[name].icon.TextColor3 = ACCENT.neon
        tabs[name].text.TextColor3 = COL.white
    end
    
    for n, content in pairs(tabContents) do
        if n == name then
            content.Visible = true
            content.Position = UDim2.new(0, 70, 0, 0)
            animate(content, {Position = UDim2.new(0, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back)
        else
            content.Visible = false
        end
    end
    
    currentTab = name
end

createTab("Sheriff", "⭐", 1)
createTab("Murderer", "🔪", 2)
createTab("ESP", "👁️", 3)
createTab("Player", "🎯", 4)
createTab("Auto Farm", "⚙️", 5)

for name in pairs(tabs) do
    createTabContent(name)
end

for name, tab in pairs(tabs) do
    tab.button.MouseButton1Click:Connect(function() switchTab(name) end)
    tab.button.MouseEnter:Connect(function()
        if not (currentTab == name) then
            animate(tab.button, {BackgroundColor3 = COL.cardHov}, 0.2)
            animate(tab.stroke, {Color = ACCENT.light}, 0.2)
        end
    end)
    tab.button.MouseLeave:Connect(function()
        if not (currentTab == name) then
            animate(tab.button, {BackgroundColor3 = COL.card, BackgroundTransparency = 0.05}, 0.2)
            animate(tab.stroke, {Color = COL.border}, 0.2)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  UI КОМПОНЕНТЫ
-- ═══════════════════════════════════════════════════════════

local function sectionTitle(parent, order, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 28)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = ACCENT.light
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = order
    l.ZIndex = 2
    l.Parent = parent
end

local function statRow(parent, order, name)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = COL.card
    row.BackgroundTransparency = 0.02
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.ZIndex = 2
    row.Parent = parent
    corner(row, 13)
    stroke(row, COL.border, 1)

    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0.6, 0, 1, 0)
    n.Position = UDim2.new(0, 18, 0, 0)
    n.BackgroundTransparency = 1
    n.Text = name
    n.TextColor3 = COL.muted
    n.Font = Enum.Font.Gotham
    n.TextSize = 13
    n.TextXAlignment = Enum.TextXAlignment.Left
    n.ZIndex = 2
    n.Parent = row

    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(0.4, -18, 1, 0)
    v.Position = UDim2.new(0.6, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text = "0"
    v.TextColor3 = ACCENT.light
    v.Font = Enum.Font.GothamBold
    v.TextSize = 14
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.ZIndex = 2
    v.Parent = row
    return v
end

local function toggleCard(parent, order, label, onToggle)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 54)
    card.BackgroundColor3 = COL.card
    card.BackgroundTransparency = 0.02
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.ZIndex = 2
    card.Parent = parent
    corner(card, 15)
    local cs = stroke(card, COL.border, 1)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -120, 1, 0)
    t.Position = UDim2.new(0, 22, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = label
    t.TextColor3 = COL.text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 15
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 2
    t.Parent = card

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 64, 0, 30)
    pill.Position = UDim2.new(1, -74, 0.5, -15)
    pill.BackgroundColor3 = COL.border
    pill.BorderSizePixel = 0
    pill.ZIndex = 2
    pill.Parent = card
    corner(pill, 15)
    local ps = stroke(pill, COL.border, 1)

    local pl = Instance.new("TextLabel")
    pl.Size = UDim2.new(1, 0, 1, 0)
    pl.BackgroundTransparency = 1
    pl.Text = "OFF"
    pl.TextColor3 = COL.muted
    pl.Font = Enum.Font.GothamBold
    pl.TextSize = 11
    pl.ZIndex = 2
    pl.Parent = pill

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 3
    btn.Parent = card

    local state = false

    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            animate(card, {BackgroundColor3 = ACCENT.dim}, 0.3)
            animate(cs, {Color = ACCENT.base}, 0.3)
            animate(pill, {BackgroundColor3 = ACCENT.base}, 0.3)
            animate(ps, {Color = ACCENT.neon}, 0.3)
            pl.Text = "ON"
            animate(pl, {TextColor3 = COL.white}, 0.3)
        else
            animate(card, {BackgroundColor3 = COL.card}, 0.3)
            animate(cs, {Color = COL.border}, 0.3)
            animate(pill, {BackgroundColor3 = COL.border}, 0.3)
            animate(ps, {Color = COL.border}, 0.3)
            pl.Text = "OFF"
            animate(pl, {TextColor3 = COL.muted}, 0.3)
        end
        if onToggle then onToggle(state) end
    end)

    btn.MouseEnter:Connect(function() if not state then animate(card, {BackgroundColor3 = COL.cardHov}, 0.2) end end)
    btn.MouseLeave:Connect(function() if not state then animate(card, {BackgroundColor3 = COL.card}, 0.2) end end)
end

-- ═══════════════════════════════════════════════════════════
--  КОНТЕНТ ВКЛАДОК
-- ═══════════════════════════════════════════════════════════

local espContent = tabContents["ESP"]
sectionTitle(espContent, 1, "👁️ VISUAL ESP")
toggleCard(espContent, 2, "ESP Roles", function(state)
    espEnabled = state
    updateESP()
    notify("XDarkHUB", "ESP: " .. (state and "ON" or "OFF"), 2)
end)

local farmContent = tabContents["Auto Farm"]
sectionTitle(farmContent, 1, "📊 STATISTICS")
local counterVal = statRow(farmContent, 2, "Coins Collected")
local timerVal = statRow(farmContent, 3, "Time Active")
local rateVal = statRow(farmContent, 4, "Coins / Hour")
local playerCoinsVal = statRow(farmContent, 5, "Your Total Coins")

sectionTitle(farmContent, 6, "🎭 ROLE INFO")
local roleVal = statRow(farmContent, 7, "Your Role")

sectionTitle(farmContent, 8, "🎒 BAG STATUS")
local bagVal = statRow(farmContent, 9, "Bag Full")

-- Лимит
do
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 54)
    card.BackgroundColor3 = COL.card
    card.BackgroundTransparency = 0.02
    card.BorderSizePixel = 0
    card.LayoutOrder = 10
    card.ZIndex = 2
    card.Parent = farmContent
    corner(card, 15)
    stroke(card, COL.border, 1)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -130, 1, 0)
    t.Position = UDim2.new(0, 22, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = "🎯 Bag Limit:"
    t.TextColor3 = COL.text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 15
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 2
    t.Parent = card

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 85, 0, 34)
    pill.Position = UDim2.new(1, -95, 0.5, -17)
    pill.BackgroundColor3 = ACCENT.base
    pill.BorderSizePixel = 0
    pill.ZIndex = 2
    pill.Parent = card
    corner(pill, 13)
    stroke(pill, ACCENT.neon, 1)

    local pillLabel = Instance.new("TextLabel")
    pillLabel.Size = UDim2.new(1, 0, 1, 0)
    pillLabel.BackgroundTransparency = 1
    pillLabel.Text = tostring(MAX_BAG) .. " 🪙"
    pillLabel.TextColor3 = COL.white
    pillLabel.Font = Enum.Font.GothamBold
    pillLabel.TextSize = 15
    pillLabel.ZIndex = 2
    pillLabel.Parent = pill

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 3
    btn.Parent = card
    btn.MouseButton1Click:Connect(function()
        if MAX_BAG == 40 then MAX_BAG = 50 else MAX_BAG = 40 end
        pillLabel.Text = tostring(MAX_BAG) .. " 🪙"
        animate(pill, {Size = UDim2.new(0, 95, 0, 38)}, 0.15)
        task.wait(0.15)
        animate(pill, {Size = UDim2.new(0, 85, 0, 34)}, 0.15)
        notify("XDarkHUB", "🎯 Лимит: " .. MAX_BAG, 2)
    end)
end

-- Скорость
do
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 54)
    card.BackgroundColor3 = COL.card
    card.BackgroundTransparency = 0.02
    card.BorderSizePixel = 0
    card.LayoutOrder = 11
    card.ZIndex = 2
    card.Parent = farmContent
    corner(card, 15)
    stroke(card, COL.border, 1)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -130, 1, 0)
    t.Position = UDim2.new(0, 22, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = "⚡ Farm Speed"
    t.TextColor3 = COL.text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 15
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 2
    t.Parent = card

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 64, 0, 30)
    pill.Position = UDim2.new(1, -74, 0.5, -15)
    pill.BackgroundColor3 = ACCENT.dim
    pill.BorderSizePixel = 0
    pill.ZIndex = 2
    pill.Parent = card
    corner(pill, 15)
    stroke(pill, ACCENT.base, 1)

    local speedPillLbl = Instance.new("TextLabel")
    speedPillLbl.Size = UDim2.new(1, 0, 1, 0)
    speedPillLbl.BackgroundTransparency = 1
    speedPillLbl.Text = tostring(flySpeed)
    speedPillLbl.TextColor3 = ACCENT.light
    speedPillLbl.Font = Enum.Font.GothamBold
    speedPillLbl.TextSize = 13
    speedPillLbl.ZIndex = 2
    speedPillLbl.Parent = pill

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 3
    btn.Parent = card
    btn.MouseButton1Click:Connect(function()
        flySpeed = flySpeed + 5
        if flySpeed > 50 then flySpeed = 10 end
        speedPillLbl.Text = tostring(flySpeed)
        notify("XDarkHUB", "⚡ Скорость: " .. flySpeed, 1)
    end)
end

toggleCard(farmContent, 12, "⚙️ Auto Farm", function(state)
    isActive = state
    if state then 
        startFarming()
        notify("XDarkHUB", "✅ Auto Farm ВКЛЮЧЕН!", 2)
    else
        notify("XDarkHUB", "❌ Auto Farm ВЫКЛЮЧЕН!", 2)
    end
end)

toggleCard(farmContent, 13, "🛡️ Anti-AFK", function(state)
    antiAFK = state
    notify("XDarkHUB", "Anti-AFK: " .. (state and "ON" or "OFF"), 2)
end)

-- Test Fling
do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 56)
    btn.BackgroundColor3 = ACCENT.base
    btn.Text = "🚀 TEST FLING"
    btn.TextColor3 = COL.white
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 16
    btn.AutoButtonColor = false
    btn.LayoutOrder = 14
    btn.ZIndex = 2
    btn.Parent = farmContent
    corner(btn, 15)
    stroke(btn, ACCENT.neon, 2)
    
    local btnGrad = Instance.new("UIGradient", btn)
    btnGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, ACCENT.neon),
        ColorSequenceKeypoint.new(1, ACCENT.dark),
    })
    btnGrad.Rotation = 90
    
    btn.MouseEnter:Connect(function() animate(btn, {BackgroundColor3 = ACCENT.neon}, 0.2) end)
    btn.MouseLeave:Connect(function() animate(btn, {BackgroundColor3 = ACCENT.base}, 0.2) end)
    btn.MouseButton1Click:Connect(function()
        notify("XDarkHUB", "🔍 Запускаю тест флинга...", 2)
        throwMurdererToSpace()
    end)
end

-- Reset
do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 48)
    btn.BackgroundColor3 = COL.card
    btn.BackgroundTransparency = 0.02
    btn.Text = "🔄 Reset & Resume"
    btn.TextColor3 = ACCENT.light
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.AutoButtonColor = false
    btn.LayoutOrder = 15
    btn.ZIndex = 2
    btn.Parent = farmContent
    corner(btn, 15)
    stroke(btn, ACCENT.base, 1)
    btn.MouseEnter:Connect(function() animate(btn, {BackgroundColor3 = COL.cardHov}, 0.2) end)
    btn.MouseLeave:Connect(function() animate(btn, {BackgroundColor3 = COL.card}, 0.2) end)
    btn.MouseButton1Click:Connect(function()
        collected = 0
        startTime = tick()
        counterVal.Text = "0"
        timerVal.Text = "0s"
        rateVal.Text = "0"
        bagFull = false
        farmStopped = false
        visitedPositions = {}
        updateBagUI()
        notify("XDarkHUB", "🔄 Сброшено!", 2)
    end)
end

-- Заглушки
for _, name in ipairs({"Sheriff", "Murderer", "Player"}) do
    local content = tabContents[name]
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.BackgroundTransparency = 1
    title.Text = name == "Sheriff" and "⭐ SHERIFF" or name == "Murderer" and "🔪 MURDERER" or "🎯 PLAYER"
    title.TextColor3 = ACCENT.light
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 1
    title.ZIndex = 2
    title.Parent = content
    
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 160)
    card.BackgroundColor3 = COL.card
    card.BackgroundTransparency = 0.02
    card.BorderSizePixel = 0
    card.LayoutOrder = 2
    card.ZIndex = 2
    card.Parent = content
    corner(card, 18)
    stroke(card, COL.border, 1)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -30, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "🚧 Coming Soon...\n\nЭта функция будет добавлена в следующей версии."
    lbl.TextColor3 = COL.muted
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 15
    lbl.TextWrapped = true
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.ZIndex = 2
    lbl.Parent = card
end

-- ═══════════════════════════════════════════════════════════
--  ФУНКЦИИ
-- ═══════════════════════════════════════════════════════════

function updateRoleUI()
    checkRole()
    if isMurderer then
        roleVal.Text = "🔪 Murderer"
        roleVal.TextColor3 = Color3.fromRGB(255, 50, 50)
    elseif isSheriff then
        roleVal.Text = "⭐ Sheriff"
        roleVal.TextColor3 = Color3.fromRGB(50, 150, 255)
    else
        roleVal.Text = "👤 Innocent"
        roleVal.TextColor3 = Color3.fromRGB(50, 255, 50)
    end
end

function updateBagUI()
    if farmStopped then
        bagVal.Text = "🛑 STOPPED"
        bagVal.TextColor3 = Color3.fromRGB(255, 80, 80)
    elseif bagFull then
        bagVal.Text = "✅ FULL"
        bagVal.TextColor3 = Color3.fromRGB(255, 200, 0)
    else
        bagVal.Text = collected .. "/" .. MAX_BAG
        bagVal.TextColor3 = ACCENT.light
    end
end

function stopFarming()
    farmStopped = true
    updateBagUI()
    notify("XDarkHUB", "🛑 Фарм остановлен", 2)
end

function cinematicMurdererKill()
    notify("XDarkHUB", "🔪 Убийца убивает всех!", 3)
    killSound:Play()
    
    character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    local myKnife = character:FindFirstChild("Knife") or character:FindFirstChild("MurdererSword")
    if not myKnife then
        myKnife = player:FindFirstChild("Backpack") and (player.Backpack:FindFirstChild("Knife") or player.Backpack:FindFirstChild("MurdererSword"))
    end
    if not myKnife then
        myKnife = Instance.new("Tool")
        myKnife.Name = "Knife"
        myKnife.RequiresHandle = false
        myKnife.Parent = player:FindFirstChild("Backpack") or player
    end
    
    hum:EquipTool(myKnife)
    task.wait(0.3)
    
    local targets = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            table.insert(targets, p)
        end
    end
    
    for _, p in ipairs(targets) do
        local targetHum = p.Character:FindFirstChild("Humanoid")
        if targetHum then
            targetHum.PlatformStand = true
            targetHum.WalkSpeed = 0
            targetHum.JumpPower = 0
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
    
    task.wait(0.5)
    
    for i, p in ipairs(targets) do
        if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, -1.5)
                task.wait(0.15)
                if myKnife and myKnife.Parent == character then myKnife:Activate() end
                task.wait(0.05)
                if p.Character and p.Character:FindFirstChild("Humanoid") then
                    p.Character.Humanoid:TakeDamage(100)
                end
                notify("XDarkHUB", "💀 " .. i .. "/" .. #targets, 1)
            end
        end
    end
    
    task.wait(0.3)
    bagFull = false
    collected = 0
    counterVal.Text = "0"
    notify("XDarkHUB", "🔪 Все убиты!", 3)
end

function throwMurdererToSpace()
    notify("XDarkHUB", "🚀 НАЧИНАЮ ФЛИНГ!", 4)
    deathSound:Play()
    
    local murdererPlayer = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local role = getPlayerRole(p)
            if role == "Murderer" then
                murdererPlayer = p
                break
            end
        end
    end
    
    if not murdererPlayer or not murdererPlayer.Character then
        notify("XDarkHUB", "❌ Мардер не найден!", 3)
        return
    end
    
    local murdererHrp = murdererPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not murdererHrp then
        notify("XDarkHUB", "❌ Нет HRP!", 3)
        return
    end
    
    notify("XDarkHUB", "✅ Мардер: " .. murdererPlayer.Name, 2)
    
    local murdererHum = murdererPlayer.Character:FindFirstChild("Humanoid")
    if murdererHum then
        murdererHum.PlatformStand = true
        murdererHum.WalkSpeed = 0
        murdererHum.JumpPower = 0
        murdererHum.AutoRotate = false
    end
    
    for _, part in ipairs(murdererPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    for _, v in ipairs(murdererHrp:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro") then
            v:Destroy()
        end
    end
    
    for i = 1, 12 do
        local part = Instance.new("Part")
        part.Size = Vector3.new(math.random(3, 6), math.random(3, 6), math.random(3, 6))
        part.Position = murdererHrp.Position + Vector3.new(math.random(-3, 3), math.random(-2, 4), math.random(-3, 3))
        part.Anchored = false
        part.CanCollide = false
        part.Transparency = 1
        part.Massless = true
        part.CustomPhysicalProperties = PhysicalProperties.new(0.1, 0.3, 0.5, 0.1, 0.1)
        part.Parent = workspace
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = part
        weld.Part1 = murdererHrp
        weld.Parent = part
        
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(math.random(-500, 500), math.random(8000, 15000), math.random(-500, 500))
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.P = math.huge
        bv.Parent = part
        
        Debris:AddItem(part, 15)
        Debris:AddItem(bv, 15)
    end
    
    local bodyAng = Instance.new("BodyAngularVelocity")
    bodyAng.AngularVelocity = Vector3.new(1500, 1500, 1500)
    bodyAng.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyAng.P = math.huge
    bodyAng.Parent = murdererHrp
    Debris:AddItem(bodyAng, 15)
    
    local flash = Instance.new("Part")
    flash.Size = Vector3.new(35, 35, 35)
    flash.Position = murdererHrp.Position
    flash.Anchored = true
    flash.CanCollide = false
    flash.Material = Enum.Material.Neon
    flash.Color = ACCENT.neon
    flash.Transparency = 0.3
    flash.Parent = workspace
    Debris:AddItem(flash, 4)
    
    local light = Instance.new("PointLight")
    light.Brightness = 35
    light.Range = 80
    light.Color = ACCENT.neon
    light.Parent = flash
    
    notify("XDarkHUB", "🚀 " .. murdererPlayer.Name .. " улетает в космос!", 3)
    
    bagFull = false
    collected = 0
    counterVal.Text = "0"
end

function flyTo(pos, speed)
    if not rootPart or farmStopped then return false end
    local distance = (pos - rootPart.Position).Magnitude
    local duration = math.max(0.1, distance / speed)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(pos)})
    tween:Play()
    local cancelled = false
    local timeout = task.delay(duration + 2, function()
        cancelled = true
        tween:Cancel()
    end)
    tween.Completed:Wait()
    if not cancelled then task.cancel(timeout) end
    return not cancelled
end

function startFarming()
    collected = 0
    startTime = tick()
    visitedPositions = {}
    bagFull = false
    farmStopped = false
    
    counterVal.Text = "0"
    timerVal.Text = "0s"
    rateVal.Text = "0"
    updateRoleUI()
    updateBagUI()
    notify("XDarkHUB", "🚀 Фарм запущен!", 3)

    task.spawn(function()
        while isActive do
            local elapsed = tick() - startTime
            timerVal.Text = math.floor(elapsed) .. "s"
            local rate = elapsed > 0 and math.floor((collected / elapsed) * 3600) or 0
            rateVal.Text = tostring(rate)
            local playerCoins = getPlayerCoins(player)
            playerCoinsVal.Text = tostring(playerCoins)
            task.wait(0.1)
        end
    end)

    task.spawn(function()
        while isActive do
            task.wait(0.5)
            if collected >= MAX_BAG and not farmStopped then
                notify("XDarkHUB", "🎒 МЕШОК ПОЛОН!", 3)
                bagFull = true
                farmStopped = true
                updateBagUI()
                checkRole()
                if isMurderer then
                    cinematicMurdererKill()
                else
                    throwMurdererToSpace()
                end
                stopFarming()
            end
        end
    end)

    task.spawn(function()
        while isActive do
            if farmStopped then task.wait(1) continue end
            character = player.Character
            if not character then task.wait(0.5) continue end
            rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then task.wait(0.5) continue end
            checkRole()

            local closest, shortest = nil, math.huge
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name == "Coin_Server" then
                    local isInsideCharacter = false
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character and obj:IsDescendantOf(p.Character) then
                            isInsideCharacter = true
                            break
                        end
                    end
                    if not isInsideCharacter and obj.Parent and obj:IsDescendantOf(workspace) and not visitedPositions[obj] then
                        local dist = (obj.Position - rootPart.Position).Magnitude
                        if dist < shortest and dist < 300 then
                            closest = obj
                            shortest = dist
                        end
                    end
                end
            end

            if closest then
                local coinPos = closest.Position
                local coinRef = closest
                if farmStopped then continue end
                local arrived = flyTo(coinPos, flySpeed)
                if farmStopped then continue end
                if arrived then
                    task.wait(0.3)
                    if coinRef.Parent and coinRef:IsDescendantOf(workspace) then
                        local isInsideCharacter = false
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p.Character and coinRef:IsDescendantOf(p.Character) then
                                isInsideCharacter = true
                                break
                            end
                        end
                        if not isInsideCharacter then
                            local distToCoin = (coinRef.Position - rootPart.Position).Magnitude
                            if distToCoin < 5 then
                                collected = collected + 1
                                counterVal.Text = tostring(collected)
                                collectSound:Play()
                                updateBagUI()
                                visitedPositions[coinRef] = true
                                if collected % 10 == 0 then
                                    notify("XDarkHUB", "✅ " .. collected .. "/" .. MAX_BAG, 2)
                                end
                            else
                                visitedPositions[coinRef] = true
                            end
                        else
                            visitedPositions[coinRef] = true
                        end
                    else
                        visitedPositions[coinRef] = true
                    end
                end
            else
                if next(visitedPositions) then visitedPositions = {} end
                task.wait(1)
            end
            task.wait(0.1)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  КНОПКА МЕНЮ (СКРЫТИЕ ВМЕСТЕ С ФРЕЙМОМ)
-- ═══════════════════════════════════════════════════════════

local menuButton = Instance.new("TextButton")
menuButton.Size = UDim2.new(0, 80, 0, 80)
menuButton.Position = UDim2.new(0, 25, 1, -105)
menuButton.BackgroundColor3 = ACCENT.base
menuButton.Text = "X"
menuButton.TextColor3 = COL.white
menuButton.TextSize = 44
menuButton.Font = Enum.Font.GothamBlack
menuButton.ZIndex = 10
menuButton.Parent = gui
corner(menuButton, 40)
stroke(menuButton, ACCENT.neon, 3, 0.4)

local menuGrad = Instance.new("UIGradient", menuButton)
menuGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ACCENT.neon),
    ColorSequenceKeypoint.new(1, ACCENT.dark),
})
menuGrad.Rotation = 45

task.spawn(function()
    while menuButton.Parent do
        animate(menuButton, {Size = UDim2.new(0, 85, 0, 85)}, 1.2, Enum.EasingStyle.Sine)
        task.wait(1.2)
        animate(menuButton, {Size = UDim2.new(0, 80, 0, 80)}, 1.2, Enum.EasingStyle.Sine)
        task.wait(1.2)
    end
end)

do
    local dragging, dragStart, startPos = false, nil, nil
    menuButton.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = menuButton.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local delta = i.Position - dragStart
            menuButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- 🔥 ИСПРАВЛЕНИЕ: скрываем ВСЁ меню вместе с фоном
menuButton.MouseButton1Click:Connect(function()
    local isVisible = frame.Visible
    frame.Visible = not isVisible
    bgFrame.Visible = not isVisible  -- Скрываем частицы тоже!
end)

function updateESP()
    for _, h in pairs(espHighlights) do
        if h then h:Destroy() end
    end
    espHighlights = {}
    if not espEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local role = getPlayerRole(p)
            local color = role == "Murderer" and Color3.fromRGB(255, 50, 50) or
                         role == "Sheriff" and Color3.fromRGB(50, 150, 255) or
                         Color3.fromRGB(50, 255, 50)
            local h = Instance.new("Highlight")
            h.FillColor = color
            h.OutlineColor = color
            h.FillTransparency = 0.7
            h.Parent = p.Character
            espHighlights[p] = h
        end
    end
end

task.spawn(function()
    while true do
        if espEnabled then updateESP() end
        task.wait(2)
    end
end)

player.CharacterAdded:Connect(function(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
    visitedPositions = {}
    farmStopped = false
    task.wait(1.5)
    checkRole()
    updateRoleUI()
end)

player.Idled:Connect(function()
    if antiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

RunService.Stepped:Connect(function()
    if isActive and character and not farmStopped then
        for _, v in ipairs(character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

updateRoleUI()
updateBagUI()
switchTab("Auto Farm")

notify("XDarkHUB", "✅ v7.0 загружен!", 3)
notify("XDarkHUB", "🎨 Улучшенные частицы", 3)
notify("XDarkHUB", "🚀 Классический флинг!", 4)
