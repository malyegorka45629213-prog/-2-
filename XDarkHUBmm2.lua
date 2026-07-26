-- XDarkHUB v34 + VISUAL EFFECTS
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
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ═══ GUI ═══
do local old = player:WaitForChild("PlayerGui"):FindFirstChild("XDarkHUB_GUI") if old then old:Destroy() end end
local guiUI = Instance.new("ScreenGui")
guiUI.Name = "XDarkHUB_GUI"
guiUI.ResetOnSpawn = false
guiUI.IgnoreGuiInset = true
guiUI.DisplayOrder = 999
guiUI.Parent = player:WaitForChild("PlayerGui")

-- ═══ ПЕРЕМЕННЫЕ ═══
local visitedPositions, isActive, flySpeed = {}, false, 16
local initialCoins, startTime, antiAFK = 0, 0, false
local isMurderer, isSheriff, farmStopped, MAX_BAG = false, false, false, 40
local playerESP, autoShooting, shootOffset, offsetToPingMult = false, false, 2.8, 1
local gunDropESP, trapDetection, autoGetDroppedGun = false, false, false
local playerData, hideMeEsp, instakillshoot = {}, false, false
local spawnAtPlayer, loopThrow, ignoreknifethrow = false, false, false
local killAuraCon, espHighlights, floatingButtons = nil, {}, {}

-- ═══ ЗВУКИ ═══
local collectSound = Instance.new("Sound"); collectSound.SoundId = "rbxassetid://12221967"; collectSound.Volume = 1; collectSound.Parent = guiUI
local clickSnd = Instance.new("Sound"); clickSnd.SoundId = "rbxassetid://169759176"; clickSnd.Volume = 0.25; clickSnd.Parent = guiUI

-- ═══ УВЕДОМЛЕНИЯ ═══
local function notify(title, text, duration)
    pcall(function() StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 3}) end)
end

-- ═══ ВИЗУАЛЬНЫЕ ЭФФЕКТЫ (КРЫЛЬЯ, КРУГ, СВЕЧЕНИЕ) ═══
local visualEffectsEnabled = false
local effectAttachments = {}

local function applyVisualEffects()
    if visualEffectsEnabled then return end
    visualEffectsEnabled = true
    
    pcall(function()
        -- Удаляем старые эффекты
        for _, att in pairs(effectAttachments) do pcall(function() att:Destroy() end) end
        effectAttachments = {}
        
        local char = localplayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- ═══ КРЫЛЬЯ СНИЗУ (ParticleEmitter на спине) ═══
        local wingAttach = Instance.new("Attachment")
        wingAttach.Name = "XDarkHUB_Wings"
        wingAttach.Position = Vector3.new(0, 0, -1)
        wingAttach.Parent = hrp
        
        local wings = Instance.new("ParticleEmitter")
        wings.Name = "XDarkHUB_WingParticles"
        wings.Texture = "rbxassetid://241876428" -- свечение
        wings.Rate = 50
        wings.Lifetime = NumberRange.new(0.5, 1)
        wings.Speed = NumberRange.new(2, 4)
        wings.SpreadAngle = Vector2.new(45, 10)
        wings.Rotation = NumberRange.new(0, 360)
        wings.RotSpeed = NumberRange.new(-180, 180)
        wings.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1.5),
            NumberSequenceKeypoint.new(1, 0)
        })
        wings.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        wings.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 80)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 30, 100)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 150, 255))
        })
        wings.LightEmission = 1
        wings.LightInfluence = 0
        wings.Parent = wingAttach
        table.insert(effectAttachments, wingAttach)
        
        -- ═══ КРУГ ПОД НОГАМИ (BillboardGui) ═══
        local circleBGUI = Instance.new("BillboardGui")
        circleBGUI.Name = "XDarkHUB_Circle"
        circleBGUI.Size = UDim2.new(4, 0, 4, 0)
        circleBGUI.StudsOffset = Vector3.new(0, -3, 0)
        circleBGUI.AlwaysOnTop = false
        circleBGUI.Adornee = hrp
        circleBGUI.Parent = guiUI
        
        local circleFrame = Instance.new("Frame")
        circleFrame.Size = UDim2.new(1, 0, 1, 0)
        circleFrame.BackgroundTransparency = 1
        circleFrame.Parent = circleBGUI
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = circleFrame
        
        local circleStroke = Instance.new("UIStroke")
        circleStroke.Color = Color3.fromRGB(255, 50, 80)
        circleStroke.Thickness = 3
        circleStroke.Parent = circleFrame
        
        local circleGrad = Instance.new("UIGradient")
        circleGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 80)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 30, 100)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 150, 255))
        })
        circleGrad.Rotation = 0
        circleGrad.Parent = circleFrame
        
        -- Анимация вращения круга
        task.spawn(function()
            while circleFrame.Parent do
                for i = 0, 360, 2 do
                    if not circleFrame.Parent then break end
                    circleGrad.Rotation = i
                    task.wait(0.02)
                end
            end
        end)
        
        -- ═══ СВЕЧЕНИЕ СВЕРХУ (PointLight + Part) ═══
        local glowAttach = Instance.new("Attachment")
        glowAttach.Name = "XDarkHUB_Glow"
        glowAttach.Position = Vector3.new(0, 3, 0)
        glowAttach.Parent = hrp
        
        local glow = Instance.new("PointLight")
        glow.Name = "XDarkHUB_PointLight"
        glow.Color = Color3.fromRGB(255, 50, 80)
        glow.Brightness = 2
        glow.Range = 15
        glow.Parent = glowAttach
        
        -- Маленькая светящаяся сфера сверху
        local glowPart = Instance.new("Part")
        glowPart.Name = "XDarkHUB_GlowPart"
        glowPart.Size = Vector3.new(0.5, 0.5, 0.5)
        glowPart.Shape = Enum.PartType.Ball
        glowPart.Material = Enum.Material.Neon
        glowPart.Color = Color3.fromRGB(255, 50, 80)
        glowPart.Anchored = true
        glowPart.CanCollide = false
        glowPart.CastShadow = false
        glowPart.Parent = workspace
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = glowPart
        weld.Part1 = hrp
        weld.Parent = glowPart
        
        glowPart.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
        table.insert(effectAttachments, glowAttach)
        
        -- Анимация пульсации свечения
        task.spawn(function()
            local up = true
            while glowPart.Parent do
                if up then
                    TweenService:Create(glow, TweenInfo.new(1), {Brightness = 4}):Play()
                    TweenService:Create(glowPart, TweenInfo.new(1), {Size = Vector3.new(0.8, 0.8, 0.8)}):Play()
                else
                    TweenService:Create(glow, TweenInfo.new(1), {Brightness = 2}):Play()
                    TweenService:Create(glowPart, TweenInfo.new(1), {Size = Vector3.new(0.5, 0.5, 0.5)}):Play()
                end
                up = not up
                task.wait(1)
            end
        end)
        
        notify("XDarkHUB", "✨ Visual effects enabled!")
    end)
end

local function removeVisualEffects()
    pcall(function()
        for _, att in pairs(effectAttachments) do pcall(function() att:Destroy() end) end
        effectAttachments = {}
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name == "XDarkHUB_GlowPart" then v:Destroy() end
        end
        for _, v in ipairs(guiUI:GetChildren()) do
            if v.Name == "XDarkHUB_Circle" then v:Destroy() end
        end
        visualEffectsEnabled = false
        notify("XDarkHUB", "Visual effects removed")
    end)
end

-- ═══ MM2 ФУНКЦИИ ═══
local function findMurderer()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Knife") then return i end
    end
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Character and i.Character:FindFirstChild("Knife") then return i end
    end
    if playerData then
        for pl, data in pairs(playerData) do
            if data.Role == "Murderer" and Players:FindFirstChild(pl) then return Players:FindFirstChild(pl) end
        end
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
    if playerData then
        for pl, data in pairs(playerData) do
            if data.Role == "Sheriff" and Players:FindFirstChild(pl) then return Players:FindFirstChild(pl) end
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
        if i.Character and i.Character:FindFirstChild("Gun") then return i end
    end
    return nil
end

local function getMap()
    for _, o in ipairs(workspace:GetChildren()) do
        if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then return o end
    end
    return nil
end

local function findNearestPlayer()
    local nearest, shortest = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localplayer and p.Character then
            local lr = localplayer.Character:FindFirstChild("HumanoidRootPart")
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

-- ═══ MINI FLING ═══
function miniFling(playerToFling)
    pcall(function()
        local Character = player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
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
        BV.Parent = RootPart; BV.Velocity = Vector3.new(9e8, 9e8, 9e8); BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        
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

-- ═══ ESP ═══
local function reloadESP()
    for _, h in pairs(espHighlights) do pcall(function() h:Destroy() end) end
    espHighlights = {}
    if not playerESP then return end
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == localplayer and hideMeEsp then continue end
        local ch = pl.Character
        if ch and ch:FindFirstChild("HumanoidRootPart") then
            local color = Color3.fromRGB(0, 255, 8)
            if pl == findMurderer() then color = Color3.fromRGB(255, 0, 4)
            elseif pl == findSheriff() then color = Color3.fromRGB(0, 153, 255) end
            local h = Instance.new("Highlight")
            h.FillColor, h.OutlineColor = color, color
            h.FillTransparency, h.OutlineTransparency = 0.5, 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Adornee = ch; h.Parent = guiUI
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
            h.Name = "TrapESP"; h.FillColor, h.OutlineColor = Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0)
            h.FillTransparency = 0.5; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Adornee = v; h.Parent = guiUI; espHighlights[v] = h
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
        h.Name = "GunESP"; h.FillColor, h.OutlineColor = Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 255, 0)
        h.FillTransparency = 0.5; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee = gun; h.Parent = guiUI; espHighlights[gun] = h
    end
end

-- ═══ ДЕЙСТВИЯ ═══
function shootMurderer()
    pcall(function()
        if findSheriff() ~= localplayer then notify("XDarkHUB", "Not sheriff."); return end
        local murderer = findMurderer() or findSheriffThatsNotMe()
        if not murderer then notify("XDarkHUB", "No murderer."); return end
        local gun = localplayer.Character:FindFirstChild("Gun") or localplayer.Backpack:FindFirstChild("Gun")
        if not gun then notify("XDarkHUB", "No gun."); return end
        if localplayer.Character:FindFirstChild("Humanoid") then localplayer.Character.Humanoid:EquipTool(gun) end
        local hrp = murderer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local args
        if instakillshoot then args = {CFrame.new(hrp.Position + Vector3.new(0,1,0)), CFrame.new(hrp.Position)}
        else args = {CFrame.new(localplayer.Character.RightHand.Position), CFrame.new(getPredictedPosition(murderer))} end
        localplayer.Character.Gun.Shoot:FireServer(unpack(args))
        notify("XDarkHUB", "Shot fired!")
    end)
end

function teleportToGun()
    pcall(function()
        local map = getMap()
        if not map or not map:FindFirstChild("GunDrop") then notify("XDarkHUB", "No gun."); return end
        local prev = localplayer.Character:GetPivot()
        localplayer.Character:PivotTo(map.GunDrop:GetPivot())
        localplayer.Backpack.ChildAdded:Wait()
        localplayer.Character:PivotTo(prev)
        notify("XDarkHUB", "Gun collected!")
    end)
end

function knifeThrow()
    pcall(function()
        if findMurderer() ~= localplayer then notify("XDarkHUB", "Not murderer."); return end
        local knife = localplayer.Character:FindFirstChild("Knife") or localplayer.Backpack:FindFirstChild("Knife")
        if not knife then notify("XDarkHUB", "No knife."); return end
        if localplayer.Character:FindFirstChild("Humanoid") then localplayer.Character.Humanoid:EquipTool(knife) end
        local target = findNearestPlayer()
        if not target or not target.Character then return end
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local args = {CFrame.new(localplayer.Character.RightHand.Position), CFrame.new(getPredictedPosition(target))}
        if spawnAtPlayer then args[1] = CFrame.new(hrp.Position + (hrp.CFrame.LookVector * 5)) end
        localplayer.Character.Knife.Events.KnifeThrown:FireServer(unpack(args))
        notify("XDarkHUB", "Knife thrown!")
    end)
end

function killClosest()
    pcall(function()
        if findMurderer() ~= localplayer then notify("XDarkHUB", "Not murderer."); return end
        local knife = localplayer.Character:FindFirstChild("Knife") or localplayer.Backpack:FindFirstChild("Knife")
        if not knife then notify("XDarkHUB", "No knife."); return end
        if localplayer.Character:FindFirstChild("Humanoid") then localplayer.Character.Humanoid:EquipTool(knife) end
        local target = findNearestPlayer()
        if not target or not target.Character then return end
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.Anchored = true
        hrp.CFrame = localplayer.Character.HumanoidRootPart.CFrame + localplayer.Character.HumanoidRootPart.CFrame.LookVector * 2
        task.wait(0.1)
        localplayer.Character.Knife.Stab:FireServer("Slash")
        notify("XDarkHUB", "Killed!")
    end)
end

function killEveryone()
    pcall(function()
        if findMurderer() ~= localplayer then notify("XDarkHUB", "Not murderer."); return end
        local knife = localplayer.Character:FindFirstChild("Knife") or localplayer.Backpack:FindFirstChild("Knife")
        if not knife then notify("XDarkHUB", "No knife."); return end
        if localplayer.Character:FindFirstChild("Humanoid") then localplayer.Character.Humanoid:EquipTool(knife) end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= localplayer then
                p.Character.HumanoidRootPart.Anchored = true
                p.Character.HumanoidRootPart.CFrame = localplayer.Character.HumanoidRootPart.CFrame + localplayer.Character.HumanoidRootPart.CFrame.LookVector * 1
            end
        end
        localplayer.Character.Knife.Stab:FireServer("Slash")
        notify("XDarkHUB", "Killed everyone!")
    end)
end

function holdHostage()
    pcall(function()
        if findMurderer() ~= localplayer then notify("XDarkHUB", "Not murderer."); return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= localplayer then
                p.Character.HumanoidRootPart.Anchored = true
                p.Character.HumanoidRootPart.CFrame = localplayer.Character.HumanoidRootPart.CFrame + localplayer.Character.HumanoidRootPart.CFrame.LookVector * 5
            end
        end
        notify("XDarkHUB", "Hostage!")
    end)
end

function godMode()
    pcall(function()
        local Cam = workspace.CurrentCamera
        local Pos, Char = Cam.CFrame, localplayer.Character
        local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
        local nHuman = Human:Clone()
        nHuman.Parent = Char
        localplayer.Character = nil
        nHuman:SetStateEnabled(15, false); nHuman:SetStateEnabled(1, false); nHuman:SetStateEnabled(0, false)
        nHuman.BreakJointsOnDeath = true
        Human:Destroy()
        localplayer.Character = Char
        Cam.CameraSubject = nHuman; Cam.CFrame = Pos
        nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        local Script = Char:FindFirstChild("Animate")
        if Script then Script.Disabled = true; task.wait(); Script.Disabled = false end
        nHuman.Health = nHuman.MaxHealth
        notify("XDarkHUB", "God mode!")
    end)
end

-- ═══ АВТОФАРМ (ТВОЙ ОРИГИНАЛЬНЫЙ) ═══
function getPlayerCoins(p)
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

function getCollectedCoins()
    return getPlayerCoins(player) - initialCoins
end

function flyTo(pos, spd)
    if not rootPart or farmStopped then return false end
    local d = (pos - rootPart.Position).Magnitude
    local dur = math.max(0.1, d / spd)
    local tw = TweenService:Create(rootPart, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tw:Play()
    local c = false
    local to = task.delay(dur + 2, function() c = true; tw:Cancel() end)
    tw.Completed:Wait()
    if not c then task.cancel(to) end
    return not c
end

function startFarming()
    initialCoins = getPlayerCoins(player)
    startTime = tick()
    visitedPositions = {}
    farmStopped = false
    notify("XDarkHUB", "Farm ON")
    
    task.spawn(function()
        while isActive do
            if farmStopped then task.wait(1) continue end
            character = player.Character
            if not character then task.wait(0.5) continue end
            rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then task.wait(0.5) continue end
            local cl, sh = nil, math.huge
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("BasePart") and o.Name == "Coin_Server" then
                    local ic = false
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character and o:IsDescendantOf(p.Character) then ic = true; break end
                    end
                    if not ic and o.Parent and o:IsDescendantOf(workspace) and not visitedPositions[o] then
                        local d = (o.Position - rootPart.Position).Magnitude
                        if d < sh and d < 300 then cl = o; sh = d end
                    end
                end
            end
            if cl then
                if flyTo(cl.Position, flySpeed) and not farmStopped then
                    task.wait(0.3)
                    if cl.Parent and cl:IsDescendantOf(workspace) then
                        local ic = false
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p.Character and cl:IsDescendantOf(p.Character) then ic = true; break end
                        end
                        if not ic and (cl.Position - rootPart.Position).Magnitude < 5 then
                            collectSound:Play()
                            visitedPositions[cl] = true
                        else
                            visitedPositions[cl] = true
                        end
                    else
                        visitedPositions[cl] = true
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

-- ═══ FLOATING BUTTONS ═══
local function createFloatingButton(name, text, callback, position)
    if floatingButtons[name] then floatingButtons[name]:Destroy(); floatingButtons[name] = nil end
    local button = Instance.new("TextButton")
    button.Name = name; button.Size = UDim2.new(0, 160, 0, 55)
    button.Position = position or UDim2.new(0, 125, 0, 90)
    button.BackgroundColor3 = Color3.fromRGB(20, 20, 30); button.BackgroundTransparency = 0.4
    button.Text = text; button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true; button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false; button.ClipsDescendants = true
    button.Parent = guiUI
    local corner = Instance.new("UICorner", button); corner.CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", button); stroke.Color = Color3.fromRGB(255, 50, 80); stroke.Thickness = 2; stroke.Transparency = 0.3
    local grad = Instance.new("UIGradient", button)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 80)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 30, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 150, 255))
    }
    grad.Rotation = 45
    task.spawn(function()
        local rot = 45
        while button.Parent do rot = rot + 0.5; grad.Rotation = rot; task.wait(0.05) end
    end)
    button.MouseButton1Click:Connect(function() clickSnd:Play(); callback() end)
    local dragging, dragStart, startPos = false, nil, nil
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = button.Position
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

-- ═══ UI ═══
local C_COL = {bg = Color3.fromRGB(8, 8, 12), panel = Color3.fromRGB(12, 12, 18), card = Color3.fromRGB(18, 18, 26), txt = Color3.fromRGB(245, 245, 255), mut = Color3.fromRGB(100, 100, 115), wht = Color3.fromRGB(255, 255, 255)}
local A_COL = {base = Color3.fromRGB(235, 35, 60), lit = Color3.fromRGB(255, 90, 115), neo = Color3.fromRGB(255, 35, 62)}

local function crn(o, r) local c = Instance.new("UICorner", o); c.CornerRadius = UDim.new(0, r or 8) end
local function stk(o, c, t) local s = Instance.new("UIStroke", o); s.Color = c; s.Thickness = t or 1 end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 700, 0, 500); frame.Position = UDim2.new(0.5, -350, 0.5, -250)
frame.BackgroundColor3 = C_COL.bg; frame.BackgroundTransparency = 0.03
frame.BorderSizePixel = 0; frame.ClipsDescendants = true; frame.Parent = guiUI
crn(frame, 10); stk(frame, A_COL.base, 1.5)

local tBar = Instance.new("Frame")
tBar.Size = UDim2.new(1, 0, 0, 50); tBar.BackgroundColor3 = C_COL.panel
tBar.BackgroundTransparency = 0.04; tBar.BorderSizePixel = 0; tBar.Active = true
tBar.Parent = frame; crn(tBar, 10)

local tLbl = Instance.new("TextLabel")
tLbl.Size = UDim2.new(1, -100, 1, 0); tLbl.Position = UDim2.new(0, 20, 0, 0)
tLbl.BackgroundTransparency = 1; tLbl.Text = "XDarkHUB v34 ✨"
tLbl.Font = Enum.Font.GothamBlack; tLbl.TextSize = 20
tLbl.TextColor3 = A_COL.lit; tLbl.TextXAlignment = Enum.TextXAlignment.Left
tLbl.Parent = tBar

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

local ctr = Instance.new("Frame")
ctr.Size = UDim2.new(1, 0, 1, -50); ctr.Position = UDim2.new(0, 0, 0, 50)
ctr.BackgroundTransparency = 1; ctr.Parent = frame

local lPan = Instance.new("Frame")
lPan.Size = UDim2.new(0, 150, 1, 0); lPan.BackgroundColor3 = C_COL.panel
lPan.BackgroundTransparency = 0.04; lPan.BorderSizePixel = 0; lPan.Parent = ctr

local rPan = Instance.new("Frame")
rPan.Size = UDim2.new(1, -150, 1, 0); rPan.Position = UDim2.new(0, 150, 0, 0)
rPan.BackgroundTransparency = 1; rPan.Parent = ctr

local tabs, tabContents, currentTab = {}, {}, nil

local function createTab(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 45); btn.Position = UDim2.new(0, 5, 0, 10 + (order-1)*50)
    btn.BackgroundColor3 = C_COL.card; btn.BackgroundTransparency = 1
    btn.Text = ""; btn.BorderSizePixel = 0; btn.Active = true; btn.AutoButtonColor = false
    btn.Parent = lPan; crn(btn, 8)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = icon .. " " .. name
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
    lbl.TextColor3 = C_COL.mut; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn
    tabs[name] = {btn = btn, lbl = lbl}
    return btn
end

local function createTabContent(name)
    local c = Instance.new("ScrollingFrame")
    c.Size = UDim2.new(1, 0, 1, 0); c.BackgroundTransparency = 1
    c.BorderSizePixel = 0; c.ScrollBarThickness = 3
    c.ScrollBarImageColor3 = A_COL.base; c.CanvasSize = UDim2.new(0, 0, 0, 0)
    c.AutomaticCanvasSize = Enum.AutomaticSize.Y; c.Visible = false
    c.Parent = rPan
    local p = Instance.new("UIPadding", c)
    p.PaddingLeft = UDim.new(0, 15); p.PaddingRight = UDim.new(0, 15)
    p.PaddingTop = UDim.new(0, 15); p.PaddingBottom = UDim.new(0, 15)
    local l = Instance.new("UIListLayout", c)
    l.SortOrder = Enum.SortOrder.LayoutOrder; l.Padding = UDim.new(0, 8)
    tabContents[name] = c
end

local function switchTab(name)
    for n, t in pairs(tabs) do
        t.btn.BackgroundTransparency = 1; t.lbl.TextColor3 = C_COL.mut
    end
    if tabs[name] then
        tabs[name].btn.BackgroundTransparency = 0.3
        tabs[name].lbl.TextColor3 = A_COL.lit
    end
    for n, c in pairs(tabContents) do c.Visible = (n == name) end
    currentTab = name
end

createTab("Sheriff", "⭐", 1); createTab("Murderer", "🔪", 2)
createTab("ESP", "👁️", 3); createTab("Farm", "⚙️", 4)
createTab("Visual", "✨", 5)

for n in pairs(tabs) do createTabContent(n) end
for n, t in pairs(tabs) do
    t.btn.MouseButton1Click:Connect(function() clickSnd:Play(); switchTab(n) end)
end

local function secT(par, txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20); l.BackgroundTransparency = 1
    l.Text = txt; l.TextColor3 = A_COL.lit
    l.Font = Enum.Font.GothamBold; l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = par
end

local function togC(par, label, onTog)
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(1, 0, 0, 40); cd.BackgroundTransparency = 1
    cd.Parent = par
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0); lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.TextColor3 = C_COL.txt
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = cd
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 45, 0, 22); sw.Position = UDim2.new(1, -50, 0.5, -11)
    sw.BackgroundColor3 = Color3.fromRGB(60, 60, 70); sw.BorderSizePixel = 0
    sw.Parent = cd; crn(sw, 11)
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 18, 0, 18); ind.Position = UDim2.new(0, 2, 0.5, -9)
    ind.BackgroundColor3 = C_COL.wht; ind.BorderSizePixel = 0
    ind.Parent = sw; crn(ind, 9)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1
    btn.Text = ""; btn.Parent = cd
    local st = false
    btn.MouseButton1Click:Connect(function()
        clickSnd:Play(); st = not st
        if st then
            sw.BackgroundColor3 = A_COL.base
            TweenService:Create(ind, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(0, 25, 0.5, -9)}):Play()
        else
            sw.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            TweenService:Create(ind, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
        end
        if onTog then onTog(st) end
    end)
end

local function mkBtn(par, text, color, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = color or A_COL.base
    b.Text = text; b.TextColor3 = C_COL.wht
    b.Font = Enum.Font.GothamBold; b.TextSize = 13
    b.AutoButtonColor = false; b.BorderSizePixel = 0
    b.Parent = par; crn(b, 8)
    b.MouseButton1Click:Connect(function() clickSnd:Play(); callback() end)
end

-- ═══ ВКЛАДКИ ═══
secT(tabContents["Sheriff"], "⭐ SHERIFF TOOLS")
mkBtn(tabContents["Sheriff"], "🔫 SHOOT MURDERER", A_COL.base, shootMurderer)
mkBtn(tabContents["Sheriff"], "🔫 TP TO GUN", Color3.fromRGB(255, 200, 0), teleportToGun)
mkBtn(tabContents["Sheriff"], "📌 FLOAT: SHOOT", Color3.fromRGB(100, 20, 30), function()
    if floatingButtons["SHOOT"] then removeFloatingButton("SHOOT")
    else createFloatingButton("SHOOT", "🔫 SHOOT", shootMurderer, UDim2.new(0, 100, 0, 100)) end
end)
mkBtn(tabContents["Sheriff"], "📌 FLOAT: TP GUN", Color3.fromRGB(100, 80, 0), function()
    if floatingButtons["TPGUN"] then removeFloatingButton("TPGUN")
    else createFloatingButton("TPGUN", "🔫 TP GUN", teleportToGun, UDim2.new(0, 100, 0, 160)) end
end)
togC(tabContents["Sheriff"], "Auto Shoot", function(s) autoShooting = s end)
togC(tabContents["Sheriff"], "Auto Get Gun", function(s) autoGetDroppedGun = s end)
togC(tabContents["Sheriff"], "Instakill", function(s) instakillshoot = s end)

secT(tabContents["Murderer"], "🔪 MURDERER TOOLS")
mkBtn(tabContents["Murderer"], "🔪 KNIFE THROW", A_COL.base, knifeThrow)
mkBtn(tabContents["Murderer"], "💀 KILL CLOSEST", Color3.fromRGB(200, 0, 0), killClosest)
mkBtn(tabContents["Murderer"], "💀 KILL EVERYONE", Color3.fromRGB(150, 0, 0), killEveryone)
mkBtn(tabContents["Murderer"], "🔒 HOSTAGE", Color3.fromRGB(100, 0, 50), holdHostage)
togC(tabContents["Murderer"], "Auto Knife Throw", function(s) loopThrow = s end)
togC(tabContents["Murderer"], "Spawn Near Player", function(s) spawnAtPlayer = s end)
togC(tabContents["Murderer"], "Ignore Knives", function(s) ignoreknifethrow = s end)
mkBtn(tabContents["Murderer"], "⚡ GOD MODE", Color3.fromRGB(150, 0, 150), godMode)

secT(tabContents["ESP"], "👁️ ESP")
togC(tabContents["ESP"], "Players ESP", function(s)
    playerESP = s
    if s then reloadESP() else for _,h in pairs(espHighlights) do pcall(function() h:Destroy() end) end; espHighlights = {} end
end)
togC(tabContents["ESP"], "Gun ESP", function(s) gunDropESP = s; reloadGunESP() end)
togC(tabContents["ESP"], "Traps ESP", function(s) trapDetection = s; reloadTrapESP() end)
togC(tabContents["ESP"], "Hide My ESP", function(s) hideMeEsp = s; reloadESP() end)

secT(tabContents["Farm"], "🔪 FLING")
mkBtn(tabContents["Farm"], "🔪 FLING MURDERER", A_COL.base, function()
    local murderer = findMurderer()
    if not murderer then notify("XDarkHUB", "No murderer."); return end
    miniFling(murderer)
end)
mkBtn(tabContents["Farm"], "⭐ FLING SHERIFF", Color3.fromRGB(50, 150, 255), function()
    local sheriff = findSheriff()
    if not sheriff then notify("XDarkHUB", "No sheriff."); return end
    miniFling(sheriff)
end)
secT(tabContents["Farm"], "📊 AUTO FARM")
togC(tabContents["Farm"], "Auto Farm", function(s) isActive = s; if s then startFarming() end end)
togC(tabContents["Farm"], "Anti-AFK", function(s) antiAFK = s end)

-- ═══ ВКЛАДКА ВИЗУАЛЬНЫХ ЭФФЕКТОВ ═══
secT(tabContents["Visual"], "✨ VISUAL EFFECTS")
mkBtn(tabContents["Visual"], "✨ ENABLE EFFECTS", Color3.fromRGB(255, 50, 80), applyVisualEffects)
mkBtn(tabContents["Visual"], "❌ DISABLE EFFECTS", Color3.fromRGB(80, 80, 80), removeVisualEffects)
secT(tabContents["Visual"], "📝 Описание:")
local desc = Instance.new("TextLabel")
desc.Size = UDim2.new(1, 0, 0, 80); desc.BackgroundTransparency = 1
desc.Text = "• Крылья снизу (свечение)\n• Вращающийся круг под ногами\n• Пульсирующее свечение сверху"
desc.TextColor3 = C_COL.txt; desc.Font = Enum.Font.Gotham
desc.TextSize = 12; desc.TextXAlignment = Enum.TextXAlignment.Left
desc.TextYAlignment = Enum.TextYAlignment.Top; desc.Parent = tabContents["Visual"]

-- ═══ EVENTS ═══
workspace.DescendantAdded:Connect(function(ch)
    pcall(function()
        if trapDetection and ch.Name == "Trap" and (ch.Parent:IsA("Folder") or ch.Parent:IsA("Model")) then
            ch.Transparency = 0; reloadTrapESP(); notify("XDarkHUB", "Trap placed!")
        end
        if gunDropESP and ch.Name == "GunDrop" then
            reloadGunESP(); notify("XDarkHUB", "Gun dropped!")
            if autoGetDroppedGun then task.wait(1); teleportToGun() end
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

task.spawn(function()
    while task.wait(1) do
        if findSheriff() == localplayer and autoShooting then
            repeat
                task.wait(0.1)
                local murderer = findMurderer()
                if not murderer then continue end
                if not localplayer.Character:FindFirstChild("Gun") then
                    local hum = localplayer.Character:FindFirstChild("Humanoid")
                    if localplayer.Backpack:FindFirstChild("Gun") then hum:EquipTool(localplayer.Backpack:FindFirstChild("Gun"))
                    else continue end
                end
                local hrp = murderer.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                pcall(function()
                    localplayer.Character.Gun.Shoot:FireServer(CFrame.new(localplayer.Character.RightHand.Position), CFrame.new(getPredictedPosition(murderer)))
                end)
            until findSheriff() ~= localplayer or not autoShooting
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if loopThrow then pcall(function() knifeThrow() end) end
    end
end)

player.CharacterAdded:Connect(function(ch)
    character = ch; rootPart = ch:WaitForChild("HumanoidRootPart")
    visitedPositions = {}; farmStopped = false
    task.wait(1.5)
    if visualEffectsEnabled then
        visualEffectsEnabled = false
        applyVisualEffects()
    end
end)

player.Idled:Connect(function()
    if antiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

-- ═══ КНОПКА ОТКРЫТИЯ ═══
local mBtn = Instance.new("TextButton")
mBtn.Size = UDim2.new(0, 60, 0, 60); mBtn.Position = UDim2.new(0, 20, 0.5, -30)
mBtn.BackgroundColor3 = A_COL.base; mBtn.Text = "X"
mBtn.TextColor3 = C_COL.wht; mBtn.Font = Enum.Font.GothamBlack
mBtn.TextSize = 26; mBtn.BorderSizePixel = 0
mBtn.Parent = guiUI; crn(mBtn, 30); stk(mBtn, A_COL.neo, 1.5)

mBtn.MouseButton1Click:Connect(function()
    clickSnd:Play()
    frame.Visible = not frame.Visible
end)

switchTab("Sheriff")
notify("XDarkHUB", "v34 Loaded!")
notify("XDarkHUB", "Нажми X чтобы открыть меню")
notify("XDarkHUB", "✨ Вкладка Visual для эффектов")
