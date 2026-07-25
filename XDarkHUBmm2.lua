-- ═══════════════════════════════════════════════════════════
--  XDarkHUB v8.0 · MM2 Autofarm · OPTIMIZED PREMIUM UI
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
--  ОПТИМИЗИРОВАННАЯ UI СИСТЕМА
-- ═══════════════════════════════════════════════════════════

local THEME = {
    colors = {
        bg = Color3.fromRGB(2, 2, 5),
        panel = Color3.fromRGB(8, 8, 12),
        card = Color3.fromRGB(14, 14, 20),
        cardHov = Color3.fromRGB(22, 22, 30),
        border = Color3.fromRGB(35, 35, 45),
        text = Color3.fromRGB(250, 248, 255),
        muted = Color3.fromRGB(100, 100, 115),
        white = Color3.fromRGB(255, 255, 255),
    },
    accent = {
        base = Color3.fromRGB(230, 25, 55),
        dim = Color3.fromRGB(70, 10, 20),
        light = Color3.fromRGB(255, 85, 105),
        glow = Color3.fromRGB(255, 45, 65),
        dark = Color3.fromRGB(45, 6, 15),
        neon = Color3.fromRGB(255, 30, 60),
    },
    sizes = {
        corner = 14,
        padding = 16,
        spacing = 12,
    }
}

local UI = {}

function UI.corner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or THEME.sizes.corner)
    return c
end

function UI.stroke(obj, color, th, trans)
    local s = Instance.new("UIStroke", obj)
    s.Color = color or THEME.colors.border
    s.Thickness = th or 1
    s.Transparency = trans or 0
    return s
end

function UI.gradient(obj, colors, rotation)
    local g = Instance.new("UIGradient", obj)
    g.Color = ColorSequence.new(colors or {
        ColorSequenceKeypoint.new(0, THEME.colors.card),
        ColorSequenceKeypoint.new(1, THEME.colors.panel),
    })
    g.Rotation = rotation or 0
    return g
end

function UI.animate(obj, props, t, style)
    local info = TweenInfo.new(t or 0.3, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

function UI.createFrame(parent, props)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = props.bg or THEME.colors.card
    f.BackgroundTransparency = props.transparency or 0
    f.BorderSizePixel = 0
    f.Size = props.size or UDim2.new(1, 0, 0, 50)
    f.Position = props.position or UDim2.new(0, 0, 0, 0)
    f.ZIndex = props.zIndex or 2
    f.Parent = parent
    
    if props.corner then UI.corner(f, props.corner) end
    if props.stroke then UI.stroke(f, props.stroke.color, props.stroke.thickness, props.stroke.transparency) end
    if props.gradient then UI.gradient(f, props.gradient.colors, props.gradient.rotation) end
    
    return f
end

function UI.createLabel(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = props.transparency or 1
    l.Size = props.size or UDim2.new(1, 0, 1, 0)
    l.Position = props.position or UDim2.new(0, 0, 0, 0)
    l.Text = props.text or ""
    l.TextColor3 = props.color or THEME.colors.text
    l.Font = props.font or Enum.Font.GothamBold
    l.TextSize = props.textSize or 14
    l.TextXAlignment = props.xAlign or Enum.TextXAlignment.Left
    l.TextYAlignment = props.yAlign or Enum.TextYAlignment.Center
    l.ZIndex = props.zIndex or 2
    l.Parent = parent
    
    if props.gradient then UI.gradient(l, props.gradient.colors, props.gradient.rotation) end
    
    return l
end

function UI.createButton(parent, props)
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = props.bg or THEME.colors.card
    b.BackgroundTransparency = props.transparency or 0
    b.Size = props.size or UDim2.new(1, 0, 0, 50)
    b.Position = props.position or UDim2.new(0, 0, 0, 0)
    b.Text = props.text or ""
    b.TextColor3 = props.textColor or THEME.colors.white
    b.Font = props.font or Enum.Font.GothamBold
    b.TextSize = props.textSize or 14
    b.AutoButtonColor = props.autoColor or false
    b.ZIndex = props.zIndex or 3
    b.Parent = parent
    
    if props.corner then UI.corner(b, props.corner) end
    if props.stroke then UI.stroke(b, props.stroke.color, props.stroke.thickness, props.stroke.transparency) end
    if props.gradient then UI.gradient(b, props.gradient.colors, props.gradient.rotation) end
    
    return b
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
--  ФОН С ЧАСТИЦАМИ
-- ═══════════════════════════════════════════════════════════

local bgFrame = UI.createFrame(gui, {
    bg = THEME.colors.bg,
    transparency = 0.15,
    size = UDim2.new(1, 0, 1, 0),
    zIndex = 0,
    gradient = {
        colors = {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 2, 8)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(2, 2, 5)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 2, 5)),
        },
        rotation = 45
    }
})

local particleColors = {
    THEME.accent.base, THEME.accent.neon, THEME.accent.glow, 
    THEME.accent.light, Color3.fromRGB(255, 20, 40), Color3.fromRGB(255, 100, 120)
}

for i = 1, 35 do
    local particle = UI.createFrame(bgFrame, {
        bg = particleColors[math.random(1, #particleColors)],
        transparency = math.random(40, 80) / 100,
        size = UDim2.new(0, math.random(3, 14), 0, math.random(3, 14)),
        position = UDim2.new(math.random(), 0, math.random(), 0),
        corner = math.random(2, 7),
        zIndex = 0
    })
    
    task.spawn(function()
        while particle.Parent do
            UI.animate(particle, {
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                BackgroundTransparency = math.random(30, 85) / 100
            }, math.random(12, 28), Enum.EasingStyle.Sine)
            task.wait(math.random(12, 28))
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  ГЛАВНЫЙ ФРЕЙМ
-- ═══════════════════════════════════════════════════════════

local frame = UI.createFrame(gui, {
    bg = THEME.colors.bg,
    transparency = 0.03,
    size = UDim2.new(0, 700, 0, 600),
    position = UDim2.new(0.5, -350, 0.5, -300),
    corner = 20,
    stroke = {color = THEME.accent.neon, thickness = 2, transparency = 0.5},
    zIndex = 1
})

local outerGlow = UI.stroke(frame, THEME.accent.neon, 2, 0.5)

task.spawn(function()
    while frame.Parent do
        UI.animate(outerGlow, {Transparency = 0.3, Thickness = 3}, 2.5, Enum.EasingStyle.Sine)
        task.wait(2.5)
        UI.animate(outerGlow, {Transparency = 0.7, Thickness = 2}, 2.5, Enum.EasingStyle.Sine)
        task.wait(2.5)
    end
end)

-- ═══════════════════════════════════════════════════════════
--  ЗАГОЛОВОК
-- ═══════════════════════════════════════════════════════════

local titleBar = UI.createFrame(frame, {
    bg = THEME.colors.panel,
    transparency = 0.05,
    size = UDim2.new(1, 0, 0, 70),
    corner = 20,
    gradient = {
        colors = {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 12, 25)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 6, 12)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 12, 25)),
        }
    },
    zIndex = 2
})
titleBar.Active = true

task.spawn(function()
    local rotation = 0
    while frame.Parent do
        rotation = rotation + 0.4
        titleBar.UIGradient.Rotation = rotation
        task.wait(0.05)
    end
end)

local logo = UI.createFrame(titleBar, {
    bg = THEME.accent.base,
    size = UDim2.new(0, 50, 0, 50),
    position = UDim2.new(0, 20, 0.5, -25),
    corner = 15,
    stroke = {color = THEME.accent.neon, thickness = 2, transparency = 0.3},
    zIndex = 3
})

task.spawn(function()
    while frame.Parent do
        UI.animate(logo, {Size = UDim2.new(0, 54, 0, 54)}, 1.5, Enum.EasingStyle.Sine)
        task.wait(1.5)
        UI.animate(logo, {Size = UDim2.new(0, 50, 0, 50)}, 1.5, Enum.EasingStyle.Sine)
        task.wait(1.5)
    end
end)

UI.createLabel(logo, {
    text = "X",
    color = THEME.colors.white,
    font = Enum.Font.GothamBlack,
    textSize = 32,
    xAlign = Enum.TextXAlignment.Center,
    zIndex = 4
})

UI.createLabel(titleBar, {
    text = "XDarkHUB",
    color = THEME.accent.light,
    font = Enum.Font.GothamBlack,
    textSize = 32,
    size = UDim2.new(1, -90, 1, 0),
    position = UDim2.new(0, 85, 0, 0),
    xAlign = Enum.TextXAlignment.Left,
    gradient = {
        colors = {
            ColorSequenceKeypoint.new(0, THEME.accent.neon),
            ColorSequenceKeypoint.new(0.5, THEME.colors.white),
            ColorSequenceKeypoint.new(1, THEME.accent.neon),
        }
    },
    zIndex = 3
})

UI.createLabel(titleBar, {
    text = "v8.0 · PREMIUM",
    color = THEME.accent.light,
    font = Enum.Font.GothamBold,
    textSize = 12,
    size = UDim2.new(0, 140, 1, 0),
    position = UDim2.new(1, -150, 0, 0),
    xAlign = Enum.TextXAlignment.Right,
    transparency = 0.7,
    zIndex = 3
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

local container = UI.createFrame(frame, {
    transparency = 1,
    size = UDim2.new(1, 0, 1, -75),
    position = UDim2.new(0, 0, 0, 75),
    zIndex = 1
})

frame.Size = UDim2.new(0, 0, 0, 0)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
UI.animate(frame, {
    Size = UDim2.new(0, 700, 0, 600),
    Position = UDim2.new(0.5, -350, 0.5, -300)
}, 0.7, Enum.EasingStyle.Back)

-- ═══════════════════════════════════════════════════════════
--  ПАНЕЛИ
-- ═══════════════════════════════════════════════════════════

local leftPanel = UI.createFrame(container, {
    bg = THEME.colors.panel,
    transparency = 0.05,
    size = UDim2.new(0, 190, 1, 0),
    gradient = {
        colors = {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 10, 15)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 5, 8)),
        }
    },
    zIndex = 2
})

local rightPanel = UI.createFrame(container, {
    transparency = 1,
    size = UDim2.new(1, -190, 1, 0),
    position = UDim2.new(0, 190, 0, 0),
    zIndex = 2
})

-- ═══════════════════════════════════════════════════════════
--  ВКЛАДКИ
-- ═══════════════════════════════════════════════════════════

local tabs = {}
local tabContents = {}
local currentTab = nil

local function createTab(name, icon, order)
    local btn = UI.createButton(leftPanel, {
        bg = THEME.colors.card,
        transparency = 0.05,
        size = UDim2.new(1, -28, 0, 56),
        position = UDim2.new(0, 14, 0, 20 + (order - 1) * 62),
        corner = 15,
        stroke = {color = THEME.colors.border, thickness = 1},
        zIndex = 3
    })

    UI.createLabel(btn, {
        text = icon,
        color = THEME.accent.light,
        font = Enum.Font.GothamBold,
        textSize = 26,
        size = UDim2.new(0, 50, 1, 0),
        xAlign = Enum.TextXAlignment.Center,
        zIndex = 3
    })

    UI.createLabel(btn, {
        text = name,
        color = THEME.colors.text,
        font = Enum.Font.GothamBold,
        textSize = 15,
        size = UDim2.new(1, -54, 1, 0),
        position = UDim2.new(0, 54, 0, 0),
        xAlign = Enum.TextXAlignment.Left,
        zIndex = 3
    })

    tabs[name] = {button = btn}
    return btn
end

local function createTabContent(name)
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = THEME.accent.base
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
        UI.animate(tab.button, {BackgroundColor3 = THEME.colors.card, BackgroundTransparency = 0.05}, 0.3)
        tab.button.UIStroke.Color = THEME.colors.border
    end
    
    if tabs[name] then
        UI.animate(tabs[name].button, {BackgroundColor3 = THEME.accent.dark, BackgroundTransparency = 0}, 0.3)
        tabs[name].button.UIStroke.Color = THEME.accent.neon
    end
    
    for n, content in pairs(tabContents) do
        if n == name then
            content.Visible = true
            content.Position = UDim2.new(0, 70, 0, 0)
            UI.animate(content, {Position = UDim2.new(0, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back)
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
            UI.animate(tab.button, {BackgroundColor3 = THEME.colors.cardHov}, 0.2)
        end
    end)
    tab.button.MouseLeave:Connect(function()
        if not (currentTab == name) then
            UI.animate(tab.button, {BackgroundColor3 = THEME.colors.card, BackgroundTransparency = 0.05}, 0.2)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  UI КОМПОНЕНТЫ
-- ═══════════════════════════════════════════════════════════

local function sectionTitle(parent, order, text)
    UI.createLabel(parent, {
        text = text,
        color = THEME.accent.light,
        font = Enum.Font.GothamBold,
        textSize = 13,
        size = UDim2.new(1, 0, 0, 28),
        xAlign = Enum.TextXAlignment.Left,
        zIndex = 2
    }).LayoutOrder = order
end

local function statRow(parent, order, name)
    local row = UI.createFrame(parent, {
        bg = THEME.colors.card,
        transparency = 0.02,
        size = UDim2.new(1, 0, 0, 38),
        corner = 13,
        stroke = {color = THEME.colors.border, thickness = 1},
        zIndex = 2
    })
    row.LayoutOrder = order

    UI.createLabel(row, {
        text = name,
        color = THEME.colors.muted,
        font = Enum.Font.Gotham,
        textSize = 13,
        size = UDim2.new(0.6, 0, 1, 0),
        position = UDim2.new(0, 18, 0, 0),
        xAlign = Enum.TextXAlignment.Left,
        zIndex = 2
    })

    local v = UI.createLabel(row, {
        text = "0",
        color = THEME.accent.light,
        font = Enum.Font.GothamBold,
        textSize = 14,
        size = UDim2.new(0.4, -18, 1, 0),
        position = UDim2.new(0.6, 0, 0, 0),
        xAlign = Enum.TextXAlignment.Right,
        zIndex = 2
    })
    return v
end

local function toggleCard(parent, order, label, onToggle)
    local card = UI.createFrame(parent, {
        bg = THEME.colors.card,
        transparency = 0.02,
        size = UDim2.new(1, 0, 0, 54),
        corner = 15,
        stroke = {color = THEME.colors.border, thickness = 1},
        zIndex = 2
    })
    card.LayoutOrder = order

    UI.createLabel(card, {
        text = label,
        color = THEME.colors.text,
        font = Enum.Font.GothamBold,
        textSize = 15,
        size = UDim2.new(1, -120, 1, 0),
        position = UDim2.new(0, 22, 0, 0),
        xAlign = Enum.TextXAlignment.Left,
        zIndex = 2
    })

    local pill = UI.createFrame(card, {
        bg = THEME.colors.border,
        size = UDim2.new(0, 64, 0, 30),
        position = UDim2.new(1, -74, 0.5, -15),
        corner = 15,
        stroke = {color = THEME.colors.border, thickness = 1},
        zIndex = 2
    })

    local pl = UI.createLabel(pill, {
        text = "OFF",
        color = THEME.colors.muted,
        font = Enum.Font.GothamBold,
        textSize = 11,
        xAlign = Enum.TextXAlignment.Center,
        zIndex = 2
    })

    local btn = UI.createButton(card, {
        transparency = 1,
        size = UDim2.new(1, 0, 1, 0),
        zIndex = 3
    })

    local state = false

    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            UI.animate(card, {BackgroundColor3 = THEME.accent.dim}, 0.3)
            card.UIStroke.Color = THEME.accent.base
            UI.animate(pill, {BackgroundColor3 = THEME.accent.base}, 0.3)
            pill.UIStroke.Color = THEME.accent.neon
            pl.Text = "ON"
            UI.animate(pl, {TextColor3 = THEME.colors.white}, 0.3)
        else
            UI.animate(card, {BackgroundColor3 = THEME.colors.card}, 0.3)
            card.UIStroke.Color = THEME.colors.border
            UI.animate(pill, {BackgroundColor3 = THEME.colors.border}, 0.3)
            pill.UIStroke.Color = THEME.colors.border
            pl.Text = "OFF"
            UI.animate(pl, {TextColor3 = THEME.colors.muted}, 0.3)
        end
        if onToggle then onToggle(state) end
    end)

    btn.MouseEnter:Connect(function() if not state then UI.animate(card, {BackgroundColor3 = THEME.colors.cardHov}, 0.2) end end)
    btn.MouseLeave:Connect(function() if not state then UI.animate(card, {BackgroundColor3 = THEME.colors.card}, 0.2) end end)
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
    local card = UI.createFrame(farmContent, {
        bg = THEME.colors.card,
        transparency = 0.02,
        size = UDim2.new(1, 0, 0, 54),
        corner = 15,
        stroke = {color = THEME.colors.border, thickness = 1},
        zIndex = 2
    })
    card.LayoutOrder = 10

    UI.createLabel(card, {
        text = "🎯 Bag Limit:",
        color = THEME.colors.text,
        font = Enum.Font.GothamBold,
        textSize = 15,
        size = UDim2.new(1, -130, 1, 0),
        position = UDim2.new(0, 22, 0, 0),
        xAlign = Enum.TextXAlignment.Left,
        zIndex = 2
    })

    local pill = UI.createFrame(card, {
        bg = THEME.accent.base,
        size = UDim2.new(0, 85, 0, 34),
        position = UDim2.new(1, -95, 0.5, -17),
        corner = 13,
        stroke = {color = THEME.accent.neon, thickness = 1},
        zIndex = 2
    })

    local pillLabel = UI.createLabel(pill, {
        text = tostring(MAX_BAG) .. " 🪙",
        color = THEME.colors.white,
        font = Enum.Font.GothamBold,
        textSize = 15,
        xAlign = Enum.TextXAlignment.Center,
        zIndex = 2
    })

    local btn = UI.createButton(card, {
        transparency = 1,
        size = UDim2.new(1, 0, 1, 0),
        zIndex = 3
    })
    
    btn.MouseButton1Click:Connect(function()
        if MAX_BAG == 40 then MAX_BAG = 50 else MAX_BAG = 40 end
        pillLabel.Text = tostring(MAX_BAG) .. " 🪙"
        UI.animate(pill, {Size = UDim2.new(0, 95, 0, 38)}, 0.15)
        task.wait(0.15)
        UI.animate(pill, {Size = UDim2.new(0, 85, 0, 34)}, 0.15)
        notify("XDarkHUB", "🎯 Лимит: " .. MAX_BAG, 2)
    end)
end

-- Скорость
do
    local card = UI.createFrame(farmContent, {
        bg = THEME.colors.card,
        transparency = 0.02,
        size = UDim2.new(1, 0, 0, 54),
        corner = 15,
        stroke = {color = THEME.colors.border, thickness = 1},
        zIndex = 2
    })
    card.LayoutOrder = 11

    UI.createLabel(card, {
        text = "⚡ Farm Speed",
        color = THEME.colors.text,
        font = Enum.Font.GothamBold,
        textSize = 15,
        size = UDim2.new(1, -130, 1, 0),
        position = UDim2.new(0, 22, 0, 0),
        xAlign = Enum.TextXAlignment.Left,
        zIndex = 2
    })

    local pill = UI.createFrame(card, {
        bg = THEME.accent.dim,
        size = UDim2.new(0, 64, 0, 30),
        position = UDim2.new(1, -74, 0.5, -15),
        corner = 15,
        stroke = {color = THEME.accent.base, thickness = 1},
        zIndex = 2
    })

    local speedPillLbl = UI.createLabel(pill, {
        text = tostring(flySpeed),
        color = THEME.accent.light,
        font = Enum.Font.GothamBold,
        textSize = 13,
        xAlign = Enum.TextXAlignment.Center,
        zIndex = 2
    })

    local btn = UI.createButton(card, {
        transparency = 1,
        size = UDim2.new(1, 0, 1, 0),
        zIndex = 3
    })
    
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
    local btn = UI.createButton(farmContent, {
        bg = THEME.accent.base,
        text = "🚀 TEST FLING",
        textColor = THEME.colors.white,
        font = Enum.Font.GothamBlack,
        textSize = 16,
        size = UDim2.new(1, 0, 0, 56),
        corner = 15,
        stroke = {color = THEME.accent.neon, thickness = 2},
        gradient = {
            colors = {
                ColorSequenceKeypoint.new(0, THEME.accent.neon),
                ColorSequenceKeypoint.new(1, THEME.accent.dark),
            },
            rotation = 90
        },
        zIndex = 2
    })
    btn.LayoutOrder = 14
    
    btn.MouseEnter:Connect(function() UI.animate(btn, {BackgroundColor3 = THEME.accent.neon}, 0.2) end)
    btn.MouseLeave:Connect(function() UI.animate(btn, {BackgroundColor3 = THEME.accent.base}, 0.2) end)
    btn.MouseButton1Click:Connect(function()
        notify("XDarkHUB", "🔍 Запускаю тест флинга...", 2)
        throwMurdererToSpace()
    end)
end

-- Reset
do
    local btn = UI.createButton(farmContent, {
        bg = THEME.colors.card,
        transparency = 0.02,
        text = "🔄 Reset & Resume",
        textColor = THEME.accent.light,
        font = Enum.Font.GothamBold,
        textSize = 15,
        size = UDim2.new(1, 0, 0, 48),
        corner = 15,
        stroke = {color = THEME.accent.base, thickness = 1},
        zIndex = 2
    })
    btn.LayoutOrder = 15
    
    btn.MouseEnter:Connect(function() UI.animate(btn, {BackgroundColor3 = THEME.colors.cardHov}, 0.2) end)
    btn.MouseLeave:Connect(function() UI.animate(btn, {BackgroundColor3 = THEME.colors.card}, 0.2) end)
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
    
    UI.createLabel(content, {
        text = name == "Sheriff" and "⭐ SHERIFF" or name == "Murderer" and "🔪 MURDERER" or "🎯 PLAYER",
        color = THEME.accent.light,
        font = Enum.Font.GothamBlack,
        textSize = 24,
        size = UDim2.new(1, 0, 0, 60),
        xAlign = Enum.TextXAlignment.Left,
        zIndex = 2
    }).LayoutOrder = 1
    
    local card = UI.createFrame(content, {
        bg = THEME.colors.card,
        transparency = 0.02,
        size = UDim2.new(1, 0, 0, 160),
        corner = 18,
        stroke = {color = THEME.colors.border, thickness = 1},
        zIndex = 2
    })
    card.LayoutOrder = 2
    
    UI.createLabel(card, {
        text = "🚧 Coming Soon...\n\nЭта функция будет добавлена в следующей версии.",
        color = THEME.colors.muted,
        font = Enum.Font.Gotham,
        textSize = 15,
        size = UDim2.new(1, -30, 1, 0),
        position = UDim2.new(0, 15, 0, 0),
        xAlign = Enum.TextXAlignment.Left,
        yAlign = Enum.TextYAlignment.Top,
        zIndex = 2
    })
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
        bagVal.TextColor3 = THEME.accent.light
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
    flash.Color = THEME.accent.neon
    flash.Transparency = 0.3
    flash.Parent = workspace
    Debris:AddItem(flash, 4)
    
    local light = Instance.new("PointLight")
    light.Brightness = 35
    light.Range = 80
    light.Color = THEME.accent.neon
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

-- Кнопка меню
local menuButton = UI.createButton(gui, {
    bg = THEME.accent.base,
    text = "X",
    textColor = THEME.colors.white,
    font = Enum.Font.GothamBlack,
    textSize = 44,
    size = UDim2.new(0, 80, 0, 80),
    position = UDim2.new(0, 25, 1, -105),
    corner = 40,
    stroke = {color = THEME.accent.neon, thickness = 3, transparency = 0.4},
    gradient = {
        colors = {
            ColorSequenceKeypoint.new(0, THEME.accent.neon),
            ColorSequenceKeypoint.new(1, THEME.accent.dark),
        },
        rotation = 45
    },
    zIndex = 10
})

task.spawn(function()
    while menuButton.Parent do
        UI.animate(menuButton, {Size = UDim2.new(0, 85, 0, 85)}, 1.2, Enum.EasingStyle.Sine)
        task.wait(1.2)
        UI.animate(menuButton, {Size = UDim2.new(0, 80, 0, 80)}, 1.2, Enum.EasingStyle.Sine)
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

menuButton.MouseButton1Click:Connect(function()
    local isVisible = frame.Visible
    frame.Visible = not isVisible
    bgFrame.Visible = not isVisible
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

notify("XDarkHUB", "✅ v8.0 OPTIMIZED загружен!", 3)
notify("XDarkHUB", "🎨 Оптимизированный UI", 3)
notify("XDarkHUB", "🚀 Классический флинг!", 4)
