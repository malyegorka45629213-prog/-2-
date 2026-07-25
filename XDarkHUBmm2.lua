-- ═══════════════════════════════════════════════════════════
--  XDarkHUB · MM2 Coin Autofarm · ПОЛНАЯ ВЕРСИЯ v3.0
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

-- 🔥 ЗВУКИ
local collectSound = Instance.new("Sound")
collectSound.SoundId = "rbxassetid://12221967"
collectSound.Volume = 1

local killSound = Instance.new("Sound")
killSound.SoundId = "rbxassetid://9120392731"
killSound.Volume = 0.8

local deathSound = Instance.new("Sound")
deathSound.SoundId = "rbxassetid://9120392731"
deathSound.Volume = 0.6

-- 🔥 УВЕДОМЛЕНИЯ
local function notify(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
    print("[" .. title .. "] " .. text)
end

-- 🔥 ОПРЕДЕЛЕНИЕ РОЛИ
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
    local leaderstats = p:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in ipairs(leaderstats:GetChildren()) do
            if v.Name == "Role" and v.Value then return v.Value end
            if v.Value == "Murderer" or v.Value == "murderer" then return "Murderer" end
            if v.Value == "Sheriff" or v.Value == "sheriff" then return "Sheriff" end
        end
    end
    local rv = p:FindFirstChild("Role")
    if rv and rv:IsA("StringValue") then return rv.Value end
    local ps = p:FindFirstChild("playerstats")
    if ps then
        local rv2 = ps:FindFirstChild("Role")
        if rv2 and rv2.Value then return rv2.Value end
    end
    return "Innocent"
end

local function checkRole()
    local role = getPlayerRole(player)
    isMurderer = (role == "Murderer")
    isSheriff = (role == "Sheriff")
end

-- 🔥 ЦВЕТА XDarkHUB
local COL = {
    bg = Color3.fromRGB(8, 8, 12),
    panel = Color3.fromRGB(15, 12, 18),
    card = Color3.fromRGB(20, 18, 24),
    cardHov = Color3.fromRGB(28, 25, 32),
    border = Color3.fromRGB(45, 40, 50),
    text = Color3.fromRGB(240, 235, 245),
    muted = Color3.fromRGB(120, 115, 130),
    white = Color3.fromRGB(255, 255, 255),
}
local ACCENT = {
    base = Color3.fromRGB(220, 30, 50),
    dim = Color3.fromRGB(90, 15, 25),
    light = Color3.fromRGB(255, 90, 110),
    glow = Color3.fromRGB(255, 50, 70),
    dark = Color3.fromRGB(60, 10, 20),
}

-- 🔥 УТИЛИТЫ UI
local function corner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r)
    return c
end

local function stroke(obj, color, th)
    local s = Instance.new("UIStroke", obj)
    s.Color = color
    s.Thickness = th or 1
    return s
end

local function tw(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad), props):Play()
end

-- Очистка старого GUI
do
    local old = player:WaitForChild("PlayerGui"):FindFirstChild("AutoFarmGui")
    if old then old:Destroy() end
end

-- 🔥 СОЗДАНИЕ GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

collectSound.Parent = gui
killSound.Parent = gui
deathSound.Parent = gui

-- 🔥 ГЛАВНЫЙ ФРЕЙМ
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 620, 0, 540)
frame.Position = UDim2.new(0.5, -310, 0.5, -270)
frame.BackgroundColor3 = COL.bg
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui
corner(frame, 14)
stroke(frame, ACCENT.base, 2)

-- 🔥 ЗАГОЛОВОК
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 55)
titleBar.BackgroundColor3 = COL.panel
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.ZIndex = 2
titleBar.Parent = frame
corner(titleBar, 14)

local titleGrad = Instance.new("UIGradient", titleBar)
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 15, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 8, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 15, 30)),
})

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -60, 1, 0)
titleLbl.Position = UDim2.new(0, 55, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "XDarkHUB"
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 24
titleLbl.TextColor3 = ACCENT.light
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 3
titleLbl.Parent = titleBar

local textGrad = Instance.new("UIGradient", titleLbl)
textGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ACCENT.light),
    ColorSequenceKeypoint.new(0.5, COL.white),
    ColorSequenceKeypoint.new(1, ACCENT.light),
})

local titleStroke = Instance.new("UIStroke", titleLbl)
titleStroke.Color = ACCENT.base
titleStroke.Thickness = 1
titleStroke.Transparency = 0.4

-- 🔥 ЛОГО X
local logo = Instance.new("Frame")
logo.Size = UDim2.new(0, 36, 0, 36)
logo.Position = UDim2.new(0, 12, 0.5, -18)
logo.BackgroundColor3 = ACCENT.base
logo.BorderSizePixel = 0
logo.ZIndex = 3
logo.Parent = titleBar
corner(logo, 10)

local logoGlow = Instance.new("UIStroke", logo)
logoGlow.Color = ACCENT.glow
logoGlow.Thickness = 2
logoGlow.Transparency = 0.5

local logoX = Instance.new("TextLabel")
logoX.Size = UDim2.new(1, 0, 1, 0)
logoX.BackgroundTransparency = 1
logoX.Text = "X"
logoX.Font = Enum.Font.GothamBlack
logoX.TextSize = 24
logoX.TextColor3 = COL.white
logoX.ZIndex = 4
logoX.Parent = logo

-- Версия
local versionLbl = Instance.new("TextLabel")
versionLbl.Size = UDim2.new(0, 100, 1, 0)
versionLbl.Position = UDim2.new(1, -110, 0, 0)
versionLbl.BackgroundTransparency = 1
versionLbl.Text = "v3.0 · MM2"
versionLbl.Font = Enum.Font.GothamBold
versionLbl.TextSize = 11
versionLbl.TextColor3 = ACCENT.light
versionLbl.TextXAlignment = Enum.TextXAlignment.Right
versionLbl.TextTransparency = 0.3
versionLbl.ZIndex = 3
versionLbl.Parent = titleBar

-- 🔥 РАЗДЕЛИТЕЛЬ
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -20, 0, 2)
sep.Position = UDim2.new(0, 10, 0, 55)
sep.BorderSizePixel = 0
sep.ZIndex = 2
sep.Parent = frame
corner(sep, 1)

local sepGrad = Instance.new("UIGradient", sep)
sepGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 8)),
    ColorSequenceKeypoint.new(0.5, ACCENT.base),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 8)),
})

-- 🔥 ПЕРЕТАСКИВАНИЕ ОКНА
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

-- 🔥 КОНТЕЙНЕР
local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 1, -60)
container.Position = UDim2.new(0, 0, 0, 60)
container.BackgroundTransparency = 1
container.Parent = frame

-- 🔥 ЛЕВАЯ ПАНЕЛЬ (ВКЛАДКИ)
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 160, 1, 0)
leftPanel.BackgroundColor3 = COL.panel
leftPanel.BorderSizePixel = 0
leftPanel.ZIndex = 2
leftPanel.Parent = container

local leftGrad = Instance.new("UIGradient", leftPanel)
leftGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 12, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 8, 12)),
})
leftGrad.Rotation = 0

-- 🔥 ПРАВАЯ ПАНЕЛЬ (КОНТЕНТ)
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(1, -160, 1, 0)
rightPanel.Position = UDim2.new(0, 160, 0, 0)
rightPanel.BackgroundTransparency = 1
rightPanel.ZIndex = 2
rightPanel.Parent = container

-- 🔥 СИСТЕМА ВКЛАДОК
local tabs = {}
local tabContents = {}
local currentTab = nil

local function createTab(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 48)
    btn.Position = UDim2.new(0, 10, 0, 10 + (order - 1) * 54)
    btn.BackgroundColor3 = COL.card
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.ZIndex = 3
    btn.Parent = leftPanel
    corner(btn, 10)
    stroke(btn, COL.border, 1)

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 40, 1, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextSize = 20
    iconLbl.TextColor3 = ACCENT.light
    iconLbl.ZIndex = 3
    iconLbl.Parent = btn

    local textLbl = Instance.new("TextLabel")
    textLbl.Size = UDim2.new(1, -45, 1, 0)
    textLbl.Position = UDim2.new(0, 45, 0, 0)
    textLbl.BackgroundTransparency = 1
    textLbl.Text = name
    textLbl.Font = Enum.Font.GothamBold
    textLbl.TextSize = 13
    textLbl.TextColor3 = COL.text
    textLbl.TextXAlignment = Enum.TextXAlignment.Left
    textLbl.ZIndex = 3
    textLbl.Parent = btn

    tabs[name] = {button = btn, icon = iconLbl, text = textLbl}
    return btn
end

local function createTabContent(name)
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = ACCENT.base
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ScrollingEnabled = true
    content.Visible = false
    content.ZIndex = 2
    content.Parent = rightPanel

    local p = Instance.new("UIPadding", content)
    p.PaddingLeft = UDim.new(0, 15)
    p.PaddingRight = UDim.new(0, 15)
    p.PaddingTop = UDim.new(0, 15)
    p.PaddingBottom = UDim.new(0, 15)

    local l = Instance.new("UIListLayout", content)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 8)

    tabContents[name] = content
    return content
end

local function switchTab(name)
    for n, tab in pairs(tabs) do
        tw(tab.button, {BackgroundColor3 = COL.card})
        tab.icon.TextColor3 = ACCENT.light
        tab.text.TextColor3 = COL.text
    end
    
    if tabs[name] then
        tw(tabs[name].button, {BackgroundColor3 = ACCENT.dark})
        tabs[name].icon.TextColor3 = ACCENT.glow
        tabs[name].text.TextColor3 = COL.white
    end
    
    for n, content in pairs(tabContents) do
        content.Visible = (n == name)
    end
    
    currentTab = name
end

-- Создаём вкладки
createTab("Sheriff", "⭐", 1)
createTab("Murderer", "🔪", 2)
createTab("ESP", "👁️", 3)
createTab("Player", "🎯", 4)
createTab("Auto Farm", "⚙️", 5)

-- Создаём контент
for name in pairs(tabs) do
    createTabContent(name)
end

-- Обработчики вкладок
for name, tab in pairs(tabs) do
    tab.button.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
    
    tab.button.MouseEnter:Connect(function()
        if not (currentTab == name) then
            tw(tab.button, {BackgroundColor3 = COL.cardHov})
        end
    end)
    
    tab.button.MouseLeave:Connect(function()
        if not (currentTab == name) then
            tw(tab.button, {BackgroundColor3 = COL.card})
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  UI КОМПОНЕНТЫ
-- ═══════════════════════════════════════════════════════════

local function sectionTitle(parent, order, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = ACCENT.light
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = order
    l.ZIndex = 2
    l.Parent = parent
end

local function statRow(parent, order, name)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = COL.card
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.ZIndex = 2
    row.Parent = parent
    corner(row, 8)
    stroke(row, COL.border, 1)

    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0.6, 0, 1, 0)
    n.Position = UDim2.new(0, 12, 0, 0)
    n.BackgroundTransparency = 1
    n.Text = name
    n.TextColor3 = COL.muted
    n.Font = Enum.Font.Gotham
    n.TextSize = 12
    n.TextXAlignment = Enum.TextXAlignment.Left
    n.ZIndex = 2
    n.Parent = row

    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(0.4, -12, 1, 0)
    v.Position = UDim2.new(0.6, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text = "0"
    v.TextColor3 = ACCENT.light
    v.Font = Enum.Font.GothamBold
    v.TextSize = 12
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.ZIndex = 2
    v.Parent = row
    return v
end

local function toggleCard(parent, order, label, onToggle)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3 = COL.card
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.ZIndex = 2
    card.Parent = parent
    corner(card, 10)
    local cs = stroke(card, COL.border, 1)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -90, 1, 0)
    t.Position = UDim2.new(0, 16, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = label
    t.TextColor3 = COL.text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 2
    t.Parent = card

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 52, 0, 24)
    pill.Position = UDim2.new(1, -62, 0.5, -12)
    pill.BackgroundColor3 = COL.border
    pill.BorderSizePixel = 0
    pill.ZIndex = 2
    pill.Parent = card
    corner(pill, 12)
    local ps = stroke(pill, COL.border, 1)

    local pl = Instance.new("TextLabel")
    pl.Size = UDim2.new(1, 0, 1, 0)
    pl.BackgroundTransparency = 1
    pl.Text = "OFF"
    pl.TextColor3 = COL.muted
    pl.Font = Enum.Font.GothamBold
    pl.TextSize = 10
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
            tw(card, {BackgroundColor3 = ACCENT.dim})
            tw(cs, {Color = ACCENT.base})
            tw(pill, {BackgroundColor3 = ACCENT.base})
            tw(ps, {Color = ACCENT.light})
            pl.Text = "ON"
            tw(pl, {TextColor3 = COL.white})
        else
            tw(card, {BackgroundColor3 = COL.card})
            tw(cs, {Color = COL.border})
            tw(pill, {BackgroundColor3 = COL.border})
            tw(ps, {Color = COL.border})
            pl.Text = "OFF"
            tw(pl, {TextColor3 = COL.muted})
        end
        if onToggle then onToggle(state) end
    end)

    btn.MouseEnter:Connect(function() if not state then tw(card, {BackgroundColor3 = COL.cardHov}) end end)
    btn.MouseLeave:Connect(function() if not state then tw(card, {BackgroundColor3 = COL.card}) end end)
end

-- ═══════════════════════════════════════════════════════════
--  КОНТЕНТ ВКЛАДКИ ESP
-- ═══════════════════════════════════════════════════════════

local espContent = tabContents["ESP"]
sectionTitle(espContent, 1, "👁️ VISUAL ESP")
toggleCard(espContent, 2, "ESP Roles", function(state)
    espEnabled = state
    updateESP()
    notify("XDarkHUB", "ESP: " .. (state and "ON" or "OFF"), 2)
end)

-- ═══════════════════════════════════════════════════════════
--  КОНТЕНТ ВКЛАДКИ AUTO FARM
-- ═══════════════════════════════════════════════════════════

local farmContent = tabContents["Auto Farm"]

sectionTitle(farmContent, 1, "📊 STATISTICS")
local counterVal = statRow(farmContent, 2, "Coins Collected")
local timerVal = statRow(farmContent, 3, "Time Active")
local rateVal = statRow(farmContent, 4, "Coins / Hour")

sectionTitle(farmContent, 5, "🎭 ROLE INFO")
local roleVal = statRow(farmContent, 6, "Your Role")

sectionTitle(farmContent, 7, "🎒 BAG STATUS")
local bagVal = statRow(farmContent, 8, "Bag Full")

-- Лимит мешка
do
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3 = COL.card
    card.BorderSizePixel = 0
    card.LayoutOrder = 9
    card.ZIndex = 2
    card.Parent = farmContent
    corner(card, 10)
    stroke(card, COL.border, 1)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -100, 1, 0)
    t.Position = UDim2.new(0, 16, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = "🎯 Bag Limit:"
    t.TextColor3 = COL.text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 2
    t.Parent = card

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 70, 0, 28)
    pill.Position = UDim2.new(1, -78, 0.5, -14)
    pill.BackgroundColor3 = ACCENT.base
    pill.BorderSizePixel = 0
    pill.ZIndex = 2
    pill.Parent = card
    corner(pill, 8)
    stroke(pill, ACCENT.light, 1)

    local pillLabel = Instance.new("TextLabel")
    pillLabel.Size = UDim2.new(1, 0, 1, 0)
    pillLabel.BackgroundTransparency = 1
    pillLabel.Text = tostring(MAX_BAG) .. " 🪙"
    pillLabel.TextColor3 = COL.white
    pillLabel.Font = Enum.Font.GothamBold
    pillLabel.TextSize = 13
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
        tw(pill, {Size = UDim2.new(0, 78, 0, 32)}, 0.1)
        task.wait(0.1)
        tw(pill, {Size = UDim2.new(0, 70, 0, 28)}, 0.1)
        notify("XDarkHUB", "🎯 Лимит: " .. MAX_BAG, 2)
    end)
end

-- Скорость
do
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3 = COL.card
    card.BorderSizePixel = 0
    card.LayoutOrder = 10
    card.ZIndex = 2
    card.Parent = farmContent
    corner(card, 10)
    stroke(card, COL.border, 1)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -100, 1, 0)
    t.Position = UDim2.new(0, 16, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = "⚡ Farm Speed"
    t.TextColor3 = COL.text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 2
    t.Parent = card

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 52, 0, 24)
    pill.Position = UDim2.new(1, -62, 0.5, -12)
    pill.BackgroundColor3 = ACCENT.dim
    pill.BorderSizePixel = 0
    pill.ZIndex = 2
    pill.Parent = card
    corner(pill, 12)
    stroke(pill, ACCENT.base, 1)

    local speedPillLbl = Instance.new("TextLabel")
    speedPillLbl.Size = UDim2.new(1, 0, 1, 0)
    speedPillLbl.BackgroundTransparency = 1
    speedPillLbl.Text = tostring(flySpeed)
    speedPillLbl.TextColor3 = ACCENT.light
    speedPillLbl.Font = Enum.Font.GothamBold
    speedPillLbl.TextSize = 11
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

-- Auto Farm кнопка
toggleCard(farmContent, 11, "⚙️ Auto Farm", function(state)
    isActive = state
    if state then 
        startFarming()
        notify("XDarkHUB", "✅ Auto Farm ВКЛЮЧЕН!", 2)
    else
        notify("XDarkHUB", "❌ Auto Farm ВЫКЛЮЧЕН!", 2)
    end
end)

-- Anti-AFK
toggleCard(farmContent, 12, "🛡️ Anti-AFK", function(state)
    antiAFK = state
    notify("XDarkHUB", "Anti-AFK: " .. (state and "ON" or "OFF"), 2)
end)

-- Test Fling
do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 48)
    btn.BackgroundColor3 = ACCENT.base
    btn.Text = "🚀 TEST FLING"
    btn.TextColor3 = COL.white
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.LayoutOrder = 13
    btn.ZIndex = 2
    btn.Parent = farmContent
    corner(btn, 10)
    stroke(btn, ACCENT.glow, 2)
    
    local btnGrad = Instance.new("UIGradient", btn)
    btnGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, ACCENT.base),
        ColorSequenceKeypoint.new(1, ACCENT.dark),
    })
    btnGrad.Rotation = 90
    
    btn.MouseEnter:Connect(function() tw(btn, {BackgroundColor3 = ACCENT.glow}) end)
    btn.MouseLeave:Connect(function() tw(btn, {BackgroundColor3 = ACCENT.base}) end)
    btn.MouseButton1Click:Connect(function()
        notify("XDarkHUB", "🔍 Запускаю тест флинга...", 2)
        throwMurdererToSpace()
    end)
end

-- Reset
do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = COL.card
    btn.Text = "🔄 Reset & Resume"
    btn.TextColor3 = ACCENT.light
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.LayoutOrder = 14
    btn.ZIndex = 2
    btn.Parent = farmContent
    corner(btn, 10)
    stroke(btn, ACCENT.base, 1)
    btn.MouseEnter:Connect(function() tw(btn, {BackgroundColor3 = COL.cardHov}) end)
    btn.MouseLeave:Connect(function() tw(btn, {BackgroundColor3 = COL.card}) end)
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

-- ═══════════════════════════════════════════════════════════
--  ЗАГЛУШКИ ДЛЯ SHERIFF/MURDERER/PLAYER
-- ═══════════════════════════════════════════════════════════

for _, name in ipairs({"Sheriff", "Murderer", "Player"}) do
    local content = tabContents[name]
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = name == "Sheriff" and "⭐ SHERIFF" or name == "Murderer" and "🔪 MURDERER" or "🎯 PLAYER"
    title.TextColor3 = ACCENT.light
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 1
    title.ZIndex = 2
    title.Parent = content
    
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 120)
    card.BackgroundColor3 = COL.card
    card.BorderSizePixel = 0
    card.LayoutOrder = 2
    card.ZIndex = 2
    card.Parent = content
    corner(card, 12)
    stroke(card, COL.border, 1)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "🚧 Coming Soon...\n\nЭта функция будет добавлена в следующей версии."
    lbl.TextColor3 = COL.muted
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
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

-- 🔪 УБИЙЦА УБИВАЕТ ВСЕХ
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
    
    notify("XDarkHUB", "🎯 Целей: " .. #targets, 2)
    
    -- Фиксируем цели
    for _, p in ipairs(targets) do
        local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")
        local targetHum = p.Character:FindFirstChild("Humanoid")
        if targetHrp and targetHum then
            targetHum.PlatformStand = true
            targetHum.WalkSpeed = 0
            targetHum.JumpPower = 0
            targetHum.AutoRotate = false
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
    
    notify("XDarkHUB", "🔒 Цели зафиксированы!", 2)
    
    -- Красная вспышка
    local flash = Instance.new("Part")
    flash.Size = Vector3.new(30, 30, 30)
    flash.Position = hrp.Position
    flash.Anchored = true
    flash.CanCollide = false
    flash.Material = Enum.Material.Neon
    flash.Color = ACCENT.base
    flash.Transparency = 0.4
    flash.Parent = workspace
    Debris:AddItem(flash, 3)
    
    local light = Instance.new("PointLight")
    light.Brightness = 25
    light.Range = 60
    light.Color = ACCENT.base
    light.Parent = flash
    
    task.wait(0.5)
    
    -- Убиваем всех
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
                local hitEffect = Instance.new("Part")
                hitEffect.Size = Vector3.new(2, 2, 2)
                hitEffect.Position = targetHrp.Position
                hitEffect.Anchored = true
                hitEffect.CanCollide = false
                hitEffect.Material = Enum.Material.Neon
                hitEffect.Color = ACCENT.base
                hitEffect.Transparency = 0.3
                hitEffect.Parent = workspace
                Debris:AddItem(hitEffect, 0.5)
                notify("XDarkHUB", "💀 " .. i .. "/" .. #targets .. " " .. p.Name, 1)
            end
        end
    end
    
    task.wait(0.3)
    bagFull = false
    collected = 0
    counterVal.Text = "0"
    notify("XDarkHUB", "🔪 Все убиты!", 3)
end

-- 🔥 ФЛИНГ МАРДЕРА (ПЕРСОНАЖ КРУТИТСЯ)
function throwMurdererToSpace()
    notify("XDarkHUB", "🚀 НАЧИНАЮ ФЛИНГ!", 4)
    deathSound:Play()
    
    local murdererPlayer = nil
    local foundRoles = {}
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local role = getPlayerRole(p)
            table.insert(foundRoles, p.Name .. ": " .. role)
            if role == "Murderer" then
                murdererPlayer = p
            end
        end
    end
    
    if not murdererPlayer then
        notify("XDarkHUB", "❌ Мардер не найден!", 4)
        notify("XDarkHUB", "Роли: " .. table.concat(foundRoles, ", "), 5)
        bagFull = false
        collected = 0
        counterVal.Text = "0"
        return
    end
    
    if not murdererPlayer.Character then
        notify("XDarkHUB", "❌ Нет Character!", 3)
        bagFull = false
        collected = 0
        counterVal.Text = "0"
        return
    end
    
    local murdererHrp = murdererPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not murdererHrp then
        notify("XDarkHUB", "❌ Нет HRP!", 3)
        bagFull = false
        collected = 0
        counterVal.Text = "0"
        return
    end
    
    local murdererHum = murdererPlayer.Character:FindFirstChild("Humanoid")
    
    notify("XDarkHUB", "✅ Мардер: " .. murdererPlayer.Name, 2)
    
    -- Отключаем управление мардеру
    if murdererHum then
        murdererHum.PlatformStand = true
        murdererHum.WalkSpeed = 0
        murdererHum.JumpPower = 0
        murdererHum.AutoRotate = false
    end
    
    -- Отключаем коллизии мардера
    for _, part in ipairs(murdererPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    -- Убираем старые velocity
    for _, v in ipairs(murdererHrp:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro") then
            v:Destroy()
        end
    end
    
    -- ПЕРСОНАЖ КРУТИТСЯ ВОКРУГ МАРДЕРА
    character = player.Character
    rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        notify("XDarkHUB", "🌀 Кручусь вокруг мардера!", 3)
        
        local startPos = rootPart.Position
        local radius = 4
        local totalSpins = 60
        
        for i = 1, totalSpins do
            if not murdererHrp.Parent or not rootPart.Parent then break end
            
            local angle = math.rad(i * 20)
            local height = i * 25
            
            local offset = Vector3.new(
                math.cos(angle) * radius,
                height,
                math.sin(angle) * radius
            )
            
            rootPart.CFrame = CFrame.new(murdererHrp.Position + offset, murdererHrp.Position)
            
            -- Красный след
            local trail = Instance.new("Part")
            trail.Size = Vector3.new(1, 1, 1)
            trail.Position = rootPart.Position
            trail.Anchored = true
            trail.CanCollide = false
            trail.Material = Enum.Material.Neon
            trail.Color = ACCENT.base
            trail.Transparency = 0.3
            trail.Parent = workspace
            Debris:AddItem(trail, 1)
            
            task.wait(0.02)
        end
        
        notify("XDarkHUB", "🚀 Выбрасываю мардера!", 2)
        
        -- Мощный импульс мардеру
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Velocity = Vector3.new(0, 15000, 0)
        bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVel.P = math.huge
        bodyVel.Parent = murdererHrp
        Debris:AddItem(bodyVel, 10)
        
        local bodyAng = Instance.new("BodyAngularVelocity")
        bodyAng.AngularVelocity = Vector3.new(800, 800, 800)
        bodyAng.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyAng.P = math.huge
        bodyAng.Parent = murdererHrp
        Debris:AddItem(bodyAng, 10)
        
        -- Возвращаем персонажа
        rootPart.CFrame = CFrame.new(startPos)
        
        notify("XDarkHUB", "🚀 " .. murdererPlayer.Name .. " улетел!", 3)
    end
    
    -- Красный эффект
    local flash = Instance.new("Part")
    flash.Size = Vector3.new(30, 30, 30)
    flash.Position = murdererHrp.Position
    flash.Anchored = true
    flash.CanCollide = false
    flash.Material = Enum.Material.Neon
    flash.Color = ACCENT.base
    flash.Transparency = 0.3
    flash.Parent = workspace
    Debris:AddItem(flash, 4)
    
    local light = Instance.new("PointLight")
    light.Brightness = 30
    light.Range = 70
    light.Color = ACCENT.base
    light.Parent = flash
    
    bagFull = false
    collected = 0
    counterVal.Text = "0"
end

-- 🔥 ПОЛЁТ К МОНЕТЕ
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

-- 🔥 ФАРМ
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
    notify("XDarkHUB", "🚀 Фарм запущен! Лимит: " .. MAX_BAG, 3)

    -- Поток статистики
    task.spawn(function()
        while isActive do
            local elapsed = tick() - startTime
            timerVal.Text = math.floor(elapsed) .. "s"
            local rate = elapsed > 0 and math.floor((collected / elapsed) * 3600) or 0
            rateVal.Text = tostring(rate)
            task.wait(0.1)
        end
    end)

    -- Поток проверки мешка
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

    -- Поток сбора монет
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

-- 🔥 ПЕРЕТАСКИВАЕМАЯ КНОПКА X
local menuButton = Instance.new("TextButton")
menuButton.Size = UDim2.new(0, 70, 0, 70)
menuButton.Position = UDim2.new(0, 15, 1, -90)
menuButton.BackgroundColor3 = ACCENT.base
menuButton.Text = "X"
menuButton.TextColor3 = COL.white
menuButton.TextSize = 36
menuButton.Font = Enum.Font.GothamBlack
menuButton.ZIndex = 10
menuButton.Parent = gui
corner(menuButton, 35)
stroke(menuButton, ACCENT.glow, 2)

local menuGrad = Instance.new("UIGradient", menuButton)
menuGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ACCENT.glow),
    ColorSequenceKeypoint.new(1, ACCENT.dark),
})
menuGrad.Rotation = 45

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
            menuButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

menuButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- 🔥 ESP ПОДСВЕТКА
function updateESP()
    for _, highlight in pairs(espHighlights) do
        if highlight then highlight:Destroy() end
    end
    espHighlights = {}
    if not espEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local role = getPlayerRole(p)
            local color
            if role == "Murderer" then color = Color3.fromRGB(255, 50, 50)
            elseif role == "Sheriff" then color = Color3.fromRGB(50, 150, 255)
            else color = Color3.fromRGB(50, 255, 50) end
            local highlight = Instance.new("Highlight")
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = p.Character
            espHighlights[p] = highlight
        end
    end
end

task.spawn(function()
    while true do
        if espEnabled then updateESP() end
        task.wait(2)
    end
end)

-- 🔥 СИСТЕМНЫЕ СОБЫТИЯ
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

-- Показываем вкладку Auto Farm по умолчанию
switchTab("Auto Farm")

notify("XDarkHUB", "✅ XDarkHUB v3.0 загружен!", 3)
notify("XDarkHUB", "🎨 Система вкладок слева", 3)
notify("XDarkHUB", "🚀 Флинг: кручусь вокруг мардера!", 4)
