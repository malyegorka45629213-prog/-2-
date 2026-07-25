-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                         XDarkHUB v33 · SHERIFF FLOATING BUTTONS              ║
-- ║   TP TO GUN + SHOOT MURDERER AS FLOATING BUTTONS                             ║
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
local trapESPEnabled = false
local gunESPEnabled = false
local espHighlights = {}
local MAX_BAG = 40
local shootOffset = 2.8

-- ЗВУКИ
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

-- УВЕДОМЛЕНИЯ
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ПОИСК РОЛЕЙ (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
local function getPlayerRole(p)
    if p.Character then
        if p.Character:FindFirstChild("Knife") or p.Character:FindFirstChild("MurdererSword") then return "Murderer" end
        if p.Character:FindFirstChild("Gun") or p.Character:FindFirstChild("SheriffGun") then return "Sheriff" end
    end
    if p:FindFirstChild("Backpack") then
        if p.Backpack:FindFirstChild("Knife") or p.Backpack:FindFirstChild("MurdererSword") then return "Murderer" end
        if p.Backpack:FindFirstChild("Gun") or p.Backpack:FindFirstChild("SheriffGun") then return "Sheriff" end
    end
    local ls = p:FindFirstChild("leaderstats")
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            if v.Name == "Role" and v.Value then return v.Value end
        end
    end
    return "Innocent"
end

local function findMurderer()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Knife") then return i end
    end
    for _, i in ipairs(Players:GetPlayers()) do
        if not i.Character then continue end
        if i.Character:FindFirstChild("Knife") then return i end
    end
    return nil
end

local function findSheriff()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Gun") then return i end
    end
    for _, i in ipairs(Players:GetPlayers()) do
        if not i.Character then continue end
        if i.Character:FindFirstChild("Gun") then return i end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ПОИСК КАРТЫ (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
local function getMap()
    for _, o in ipairs(workspace:GetChildren()) do
        if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then
            return o
        end
    end
    return nil
end

local function getPlayerCoins(p)
    local ls = p:FindFirstChild("leaderstats")
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local n = v.Name:lower()
                if n:find("coin") or n:find("money") or n:find("cash") or n:find("gold") then return v.Value end
            end
        end
        for _, v in ipairs(ls:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then return v.Value end
        end
    end
    return 0
end

local function getCollectedCoins()
    return getPlayerCoins(player) - initialCoins
end

local function checkRole()
    local r = getPlayerRole(player)
    isMurderer = (r == "Murderer")
    isSheriff = (r == "Sheriff")
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  PREDICTION (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
local function getPredictedPosition(targetPlayer)
    local playerChar = targetPlayer.Character
    if not playerChar then return Vector3.new(0,0,0) end
    
    local playerHRP = playerChar:FindFirstChild("UpperTorso") or playerChar:FindFirstChild("HumanoidRootPart")
    local playerHum = playerChar:FindFirstChild("Humanoid")
    
    if not playerHRP or not playerHum then return Vector3.new(0,0,0) end
    
    local playerPosition = playerHRP.Position
    local velocity = playerHRP.AssemblyLinearVelocity
    local playerMoveDirection = playerHum.MoveDirection
    
    local predictedPosition = playerHRP.Position + ((velocity * Vector3.new(0.75, 0.5, 0.75))) * (shootOffset / 15) + playerMoveDirection * shootOffset
    
    return predictedPosition
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  TP TO GUN (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
local function teleportToGun()
    local map = getMap()
    if not map then
        notify("XDarkHUB", "❌ Карта не найдена!", 2)
        return
    end
    
    local gunDrop = map:FindFirstChild("GunDrop")
    if not gunDrop then
        notify("XDarkHUB", "❌ Пистолет не брошен!", 2)
        return
    end
    
    local localplayer = player
    local previousPosition = localplayer.Character:GetPivot()
    
    -- Телепорт к пистолету
    localplayer.Character:PivotTo(gunDrop:GetPivot())
    notify("XDarkHUB", "🔫 Телепорт к пистолету!", 2)
    
    -- Ждем получения пистолета
    localplayer.Backpack.ChildAdded:Wait()
    
    -- Возвращаемся на предыдущую позицию
    localplayer.Character:PivotTo(previousPosition)
    notify("XDarkHUB", "✅ Пистолет получен!", 2)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SHOOT MURDERER (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
local function shootMurderer()
    if findSheriff() ~= player then
        notify("XDarkHUB", "❌ Ты не шериф!", 2)
        return
    end
    
    local murderer = findMurderer()
    if not murderer then
        notify("XDarkHUB", "❌ Мардер не найден!", 2)
        return
    end
    
    if not player.Character:FindFirstChild("Gun") then
        local hum = player.Character:FindFirstChild("Humanoid")
        if player.Backpack:FindFirstChild("Gun") then
            hum:EquipTool(player.Backpack:FindFirstChild("Gun"))
        else
            notify("XDarkHUB", "❌ У тебя нет пистолета!", 2)
            return
        end
    end
    
    local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not murdererHRP then
        notify("XDarkHUB", "❌ Не найден HumanoidRootPart мардера!", 2)
        return
    end
    
    local predictedPosition = getPredictedPosition(murderer)
    local args = {
        CFrame.new(player.Character.RightHand.Position),
        CFrame.new(predictedPosition)
    }
    
    player.Character:WaitForChild("Gun"):WaitForChild("Shoot"):FireServer(unpack(args))
    notify("XDarkHUB", "🔫 Выстрел в мардера!", 2)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  FLOATING BUTTON SYSTEM (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
local floatingButtons = {}

local function createFloatingButton(name, text, color, callback, position)
    -- Удаляем старую кнопку если есть
    if floatingButtons[name] then
        floatingButtons[name]:Destroy()
        floatingButtons[name] = nil
    end
    
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 150, 0, 50)
    button.Position = position or UDim2.new(0, 125, 0, 90)
    button.BackgroundColor3 = color or Color3.fromRGB(31, 31, 31)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.ClipsDescendants = true
    button.Parent = player:WaitForChild("PlayerGui"):WaitForChild("AutoFarmGui")
    
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", button)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    -- Click handler
    button.MouseButton1Click:Connect(function()
        clickSnd:Play()
        callback()
    end)
    
    -- Ripple effect
    button.MouseButton1Down:Connect(function(x, y)
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 145, 0, 48)
        }):Play()
        
        local ripple = Instance.new("Frame")
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 1
        ripple.Position = UDim2.fromOffset(x - button.AbsolutePosition.X, y - button.AbsolutePosition.Y)
        ripple.Size = UDim2.fromOffset(50, 50)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Parent = button
        
        local rippleCorner = Instance.new("UICorner", ripple)
        rippleCorner.CornerRadius = UDim.new(1, 0)
        
        TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.6,
            Size = UDim2.fromOffset(150, 150)
        }):Play()
        
        task.spawn(function()
            task.wait(0.5)
            if ripple and ripple.Parent then ripple:Destroy() end
        end)
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(button, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 150, 0, 50)
            }):Play()
        end
    end)
    
    -- Draggable (ИЗ YARHM)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Animate appearance
    button.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(button, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 150, 0, 50)
    }):Play()
    
    floatingButtons[name] = button
    notify("XDarkHUB", "📌 Кнопка " .. text .. " создана!", 3)
    
    return button
end

local function removeFloatingButton(name)
    if floatingButtons[name] then
        local button = floatingButtons[name]
        TweenService:Create(button, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.3)
        button:Destroy()
        floatingButtons[name] = nil
        notify("XDarkHUB", "📌 Кнопка удалена!", 2)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  FLING ИЗ YARHM
-- ═══════════════════════════════════════════════════════════════════════════════
function miniFling(playerToFling)
    local Character = player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = playerToFling.Character
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle
    
    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessory and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end
    
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif not THead and Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end
        
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= playerToFling.Character or playerToFling.Parent ~= Players or playerToFling.Character ~= TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end
        
        workspace.FallenPartsDestroyHeight = 0/0
        
        local BV = Instance.new("BodyVelocity")
        BV.Name = "EpixVel"
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        
        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                SFBasePart(THead)
            else
                SFBasePart(TRootPart)
            end
        elseif TRootPart and not THead then
            SFBasePart(TRootPart)
        elseif not TRootPart and THead then
            SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then
            SFBasePart(Handle)
        else
            notify("XDarkHUB", "❌ Не найдена часть для флинга!", 2)
        end
        
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        
        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
            Humanoid:ChangeState("GettingUp")
            table.foreach(Character:GetChildren(), function(_, x)
                if x:IsA("BasePart") then
                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                end
            end)
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        
        workspace.FallenPartsDestroyHeight = getgenv().FPDH or -500
    else
        notify("XDarkHUB", "❌ Нет персонажа!", 2)
    end
end

function throwMurdererToSpace()
    local murderer = findMurderer()
    if not murderer then
        notify("XDarkHUB", "❌ Мардер не найден!", 2)
        return
    end
    notify("XDarkHUB", "🔪 Флингу мардера: " .. murderer.Name, 3)
    miniFling(murderer)
    initialCoins = getPlayerCoins(player)
end

function flingSheriff()
    local sheriff = findSheriff()
    if not sheriff then
        notify("XDarkHUB", "❌ Шериф не найден!", 2)
        return
    end
    notify("XDarkHUB", "⭐ Флингу шерифа: " .. sheriff.Name, 3)
    miniFling(sheriff)
    initialCoins = getPlayerCoins(player)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ЦВЕТА
-- ═══════════════════════════════════════════════════════════════════════════════
local C = {
    bg = Color3.fromRGB(8, 8, 12),
    panel = Color3.fromRGB(12, 12, 18),
    card = Color3.fromRGB(18, 18, 26),
    cardHov = Color3.fromRGB(26, 26, 36),
    bdr = Color3.fromRGB(40, 40, 50),
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

-- UI HELPERS
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

-- ОЧИСТКА
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

-- ФОН С ЧАСТИЦАМИ
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
    ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 4, 10))
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

-- ГЛАВНЫЙ ФРЕЙМ
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 800, 0, 600)
frame.Position = UDim2.new(0.5, -400, 0.5, -300)
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
    Size = UDim2.new(0, 800, 0, 600),
    Position = UDim2.new(0.5, -400, 0.5, -300)
}, 0.6, Enum.EasingStyle.Back)

-- ЗАГОЛОВОК
local tBar = Instance.new("Frame")
tBar.Size = UDim2.new(1, 0, 0, 60)
tBar.BackgroundColor3 = C.panel
tBar.BackgroundTransparency = 0.04
tBar.BorderSizePixel = 0
tBar.Active = true
tBar.ZIndex = 2
tBar.Parent = frame
crn(tBar, 10)
grd(tBar, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 14, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 10, 16))
})

local logo = Instance.new("Frame")
logo.Size = UDim2.new(0, 40, 0, 40)
logo.Position = UDim2.new(0, 15, 0.5, -20)
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
logoX.TextSize = 26
logoX.TextColor3 = C.wht
logoX.ZIndex = 4
logoX.Parent = logo

local tLbl = Instance.new("TextLabel")
tLbl.Size = UDim2.new(1, -150, 1, 0)
tLbl.Position = UDim2.new(0, 65, 0, 0)
tLbl.BackgroundTransparency = 1
tLbl.Text = "XDarkHUB"
tLbl.Font = Enum.Font.GothamBlack
tLbl.TextSize = 24
tLbl.TextColor3 = A.lit
tLbl.TextXAlignment = Enum.TextXAlignment.Left
tLbl.ZIndex = 3
tLbl.Parent = tBar

local sep1 = Instance.new("Frame")
sep1.Size = UDim2.new(0, 1, 0, 30)
sep1.Position = UDim2.new(0, 60, 0.5, -15)
sep1.BackgroundColor3 = A.base
sep1.BackgroundTransparency = 0.5
sep1.BorderSizePixel = 0
sep1.ZIndex = 3
sep1.Parent = tBar

local vLbl = Instance.new("TextLabel")
vLbl.Size = UDim2.new(0, 80, 1, 0)
vLbl.Position = UDim2.new(1, -90, 0, 0)
vLbl.BackgroundTransparency = 1
vLbl.Text = "[v33]"
vLbl.Font = Enum.Font.Code
vLbl.TextSize = 12
vLbl.TextColor3 = C.mut
vLbl.TextXAlignment = Enum.TextXAlignment.Right
vLbl.ZIndex = 3
vLbl.Parent = tBar

-- ПЕРЕТАСКИВАНИЕ
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

-- КОНТЕЙНЕР
local ctr = Instance.new("Frame")
ctr.Size = UDim2.new(1, 0, 1, -65)
ctr.Position = UDim2.new(0, 0, 0, 65)
ctr.BackgroundTransparency = 1
ctr.Parent = frame

local lPan = Instance.new("Frame")
lPan.Size = UDim2.new(0, 200, 1, 0)
lPan.BackgroundColor3 = C.panel
lPan.BackgroundTransparency = 0.04
lPan.BorderSizePixel = 0
lPan.ZIndex = 2
lPan.Parent = ctr

local vLine = Instance.new("Frame")
vLine.Size = UDim2.new(0, 1, 1, 0)
vLine.Position = UDim2.new(0, 200, 0, 0)
vLine.BackgroundColor3 = A.base
vLine.BackgroundTransparency = 0.65
vLine.BorderSizePixel = 0
vLine.ZIndex = 3
vLine.Parent = ctr

local rPan = Instance.new("Frame")
rPan.Size = UDim2.new(1, -205, 1, 0)
rPan.Position = UDim2.new(0, 205, 0, 0)
rPan.BackgroundTransparency = 1
rPan.ZIndex = 2
rPan.Parent = ctr

-- ВКЛАДКИ
local tabs = {}
local tabContents = {}
local currentTab = nil

local function createTab(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 55)
    btn.Position = UDim2.new(0, 10, 0, 15 + (order - 1) * 60)
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
    ind.Size = UDim2.new(0, 3, 0, 30)
    ind.Position = UDim2.new(0, 0, 0.5, -15)
    ind.BackgroundColor3 = A.base
    ind.BackgroundTransparency = 1
    ind.BorderSizePixel = 0
    ind.ZIndex = 6
    ind.Parent = btn
    crn(ind, 2)
    
    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(0, 40, 1, 0)
    ic.Position = UDim2.new(0, 15, 0, 0)
    ic.BackgroundTransparency = 1
    ic.Text = icon
    ic.Font = Enum.Font.GothamBold
    ic.TextSize = 22
    ic.TextColor3 = C.mut
    ic.ZIndex = 6
    ic.Parent = btn
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 55, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextColor3 = C.mut
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6
    lbl.Parent = btn
    
    tabs[name] = {btn = btn, ic = ic, ind = ind, lbl = lbl}
    
    btn.MouseEnter:Connect(function()
        if currentTab ~= name then
            ani(btn, {BackgroundTransparency = 0.3}, 0.15)
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
    p.PaddingLeft = UDim.new(0, 25)
    p.PaddingRight = UDim.new(0, 25)
    p.PaddingTop = UDim.new(0, 20)
    p.PaddingBottom = UDim.new(0, 20)
    local l = Instance.new("UIListLayout", c)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 12)
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
        tabs[name].btn.BackgroundTransparency = 0.35
        tabs[name].btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        tabs[name].ic.TextColor3 = A.neo
        tabs[name].lbl.TextColor3 = C.wht
        tabs[name].ind.BackgroundTransparency = 0
        tabs[name].ind.BackgroundColor3 = A.neo
    end
    for n, c in pairs(tabContents) do
        if n == name then
            c.Visible = true
            c.Position = UDim2.new(0, 50, 0, 0)
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

for n in pairs(tabs) do createTabContent(n) end
for n, t in pairs(tabs) do
    t.btn.MouseButton1Click:Connect(function()
        clickSnd:Play()
        switchTab(n)
    end)
end

-- UI КОМПОНЕНТЫ
local function secT(par, ord, txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 26)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = A.soft
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
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
    r.Size = UDim2.new(1, 0, 0, 40)
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
    n.Position = UDim2.new(0, 18, 0, 0)
    n.BackgroundTransparency = 1
    n.Text = name
    n.TextColor3 = C.mut
    n.Font = Enum.Font.Gotham
    n.TextSize = 14
    n.TextXAlignment = Enum.TextXAlignment.Left
    n.ZIndex = 2
    n.Parent = r
    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(0.4, -18, 1, 0)
    v.Position = UDim2.new(0.6, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text = "0"
    v.TextColor3 = A.lit
    v.Font = Enum.Font.GothamBold
    v.TextSize = 15
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.ZIndex = 2
    v.Parent = r
    return v
end

local function togC(par, ord, label, onTog)
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(1, 0, 0, 52)
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
    lbl.Size = UDim2.new(1, -110, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.txt
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 2
    lbl.Parent = cd
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 60, 0, 30)
    sw.Position = UDim2.new(1, -68, 0.5, -15)
    sw.BackgroundColor3 = C.bdr
    sw.BorderSizePixel = 0
    sw.ZIndex = 2
    sw.Parent = cd
    crn(sw, 15)
    stk(sw, Color3.fromRGB(55, 55, 70), 1)
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 20, 0, 20)
    ind.Position = UDim2.new(0, 5, 0.5, -10)
    ind.BackgroundColor3 = C.mut
    ind.BorderSizePixel = 0
    ind.ZIndex = 2
    ind.Parent = sw
    crn(ind, 10)
    local pl = Instance.new("TextLabel")
    pl.Size = UDim2.new(1, 0, 1, 0)
    pl.Position = UDim2.new(0, 28, 0, 0)
    pl.BackgroundTransparency = 1
    pl.Text = "OFF"
    pl.TextColor3 = C.mut
    pl.Font = Enum.Font.GothamBold
    pl.TextSize = 11
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
            ani(ind, {Position = UDim2.new(0, 35, 0.5, -10), BackgroundColor3 = A.neo}, 0.25, Enum.EasingStyle.Back)
            pl.Text = "ON"
            ani(pl, {TextColor3 = A.lit}, 0.2)
            ani(cd, {BackgroundColor3 = Color3.fromRGB(20, 16, 22), BackgroundTransparency = 0.5}, 0.2)
        else
            ani(sw, {BackgroundColor3 = C.bdr}, 0.2)
            sw.UIStroke.Color = Color3.fromRGB(55, 55, 70)
            ani(ind, {Position = UDim2.new(0, 5, 0.5, -10), BackgroundColor3 = C.mut}, 0.25, Enum.EasingStyle.Back)
            pl.Text = "OFF"
            ani(pl, {TextColor3 = C.mut}, 0.2)
            cd.BackgroundTransparency = 1
        end
        if onTog then onTog(st) end
    end)
    btn.MouseEnter:Connect(function() if not st then ani(cd, {BackgroundColor3 = Color3.fromRGB(18, 18, 24), BackgroundTransparency = 0.5}, 0.15) end end)
    btn.MouseLeave:Connect(function() if not st then cd.BackgroundTransparency = 1 end end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  КОНТЕНТ ВКЛАДОК
-- ═══════════════════════════════════════════════════════════════════════════════

-- ESP TAB
local espC = tabContents["ESP"]
secT(espC, 1, "VISUAL")
togC(espC, 2, "ESP Roles", function(s) espEnabled = s; notify("XDarkHUB", "ESP: " .. (s and "ВКЛ" or "ВЫКЛ"), 2) end)
togC(espC, 3, "🪤 Trap ESP", function(s) trapESPEnabled = s; notify("XDarkHUB", "🪤 Trap ESP: " .. (s and "ВКЛ" or "ВЫКЛ"), 2) end)
togC(espC, 4, "🔫 Gun ESP", function(s) gunESPEnabled = s; notify("XDarkHUB", "🔫 Gun ESP: " .. (s and "ВКЛ" or "ВЫКЛ"), 2) end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  SHERIFF TAB (С FLOATING BUTTONS)
-- ═══════════════════════════════════════════════════════════════════════════════
local sheriffC = tabContents["Sheriff"]
secT(sheriffC, 1, "⭐ SHERIFF TOOLS")

-- TP TO GUN BUTTON
do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 52)
    b.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    b.Text = "🔫 TP TO GUN"
    b.TextColor3 = Color3.fromRGB(0, 0, 0)
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 16
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.LayoutOrder = 2
    b.ZIndex = 2
    b.Active = true
    b.Parent = sheriffC
    crn(b, 10)
    stk(b, Color3.fromRGB(200, 200, 0), 1.5)
    b.MouseEnter:Connect(function() ani(b, {BackgroundColor3 = Color3.fromRGB(255, 200, 0)}, 0.15) end)
    b.MouseLeave:Connect(function() ani(b, {BackgroundColor3 = Color3.fromRGB(255, 255, 0)}, 0.15) end)
    b.MouseButton1Click:Connect(function() clickSnd:Play(); teleportToGun() end)
end

-- TP TO GUN FLOATING BUTTON TOGGLE
do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 52)
    b.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
    b.Text = "📌 TOGGLE TP BUTTON ON SCREEN"
    b.TextColor3 = COL.wht
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 14
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.LayoutOrder = 3
    b.ZIndex = 2
    b.Active = true
    b.Parent = sheriffC
    crn(b, 10)
    stk(b, Color3.fromRGB(150, 150, 0), 1.5)
    b.MouseEnter:Connect(function() ani(b, {BackgroundColor3 = Color3.fromRGB(150, 150, 0)}, 0.15) end)
    b.MouseLeave:Connect(function() ani(b, {BackgroundColor3 = Color3.fromRGB(100, 100, 0)}, 0.15) end)
    b.MouseButton1Click:Connect(function()
        clickSnd:Play()
        if floatingButtons["TP_TO_GUN"] then
            removeFloatingButton("TP_TO_GUN")
        else
            createFloatingButton("TP_TO_GUN", "🔫 TP TO GUN", Color3.fromRGB(255, 255, 0), teleportToGun, UDim2.new(0, 125, 0, 90))
        end
    end)
end

-- SHOOT MURDERER BUTTON
do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 52)
    b.BackgroundColor3 = A.base
    b.Text = "🔫 SHOOT MURDERER"
    b.TextColor3 = COL.wht
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 16
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.LayoutOrder = 4
    b.ZIndex = 2
    b.Active = true
    b.Parent = sheriffC
    crn(b, 10)
    stk(b, A.neo, 1.5)
    b.MouseEnter:Connect(function() ani(b, {BackgroundColor3 = A.neo}, 0.15) end)
    b.MouseLeave:Connect(function() ani(b, {BackgroundColor3 = A.base}, 0.15) end)
    b.MouseButton1Click:Connect(function() clickSnd:Play(); shootMurderer() end)
end

-- SHOOT MURDERER FLOATING BUTTON TOGGLE
do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 52)
    b.BackgroundColor3 = Color3.fromRGB(100, 20, 30)
    b.Text = "📌 TOGGLE SHOOT BUTTON ON SCREEN"
    b.TextColor3 = COL.wht
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 14
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.LayoutOrder = 5
    b.ZIndex = 2
    b.Active = true
    b.Parent = sheriffC
    crn(b, 10)
    stk(b, Color3.fromRGB(150, 30, 40), 1.5)
    b.MouseEnter:Connect(function() ani(b, {BackgroundColor3 = Color3.fromRGB(150, 30, 40)}, 0.15) end)
    b.MouseLeave:Connect(function() ani(b, {BackgroundColor3 = Color3.fromRGB(100, 20, 30)}, 0.15) end)
    b.MouseButton1Click:Connect(function()
        clickSnd:Play()
        if floatingButtons["SHOOT_MURDERER"] then
            removeFloatingButton("SHOOT_MURDERER")
        else
            createFloatingButton("SHOOT_MURDERER", "🔫 SHOOT MURDERER", A.base, shootMurderer, UDim2.new(0, 125, 0, 150))
        end
    end)
end

-- FLING SHERIFF BUTTON
do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 52)
    b.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    b.Text = "⭐ FLING SHERIFF"
    b.TextColor3 = COL.wht
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 16
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.LayoutOrder = 6
    b.ZIndex = 2
    b.Active = true
    b.Parent = sheriffC
    crn(b, 10)
    stk(b, Color3.fromRGB(100, 200, 255), 1.5)
    b.MouseEnter:Connect(function() ani(b, {BackgroundColor3 = Color3.fromRGB(100, 200, 255)}, 0.15) end)
    b.MouseLeave:Connect(function() ani(b, {BackgroundColor3 = Color3.fromRGB(50, 150, 255)}, 0.15) end)
    b.MouseButton1Click:Connect(function() clickSnd:Play(); flingSheriff() end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  FARM TAB
-- ═══════════════════════════════════════════════════════════════════════════════
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

-- FLING MURDERER BUTTON
do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 52)
    b.BackgroundColor3 = A.base
    b.Text = "🔪 FLING MURDERER"
    b.TextColor3 = COL.wht
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 16
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.LayoutOrder = 10
    b.ZIndex = 2
    b.Active = true
    b.Parent = fC
    crn(b, 10)
    stk(b, A.neo, 1.5)
    b.MouseEnter:Connect(function() ani(b, {BackgroundColor3 = A.neo}, 0.15) end)
    b.MouseLeave:Connect(function() ani(b, {BackgroundColor3 = A.base}, 0.15) end)
    b.MouseButton1Click:Connect(function() clickSnd:Play(); throwMurdererToSpace() end)
end

-- AUTO FARM TOGGLE
togC(fC, 11, "Auto Farm", function(s) isActive = s; if s then notify("XDarkHUB", "Фарм ВКЛ", 2) else notify("XDarkHUB", "Фарм ВЫКЛ", 2) end end)
togC(fC, 12, "Anti-AFK", function(s) antiAFK = s; notify("XDarkHUB", "Anti-AFK: " .. (s and "ВКЛ" or "ВЫКЛ"), 2) end)

-- ЗАГЛУШКИ
for _, name in ipairs({"Murderer", "Player"}) do
    local c = tabContents[name]
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 35)
    t.BackgroundTransparency = 1
    t.Text = name:upper()
    t.TextColor3 = A.soft
    t.Font = Enum.Font.GothamBlack
    t.TextSize = 20
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.LayoutOrder = 1
    t.ZIndex = 2
    t.Parent = c
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(1, 0, 0, 120)
    cd.BackgroundTransparency = 1
    cd.LayoutOrder = 2
    cd.ZIndex = 2
    cd.Parent = c
    crn(cd, 10)
    stk(cd, C.bdr, 1, 0.5)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -25, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Coming Soon"
    lbl.TextColor3 = C.mut
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 2
    lbl.Parent = cd
end

-- ФУНКЦИИ UI
function updateRoleUI()
    checkRole()
    if isMurderer then roleV.Text = "Murderer"; roleV.TextColor3 = Color3.fromRGB(255, 50, 50)
    elseif isSheriff then roleV.Text = "Sheriff"; roleV.TextColor3 = Color3.fromRGB(50, 150, 255)
    else roleV.Text = "Innocent"; roleV.TextColor3 = Color3.fromRGB(50, 255, 50) end
end

function updateBagUI()
    local cc = getCollectedCoins()
    if farmStopped then bagV.Text = "Stopped"; bagV.TextColor3 = Color3.fromRGB(255, 80, 80)
    elseif cc >= MAX_BAG then bagV.Text = "Full"; bagV.TextColor3 = Color3.fromRGB(255, 200, 0)
    else bagV.Text = cc .. "/" .. MAX_BAG; bagV.TextColor3 = A.lit end
end

function stopFarming() farmStopped = true; updateBagUI(); notify("XDarkHUB", "🛑 Фарм остановлен", 2) end

-- ФАРМ
function flyTo(pos, spd)
    if not rootPart or farmStopped then return false end
    local d = (pos - rootPart.Position).Magnitude; local dur = math.max(0.1, d / spd)
    local tw = TweenService:Create(rootPart, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)}); tw:Play()
    local c = false; local to = task.delay(dur + 2, function() c = true; tw:Cancel() end)
    tw.Completed:Wait(); if not c then task.cancel(to) end; return not c
end

function startFarming()
    initialCoins = getPlayerCoins(player); startTime = tick(); visitedPositions = {}; bagFull = false; farmStopped = false
    counterV.Text = "0"; timerV.Text = "0s"; rateV.Text = "0"; updateRoleUI(); updateBagUI()
    notify("XDarkHUB", "Фарм ВКЛ", 2); notify("XDarkHUB", "Старт: " .. initialCoins .. " монет", 3)
    task.spawn(function()
        while isActive do
            local e = tick() - startTime; timerV.Text = math.floor(e) .. "s"
            local cc = getCollectedCoins(); rateV.Text = tostring(e > 0 and math.floor(cc / e * 3600) or 0)
            pCoinV.Text = tostring(getPlayerCoins(player)); task.wait(0.1)
        end
    end)
    task.spawn(function()
        while isActive do
            task.wait(0.5); local cc = getCollectedCoins(); counterV.Text = tostring(cc)
            if cc >= MAX_BAG and not farmStopped then
                notify("XDarkHUB", "Мешок полон!", 3); bagFull = true; farmStopped = true; updateBagUI(); checkRole()
                if isMurderer then throwMurdererToSpace() else throwMurdererToSpace() end
                stopFarming()
            end
        end
    end)
    task.spawn(function()
        while isActive do
            if farmStopped then task.wait(1) continue end
            character = player.Character; if not character then task.wait(0.5) continue end
            rootPart = character:FindFirstChild("HumanoidRootPart"); if not rootPart then task.wait(0.5) continue end
            checkRole()
            local cl, sh = nil, math.huge
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("BasePart") and o.Name == "Coin_Server" then
                    local ic = false
                    for _, p in ipairs(Players:GetPlayers()) do if p.Character and o:IsDescendantOf(p.Character) then ic = true; break end end
                    if not ic and o.Parent and o:IsDescendantOf(workspace) and not visitedPositions[o] then
                        local d = (o.Position - rootPart.Position).Magnitude
                        if d < sh and d < 300 then cl = o; sh = d end
                    end
                end
            end
            if cl then
                local cp = cl.Position; local cr = cl
                if farmStopped then continue end
                if flyTo(cp, flySpeed) and not farmStopped then
                    task.wait(0.3)
                    if cr.Parent and cr:IsDescendantOf(workspace) then
                        local ic = false
                        for _, p in ipairs(Players:GetPlayers()) do if p.Character and cr:IsDescendantOf(p.Character) then ic = true; break end end
                        if not ic and (cr.Position - rootPart.Position).Magnitude < 5 then collectSound:Play(); updateBagUI(); visitedPositions[cr] = true
                        else visitedPositions[cr] = true end
                    else visitedPositions[cr] = true end
                end
            else if next(visitedPositions) then visitedPositions = {} end; task.wait(1) end
            task.wait(0.1)
        end
    end)
end

-- КНОПКА МЕНЮ
local mBtn = Instance.new("TextButton")
mBtn.Size = UDim2.new(0, 70, 0, 70)
mBtn.Position = UDim2.new(0, 20, 1, -90)
mBtn.BackgroundColor3 = A.base
mBtn.Text = "X"
mBtn.TextColor3 = COL.wht
mBtn.Font = Enum.Font.GothamBlack
mBtn.TextSize = 30
mBtn.BorderSizePixel = 0
mBtn.ZIndex = 10
mBtn.Active = true
mBtn.AutoButtonColor = false
mBtn.Parent = gui
crn(mBtn, 35)
stk(mBtn, A.neo, 1.5, 0.4)

task.spawn(function()
    while mBtn.Parent do
        ani(mBtn, {Size = UDim2.new(0, 75, 0, 75)}, 1.5, Enum.EasingStyle.Sine); task.wait(1.5)
        ani(mBtn, {Size = UDim2.new(0, 70, 0, 70)}, 1.5, Enum.EasingStyle.Sine); task.wait(1.5)
    end
end)

do
    local dr, ds, sp = false, nil, nil
    mBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dr = true; ds = i.Position; sp = mBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            mBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dr = false end
    end)
end

mBtn.MouseButton1Click:Connect(function()
    clickSnd:Play()
    local v = frame.Visible
    frame.Visible = not v
    bgF.Visible = not v
end)

player.CharacterAdded:Connect(function(ch)
    character = ch; rootPart = ch:WaitForChild("HumanoidRootPart")
    visitedPositions = {}; farmStopped = false
    task.wait(1.5); checkRole(); updateRoleUI()
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

updateRoleUI(); updateBagUI(); switchTab("Sheriff")
notify("XDarkHUB", "v33 загружен!", 3)
notify("XDarkHUB", "⭐ Sheriff floating buttons!", 3)
