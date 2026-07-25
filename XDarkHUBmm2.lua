-- ═══════════════════════════════════════════════════════════
--  XDarkHUB · MM2 Coin Autofarm · ЧЁРНАЯ ТЕМА
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
        local rv = leaderstats:FindFirstChild("Role")
        if rv and rv.Value then return rv.Value end
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

-- 🔥 ЧЁРНАЯ ТЕМА XDarkHUB
local COL = {
    bg = Color3.fromRGB(8, 8, 12),          -- Почти чёрный фон
    card = Color3.fromRGB(18, 18, 24),       -- Тёмно-серая карточка
    cardHov = Color3.fromRGB(28, 28, 36),    -- Серый при наведении
    off = Color3.fromRGB(35, 35, 45),        -- Выключенный
    border = Color3.fromRGB(45, 45, 55),     -- Граница
    text = Color3.fromRGB(240, 240, 245),    -- Белый текст
    muted = Color3.fromRGB(120, 120, 135),   -- Приглушённый
    white = Color3.fromRGB(255, 255, 255),   -- Белый
}
local ACCENT = {
    base = Color3.fromRGB(180, 30, 50),      -- Тёмно-красный (XDarkHUB стиль)
    dim = Color3.fromRGB(80, 15, 25),        -- Тёмный красный
    light = Color3.fromRGB(255, 80, 100),    -- Светло-красный
}

local function corner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r)
    return c
end

local function stroke(obj, color, th)
    local s = Instance.new("UIStroke", obj)
    s.Color = color
    s.Thickness = th or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function tw(obj, props, t, style)
    TweenService:Create(obj, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

do
    local pg = player:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("AutoFarmGui")
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

-- 🔥 ГЛАВНЫЙ ФРЕЙМ
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 540)
frame.Position = UDim2.new(0.5, -180, 0.5, -270)
frame.BackgroundColor3 = COL.bg
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui
corner(frame, 16)
stroke(frame, ACCENT.base, 2)

-- 🔥 ВЕРХНЯЯ ПАНЕЛЬ С НАЗВАНИЕМ XDarkHUB
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.ZIndex = 2
titleBar.Parent = frame
corner(titleBar, 16)

-- Градиент на верхней панели
local titleGrad = Instance.new("UIGradient", titleBar)
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 12)),
})
titleGrad.Rotation = 0

-- 🔥 НАЗВАНИЕ XDarkHUB (КРАСИВЫЙ ШРИФТ)
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -60, 1, 0)
titleLbl.Position = UDim2.new(0, 50, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "XDarkHUB"
titleLbl.Font = Enum.Font.GothamBlack  -- Самый жирный и красивый
titleLbl.TextSize = 22
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 3
titleLbl.Parent = titleBar

-- Градиент на тексте
local textGrad = Instance.new("UIGradient", titleLbl)
textGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 100)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 100)),
})
textGrad.Rotation = 0

-- Обводка текста
local titleStroke = Instance.new("UIStroke", titleLbl)
titleStroke.Color = ACCENT.base
titleStroke.Thickness = 1
titleStroke.Transparency = 0.3

-- 🔥 ЛОГО (красный квадрат с X)
local logo = Instance.new("Frame")
logo.Size = UDim2.new(0, 32, 0, 32)
logo.Position = UDim2.new(0, 12, 0.5, -16)
logo.BackgroundColor3 = ACCENT.base
logo.BorderSizePixel = 0
logo.ZIndex = 3
logo.Parent = titleBar
corner(logo, 8)

local logoX = Instance.new("TextLabel")
logoX.Size = UDim2.new(1, 0, 1, 0)
logoX.BackgroundTransparency = 1
logoX.Text = "X"
logoX.Font = Enum.Font.GothamBlack
logoX.TextSize = 22
logoX.TextColor3 = COL.white
logoX.ZIndex = 4
logoX.Parent = logo

-- Линия под заголовком
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -20, 0, 1)
sep.Position = UDim2.new(0, 10, 0, 50)
sep.BackgroundColor3 = ACCENT.base
sep.BorderSizePixel = 0
sep.ZIndex = 2
sep.Parent = frame

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

-- Scrolling Frame
local body = Instance.new("ScrollingFrame")
body.Size = UDim2.new(1, 0, 1, -55)
body.Position = UDim2.new(0, 0, 0, 55)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ScrollBarThickness = 4
body.ScrollBarImageColor3 = ACCENT.base
body.CanvasSize = UDim2.new(0, 0, 0, 0)
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.ScrollingEnabled = true
body.ZIndex = 2
body.Parent = frame

do
    local p = Instance.new("UIPadding", body)
    p.PaddingLeft = UDim.new(0, 14)
    p.PaddingRight = UDim.new(0, 14)
    p.PaddingTop = UDim.new(0, 10)
    p.PaddingBottom = UDim.new(0, 14)
    local l = Instance.new("UIListLayout", body)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 8)
end

-- 🔥 КНОПКА С ЧЁРНОЙ ТЕМОЙ
local function toggleCard(order, label, onToggle)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 46)
    card.BackgroundColor3 = COL.card
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.ZIndex = 2
    card.Parent = body
    corner(card, 10)
    local cs = stroke(card, COL.border, 1)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -90, 1, 0)
    t.Position = UDim2.new(0, 16, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = label
    t.TextColor3 = COL.text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 2
    t.Parent = card

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 52, 0, 24)
    pill.Position = UDim2.new(1, -66, 0.5, -12)
    pill.BackgroundColor3 = COL.off
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
    pl.TextSize = 11
    pl.ZIndex = 2
    pl.Parent = pill

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 3
    btn.Parent = card

    local currentState = false

    local function updateVisual()
        if currentState then
            tw(card, {BackgroundColor3 = ACCENT.dim})
            tw(cs, {Color = ACCENT.base})
            tw(pill, {BackgroundColor3 = ACCENT.base})
            tw(ps, {Color = ACCENT.light})
            pl.Text = "ON"
            tw(pl, {TextColor3 = COL.white})
        else
            tw(card, {BackgroundColor3 = COL.card})
            tw(cs, {Color = COL.border})
            tw(pill, {BackgroundColor3 = COL.off})
            tw(ps, {Color = COL.border})
            pl.Text = "OFF"
            tw(pl, {TextColor3 = COL.muted})
        end
    end

    btn.MouseButton1Click:Connect(function()
        currentState = not currentState
        updateVisual()
        if onToggle then onToggle(currentState) end
    end)

    btn.MouseEnter:Connect(function() if not currentState then tw(card, {BackgroundColor3 = COL.cardHov}) end end)
    btn.MouseLeave:Connect(function() if not currentState then tw(card, {BackgroundColor3 = COL.card}) end end)

    return {
        setState = function(v) currentState = v updateVisual() end,
        getState = function() return currentState end
    }
end

local function statRow(order, name)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.ZIndex = 2
    row.Parent = body

    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0.62, 0, 1, 0)
    n.BackgroundTransparency = 1
    n.Text = name
    n.TextColor3 = COL.muted
    n.Font = Enum.Font.Gotham
    n.TextSize = 13
    n.TextXAlignment = Enum.TextXAlignment.Left
    n.ZIndex = 2
    n.Parent = row

    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(0.38, -2, 1, 0)
    v.Position = UDim2.new(0.62, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text = "0"
    v.TextColor3 = ACCENT.light
    v.Font = Enum.Font.GothamBold
    v.TextSize = 13
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.ZIndex = 2
    v.Parent = row
    return v
end

local function sectionLabel(order, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = ACCENT.light
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = order
    l.ZIndex = 2
    l.Parent = body
end

sectionLabel(5, "STATS")
local counterVal = statRow(6, "Coins Collected")
local timerVal = statRow(7, "Time Active")
local rateVal = statRow(8, "Coins / Hour")

sectionLabel(9, "ROLE INFO")
local roleVal = statRow(10, "Your Role")

sectionLabel(11, "BAG STATUS")
local bagVal = statRow(12, "Bag Full")

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
        bagVal.TextColor3 = Color3.fromRGB(150, 150, 160)
    end
end

function stopFarming()
    farmStopped = true
    updateBagUI()
    print("🛑 ФАРМ ОСТАНОВЛЕН!")
end

function cinematicMurdererKill()
    print("🔪 === УБИЙЦА УБИВАЕТ ВСЕХ ===")
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
    
    local myLook = hrp.CFrame.LookVector
    for i, p in ipairs(targets) do
        local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")
        local targetHum = p.Character:FindFirstChild("Humanoid")
        if targetHrp then
            local offset = myLook * (2 + (i - 1) * 1.5)
            targetHrp.CFrame = CFrame.new(hrp.Position + offset, hrp.Position)
            if targetHum then
                targetHum.PlatformStand = true
                targetHum.WalkSpeed = 0
                targetHum.JumpPower = 0
            end
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
    
    task.wait(0.5)
    
    for _, p in ipairs(targets) do
        if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, -1.5)
                task.wait(0.1)
                if myKnife and myKnife.Parent == character then myKnife:Activate() end
                task.wait(0.05)
                if p.Character and p.Character:FindFirstChild("Humanoid") then
                    p.Character.Humanoid:TakeDamage(100)
                end
            end
        end
    end
    
    task.wait(0.3)
    bagFull = false
    collected = 0
    counterVal.Text = "0"
end

-- 🔥 ПРАВИЛЬНЫЙ ФЛИНГ С ОТЛАДКОЙ
function throwMurdererToSpace()
    print("🚀 ========================================")
    print("🚀 === ФЛИНГ МАРДЕРА В КОСМОС ===")
    print("🚀 ========================================")
    deathSound:Play()
    
    -- 🔥 Ищем мардера
    local murdererPlayer = nil
    print("🔍 Ищем мардера среди игроков...")
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local role = getPlayerRole(p)
            print("  👤", p.Name, "→", role)
            if role == "Murderer" then
                murdererPlayer = p
                print("  ✅ НАЙДЕН:", p.Name)
                break
            end
        end
    end
    
    if not murdererPlayer then
        print("❌ МАРДЕР НЕ НАЙДЕН!")
        bagFull = false
        collected = 0
        counterVal.Text = "0"
        return
    end
    
    if not murdererPlayer.Character then
        print("❌ У мардера нет Character!")
        bagFull = false
        collected = 0
        counterVal.Text = "0"
        return
    end
    
    local murdererHrp = murdererPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not murdererHrp then
        print("❌ У мардера нет HumanoidRootPart!")
        bagFull = false
        collected = 0
        counterVal.Text = "0"
        return
    end
    
    local murdererHum = murdererPlayer.Character:FindFirstChild("Humanoid")
    
    print("✅ Мардер найден:", murdererPlayer.Name)
    print("📍 Позиция мардера:", murdererHrp.Position)
    
    -- 🔥 Отключаем управление мардеру
    if murdererHum then
        murdererHum.PlatformStand = true
        murdererHum.WalkSpeed = 0
        murdererHum.JumpPower = 0
        murdererHum.AutoRotate = false
        print("✅ Управление отключено")
    end
    
    -- 🔥 Отключаем коллизии мардера
    for _, part in ipairs(murdererPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    print("✅ Коллизии отключены")
    
    -- 🔥 Убираем старые velocity
    for _, v in ipairs(murdererHrp:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro") then
            v:Destroy()
        end
    end
    
    -- 🔥 СОЗДАЁМ ФЛИНГ-ЧАСТЬ
    local flingPart = Instance.new("Part")
    flingPart.Name = "XDarkHUB_Fling"
    flingPart.Size = Vector3.new(4, 4, 4)
    flingPart.Position = murdererHrp.Position + Vector3.new(0, 3, 0)
    flingPart.Anchored = false
    flingPart.CanCollide = false
    flingPart.Transparency = 1
    flingPart.Massless = true
    flingPart.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
    flingPart.Parent = workspace
    print("✅ Флинг-часть создана")
    
    -- 🔥 WeldConstraint (НЕ Weld!)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = flingPart
    weld.Part1 = murdererHrp
    weld.Parent = flingPart
    print("✅ WeldConstraint создан")
    
    -- 🔥 ОГРОМНЫЙ BodyVelocity на флинг-части
    local flingVel = Instance.new("BodyVelocity")
    flingVel.Velocity = Vector3.new(0, 15000, 0)
    flingVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flingVel.P = math.huge
    flingVel.Parent = flingPart
    print("✅ BodyVelocity 15000 добавлен")
    
    -- 🔥 Быстрое вращение
    local flingAng = Instance.new("BodyAngularVelocity")
    flingAng.AngularVelocity = Vector3.new(800, 800, 800)
    flingAng.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flingAng.P = math.huge
    flingAng.Parent = flingPart
    print("✅ BodyAngularVelocity 800 добавлен")
    
    -- 🔥 Красный эффект (XDarkHUB стиль)
    local flash = Instance.new("Part")
    flash.Size = Vector3.new(25, 25, 25)
    flash.Position = murdererHrp.Position
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
    
    -- 🔥 Красный след
    task.spawn(function()
        for i = 1, 50 do
            task.wait(0.05)
            if murdererHrp.Parent then
                local trail = Instance.new("Part")
                trail.Size = Vector3.new(2, 2, 2)
                trail.Position = murdererHrp.Position
                trail.Anchored = true
                trail.CanCollide = false
                trail.Material = Enum.Material.Neon
                trail.Color = ACCENT.base
                trail.Transparency = 0.3
                trail.Parent = workspace
                Debris:AddItem(trail, 1.5)
            end
        end
    end)
    
    Debris:AddItem(flingPart, 10)
    Debris:AddItem(flingVel, 10)
    Debris:AddItem(flingAng, 10)
    
    print("🚀", murdererPlayer.Name, "улетает в космос!")
    print("🚀 ========================================")
    
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
    print("🚀 ФАРМ ЗАПУЩЕН! MAX_BAG =", MAX_BAG)

    task.spawn(function()
        while isActive do
            local elapsed = tick() - startTime
            timerVal.Text = math.floor(elapsed) .. "s"
            local rate = elapsed > 0 and math.floor((collected / elapsed) * 3600) or 0
            rateVal.Text = tostring(rate)
            task.wait(0.1)
        end
    end)

    task.spawn(function()
        while isActive do
            task.wait(0.5)
            if collected >= MAX_BAG and not farmStopped then
                print("🎒 === МЕШОК ПОЛОН! ===")
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
                                print("✅ Собрано:", collected, "/", MAX_BAG)
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

local farmToggle = toggleCard(1, "Auto Farm", function(state)
    isActive = state
    if state then startFarming() end
end)

local afkToggle = toggleCard(2, "Anti-AFK", function(state)
    antiAFK = state
end)

local espToggle = toggleCard(3, "ESP Roles", function(state)
    espEnabled = state
    updateESP()
end)

-- 🔥 КНОПКА СКОРОСТИ (ЧЁРНАЯ ТЕМА)
local speedCard = Instance.new("Frame")
speedCard.Size = UDim2.new(1, 0, 0, 46)
speedCard.BackgroundColor3 = COL.card
speedCard.BorderSizePixel = 0
speedCard.LayoutOrder = 4
speedCard.ZIndex = 2
speedCard.Parent = body
corner(speedCard, 10)
stroke(speedCard, COL.border, 1)
do
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -90, 1, 0)
    t.Position = UDim2.new(0, 16, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = "Farm Speed"
    t.TextColor3 = COL.text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 2
    t.Parent = speedCard
end
local speedPillLbl
do
    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 52, 0, 24)
    pill.Position = UDim2.new(1, -66, 0.5, -12)
    pill.BackgroundColor3 = ACCENT.dim
    pill.BorderSizePixel = 0
    pill.ZIndex = 2
    pill.Parent = speedCard
    corner(pill, 12)
    stroke(pill, ACCENT.base, 1)
    speedPillLbl = Instance.new("TextLabel")
    speedPillLbl.Size = UDim2.new(1, 0, 1, 0)
    speedPillLbl.BackgroundTransparency = 1
    speedPillLbl.Text = tostring(flySpeed)
    speedPillLbl.TextColor3 = ACCENT.light
    speedPillLbl.Font = Enum.Font.GothamBold
    speedPillLbl.TextSize = 12
    speedPillLbl.ZIndex = 2
    speedPillLbl.Parent = pill
end
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, 0, 1, 0)
speedBtn.BackgroundTransparency = 1
speedBtn.Text = ""
speedBtn.ZIndex = 3
speedBtn.Parent = speedCard
speedBtn.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 5
    if flySpeed > 50 then flySpeed = 10 end
    speedPillLbl.Text = tostring(flySpeed)
end)

-- 🔥 КНОПКА ЛИМИТА
do
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 46)
    card.BackgroundColor3 = COL.card
    card.BorderSizePixel = 0
    card.LayoutOrder = 13
    card.ZIndex = 2
    card.Parent = body
    corner(card, 10)
    stroke(card, COL.border, 1)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(0.6, 0, 1, 0)
    t.Position = UDim2.new(0, 16, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = "Bag Limit:"
    t.TextColor3 = COL.text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 2
    t.Parent = card

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 72, 0, 30)
    pill.Position = UDim2.new(0.75, 0, 0.5, -15)
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
    pillLabel.TextSize = 14
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
        tw(pill, {Size = UDim2.new(0, 80, 0, 34)}, 0.1)
        task.wait(0.1)
        tw(pill, {Size = UDim2.new(0, 72, 0, 30)}, 0.1)
    end)
end

-- 🔥 КНОПКА СБРОСА
do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = COL.card
    btn.Text = "Reset & Resume"
    btn.TextColor3 = ACCENT.light
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.LayoutOrder = 14
    btn.ZIndex = 2
    btn.Parent = body
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
    end)
end

-- 🔥 КНОПКА 💎 (КРАСНАЯ ВМЕСТО ФИОЛЕТОВОЙ)
local menuButton = Instance.new("TextButton")
menuButton.Size = UDim2.new(0, 65, 0, 65)
menuButton.Position = UDim2.new(0, 15, 1, -85)
menuButton.BackgroundColor3 = ACCENT.base
menuButton.Text = "X"
menuButton.TextColor3 = COL.white
menuButton.TextSize = 32
menuButton.Font = Enum.Font.GothamBlack
menuButton.ZIndex = 10
menuButton.Parent = gui
corner(menuButton, 32)
stroke(menuButton, ACCENT.light, 2)
menuButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

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

print("========================================")
print("✅ XDarkHUB загружен!")
print("🎨 Чёрная тема с красным акцентом")
print("🚀 Флинг мардера через WeldConstraint")
print("📍 Открой консоль (F9) для отладки")
print("========================================")
