-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                    XDarkHUB v35 · FULL MM2 MODULE + VISUALS                  ║
-- ║   ESP ПО РОЛЯМ + ПЛАВАЮЩИЕ КНОПКИ + ВКЛАДКА ВИЗУАЛЬНЫХ ЭФФЕКТОВ             ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Debris = game:GetService("Debris")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local localplayer = player
local character = player.Character
local rootPart = character and character:FindFirstChild("HumanoidRootPart")

task.spawn(function()
    if character and not rootPart then
        rootPart = character:WaitForChild("HumanoidRootPart", 10)
    end
end)

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
local farmRunning = false
local espEnabled = false
local trapESPEnabled = false
local gunESPEnabled = false
local MAX_BAG = 40

-- ═══════════════════════════════════════════════════════════════════════════════
--  MM2 ПЕРЕМЕННЫЕ
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
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  GUI / ROLE HELPERS
-- ═══════════════════════════════════════════════════════════════════════════════
local gui = nil
local refreshESP
local onRolesChanged

local function normalizeRoleName(value)
    if type(value) == "number" then
        if value == 1 then return "Sheriff" end
        if value == 2 then return "Murderer" end
        if value == 0 then return "Innocent" end
        return nil
    end

    if type(value) ~= "string" then return nil end

    local v = value:lower()
    if v:find("murder") or v:find("killer") then return "Murderer" end
    if v:find("sheriff") or v:find("hero") or v:find("cop") then return "Sheriff" end
    if v:find("innocent") or v:find("civilian") or v:find("none") then return "Innocent" end

    return nil
end

local function readRoleFromTable(tbl)
    if type(tbl) ~= "table" then return nil end

    return normalizeRoleName(
        tbl.Role or tbl.role or
        tbl.RoleName or tbl.rolename or
        tbl.Status or tbl.status or
        tbl.Team or tbl.team or
        tbl.PlayerRole or tbl.playerRole
    )
end

local function getPlayerRole(pl)
    if not pl then return "Innocent" end

    local directKeys = {pl, pl.Name, pl.UserId, pl.DisplayName}
    for _, key in ipairs(directKeys) do
        local data = playerData[key]
        if data ~= nil then
            if type(data) == "string" or type(data) == "number" then
                local role = normalizeRoleName(data)
                if role then return role end
            elseif type(data) == "table" then
                local role = readRoleFromTable(data)
                if role then return role end
            end
        end
    end

    for key, data in pairs(playerData) do
        local target = nil

        if typeof(key) == "Instance" and key:IsA("Player") then
            target = key
        elseif type(key) == "string" then
            target = Players:FindFirstChild(key)
            if not target and tostring(pl.UserId) == key then
                target = pl
            end
        end

        if type(data) == "table" then
            local p = data.Player or data.player or data.PlayerName or data.playerName or data.Name or data.name
            if typeof(p) == "Instance" and p:IsA("Player") then
                target = p
            elseif type(p) == "string" then
                target = Players:FindFirstChild(p)
            end
        end

        if target == pl then
            if type(data) == "string" or type(data) == "number" then
                local role = normalizeRoleName(data)
                if role then return role end
            elseif type(data) == "table" then
                local role = readRoleFromTable(data)
                if role then return role end
            end
        end
    end

    local function hasTool(name)
        if pl.Backpack and pl.Backpack:FindFirstChild(name) then return true end
        if pl.Character and pl.Character:FindFirstChild(name) then return true end
        return false
    end

    if hasTool("Knife") then return "Murderer" end
    if hasTool("Gun") or hasTool("Revolver") or hasTool("Pistol") then return "Sheriff" end

    local roleValue = pl:FindFirstChild("Role") or pl:FindFirstChild("PlayerRole") or pl:FindFirstChild("Team")
    if roleValue and roleValue:IsA("ValueBase") then
        local role = normalizeRoleName(roleValue.Value)
        if role then return role end
    end

    local ls = pl:FindFirstChild("leaderstats")
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            if v:IsA("ValueBase") and (v.Name:lower():find("role") or v.Name:lower():find("team")) then
                local role = normalizeRoleName(v.Value)
                if role then return role end
            end
        end
    end

    return "Innocent"
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  MM2 ФУНКЦИИ
-- ═══════════════════════════════════════════════════════════════════════════════
local function findMurderer()
    for _, pl in ipairs(Players:GetPlayers()) do
        if getPlayerRole(pl) == "Murderer" then
            return pl
        end
    end
    return nil
end

local function findSheriff()
    for _, pl in ipairs(Players:GetPlayers()) do
        if getPlayerRole(pl) == "Sheriff" then
            return pl
        end
    end
    return nil
end

local function findSheriffThatsNotMe()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= localplayer and getPlayerRole(pl) == "Sheriff" then
            return pl
        end
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
            local localRootPart = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
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
    local char = targetPlayer and targetPlayer.Character
    if not char then return Vector3.new(0, 0, 0) end

    local playerHRP = char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    local playerHum = char:FindFirstChild("Humanoid")
    if not playerHRP or not playerHum then return Vector3.new(0, 0, 0) end

    local velocity = playerHRP.AssemblyLinearVelocity
    local playerMoveDirection = playerHum.MoveDirection

    local predictedPosition = playerHRP.Position + ((velocity * Vector3.new(0.75, 0.5, 0.75))) * (shootOffset / 15) + playerMoveDirection * shootOffset
    predictedPosition = predictedPosition * (((localplayer:GetNetworkPing() * 1000) * ((offsetToPingMult - 1) * 0.01)) + 1)

    return predictedPosition
end

local function getClosestModelToPlayer(pl, models)
    if not pl or not pl.Character or not pl.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end

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
--  MINI FLING
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
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= playerToFling.Character or playerToFling.Parent ~= Players or playerToFling.Character ~= TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end

        local oldFallenPartsDestroyHeight = workspace.FallenPartsDestroyHeight
        workspace.FallenPartsDestroyHeight = -1e6

        local BV = Instance.new("BodyVelocity")
        BV.Name = "EpixVel"
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

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
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

            for _, x in ipairs(Character:GetChildren()) do
                if x:IsA("BasePart") then
                    x.Velocity = Vector3.new()
                    x.RotVelocity = Vector3.new()
                end
            end

            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25

        workspace.FallenPartsDestroyHeight = oldFallenPartsDestroyHeight
    else
        notify("XDarkHUB", "No valid character.")
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ESP ФУНКЦИИ
-- ═══════════════════════════════════════════════════════════════════════════════
local espObjects = {}
local trapHighlights = {}
local gunHighlight = nil
local espWatcherRunning = false
local highlightParent = player:FindFirstChild("PlayerGui")

local function clearPlayerHighlight(pl)
    if espObjects[pl] then
        pcall(function()
            espObjects[pl]:Destroy()
        end)
        espObjects[pl] = nil
    end
end

refreshESP = function()
    if not highlightParent then
        highlightParent = player:FindFirstChild("PlayerGui")
    end

    if not playerESP then
        for _, h in pairs(espObjects) do
            pcall(function()
                h:Destroy()
            end)
        end
        espObjects = {}
        return
    end

    if not highlightParent then return end

    local alive = {}

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= localplayer or not hideMeEsp then
            local char = pl.Character

            if char and char.Parent then
                alive[pl] = true

                local h = espObjects[pl]
                if not h or not h.Parent then
                    h = Instance.new("Highlight")
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 0
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = highlightParent
                    espObjects[pl] = h
                end

                h.Adornee = char

                local role = getPlayerRole(pl)
                local color

                if role == "Murderer" then
                    color = Color3.fromRGB(255, 0, 4)
                elseif role == "Sheriff" then
                    color = Color3.fromRGB(0, 153, 255)
                else
                    color = Color3.fromRGB(0, 255, 8)
                end

                h.FillColor = color
                h.OutlineColor = color
            else
                clearPlayerHighlight(pl)
            end
        else
            clearPlayerHighlight(pl)
        end
    end

    for pl in pairs(espObjects) do
        if not alive[pl] then
            clearPlayerHighlight(pl)
        end
    end
end

local function reloadESP()
    refreshESP()
end

local function ensureEspWatcher()
    if espWatcherRunning then return end

    espWatcherRunning = true

    task.spawn(function()
        while playerESP do
            pcall(refreshESP)
            task.wait(0.8)
        end

        espWatcherRunning = false
    end)
end

onRolesChanged = function()
    task.spawn(function()
        if playerESP then
            pcall(refreshESP)
        end

        if updateRoleUI then
            pcall(updateRoleUI)
        end
    end)
end

local function reloadTrapESP()
    for _, h in pairs(trapHighlights) do
        pcall(function()
            h:Destroy()
        end)
    end
    trapHighlights = {}

    if not highlightParent then
        highlightParent = player:FindFirstChild("PlayerGui")
    end

    if not trapDetection or not highlightParent then return end

    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "Trap" and v.Parent and (v.Parent:IsA("Folder") or v.Parent:IsA("Model")) then
            local h = Instance.new("Highlight")
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.OutlineColor = Color3.fromRGB(255, 0, 0)
            h.FillTransparency = 0.5
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Adornee = v
            h.Parent = highlightParent
            trapHighlights[v] = h

            if v:IsA("BasePart") then
                v.Transparency = 0
            end
        end
    end
end

local function reloadGunESP()
    if gunHighlight then
        pcall(function()
            gunHighlight:Destroy()
        end)
        gunHighlight = nil
    end

    if not highlightParent then
        highlightParent = player:FindFirstChild("PlayerGui")
    end

    if not gunDropESP or not highlightParent then return end

    local map = getMap()
    if map and map:FindFirstChild("GunDrop") then
        local gun = map:FindFirstChild("GunDrop")

        gunHighlight = Instance.new("Highlight")
        gunHighlight.FillColor = Color3.fromRGB(255, 255, 0)
        gunHighlight.OutlineColor = Color3.fromRGB(255, 255, 0)
        gunHighlight.FillTransparency = 0.5
        gunHighlight.OutlineTransparency = 0
        gunHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        gunHighlight.Adornee = gun
        gunHighlight.Parent = highlightParent
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  MM2 ДЕЙСТВИЯ
-- ═══════════════════════════════════════════════════════════════════════════════
function shootMurderer()
    if findSheriff() ~= localplayer then
        notify("XDarkHUB", "You're not sheriff/hero.")
        return
    end

    local murderer = findMurderer() or findSheriffThatsNotMe()
    if not murderer or not murderer.Character then
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
    local rightHand = localplayer.Character:FindFirstChild("RightHand")
    local origin = rightHand and rightHand.Position or localplayer.Character:GetPivot().Position

    local args
    if instakillshoot then
        args = {
            CFrame.new(murdererHRP.Position + Vector3.new(0, 1, 0)),
            CFrame.new(murdererHRP.Position)
        }
    else
        args = {
            CFrame.new(origin),
            CFrame.new(predictedPosition)
        }
    end

    pcall(function()
        localplayer.Character:WaitForChild("Gun"):WaitForChild("Shoot"):FireServer(unpack(args))
    end)

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

    local rightHand = localplayer.Character:FindFirstChild("RightHand")
    local origin = rightHand and rightHand.Position or localplayer.Character:GetPivot().Position

    local argsThrowRemote = {
        CFrame.new(origin),
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

function killClosest()
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
    local myHRP = localplayer.Character:FindFirstChild("HumanoidRootPart")
    if not nearestHRP or not myHRP then return end

    nearestHRP.Anchored = true
    nearestHRP.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 2

    task.wait(0.1)

    pcall(function()
        localplayer.Character:WaitForChild("Knife"):WaitForChild("Stab"):FireServer("Slash")
    end)

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
            hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
        else
            notify("XDarkHUB", "You don't have the knife.")
            return
        end
    end

    local myHRP = localplayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.Anchored = true
            p.Character.HumanoidRootPart.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 1
        end
    end

    pcall(function()
        localplayer.Character:WaitForChild("Knife"):WaitForChild("Stab"):FireServer("Slash")
    end)

    notify("XDarkHUB", "Killed everyone!")
end

function holdHostage()
    if findMurderer() ~= localplayer then
        notify("XDarkHUB", "You're not murderer.")
        return
    end

    local myHRP = localplayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.Anchored = true
            p.Character.HumanoidRootPart.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 5
        end
    end

    notify("XDarkHUB", "All players held hostage!")
end

function godMode()
    local Cam = workspace.CurrentCamera
    local Pos, Char = Cam.CFrame, localplayer.Character
    local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")

    if not Human then
        notify("XDarkHUB", "No humanoid.")
        return
    end

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
    if lobby and lobby:FindFirstChild("Spawns") then
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
        if #spawns > 0 then
            local randomSpawn = spawns[math.random(1, #spawns)]
            localplayer.Character:MoveTo(randomSpawn.Position)
            notify("XDarkHUB", "Teleported to map!")
        end
    end
end

function sendNamesToChat()
    local murd = findMurderer()
    local sher = findSheriff()

    local murdName = murd and murd.Name or "-"
    local sherName = sher and sher.Name or "-"

    local message = string.format("Murderer: %s | Sheriff: %s | <<XDarkHUB>>", murdName, sherName)

    pcall(function()
        local textchannels = TextChatService:WaitForChild("TextChannels"):GetChildren()
        for _, textchannel in ipairs(textchannels) do
            if textchannel.Name ~= "RBXSystem" then
                pcall(function()
                    textchannel:SendAsync(message)
                end)
            end
        end
    end)

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
--  AUTO SHOOT LOOP
-- ═══════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(1) do
        if findSheriff() == localplayer and autoShooting then
            repeat
                task.wait(0.1)

                local murderer = findMurderer()
                if not murderer or not murderer.Character then continue end

                local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
                local characterRootPart = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
                if not murdererHRP or not characterRootPart then continue end

                local murdererPosition = murdererHRP.Position
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

                    local predictedPosition = getPredictedPosition(murderer)
                    local rightHand = localplayer.Character:FindFirstChild("RightHand")
                    local origin = rightHand and rightHand.Position or localplayer.Character:GetPivot().Position

                    local args = {
                        CFrame.new(origin),
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
            pcall(function()
                knifeThrow()
            end)
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

            local myHRP = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    if (hrp.Position - myHRP.Position).Magnitude < 7 then
                        hrp.Anchored = true
                        hrp.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 2

                        task.wait(0.1)

                        pcall(function()
                            localplayer.Character:WaitForChild("Knife"):WaitForChild("Stab"):FireServer("Slash")
                        end)

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
--  AUTO GET GUN ON DROP / TRAP WATCHER
-- ═══════════════════════════════════════════════════════════════════════════════
workspace.DescendantAdded:Connect(function(ch)
    if trapDetection and ch.Name == "Trap" and ch.Parent and (ch.Parent:IsA("Folder") or ch.Parent:IsA("Model")) then
        if ch:IsA("BasePart") then
            ch.Transparency = 0
        end

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

    if trapDetection and ch.Name == "Trap" then
        reloadTrapESP()
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
--  VISUAL EFFECTS SYSTEM (НОВОЕ В v35)
-- ═══════════════════════════════════════════════════════════════════════════════
local visualState = {
    wings = false,
    circle = false,
    halo = false,
    aura = false,
    fire = false,
    smoke = false,
    trails = false,
    eyes = false,
    light = false,
}

local visualObjects = {}
local wingFeathers = {}
local circleOrbs = {}
local eyeParts = {}
local haloDisc = nil
local circleOuter = nil
local circleInner = nil

local function registerVisual(name, obj)
    visualObjects[name] = visualObjects[name] or {}
    table.insert(visualObjects[name], obj)
end

local function clearVisual(name)
    if visualObjects[name] then
        for _, obj in ipairs(visualObjects[name]) do
            pcall(function()
                obj:Destroy()
            end)
        end
        visualObjects[name] = nil
    end

    if name == "wings" then wingFeathers = {} end
    if name == "circle" then
        circleOrbs = {}
        circleOuter = nil
        circleInner = nil
    end
    if name == "halo" then haloDisc = nil end
    if name == "eyes" then eyeParts = {} end
end

local function clearAllVisuals()
    local names = {}
    for name in pairs(visualObjects) do
        table.insert(names, name)
    end

    for _, name in ipairs(names) do
        clearVisual(name)
    end

    wingFeathers = {}
    circleOrbs = {}
    eyeParts = {}
    haloDisc = nil
    circleOuter = nil
    circleInner = nil
end

local function makeNeonPart(props)
    local p = Instance.new("Part")
    p.Material = Enum.Material.Neon
    p.Anchored = true
    p.CanCollide = false
    p.CastShadow = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth

    for k, v in pairs(props) do
        p[k] = v
    end

    return p
end

local function applyWings()
    clearVisual("wings")

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for side = -1, 1, 2 do
        for i = 1, 6 do
            local feather = makeNeonPart({
                Name = "XDarkFeather",
                Size = Vector3.new(0.12, 3.4 - i * 0.38, 1.2 - i * 0.1),
                Color = Color3.fromRGB(255, math.max(10, 55 - i * 7), math.max(20, 70 - i * 8)),
                Transparency = 0.05 + i * 0.04,
                Parent = char,
            })

            registerVisual("wings", feather)
            table.insert(wingFeathers, {part = feather, side = side, i = i})
        end
    end

    local wingLight = Instance.new("PointLight")
    wingLight.Color = Color3.fromRGB(255, 30, 50)
    wingLight.Brightness = 1.2
    wingLight.Range = 12
    wingLight.Parent = hrp
    registerVisual("wings", wingLight)
end

local function applyCircle()
    clearVisual("circle")

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    circleOuter = makeNeonPart({
        Name = "XDarkCircleOuter",
        Shape = Enum.PartType.Cylinder,
        Size = Vector3.new(0.18, 9, 9),
        Color = Color3.fromRGB(255, 25, 45),
        Transparency = 0.45,
        Parent = char,
    })
    registerVisual("circle", circleOuter)

    circleInner = makeNeonPart({
        Name = "XDarkCircleInner",
        Shape = Enum.PartType.Cylinder,
        Size = Vector3.new(0.2, 5, 5),
        Color = Color3.fromRGB(255, 80, 100),
        Transparency = 0.3,
        Parent = char,
    })
    registerVisual("circle", circleInner)

    for k = 1, 8 do
        local orb = makeNeonPart({
            Name = "XDarkCircleOrb",
            Shape = Enum.PartType.Ball,
            Size = Vector3.new(0.35, 0.35, 0.35),
            Color = Color3.fromRGB(255, 60, 80),
            Transparency = 0.1,
            Parent = char,
        })

        registerVisual("circle", orb)
        table.insert(circleOrbs, {part = orb, k = k})
    end

    local att = Instance.new("Attachment", hrp)
    att.Position = Vector3.new(0, -3, 0)
    registerVisual("circle", att)

    local em = Instance.new("ParticleEmitter", att)
    em.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    em.Color = ColorSequence.new(Color3.fromRGB(255, 40, 60), Color3.fromRGB(140, 0, 25))
    em.Rate = 45
    em.Lifetime = NumberRange.new(0.8, 1.4)
    em.Speed = NumberRange.new(2, 4)
    em.SpreadAngle = Vector2.new(180, 180)
    em.LightEmission = 1
    em.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(1, 0)
    })
    em.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.25),
        NumberSequenceKeypoint.new(1, 1)
    })
    registerVisual("circle", em)

    local cl = Instance.new("PointLight")
    cl.Color = Color3.fromRGB(255, 30, 55)
    cl.Brightness = 1.5
    cl.Range = 16
    cl.Parent = hrp
    registerVisual("circle", cl)
end

local function applyHalo()
    clearVisual("halo")

    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end

    haloDisc = makeNeonPart({
        Name = "XDarkHalo",
        Shape = Enum.PartType.Cylinder,
        Size = Vector3.new(0.12, 2.4, 2.4),
        Color = Color3.fromRGB(255, 45, 65),
        Transparency = 0.2,
        Parent = char,
    })
    registerVisual("halo", haloDisc)

    local hl = Instance.new("PointLight")
    hl.Color = Color3.fromRGB(255, 40, 60)
    hl.Brightness = 0.8
    hl.Range = 8
    hl.Parent = head
    registerVisual("halo", hl)
end

local function applyEmitter(name, texture, c1, c2, rate, speed, spread, sizeStart, attPos, emissionDir)
    clearVisual(name)

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local att = Instance.new("Attachment", hrp)
    att.Position = attPos or Vector3.new(0, 0, 0)
    registerVisual(name, att)

    local em = Instance.new("ParticleEmitter", att)
    em.Texture = texture
    em.Color = ColorSequence.new(c1, c2)
    em.Rate = rate
    em.Lifetime = NumberRange.new(0.6, 1.2)
    em.Speed = NumberRange.new(speed * 0.6, speed)
    em.SpreadAngle = Vector2.new(spread, spread)
    em.LightEmission = 1

    if emissionDir then
        em.EmissionDirection = emissionDir
    end

    em.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, sizeStart),
        NumberSequenceKeypoint.new(1, 0)
    })
    em.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    })
    registerVisual(name, em)
end

local function applyTrails()
    clearVisual("trails")

    local char = player.Character
    if not char then return end

    local handNames = {"LeftHand", "RightHand", "Left Arm", "Right Arm"}

    for _, hn in ipairs(handNames) do
        local hand = char:FindFirstChild(hn)
        if hand then
            local a0 = Instance.new("Attachment", hand)
            a0.Position = Vector3.new(0, 0.35, 0)

            local a1 = Instance.new("Attachment", hand)
            a1.Position = Vector3.new(0, -0.35, 0)

            local trail = Instance.new("Trail", hand)
            trail.Attachment0 = a0
            trail.Attachment1 = a1
            trail.Color = ColorSequence.new(Color3.fromRGB(255, 35, 55), Color3.fromRGB(110, 0, 20))
            trail.Lifetime = 0.45
            trail.LightEmission = 1
            trail.LightInfluence = 0
            trail.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.15),
                NumberSequenceKeypoint.new(1, 1)
            })

            registerVisual("trails", a0)
            registerVisual("trails", a1)
            registerVisual("trails", trail)
        end
    end
end

local function applyEyes()
    clearVisual("eyes")

    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end

    for side = -1, 1, 2 do
        local eye = makeNeonPart({
            Name = "XDarkEye",
            Size = Vector3.new(0.12, 0.14, 0.14),
            Color = Color3.fromRGB(255, 20, 40),
            Transparency = 0,
            Parent = char,
        })

        registerVisual("eyes", eye)
        table.insert(eyeParts, {part = eye, side = side})
    end

    local el = Instance.new("PointLight")
    el.Color = Color3.fromRGB(255, 25, 45)
    el.Brightness = 0.7
    el.Range = 6
    el.Parent = head
    registerVisual("eyes", el)
end

local function applyLight()
    clearVisual("light")

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local l = Instance.new("PointLight")
    l.Color = Color3.fromRGB(255, 30, 50)
    l.Brightness = 2
    l.Range = 18
    l.Parent = hrp
    registerVisual("light", l)
end

local function applyVisual(name)
    if name == "wings" then
        applyWings()
    elseif name == "circle" then
        applyCircle()
    elseif name == "halo" then
        applyHalo()
    elseif name == "aura" then
        applyEmitter("aura", "rbxasset://textures/particles/sparkles_main.dds",
            Color3.fromRGB(255, 45, 65), Color3.fromRGB(130, 0, 25),
            55, 4, 180, 0.45, Vector3.new(0, -0.5, 0), nil)
    elseif name == "fire" then
        applyEmitter("fire", "rbxasset://textures/particles/fire_main.dds",
            Color3.fromRGB(255, 70, 40), Color3.fromRGB(140, 0, 0),
            45, 5, 22, 1.1, Vector3.new(0, -2.6, 0), Enum.NormalId.Top)
    elseif name == "smoke" then
        applyEmitter("smoke", "rbxasset://textures/particles/smoke_main.dds",
            Color3.fromRGB(90, 5, 15), Color3.fromRGB(30, 0, 5),
            30, 2.5, 30, 1.5, Vector3.new(0, -2.2, 0), Enum.NormalId.Top)
    elseif name == "trails" then
        applyTrails()
    elseif name == "eyes" then
        applyEyes()
    elseif name == "light" then
        applyLight()
    end
end

local function reapplyVisuals()
    clearAllVisuals()

    for name, on in pairs(visualState) do
        if on then
            pcall(function()
                applyVisual(name)
            end)
        end
    end
end

-- Анимация крыльев, круга, нимба и глаз
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local t = tick()

    if visualState.wings and hrp and #wingFeathers > 0 then
        local flap = math.sin(t * 3.2) * 12

        for _, f in ipairs(wingFeathers) do
            if f.part.Parent then
                local i, side = f.i, f.side
                local yaw = side * (15 + i * 10 + flap)
                local tilt = side * (5 + i * 4)

                f.part.CFrame = hrp.CFrame
                    * CFrame.new(side * (0.5 + i * 0.22), 1.2 - i * 0.14, 0.9)
                    * CFrame.Angles(0, math.rad(yaw), math.rad(tilt))
            end
        end
    end

    if visualState.circle and hrp then
        local basePos = hrp.CFrame * CFrame.new(0, -3.1, 0)

        if circleOuter and circleOuter.Parent then
            circleOuter.CFrame = basePos * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(t * 1.2, 0, 0)
        end

        if circleInner and circleInner.Parent then
            circleInner.CFrame = basePos * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(-t * 2, 0, 0)
        end

        for _, o in ipairs(circleOrbs) do
            if o.part.Parent then
                local ang = t * 1.6 + (o.k / 8) * math.pi * 2
                local orbPos = hrp.Position + Vector3.new(
                    math.cos(ang) * 4.6,
                    -3.1 + math.sin(t * 3 + o.k) * 0.25,
                    math.sin(ang) * 4.6
                )
                o.part.CFrame = CFrame.new(orbPos)
            end
        end
    end

    if visualState.halo and haloDisc and haloDisc.Parent then
        local head = char:FindFirstChild("Head")
        if head then
            local bob = math.sin(t * 2.2) * 0.12
            haloDisc.CFrame = head.CFrame
                * CFrame.new(0, 1.8 + bob, 0)
                * CFrame.Angles(0, 0, math.rad(90))
                * CFrame.Angles(t * 2.5, 0, 0)
        end
    end

    if visualState.eyes and #eyeParts > 0 then
        local head = char:FindFirstChild("Head")
        if head then
            for _, e in ipairs(eyeParts) do
                if e.part.Parent then
                    e.part.CFrame = head.CFrame * CFrame.new(e.side * 0.35, 0.12, -0.52)
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  ROLE DATA LISTENER / REMOTE HOOKS
-- ═══════════════════════════════════════════════════════════════════════════════
local function applyRolePayload(payload, sourceName)
    local changed = false

    local function setRole(pl, raw)
        local role = normalizeRoleName(raw)
        if pl and role then
            playerData[pl] = role
            playerData[pl.Name] = role
            playerData[pl.UserId] = role
            changed = true
        end
    end

    if type(payload) == "table" then
        local explicit = readRoleFromTable(payload)
        if explicit then
            setRole(localplayer, explicit)
        end

        for k, v in pairs(payload) do
            local target = nil

            if typeof(k) == "Instance" and k:IsA("Player") then
                target = k
            elseif type(k) == "string" then
                target = Players:FindFirstChild(k)
            end

            if target then
                if type(v) == "table" then
                    setRole(target, readRoleFromTable(v))
                else
                    setRole(target, v)
                end
            elseif type(v) == "table" then
                local p = v.Player or v.player or v.PlayerName or v.playerName or v.Name or v.name

                if typeof(p) == "Instance" and p:IsA("Player") then
                    target = p
                elseif type(p) == "string" then
                    target = Players:FindFirstChild(p)
                end

                if target then
                    setRole(target, readRoleFromTable(v))
                end
            end
        end
    elseif type(payload) == "string" or type(payload) == "number" then
        local rn = tostring(sourceName or ""):lower()
        if rn:find("role") or rn:find("playerdata") or rn:find("gamedata") or rn:find("game") then
            setRole(localplayer, payload)
        end
    end

    if changed and onRolesChanged then
        onRolesChanged()
    end
end

pcall(function()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local gameplay = remotes:FindFirstChild("Gameplay")
        if gameplay then
            local pd = gameplay:FindFirstChild("PlayerDataChanged")
            if pd and pd:IsA("RemoteEvent") then
                pd.OnClientEvent:Connect(function(...)
                    for _, arg in ipairs({...}) do
                        applyRolePayload(arg, "PlayerDataChanged")
                    end
                end)
            end
        end
    end
end)

pcall(function()
    local connected = {}

    local function hookRemote(inst)
        if connected[inst] then return end

        if inst:IsA("RemoteEvent") then
            connected[inst] = true

            pcall(function()
                inst.OnClientEvent:Connect(function(...)
                    for _, arg in ipairs({...}) do
                        applyRolePayload(arg, inst.Name)
                    end
                end)
            end)
        end
    end

    for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
        hookRemote(inst)
    end

    ReplicatedStorage.DescendantAdded:Connect(hookRemote)
end)

local hookedPlayers = {}

local function hookPlayerRoleEvents(pl)
    if hookedPlayers[pl] then return end
    hookedPlayers[pl] = true

    pcall(function()
        pl.CharacterAdded:Connect(function(char)
            task.wait(0.1)

            if onRolesChanged then
                onRolesChanged()
            end

            pcall(function()
                char.ChildAdded:Connect(function()
                    task.wait(0.05)
                    if onRolesChanged then onRolesChanged() end
                end)

                char.ChildRemoved:Connect(function()
                    task.wait(0.05)
                    if onRolesChanged then onRolesChanged() end
                end)
            end)
        end)
    end)

    pcall(function()
        if pl.Backpack then
            pl.Backpack.ChildAdded:Connect(function()
                if onRolesChanged then onRolesChanged() end
            end)

            pl.Backpack.ChildRemoved:Connect(function()
                if onRolesChanged then onRolesChanged() end
            end)
        end
    end)

    if pl.Character and onRolesChanged then
        task.spawn(function()
            onRolesChanged()
        end)
    end
end

for _, pl in ipairs(Players:GetPlayers()) do
    hookPlayerRoleEvents(pl)
end

Players.PlayerAdded:Connect(hookPlayerRoleEvents)

Players.PlayerRemoving:Connect(function(pl)
    hookedPlayers[pl] = nil
    playerData[pl] = nil
    playerData[pl.Name] = nil
    playerData[pl.UserId] = nil

    if clearPlayerHighlight then
        clearPlayerHighlight(pl)
    end
end)

player.CharacterAdded:Connect(function()
    playerData = {}
    task.wait(0.25)

    if onRolesChanged then
        onRolesChanged()
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  FLOATING BUTTONS SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════
local floatingButtons = {}

local function createFloatingButton(name, text, color, callback, position)
    if not gui then
        notify("XDarkHUB", "GUI ещё не готов")
        return
    end

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
    button.Visible = true
    button.ZIndex = 100
    button.Parent = gui

    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", button)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2

    button.MouseButton1Click:Connect(function()
        clickSnd:Play()
        callback()
    end)

    button.MouseButton1Down:Connect(function(x, y)
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 145, 0, 48)}):Play()

        local ripple = Instance.new("Frame")
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 1
        ripple.Position = UDim2.fromOffset(x - button.AbsolutePosition.X, y - button.AbsolutePosition.Y)
        ripple.Size = UDim2.fromOffset(50, 50)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.ZIndex = 101
        ripple.Parent = button

        local rippleCorner = Instance.new("UICorner", ripple)
        rippleCorner.CornerRadius = UDim.new(1, 0)

        TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.6,
            Size = UDim2.fromOffset(150, 150)
        }):Play()

        task.spawn(function()
            task.wait(0.5)
            if ripple and ripple.Parent then
                ripple:Destroy()
            end
        end)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 150, 0, 50)}):Play()
        end
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

    button.Size = UDim2.new(0, 0, 0, 0)

    TweenService:Create(button, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 150, 0, 50)
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

do
    local old = player:WaitForChild("PlayerGui"):FindFirstChild("AutoFarmGui")
    if old then old:Destroy() end
end

local function getGuiParent()
    if gethui and type(gethui) == "function" then
        local ok, res = pcall(gethui)
        if ok and res then
            return res
        end
    end

    if get_hidden_gui and type(get_hidden_gui) == "function" then
        local ok, res = pcall(get_hidden_gui)
        if ok and res then
            return res
        end
    end

    return player:WaitForChild("PlayerGui")
end

local guiUI = Instance.new("ScreenGui")
guiUI.Name = "AutoFarmGui"
guiUI.ResetOnSpawn = false
guiUI.IgnoreGuiInset = true
guiUI.DisplayOrder = 999999
guiUI.Parent = getGuiParent()

gui = guiUI

collectSound.Parent = guiUI
killSound.Parent = guiUI
deathSound.Parent = guiUI
clickSnd.Parent = guiUI

local bgF = Instance.new("Frame")
bgF.Size = UDim2.new(1, 0, 1, 0)
bgF.BackgroundColor3 = C_COL.bg
bgF.BackgroundTransparency = 0.08
bgF.BorderSizePixel = 0
bgF.ZIndex = 0
bgF.Active = false
bgF.InputTransparent = true
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
    p.Active = false
    p.InputTransparent = true
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

ani(frame, {
    Size = UDim2.new(0, 800, 0, 600),
    Position = UDim2.new(0.5, -400, 0.5, -300)
}, 0.6, Enum.EasingStyle.Back)

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
vLbl.Text = "[v35]"
vLbl.Font = Enum.Font.Code
vLbl.TextSize = 12
vLbl.TextColor3 = C_COL.mut
vLbl.TextXAlignment = Enum.TextXAlignment.Right
vLbl.ZIndex = 3
vLbl.Parent = tBar

do
    local dr, ds, sp = false, nil, nil

    tBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dr = true
            ds = i.Position
            sp = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dr = false
        end
    end)
end

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
createTab("Visuals", "✨", 6)

for n in pairs(tabs) do
    createTabContent(n)
end

for n, t in pairs(tabs) do
    t.btn.MouseButton1Click:Connect(function()
        clickSnd:Play()
        switchTab(n)
    end)
end

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
    cd.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
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
    local control = {}

    local function applyState(newState)
        st = newState

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
    end

    function control:Set(state)
        if st ~= state then
            applyState(state)
        end
    end

    btn.MouseButton1Click:Connect(function()
        clickSnd:Play()
        applyState(not st)
    end)

    btn.MouseEnter:Connect(function()
        if not st then
            ani(cd, {BackgroundColor3 = Color3.fromRGB(18, 18, 24), BackgroundTransparency = 0.5}, 0.15)
        end
    end)

    btn.MouseLeave:Connect(function()
        if not st then
            cd.BackgroundTransparency = 1
        end
    end)

    return control
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

    b.MouseEnter:Connect(function()
        ani(b, {BackgroundColor3 = A_COL.neo}, 0.15)
    end)

    b.MouseLeave:Connect(function()
        ani(b, {BackgroundColor3 = color or A_COL.base}, 0.15)
    end)

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

togC(sheriffC, 6, "Auto Shoot Murderer", function(s)
    autoShooting = s
end)

togC(sheriffC, 7, "Auto Get Gun On Drop", function(s)
    autoGetDroppedGun = s
end)

togC(sheriffC, 8, "Instakill Murderer", function(s)
    instakillshoot = s
end)

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

togC(murdererC, 6, "Auto Knife Throw", function(s)
    loopThrow = s
end)

togC(murdererC, 7, "Murderer Kill Aura", function(s)
    toggleKillAura(s)
end)

togC(murdererC, 8, "Spawn Knife Near Player", function(s)
    spawnAtPlayer = s
end)

togC(murdererC, 9, "Ignore Knife Throws", function(s)
    ignoreknifethrow = s
end)

mkBtn(murdererC, 10, "⚡ GOD MODE (UNSTABLE)", Color3.fromRGB(150, 0, 150), godMode)

-- ═══════════════════════════════════════════════════════════════════════════════
--  TAB CONTENT - ESP
-- ═══════════════════════════════════════════════════════════════════════════════
local espC = tabContents["ESP"]
secT(espC, 1, "👁️ ESP TOGGLES")

togC(espC, 2, "Players ESP", function(s)
    playerESP = s

    if s then
        ensureEspWatcher()
        notify("XDarkHUB", "ESP ON")
    end

    refreshESP()
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
    refreshESP()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  TAB CONTENT - PLAYER
-- ═══════════════════════════════════════════════════════════════════════════════
local playerC = tabContents["Player"]
secT(playerC, 1, "🎯 TELEPORTS")

mkBtn(playerC, 2, "🏠 TELEPORT TO LOBBY", Color3.fromRGB(50, 100, 200), teleportToLobby)
mkBtn(playerC, 3, "🗺️ TELEPORT TO MAP", Color3.fromRGB(50, 150, 50), teleportToMap)

secT(playerC, 4, "⚙️ SETTINGS")

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

togC(fC, 12, "Auto Farm", function(s)
    isActive = s

    if s then
        startFarming()
    else
        farmStopped = true
    end
end)

togC(fC, 13, "Anti-AFK", function(s)
    antiAFK = s
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  TAB CONTENT - VISUALS (НОВОЕ В v35)
-- ═══════════════════════════════════════════════════════════════════════════════
local visC = tabContents["Visuals"]
secT(visC, 1, "✨ VISUAL EFFECTS")

local visualToggles = {}

visualToggles.wings = togC(visC, 2, "Crimson Wings (Красные Крылья)", function(s)
    visualState.wings = s
    if s then applyVisual("wings") else clearVisual("wings") end
end)

visualToggles.circle = togC(visC, 3, "Magic Circle (Круг Под Ногами)", function(s)
    visualState.circle = s
    if s then applyVisual("circle") else clearVisual("circle") end
end)

visualToggles.halo = togC(visC, 4, "Halo (Нимб Сверху)", function(s)
    visualState.halo = s
    if s then applyVisual("halo") else clearVisual("halo") end
end)

visualToggles.aura = togC(visC, 5, "Red Aura Particles (Красная Аура)", function(s)
    visualState.aura = s
    if s then applyVisual("aura") else clearVisual("aura") end
end)

visualToggles.fire = togC(visC, 6, "Fire Aura (Огненная Аура)", function(s)
    visualState.fire = s
    if s then applyVisual("fire") else clearVisual("fire") end
end)

visualToggles.smoke = togC(visC, 7, "Dark Smoke (Тёмный Дым)", function(s)
    visualState.smoke = s
    if s then applyVisual("smoke") else clearVisual("smoke") end
end)

visualToggles.trails = togC(visC, 8, "Neon Trails (Трейлы На Руках)", function(s)
    visualState.trails = s
    if s then applyVisual("trails") else clearVisual("trails") end
end)

visualToggles.eyes = togC(visC, 9, "Glowing Eyes (Светящиеся Глаза)", function(s)
    visualState.eyes = s
    if s then applyVisual("eyes") else clearVisual("eyes") end
end)

visualToggles.light = togC(visC, 10, "Red Light (Красная Подсветка)", function(s)
    visualState.light = s
    if s then applyVisual("light") else clearVisual("light") end
end)

mkBtn(visC, 11, "🔥 FULL SET - ВСЕ ЭФФЕКТЫ", A_COL.base, function()
    for _, t in pairs(visualToggles) do
        t:Set(true)
    end
    notify("XDarkHUB", "Full visual set ON!")
end)

mkBtn(visC, 12, "🧹 CLEAR ALL EFFECTS", Color3.fromRGB(80, 80, 80), function()
    for _, t in pairs(visualToggles) do
        t:Set(false)
    end
    notify("XDarkHUB", "All visuals cleared!")
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  UI UPDATE FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════
local function checkRole()
    local r = getPlayerRole(player)
    isMurderer = (r == "Murderer")
    isSheriff = (r == "Sheriff")
end

local function getPlayerCoins(p)
    local ls = p:FindFirstChild("leaderstats")

    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local n = v.Name:lower()
                if n:find("coin") or n:find("money") or n:find("cash") or n:find("gold") then
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
    isActive = false
    updateBagUI()
    notify("XDarkHUB", "Stopped")
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

    if not c then
        task.cancel(to)
    end

    return not c
end

function startFarming()
    if farmRunning then return end

    farmRunning = true
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
            local cc = getCollectedCoins()

            timerV.Text = math.floor(e) .. "s"
            counterV.Text = tostring(cc)
            rateV.Text = tostring(e > 0 and math.floor(cc / e * 3600) or 0)
            pCoinV.Text = tostring(getPlayerCoins(player))

            updateRoleUI()
            updateBagUI()

            task.wait(0.25)
        end
    end)

    task.spawn(function()
        while isActive do
            if farmStopped then
                task.wait(1)
                continue
            end

            character = player.Character
            if not character then
                task.wait(0.5)
                continue
            end

            rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                task.wait(0.5)
                continue
            end

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
                if next(visitedPositions) then
                    visitedPositions = {}
                end

                task.wait(1)
            end

            task.wait(0.1)
        end

        farmRunning = false
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  MENU BUTTON
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
--  FINAL CONNECTIONS
-- ═══════════════════════════════════════════════════════════════════════════════
player.CharacterAdded:Connect(function(ch)
    character = ch
    rootPart = ch:WaitForChild("HumanoidRootPart")
    visitedPositions = {}
    farmStopped = false

    task.wait(1.5)

    checkRole()
    updateRoleUI()
    reapplyVisuals()
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
switchTab("Sheriff")

notify("XDarkHUB", "v35 Loaded - Visuals Update!")
notify("XDarkHUB", "Новая вкладка Visuals с эффектами!")
