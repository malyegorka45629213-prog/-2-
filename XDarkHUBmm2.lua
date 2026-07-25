-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                         XDarkHUB v17 · BODY FLING                          ║
-- ║   ПЕРСОНАЖ РАСКРУЧИВАЕТСЯ И ВЫКИДЫВАЕТ МАРДЕРА ТЕЛОМ                       ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Debris = game:GetService("Debris")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local visitedPositions = {}
local isActive = false
local flySpeed = 16
local collected = 0
local initialCoins = 0
local startTime = 0
local antiAFK = false
local isMurderer = false
local isSheriff = false
local bagFull = false
local farmStopped = false
local espEnabled = false
local espHighlights = {}
local MAX_BAG = 40

-- ═══════════════════════════════════════════════════════════════════════════════
--  ЗВУКИ
-- ═══════════════════════════════════════════════════════════════════════════════
local collectSound = Instance.new("Sound")
collectSound.SoundId = "rbxassetid://12221967"
collectSound.Volume = 1

local killSound = Instance.new("Sound")
killSound.SoundId = "rbxassetid://9120392731"
killSound.Volume = 0.8

local deathSound = Instance.new("Sound")
deathSound.SoundId = "rbxassetid://9120392731"
deathSound.Volume = 0.6

local clickSnd = Instance.new("Sound")
clickSnd.SoundId = "rbxassetid://169759176"
clickSnd.Volume = 0.25

-- ═══════════════════════════════════════════════════════════════════════════════
--  УВЕДОМЛЕНИЯ
-- ═══════════════════════════════════════════════════════════════════════════════
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = duration or 3
        })
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  РОЛИ
-- ═══════════════════════════════════════════════════════════════════════════════
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
        end
    end
    return "Innocent"
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  УМНАЯ СИСТЕМА МОНЕТ
-- ═══════════════════════════════════════════════════════════════════════════════
local function getPlayerCoins(p)
    local ls = p:FindFirstChild("leaderstats")
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name:find("coin") or name:find("money") or name:find("cash") or name:find("gold") then
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

local function getCollectedCoins()
    local currentCoins = getPlayerCoins(player)
    return currentCoins - initialCoins
end

local function checkRole()
    local r = getPlayerRole(player)
    isMurderer = (r == "Murderer")
    isSheriff = (r == "Sheriff")
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ЦВЕТА
-- ═══════════════════════════════════════════════════════════════════════════════
local C = {
    bg = Color3.fromRGB(8, 8, 12),
    panel = Color3.fromRGB(12, 12, 18),
    card = Color3.fromRGB(18, 18, 26),
    hov = Color3.fromRGB(26, 26, 36),
    bdr = Color3.fromRGB(40, 40, 52),
    txt = Color3.fromRGB(245, 245, 255),
    mut = Color3.fromRGB(100, 100, 115),
    wht = Color3.fromRGB(255, 255, 255),
    dim = Color3.fromRGB(65, 65, 80),
}

local A = {
    base = Color3.fromRGB(235, 35, 60),
    dim = Color3.fromRGB(65, 12, 24),
    lit = Color3.fromRGB(255, 90, 115),
    neo = Color3.fromRGB(255, 35, 62),
    soft = Color3.fromRGB(190, 45, 70),
}

-- ═══════════════════════════════════════════════════════════════════════════════
--  UI HELPERS
-- ═══════════════════════════════════════════════════════════════════════════════
local function crn(o, r)
    local c = Instance.new("UICorner", o)
    c.CornerRadius = UDim.new(0, r or 8)
end

local function stk(o, c, t, tr)
    local s = Instance.new("UIStroke", o)
    s.Color = c
    s.Thickness = t or 1
    s.Transparency = tr or 0
end

local function grd(o, cs, rot)
    local g = Instance.new("UIGradient", o)
    g.Color = ColorSequence.new(cs)
    g.Rotation = rot or 0
end

local function ani(o, p, t, s)
    TweenService:Create(o, TweenInfo.new(t or 0.25, s or Enum.EasingStyle.Quint), p):Play()
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ОЧИСТКА + GUI
-- ═══════════════════════════════════════════════════════════════════════════════
do
    local old = player:WaitForChild("PlayerGui"):FindFirstChild("AutoFarmGui")
    if old then old:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")
collectSound.Parent = gui
killSound.Parent = gui
deathSound.Parent = gui
clickSnd.Parent = gui

-- ═══════════════════════════════════════════════════════════════════════════════
--  ФОН С ЧАСТИЦАМИ
-- ═══════════════════════════════════════════════════════════════════════════════
local bgF = Instance.new("Frame")
bgF.Size = UDim2.new(1, 0, 1, 0)
bgF.BackgroundColor3 = C.bg
bgF.BackgroundTransparency = 0.08
bgF.BorderSizePixel = 0
bgF.ZIndex = 0
bgF.Parent = gui
crn(bgF, 0)
grd(bgF, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 4, 14)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 8, 12)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 4, 10)),
}, 45)

task.spawn(function()
    local rotation = 0
    while bgF.Parent do
        rotation = rotation + 0.15
        bgF.UIGradient.Rotation = rotation
        task.wait(0.05)
    end
end)

local pCols = {A.base, A.neo, A.lit, Color3.fromRGB(255, 20, 40), Color3.fromRGB(255, 115, 135)}
for i = 1, 28 do
    local sz = math.random(2, 11)
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, sz, 0, sz)
    p.Position = UDim2.new(math.random(), 0, math.random(), 0)
    p.BackgroundColor3 = pCols[math.random(1, #pCols)]
    p.BackgroundTransparency = math.random(45, 82) / 100
    p.BorderSizePixel = 0
    p.ZIndex = 0
    p.Parent = bgF
    crn(p, math.random(1, 5))
    
    task.spawn(function()
        while p.Parent do
            local d = math.random(16, 36)
            ani(p, {
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                BackgroundTransparency = math.random(35, 82) / 100
            }, d, Enum.EasingStyle.Sine)
            task.wait(d)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ГЛАВНЫЙ ФРЕЙМ
-- ═══════════════════════════════════════════════════════════════════════════════
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 640, 0, 540)
frame.Position = UDim2.new(0.5, -320, 0.5, -270)
frame.BackgroundColor3 = C.bg
frame.BackgroundTransparency = 0.03
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.ZIndex = 1
frame.Parent = gui
crn(frame, 10)
stk(frame, A.base, 1.5, 0.4)

local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, 0, 0, 2)
topLine.BackgroundColor3 = A.neo
topLine.BackgroundTransparency = 0.15
topLine.BorderSizePixel = 0
topLine.ZIndex = 3
topLine.Parent = frame
crn(topLine, 1)

frame.Size = UDim2.new(0, 0, 0, 0)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
ani(frame, {
    Size = UDim2.new(0, 640, 0, 540),
    Position = UDim2.new(0.5, -320, 0.5, -270)
}, 0.6, Enum.EasingStyle.Back)

-- ═══════════════════════════════════════════════════════════════════════════════
--  ЗАГОЛОВОК
-- ═══════════════════════════════════════════════════════════════════════════════
local tBar = Instance.new("Frame")
tBar.Size = UDim2.new(1, 0, 0, 54)
tBar.BackgroundColor3 = C.panel
tBar.BackgroundTransparency = 0.04
tBar.BorderSizePixel = 0
tBar.Active = true
tBar.ZIndex = 2
tBar.Parent = frame
crn(tBar, 10)
grd(tBar, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 14, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 10, 16)),
})

local logo = Instance.new("Frame")
logo.Size = UDim2.new(0, 36, 0, 36)
logo.Position = UDim2.new(0, 14, 0.5, -18)
logo.BackgroundColor3 = A.base
logo.BorderSizePixel = 0
logo.ZIndex = 3
logo.Parent = tBar
crn(logo, 10)
stk(logo, A.neo, 1.5, 0.3)

local logoX = Instance.new("TextLabel")
logoX.Size = UDim2.new(1, 0, 1, 0)
logoX.BackgroundTransparency = 1
logoX.Text = "X"
logoX.Font = Enum.Font.GothamBlack
logoX.TextSize = 22
logoX.TextColor3 = C.wht
logoX.ZIndex = 4
logoX.Parent = logo

local tLbl = Instance.new("TextLabel")
tLbl.Size = UDim2.new(1, -140, 1, 0)
tLbl.Position = UDim2.new(0, 60, 0, 0)
tLbl.BackgroundTransparency = 1
tLbl.Text = "XDARKHUB"
tLbl.Font = Enum.Font.GothamBlack
tLbl.TextSize = 20
tLbl.TextColor3 = A.lit
tLbl.TextXAlignment = Enum.TextXAlignment.Left
tLbl.ZIndex = 3
tLbl.Parent = tBar
tLbl.TextStrokeTransparency = 0.8
tLbl.TextStrokeColor3 = Color3.fromRGB(38, 8, 16)

local sep1 = Instance.new("Frame")
sep1.Size = UDim2.new(0, 1, 0, 24)
sep1.Position = UDim2.new(0, 56, 0.5, -12)
sep1.BackgroundColor3 = A.base
sep1.BackgroundTransparency = 0.5
sep1.BorderSizePixel = 0
sep1.ZIndex = 3
sep1.Parent = tBar

local vLbl = Instance.new("TextLabel")
vLbl.Size = UDim2.new(0, 60, 1, 0)
vLbl.Position = UDim2.new(1, -70, 0, 0)
vLbl.BackgroundTransparency = 1
vLbl.Text = "[v17]"
vLbl.Font = Enum.Font.Code
vLbl.TextSize = 11
vLbl.TextColor3 = C.mut
vLbl.TextXAlignment = Enum.TextXAlignment.Right
vLbl.ZIndex = 3
vLbl.Parent = tBar

do
    local dr, ds, sp = false, nil, nil
    tBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dr = true; ds = i.Position; sp = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dr = false end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  КОНТЕЙНЕР
-- ═══════════════════════════════════════════════════════════════════════════════
local ctr = Instance.new("Frame")
ctr.Size = UDim2.new(1, 0, 1, -56)
ctr.Position = UDim2.new(0, 0, 0, 56)
ctr.BackgroundTransparency = 1
ctr.Parent = frame

local lPan = Instance.new("Frame")
lPan.Size = UDim2.new(0, 170, 1, 0)
lPan.BackgroundColor3 = C.panel
lPan.BackgroundTransparency = 0.04
lPan.BorderSizePixel = 0
lPan.ZIndex = 2
lPan.Parent = ctr

local vLine = Instance.new("Frame")
vLine.Size = UDim2.new(0, 1, 1, 0)
vLine.Position = UDim2.new(0, 170, 0, 0)
vLine.BackgroundColor3 = A.base
vLine.BackgroundTransparency = 0.65
vLine.BorderSizePixel = 0
vLine.ZIndex = 3
vLine.Parent = ctr

local rPan = Instance.new("Frame")
rPan.Size = UDim2.new(1, -172, 1, 0)
rPan.Position = UDim2.new(0, 172, 0, 0)
rPan.BackgroundTransparency = 1
rPan.ZIndex = 2
rPan.Parent = ctr

-- ═══════════════════════════════════════════════════════════════════════════════
--  ВКЛАДКИ
-- ═══════════════════════════════════════════════════════════════════════════════
local tabs = {}
local tabContents = {}
local currentTab = nil

local function createTab(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 48)
    btn.Position = UDim2.new(0, 10, 0, 14 + (order - 1) * 54)
    btn.BackgroundColor3 = C.card
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.ZIndex = 5
    btn.Active = true
    btn.AutoButtonColor = false
    btn.Parent = lPan
    crn(btn, 10)
    
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 3, 0, 26)
    ind.Position = UDim2.new(0, 0, 0.5, -13)
    ind.BackgroundColor3 = A.base
    ind.BackgroundTransparency = 1
    ind.BorderSizePixel = 0
    ind.ZIndex = 6
    ind.Parent = btn
    crn(ind, 2)
    
    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(0, 36, 1, 0)
    ic.Position = UDim2.new(0, 14, 0, 0)
    ic.BackgroundTransparency = 1
    ic.Text = icon
    ic.Font = Enum.Font.GothamBold
    ic.TextSize = 20
    ic.TextColor3 = C.mut
    ic.ZIndex = 6
    ic.Parent = btn
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -56, 1, 0)
    lbl.Position = UDim2.new(0, 50, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextColor3 = C.mut
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6
    lbl.Parent = btn
    
    tabs[name] = {btn = btn, ic = ic, ind = ind, lbl = lbl}
    
    btn.MouseEnter:Connect(function()
        if currentTab ~= name then
            ani(btn, {BackgroundTransparency = 0.7}, 0.15)
            ani(ic, {TextColor3 = C.txt}, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= name then
            ani(btn, {BackgroundTransparency = 1}, 0.15)
            ani(ic, {TextColor3 = C.mut}, 0.15)
        end
    end)
    
    return btn
end

local function createTabContent(name)
    local c = Instance.new("ScrollingFrame")
    c.Size = UDim2.new(1, 0, 1, 0)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = 3
    c.ScrollBarImageColor3 = A.base
    c.CanvasSize = UDim2.new(0, 0, 0, 0)
    c.AutomaticCanvasSize = Enum.AutomaticSize.Y
    c.Visible = false
    c.ZIndex = 2
    c.Parent = rPan
    
    local p = Instance.new("UIPadding", c)
    p.PaddingLeft = UDim.new(0, 20)
    p.PaddingRight = UDim.new(0, 20)
    p.PaddingTop = UDim.new(0, 18)
    p.PaddingBottom = UDim.new(0, 18)
    
    local l = Instance.new("UIListLayout", c)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 10)
    
    tabContents[name] = c
end

local function switchTab(name)
    for n, t in pairs(tabs) do
        t.btn.BackgroundTransparency = 1
        t.btn.BackgroundColor3 = C.card
        t.ic.TextColor3 = C.mut
        t.lbl.TextColor3 = C.mut
        t.ind.BackgroundTransparency = 1
    end
    
    if tabs[name] then
        tabs[name].btn.BackgroundTransparency = 0.65
        tabs[name].btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        tabs[name].ic.TextColor3 = A.neo
        tabs[name].lbl.TextColor3 = C.wht
        tabs[name].ind.BackgroundTransparency = 0
        tabs[name].ind.BackgroundColor3 = A.neo
    end
    
    for n, c in pairs(tabContents) do
        if n == name then
            c.Visible = true
            c.Position = UDim2.new(0, 40, 0, 0)
            ani(c, {Position = UDim2.new(0, 0, 0, 0)}, 0.35, Enum.EasingStyle.Back)
        else
            c.Visible = false
        end
    end
    
    currentTab = name
end

createTab("Sheriff", "⭐", 1)
createTab("Murderer", "🔪", 2)
createTab("ESP", "👁️", 3)
createTab("Player", "🎯", 4)
createTab("Farm", "⚙️", 5)

for n in pairs(tabs) do
    createTabContent(n)
end

for n, t in pairs(tabs) do
    t.btn.MouseButton1Click:Connect(function()
        clickSnd:Play()
        switchTab(n)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  UI КОМПОНЕНТЫ
-- ═══════════════════════════════════════════════════════════════════════════════
local function secT(par, ord, txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 24)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = A.soft
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = ord
    l.ZIndex = 2
    l.Parent = par
    
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1, 0, 0, 1)
    ln.BackgroundColor3 = A.base
    ln.BackgroundTransparency = 0.82
    ln.BorderSizePixel = 0
    ln.LayoutOrder = ord + 0.1
    ln.ZIndex = 2
    ln.Parent = par
end

local function statR(par, ord, name)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(1, 0, 0, 36)
    r.BackgroundTransparency = 1
    r.LayoutOrder = ord
    r.ZIndex = 2
    r.Parent = par
    
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1, 0, 0, 1)
    ln.Position = UDim2.new(0, 0, 1, 0)
    ln.BackgroundColor3 = C.bdr
    ln.BackgroundTransparency = 0.65
    ln.BorderSizePixel = 0
    ln.ZIndex = 2
    ln.Parent = r
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 5, 0, 5)
    dot.Position = UDim2.new(0, 0, 0.5, -2.5)
    dot.BackgroundColor3 = A.base
    dot.BorderSizePixel = 0
    dot.ZIndex = 2
    dot.Parent = r
    crn(dot, 3)
    
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0.6, 0, 1, 0)
    n.Position = UDim2.new(0, 16, 0, 0)
    n.BackgroundTransparency = 1
    n.Text = name
    n.TextColor3 = C.mut
    n.Font = Enum.Font.Gotham
    n.TextSize = 13
    n.TextXAlignment = Enum.TextXAlignment.Left
    n.ZIndex = 2
    n.Parent = r
    
    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(0.4, -16, 1, 0)
    v.Position = UDim2.new(0.6, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text = "0"
    v.TextColor3 = A.lit
    v.Font = Enum.Font.GothamBold
    v.TextSize = 14
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.ZIndex = 2
    v.Parent = r
    
    return v
end

local function togC(par, ord, label, onTog)
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(1, 0, 0, 48)
    cd.BackgroundTransparency = 1
    cd.LayoutOrder = ord
    cd.ZIndex = 2
    cd.Parent = par
    
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1, 0, 0, 1)
    ln.Position = UDim2.new(0, 0, 1, 0)
    ln.BackgroundColor3 = C.bdr
    ln.BackgroundTransparency = 0.65
    ln.BorderSizePixel = 0
    ln.ZIndex = 2
    ln.Parent = cd
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -100, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.txt
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 2
    lbl.Parent = cd
    
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 54, 0, 28)
    sw.Position = UDim2.new(1, -62, 0.5, -14)
    sw.BackgroundColor3 = C.bdr
    sw.BorderSizePixel = 0
    sw.ZIndex = 2
    sw.Parent = cd
    crn(sw, 14)
    stk(sw, Color3.fromRGB(55, 55, 70), 1)
    
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 18, 0, 18)
    ind.Position = UDim2.new(0, 5, 0.5, -9)
    ind.BackgroundColor3 = C.mut
    ind.BorderSizePixel = 0
    ind.ZIndex = 2
    ind.Parent = sw
    crn(ind, 9)
    
    local pl = Instance.new("TextLabel")
    pl.Size = UDim2.new(1, 0, 1, 0)
    pl.Position = UDim2.new(0, 26, 0, 0)
    pl.BackgroundTransparency = 1
    pl.Text = "OFF"
    pl.TextColor3 = C.mut
    pl.Font = Enum.Font.GothamBold
    pl.TextSize = 10
    pl.TextXAlignment = Enum.TextXAlignment.Left
    pl.ZIndex = 2
    pl.Parent = sw
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 3
    btn.Active = true
    btn.Parent = cd
    
    local st = false
    
    btn.MouseButton1Click:Connect(function()
        clickSnd:Play()
        st = not st
        if st then
            ani(sw, {BackgroundColor3 = A.dim}, 0.2)
            sw.UIStroke.Color = A.base
            ani(ind, {Position = UDim2.new(0, 31, 0.5, -9), BackgroundColor3 = A.neo}, 0.25, Enum.EasingStyle.Back)
            pl.Text = "ON"
            ani(pl, {TextColor3 = A.lit}, 0.2)
            ani(cd, {BackgroundColor3 = Color3.fromRGB(20, 16, 22), BackgroundTransparency = 0.5}, 0.2)
        else
            ani(sw, {BackgroundColor3 = C.bdr}, 0.2)
            sw.UIStroke.Color = Color3.fromRGB(55, 55, 70)
            ani(ind, {Position = UDim2.new(0, 5, 0.5, -9), BackgroundColor3 = C.mut}, 0.25, Enum.EasingStyle.Back)
            pl.Text = "OFF"
            ani(pl, {TextColor3 = C.mut}, 0.2)
            cd.BackgroundTransparency = 1
        end
        if onTog then onTog(st) end
    end)
    
    btn.MouseEnter:Connect(function()
        if not st then ani(cd, {BackgroundColor3 = Color3.fromRGB(18, 18, 24), BackgroundTransparency = 0.5}, 0.15) end
    end)
    btn.MouseLeave:Connect(function()
        if not st then cd.BackgroundTransparency = 1 end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  КОНТЕНТ ВКЛАДОК
-- ═══════════════════════════════════════════════════════════════════════════════
local espC = tabContents["ESP"]
secT(espC, 1, "VISUAL")
togC(espC, 2, "ESP Roles", function(s)
    espEnabled = s
    updateESP()
    notify("XDarkHUB", "ESP: " .. (s and "ON" or "OFF"), 2)
end)

local fC = tabContents["Farm"]
secT(fC, 1, "STATS")
local counterV = statR(fC, 2, "Coins")
local timerV = statR(fC, 3, "Time")
local rateV = statR(fC, 4, "Rate")
local pCoinV = statR(fC, 5, "Total")
secT(fC, 6, "ROLE")
local roleV = statR(fC, 7, "Status")
secT(fC, 8, "BAG")
local bagV = statR(fC, 9, "State")

do
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(1, 0, 0, 44)
    cd.BackgroundTransparency = 1
    cd.LayoutOrder = 10
    cd.ZIndex = 2
    cd.Parent = fC
    
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1, 0, 0, 1)
    ln.Position = UDim2.new(0, 0, 1, 0)
    ln.BackgroundColor3 = C.bdr
    ln.BackgroundTransparency = 0.65
    ln.BorderSizePixel = 0
    ln.ZIndex = 2
    ln.Parent = cd
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -100, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Limit"
    lbl.TextColor3 = C.txt
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 2
    lbl.Parent = cd
    
    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 72, 0, 30)
    pill.Position = UDim2.new(1, -80, 0.5, -15)
    pill.BackgroundColor3 = A.base
    pill.BorderSizePixel = 0
    pill.ZIndex = 2
    pill.Parent = cd
    crn(pill, 10)
    stk(pill, A.neo, 1)
    
    local pL = Instance.new("TextLabel")
    pL.Size = UDim2.new(1, 0, 1, 0)
    pL.BackgroundTransparency = 1
    pL.Text = MAX_BAG
    pL.TextColor3 = C.wht
    pL.Font = Enum.Font.GothamBold
    pL.TextSize = 14
    pL.ZIndex = 2
    pL.Parent = pill
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 3
    btn.Active = true
    btn.Parent = cd
    
    btn.MouseButton1Click:Connect(function()
        clickSnd:Play()
        if MAX_BAG == 40 then MAX_BAG = 50 else MAX_BAG = 40 end
        pL.Text = MAX_BAG
        ani(pill, {Size = UDim2.new(0, 80, 0, 34)}, 0.12)
        task.wait(0.12)
        ani(pill, {Size = UDim2.new(0, 72, 0, 30)}, 0.12)
    end)
end

do
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(1, 0, 0, 44)
    cd.BackgroundTransparency = 1
    cd.LayoutOrder = 11
    cd.ZIndex = 2
    cd.Parent = fC
    
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1, 0, 0, 1)
    ln.Position = UDim2.new(0, 0, 1, 0)
    ln.BackgroundColor3 = C.bdr
    ln.BackgroundTransparency = 0.65
    ln.BorderSizePixel = 0
    ln.ZIndex = 2
    ln.Parent = cd
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -100, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Speed"
    lbl.TextColor3 = C.txt
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 2
    lbl.Parent = cd
    
    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 62, 0, 28)
    pill.Position = UDim2.new(1, -70, 0.5, -14)
    pill.BackgroundColor3 = C.bdr
    pill.BorderSizePixel = 0
    pill.ZIndex = 2
    pill.Parent = cd
    crn(pill, 10)
    stk(pill, A.base, 1)
    
    local sL = Instance.new("TextLabel")
    sL.Size = UDim2.new(1, 0, 1, 0)
    sL.BackgroundTransparency = 1
    sL.Text = tostring(flySpeed)
    sL.TextColor3 = A.lit
    sL.Font = Enum.Font.GothamBold
    sL.TextSize = 13
    sL.ZIndex = 2
    sL.Parent = pill
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 3
    btn.Active = true
    btn.Parent = cd
    
    btn.MouseButton1Click:Connect(function()
        clickSnd:Play()
        flySpeed = flySpeed + 5
        if flySpeed > 50 then flySpeed = 10 end
        sL.Text = tostring(flySpeed)
    end)
end

togC(fC, 12, "Auto Farm", function(s)
    isActive = s
    if s then
        startFarming()
        notify("XDarkHUB", "Farm ON", 2)
    else
        notify("XDarkHUB", "Farm OFF", 2)
    end
end)

togC(fC, 13, "Anti-AFK", function(s)
    antiAFK = s
end)

do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 48)
    b.BackgroundColor3 = A.base
    b.Text = "FLING"
    b.TextColor3 = C.wht
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 15
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.LayoutOrder = 14
    b.ZIndex = 2
    b.Active = true
    b.Parent = fC
    crn(b, 10)
    stk(b, A.neo, 1.5)
    
    b.MouseEnter:Connect(function() ani(b, {BackgroundColor3 = A.neo}, 0.15) end)
    b.MouseLeave:Connect(function() ani(b, {BackgroundColor3 = A.base}, 0.15) end)
    b.MouseButton1Click:Connect(function()
        clickSnd:Play()
        throwMurdererToSpace()
    end)
end

do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = C.card
    b.BackgroundTransparency = 1
    b.Text = "RESET"
    b.TextColor3 = A.soft
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.LayoutOrder = 15
    b.ZIndex = 2
    b.Active = true
    b.Parent = fC
    crn(b, 10)
    stk(b, A.base, 1, 0.5)
    
    b.MouseEnter:Connect(function() ani(b, {BackgroundColor3 = Color3.fromRGB(20, 16, 22), BackgroundTransparency = 0.5}, 0.15) end)
    b.MouseLeave:Connect(function() b.BackgroundTransparency = 1 end)
    b.MouseButton1Click:Connect(function()
        clickSnd:Play()
        initialCoins = getPlayerCoins(player)
        startTime = tick()
        counterV.Text = "0"
        timerV.Text = "0s"
        rateV.Text = "0"
        bagFull = false
        farmStopped = false
        visitedPositions = {}
        updateBagUI()
    end)
end

for _, name in ipairs({"Sheriff", "Murderer", "Player"}) do
    local c = tabContents[name]
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 32)
    t.BackgroundTransparency = 1
    t.Text = name:upper()
    t.TextColor3 = A.soft
    t.Font = Enum.Font.GothamBlack
    t.TextSize = 18
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.LayoutOrder = 1
    t.ZIndex = 2
    t.Parent = c
    
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(1, 0, 0, 110)
    cd.BackgroundTransparency = 1
    cd.LayoutOrder = 2
    cd.ZIndex = 2
    cd.Parent = c
    crn(cd, 10)
    stk(cd, C.bdr, 1, 0.5)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Coming Soon"
    lbl.TextColor3 = C.mut
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 2
    lbl.Parent = cd
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ФУНКЦИИ UI
-- ═══════════════════════════════════════════════════════════════════════════════
function updateRoleUI()
    checkRole()
    if isMurderer then
        roleV.Text = "Murderer"
        roleV.TextColor3 = Color3.fromRGB(255, 50, 50)
    elseif isSheriff then
        roleV.Text = "Sheriff"
        roleV.TextColor3 = Color3.fromRGB(50, 150, 255)
    else
        roleV.Text = "Innocent"
        roleV.TextColor3 = Color3.fromRGB(50, 255, 50)
    end
end

function updateBagUI()
    local collectedCoins = getCollectedCoins()
    if farmStopped then
        bagV.Text = "Stopped"
        bagV.TextColor3 = Color3.fromRGB(255, 80, 80)
    elseif collectedCoins >= MAX_BAG then
        bagV.Text = "Full"
        bagV.TextColor3 = Color3.fromRGB(255, 200, 0)
    else
        bagV.Text = collectedCoins .. "/" .. MAX_BAG
        bagV.TextColor3 = A.lit
    end
end

function stopFarming()
    farmStopped = true
    updateBagUI()
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  🔪 УБИЙЦА УБИВАЕТ ВСЕХ
-- ═══════════════════════════════════════════════════════════════════════════════
function cinematicMurdererKill()
    notify("XDarkHUB", "Kill All", 3)
    killSound:Play()
    
    character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    local k = character:FindFirstChild("Knife") or character:FindFirstChild("MurdererSword")
    if not k then
        k = player:FindFirstChild("Backpack") and (player.Backpack:FindFirstChild("Knife") or player.Backpack:FindFirstChild("MurdererSword"))
    end
    if not k then
        k = Instance.new("Tool")
        k.Name = "Knife"
        k.RequiresHandle = false
        k.Parent = player:FindFirstChild("Backpack") or player
    end
    
    hum:EquipTool(k)
    task.wait(0.3)
    
    local tgts = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            table.insert(tgts, p)
        end
    end
    
    local myLook = hrp.CFrame.LookVector
    local myRight = hrp.CFrame.RightVector
    
    for i, p in ipairs(tgts) do
        local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")
        local targetHum = p.Character:FindFirstChild("Humanoid")
        if targetHrp and targetHum then
            local distance = 5
            local spread = (i - (#tgts + 1) / 2) * 2.5
            local newPos = hrp.Position + myLook * distance + myRight * spread
            targetHrp.CFrame = CFrame.new(newPos, hrp.Position)
            targetHum.PlatformStand = true
            targetHum.WalkSpeed = 0
            targetHum.JumpPower = 0
            targetHum.AutoRotate = false
            for _, pt in ipairs(p.Character:GetDescendants()) do
                if pt:IsA("BasePart") then pt.CanCollide = false end
            end
        end
    end
    
    local flash = Instance.new("Part")
    flash.Size = Vector3.new(30, 30, 30)
    flash.Position = hrp.Position
    flash.Anchored = true
    flash.CanCollide = false
    flash.Material = Enum.Material.Neon
    flash.Color = A.neo
    flash.Transparency = 0.3
    flash.Parent = workspace
    Debris:AddItem(flash, 3)
    
    local light = Instance.new("PointLight")
    light.Brightness = 30
    light.Range = 60
    light.Color = A.neo
    light.Parent = flash
    
    task.wait(0.5)
    
    for i, p in ipairs(tgts) do
        if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, -1.5)
                task.wait(0.12)
                if k and k.Parent == character then k:Activate() end
                task.wait(0.05)
                if p.Character:FindFirstChild("Humanoid") then
                    p.Character.Humanoid:TakeDamage(100)
                end
                local hit = Instance.new("Part")
                hit.Size = Vector3.new(2, 2, 2)
                hit.Position = targetHrp.Position
                hit.Anchored = true
                hit.CanCollide = false
                hit.Material = Enum.Material.Neon
                hit.Color = A.neo
                hit.Transparency = 0.3
                hit.Parent = workspace
                Debris:AddItem(hit, 0.5)
                notify("XDarkHUB", i .. "/" .. #tgts, 1)
            end
        end
    end
    
    task.wait(0.3)
    initialCoins = getPlayerCoins(player)
    counterV.Text = "0"
    notify("XDarkHUB", "Done", 2)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  🚀 BODY FLING - ПЕРСОНАЖ РАСКРУЧИВАЕТСЯ И ВЫКИДЫВАЕТ МАРДЕРА
-- ═══════════════════════════════════════════════════════════════════════════════
function throwMurdererToSpace()
    notify("XDarkHUB", "Body Fling Start", 3)
    deathSound:Play()
    
    -- Поиск мардера
    local mp = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and getPlayerRole(p) == "Murderer" then
            mp = p
            break
        end
    end
    
    if not mp or not mp.Character then
        notify("XDarkHUB", "Not Found", 2)
        return
    end
    
    local mh = mp.Character:FindFirstChild("HumanoidRootPart")
    if not mh then return end
    
    notify("XDarkHUB", mp.Name, 2)
    
    -- Отключение управления мардеру
    local mhu = mp.Character:FindFirstChild("Humanoid")
    if mhu then
        mhu.PlatformStand = true
        mhu.WalkSpeed = 0
        mhu.JumpPower = 0
        mhu.AutoRotate = false
    end
    
    -- Отключение коллизий мардера
    for _, pt in ipairs(mp.Character:GetDescendants()) do
        if pt:IsA("BasePart") then pt.CanCollide = false end
    end
    
    character = player.Character
    rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return end
    
    local startPos = rootPart.Position
    local radius = 4
    local totalCycles = 15  -- Количество циклов раскрутки
    
    -- 🔥 ЦИКЛ РАСКРУТКИ И ВЫКИДЫВАНИЯ
    for cycle = 1, totalCycles do
        if not mh.Parent or not rootPart.Parent then break end
        
        -- 🔥 БЫСТРАЯ РАСКРУТКА ВОКРУГ МАРДЕРА
        local spins = 20  -- Обороты за цикл
        for i = 1, spins do
            if not mh.Parent or not rootPart.Parent then break end
            
            local angle = math.rad(i * 36)
            local height = i * 0.5
            
            local offset = Vector3.new(
                math.cos(angle) * radius,
                height,
                math.sin(angle) * radius
            )
            
            rootPart.CFrame = CFrame.new(mh.Position + offset, mh.Position)
            task.wait(0.01)
        end
        
        -- 🔥 ТЕЛЕПОРТ ВПЛОТНУЮ К МАРДЕРУ + ВЫКИДЫВАНИЕ
        rootPart.CFrame = mh.CFrame * CFrame.new(0, 0, -1)
        
        -- 🔥 ДАЁМ МАРДЕРУ ОГРОМНЫЙ ИМПУЛЬС ВВЕРХ
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, 3000, 0)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.P = math.huge
        bv.Parent = mh
        Debris:AddItem(bv, 2)
        
        -- 🔥 ВРАЩЕНИЕ МАРДЕРА
        local ba = Instance.new("BodyAngularVelocity")
        ba.AngularVelocity = Vector3.new(500, 500, 500)
        ba.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        ba.P = math.huge
        ba.Parent = mh
        Debris:AddItem(ba, 2)
        
        -- 🔥 КРАСНЫЙ ЭФФЕКТ
        local hit = Instance.new("Part")
        hit.Size = Vector3.new(3, 3, 3)
        hit.Position = mh.Position
        hit.Anchored = true
        hit.CanCollide = false
        hit.Material = Enum.Material.Neon
        hit.Color = A.neo
        hit.Transparency = 0.2
        hit.Parent = workspace
        Debris:AddItem(hit, 0.5)
        
        task.wait(0.1)
        
        -- 🔥 ПРОВЕРКА: мардер улетел достаточно далеко?
        local distance = (mh.Position - startPos).Magnitude
        if distance > 100 then
            notify("XDarkHUB", "Flinged!", 2)
            break
        end
    end
    
    -- 🔥 ФИНАЛЬНЫЙ МОЩНЫЙ ВЫКИД
    local finalBv = Instance.new("BodyVelocity")
    finalBv.Velocity = Vector3.new(0, 50000, 0)
    finalBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    finalBv.P = math.huge
    finalBv.Parent = mh
    Debris:AddItem(finalBv, 15)
    
    local finalBa = Instance.new("BodyAngularVelocity")
    finalBa.AngularVelocity = Vector3.new(3000, 3000, 3000)
    finalBa.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    finalBa.P = math.huge
    finalBa.Parent = mh
    Debris:AddItem(finalBa, 15)
    
    -- 🔥 БОЛЬШАЯ КРАСНАЯ ВСПЫШКА
    local fl = Instance.new("Part")
    fl.Size = Vector3.new(50, 50, 50)
    fl.Position = mh.Position
    fl.Anchored = true
    fl.CanCollide = false
    fl.Material = Enum.Material.Neon
    fl.Color = A.neo
    fl.Transparency = 0.2
    fl.Parent = workspace
    Debris:AddItem(fl, 4)
    
    local lt = Instance.new("PointLight")
    lt.Brightness = 50
    lt.Range = 120
    lt.Color = A.neo
    lt.Parent = fl
    
    -- 🔥 КРАСНЫЙ СЛЕД ЗА МАРДЕРОМ
    task.spawn(function()
        for i = 1, 150 do
            task.wait(0.03)
            if not mh.Parent then break end
            local trail = Instance.new("Part")
            trail.Size = Vector3.new(3, 3, 3)
            trail.Position = mh.Position
            trail.Anchored = true
            trail.CanCollide = false
            trail.Material = Enum.Material.Neon
            trail.Color = A.neo
            trail.Transparency = 0.2
            trail.Parent = workspace
            Debris:AddItem(trail, 3)
        end
    end)
    
    -- 🔥 ВОЗВРАТ ПЕРСОНАЖА НА МЕСТО
    rootPart.CFrame = CFrame.new(startPos)
    
    notify("XDarkHUB", mp.Name .. " Flung!", 3)
    initialCoins = getPlayerCoins(player)
    counterV.Text = "0"
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ФАРМ
-- ═══════════════════════════════════════════════════════════════════════════════
function flyTo(pos, spd)
    if not rootPart or farmStopped then return false end
    
    local d = (pos - rootPart.Position).Magnitude
    local dur = math.max(0.1, d / spd)
    local tw = TweenService:Create(rootPart, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tw:Play()
    
    local c = false
    local to = task.delay(dur + 2, function()
        c = true
        tw:Cancel()
    end)
    
    tw.Completed:Wait()
    if not c then task.cancel(to) end
    return not c
end

function startFarming()
    initialCoins = getPlayerCoins(player)
    startTime = tick()
    visitedPositions = {}
    bagFull = false
    farmStopped = false
    
    counterV.Text = "0"
    timerV.Text = "0s"
    rateV.Text = "0"
    updateRoleUI()
    updateBagUI()
    notify("XDarkHUB", "Farm ON", 2)
    notify("XDarkHUB", "Start: " .. initialCoins, 3)
    
    task.spawn(function()
        while isActive do
            local e = tick() - startTime
            timerV.Text = math.floor(e) .. "s"
            local collectedCoins = getCollectedCoins()
            rateV.Text = tostring(e > 0 and math.floor(collectedCoins / e * 3600) or 0)
            pCoinV.Text = tostring(getPlayerCoins(player))
            task.wait(0.1)
        end
    end)
    
    task.spawn(function()
        while isActive do
            task.wait(0.5)
            local collectedCoins = getCollectedCoins()
            counterV.Text = tostring(collectedCoins)
            
            if collectedCoins >= MAX_BAG and not farmStopped then
                notify("XDarkHUB", "Full", 3)
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
            
            local cl, sh = nil, math.huge
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("BasePart") and o.Name == "Coin_Server" then
                    local ic = false
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character and o:IsDescendantOf(p.Character) then
                            ic = true
                            break
                        end
                    end
                    if not ic and o.Parent and o:IsDescendantOf(workspace) and not visitedPositions[o] then
                        local d = (o.Position - rootPart.Position).Magnitude
                        if d < sh and d < 300 then
                            cl = o
                            sh = d
                        end
                    end
                end
            end
            
            if cl then
                local cp = cl.Position
                local cr = cl
                if farmStopped then continue end
                
                if flyTo(cp, flySpeed) and not farmStopped then
                    task.wait(0.3)
                    if cr.Parent and cr:IsDescendantOf(workspace) then
                        local ic = false
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p.Character and cr:IsDescendantOf(p.Character) then
                                ic = true
                                break
                            end
                        end
                        if not ic and (cr.Position - rootPart.Position).Magnitude < 5 then
                            collectSound:Play()
                            updateBagUI()
                            visitedPositions[cr] = true
                        else
                            visitedPositions[cr] = true
                        end
                    else
                        visitedPositions[cr] = true
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

-- ═══════════════════════════════════════════════════════════════════════════════
--  КНОПКА МЕНЮ
-- ═══════════════════════════════════════════════════════════════════════════════
local mBtn = Instance.new("TextButton")
mBtn.Size = UDim2.new(0, 60, 0, 60)
mBtn.Position = UDim2.new(0, 20, 1, -80)
mBtn.BackgroundColor3 = A.base
mBtn.Text = "X"
mBtn.TextColor3 = C.wht
mBtn.Font = Enum.Font.GothamBlack
mBtn.TextSize = 26
mBtn.BorderSizePixel = 0
mBtn.ZIndex = 10
mBtn.Active = true
mBtn.AutoButtonColor = false
mBtn.Parent = gui
crn(mBtn, 30)
stk(mBtn, A.neo, 1.5, 0.4)

task.spawn(function()
    while mBtn.Parent do
        ani(mBtn, {Size = UDim2.new(0, 64, 0, 64)}, 1.5, Enum.EasingStyle.Sine)
        task.wait(1.5)
        ani(mBtn, {Size = UDim2.new(0, 60, 0, 60)}, 1.5, Enum.EasingStyle.Sine)
        task.wait(1.5)
    end
end)

do
    local dr, ds, sp = false, nil, nil
    mBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dr = true
            ds = i.Position
            sp = mBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            mBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dr = false
        end
    end)
end

mBtn.MouseButton1Click:Connect(function()
    clickSnd:Play()
    local v = frame.Visible
    frame.Visible = not v
    bgF.Visible = not v
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  ESP
-- ═══════════════════════════════════════════════════════════════════════════════
function updateESP()
    for _, h in pairs(espHighlights) do
        if h then h:Destroy() end
    end
    espHighlights = {}
    
    if not espEnabled then return end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local r = getPlayerRole(p)
            local c
            if r == "Murderer" then
                c = Color3.fromRGB(255, 50, 50)
            elseif r == "Sheriff" then
                c = Color3.fromRGB(50, 150, 255)
            else
                c = Color3.fromRGB(50, 255, 50)
            end
            local h = Instance.new("Highlight")
            h.FillColor = c
            h.OutlineColor = c
            h.FillTransparency = 0.7
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
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

-- ═══════════════════════════════════════════════════════════════════════════════
--  СИСТЕМНЫЕ СОБЫТИЯ
-- ═══════════════════════════════════════════════════════════════════════════════
player.CharacterAdded:Connect(function(ch)
    character = ch
    rootPart = ch:WaitForChild("HumanoidRootPart")
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

-- ═══════════════════════════════════════════════════════════════════════════════
--  ИНИЦИАЛИЗАЦИЯ
-- ═══════════════════════════════════════════════════════════════════════════════
updateRoleUI()
updateBagUI()
switchTab("Farm")

notify("XDarkHUB", "v17 Loaded", 3)
notify("XDarkHUB", "Body Fling System", 3)
