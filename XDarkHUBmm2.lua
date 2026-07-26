-- XDarkHUB v34 · FIXED (по структуре YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
--  ИНИЦИАЛИЗАЦИЯ СЕРВИСОВ
-- ═══════════════════════════════════════════════════════════════════════════════
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local localplayer = player

-- ═══════════════════════════════════════════════════════════════════════════════
--  СОЗДАНИЕ GUI (САМОЕ ПЕРВОЕ!)
-- ═══════════════════════════════════════════════════════════════════════════════
local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("XDarkHUB_GUI")
if oldGui then oldGui:Destroy() end

local guiUI = Instance.new("ScreenGui")
guiUI.Name = "XDarkHUB_GUI"
guiUI.ResetOnSpawn = false
guiUI.IgnoreGuiInset = true
guiUI.DisplayOrder = 999
guiUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Антидетект (как в YARHM)
local success, err = pcall(function()
    if gethui then
        guiUI.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(guiUI)
        guiUI.Parent = game:GetService("CoreGui")
    else
        guiUI.Parent = player:WaitForChild("PlayerGui")
    end
end)

if not success then
    guiUI.Parent = player:WaitForChild("PlayerGui")
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ПЕРЕМЕННЫЕ
-- ═══════════════════════════════════════════════════════════════════════════════
local visitedPositions = {}
local isActive = false
local flySpeed = 16
local initialCoins = 0
local startTime = 0
local antiAFK = false
local isMurderer = false
local isSheriff = false
local farmStopped = false
local MAX_BAG = 40

local playerESP = false
local autoShooting = false
local shootOffset = 2.8
local offsetToPingMult = 1
local gunDropESP = false
local trapDetection = false
local autoGetDroppedGun = false
local playerData = {}
local hideMeEsp = false
local instakillshoot = false
local spawnAtPlayer = false
local loopThrow = false
local ignoreknifethrow = false
local killAuraCon = nil

local espHighlights = {}
local floatingButtons = {}

-- ═══════════════════════════════════════════════════════════════════════════════
--  ЗВУКИ
-- ═══════════════════════════════════════════════════════════════════════════════
local clickSnd = Instance.new("Sound")
clickSnd.SoundId = "rbxassetid://169759176"
clickSnd.Volume = 0.25
clickSnd.Parent = guiUI

local collectSound = Instance.new("Sound")
collectSound.SoundId = "rbxassetid://12221967"
collectSound.Volume = 1
collectSound.Parent = guiUI

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
--  БАЗОВЫЕ ФУНКЦИИ MM2
-- ═══════════════════════════════════════════════════════════════════════════════
local function findMurderer()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Knife") then return i end
    end
    for _, i in ipairs(Players:GetPlayers()) do
        if not i.Character then continue end
        if i.Character:FindFirstChild("Knife") then return i end
    end
    if playerData then
        for pl, data in pairs(playerData) do
            if data.Role == "Murderer" then
                if Players:FindFirstChild(pl) then return Players:FindFirstChild(pl) end
            end
        end
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
    if playerData then
        for pl, data in pairs(playerData) do
            if data.Role == "Sheriff" then
                if Players:FindFirstChild(pl) then return Players:FindFirstChild(pl) end
            end
        end
    end
    return nil
end

local function findSheriffThatsNotMe()
    for _, i in ipairs(Players:GetPlayers()) do
        if i == localplayer then continue end
        if i.Backpack:FindFirstChild("Gun") then return i end
    end
    for _, i in ipairs(Players:GetPlayers()) do
        if i == localplayer then continue end
        if not i.Character then continue end
        if i.Character:FindFirstChild("Gun") then return i end
    end
    return nil
end

local function getMap()
    for _, o in ipairs(workspace:GetChildren()) do
        if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then
            return o
        end
    end
    return nil
end

local function findNearestPlayer()
    local nearestPlayer = nil
    local shortestDistance = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localplayer and p.Character then
            local localRootPart = localplayer.Character:FindFirstChild("HumanoidRootPart")
            local otherRootPart = p.Character:FindFirstChild("HumanoidRootPart")
            if localRootPart and otherRootPart then
                local distance = (localRootPart.Position - otherRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestPlayer = p
                end
            end
        end
    end
    return nearestPlayer
end

local function getPredictedPosition(targetPlayer)
    local p = targetPlayer
    pcall(function() p = targetPlayer.Character end)
    local playerHRP = p:FindFirstChild("UpperTorso") or p:FindFirstChild("HumanoidRootPart")
    local playerHum = p:FindFirstChild("Humanoid")
    if not playerHRP or not playerHum then return Vector3.new(0,0,0) end
    local velocity = playerHRP.AssemblyLinearVelocity
    local playerMoveDirection = playerHum.MoveDirection
    local predictedPosition = playerHRP.Position + ((velocity * Vector3.new(0.75, 0.5, 0.75))) * (shootOffset / 15) + playerMoveDirection * shootOffset
    predictedPosition = predictedPosition * (((localplayer:GetNetworkPing() * 1000) * ((offsetToPingMult - 1) * 0.01)) + 1)
    return predictedPosition
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ESP ФУНКЦИИ
-- ═══════════════════════════════════════════════════════════════════════════════
local function reloadESP()
    for key, h in pairs(espHighlights) do
        if h and h:IsA("Highlight") then h:Destroy() end
    end
    espHighlights = {}
    if not playerESP then return end
    
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == localplayer and hideMeEsp then continue end
        local ch = pl.Character
        if ch and ch:FindFirstChild("HumanoidRootPart") then
            task.spawn(function()
                local color
                if pl == findMurderer() then
                    color = Color3.fromRGB(255, 0, 4)
                elseif pl == findSheriff() then
                    color = Color3.fromRGB(0, 153, 255)
                else
                    color = Color3.fromRGB(0, 255, 8)
                end
                
                local h = Instance.new("Highlight")
                h.FillColor = color
                h.OutlineColor = color
                h.FillTransparency = 0.5
                h.OutlineTransparency = 0
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Adornee = ch
                h.Parent = guiUI
                espHighlights[ch] = h
            end)
        end
    end
end

local function reloadTrapESP()
    for key, obj in pairs(espHighlights) do
        if obj and obj.Name and obj.Name:find("Trap") then
            obj:Destroy()
            espHighlights[key] = nil
        end
    end
    if not trapDetection then return end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "Trap" and (v.Parent:IsA("Folder") or v.Parent:IsA("Model")) then
            v.Transparency = 0
            local h = Instance.new("Highlight")
            h.Name = "TrapESP_" .. tostring(v)
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.OutlineColor = Color3.fromRGB(255, 0, 0)
            h.FillTransparency = 0.5
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Adornee = v
            h.Parent = guiUI
            espHighlights[v] = h
        end
    end
end

local function reloadGunESP()
    for key, obj in pairs(espHighlights) do
        if obj and obj.Name and obj.Name:find("Gun") then
            obj:Destroy()
            espHighlights[key] = nil
        end
    end
    if not gunDropESP then return end
    local map = getMap()
    if map and map:FindFirstChild("GunDrop") then
        local gun = map:FindFirstChild("GunDrop")
        local h = Instance.new("Highlight")
        h.Name = "GunESP_" .. tostring(gun)
        h.FillColor = Color3.fromRGB(255, 255, 0)
        h.OutlineColor = Color3.fromRGB(255, 255, 0)
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee = gun
        h.Parent = guiUI
        espHighlights[gun] = h
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ДЕЙСТВИЯ
-- ═══════════════════════════════════════════════════════════════════════════════
local function shootMurderer()
    if findSheriff() ~= localplayer then
        notify("XDarkHUB", "You're not sheriff.")
        return
    end
    local murderer = findMurderer() or findSheriffThatsNotMe()
    if not murderer then
        notify("XDarkHUB", "No murderer.")
        return
    end
    if not localplayer.Character:FindFirstChild("Gun") then
        local hum = localplayer.Character:FindFirstChild("Humanoid")
        if localplayer.Backpack:FindFirstChild("Gun") then
            hum:EquipTool(localplayer.Backpack:FindFirstChild("Gun"))
        else
            notify("XDarkHUB", "You don't have the gun.")
            return
        end
    end
    local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not murdererHRP then return end
    local predictedPosition = getPredictedPosition(murderer)
    local args
    if instakillshoot then
        args = {CFrame.new(murdererHRP.Position + Vector3.new(0,1,0)), CFrame.new(murdererHRP.Position)}
    else
        args = {CFrame.new(localplayer.Character.RightHand.Position), CFrame.new(predictedPosition)}
    end
    pcall(function()
        localplayer.Character:WaitForChild("Gun"):WaitForChild("Shoot"):FireServer(unpack(args))
    end)
    notify("XDarkHUB", "Shot fired!")
end

local function teleportToGun()
    local map = getMap()
    if not map or not map:FindFirstChild("GunDrop") then
        notify("XDarkHUB", "No dropped gun.")
        return
    end
    local previousPosition = localplayer.Character:GetPivot()
    localplayer.Character:PivotTo(map:FindFirstChild("GunDrop"):GetPivot())
    localplayer.Backpack.ChildAdded:Wait()
    localplayer.Character:PivotTo(previousPosition)
    notify("XDarkHUB", "Gun collected!")
end

local function knifeThrow()
    if findMurderer() ~= localplayer then
        notify("XDarkHUB", "Not murderer.")
        return
    end
    if not localplayer.Character:FindFirstChild("Knife") then
        local hum = localplayer.Character:FindFirstChild("Humanoid")
        if localplayer.Backpack:FindFirstChild("Knife") then
            hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
        else
            notify("XDarkHUB", "No knife.")
            return
        end
    end
    local NearestPlayer = findNearestPlayer()
    if not NearestPlayer or not NearestPlayer.Character then return end
    local nearestHRP = NearestPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not nearestHRP then return end
    local argsThrowRemote = {
        CFrame.new(localplayer.Character.RightHand.Position),
        CFrame.new(getPredictedPosition(NearestPlayer))
    }
    if spawnAtPlayer then
        argsThrowRemote[1] = CFrame.new(nearestHRP.Position + (nearestHRP.CFrame.LookVector * 5))
    end
    pcall(function()
        localplayer.Character:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(unpack(argsThrowRemote))
    end)
    notify("XDarkHUB", "Knife thrown!")
end

local function killClosest()
    if findMurderer() ~= localplayer then
        notify("XDarkHUB", "Not murderer.")
        return
    end
    if not localplayer.Character:FindFirstChild("Knife") then
        local hum = localplayer.Character:FindFirstChild("Humanoid")
        if localplayer.Backpack:FindFirstChild("Knife") then
            hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
        else
            notify("XDarkHUB", "No knife.")
            return
        end
    end
    local NearestPlayer = findNearestPlayer()
    if not NearestPlayer or not NearestPlayer.Character then return end
    local nearestHRP = NearestPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not nearestHRP then return end
    nearestHRP.Anchored = true
    nearestHRP.CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 2
    task.wait(0.1)
    pcall(function() localplayer.Character.Knife.Stab:FireServer("Slash") end)
    notify("XDarkHUB", "Killed closest!")
end

local function killEveryone()
    if findMurderer() ~= localplayer then
        notify("XDarkHUB", "Not murderer.")
        return
    end
    if not localplayer.Character:FindFirstChild("Knife") then
        local hum = localplayer.Character:FindFirstChild("Humanoid")
        if localplayer.Backpack:FindFirstChild("Knife") then
            hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
        else
            notify("XDarkHUB", "No knife.")
            return
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= localplayer then
            p.Character:FindFirstChild("HumanoidRootPart").Anchored = true
            p.Character:FindFirstChild("HumanoidRootPart").CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 1
        end
    end
    pcall(function() localplayer.Character.Knife.Stab:FireServer("Slash") end)
    notify("XDarkHUB", "Killed everyone!")
end

local function holdHostage()
    if findMurderer() ~= localplayer then
        notify("XDarkHUB", "Not murderer.")
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= localplayer then
            p.Character:FindFirstChild("HumanoidRootPart").Anchored = true
            p.Character:FindFirstChild("HumanoidRootPart").CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 5
        end
    end
    notify("XDarkHUB", "Hostage!")
end

local function godMode()
    pcall(function()
        local Cam = workspace.CurrentCamera
        local Pos, Char = Cam.CFrame, localplayer.Character
        local Human = Char:FindFirstChildWhichIsA("Humanoid")
        local nHuman = Human:Clone()
        nHuman.Parent = Char
        localplayer.Character = nil
        nHuman:SetStateEnabled(15, false)
        nHuman:SetStateEnabled(1, false)
        nHuman:SetStateEnabled(0, false)
        nHuman.BreakJointsOnDeath = true
        Human:Destroy()
        localplayer.Character = Char
        Cam.CameraSubject = nHuman
        Cam.CFrame = Pos
        nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        local Script = Char:FindFirstChild("Animate")
        if Script then
            Script.Disabled = true
            task.wait()
            Script.Disabled = false
        end
        nHuman.Health = nHuman.MaxHealth
        notify("XDarkHUB", "God mode!")
    end)
end

local function sendNamesToChat()
    local murd = findMurderer()
    local sher = findSheriff()
    local murdName = murd and murd.Name or "-"
    local sherName = sher and sher.Name or "-"
    local message = string.format("Murderer: %s | Sheriff: %s | <<XDarkHUB>>", murdName, sherName)
    pcall(function()
        local textchannels = TextChatService:WaitForChild("TextChannels"):GetChildren()
        for _, textchannel in ipairs(textchannels) do
            if textchannel.Name == "RBXSystem" then continue end
            pcall(function() textchannel:SendAsync(message) end)
        end
    end)
    notify("XDarkHUB", "Names sent!")
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  MINI FLING
-- ═══════════════════════════════════════════════════════════════════════════════
local function miniFling(playerToFling)
    pcall(function()
        local Character = player.Character
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Humanoid and Humanoid.RootPart
        local TCharacter = playerToFling.Character
        local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
        local TRootPart = THumanoid and THumanoid.RootPart
        local THead = TCharacter:FindFirstChild("Head")
        
        if not (Character and Humanoid and RootPart) then return end
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    Angle = Angle + 100
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                else break end
            until BasePart.Velocity.Magnitude > 500 or tick() > Time + TimeToWait
        end
        
        workspace.FallenPartsDestroyHeight = 0/0
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        
        if TRootPart then SFBasePart(TRootPart)
        elseif THead then SFBasePart(THead) end
        
        BV:Destroy()
        workspace.CurrentCamera.CameraSubject = Humanoid
        
        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            Humanoid:ChangeState("GettingUp")
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  FLOATING BUTTONS (КРАСИВЫЕ ПЕРЕТАСКИВАЕМЫЕ)
-- ═══════════════════════════════════════════════════════════════════════════════
local function createFloatingButton(name, text, callback, position)
    if floatingButtons[name] then
        floatingButtons[name]:Destroy()
        floatingButtons[name] = nil
    end
    
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 160, 0, 55)
    button.Position = position or UDim2.new(0, 125, 0, 90)
    button.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    button.BackgroundTransparency = 0.4
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.ClipsDescendants = true
    button.Parent = guiUI
    
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", button)
    stroke.Color = Color3.fromRGB(255, 50, 80)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    
    local grad = Instance.new("UIGradient", button)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 80)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 30, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 150, 255))
    }
    grad.Rotation = 45
    grad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(0.5, 0.85),
        NumberSequenceKeypoint.new(1, 0.7)
    }
    
    task.spawn(function()
        local rot = 45
        while button.Parent do
            rot = rot + 0.5
            grad.Rotation = rot
            task.wait(0.05)
        end
    end)
    
    button.MouseButton1Click:Connect(function()
        clickSnd:Play()
        callback()
    end)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.3}):Play()
    end)
    
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
    
    floatingButtons[name] = button
    return button
end

local function removeFloatingButton(name)
    if floatingButtons[name] then
        floatingButtons[name]:Destroy()
        floatingButtons[name] = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  UI КОМПОНЕНТЫ
-- ═══════════════════════════════════════════════════════════════════════════════
local C_COL = {
    bg = Color3.fromRGB(8, 8, 12),
    panel = Color3.fromRGB(12, 12, 18),
    card = Color3.fromRGB(18, 18, 26),
    txt = Color3.fromRGB(245, 245, 255),
    mut = Color3.fromRGB(100, 100, 115),
    wht = Color3.fromRGB(255, 255, 255),
}
local A_COL = {
    base = Color3.fromRGB(235, 35, 60),
    lit = Color3.fromRGB(255, 90, 115),
    neo = Color3.fromRGB(255, 35, 62),
}

local function crn(o, r) local c = Instance.new("UICorner", o) c.CornerRadius = UDim.new(0, r or 8) end
local function stk(o, c, t) local s = Instance.new("UIStroke", o) s.Color = c s.Thickness = t or 1 end
local function ani(o, p, t) TweenService:Create(o, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quint), p):Play end

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 800, 0, 600)
frame.Position = UDim2.new(0.5, -400, 0.5, -300)
frame.BackgroundColor3 = C_COL.bg
frame.BackgroundTransparency = 0.03
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.ZIndex = 1
frame.Parent = guiUI
crn(frame, 10)
stk(frame, A_COL.base, 1.5)

-- Header
local tBar = Instance.new("Frame")
tBar.Size = UDim2.new(1, 0, 0, 60)
tBar.BackgroundColor3 = C_COL.panel
tBar.BackgroundTransparency = 0.04
tBar.BorderSizePixel = 0
tBar.Active = true
tBar.ZIndex = 2
tBar.Parent = frame
crn(tBar, 10)

local tLbl = Instance.new("TextLabel")
tLbl.Size = UDim2.new(1, -150, 1, 0)
tLbl.Position = UDim2.new(0, 65, 0, 0)
tLbl.BackgroundTransparency = 1
tLbl.Text = "XDarkHUB v34"
tLbl.Font = Enum.Font.GothamBlack
tLbl.TextSize = 24
tLbl.TextColor3 = A_COL.lit
tLbl.TextXAlignment = Enum.TextXAlignment.Left
tLbl.ZIndex = 3
tLbl.Parent = tBar

-- Dragging
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

-- Container
local ctr = Instance.new("Frame")
ctr.Size = UDim2.new(1, 0, 1, -65)
ctr.Position = UDim2.new(0, 0, 0, 65)
ctr.BackgroundTransparency = 1
ctr.Parent = frame

local lPan = Instance.new("Frame")
lPan.Size = UDim2.new(0, 200, 1, 0)
lPan.BackgroundColor3 = C_COL.panel
lPan.BackgroundTransparency = 0.04
lPan.BorderSizePixel = 0
lPan.ZIndex = 2
lPan.Parent = ctr

local rPan = Instance.new("Frame")
rPan.Size = UDim2.new(1, -205, 1, 0)
rPan.Position = UDim2.new(0, 205, 0, 0)
rPan.BackgroundTransparency = 1
rPan.ZIndex = 2
rPan.Parent = ctr

-- Tabs
local tabs = {}
local tabContents = {}
local currentTab = nil

local function createTab(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 55)
    btn.Position = UDim2.new(0, 10, 0, 15 + (order - 1) * 60)
    btn.BackgroundColor3 = C_COL.card
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.ZIndex = 5
    btn.Active = true
    btn.AutoButtonColor = false
    btn.Parent = lPan
    crn(btn, 10)
    
    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(0, 40, 1, 0)
    ic.Position = UDim2.new(0, 15, 0, 0)
    ic.BackgroundTransparency = 1
    ic.Text = icon
    ic.Font = Enum.Font.GothamBold
    ic.TextSize = 22
    ic.TextColor3 = C_COL.mut
    ic.ZIndex = 6
    ic.Parent = btn
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 55, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextColor3 = C_COL.mut
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6
    lbl.Parent = btn
    
    tabs[name] = {btn = btn, ic = ic, lbl = lbl}
    
    btn.MouseEnter:Connect(function()
        if currentTab ~= name then
            ani(btn, {BackgroundTransparency = 0.3}, 0.15)
            ani(ic, {TextColor3 = C_COL.txt}, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= name then
            ani(btn, {BackgroundTransparency = 1}, 0.15)
            ani(ic, {TextColor3 = C_COL.mut}, 0.15)
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
    c.ScrollBarImageColor3 = A_COL.base
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
        t.btn.BackgroundColor3 = C_COL.card
        t.ic.TextColor3 = C_COL.mut
        t.lbl.TextColor3 = C_COL.mut
    end
    if tabs[name] then
        tabs[name].btn.BackgroundTransparency = 0.35
        tabs[name].btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        tabs[name].ic.TextColor3 = A_COL.neo
        tabs[name].lbl.TextColor3 = C_COL.wht
    end
    for n, c in pairs(tabContents) do
        c.Visible = (n == name)
    end
    currentTab = name
end

createTab("Sheriff", "⭐", 1)
createTab("Murderer", "🔪", 2)
createTab("ESP", "👁️", 3)
createTab("Farm", "⚙️", 4)

for n in pairs(tabs) do createTabContent(n) end
for n, t in pairs(tabs) do
    t.btn.MouseButton1Click:Connect(function()
        clickSnd:Play()
        switchTab(n)
    end)
end

-- UI Components
local function secT(par, ord, txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 26)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = A_COL.lit
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = ord
    l.ZIndex = 2
    l.Parent = par
end

local function togC(par, ord, label, onTog)
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(1, 0, 0, 52)
    cd.BackgroundTransparency = 1
    cd.LayoutOrder = ord
    cd.ZIndex = 2
    cd.Parent = par
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -110, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C_COL.txt
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 2
    lbl.Parent = cd
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 60, 0, 30)
    sw.Position = UDim2.new(1, -68, 0.5, -15)
    sw.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sw.BorderSizePixel = 0
    sw.ZIndex = 2
    sw.Parent = cd
    crn(sw, 15)
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 20, 0, 20)
    ind.Position = UDim2.new(0, 5, 0.5, -10)
    ind.BackgroundColor3 = C_COL.wht
    ind.BorderSizePixel = 0
    ind.ZIndex = 2
    ind.Parent = sw
    crn(ind, 10)
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
            ani(sw, {BackgroundColor3 = A_COL.base}, 0.2)
            ani(ind, {Position = UDim2.new(0, 35, 0.5, -10), BackgroundColor3 = A_COL.neo}, 0.25, Enum.EasingStyle.Back)
        else
            ani(sw, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, 0.2)
            ani(ind, {Position = UDim2.new(0, 5, 0.5, -10), BackgroundColor3 = C_COL.wht}, 0.25, Enum.EasingStyle.Back)
        end
        if onTog then onTog(st) end
    end)
end

local function mkBtn(par, ord, text, color, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 52)
    b.BackgroundColor3 = color or A_COL.base
    b.Text = text
    b.TextColor3 = C_COL.wht
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 15
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.LayoutOrder = ord
    b.ZIndex = 2
    b.Active = true
    b.Parent = par
    crn(b, 10)
    stk(b, A_COL.neo, 1.5)
    b.MouseEnter:Connect(function() ani(b, {BackgroundColor3 = A_COL.neo}, 0.15) end)
    b.MouseLeave:Connect(function() ani(b, {BackgroundColor3 = color or A_COL.base}, 0.15) end)
    b.MouseButton1Click:Connect(function()
        clickSnd:Play()
        callback()
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  TAB CONTENT - SHERIFF
-- ═══════════════════════════════════════════════════════════════════════════════
local sheriffC = tabContents["Sheriff"]
secT(sheriffC, 1, "⭐ SHERIFF TOOLS")

mkBtn(sheriffC, 2, "🔫 SHOOT MURDERER", A_COL.base, shootMurderer)
mkBtn(sheriffC, 3, "🔫 TP TO DROPPED GUN", Color3.fromRGB(255, 200, 0), teleportToGun)
mkBtn(sheriffC, 4, "📌 FLOATING: TP TO GUN", Color3.fromRGB(100, 100, 0), function()
    if floatingButtons["TP_TO_GUN"] then
        removeFloatingButton("TP_TO_GUN")
    else
        createFloatingButton("TP_TO_GUN", "🔫 TP TO GUN", teleportToGun, UDim2.new(0, 125, 0, 90))
    end
end)
mkBtn(sheriffC, 5, "📌 FLOATING: SHOOT", Color3.fromRGB(100, 20, 30), function()
    if floatingButtons["SHOOT_MURDERER"] then
        removeFloatingButton("SHOOT_MURDERER")
    else
        createFloatingButton("SHOOT_MURDERER", "🔫 SHOOT MURDERER", shootMurderer, UDim2.new(0, 125, 0, 150))
    end
end)

togC(sheriffC, 6, "Auto Shoot Murderer", function(s) autoShooting = s end)
togC(sheriffC, 7, "Auto Get Gun On Drop", function(s) autoGetDroppedGun = s end)
togC(sheriffC, 8, "Instakill Murderer", function(s) instakillshoot = s end)
mkBtn(sheriffC, 9, "📋 SEND NAMES TO CHAT", Color3.fromRGB(50, 100, 200), sendNamesToChat)

-- ═══════════════════════════════════════════════════════════════════════════════
--  TAB CONTENT - MURDERER
-- ═══════════════════════════════════════════════════════════════════════════════
local murdererC = tabContents["Murderer"]
secT(murdererC, 1, "🔪 MURDERER TOOLS")

mkBtn(murdererC, 2, "🔪 KNIFE THROW TO CLOSEST", A_COL.base, knifeThrow)
mkBtn(murdererC, 3, "💀 KILL CLOSEST PLAYER", Color3.fromRGB(200, 0, 0), killClosest)
mkBtn(murdererC, 4, "💀 KILL EVERYONE", Color3.fromRGB(150, 0, 0), killEveryone)
mkBtn(murdererC, 5, "🔒 HOLD EVERYONE HOSTAGE", Color3.fromRGB(100, 0, 50), holdHostage)

togC(murdererC, 6, "Auto Knife Throw", function(s) loopThrow = s end)
togC(murdererC, 7, "Spawn Knife Near Player", function(s) spawnAtPlayer = s end)
togC(murdererC, 8, "Ignore Knife Throws", function(s) ignoreknifethrow = s end)
mkBtn(murdererC, 9, "⚡ GOD MODE", Color3.fromRGB(150, 0, 150), godMode)

-- ═══════════════════════════════════════════════════════════════════════════════
--  TAB CONTENT - ESP
-- ═══════════════════════════════════════════════════════════════════════════════
local espC = tabContents["ESP"]
secT(espC, 1, "👁️ ESP TOGGLES")

togC(espC, 2, "Players ESP", function(s)
    playerESP = s
    if s then
        if not findMurderer() and not findSheriff() then
            notify("XDarkHUB", "Waiting for roles...")
        end
        reloadESP()
    else
        for _, h in pairs(espHighlights) do if h then h:Destroy() end end
        espHighlights = {}
    end
end)

togC(espC, 3, "Dropped Gun ESP", function(s)
    gunDropESP = s
    reloadGunESP()
end)

togC(espC, 4, "Traps ESP", function(s)
    trapDetection = s
    reloadTrapESP()
end)

togC(espC, 5, "Hide My Own ESP", function(s)
    hideMeEsp = s
    reloadESP()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  TAB CONTENT - FARM
-- ═══════════════════════════════════════════════════════════════════════════════
local fC = tabContents["Farm"]
secT(fC, 1, "🔪 FLING")

mkBtn(fC, 2, "🔪 FLING MURDERER", A_COL.base, function()
    local murderer = findMurderer()
    if not murderer then
        notify("XDarkHUB", "No murderer.")
        return
    end
    miniFling(murderer)
end)

mkBtn(fC, 3, "⭐ FLING SHERIFF", Color3.fromRGB(50, 150, 255), function()
    local sheriff = findSheriff()
    if not sheriff then
        notify("XDarkHUB", "No sheriff.")
        return
    end
    miniFling(sheriff)
end)

togC(fC, 4, "Anti-AFK", function(s) antiAFK = s end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  LOOP'Ы
-- ═══════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(1) do
        if findSheriff() == localplayer and autoShooting then
            repeat
                task.wait(0.1)
                local murderer = findMurderer()
                if not murderer then continue end
                if not localplayer.Character:FindFirstChild("Gun") then
                    local hum = localplayer.Character:FindFirstChild("Humanoid")
                    if localplayer.Backpack:FindFirstChild("Gun") then
                        hum:EquipTool(localplayer.Backpack:FindFirstChild("Gun"))
                    else
                        continue
                    end
                end
                local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
                if not murdererHRP then continue end
                local predictedPosition = getPredictedPosition(murderer)
                local args = {
                    CFrame.new(localplayer.Character.RightHand.Position),
                    CFrame.new(predictedPosition)
                }
                pcall(function()
                    localplayer.Character:WaitForChild("Gun"):WaitForChild("Shoot"):FireServer(unpack(args))
                end)
            until findSheriff() ~= localplayer or not autoShooting
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if loopThrow then
            pcall(function() knifeThrow() end)
        end
    end
end)

-- Kill Aura
task.spawn(function()
    while task.wait(0.1) do
        if killAuraCon then
            if findMurderer() ~= localplayer then continue end
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= localplayer then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if (hrp.Position - localplayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude < 7 then
                        hrp.Anchored = true
                        hrp.CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 2
                        task.wait(0.1)
                        pcall(function() localplayer.Character.Knife.Stab:FireServer("Slash") end)
                        break
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  EVENTS
-- ═══════════════════════════════════════════════════════════════════════════════
workspace.DescendantAdded:Connect(function(ch)
    if trapDetection and ch.Name == "Trap" and (ch.Parent:IsA("Folder") or ch.Parent:IsA("Model")) then
        ch.Transparency = 0
        reloadTrapESP()
        notify("XDarkHUB", "Trap placed!")
    end
    if gunDropESP and ch.Name == "GunDrop" then
        reloadGunESP()
        notify("XDarkHUB", "Gun dropped!")
        if autoGetDroppedGun then
            task.wait(1)
            teleportToGun()
        end
    end
end)

workspace.ChildAdded:Connect(function(chi)
    if chi.Name == "ThrowingKnife" and ignoreknifethrow then
        chi:Destroy()
    end
end)

pcall(function()
    if game.ReplicatedStorage:FindFirstChild("Remotes") then
        local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
        if remotes:FindFirstChild("Gameplay") then
            local pdEvent = remotes.Gameplay:FindFirstChild("PlayerDataChanged")
            if pdEvent then
                pdEvent.OnClientEvent:Connect(function(data)
                    playerData = data
                    if playerESP then reloadESP() end
                end)
            end
        end
    end
end)

player.CharacterAdded:Connect(function(ch)
    visitedPositions = {}
    farmStopped = false
    task.wait(1.5)
end)

player.Idled:Connect(function()
    if antiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  MENU BUTTON (КНОПКА ОТКРЫТИЯ/СКРЫТИЯ)
-- ═══════════════════════════════════════════════════════════════════════════════
local mBtn = Instance.new("TextButton")
mBtn.Size = UDim2.new(0, 70, 0, 70)
mBtn.Position = UDim2.new(0, 20, 1, -90)
mBtn.BackgroundColor3 = A_COL.base
mBtn.Text = "X"
mBtn.TextColor3 = C_COL.wht
mBtn.Font = Enum.Font.GothamBlack
mBtn.TextSize = 30
mBtn.BorderSizePixel = 0
mBtn.ZIndex = 10
mBtn.Active = true
mBtn.AutoButtonColor = false
mBtn.Parent = guiUI
crn(mBtn, 35)
stk(mBtn, A_COL.neo, 1.5)

mBtn.MouseButton1Click:Connect(function()
    clickSnd:Play()
    frame.Visible = not frame.Visible
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  ФИНАЛЬНАЯ ИНИЦИАЛИЗАЦИЯ
-- ═══════════════════════════════════════════════════════════════════════════════
switchTab("Sheriff")
notify("XDarkHUB", "v34 Loaded!")
notify("XDarkHUB", "Click X button to toggle menu")
