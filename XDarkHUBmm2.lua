-- ═══════════════════════════════════════════════════════════════════════════════
--  XDarkHUB v12 · GLASSMORPHISM · MM2 Autofarm · FULL VERSION
-- ═══════════════════════════════════════════════════════════════════════════════

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
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
    print("[XDarkHUB] " .. title .. ": " .. text)
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
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name:find("coin") or name:find("money") or name:find("cash") then
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
    local r = getPlayerRole(player)
    isMurderer = (r == "Murderer")
    isSheriff = (r == "Sheriff")
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  GLASSMORPHISM THEME
-- ═══════════════════════════════════════════════════════════════════════════════
local C = {
    bg = Color3.fromRGB(8, 8, 12),
    panel = Color3.fromRGB(12, 12, 18),
    card = Color3.fromRGB(18, 18, 26),
    hov = Color3.fromRGB(26, 26, 36),
    bdr = Color3.fromRGB(40, 40, 52),
    bdrLt = Color3.fromRGB(55, 55, 70),
    txt = Color3.fromRGB(245, 245, 255),
    mut = Color3.fromRGB(100, 100, 115),
    wht = Color3.fromRGB(255, 255, 255),
    dim = Color3.fromRGB(65, 65, 80),
}

local A = {
    base = Color3.fromRGB(235, 35, 60),
    dim = Color3.fromRGB(65, 12, 24),
    lit = Color3.fromRGB(255, 90, 115),
    glo = Color3.fromRGB(255, 50, 75),
    drk = Color3.fromRGB(38, 8, 16),
    neo = Color3.fromRGB(255, 35, 62),
    soft = Color3.fromRGB(190, 45, 70),
}

-- ═══════════════════════════════════════════════════════════════════════════════
--  UI HELPERS
-- ═══════════════════════════════════════════════════════════════════════════════
local function crn(o, r)
    local c = Instance.new("UICorner", o)
    c.CornerRadius = UDim.new(0, r)
    return c
end

local function stk(o, c, t, tr)
    local s = Instance.new("UIStroke", o)
    s.Color = c
    s.Thickness = t or 1
    s.Transparency = tr or 0
    return s
end

local function grd(o, cs, rot)
    local g = Instance.new("UIGradient", o)
    g.Color = ColorSequence.new(cs)
    g.Rotation = rot or 0
    return g
end

local function ani(o, p, t, s)
    TweenService:Create(o, TweenInfo.new(t or 0.25, s or Enum.EasingStyle.Quint), p):Play()
end

local function mkF(par, bg, sz, pos, r, zi)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = bg or C.card
    f.BorderSizePixel = 0
    f.Size = sz or UDim2.new(1, 0, 0, 40)
    f.Position = pos or UDim2.new()
    f.ZIndex = zi or 2
    f.Parent = par
    if r then crn(f, r) end
    return f
end

local function mkL(par, txt, col, fnt, fsz, sz, pos, xa, zi)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = txt or ""
    l.TextColor3 = col or C.txt
    l.Font = fnt or Enum.Font.GothamBold
    l.TextSize = fsz or 13
    l.Size = sz or UDim2.new(1, 0, 1, 0)
    l.Position = pos or UDim2.new()
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.ZIndex = zi or 2
    l.Parent = par
    return l
end

local function mkB(par, bg, txt, tcol, fnt, fsz, sz, pos, r, zi)
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = bg or C.card
    b.Text = txt or ""
    b.TextColor3 = tcol or C.wht
    b.Font = fnt or Enum.Font.GothamBold
    b.TextSize = fsz or 13
    b.Size = sz or UDim2.new(1, 0, 0, 40)
    b.Position = pos or UDim2.new()
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.ZIndex = zi or 3
    b.Parent = par
    if r then crn(b, r) end
    b.MouseButton1Click:Connect(function()
        clickSnd:Play()
        local rip = Instance.new("Frame")
        rip.Size = UDim2.new(0, 0, 0, 0)
        rip.Position = UDim2.new(0.5, 0, 0.5, 0)
        rip.AnchorPoint = Vector2.new(0.5, 0.5)
        rip.BackgroundColor3 = A.neo
        rip.BackgroundTransparency = 0.5
        rip.BorderSizePixel = 0
        rip.ZIndex = (zi or 3) + 1
        rip.Parent = b
        crn(rip, 50)
        ani(rip, {Size = UDim2.new(2.5, 0, 2.5, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Quad)
        task.delay(0.4, function()
            if rip.Parent then rip:Destroy() end
        end)
    end)
    return b
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
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")
collectSound.Parent = gui
killSound.Parent = gui
deathSound.Parent = gui
clickSnd.Parent = gui

-- ═══════════════════════════════════════════════════════════════════════════════
--  ФОН С ЧАСТИЦАМИ
-- ═══════════════════════════════════════════════════════════════════════════════
local bgF = mkF(gui, C.bg, UDim2.new(1, 0, 1, 0), nil, nil, 0)
bgF.BackgroundTransparency = 0.08
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

local pCols = {A.base, A.neo, A.glo, A.lit, Color3.fromRGB(255, 20, 40), Color3.fromRGB(255, 115, 135)}
for i = 1, 28 do
    local sz = math.random(2, 11)
    local p = mkF(bgF, pCols[math.random(1, #pCols)], UDim2.new(0, sz, 0, sz), UDim2.new(math.random(), 0, math.random(), 0), math.random(1, 5), 0)
    p.BackgroundTransparency = math.random(45, 82) / 100
    if math.random() > 0.5 then
        stk(p, p.BackgroundColor3, 1, 0.5)
    end
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
local frame = mkF(gui, C.bg, UDim2.new(0, 620, 0, 520), UDim2.new(0.5, -310, 0.5, -260), 8, 1)
frame.BackgroundTransparency = 0.03
frame.ClipsDescendants = true
stk(frame, A.base, 1.5, 0.4)

local topLine = mkF(frame, A.neo, UDim2.new(1, 0, 0, 2), nil, nil, 3)
topLine.BackgroundTransparency = 0.15

frame.Size = UDim2.new(0, 0, 0, 0)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
ani(frame, {Size = UDim2.new(0, 620, 0, 520), Position = UDim2.new(0.5, -310, 0.5, -260)}, 0.6, Enum.EasingStyle.Back)

-- ═══════════════════════════════════════════════════════════════════════════════
--  ЗАГОЛОВОК
-- ═══════════════════════════════════════════════════════════════════════════════
local tBar = mkF(frame, C.panel, UDim2.new(1, 0, 0, 50), nil, nil, 2)
tBar.Active = true
tBar.BackgroundTransparency = 0.04
grd(tBar, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 14, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 10, 16)),
})

local logo = mkF(tBar, A.base, UDim2.new(0, 32, 0, 32), UDim2.new(0, 14, 0.5, -16), nil, 3)
stk(logo, A.neo, 1.5, 0.3)
mkL(logo, "X", C.wht, Enum.Font.GothamBlack, 20, UDim2.new(1, 0, 1, 0), nil, Enum.TextXAlignment.Center, 4)

local tLbl = mkL(tBar, "XDARKHUB", A.lit, Enum.Font.GothamBlack, 18, UDim2.new(1, -130, 1, 0), UDim2.new(0, 56, 0, 0), Enum.TextXAlignment.Left, 3)
tLbl.TextStrokeTransparency = 0.8
tLbl.TextStrokeColor3 = A.drk

local sep1 = mkF(tBar, A.base, UDim2.new(0, 1, 0, 22), UDim2.new(0, 52, 0.5, -11), nil, 3)
sep1.BackgroundTransparency = 0.5

mkL(tBar, "[v12]", A.mut, Enum.Font.Code, 11, UDim2.new(0, 60, 1, 0), UDim2.new(1, -68, 0, 0), Enum.TextXAlignment.Right, 3)

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
local ctr = mkF(frame, nil, UDim2.new(1, 0, 1, -52), UDim2.new(0, 0, 0, 52), nil, 1)
ctr.BackgroundTransparency = 1

local lPan = mkF(ctr, C.panel, UDim2.new(0, 160, 1, 0), nil, nil, 2)
lPan.BackgroundTransparency = 0.04

local vLine = mkF(ctr, A.base, UDim2.new(0, 1, 1, 0), UDim2.new(0, 160, 0, 0), nil, 3)
vLine.BackgroundTransparency = 0.65

local rPan = mkF(ctr, nil, UDim2.new(1, -162, 1, 0), UDim2.new(0, 162, 0, 0), nil, 2)
rPan.BackgroundTransparency = 1

-- ═══════════════════════════════════════════════════════════════════════════════
--  ВКЛАДКИ
-- ═══════════════════════════════════════════════════════════════════════════════
local tabs = {}
local tabC = {}
local curTab = nil

local function mkTab(name, icon, ord)
    local b = mkB(lPan, nil, "", nil, nil, nil, UDim2.new(1, -16, 0, 46), UDim2.new(0, 8, 0, 12 + (ord - 1) * 52), nil, 3)
    b.BackgroundTransparency = 1
    
    local ind = mkF(b, A.base, UDim2.new(0, 3, 0, 24), UDim2.new(0, 0, 0.5, -12), nil, 3)
    ind.BackgroundTransparency = 1
    
    local ic = mkL(b, icon, A.mut, Enum.Font.GothamBold, 18, UDim2.new(0, 34, 1, 0), UDim2.new(0, 12, 0, 0), Enum.TextXAlignment.Center, 3)
    
    mkL(b, name, C.mut, Enum.Font.GothamBold, 12, UDim2.new(1, -54, 1, 0), UDim2.new(0, 46, 0, 0), Enum.TextXAlignment.Left, 3)
    
    tabs[name] = {btn = b, ic = ic, ind = ind}
    
    b.MouseEnter:Connect(function()
        if curTab ~= name then
            ani(b, {BackgroundColor3 = Color3.fromRGB(20, 20, 28)}, 0.15)
            ani(ic, {TextColor3 = C.txt}, 0.15)
        end
    end)
    b.MouseLeave:Connect(function()
        if curTab ~= name then
            b.BackgroundColor3 = nil
            b.BackgroundTransparency = 1
            ani(ic, {TextColor3 = A.mut}, 0.15)
        end
    end)
end

local function mkTabC(name)
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
    p.PaddingLeft = UDim.new(0, 18)
    p.PaddingRight = UDim.new(0, 18)
    p.PaddingTop = UDim.new(0, 16)
    p.PaddingBottom = UDim.new(0, 16)
    
    local l = Instance.new("UIListLayout", c)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 10)
    
    tabC[name] = c
end

function switchTab(name)
    for n, t in pairs(tabs) do
        t.btn.BackgroundColor3 = nil
        t.btn.BackgroundTransparency = 1
        t.ic.TextColor3 = A.mut
        t.ind.BackgroundTransparency = 1
    end
    
    if tabs[name] then
        tabs[name].btn.BackgroundTransparency = 0.65
        tabs[name].btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        tabs[name].ic.TextColor3 = A.neo
        tabs[name].ind.BackgroundTransparency = 0
        tabs[name].ind.BackgroundColor3 = A.neo
    end
    
    for n, c in pairs(tabC) do
        if n == name then
            c.Visible = true
            c.Position = UDim2.new(0, 40, 0, 0)
            ani(c, {Position = UDim2.new(0, 0, 0, 0)}, 0.35, Enum.EasingStyle.Back)
        else
            c.Visible = false
        end
    end
    
    curTab = name
end

mkTab("Sheriff", "⭐", 1)
mkTab("Murderer", "🔪", 2)
mkTab("ESP", "👁️", 3)
mkTab("Player", "🎯", 4)
mkTab("Farm", "⚙️", 5)

for n in pairs(tabs) do
    mkTabC(n)
    tabs[n].btn.MouseButton1Click:Connect(function()
        switchTab(n)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  UI КОМПОНЕНТЫ
-- ═══════════════════════════════════════════════════════════════════════════════
local function secT(par, ord, txt)
    local l = mkL(par, txt, A.soft, Enum.Font.GothamBold, 11, UDim2.new(1, 0, 0, 22), nil, Enum.TextXAlignment.Left, 2)
    l.LayoutOrder = ord
    local ln = mkF(par, A.base, UDim2.new(1, 0, 0, 1), nil, nil, 2)
    ln.BackgroundTransparency = 0.82
    ln.LayoutOrder = ord + 0.1
end

local function statR(par, ord, name)
    local r = mkF(par, nil, UDim2.new(1, 0, 0, 34), nil, nil, 2)
    r.LayoutOrder = ord
    r.BackgroundTransparency = 1
    
    local ln = mkF(r, C.bdr, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, 0), nil, 2)
    ln.BackgroundTransparency = 0.65
    
    local dot = mkF(r, A.base, UDim2.new(0, 5, 0, 5), UDim2.new(0, 0, 0.5, -2.5), 3, 2)
    
    mkL(r, name, C.mut, Enum.Font.Gotham, 12, UDim2.new(0.6, 0, 1, 0), UDim2.new(0, 14, 0, 0), Enum.TextXAlignment.Left, 2)
    local v = mkL(r, "0", A.lit, Enum.Font.GothamBold, 13, UDim2.new(0.4, -14, 1, 0), UDim2.new(0.6, 0, 0, 0), Enum.TextXAlignment.Right, 2)
    return v
end

local function togC(par, ord, label, onTog)
    local cd = mkF(par, nil, UDim2.new(1, 0, 0, 46), nil, nil, 2)
    cd.LayoutOrder = ord
    cd.BackgroundTransparency = 1
    
    local ln = mkF(cd, C.bdr, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, 0), nil, 2)
    ln.BackgroundTransparency = 0.65
    
    mkL(cd, label, C.txt, Enum.Font.GothamBold, 13, UDim2.new(1, -90, 1, 0), UDim2.new(0, 0, 0, 0), Enum.TextXAlignment.Left, 2)
    
    local sw = mkF(cd, C.bdr, UDim2.new(0, 50, 0, 26), UDim2.new(1, -58, 0.5, -13), nil, 2)
    stk(sw, C.bdrLt, 1)
    
    local ind = mkF(sw, C.mut, UDim2.new(0, 16, 0, 16), UDim2.new(0, 5, 0.5, -8), nil, 2)
    
    local pl = mkL(sw, "OFF", C.mut, Enum.Font.GothamBold, 10, UDim2.new(1, 0, 1, 0), UDim2.new(0, 24, 0, 0), Enum.TextXAlignment.Left, 2)
    
    local btn = mkB(cd, nil, "", nil, nil, nil, UDim2.new(1, 0, 1, 0), nil, nil, 3)
    btn.BackgroundTransparency = 1
    
    local st = false
    
    btn.MouseButton1Click:Connect(function()
        st = not st
        if st then
            ani(sw, {BackgroundColor3 = A.dim}, 0.2)
            sw.UIStroke.Color = A.base
            ani(ind, {Position = UDim2.new(0, 29, 0.5, -8), BackgroundColor3 = A.neo}, 0.25, Enum.EasingStyle.Back)
            pl.Text = "ON"
            ani(pl, {TextColor3 = A.lit}, 0.2)
            ani(cd, {BackgroundColor3 = Color3.fromRGB(20, 16, 22)}, 0.2)
        else
            ani(sw, {BackgroundColor3 = C.bdr}, 0.2)
            sw.UIStroke.Color = C.bdrLt
            ani(ind, {Position = UDim2.new(0, 5, 0.5, -8), BackgroundColor3 = C.mut}, 0.25, Enum.EasingStyle.Back)
            pl.Text = "OFF"
            ani(pl, {TextColor3 = C.mut}, 0.2)
            cd.BackgroundColor3 = nil
            cd.BackgroundTransparency = 1
        end
        if onTog then onTog(st) end
    end)
    
    btn.MouseEnter:Connect(function()
        if not st then
            ani(cd, {BackgroundColor3 = Color3.fromRGB(18, 18, 24)}, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if not st then
            cd.BackgroundColor3 = nil
            cd.BackgroundTransparency = 1
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  КОНТЕНТ ВКЛАДОК
-- ═══════════════════════════════════════════════════════════════════════════════
local espC = tabC["ESP"]
secT(espC, 1, "VISUAL")
togC(espC, 2, "ESP Roles", function(s)
    espEnabled = s
    updateESP()
    notify("XDarkHUB", "ESP: " .. (s and "ON" or "OFF"), 2)
end)

local fC = tabC["Farm"]
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
    local cd = mkF(fC, nil, UDim2.new(1, 0, 0, 42), nil, nil, 2)
    cd.LayoutOrder = 10
    cd.BackgroundTransparency = 1
    local ln = mkF(cd, C.bdr, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, 0), nil, 2)
    ln.BackgroundTransparency = 0.65
    mkL(cd, "Limit", C.txt, Enum.Font.GothamBold, 13, UDim2.new(1, -90, 1, 0), nil, Enum.TextXAlignment.Left, 2)
    local pill = mkF(cd, A.base, UDim2.new(0, 68, 0, 28), UDim2.new(1, -76, 0.5, -14), nil, 2)
    stk(pill, A.neo, 1)
    local pL = mkL(pill, MAX_BAG, C.wht, Enum.Font.GothamBold, 13, UDim2.new(1, 0, 1, 0), nil, Enum.TextXAlignment.Center, 2)
    local b = mkB(cd, nil, "", nil, nil, nil, UDim2.new(1, 0, 1, 0), nil, nil, 3)
    b.BackgroundTransparency = 1
    b.MouseButton1Click:Connect(function()
        if MAX_BAG == 40 then MAX_BAG = 50 else MAX_BAG = 40 end
        pL.Text = MAX_BAG
        ani(pill, {Size = UDim2.new(0, 76, 0, 32)}, 0.12)
        task.wait(0.12)
        ani(pill, {Size = UDim2.new(0, 68, 0, 28)}, 0.12)
    end)
end

do
    local cd = mkF(fC, nil, UDim2.new(1, 0, 0, 42), nil, nil, 2)
    cd.LayoutOrder = 11
    cd.BackgroundTransparency = 1
    local ln = mkF(cd, C.bdr, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, 0), nil, 2)
    ln.BackgroundTransparency = 0.65
    mkL(cd, "Speed", C.txt, Enum.Font.GothamBold, 13, UDim2.new(1, -90, 1, 0), nil, Enum.TextXAlignment.Left, 2)
    local pill = mkF(cd, C.bdr, UDim2.new(0, 58, 0, 26), UDim2.new(1, -66, 0.5, -13), nil, 2)
    stk(pill, A.base, 1)
    local sL = mkL(pill, tostring(flySpeed), A.lit, Enum.Font.GothamBold, 12, UDim2.new(1, 0, 1, 0), nil, Enum.TextXAlignment.Center, 2)
    local b = mkB(cd, nil, "", nil, nil, nil, UDim2.new(1, 0, 1, 0), nil, nil, 3)
    b.BackgroundTransparency = 1
    b.MouseButton1Click:Connect(function()
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
    local b = mkB(fC, A.base, "FLING", C.wht, Enum.Font.GothamBlack, 14, UDim2.new(1, 0, 0, 46), nil, nil, 2)
    b.LayoutOrder = 14
    stk(b, A.neo, 1.5)
    b.MouseEnter:Connect(function()
        ani(b, {BackgroundColor3 = A.neo}, 0.15)
    end)
    b.MouseLeave:Connect(function()
        ani(b, {BackgroundColor3 = A.base}, 0.15)
    end)
    b.MouseButton1Click:Connect(function()
        throwMurdererToSpace()
    end)
end

do
    local b = mkB(fC, nil, "RESET", A.soft, Enum.Font.GothamBold, 12, UDim2.new(1, 0, 0, 38), nil, nil, 2)
    b.LayoutOrder = 15
    b.BackgroundTransparency = 1
    stk(b, A.base, 1, 0.5)
    b.MouseEnter:Connect(function()
        ani(b, {BackgroundColor3 = Color3.fromRGB(20, 16, 22)}, 0.15)
    end)
    b.MouseLeave:Connect(function()
        b.BackgroundColor3 = nil
        b.BackgroundTransparency = 1
    end)
    b.MouseButton1Click:Connect(function()
        collected = 0
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
    local c = tabC[name]
    mkL(c, name:upper(), A.soft, Enum.Font.GothamBlack, 16, UDim2.new(1, 0, 0, 30), nil, Enum.TextXAlignment.Left, 2).LayoutOrder = 1
    local cd = mkF(c, nil, UDim2.new(1, 0, 0, 100), nil, nil, 2)
    cd.LayoutOrder = 2
    cd.BackgroundTransparency = 1
    stk(cd, C.bdr, 1, 0.5)
    mkL(cd, "Coming Soon", C.mut, Enum.Font.Gotham, 13, UDim2.new(1, -20, 1, 0), UDim2.new(0, 10, 0, 0), Enum.TextXAlignment.Left, 2)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ФУНКЦИИ
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
    if farmStopped then
        bagV.Text = "Stopped"
        bagV.TextColor3 = Color3.fromRGB(255, 80, 80)
    elseif bagFull then
        bagV.Text = "Full"
        bagV.TextColor3 = Color3.fromRGB(255, 200, 0)
    else
        bagV.Text = collected .. "/" .. MAX_BAG
        bagV.TextColor3 = A.lit
    end
end

function stopFarming()
    farmStopped = true
    updateBagUI()
    notify("XDarkHUB", "Stopped", 2)
end

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
    
    for _, p in ipairs(tgts) do
        local h = p.Character:FindFirstChild("Humanoid")
        if h then
            h.PlatformStand = true
            h.WalkSpeed = 0
            h.JumpPower = 0
            for _, pt in ipairs(p.Character:GetDescendants()) do
                if pt:IsA("BasePart") then pt.CanCollide = false end
            end
        end
    end
    
    task.wait(0.4)
    
    for i, p in ipairs(tgts) do
        if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            if h then
                hrp.CFrame = h.CFrame * CFrame.new(0, 0, -1.5)
                task.wait(0.12)
                if k and k.Parent == character then k:Activate() end
                task.wait(0.05)
                if p.Character:FindFirstChild("Humanoid") then
                    p.Character.Humanoid:TakeDamage(100)
                end
            end
        end
    end
    
    task.wait(0.3)
    bagFull = false
    collected = 0
    counterV.Text = "0"
    notify("XDarkHUB", "Done", 2)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ФЛИНГ МАРДЕРА (РАБОЧИЙ МЕТОД)
-- ═══════════════════════════════════════════════════════════════════════════════
function throwMurdererToSpace()
    notify("XDarkHUB", "Fling", 3)
    deathSound:Play()
    
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
    if not mh then
        notify("XDarkHUB", "No HRP", 2)
        return
    end
    
    notify("XDarkHUB", mp.Name, 2)
    
    -- Отключение управления
    local mhu = mp.Character:FindFirstChild("Humanoid")
    if mhu then
        mhu.PlatformStand = true
        mhu.WalkSpeed = 0
        mhu.JumpPower = 0
        mhu.AutoRotate = false
        mhu.JumpHeight = 0
    end
    
    -- Отключение коллизий
    for _, pt in ipairs(mp.Character:GetDescendants()) do
        if pt:IsA("BasePart") then
            pt.CanCollide = false
        end
    end
    
    -- Удаление старых velocity
    for _, v in ipairs(mh:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro") or v:IsA("AlignPosition") or v:IsA("AlignOrientation") then
            v:Destroy()
        end
    end
    
    -- Создание ОДНОЙ большой невидимой части
    local flingPart = Instance.new("Part")
    flingPart.Name = "FlingPart"
    flingPart.Size = Vector3.new(10, 10, 10)
    flingPart.Position = mh.Position
    flingPart.Anchored = false
    flingPart.CanCollide = false
    flingPart.Transparency = 1
    flingPart.Massless = false
    flingPart.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5, 100, 1000)
    flingPart.Parent = workspace
    
    -- WeldConstraint
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = flingPart
    weld.Part1 = mh
    weld.Parent = flingPart
    
    -- BodyVelocity на часть (огромная сила вверх)
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 20000, 0)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.P = math.huge
    bv.Parent = flingPart
    
    -- BodyAngularVelocity на часть (вращение)
    local ba = Instance.new("BodyAngularVelocity")
    ba.AngularVelocity = Vector3.new(2000, 2000, 2000)
    ba.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    ba.P = math.huge
    ba.Parent = flingPart
    
    -- Очистка через 15 секунд
    Debris:AddItem(flingPart, 15)
    Debris:AddItem(bv, 15)
    Debris:AddItem(ba, 15)
    
    -- Красный эффект
    local fl = Instance.new("Part")
    fl.Size = Vector3.new(35, 35, 35)
    fl.Position = mh.Position
    fl.Anchored = true
    fl.CanCollide = false
    fl.Material = Enum.Material.Neon
    fl.Color = A.neo
    fl.Transparency = 0.25
    fl.Parent = workspace
    Debris:AddItem(fl, 4)
    
    local lt = Instance.new("PointLight")
    lt.Brightness = 35
    lt.Range = 80
    lt.Color = A.neo
    lt.Parent = fl
    
    notify("XDarkHUB", mp.Name .. " Flung", 3)
    bagFull = false
    collected = 0
    counterV.Text = "0"
end

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
    collected = 0
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
    
    task.spawn(function()
        while isActive do
            local e = tick() - startTime
            timerV.Text = math.floor(e) .. "s"
            rateV.Text = tostring(e > 0 and math.floor(collected / e * 3600) or 0)
            pCoinV.Text = tostring(getPlayerCoins(player))
            task.wait(0.1)
        end
    end)
    
    task.spawn(function()
        while isActive do
            task.wait(0.5)
            if collected >= MAX_BAG and not farmStopped then
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
                            collected = collected + 1
                            counterV.Text = tostring(collected)
                            collectSound:Play()
                            updateBagUI()
                            visitedPositions[cr] = true
                            if collected % 10 == 0 then
                                notify("XDarkHUB", collected .. "/" .. MAX_BAG, 2)
                            end
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
local mBtn = mkB(gui, A.base, "X", C.wht, Enum.Font.GothamBlack, 24, UDim2.new(0, 56, 0, 56), UDim2.new(0, 18, 1, -74), nil, 10)
stk(mBtn, A.neo, 1.5, 0.4)

task.spawn(function()
    while mBtn.Parent do
        ani(mBtn, {Size = UDim2.new(0, 60, 0, 60)}, 1.5, Enum.EasingStyle.Sine)
        task.wait(1.5)
        ani(mBtn, {Size = UDim2.new(0, 56, 0, 56)}, 1.5, Enum.EasingStyle.Sine)
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
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

updateRoleUI()
updateBagUI()
switchTab("Farm")

notify("XDarkHUB", "v12 Loaded", 3)
