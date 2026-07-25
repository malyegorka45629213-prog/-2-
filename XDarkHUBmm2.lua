-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                    XDarkHUB v37 · FULL MM2 MODULE                            ║
-- ║              ВСЕ ФУНКЦИИ ИЗ YARHM + НАШ TERMINAL UI                         ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Debris = game:GetService("Debris")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local localplayer = player
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ═══════════════════════════════════════════════════════════════════════════════
--  ПЕРЕМЕННЫЕ MM2 (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
local playerESP = false
local sheriffAimbot = false
local coinAutoCollect = false
local autoShooting = false
local shootOffset = 2.8
local offsetToPingMult = 1
local predictionAIEngine = false
local gunDropESP = false
local trapDetection = false
local autoGetDroppedGun = false
local simulateKnifeThrow = false
local hideMeEsp = false
local instakillshoot = false
local spawnAtPlayer = false
local loopThrow = false
local ignoreknifethrow = false
local playerData = {}
local claimedCoins = {}

-- ═══════════════════════════════════════════════════════════════════════════════
--  ЗВУКИ
-- ═══════════════════════════════════════════════════════════════════════════════
local collectSound = Instance.new("Sound"); collectSound.SoundId = "rbxassetid://12221967"; collectSound.Volume = 1
local killSound = Instance.new("Sound"); killSound.SoundId = "rbxassetid://9120392731"; killSound.Volume = 0.8
local deathSound = Instance.new("Sound"); deathSound.SoundId = "rbxassetid://9120392731"; deathSound.Volume = 0.6
local clickSnd = Instance.new("Sound"); clickSnd.SoundId = "rbxassetid://169759176"; clickSnd.Volume = 0.25

-- ═══════════════════════════════════════════════════════════════════════════════
--  УВЕДОМЛЕНИЯ
-- ═══════════════════════════════════════════════════════════════════════════════
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 3})
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ФУНКЦИИ MM2 (ИЗ YARHM)
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
    local player = targetPlayer
    pcall(function() player = targetPlayer.Character end)
    local playerHRP = player:FindFirstChild("UpperTorso") or player:FindFirstChild("HumanoidRootPart")
    local playerHum = player:FindFirstChild("Humanoid")
    if not playerHRP or not playerHum then return Vector3.new(0,0,0) end
    local velocity = playerHRP.AssemblyLinearVelocity
    local playerMoveDirection = playerHum.MoveDirection
    local predictedPosition = playerHRP.Position + ((velocity * Vector3.new(0.75, 0.5, 0.75))) * (shootOffset / 15) + playerMoveDirection * shootOffset
    predictedPosition = predictedPosition * (((localplayer:GetNetworkPing() * 1000) * ((offsetToPingMult - 1) * 0.01)) + 1)
    return predictedPosition
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ESP СИСТЕМА (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
local espHighlights = {}

local function reloadESP()
    if not playerESP then return end
    
    -- Удаляем старые highlights
    for _, h in pairs(espHighlights) do
        if h then h:Destroy() end
    end
    espHighlights = {}
    
    local listplayers = Players:GetChildren()
    for _, pl in ipairs(listplayers) do
        if pl == localplayer and hideMeEsp then continue end
        if pl.Character ~= nil then
            local ch = pl.Character
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
                h.Name = "ESP_" .. pl.Name
                h.FillColor = color
                h.OutlineColor = color
                h.FillTransparency = 0.5
                h.OutlineTransparency = 0
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Adornee = ch
                h.Parent = gui
                espHighlights[pl] = h
            end)
        end
    end
end

-- Авто-обновление ESP при загрузке карты
workspace.ChildAdded:Connect(function(ch)
    if ch == getMap() and playerESP then
        notify("XDarkHUB", "Map loaded, waiting for roles...")
        repeat task.wait(1) until findMurderer() or findSheriff()
        reloadESP()
        notify("XDarkHUB", "Player ESP reloaded.")
    end
end)

workspace.ChildRemoved:Connect(function(ch)
    if ch == getMap() and playerESP then
        notify("XDarkHUB", "Game ended, removing ESPs.")
        playerData = {}
        for _, h in pairs(espHighlights) do
            if h then h:Destroy() end
        end
        espHighlights = {}
    end
end)

-- Trap ESP
workspace.DescendantAdded:Connect(function(ch)
    if trapDetection and ch.Name == "Trap" and (ch.Parent:IsA("Folder") or ch.Parent:IsA("Model")) then
        ch.Transparency = 0
        local h = Instance.new("Highlight")
        h.Name = "TrapESP_" .. tostring(ch)
        h.FillColor = Color3.fromRGB(255, 0, 0)
        h.OutlineColor = Color3.fromRGB(255, 0, 0)
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee = ch
        h.Parent = gui
        notify("XDarkHUB", "Murderer placed a trap!")
    end
    
    if gunDropESP and ch.Name == "GunDrop" then
        local h = Instance.new("Highlight")
        h.Name = "GunESP_" .. tostring(ch)
        h.FillColor = Color3.fromRGB(255, 255, 0)
        h.OutlineColor = Color3.fromRGB(255, 255, 0)
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee = ch
        h.Parent = gui
        notify("XDarkHUB", "Gun dropped! Find yellow highlight.")
        
        if autoGetDroppedGun then
            task.wait(1)
            local map = getMap()
            if map and map:FindFirstChild("GunDrop") then
                local previousPosition = localplayer.Character:GetPivot()
                localplayer.Character:MoveTo(map:FindFirstChild("GunDrop").Position)
                localplayer.Backpack.ChildAdded:Wait()
                localplayer.Character:PivotTo(previousPosition)
            end
        end
    end
end)

-- Player Data listener
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

-- ═══════════════════════════════════════════════════════════════════════════════
--  MINI FLING (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
function miniFling(playerToFling)
    local Character = localplayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = playerToFling.Character
    local THumanoid, TRootPart, THead, Accessory, Handle
    
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
    if Accessory and Accessory:FindFirstChild("handle") then
        Handle = Accessory.handle
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
        
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end
        
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
                else break end
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
            notify("XDarkHUB", "Can't find proper part to fling.")
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
        notify("XDarkHUB", "No valid character.")
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  MM2 ДЕЙСТВИЯ (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
function shootMurderer()
    if findSheriff() ~= localplayer then
        notify("XDarkHUB", "You're not sheriff/hero.")
        return
    end
    local murderer = findMurderer() or findSheriffThatsNotMe()
    if not murderer then
        notify("XDarkHUB", "No murderer to shoot.")
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
    if not murdererHRP then
        notify("XDarkHUB", "Could not find murderer's HRP.")
        return
    end
    local predictedPosition = getPredictedPosition(murderer)
    local args
    if instakillshoot then
        args = {
            CFrame.new(murdererHRP.Position + Vector3.new(0,1,0)),
            CFrame.new(murdererHRP.Position)
        }
    else
        args = {
            CFrame.new(localplayer.Character.RightHand.Position),
            CFrame.new(predictedPosition)
        }
    end
    localplayer.Character:WaitForChild("Gun"):WaitForChild("Shoot"):FireServer(unpack(args))
    notify("XDarkHUB", "Shot fired!")
end

function knifeThrow()
    if findMurderer() ~= localplayer then
        notify("XDarkHUB", "You're not murderer.")
        return
    end
    if not localplayer.Character:FindFirstChild("Knife") then
        local hum = localplayer.Character:FindFirstChild("Humanoid")
        if localplayer.Backpack:FindFirstChild("Knife") then
            hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
        else
            notify("XDarkHUB", "You don't have the knife.")
            return
        end
    end
    local NearestPlayer = findNearestPlayer()
    if not NearestPlayer or not NearestPlayer.Character then
        notify("XDarkHUB", "Can't find a player.")
        return
    end
    local nearestHRP = NearestPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not nearestHRP then return end
    local argsThrowRemote = {
        CFrame.new(localplayer.Character.RightHand.Position),
        CFrame.new(getPredictedPosition(NearestPlayer, shootOffset + 1))
    }
    if spawnAtPlayer then
        argsThrowRemote[1] = CFrame.new(nearestHRP.Position + (nearestHRP.CFrame.LookVector * 5))
    end
    localplayer.Character:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(unpack(argsThrowRemote))
    notify("XDarkHUB", "Knife thrown!")
end

function killClosest()
    if findMurderer() ~= localplayer then
        notify("XDarkHUB", "You're not murderer.")
        return
    end
    if not localplayer.Character:FindFirstChild("Knife") then
        local hum = localplayer.Character:FindFirstChild("Humanoid")
        if localplayer.Backpack:FindFirstChild("Knife") then
            localplayer.Character:FindFirstChild("Humanoid"):EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
        else
            notify("XDarkHUB", "You don't have the knife.")
            return
        end
    end
    local NearestPlayer = findNearestPlayer()
    if not NearestPlayer or not NearestPlayer.Character then
        notify("XDarkHUB", "Can't find a player.")
        return
    end
    local nearestHRP = NearestPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not nearestHRP then return end
    nearestHRP.Anchored = true
    nearestHRP.CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 2
    task.wait(0.1)
    local args = {[1] = "Slash"}
    localplayer.Character.Knife.Stab:FireServer(unpack(args))
    notify("XDarkHUB", "Killed closest!")
end

function killEveryone()
    if findMurderer() ~= localplayer then
        notify("XDarkHUB", "You're not murderer.")
        return
    end
    if not localplayer.Character:FindFirstChild("Knife") then
        local hum = localplayer.Character:FindFirstChild("Humanoid")
        if localplayer.Backpack:FindFirstChild("Knife") then
            localplayer.Character:FindFirstChild("Humanoid"):EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
        else
            notify("XDarkHUB", "You don't have the knife.")
            return
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= localplayer then
            p.Character:FindFirstChild("HumanoidRootPart").Anchored = true
            p.Character:FindFirstChild("HumanoidRootPart").CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 1
        end
    end
    local args = {[1] = "Slash"}
    localplayer.Character.Knife.Stab:FireServer(unpack(args))
    notify("XDarkHUB", "Killed everyone!")
end

function holdHostage()
    if findMurderer() ~= localplayer then
        notify("XDarkHUB", "You're not murderer.")
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= localplayer then
            p.Character:FindFirstChild("HumanoidRootPart").Anchored = true
            p.Character:FindFirstChild("HumanoidRootPart").CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 5
        end
    end
    notify("XDarkHUB", "All players held hostage!")
end

function godMode()
    local Cam = workspace.CurrentCamera
    local Pos, Char = Cam.CFrame, localplayer.Character
    local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
    if not Human then return end
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
    notify("XDarkHUB", "God mode activated!")
end

function teleportToGun()
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

function teleportToLobby()
    local lobby = workspace:FindFirstChild("Lobby")
    if lobby then
        local spawn = lobby.Spawns:FindFirstChildWhichIsA("SpawnLocation")
        if spawn then
            localplayer.Character:MoveTo(spawn.Position)
            notify("XDarkHUB", "Teleported to lobby!")
        end
    end
end

function teleportToMap()
    local map = getMap()
    if not map then
        notify("XDarkHUB", "No map.")
        return
    end
    local spawnsFolder = map:FindFirstChild("Spawns")
    if spawnsFolder then
        local spawns = spawnsFolder:GetChildren()
        local randomSpawn = spawns[math.random(1, #spawns)]
        localplayer.Character:MoveTo(randomSpawn.Position)
        notify("XDarkHUB", "Teleported to map!")
    end
end

function sendNamesToChat()
    local murd = findMurderer()
    local sher = findSheriff()
    local murdName = murd and murd.Name or "-"
    local sherName = sher and sher.Name or "-"
    local message = string.format("Murderer: %s | Sheriff: %s | <<XDarkHUB>>", murdName, sherName)
    local textchannels = game:GetService("TextChatService"):WaitForChild("TextChannels"):GetChildren()
    for _, textchannel in ipairs(textchannels) do
        if textchannel.Name == "RBXSystem" then continue end
        pcall(function() textchannel:SendAsync(message) end)
    end
    notify("XDarkHUB", "Names sent to chat!")
end

function copyMurdererName()
    local murd = findMurderer()
    if not murd then
        notify("XDarkHUB", "No murderer.")
        return
    end
    if setclipboard then
        setclipboard(murd.Name)
        notify("XDarkHUB", "Copied: " .. murd.Name)
    end
end

function copySheriffName()
    local sher = findSheriff()
    if not sher then
        notify("XDarkHUB", "No sheriff.")
        return
    end
    if setclipboard then
        setclipboard(sher.Name)
        notify("XDarkHUB", "Copied: " .. sher.Name)
    end
end

-- Auto Shoot Loop
task.spawn(function()
    while task.wait(1) do
        if findSheriff() == localplayer and autoShooting then
            notify("XDarkHUB", "Auto-shooting started.")
            repeat
                task.wait(0.1)
                local murderer = findMurderer()
                if not murderer then continue end
                local murdererPosition = murderer.Character.HumanoidRootPart.Position
                local characterRootPart = localplayer.Character.HumanoidRootPart
                local rayDirection = murdererPosition - characterRootPart.Position
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                raycastParams.FilterDescendantsInstances = {localplayer.Character}
                local hit = workspace:Raycast(characterRootPart.Position, rayDirection, raycastParams)
                if not hit or hit.Instance.Parent == murderer.Character then
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
                    local args = {CFrame.new(localplayer.Character.RightHand.Position), CFrame.new(predictedPosition)}
                    pcall(function() localplayer.Character:WaitForChild("Gun"):WaitForChild("Shoot"):FireServer(unpack(args)) end)
                end
            until findSheriff() ~= localplayer or not autoShooting
        end
    end
end)

-- Auto Knife Throw Loop
task.spawn(function()
    while task.wait(1.5) do
        if loopThrow then
            pcall(function() knifeThrow() end)
        end
    end
end)

-- Kill Aura
local killAuraCon = nil
function toggleKillAura(state)
    if state then
        if killAuraCon then killAuraCon:Disconnect() end
        killAuraCon = RunService.Heartbeat:Connect(function()
            if findMurderer() ~= localplayer then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= localplayer then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if (hrp.Position - localplayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude < 7 then
                        hrp.Anchored = true
                        hrp.CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 2
                        task.wait(0.1)
                        pcall(function() localplayer.Character.Knife.Stab:FireServer("Slash") end)
                        return
                    end
                end
            end
        end)
    else
        if killAuraCon then killAuraCon:Disconnect() end
        killAuraCon = nil
    end
end

-- Ignore Knife Throws
workspace.ChildAdded:Connect(function(chi)
    if chi.Name == "ThrowingKnife" and ignoreknifethrow then
        chi:Destroy()
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  TERMINAL UI (НАШ ДИЗАЙН)
-- ═══════════════════════════════════════════════════════════════════════════════
local CC = {bg=Color3.fromRGB(8,8,12),panel=Color3.fromRGB(12,12,18),card=Color3.fromRGB(18,18,26),cardHov=Color3.fromRGB(26,26,36),bdr=Color3.fromRGB(40,40,50),txt=Color3.fromRGB(245,245,255),mut=Color3.fromRGB(100,100,115),wht=Color3.fromRGB(255,255,255),dim=Color3.fromRGB(65,65,80)}
local AC = {base=Color3.fromRGB(235,35,60),dim=Color3.fromRGB(65,12,24),lit=Color3.fromRGB(255,90,115),neo=Color3.fromRGB(255,35,62),soft=Color3.fromRGB(190,45,70)}

local function crn(o,r) Instance.new("UICorner",o).CornerRadius=UDim.new(0,r or 8) end
local function stk(o,c,t,tr) local s=Instance.new("UIStroke",o) s.Color=c s.Thickness=t or 1 s.Transparency=tr or 0 end
local function grd(o,cs,rot) local g=Instance.new("UIGradient",o) g.Color=ColorSequence.new(cs) g.Rotation=rot or 0 end
local function ani(o,p,t,s) TweenService:Create(o,TweenInfo.new(t or 0.25,s or Enum.EasingStyle.Quint),p):Play() end

do local old=localplayer:WaitForChild("PlayerGui"):FindFirstChild("AutoFarmGui") if old then old:Destroy() end end

local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = localplayer:WaitForChild("PlayerGui")
collectSound.Parent = gui
killSound.Parent = gui
deathSound.Parent = gui
clickSnd.Parent = gui

-- Background
local bgF = Instance.new("Frame")
bgF.Size = UDim2.new(1,0,1,0)
bgF.BackgroundColor3 = CC.bg
bgF.BackgroundTransparency = 0.08
bgF.BorderSizePixel = 0
bgF.ZIndex = 0
bgF.Parent = gui
crn(bgF, 0)
grd(bgF, {ColorSequenceKeypoint.new(0,Color3.fromRGB(10,4,14)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(8,8,12)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,4,10))}, 45)

task.spawn(function() local r=0 while bgF.Parent do r=r+0.15 bgF.UIGradient.Rotation=r task.wait(0.05) end end)

local pCols = {AC.base,AC.neo,AC.lit,Color3.fromRGB(255,20,40),Color3.fromRGB(255,115,135)}
for i=1,28 do
    local sz = math.random(2,11)
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0,sz,0,sz)
    p.Position = UDim2.new(math.random(),0,math.random(),0)
    p.BackgroundColor3 = pCols[math.random(1,#pCols)]
    p.BackgroundTransparency = math.random(45,82)/100
    p.BorderSizePixel = 0
    p.ZIndex = 0
    p.Parent = bgF
    crn(p, math.random(1,5))
    task.spawn(function() while p.Parent do ani(p,{Position=UDim2.new(math.random(),0,math.random(),0),BackgroundTransparency=math.random(35,82)/100},math.random(16,36),Enum.EasingStyle.Sine) task.wait(math.random(16,36)) end end)
end

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,800,0,600)
frame.Position = UDim2.new(0.5,-400,0.5,-300)
frame.BackgroundColor3 = CC.bg
frame.BackgroundTransparency = 0.03
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.ZIndex = 1
frame.Parent = gui
crn(frame, 10)
stk(frame, AC.base, 1.5, 0.4)

frame.Size = UDim2.new(0,0,0,0)
frame.Position = UDim2.new(0.5,0,0.5,0)
ani(frame, {Size=UDim2.new(0,800,0,600),Position=UDim2.new(0.5,-400,0.5,-300)}, 0.6, Enum.EasingStyle.Back)

-- Header
local tBar = Instance.new("Frame")
tBar.Size = UDim2.new(1,0,0,60)
tBar.BackgroundColor3 = CC.panel
tBar.BackgroundTransparency = 0.04
tBar.BorderSizePixel = 0
tBar.Active = true
tBar.ZIndex = 2
tBar.Parent = frame
crn(tBar, 10)
grd(tBar, {ColorSequenceKeypoint.new(0,Color3.fromRGB(20,14,24)),ColorSequenceKeypoint.new(1,Color3.fromRGB(12,10,16))})

local logo = Instance.new("Frame")
logo.Size = UDim2.new(0,40,0,40)
logo.Position = UDim2.new(0,15,0.5,-20)
logo.BackgroundColor3 = AC.base
logo.BorderSizePixel = 0
logo.ZIndex = 3
logo.Parent = tBar
crn(logo, 10)
stk(logo, AC.neo, 1.5, 0.3)

local logoX = Instance.new("TextLabel")
logoX.Size = UDim2.new(1,0,1,0)
logoX.BackgroundTransparency = 1
logoX.Text = "X"
logoX.Font = Enum.Font.GothamBlack
logoX.TextSize = 26
logoX.TextColor3 = CC.wht
logoX.ZIndex = 4
logoX.Parent = logo

local tLbl = Instance.new("TextLabel")
tLbl.Size = UDim2.new(1,-150,1,0)
tLbl.Position = UDim2.new(0,65,0,0)
tLbl.BackgroundTransparency = 1
tLbl.Text = "XDarkHUB"
tLbl.Font = Enum.Font.GothamBlack
tLbl.TextSize = 24
tLbl.TextColor3 = AC.lit
tLbl.TextXAlignment = Enum.TextXAlignment.Left
tLbl.ZIndex = 3
tLbl.Parent = tBar

Instance.new("TextLabel", {Size=UDim2.new(0,80,1,0),Position=UDim2.new(1,-90,0,0),BackgroundTransparency=1,Text="[v37]",Font=Enum.Font.Code,TextSize=12,TextColor3=CC.mut,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=3,Parent=tBar})

-- Dragging
do
    local dr,ds,sp=false,nil,nil
    tBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true;ds=i.Position;sp=frame.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ds frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
end

-- Container
local ctr = Instance.new("Frame")
ctr.Size = UDim2.new(1,0,1,-65)
ctr.Position = UDim2.new(0,0,0,65)
ctr.BackgroundTransparency = 1
ctr.Parent = frame

local lPan = Instance.new("Frame")
lPan.Size = UDim2.new(0,200,1,0)
lPan.BackgroundColor3 = CC.panel
lPan.BackgroundTransparency = 0.04
lPan.BorderSizePixel = 0
lPan.ZIndex = 2
lPan.Parent = ctr

local vLine = Instance.new("Frame")
vLine.Size = UDim2.new(0,1,1,0)
vLine.Position = UDim2.new(0,200,0,0)
vLine.BackgroundColor3 = AC.base
vLine.BackgroundTransparency = 0.65
vLine.BorderSizePixel = 0
vLine.ZIndex = 3
vLine.Parent = ctr

local rPan = Instance.new("Frame")
rPan.Size = UDim2.new(1,-205,1,0)
rPan.Position = UDim2.new(0,205,0,0)
rPan.BackgroundTransparency = 1
rPan.ZIndex = 2
rPan.Parent = ctr

-- Tabs
local tabs = {}
local tabContents = {}
local currentTab = nil

local function createTab(name,icon,order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,55)
    btn.Position = UDim2.new(0,10,0,15+(order-1)*60)
    btn.BackgroundColor3 = CC.card
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.ZIndex = 5
    btn.Active = true
    btn.AutoButtonColor = false
    btn.Parent = lPan
    crn(btn, 10)
    
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0,3,0,30)
    ind.Position = UDim2.new(0,0,0.5,-15)
    ind.BackgroundColor3 = AC.base
    ind.BackgroundTransparency = 1
    ind.BorderSizePixel = 0
    ind.ZIndex = 6
    ind.Parent = btn
    
    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(0,40,1,0)
    ic.Position = UDim2.new(0,15,0,0)
    ic.BackgroundTransparency = 1
    ic.Text = icon
    ic.Font = Enum.Font.GothamBold
    ic.TextSize = 22
    ic.TextColor3 = CC.mut
    ic.ZIndex = 6
    ic.Parent = btn
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-60,1,0)
    lbl.Position = UDim2.new(0,55,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextColor3 = CC.mut
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6
    lbl.Parent = btn
    
    tabs[name] = {btn=btn,ic=ic,ind=ind,lbl=lbl}
    
    btn.MouseEnter:Connect(function() if currentTab~=name then ani(btn,{BackgroundTransparency=0.3},0.15) ani(ic,{TextColor3=CC.txt},0.15) end end)
    btn.MouseLeave:Connect(function() if currentTab~=name then ani(btn,{BackgroundTransparency=1},0.15) ani(ic,{TextColor3=CC.mut},0.15) end end)
end

local function createTabContent(name)
    local c = Instance.new("ScrollingFrame")
    c.Size = UDim2.new(1,0,1,0)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = 3
    c.ScrollBarImageColor3 = AC.base
    c.CanvasSize = UDim2.new(0,0,0,0)
    c.AutomaticCanvasSize = Enum.AutomaticSize.Y
    c.Visible = false
    c.ZIndex = 2
    c.Parent = rPan
    
    local p = Instance.new("UIPadding", c)
    p.PaddingLeft = UDim.new(0,25)
    p.PaddingRight = UDim.new(0,25)
    p.PaddingTop = UDim.new(0,20)
    p.PaddingBottom = UDim.new(0,20)
    
    local l = Instance.new("UIListLayout", c)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0,12)
    
    tabContents[name] = c
end

local function switchTab(name)
    for n,t in pairs(tabs) do
        t.btn.BackgroundTransparency = 1
        t.btn.BackgroundColor3 = CC.card
        t.ic.TextColor3 = CC.mut
        t.lbl.TextColor3 = CC.mut
        t.ind.BackgroundTransparency = 1
    end
    if tabs[name] then
        tabs[name].btn.BackgroundTransparency = 0.35
        tabs[name].btn.BackgroundColor3 = Color3.fromRGB(20,20,28)
        tabs[name].ic.TextColor3 = AC.neo
        tabs[name].lbl.TextColor3 = CC.wht
        tabs[name].ind.BackgroundTransparency = 0
        tabs[name].ind.BackgroundColor3 = AC.neo
    end
    for n,c in pairs(tabContents) do
        if n == name then
            c.Visible = true
            c.Position = UDim2.new(0,50,0,0)
            ani(c, {Position=UDim2.new(0,0,0,0)}, 0.35, Enum.EasingStyle.Back)
        else
            c.Visible = false
        end
    end
    currentTab = name
end

createTab("ESP", "👁️", 1)
createTab("Sheriff", "⭐", 2)
createTab("Murderer", "🔪", 3)
createTab("Teleports", "🗺️", 4)
createTab("Misc", "⚙️", 5)

for n in pairs(tabs) do createTabContent(n) end
for n,t in pairs(tabs) do t.btn.MouseButton1Click:Connect(function() clickSnd:Play() switchTab(n) end) end

-- UI Components
local function secT(par,ord,txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,26)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = AC.soft
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = ord
    l.ZIndex = 2
    l.Parent = par
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1,0,0,1)
    ln.BackgroundColor3 = AC.base
    ln.BackgroundTransparency = 0.82
    ln.BorderSizePixel = 0
    ln.LayoutOrder = ord + 0.1
    ln.ZIndex = 2
    ln.Parent = par
end

local function togC(par,ord,label,onTog)
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(1,0,0,52)
    cd.BackgroundTransparency = 1
    cd.LayoutOrder = ord
    cd.ZIndex = 2
    cd.Parent = par
    
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1,0,0,1)
    ln.Position = UDim2.new(0,0,1,0)
    ln.BackgroundColor3 = CC.bdr
    ln.BackgroundTransparency = 0.65
    ln.BorderSizePixel = 0
    ln.ZIndex = 2
    ln.Parent = cd
    
    Instance.new("TextLabel", {Size=UDim2.new(1,-110,1,0),BackgroundTransparency=1,Text=label,TextColor3=CC.txt,Font=Enum.Font.GothamBold,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=cd})
    
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0,60,0,30)
    sw.Position = UDim2.new(1,-68,0.5,-15)
    sw.BackgroundColor3 = CC.bdr
    sw.BorderSizePixel = 0
    sw.ZIndex = 2
    sw.Parent = cd
    crn(sw, 15)
    stk(sw, Color3.fromRGB(55,55,70), 1)
    
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0,20,0,20)
    ind.Position = UDim2.new(0,5,0.5,-10)
    ind.BackgroundColor3 = CC.mut
    ind.BorderSizePixel = 0
    ind.ZIndex = 2
    ind.Parent = sw
    crn(ind, 10)
    
    local pl = Instance.new("TextLabel")
    pl.Size = UDim2.new(1,0,1,0)
    pl.Position = UDim2.new(0,28,0,0)
    pl.BackgroundTransparency = 1
    pl.Text = "OFF"
    pl.TextColor3 = CC.mut
    pl.Font = Enum.Font.GothamBold
    pl.TextSize = 11
    pl.TextXAlignment = Enum.TextXAlignment.Left
    pl.ZIndex = 2
    pl.Parent = sw
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
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
            ani(sw, {BackgroundColor3=AC.dim}, 0.2)
            sw.UIStroke.Color = AC.base
            ani(ind, {Position=UDim2.new(0,35,0.5,-10), BackgroundColor3=AC.neo}, 0.25, Enum.EasingStyle.Back)
            pl.Text = "ON"
            ani(pl, {TextColor3=AC.lit}, 0.2)
            ani(cd, {BackgroundColor3=Color3.fromRGB(20,16,22), BackgroundTransparency=0.5}, 0.2)
        else
            ani(sw, {BackgroundColor3=CC.bdr}, 0.2)
            sw.UIStroke.Color = Color3.fromRGB(55,55,70)
            ani(ind, {Position=UDim2.new(0,5,0.5,-10), BackgroundColor3=CC.mut}, 0.25, Enum.EasingStyle.Back)
            pl.Text = "OFF"
            ani(pl, {TextColor3=CC.mut}, 0.2)
            cd.BackgroundTransparency = 1
        end
        if onTog then onTog(st) end
    end)
    btn.MouseEnter:Connect(function() if not st then ani(cd,{BackgroundColor3=Color3.fromRGB(18,18,24),BackgroundTransparency=0.5},0.15) end end)
    btn.MouseLeave:Connect(function() if not st then cd.BackgroundTransparency=1 end end)
end

local function mkBtn(par,ord,text,color,callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,52)
    b.BackgroundColor3 = color or AC.base
    b.Text = text
    b.TextColor3 = CC.wht
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 15
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.LayoutOrder = ord
    b.ZIndex = 2
    b.Active = true
    b.Parent = par
    crn(b, 10)
    stk(b, AC.neo, 1.5)
    b.MouseEnter:Connect(function() ani(b,{BackgroundColor3=AC.neo},0.15) end)
    b.MouseLeave:Connect(function() ani(b,{BackgroundColor3=color or AC.base},0.15) end)
    b.MouseButton1Click:Connect(function() clickSnd:Play() callback() end)
end

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
            repeat task.wait(1) until findSheriff() or findMurderer()
        end
        reloadESP()
    else
        for _, h in pairs(espHighlights) do
            if h then h:Destroy() end
        end
        espHighlights = {}
    end
end)
togC(espC, 3, "Dropped Gun ESP", function(s) gunDropESP = s end)
togC(espC, 4, "Traps ESP", function(s) trapDetection = s end)
togC(espC, 5, "Hide My Own ESP", function(s) hideMeEsp = s reloadESP() end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  TAB CONTENT - SHERIFF
-- ═══════════════════════════════════════════════════════════════════════════════
local sheriffC = tabContents["Sheriff"]
secT(sheriffC, 1, "⭐ SHERIFF TOOLS")
mkBtn(sheriffC, 2, "🔫 SHOOT MURDERER", AC.base, shootMurderer)
mkBtn(sheriffC, 3, "🔫 TP TO DROPPED GUN", Color3.fromRGB(255,200,0), teleportToGun)
togC(sheriffC, 4, "Auto Shoot Murderer", function(s) autoShooting = s end)
togC(sheriffC, 5, "Auto Get Gun On Drop", function(s) autoGetDroppedGun = s end)
togC(sheriffC, 6, "Instakill Shoot", function(s) instakillshoot = s end)
mkBtn(sheriffC, 7, "📋 SEND NAMES TO CHAT", Color3.fromRGB(50,100,200), sendNamesToChat)
mkBtn(sheriffC, 8, "📋 COPY MURDERER NAME", Color3.fromRGB(80,80,80), copyMurdererName)
mkBtn(sheriffC, 9, "📋 COPY SHERIFF NAME", Color3.fromRGB(80,80,80), copySheriffName)
mkBtn(sheriffC, 10, "⭐ FLING SHERIFF", Color3.fromRGB(50,150,255), function()
    local s = findSheriff()
    if s then miniFling(s) else notify("XDarkHUB", "No sheriff") end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  TAB CONTENT - MURDERER
-- ═══════════════════════════════════════════════════════════════════════════════
local murdererC = tabContents["Murderer"]
secT(murdererC, 1, "🔪 MURDERER TOOLS")
mkBtn(murdererC, 2, "🔪 KNIFE THROW", AC.base, knifeThrow)
mkBtn(murdererC, 3, "💀 KILL CLOSEST", Color3.fromRGB(200,0,0), killClosest)
mkBtn(murdererC, 4, "💀 KILL EVERYONE", Color3.fromRGB(150,0,0), killEveryone)
mkBtn(murdererC, 5, "🔒 HOLD HOSTAGE", Color3.fromRGB(100,0,50), holdHostage)
togC(murdererC, 6, "Auto Knife Throw", function(s) loopThrow = s end)
togC(murdererC, 7, "Kill Aura", function(s) toggleKillAura(s) end)
togC(murdererC, 8, "Spawn Knife Near Player", function(s) spawnAtPlayer = s end)
togC(murdererC, 9, "Ignore Knife Throws", function(s) ignoreknifethrow = s end)
mkBtn(murdererC, 10, "⚡ GOD MODE", Color3.fromRGB(150,0,150), godMode)
mkBtn(murdererC, 11, "🔪 FLING MURDERER", AC.base, function()
    local m = findMurderer()
    if m then miniFling(m) else notify("XDarkHUB", "No murderer") end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  TAB CONTENT - TELEPORTS
-- ═══════════════════════════════════════════════════════════════════════════════
local teleportsC = tabContents["Teleports"]
secT(teleportsC, 1, "🗺️ TELEPORTS")
mkBtn(teleportsC, 2, "🏠 TP TO LOBBY", Color3.fromRGB(50,100,200), teleportToLobby)
mkBtn(teleportsC, 3, "🗺️ TP TO MAP", Color3.fromRGB(50,150,50), teleportToMap)

-- ═══════════════════════════════════════════════════════════════════════════════
--  TAB CONTENT - MISC
-- ═══════════════════════════════════════════════════════════════════════════════
local miscC = tabContents["Misc"]
secT(miscC, 1, "⚙️ SETTINGS")

-- Shoot Offset Input
do
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(1,0,0,52)
    cd.BackgroundTransparency = 1
    cd.LayoutOrder = 2
    cd.ZIndex = 2
    cd.Parent = miscC
    
    Instance.new("Frame", {Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=CC.bdr,BackgroundTransparency=0.65,BorderSizePixel=0,ZIndex=2,Parent=cd})
    Instance.new("TextLabel", {Size=UDim2.new(0.5,0,1,0),BackgroundTransparency=1,Text="Shoot Offset",TextColor3=CC.txt,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=cd})
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.4,0,1,0)
    input.Position = UDim2.new(0.55,0,0,0)
    input.BackgroundColor3 = CC.card
    input.Text = tostring(shootOffset)
    input.TextColor3 = CC.wht
    input.Font = Enum.Font.GothamBold
    input.TextSize = 13
    input.PlaceholderText = "2.8"
    input.BorderSizePixel = 0
    input.ZIndex = 2
    input.Parent = cd
    crn(input, 8)
    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then
            shootOffset = val
            notify("XDarkHUB", "Offset: " .. val)
        end
    end)
end

-- Ping Multiplier Input
do
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(1,0,0,52)
    cd.BackgroundTransparency = 1
    cd.LayoutOrder = 3
    cd.ZIndex = 2
    cd.Parent = miscC
    
    Instance.new("Frame", {Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=CC.bdr,BackgroundTransparency=0.65,BorderSizePixel=0,ZIndex=2,Parent=cd})
    Instance.new("TextLabel", {Size=UDim2.new(0.5,0,1,0),BackgroundTransparency=1,Text="Ping Multiplier",TextColor3=CC.txt,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=cd})
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.4,0,1,0)
    input.Position = UDim2.new(0.55,0,0,0)
    input.BackgroundColor3 = CC.card
    input.Text = tostring(offsetToPingMult)
    input.TextColor3 = CC.wht
    input.Font = Enum.Font.GothamBold
    input.TextSize = 13
    input.PlaceholderText = "1"
    input.BorderSizePixel = 0
    input.ZIndex = 2
    input.Parent = cd
    crn(input, 8)
    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then
            offsetToPingMult = val
            notify("XDarkHUB", "Ping mult: " .. val)
        end
    end)
end

-- Menu Button
local mBtn = Instance.new("TextButton")
mBtn.Size = UDim2.new(0,70,0,70)
mBtn.Position = UDim2.new(0,20,1,-90)
mBtn.BackgroundColor3 = AC.base
mBtn.Text = "X"
mBtn.TextColor3 = CC.wht
mBtn.Font = Enum.Font.GothamBlack
mBtn.TextSize = 30
mBtn.BorderSizePixel = 0
mBtn.ZIndex = 10
mBtn.Active = true
mBtn.AutoButtonColor = false
mBtn.Parent = gui
crn(mBtn, 35)
stk(mBtn, AC.neo, 1.5, 0.4)

task.spawn(function() while mBtn.Parent do ani(mBtn,{Size=UDim2.new(0,75,0,75)},1.5,Enum.EasingStyle.Sine) task.wait(1.5) ani(mBtn,{Size=UDim2.new(0,70,0,70)},1.5,Enum.EasingStyle.Sine) task.wait(1.5) end end)

do
    local dr,ds,sp=false,nil,nil
    mBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true;ds=i.Position;sp=mBtn.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ds mBtn.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
end

mBtn.MouseButton1Click:Connect(function() clickSnd:Play() local v=frame.Visible frame.Visible=not v bgF.Visible=not v end)

localplayer.CharacterAdded:Connect(function(ch)
    character = ch
    rootPart = ch:WaitForChild("HumanoidRootPart")
    task.wait(1.5)
end)

switchTab("ESP")
notify("XDarkHUB", "v37 Loaded - Full MM2 Module!", 3)
notify("XDarkHUB", "All YARHM functions included!", 3)
