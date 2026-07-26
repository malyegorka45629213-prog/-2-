-- XDarkHUB v34 - MINIMAL WORKING
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- ═══════════════════════════════════════════════════════════════════════════════
--  GUI (ОБЯЗАТЕЛЬНО ПЕРВЫМ!)
-- ═══════════════════════════════════════════════════════════════════════════════
local old = CoreGui:FindFirstChild("XDarkHUB_GUI")
if old then old:Destroy() end

local guiUI = Instance.new("ScreenGui")
guiUI.Name = "XDarkHUB_GUI"
guiUI.ResetOnSpawn = false
guiUI.IgnoreGuiInset = true
guiUI.DisplayOrder = 999999
guiUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if gethui then
        guiUI.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(guiUI)
        guiUI.Parent = CoreGui
    else
        guiUI.Parent = CoreGui
    end
end)

if not guiUI.Parent then
    guiUI.Parent = CoreGui
end

print("[XDarkHUB] GUI создан в: " .. tostring(guiUI.Parent))

-- ═══════════════════════════════════════════════════════════════════════════════
--  ПЕРЕМЕННЫЕ
-- ═══════════════════════════════════════════════════════════════════════════════
local playerESP, autoShooting, gunDropESP, trapDetection = false, false, false, false
local hideMeEsp, instakillshoot, spawnAtPlayer = false, false, false
local loopThrow, ignoreknifethrow, antiAFK, isActive = false, false, false, false
local shootOffset, offsetToPingMult = 2.8, 1
local playerData, espHighlights, floatingButtons = {}, {}, {}
local killAuraCon = nil

local clickSnd = Instance.new("Sound")
clickSnd.SoundId = "rbxassetid://169759176"
clickSnd.Volume = 0.25
clickSnd.Parent = guiUI

local function notify(t, d)
    pcall(function() StarterGui:SetCore("SendNotification", {Title = "XDarkHUB", Text = t, Duration = d or 3}) end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  MM2 ФУНКЦИИ
-- ═══════════════════════════════════════════════════════════════════════════════
local function findMurderer()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Knife") then return i end
    end
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Character and i.Character:FindFirstChild("Knife") then return i end
    end
    return nil
end

local function findSheriff()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Gun") then return i end
    end
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Character and i.Character:FindFirstChild("Gun") then return i end
    end
    return nil
end

local function findNearestPlayer()
    local nearest, shortest = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local lr = player.Character:FindFirstChild("HumanoidRootPart")
            local or_ = p.Character:FindFirstChild("HumanoidRootPart")
            if lr and or_ then
                local d = (lr.Position - or_.Position).Magnitude
                if d < shortest then shortest = d; nearest = p end
            end
        end
    end
    return nearest
end

local function getPredictedPosition(targetPlayer)
    local p = targetPlayer.Character or targetPlayer
    local hrp = p:FindFirstChild("HumanoidRootPart") or p:FindFirstChild("UpperTorso")
    local hum = p:FindFirstChild("Humanoid")
    if not hrp or not hum then return Vector3.new(0,0,0) end
    local velocity = hrp.AssemblyLinearVelocity
    local moveDir = hum.MoveDirection
    local pred = hrp.Position + ((velocity * Vector3.new(0.75, 0.5, 0.75))) * (shootOffset / 15) + moveDir * shootOffset
    return pred * (((player:GetNetworkPing() * 1000) * ((offsetToPingMult - 1) * 0.01)) + 1)
end

local function getMap()
    for _, o in ipairs(workspace:GetChildren()) do
        if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then return o end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ESP
-- ═══════════════════════════════════════════════════════════════════════════════
local function reloadESP()
    for _, h in pairs(espHighlights) do pcall(function() h:Destroy() end) end
    espHighlights = {}
    if not playerESP then return end
    
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == player and hideMeEsp then continue end
        local ch = pl.Character
        if ch and ch:FindFirstChild("HumanoidRootPart") then
            local color = Color3.fromRGB(0, 255, 8)
            if pl == findMurderer() then color = Color3.fromRGB(255, 0, 4)
            elseif pl == findSheriff() then color = Color3.fromRGB(0, 153, 255) end
            
            local h = Instance.new("Highlight")
            h.FillColor, h.OutlineColor = color, color
            h.FillTransparency, h.OutlineTransparency = 0.5, 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Adornee = ch
            h.Parent = guiUI
            espHighlights[ch] = h
        end
    end
end

local function reloadTrapESP()
    for k, obj in pairs(espHighlights) do
        if obj and obj.Name and obj.Name:find("Trap") then obj:Destroy(); espHighlights[k] = nil end
    end
    if not trapDetection then return end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "Trap" and (v.Parent:IsA("Folder") or v.Parent:IsA("Model")) then
            v.Transparency = 0
            local h = Instance.new("Highlight")
            h.Name = "TrapESP"
            h.FillColor, h.OutlineColor = Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0)
            h.FillTransparency = 0.5
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Adornee = v
            h.Parent = guiUI
            espHighlights[v] = h
        end
    end
end

local function reloadGunESP()
    for k, obj in pairs(espHighlights) do
        if obj and obj.Name and obj.Name:find("Gun") then obj:Destroy(); espHighlights[k] = nil end
    end
    if not gunDropESP then return end
    local map = getMap()
    if map and map:FindFirstChild("GunDrop") then
        local gun = map:FindFirstChild("GunDrop")
        local h = Instance.new("Highlight")
        h.Name = "GunESP"
        h.FillColor, h.OutlineColor = Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 255, 0)
        h.FillTransparency = 0.5
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
    pcall(function()
        if findSheriff() ~= player then notify("Not sheriff"); return end
        local murderer = findMurderer()
        if not murderer then notify("No murderer"); return end
        local gun = player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
        if not gun then notify("No gun"); return end
        if player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:EquipTool(gun) end
        local hrp = murderer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local args
        if instakillshoot then
            args = {CFrame.new(hrp.Position + Vector3.new(0,1,0)), CFrame.new(hrp.Position)}
        else
            args = {CFrame.new(player.Character.RightHand.Position), CFrame.new(getPredictedPosition(murderer))}
        end
        player.Character.Gun.Shoot:FireServer(unpack(args))
        notify("Shot fired!")
    end)
end

local function teleportToGun()
    pcall(function()
        local map = getMap()
        if not map or not map:FindFirstChild("GunDrop") then notify("No gun"); return end
        local prev = player.Character:GetPivot()
        player.Character:PivotTo(map.GunDrop:GetPivot())
        player.Backpack.ChildAdded:Wait()
        player.Character:PivotTo(prev)
        notify("Gun collected!")
    end)
end

local function knifeThrow()
    pcall(function()
        if findMurderer() ~= player then notify("Not murderer"); return end
        local knife = player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
        if not knife then notify("No knife"); return end
        if player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:EquipTool(knife) end
        local target = findNearestPlayer()
        if not target or not target.Character then return end
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local args = {CFrame.new(player.Character.RightHand.Position), CFrame.new(getPredictedPosition(target))}
        if spawnAtPlayer then args[1] = CFrame.new(hrp.Position + (hrp.CFrame.LookVector * 5)) end
        player.Character.Knife.Events.KnifeThrown:FireServer(unpack(args))
        notify("Knife thrown!")
    end)
end

local function killClosest()
    pcall(function()
        if findMurderer() ~= player then notify("Not murderer"); return end
        local knife = player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
        if not knife then notify("No knife"); return end
        if player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:EquipTool(knife) end
        local target = findNearestPlayer()
        if not target or not target.Character then return end
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.Anchored = true
        hrp.CFrame = player.Character.HumanoidRootPart.CFrame + player.Character.HumanoidRootPart.CFrame.LookVector * 2
        task.wait(0.1)
        player.Character.Knife.Stab:FireServer("Slash")
        notify("Killed!")
    end)
end

local function killEveryone()
    pcall(function()
        if findMurderer() ~= player then notify("Not murderer"); return end
        local knife = player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
        if not knife then notify("No knife"); return end
        if player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:EquipTool(knife) end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= player then
                p.Character.HumanoidRootPart.Anchored = true
                p.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + player.Character.HumanoidRootPart.CFrame.LookVector * 1
            end
        end
        player.Character.Knife.Stab:FireServer("Slash")
        notify("Killed everyone!")
    end)
end

local function holdHostage()
    pcall(function()
        if findMurderer() ~= player then notify("Not murderer"); return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= player then
                p.Character.HumanoidRootPart.Anchored = true
                p.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + player.Character.HumanoidRootPart.CFrame.LookVector * 5
            end
        end
        notify("Hostage!")
    end)
end

local function godMode()
    pcall(function()
        local Cam = workspace.CurrentCamera
        local Pos, Char = Cam.CFrame, player.Character
        local Human = Char:FindFirstChildWhichIsA("Humanoid")
        local nHuman = Human:Clone()
        nHuman.Parent = Char
        player.Character = nil
        nHuman:SetStateEnabled(15, false)
        nHuman:SetStateEnabled(1, false)
        nHuman:SetStateEnabled(0, false)
        nHuman.BreakJointsOnDeath = true
        Human:Destroy()
        player.Character = Char
        Cam.CameraSubject = nHuman
        Cam.CFrame = Pos
        nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        local Script = Char:FindFirstChild("Animate")
        if Script then Script.Disabled = true; task.wait(); Script.Disabled = false end
        nHuman.Health = nHuman.MaxHealth
        notify("God mode!")
    end)
end

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
        if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
        if THead then workspace.CurrentCamera.CameraSubject = THead
        elseif THumanoid and TRootPart then workspace.CurrentCamera.CameraSubject = THumanoid end
        
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        
        local SFBasePart = function(BasePart)
            local Time = tick(); local Angle = 0
            repeat
                if RootPart and THumanoid then
                    Angle = Angle + 100
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                else break end
            until BasePart.Velocity.Magnitude > 500 or tick() > Time + 2
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
--  FLOATING BUTTONS (ПЕРЕТАСКИВАЕМЫЕ С ГРАДИЕНТОМ)
-- ═══════════════════════════════════════════════════════════════════════════════
local function createFloatingButton(name, text, callback, position)
    if floatingButtons[name] then floatingButtons[name]:Destroy(); floatingButtons[name] = nil end
    
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
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play()
    end)
    
    local dragging, dragStart, startPos = false, nil, nil
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
            button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    
    floatingButtons[name] = button
    return button
end

local function removeFloatingButton(name)
    if floatingButtons[name] then floatingButtons[name]:Destroy(); floatingButtons[name] = nil end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  UI - ПРОСТОЕ МЕНЮ
-- ═══════════════════════════════════════════════════════════════════════════════
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 600, 0, 400)
frame.Position = UDim2.new(0.5, -300, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Parent = guiUI
local fc = Instance.new("UICorner", frame); fc.CornerRadius = UDim.new(0, 10)
local fs = Instance.new("UIStroke", frame); fs.Color = Color3.fromRGB(255, 50, 80); fs.Thickness = 2

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
header.BorderSizePixel = 0
header.Parent = frame
local hc = Instance.new("UICorner", header); hc.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "XDarkHUB v34"
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255, 90, 115)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Dragging
local dr, ds, sp = false, nil, nil
header.InputBegan:Connect(function(i)
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

-- Tabs
local tabs = {"Sheriff", "Murderer", "ESP", "Farm"}
local tabButtons = {}
local tabFrames = {}
local currentTab = "Sheriff"

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(0, 150, 1, -50)
tabBar.Position = UDim2.new(0, 0, 0, 50)
tabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
tabBar.BorderSizePixel = 0
tabBar.Parent = frame

local contentArea = Instance.new("ScrollingFrame")
contentArea.Size = UDim2.new(1, -150, 1, -50)
contentArea.Position = UDim2.new(0, 150, 0, 50)
contentArea.BackgroundTransparency = 1
contentArea.ScrollBarThickness = 3
contentArea.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 80)
contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
contentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentArea.Parent = frame
local cl = Instance.new("UIListLayout", contentArea)
cl.Padding = UDim.new(0, 8)
local cp = Instance.new("UIPadding", contentArea)
cp.PaddingTop = UDim.new(0, 10)
cp.PaddingLeft = UDim.new(0, 10)
cp.PaddingRight = UDim.new(0, 10)

-- UI Components
local function mkBtn(par, text, color, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = color or Color3.fromRGB(235, 35, 60)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.Parent = par
    local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        clickSnd:Play()
        callback()
    end)
end

local function togC(par, label, onTog)
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(1, 0, 0, 40)
    cd.BackgroundTransparency = 1
    cd.Parent = par
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = cd
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 50, 0, 25)
    sw.Position = UDim2.new(1, -55, 0.5, -12)
    sw.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    sw.BorderSizePixel = 0
    sw.Parent = cd
    local sc = Instance.new("UICorner", sw); sc.CornerRadius = UDim.new(1, 0)
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 20, 0, 20)
    ind.Position = UDim2.new(0, 3, 0.5, -10)
    ind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ind.BorderSizePixel = 0
    ind.Parent = sw
    local ic = Instance.new("UICorner", ind); ic.CornerRadius = UDim.new(1, 0)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = cd
    local st = false
    btn.MouseButton1Click:Connect(function()
        clickSnd:Play()
        st = not st
        if st then
            sw.BackgroundColor3 = Color3.fromRGB(235, 35, 60)
            TweenService:Create(ind, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(0, 27, 0.5, -10)}):Play()
        else
            sw.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            TweenService:Create(ind, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(0, 3, 0.5, -10)}):Play()
        end
        if onTog then onTog(st) end
    end)
end

local function secT(par, txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 25)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(255, 90, 115)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = par
end

-- Tabs creation
for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, 10 + (i-1) * 45)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Parent = tabBar
    local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0, 8)
    tabButtons[tabName] = btn
    
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 0)
    f.BackgroundTransparency = 1
    f.AutomaticSize = Enum.AutomaticSize.Y
    f.Visible = (tabName == "Sheriff")
    f.Parent = contentArea
    local fl = Instance.new("UIListLayout", f)
    fl.Padding = UDim.new(0, 8)
    tabFrames[tabName] = f
    
    btn.MouseButton1Click:Connect(function()
        clickSnd:Play()
        for n, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        end
        btn.BackgroundColor3 = Color3.fromRGB(235, 35, 60)
        for n, fr in pairs(tabFrames) do
            fr.Visible = (n == tabName)
        end
        currentTab = tabName
    end)
end
tabButtons["Sheriff"].BackgroundColor3 = Color3.fromRGB(235, 35, 60)

-- Sheriff tab
secT(tabFrames["Sheriff"], "⭐ SHERIFF TOOLS")
mkBtn(tabFrames["Sheriff"], "🔫 SHOOT MURDERER", Color3.fromRGB(235, 35, 60), shootMurderer)
mkBtn(tabFrames["Sheriff"], "🔫 TP TO DROPPED GUN", Color3.fromRGB(255, 200, 0), teleportToGun)
mkBtn(tabFrames["Sheriff"], "📌 FLOAT: SHOOT", Color3.fromRGB(100, 20, 30), function()
    if floatingButtons["SHOOT"] then removeFloatingButton("SHOOT")
    else createFloatingButton("SHOOT", "🔫 SHOOT", shootMurderer, UDim2.new(0, 100, 0, 100)) end
end)
mkBtn(tabFrames["Sheriff"], "📌 FLOAT: TP TO GUN", Color3.fromRGB(100, 80, 0), function()
    if floatingButtons["TPGUN"] then removeFloatingButton("TPGUN")
    else createFloatingButton("TPGUN", "🔫 TP TO GUN", teleportToGun, UDim2.new(0, 100, 0, 160)) end
end)
togC(tabFrames["Sheriff"], "Auto Shoot Murderer", function(s) autoShooting = s end)
togC(tabFrames["Sheriff"], "Auto Get Gun On Drop", function(s) autoGetDroppedGun = s end)
togC(tabFrames["Sheriff"], "Instakill Murderer", function(s) instakillshoot = s end)

-- Murderer tab
secT(tabFrames["Murderer"], "🔪 MURDERER TOOLS")
mkBtn(tabFrames["Murderer"], "🔪 KNIFE THROW", Color3.fromRGB(235, 35, 60), knifeThrow)
mkBtn(tabFrames["Murderer"], "💀 KILL CLOSEST", Color3.fromRGB(200, 0, 0), killClosest)
mkBtn(tabFrames["Murderer"], "💀 KILL EVERYONE", Color3.fromRGB(150, 0, 0), killEveryone)
mkBtn(tabFrames["Murderer"], "🔒 HOLD HOSTAGE", Color3.fromRGB(100, 0, 50), holdHostage)
togC(tabFrames["Murderer"], "Auto Knife Throw", function(s) loopThrow = s end)
togC(tabFrames["Murderer"], "Spawn Knife Near Player", function(s) spawnAtPlayer = s end)
togC(tabFrames["Murderer"], "Ignore Knife Throws", function(s) ignoreknifethrow = s end)
mkBtn(tabFrames["Murderer"], "⚡ GOD MODE", Color3.fromRGB(150, 0, 150), godMode)

-- ESP tab
secT(tabFrames["ESP"], "👁️ ESP TOGGLES")
togC(tabFrames["ESP"], "Players ESP", function(s)
    playerESP = s
    if s then reloadESP() else for _,h in pairs(espHighlights) do pcall(function() h:Destroy() end) end; espHighlights = {} end
end)
togC(tabFrames["ESP"], "Dropped Gun ESP", function(s) gunDropESP = s; reloadGunESP() end)
togC(tabFrames["ESP"], "Traps ESP", function(s) trapDetection = s; reloadTrapESP() end)
togC(tabFrames["ESP"], "Hide My Own ESP", function(s) hideMeEsp = s; reloadESP() end)

-- Farm tab
secT(tabFrames["Farm"], "🔪 FLING")
mkBtn(tabFrames["Farm"], "🔪 FLING MURDERER", Color3.fromRGB(235, 35, 60), function()
    local murderer = findMurderer()
    if not murderer then notify("No murderer"); return end
    miniFling(murderer)
end)
mkBtn(tabFrames["Farm"], "⭐ FLING SHERIFF", Color3.fromRGB(50, 150, 255), function()
    local sheriff = findSheriff()
    if not sheriff then notify("No sheriff"); return end
    miniFling(sheriff)
end)
togC(tabFrames["Farm"], "Anti-AFK", function(s) antiAFK = s end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  EVENTS
-- ═══════════════════════════════════════════════════════════════════════════════
workspace.DescendantAdded:Connect(function(ch)
    pcall(function()
        if trapDetection and ch.Name == "Trap" and (ch.Parent:IsA("Folder") or ch.Parent:IsA("Model")) then
            ch.Transparency = 0
            reloadTrapESP()
            notify("Trap placed!")
        end
        if gunDropESP and ch.Name == "GunDrop" then
            reloadGunESP()
            notify("Gun dropped!")
            if autoGetDroppedGun then
                task.wait(1)
                teleportToGun()
            end
        end
    end)
end)

workspace.ChildAdded:Connect(function(chi)
    pcall(function()
        if chi.Name == "ThrowingKnife" and ignoreknifethrow then chi:Destroy() end
    end)
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
    character = ch
end)

player.Idled:Connect(function()
    if antiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

-- Auto shoot loop
task.spawn(function()
    while task.wait(1) do
        if findSheriff() == player and autoShooting then
            repeat
                task.wait(0.1)
                local murderer = findMurderer()
                if not murderer then continue end
                if not player.Character:FindFirstChild("Gun") then
                    local hum = player.Character:FindFirstChild("Humanoid")
                    if player.Backpack:FindFirstChild("Gun") then hum:EquipTool(player.Backpack:FindFirstChild("Gun"))
                    else continue end
                end
                local hrp = murderer.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                pcall(function()
                    player.Character.Gun.Shoot:FireServer(CFrame.new(player.Character.RightHand.Position), CFrame.new(getPredictedPosition(murderer)))
                end)
            until findSheriff() ~= player or not autoShooting
        end
    end
end)

-- Auto knife throw loop
task.spawn(function()
    while task.wait(1.5) do
        if loopThrow then pcall(function() knifeThrow() end) end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  TOGGLE BUTTON (КНОПКА ОТКРЫТИЯ/СКРЫТИЯ)
-- ═══════════════════════════════════════════════════════════════════════════════
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -30)
toggleBtn.BackgroundColor3 = Color3.fromRGB(235, 35, 60)
toggleBtn.Text = "X"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.TextSize = 28
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = guiUI
local tc = Instance.new("UICorner", toggleBtn); tc.CornerRadius = UDim.new(1, 0)
local ts = Instance.new("UIStroke", toggleBtn); ts.Color = Color3.fromRGB(255, 255, 255); ts.Thickness = 2

toggleBtn.MouseButton1Click:Connect(function()
    clickSnd:Play()
    frame.Visible = not frame.Visible
end)

notify("XDarkHUB v34 Loaded!")
notify("Нажми X чтобы открыть меню")
print("[XDarkHUB] Загружено успешно!")
