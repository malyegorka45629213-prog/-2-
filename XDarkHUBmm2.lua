-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                         XDarkHUB v34 · FULL MM2 MODULE                       ║
-- ║   ВСЕ ФУНКЦИИ ИЗ YARHM + ПЛАВАЮЩИЕ КНОПКИ + НАШ UI                          ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Debris = game:GetService("Debris")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local localplayer = player
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ═══════════════════════════════════════════════════════════════════════════════
--  ПЕРЕМЕННЫЕ СОСТОЯНИЯ
-- ═══════════════════════════════════════════════════════════════════════════════
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
local MAX_BAG = 40

-- ═══════════════════════════════════════════════════════════════════════════════
--  MM2 ПЕРЕМЕННЫЕ (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
local playerESP = false
local sheriffAimbot = false
local coinAutoCollect = false
local autoShooting = false
local shootOffset = 2.8
local offsetToPingMult = 1
local predictionAIEngine = false
local predictionOngoing = false
local predictionCooldown = false
local gunDropESP = false
local trapDetection = false
local autoGetDroppedGun = false
local simulateKnifeThrow = false
local playerData = {}
local claimedCoins = {}
local hideMeEsp = false
local instakillshoot = false
local spawnAtPlayer = false
local loopThrow = false
local ignoreknifethrow = false
local killAuraCon = nil

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
--  MM2 ФУНКЦИИ (ИЗ YARHM)
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

local function getClosestModelToPlayer(pl, models)
    local closestModel = nil
    local closestDistance = math.huge
    local playerPosition = pl.Character.HumanoidRootPart.Position
    for _, model in ipairs(models) do
        local modelPosition = model:GetPivot().Position
        local distance = (modelPosition - playerPosition).Magnitude
        if distance < closestDistance then
            closestDistance = distance
            closestModel = model
        end
    end
    return closestModel
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  MINI FLING (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
function miniFling(playerToFling)
    local Character = player.Character
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
            notify("XDarkHUB", "Can't find a proper part to fling.")
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
--  ESP ФУНКЦИИ (ИСПРАВЛЕНО: gui -> guiUI)
-- ═══════════════════════════════════════════════════════════════════════════════
local espHighlights = {}

local function reloadESP()
    if not playerESP then return end
    for key, h in pairs(espHighlights) do 
        if h and h:IsA("Highlight") then 
            h:Destroy() 
        end 
    end
    espHighlights = {}
    
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
        notify("XDarkHUB", "No map to teleport to.")
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
    local textchannels = TextChatService:WaitForChild("TextChannels"):GetChildren()
    for _, textchannel in ipairs(textchannels) do
        if textchannel.Name == "RBXSystem" then continue end
        pcall(function() textchannel:SendAsync(message) end)
    end
    notify("XDarkHUB", "Names sent to chat!")
end

function copyMurdererName()
    local murd = findMurderer()
    if not murd then
        notify("XDarkHUB", "No murderer to copy.")
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
        notify("XDarkHUB", "No sheriff to copy.")
        return
    end
    if setclipboard then
        setclipboard(sher.Name)
        notify("XDarkHUB", "Copied: " .. sher.Name)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO SHOOT LOOP (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(1) do
        if findSheriff() == localplayer and autoShooting then
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
                    local args = {
                        CFrame.new(localplayer.Character.RightHand.Position),
                        CFrame.new(predictedPosition)
                    }
                    pcall(function()
                        localplayer.Character:WaitForChild("Gun"):WaitForChild("Shoot"):FireServer(unpack(args))
                    end)
                end
            until findSheriff() ~= localplayer or not autoShooting
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO KNIFE THROW LOOP
-- ═══════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(1.5) do
        if loopThrow then
            pcall(function() knifeThrow() end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  KILL AURA LOOP
-- ═══════════════════════════════════════════════════════════════════════════════
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
                        local args = {[1] = "Slash"}
                        pcall(function() localplayer.Character.Knife.Stab:FireServer(unpack(args)) end)
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

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO GET GUN ON DROP (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
workspace.DescendantAdded:Connect(function(ch)
    if trapDetection and ch.Name == "Trap" and (ch.Parent:IsA("Folder") or ch.Parent:IsA("Model")) then
        ch.Transparency = 0
        reloadTrapESP()
        notify("XDarkHUB", "Murderer has placed a trap!")
    end
    if gunDropESP and ch.Name == "GunDrop" then
        reloadGunESP()
        notify("XDarkHUB", "Gun has been dropped!")
        if autoGetDroppedGun then
            task.wait(1)
            local map = getMap()
            if not map or not map:FindFirstChild("GunDrop") then return end
            local previousPosition = localplayer.Character:GetPivot()
            localplayer.Character:MoveTo(map:FindFirstChild("GunDrop").Position)
            localplayer.Backpack.ChildAdded:Wait()
            localplayer.Character:PivotTo(previousPosition)
        end
    end
end)

workspace.DescendantRemoving:Connect(function(ch)
    if gunDropESP and ch.Name == "GunDrop" then
        reloadGunESP()
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  IGNORE KNIFE THROW
-- ═══════════════════════════════════════════════════════════════════════════════
workspace.ChildAdded:Connect(function(chi)
    if chi.Name == "ThrowingKnife" and ignoreknifethrow then
        chi:Destroy()
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  PLAYER DATA LISTENER (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
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
--  FLOATING BUTTONS SYSTEM (КРАСИВЫЕ ПОЛУПРОЗРАЧНЫЕ С ЭФФЕКТОМ)
-- ═══════════════════════════════════════════════════════════════════════════════
local floatingButtons = {}

local function createFloatingButton(name, text, color, callback, position)
    if floatingButtons[name] then
        floatingButtons[name]:Destroy()
        floatingButtons[name] = nil
    end
    
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 160, 0, 55)
    button.Position = position or UDim2.new(0, 125, 0, 90)
    button.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    button.BackgroundTransparency = 0.4  -- Полупрозрачный
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.ClipsDescendants = true
    button.Parent = guiUI
    
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 12)
    
    -- Неоновая обводка
    local stroke = Instance.new("UIStroke", button)
    stroke.Color = Color3.fromRGB(255, 50, 80)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    
    -- Красивый градиент внутри
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
    
    -- Анимация свечения
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
    
    -- Эффект при наведении
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.3}):Play()
    end)
    
    -- Перетаскивание
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
    
    -- Анимация появления
    button.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(button, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 160, 0, 55)
    }):Play()
    
    floatingButtons[name] = button
    notify("XDarkHUB", "Button created: " .. text)
    return button
end

local function removeFloatingButton(name)
    if floatingButtons[name] then
        local button = floatingButtons[name]
        TweenService:Create(button, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.3)
        button:Destroy()
        floatingButtons[name] = nil
        notify("XDarkHUB", "Button removed: " .. name)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  UI СИСТЕМА XDarkHUB
-- ═══════════════════════════════════════════════════════════════════════════════
local C_COL = {
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
local A_COL = {
    base = Color3.fromRGB(235, 35, 60),
    dim = Color3.fromRGB(65, 12, 24),
    lit = Color3.fromRGB(255, 90, 115),
    neo = Color3.fromRGB(255, 35, 62),
    soft = Color3.fromRGB(190, 45, 70),
}

local function crn(o, r) local c = Instance.new("UICorner", o) c.CornerRadius = UDim.new(0, r or 8) end
local function stk(o, c, t, tr) local s = Instance.new("UIStroke", o) s.Color = c s.Thickness = t or 1 s.Transparency = tr or 0 end
local function grd(o, cs, rot) local g = Instance.new("UIGradient", o) g.Color = ColorSequence.new(cs) g.Rotation = rot or 0 end
local function ani(o, p, t, s) TweenService:Create(o, TweenInfo.new(t or 0.25, s or Enum.EasingStyle.Quint), p):Play end

do local old = player:WaitForChild("PlayerGui"):FindFirstChild("AutoFarmGui") if old then old:Destroy() end end

local guiUI = Instance.new("ScreenGui")
guiUI.Name = "AutoFarmGui"
guiUI.ResetOnSpawn = false
guiUI.IgnoreGuiInset = true
guiUI.Parent = player:WaitForChild("PlayerGui")
collectSound.Parent = guiUI
killSound.Parent = guiUI
deathSound.Parent = guiUI
clickSnd.Parent = guiUI

-- Background particles
local bgF = Instance.new("Frame")
bgF.Size = UDim2.new(1, 0, 1, 0)
bgF.BackgroundColor3 = C_COL.bg
bgF.BackgroundTransparency = 0.08
bgF.BorderSizePixel = 0
bgF.ZIndex = 0
bgF.Parent = guiUI
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

local pCols = {A_COL.base, A_COL.neo, A_COL.lit, Color3.fromRGB(255, 20, 40), Color3.fromRGB(255, 115, 135)}
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
stk(frame, A_COL.base, 1.5, 0.4)

local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, 0, 0, 2)
topLine.BackgroundColor3 = A_COL.neo
topLine.BackgroundTransparency = 0.15
topLine.BorderSizePixel = 0
topLine.ZIndex = 3
topLine.Parent = frame
crn(topLine, 1)

frame.Size = UDim2.new(0, 0, 0, 0)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
ani(frame, {Size = UDim2.new(0, 800, 0, 600), Position = UDim2.new(0.5, -400, 0.5, -300)}, 0.6, Enum.EasingStyle.Back)

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
grd(tBar, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 14, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 10, 16))
})

local logo = Instance.new("Frame")
logo.Size = UDim2.new(0, 40, 0, 40)
logo.Position = UDim2.new(0, 15, 0.5, -20)
logo.BackgroundColor3 = A_COL.base
logo.BorderSizePixel = 0
logo.ZIndex = 3
logo.Parent = tBar
crn(logo, 10)
stk(logo, A_COL.neo, 1.5, 0.3)

local logoX = Instance.new("TextLabel")
logoX.Size = UDim2.new(1, 0, 1, 0)
logoX.BackgroundTransparency = 1
logoX.Text = "X"
logoX.Font = Enum.Font.GothamBlack
logoX.TextSize = 26
logoX.TextColor3 = C_COL.wht
logoX.ZIndex = 4
logoX.Parent = logo

local tLbl = Instance.new("TextLabel")
tLbl.Size = UDim2.new(1, -150, 1, 0)
tLbl.Position = UDim2.new(0, 65, 0, 0)
tLbl.BackgroundTransparency = 1
tLbl.Text = "XDarkHUB"
tLbl.Font = Enum.Font.GothamBlack
tLbl.TextSize = 24
tLbl.TextColor3 = A_COL.lit
tLbl.TextXAlignment = Enum.TextXAlignment.Left
tLbl.ZIndex = 3
tLbl.Parent = tBar

local sep1 = Instance.new("Frame")
sep1.Size = UDim2.new(0, 1, 0, 30)
sep1.Position = UDim2.new(0, 60, 0.5, -15)
sep1.BackgroundColor3 = A_COL.base
sep1.BackgroundTransparency = 0.5
sep1.BorderSizePixel = 0
sep1.ZIndex = 3
sep1.Parent = tBar

local vLbl = Instance.new("TextLabel")
vLbl.Size = UDim2.new(0, 80, 1, 0)
vLbl.Position = UDim2.new(1, -90, 0, 0)
vLbl.BackgroundTransparency = 1
vLbl.Text = "[v34]"
vLbl.Font = Enum.Font.Code
vLbl.TextSize = 12
vLbl.TextColor3 = C_COL.mut
vLbl.TextXAlignment = Enum.TextXAlignment.Right
vLbl.ZIndex = 3
vLbl.Parent = tBar

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

local vLine = Instance.new("Frame")
vLine.Size = UDim2.new(0, 1, 1, 0)
vLine.Position = UDim2.new(0, 200, 0, 0)
vLine.BackgroundColor3 = A_COL.base
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
    
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 3, 0, 30)
    ind.Position = UDim2.new(0, 0, 0.5, -15)
    ind.BackgroundColor3 = A_COL.base
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
    
    tabs[name] = {btn = btn, ic = ic, ind = ind, lbl = lbl}
    
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
        t.ind.BackgroundTransparency = 1
    end
    if tabs[name] then
        tabs[name].btn.BackgroundTransparency = 0.35
        tabs[name].btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        tabs[name].ic.TextColor3 = A_COL.neo
        tabs[name].lbl.TextColor3 = C_COL.wht
        tabs[name].ind.BackgroundTransparency = 0
        tabs[name].ind.BackgroundColor3 = A_COL.neo
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

-- UI Components
local function secT(par, ord, txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 26)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = A_COL.soft
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = ord
    l.ZIndex = 2
    l.Parent = par
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1, 0, 0, 1)
    ln.BackgroundColor3 = A_COL.base
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
    ln.BackgroundColor3 = C_COL.bdr
    ln.BackgroundTransparency = 0.65
    ln.BorderSizePixel = 0
    ln.ZIndex = 2
    ln.Parent = r
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 5, 0, 5)
    dot.Position = UDim2.new(0, 0, 0.5, -2.5)
    dot.BackgroundColor3 = A_COL.base
    dot.BorderSizePixel = 0
    dot.ZIndex = 2
    dot.Parent = r
    crn(dot, 3)
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0.6, 0, 1, 0)
    n.Position = UDim2.new(0, 18, 0, 0)
    n.BackgroundTransparency = 1
    n.Text = name
    n.TextColor3 = C_COL.mut
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
    v.TextColor3 = A_COL.lit
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
    ln.BackgroundColor3 = C_COL.bdr
    ln.BackgroundTransparency = 0.65
    ln.BorderSizePixel = 0
    ln.ZIndex = 2
    ln.Parent = cd
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
    sw.BackgroundColor3 = C_COL.bdr
    sw.BorderSizePixel = 0
    sw.ZIndex = 2
    sw.Parent = cd
    crn(sw, 15)
    stk(sw, Color3.fromRGB(55, 55, 70), 1)
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 20, 0, 20)
    ind.Position = UDim2.new(0, 5, 0.5, -10)
    ind.BackgroundColor3 = C_COL.mut
    ind.BorderSizePixel = 0
    ind.ZIndex = 2
    ind.Parent = sw
    crn(ind, 10)
    local pl = Instance.new("TextLabel")
    pl.Size = UDim2.new(1, 0, 1, 0)
    pl.Position = UDim2.new(0, 28, 0, 0)
    pl.BackgroundTransparency = 1
    pl.Text = "OFF"
    pl.TextColor3 = C_COL.mut
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
            ani(sw, {BackgroundColor3 = A_COL.dim}, 0.2)
            sw.UIStroke.Color = A_COL.base
            ani(ind, {Position = UDim2.new(0, 35, 0.5, -10), BackgroundColor3 = A_COL.neo}, 0.25, Enum.EasingStyle.Back)
            pl.Text = "ON"
            ani(pl, {TextColor3 = A_COL.lit}, 0.2)
            ani(cd, {BackgroundColor3 = Color3.fromRGB(20, 16, 22), BackgroundTransparency = 0.5}, 0.2)
        else
            ani(sw, {BackgroundColor3 = C_COL.bdr}, 0.2)
            sw.UIStroke.Color = Color3.fromRGB(55, 55, 70)
            ani(ind, {Position = UDim2.new(0, 5, 0.5, -10), BackgroundColor3 = C_COL.mut}, 0.25, Enum.EasingStyle.Back)
            pl.Text = "OFF"
            ani(pl, {TextColor3 = C_COL.mut}, 0.2)
            cd.BackgroundTransparency = 1
        end
        if onTog then onTog(st) end
    end)
    btn.MouseEnter:Connect(function() if not st then ani(cd, {BackgroundColor3 = Color3.fromRGB(18, 18, 24), BackgroundTransparency = 0.5}, 0.15) end end)
    btn.MouseLeave:Connect(function() if not st then cd.BackgroundTransparency = 1 end end)
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
        createFloatingButton("TP_TO_GUN", "🔫 TP TO GUN", Color3.fromRGB(255, 200, 0), teleportToGun, UDim2.new(0, 125, 0, 90))
    end
end)
mkBtn(sheriffC, 5, "📌 FLOATING: SHOOT", Color3.fromRGB(100, 20, 30), function()
    if floatingButtons["SHOOT_MURDERER"] then
        removeFloatingButton("SHOOT_MURDERER")
    else
        createFloatingButton("SHOOT_MURDERER", "🔫 SHOOT MURDERER", A_COL.base, shootMurderer, UDim2.new(0, 125, 0, 150))
    end
end)

togC(sheriffC, 6, "Auto Shoot Murderer", function(s) autoShooting = s end)
togC(sheriffC, 7, "Auto Get Gun On Drop", function(s) autoGetDroppedGun = s end)
togC(sheriffC, 8, "Instakill Murderer", function(s) instakillshoot = s end)

mkBtn(sheriffC, 9, "📋 SEND NAMES TO CHAT", Color3.fromRGB(50, 100, 200), sendNamesToChat)
mkBtn(sheriffC, 10, "📋 COPY SHERIFF NAME", Color3.fromRGB(80, 80, 80), copySheriffName)
mkBtn(sheriffC, 11, "📋 COPY MURDERER NAME", Color3.fromRGB(80, 80, 80), copyMurdererName)

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
togC(murdererC, 7, "Murderer Kill Aura", function(s) toggleKillAura(s) end)
togC(murdererC, 8, "Spawn Knife Near Player", function(s) spawnAtPlayer = s end)
togC(murdererC, 9, "Ignore Knife Throws", function(s) ignoreknifethrow = s end)

mkBtn(murdererC, 10, "⚡ GOD MODE (UNSTABLE)", Color3.fromRGB(150, 0, 150), godMode)

-- ═══════════════════════════════════════════════════════════════════════════════
--  TAB CONTENT - ESP
-- ═══════════════════════════════════════════════════════════════════════════════
local espC = tabContents["ESP"]
secT(espC, 1, "👁️ ESP TOGGLES")

togC(espC, 2, "Players ESP", function(s)
    playerESP = s
    if s then
        if not findMurderer() or not findSheriff() then
            notify("XDarkHUB", "Waiting for roles...")
            repeat task.wait(1) until findSheriff() or findMurderer()
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
--  TAB CONTENT - PLAYER
-- ═══════════════════════════════════════════════════════════════════════════════
local playerC = tabContents["Player"]
secT(playerC, 1, "🎯 TELEPORTS")

mkBtn(playerC, 2, "🏠 TELEPORT TO LOBBY", Color3.fromRGB(50, 100, 200), teleportToLobby)
mkBtn(playerC, 3, "🗺️ TELEPORT TO MAP", Color3.fromRGB(50, 150, 50), teleportToMap)

secT(playerC, 4, "⚙️ SETTINGS")

-- Shoot offset input
do
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(1, 0, 0, 52)
    cd.BackgroundTransparency = 1
    cd.LayoutOrder = 5
    cd.ZIndex = 2
    cd.Parent = playerC
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1, 0, 0, 1)
    ln.Position = UDim2.new(0, 0, 1, 0)
    ln.BackgroundColor3 = C_COL.bdr
    ln.BackgroundTransparency = 0.65
    ln.BorderSizePixel = 0
    ln.ZIndex = 2
    ln.Parent = cd
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Shoot Offset"
    lbl.TextColor3 = C_COL.txt
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 2
    lbl.Parent = cd
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.4, 0, 1, 0)
    input.Position = UDim2.new(0.55, 0, 0, 0)
    input.BackgroundColor3 = C_COL.card
    input.Text = tostring(shootOffset)
    input.TextColor3 = C_COL.wht
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
            notify("XDarkHUB", "Offset set to " .. val)
        end
    end)
end

-- Offset to ping multiplier
do
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(1, 0, 0, 52)
    cd.BackgroundTransparency = 1
    cd.LayoutOrder = 6
    cd.ZIndex = 2
    cd.Parent = playerC
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1, 0, 0, 1)
    ln.Position = UDim2.new(0, 0, 1, 0)
    ln.BackgroundColor3 = C_COL.bdr
    ln.BackgroundTransparency = 0.65
    ln.BorderSizePixel = 0
    ln.ZIndex = 2
    ln.Parent = cd
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Ping Multiplier"
    lbl.TextColor3 = C_COL.txt
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 2
    lbl.Parent = cd
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.4, 0, 1, 0)
    input.Position = UDim2.new(0.55, 0, 0, 0)
    input.BackgroundColor3 = C_COL.card
    input.Text = tostring(offsetToPingMult)
    input.TextColor3 = C_COL.wht
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
            notify("XDarkHUB", "Ping mult set to " .. val)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  TAB CONTENT - FARM
-- ═══════════════════════════════════════════════════════════════════════════════
local fC = tabContents["Farm"]
secT(fC, 1, "📊 STATS")
local counterV = statR(fC, 2, "Coins")
local timerV = statR(fC, 3, "Time")
local rateV = statR(fC, 4, "Rate")
local pCoinV = statR(fC, 5, "Total")
secT(fC, 6, "ROLE")
local roleV = statR(fC, 7, "Status")
secT(fC, 8, "BAG")
local bagVal = statR(fC, 9, "State")

mkBtn(fC, 10, "🔪 FLING MURDERER", A_COL.base, function()
    local murderer = findMurderer()
    if not murderer then
        notify("XDarkHUB", "No murderer to fling.")
        return
    end
    miniFling(murderer)
end)

mkBtn(fC, 11, "⭐ FLING SHERIFF", Color3.fromRGB(50, 150, 255), function()
    local sheriff = findSheriff()
    if not sheriff then
        notify("XDarkHUB", "No sheriff to fling.")
        return
    end
    miniFling(sheriff)
end)

togC(fC, 12, "Auto Farm", function(s) isActive = s end)
togC(fC, 13, "Anti-AFK", function(s) antiAFK = s end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  UI UPDATE FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════
local function checkRole()
    isMurderer = (findMurderer() == localplayer)
    isSheriff = (findSheriff() == localplayer)
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
    local cc = getCollectedCoins()
    if farmStopped then
        bagVal.Text = "Stopped"
        bagVal.TextColor3 = Color3.fromRGB(255, 80, 80)
    elseif cc >= MAX_BAG then
        bagVal.Text = "Full"
        bagVal.TextColor3 = Color3.fromRGB(255, 200, 0)
    else
        bagVal.Text = cc .. "/" .. MAX_BAG
        bagVal.TextColor3 = A_COL.lit
    end
end

function stopFarming()
    farmStopped = true
    updateBagUI()
    notify("XDarkHUB", "Stopped")
end

-- Farm loop
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
    bagFull = false
    farmStopped = false
    counterV.Text = "0"
    timerV.Text = "0s"
    rateV.Text = "0"
    updateRoleUI()
    updateBagUI()
    notify("XDarkHUB", "Farm ON")
    
    task.spawn(function()
        while isActive do
            local e = tick() - startTime
            timerV.Text = math.floor(e) .. "s"
            local cc = getCollectedCoins()
            rateV.Text = tostring(e > 0 and math.floor(cc / e * 3600) or 0)
            pCoinV.Text = tostring(getPlayerCoins(player))
            task.wait(0.1)
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
                        if p.Character and o:IsDescendantOf(p.Character) then ic = true; break end
                    end
                    if not ic and o.Parent and o:IsDescendantOf(workspace) and not visitedPositions[o] then
                        local d = (o.Position - rootPart.Position).Magnitude
                        if d < sh and d < 300 then cl = o; sh = d end
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
                            if p.Character and cr:IsDescendantOf(p.Character) then ic = true; break end
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

-- Menu button
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
stk(mBtn, A_COL.neo, 1.5, 0.4)

task.spawn(function()
    while mBtn.Parent do
        ani(mBtn, {Size = UDim2.new(0, 75, 0, 75)}, 1.5, Enum.EasingStyle.Sine)
        task.wait(1.5)
        ani(mBtn, {Size = UDim2.new(0, 70, 0, 70)}, 1.5, Enum.EasingStyle.Sine)
        task.wait(1.5)
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

updateRoleUI()
updateBagUI()
switchTab("Sheriff")
notify("XDarkHUB", "v34 Loaded - Full MM2 Module!")
notify("XDarkHUB", "All YARHM functions included!")
