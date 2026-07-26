local function safeParentGui(obj)
    local attempts = {}

    if gethui and type(gethui) == "function" then
        table.insert(attempts, function() return gethui() end)
    end

    if get_hidden_gui and type(get_hidden_gui) == "function" then
        table.insert(attempts, function() return get_hidden_gui() end)
    end

    table.insert(attempts, function()
        local pl = game:GetService("Players").LocalPlayer
        return pl and pl:FindFirstChild("PlayerGui")
    end)

    table.insert(attempts, function()
        return game:GetService("CoreGui")
    end)

    for _, fn in ipairs(attempts) do
        local ok, res = pcall(fn)
        if ok and res then
            local ok2 = pcall(function()
                obj.Parent = res
            end)

            if ok2 and obj.Parent == res then
                return res
            end
        end
    end

    return nil
end

local statusGui, statusLabel

local function xdStatus(text, color)
    pcall(function()
        if not statusGui or not statusGui.Parent then
            statusGui = Instance.new("ScreenGui")
            statusGui.Name = "XDarkStatus"
            statusGui.ResetOnSpawn = false

            pcall(function()
                statusGui.IgnoreGuiInset = true
            end)

            pcall(function()
                statusGui.DisplayOrder = 999999999
            end)

            if not safeParentGui(statusGui) then
                return
            end

            statusLabel = Instance.new("TextLabel")
            statusLabel.Size = UDim2.new(0, 560, 0, 80)
            statusLabel.Position = UDim2.new(0.5, -280, 0, 8)
            statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            statusLabel.BackgroundTransparency = 0.35
            statusLabel.BorderSizePixel = 0
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            statusLabel.Font = Enum.Font.GothamBold
            statusLabel.TextScaled = true
            statusLabel.TextWrapped = true
            statusLabel.ZIndex = 999999
            statusLabel.Text = ""
            statusLabel.Parent = statusGui

            pcall(function()
                local c = Instance.new("UICorner", statusLabel)
                c.CornerRadius = UDim.new(0, 10)
            end)
        end

        if statusLabel then
            statusLabel.Visible = true
            statusLabel.Text = text
            statusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        end
    end)
end

local function xdError(err)
    pcall(function()
        warn("[XDarkHUB ERROR] " .. tostring(err))
    end)

    xdStatus("XDarkHUB ERROR: " .. tostring(err), Color3.fromRGB(255, 70, 70))
end

local xdWait = (task and task.wait) or wait
local xdDelay = function(t, f)
    if task and task.delay then
        task.delay(t, f)
    else
        delay(t, f)
    end
end
local xdSpawn = function(f)
    if task and task.spawn then
        task.spawn(f)
    else
        spawn(f)
    end
end

xdStatus("XDarkHUB: загрузка...", Color3.fromRGB(255, 255, 255))

xpcall(function()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualUser = game:GetService("VirtualUser")
    local StarterGui = game:GetService("StarterGui")
    local TextChatService = game:GetService("TextChatService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local player = Players.LocalPlayer
    while not player do
        xdWait(0.1)
        player = Players.LocalPlayer
    end

    local localplayer = player
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    xdSpawn(function()
        if character and not rootPart then
            rootPart = character:WaitForChild("HumanoidRootPart", 10)
        end
    end)

    local visitedPositions = {}
    local isActive = false
    local flySpeed = 16
    local initialCoins = 0
    local startTime = 0
    local antiAFK = false
    local isMurderer = false
    local isSheriff = false
    local farmStopped = false
    local farmRunning = false
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

    local xdG = (getgenv and getgenv()) or _G

    local function notify(title, text, duration)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = duration or 3
            })
        end)
    end

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

        for _, key in ipairs({pl, pl.Name, pl.UserId}) do
            local data = playerData[key]
            if data ~= nil then
                if type(data) == "table" then
                    local role = readRoleFromTable(data)
                    if role then return role end
                else
                    local role = normalizeRoleName(data)
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
                if type(data) == "table" then
                    local role = readRoleFromTable(data)
                    if role then return role end
                else
                    local role = normalizeRoleName(data)
                    if role then return role end
                end
            end
        end

        if pl.Backpack and pl.Backpack:FindFirstChild("Knife") then return "Murderer" end
        if pl.Character and pl.Character:FindFirstChild("Knife") then return "Murderer" end

        if pl.Backpack and (pl.Backpack:FindFirstChild("Gun") or pl.Backpack:FindFirstChild("Revolver")) then
            return "Sheriff"
        end

        if pl.Character and (pl.Character:FindFirstChild("Gun") or pl.Character:FindFirstChild("Revolver")) then
            return "Sheriff"
        end

        return "Innocent"
    end

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

        local ping = 0
        pcall(function()
            ping = localplayer:GetNetworkPing() * 1000
        end)

        predictedPosition = predictedPosition * ((ping * ((offsetToPingMult - 1) * 0.01)) + 1)

        return predictedPosition
    end

    function miniFling(playerToFling)
        local Character = player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Humanoid and Humanoid.RootPart

        local TCharacter = playerToFling and playerToFling.Character
        if not TCharacter then
            notify("XDarkHUB", "No target character.")
            return
        end

        local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
        local TRootPart = THumanoid and THumanoid.RootPart
        local THead = TCharacter:FindFirstChild("Head")
        local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
        local Handle = Accessory and Accessory:FindFirstChild("Handle")

        if not (Character and Humanoid and RootPart) then
            notify("XDarkHUB", "No valid character.")
            return
        end

        pcall(function()
            Character.PrimaryPart = RootPart
        end)

        if RootPart.Velocity.Magnitude < 50 then
            xdG.OldPos = RootPart.CFrame
        end

        local function setCam(subject)
            pcall(function()
                workspace.CurrentCamera.CameraSubject = subject
            end)
        end

        if THead then
            setCam(THead)
        elseif Handle then
            setCam(Handle)
        elseif THumanoid then
            setCam(THumanoid)
        end

        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            notify("XDarkHUB", "Can't find a proper part to fling.")
            return
        end

        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            pcall(function()
                Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            end)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0

            repeat
                if RootPart and THumanoid then
                    local trVel = (TRootPart and TRootPart.Velocity.Magnitude) or BasePart.Velocity.Magnitude

                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100

                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        xdWait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        xdWait()

                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        xdWait()

                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        xdWait()

                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        xdWait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        xdWait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        xdWait()

                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        xdWait()

                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        xdWait()

                        FPos(BasePart, CFrame.new(0, 1.5, trVel / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        xdWait()

                        FPos(BasePart, CFrame.new(0, -1.5, -trVel / 1.25), CFrame.Angles(0, 0, 0))
                        xdWait()

                        FPos(BasePart, CFrame.new(0, 1.5, trVel / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        xdWait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        xdWait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        xdWait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                        xdWait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        xdWait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= playerToFling.Character or playerToFling.Parent ~= Players or playerToFling.Character ~= TCharacter or (THumanoid and THumanoid.Sit) or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end

        local oldFPDH
        pcall(function()
            oldFPDH = workspace.FallenPartsDestroyHeight
            workspace.FallenPartsDestroyHeight = -1e6
        end)

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
        elseif TRootPart then
            SFBasePart(TRootPart)
        elseif THead then
            SFBasePart(THead)
        elseif Handle then
            SFBasePart(Handle)
        else
            notify("XDarkHUB", "Can't find a proper part to fling.")
        end

        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        setCam(Humanoid)

        local oldPos = xdG.OldPos or RootPart.CFrame
        local returnTime = tick() + 3

        repeat
            RootPart.CFrame = oldPos * CFrame.new(0, 0.5, 0)
            pcall(function()
                Character:SetPrimaryPartCFrame(oldPos * CFrame.new(0, 0.5, 0))
            end)

            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

            for _, x in ipairs(Character:GetChildren()) do
                if x:IsA("BasePart") then
                    x.Velocity = Vector3.new()
                    x.RotVelocity = Vector3.new()
                end
            end

            xdWait()
        until (RootPart.Position - oldPos.p).Magnitude < 25 or Humanoid.Health <= 0 or tick() > returnTime

        pcall(function()
            workspace.FallenPartsDestroyHeight = oldFPDH or -500
        end)
    end

    local espObjects = {}
    local trapHighlights = {}
    local gunHighlight = nil
    local espWatcherRunning = false
    local highlightParent = player:FindFirstChild("PlayerGui")
    local highlightSupported = true
    local refreshESP
    local onRolesChanged

    local function newHighlight(props)
        if not highlightSupported then return nil end

        local ok, h = pcall(function()
            local obj = Instance.new("Highlight")

            for k, v in pairs(props) do
                if k ~= "Parent" then
                    obj[k] = v
                end
            end

            return obj
        end)

        if ok and h then
            return h
        end

        highlightSupported = false
        return nil
    end

    local function clearPlayerHighlight(pl)
        if espObjects[pl] then
            pcall(function()
                espObjects[pl]:Destroy()
            end)
            espObjects[pl] = nil
        end
    end

    refreshESP = function()
        if not playerESP then
            for _, h in pairs(espObjects) do
                pcall(function()
                    h:Destroy()
                end)
            end
            espObjects = {}
            return
        end

        if not highlightSupported then return end

        if not highlightParent then
            highlightParent = player:FindFirstChild("PlayerGui")
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
                        h = newHighlight({
                            FillTransparency = 0.5,
                            OutlineTransparency = 0,
                            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        })

                        if not h then return end

                        pcall(function()
                            h.Parent = highlightParent
                        end)

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

    local function ensureEspWatcher()
        if espWatcherRunning then return end

        espWatcherRunning = true

        xdSpawn(function()
            while playerESP do
                pcall(refreshESP)
                xdWait(0.8)
            end

            espWatcherRunning = false
        end)
    end

    onRolesChanged = function()
        xdSpawn(function()
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

        if not trapDetection or not highlightSupported then return end

        if not highlightParent then
            highlightParent = player:FindFirstChild("PlayerGui")
        end

        if not highlightParent then return end

        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "Trap" and v.Parent and (v.Parent:IsA("Folder") or v.Parent:IsA("Model")) then
                local h = newHighlight({
                    FillColor = Color3.fromRGB(255, 0, 0),
                    OutlineColor = Color3.fromRGB(255, 0, 0),
                    FillTransparency = 0.5,
                    OutlineTransparency = 0,
                    DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
                    Adornee = v
                })

                if h then
                    pcall(function()
                        h.Parent = highlightParent
                    end)
                    trapHighlights[v] = h
                end

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

        if not gunDropESP or not highlightSupported then return end

        if not highlightParent then
            highlightParent = player:FindFirstChild("PlayerGui")
        end

        if not highlightParent then return end

        local map = getMap()
        if map and map:FindFirstChild("GunDrop") then
            local gun = map:FindFirstChild("GunDrop")

            gunHighlight = newHighlight({
                FillColor = Color3.fromRGB(255, 255, 0),
                OutlineColor = Color3.fromRGB(255, 255, 0),
                FillTransparency = 0.5,
                OutlineTransparency = 0,
                DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
                Adornee = gun
            })

            if gunHighlight then
                pcall(function()
                    gunHighlight.Parent = highlightParent
                end)
            end
        end
    end

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

        xdWait(0.1)

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
            xdWait()
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
            local channels = TextChatService:FindFirstChild("TextChannels")
            if channels then
                for _, textchannel in ipairs(channels:GetChildren()) do
                    if textchannel.Name ~= "RBXSystem" then
                        pcall(function()
                            textchannel:SendAsync(message)
                        end)
                    end
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

    xdSpawn(function()
        while xdWait(0.5) do
            if autoShooting and findSheriff() == localplayer then
                pcall(function()
                    local murderer = findMurderer()
                    if murderer and murderer.Character and localplayer.Character then
                        if not localplayer.Character:FindFirstChild("Gun") then
                            local hum = localplayer.Character:FindFirstChild("Humanoid")
                            local bp = localplayer.Backpack and localplayer.Backpack:FindFirstChild("Gun")
                            if hum and bp then
                                hum:EquipTool(bp)
                            end
                        end

                        local gun = localplayer.Character:FindFirstChild("Gun")
                        local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")

                        if gun and murdererHRP then
                            local predictedPosition = getPredictedPosition(murderer)
                            local rightHand = localplayer.Character:FindFirstChild("RightHand")
                            local origin = rightHand and rightHand.Position or localplayer.Character:GetPivot().Position

                            gun:WaitForChild("Shoot"):FireServer(
                                CFrame.new(origin),
                                CFrame.new(predictedPosition)
                            )
                        end
                    end
                end)
            end
        end
    end)

    xdSpawn(function()
        while xdWait(1.5) do
            if loopThrow then
                pcall(function()
                    knifeThrow()
                end)
            end
        end
    end)

    function toggleKillAura(state)
        if state then
            if killAuraCon then killAuraCon:Disconnect() end

            killAuraCon = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if findMurderer() ~= localplayer then return end

                    local myHRP = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
                    if not myHRP then return end

                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local hrp = p.Character.HumanoidRootPart
                            if (hrp.Position - myHRP.Position).Magnitude < 7 then
                                hrp.Anchored = true
                                hrp.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 2

                                xdWait(0.1)

                                pcall(function()
                                    localplayer.Character:WaitForChild("Knife"):WaitForChild("Stab"):FireServer("Slash")
                                end)

                                return
                            end
                        end
                    end
                end)
            end)
        else
            if killAuraCon then killAuraCon:Disconnect() end
            killAuraCon = nil
        end
    end

    workspace.DescendantAdded:Connect(function(ch)
        pcall(function()
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
                    xdWait(1)

                    local map = getMap()
                    if not map or not map:FindFirstChild("GunDrop") then return end

                    local previousPosition = localplayer.Character:GetPivot()
                    localplayer.Character:MoveTo(map:FindFirstChild("GunDrop").Position)
                    localplayer.Backpack.ChildAdded:Wait()
                    localplayer.Character:PivotTo(previousPosition)
                end
            end
        end)
    end)

    workspace.DescendantRemoving:Connect(function(ch)
        pcall(function()
            if gunDropESP and ch.Name == "GunDrop" then
                reloadGunESP()
            end

            if trapDetection and ch.Name == "Trap" then
                reloadTrapESP()
            end
        end)
    end)

    workspace.ChildAdded:Connect(function(chi)
        if chi.Name == "ThrowingKnife" and ignoreknifethrow then
            chi:Destroy()
        end
    end)

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

    pcall(function()
        local hookedPlayers = {}

        local function hookPlayerRoleEvents(pl)
            if hookedPlayers[pl] then return end
            hookedPlayers[pl] = true

            pcall(function()
                pl.CharacterAdded:Connect(function(char)
                    xdWait(0.1)

                    if onRolesChanged then
                        onRolesChanged()
                    end

                    pcall(function()
                        char.ChildAdded:Connect(function()
                            xdWait(0.05)
                            if onRolesChanged then onRolesChanged() end
                        end)

                        char.ChildRemoved:Connect(function()
                            xdWait(0.05)
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
    end)

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

    local function applyVisualSafe(name)
        pcall(function()
            applyVisual(name)
        end)
    end

    local function reapplyVisuals()
        clearAllVisuals()

        for name, on in pairs(visualState) do
            if on then
                applyVisualSafe(name)
            end
        end
    end

    RunService.Heartbeat:Connect(function()
        pcall(function()
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
    end)

    local viewport = Vector2.new(1000, 700)
    pcall(function()
        viewport = workspace.CurrentCamera.ViewportSize
    end)

    local function clamp(n, min, max)
        return math.min(max, math.max(min, n))
    end

    local guiW = clamp(viewport.X * 0.92, 320, 780)
    local guiH = clamp(viewport.Y * 0.82, 280, 540)

    pcall(function()
        local pg = player:FindFirstChild("PlayerGui")
        if pg then
            local old = pg:FindFirstChild("AutoFarmGui")
            if old then old:Destroy() end
        end
    end)

    local guiUI = Instance.new("ScreenGui")
    guiUI.Name = "AutoFarmGui"
    guiUI.ResetOnSpawn = false
    guiUI.Enabled = true

    pcall(function()
        guiUI.IgnoreGuiInset = true
    end)

    pcall(function()
        guiUI.DisplayOrder = 999999
    end)

    if not safeParentGui(guiUI) then
        error("GUI parent not found: gethui / PlayerGui / CoreGui unavailable")
    end

    local clickSnd = Instance.new("Sound")
    clickSnd.SoundId = "rbxassetid://169759176"
    clickSnd.Volume = 0.25
    clickSnd.Parent = guiUI

    local collectSound = Instance.new("Sound")
    collectSound.SoundId = "rbxassetid://12221967"
    collectSound.Volume = 1
    collectSound.Parent = guiUI

    local function playClick()
        pcall(function()
            clickSnd:Play()
        end)
    end

    local function corner(o, r)
        pcall(function()
            local c = Instance.new("UICorner", o)
            c.CornerRadius = UDim.new(0, r or 8)
        end)
    end

    local function makeDraggable(handle, obj)
        local dragging = false
        local dragStart = nil
        local startPos = nil
        local moved = false

        handle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = i.Position
                startPos = obj.Position
                moved = false
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - dragStart

                if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then
                    moved = true
                end

                obj.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + d.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + d.Y
                )
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        return function()
            return moved
        end
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, guiW, 0, guiH)
    frame.Position = UDim2.new(0.5, -guiW / 2, 0.5, -guiH / 2)
    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    frame.BorderSizePixel = 0
    frame.Visible = true
    frame.Active = true
    frame.ClipsDescendants = true
    frame.Parent = guiUI
    corner(frame, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 38)
    title.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    title.BorderSizePixel = 0
    title.Text = "XDarkHUB v36"
    title.TextColor3 = Color3.fromRGB(255, 80, 100)
    title.Font = Enum.Font.GothamBlack
    title.TextScaled = true
    title.Active = true
    title.Parent = frame
    corner(title, 10)

    makeDraggable(title, frame)

    local left = Instance.new("Frame")
    left.Size = UDim2.new(0, 150, 1, -42)
    left.Position = UDim2.new(0, 0, 0, 42)
    left.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    left.BorderSizePixel = 0
    left.Parent = frame

    local leftLayout = Instance.new("UIListLayout", left)
    leftLayout.Padding = UDim.new(0, 6)
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local leftPad = Instance.new("UIPadding", left)
    leftPad.PaddingTop = UDim.new(0, 8)
    leftPad.PaddingLeft = UDim.new(0, 8)
    leftPad.PaddingRight = UDim.new(0, 8)

    local right = Instance.new("Frame")
    right.Size = UDim2.new(1, -156, 1, -48)
    right.Position = UDim2.new(0, 154, 0, 44)
    right.BackgroundTransparency = 1
    right.Parent = frame

    local tabs = {}
    local contents = {}

    local function switchTab(name)
        for n, b in pairs(tabs) do
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            b.TextColor3 = Color3.fromRGB(210, 210, 220)
        end

        for n, c in pairs(contents) do
            c.Visible = false
        end

        if tabs[name] then
            tabs[name].BackgroundColor3 = Color3.fromRGB(200, 35, 60)
            tabs[name].TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        if contents[name] then
            contents[name].Visible = true
        end
    end

    local function addTab(name, order)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 38)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        b.TextColor3 = Color3.fromRGB(210, 210, 220)
        b.Text = name
        b.Font = Enum.Font.GothamBold
        b.TextScaled = true
        b.BorderSizePixel = 0
        b.LayoutOrder = order
        b.Parent = left
        corner(b, 8)

        local c = Instance.new("ScrollingFrame")
        c.Size = UDim2.new(1, 0, 1, 0)
        c.BackgroundTransparency = 1
        c.BorderSizePixel = 0
        c.ScrollBarThickness = 4
        c.CanvasSize = UDim2.new(0, 0, 0, 0)
        c.Visible = false
        c.Parent = right

        pcall(function()
            c.AutomaticCanvasSize = Enum.AutomaticSize.Y
        end)

        local l = Instance.new("UIListLayout", c)
        l.Padding = UDim.new(0, 8)
        l.SortOrder = Enum.SortOrder.LayoutOrder

        local p = Instance.new("UIPadding", c)
        p.PaddingTop = UDim.new(0, 4)
        p.PaddingBottom = UDim.new(0, 24)
        p.PaddingLeft = UDim.new(0, 4)
        p.PaddingRight = UDim.new(0, 4)

        tabs[name] = b
        contents[name] = c

        b.MouseButton1Click:Connect(function()
            playClick()
            switchTab(name)
        end)
    end

    addTab("Sheriff", 1)
    addTab("Murderer", 2)
    addTab("ESP", 3)
    addTab("Player", 4)
    addTab("Farm", 5)
    addTab("Visuals", 6)

    local function makeButton(parent, order, text, color, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 42)
        b.BackgroundColor3 = color or Color3.fromRGB(200, 35, 60)
        b.Text = text
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamBold
        b.TextScaled = true
        b.BorderSizePixel = 0
        b.LayoutOrder = order
        b.Parent = parent
        corner(b, 8)

        b.MouseButton1Click:Connect(function()
            playClick()
            pcall(callback)
        end)

        return b
    end

    local function makeToggle(parent, order, text, callback)
        local state = false

        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 42)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        b.Text = text .. ": OFF"
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamBold
        b.TextScaled = true
        b.BorderSizePixel = 0
        b.LayoutOrder = order
        b.Parent = parent
        corner(b, 8)

        local function update(v)
            state = v
            b.Text = text .. (state and ": ON" or ": OFF")
            b.BackgroundColor3 = state and Color3.fromRGB(140, 25, 45) or Color3.fromRGB(30, 30, 40)

            pcall(function()
                callback(state)
            end)
        end

        b.MouseButton1Click:Connect(function()
            playClick()
            update(not state)
        end)

        return {
            Set = function(_, v)
                if state ~= v then
                    update(v)
                end
            end
        }
    end

    local function makeInput(parent, order, label, default, callback)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 42)
        f.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        f.BorderSizePixel = 0
        f.LayoutOrder = order
        f.Parent = parent
        corner(f, 8)

        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.55, -8, 1, 0)
        l.Position = UDim2.new(0, 8, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = label
        l.TextColor3 = Color3.fromRGB(230, 230, 240)
        l.Font = Enum.Font.GothamBold
        l.TextScaled = true
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0.4, -8, 0.7, 0)
        box.Position = UDim2.new(0.58, 0, 0.15, 0)
        box.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        box.BorderSizePixel = 0
        box.Text = tostring(default)
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.Font = Enum.Font.GothamBold
        box.TextScaled = true
        box.Parent = f
        corner(box, 6)

        box.FocusLost:Connect(function()
            local v = tonumber(box.Text)
            if v then
                pcall(function()
                    callback(v)
                end)
            else
                box.Text = tostring(default)
            end
        end)

        return box
    end

    local function makeStat(parent, order, label)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 36)
        f.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        f.BorderSizePixel = 0
        f.LayoutOrder = order
        f.Parent = parent
        corner(f, 8)

        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.6, -8, 1, 0)
        l.Position = UDim2.new(0, 8, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = label
        l.TextColor3 = Color3.fromRGB(190, 190, 200)
        l.Font = Enum.Font.GothamBold
        l.TextScaled = true
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f

        local v = Instance.new("TextLabel")
        v.Size = UDim2.new(0.4, -8, 1, 0)
        v.Position = UDim2.new(0.6, 0, 0, 0)
        v.BackgroundTransparency = 1
        v.Text = "0"
        v.TextColor3 = Color3.fromRGB(255, 90, 115)
        v.Font = Enum.Font.GothamBlack
        v.TextScaled = true
        v.TextXAlignment = Enum.TextXAlignment.Right
        v.Parent = f

        return v
    end

    local floatingButtons = {}

    local function createFloatingButton(name, text, color, callback, position)
        if floatingButtons[name] then
            floatingButtons[name]:Destroy()
            floatingButtons[name] = nil
        end

        local b = Instance.new("TextButton")
        b.Name = name
        b.Size = UDim2.new(0, 150, 0, 45)
        b.Position = position or UDim2.new(0, 120, 0, 80)
        b.BackgroundColor3 = color or Color3.fromRGB(200, 35, 60)
        b.Text = text
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamBold
        b.TextScaled = true
        b.BorderSizePixel = 0
        b.ZIndex = 100
        b.Parent = guiUI
        corner(b, 10)

        local wasMoved = makeDraggable(b, b)

        b.MouseButton1Click:Connect(function()
            if wasMoved() then return end
            playClick()
            pcall(callback)
        end)

        floatingButtons[name] = b
        notify("XDarkHUB", "Button created: " .. text)
    end

    local function removeFloatingButton(name)
        if floatingButtons[name] then
            floatingButtons[name]:Destroy()
            floatingButtons[name] = nil
            notify("XDarkHUB", "Button removed: " .. name)
        end
    end

    local sheriffC = contents["Sheriff"]

    makeButton(sheriffC, 1, "Shoot Murderer", Color3.fromRGB(200, 35, 60), shootMurderer)
    makeButton(sheriffC, 2, "TP To Dropped Gun", Color3.fromRGB(220, 170, 0), teleportToGun)

    makeButton(sheriffC, 3, "Floating: TP Gun", Color3.fromRGB(120, 100, 0), function()
        if floatingButtons["TP_GUN"] then
            removeFloatingButton("TP_GUN")
        else
            createFloatingButton("TP_GUN", "TP Gun", Color3.fromRGB(220, 170, 0), teleportToGun, UDim2.new(0, 120, 0, 80))
        end
    end)

    makeButton(sheriffC, 4, "Floating: Shoot", Color3.fromRGB(120, 20, 35), function()
        if floatingButtons["SHOOT"] then
            removeFloatingButton("SHOOT")
        else
            createFloatingButton("SHOOT", "Shoot", Color3.fromRGB(200, 35, 60), shootMurderer, UDim2.new(0, 120, 0, 135))
        end
    end)

    makeToggle(sheriffC, 5, "Auto Shoot", function(s)
        autoShooting = s
    end)

    makeToggle(sheriffC, 6, "Auto Get Gun On Drop", function(s)
        autoGetDroppedGun = s
    end)

    makeToggle(sheriffC, 7, "Instakill Shoot", function(s)
        instakillshoot = s
    end)

    makeButton(sheriffC, 8, "Send Names To Chat", Color3.fromRGB(50, 100, 200), sendNamesToChat)
    makeButton(sheriffC, 9, "Copy Sheriff Name", Color3.fromRGB(70, 70, 80), copySheriffName)
    makeButton(sheriffC, 10, "Copy Murderer Name", Color3.fromRGB(70, 70, 80), copyMurdererName)

    local murdererC = contents["Murderer"]

    makeButton(murdererC, 1, "Knife Throw Closest", Color3.fromRGB(200, 35, 60), knifeThrow)
    makeButton(murdererC, 2, "Kill Closest", Color3.fromRGB(170, 0, 0), killClosest)
    makeButton(murdererC, 3, "Kill Everyone", Color3.fromRGB(130, 0, 0), killEveryone)
    makeButton(murdererC, 4, "Hold Hostage", Color3.fromRGB(100, 0, 50), holdHostage)

    makeToggle(murdererC, 5, "Auto Knife Throw", function(s)
        loopThrow = s
    end)

    makeToggle(murdererC, 6, "Kill Aura", function(s)
        toggleKillAura(s)
    end)

    makeToggle(murdererC, 7, "Spawn Knife Near Player", function(s)
        spawnAtPlayer = s
    end)

    makeToggle(murdererC, 8, "Ignore Knife Throws", function(s)
        ignoreknifethrow = s
    end)

    makeButton(murdererC, 9, "God Mode (Unstable)", Color3.fromRGB(150, 0, 150), godMode)

    local espC = contents["ESP"]

    makeToggle(espC, 1, "Players ESP", function(s)
        playerESP = s

        if s then
            ensureEspWatcher()
            notify("XDarkHUB", "ESP ON")
        end

        refreshESP()
    end)

    makeToggle(espC, 2, "Dropped Gun ESP", function(s)
        gunDropESP = s
        reloadGunESP()
    end)

    makeToggle(espC, 3, "Traps ESP", function(s)
        trapDetection = s
        reloadTrapESP()
    end)

    makeToggle(espC, 4, "Hide My ESP", function(s)
        hideMeEsp = s
        refreshESP()
    end)

    local playerC = contents["Player"]

    makeButton(playerC, 1, "Teleport To Lobby", Color3.fromRGB(50, 100, 200), teleportToLobby)
    makeButton(playerC, 2, "Teleport To Map", Color3.fromRGB(50, 150, 50), teleportToMap)

    makeInput(playerC, 3, "Shoot Offset", shootOffset, function(v)
        shootOffset = v
        notify("XDarkHUB", "Offset set to " .. v)
    end)

    makeInput(playerC, 4, "Ping Multiplier", offsetToPingMult, function(v)
        offsetToPingMult = v
        notify("XDarkHUB", "Ping mult set to " .. v)
    end)

    local farmC = contents["Farm"]

    local counterV = makeStat(farmC, 1, "Coins")
    local timerV = makeStat(farmC, 2, "Time")
    local rateV = makeStat(farmC, 3, "Rate")
    local pCoinV = makeStat(farmC, 4, "Total")
    local roleV = makeStat(farmC, 5, "Role")
    local bagVal = makeStat(farmC, 6, "Bag")

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
            bagVal.TextColor3 = Color3.fromRGB(255, 90, 115)
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
        local to = xdDelay(dur + 2, function()
            c = true
            tw:Cancel()
        end)

        tw.Completed:Wait()

        if not c then
            pcall(function()
                task.cancel(to)
            end)
        end

        return not c
    end

    function startFarming()
        if farmRunning then return end

        farmRunning = true
        initialCoins = getPlayerCoins(player)
        startTime = tick()
        visitedPositions = {}
        farmStopped = false

        counterV.Text = "0"
        timerV.Text = "0s"
        rateV.Text = "0"

        updateRoleUI()
        updateBagUI()
        notify("XDarkHUB", "Farm ON")

        xdSpawn(function()
            while isActive do
                local e = tick() - startTime
                local cc = getCollectedCoins()

                timerV.Text = math.floor(e) .. "s"
                counterV.Text = tostring(cc)
                rateV.Text = tostring(e > 0 and math.floor(cc / e * 3600) or 0)
                pCoinV.Text = tostring(getPlayerCoins(player))

                updateRoleUI()
                updateBagUI()

                xdWait(0.25)
            end
        end)

        xdSpawn(function()
            while isActive do
                if farmStopped then
                    xdWait(1)
                    continue
                end

                character = player.Character
                if not character then
                    xdWait(0.5)
                    continue
                end

                rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then
                    xdWait(0.5)
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
                        xdWait(0.3)

                        if cr.Parent and cr:IsDescendantOf(workspace) then
                            local ic = false

                            for _, p in ipairs(Players:GetPlayers()) do
                                if p.Character and cr:IsDescendantOf(p.Character) then
                                    ic = true
                                    break
                                end
                            end

                            if not ic and (cr.Position - rootPart.Position).Magnitude < 5 then
                                pcall(function()
                                    collectSound:Play()
                                end)

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

                    xdWait(1)
                end

                xdWait(0.1)
            end

            farmRunning = false
        end)
    end

    makeButton(farmC, 7, "Fling Murderer", Color3.fromRGB(200, 35, 60), function()
        local murderer = findMurderer()
        if not murderer then
            notify("XDarkHUB", "No murderer to fling.")
            return
        end

        miniFling(murderer)
    end)

    makeButton(farmC, 8, "Fling Sheriff", Color3.fromRGB(50, 150, 255), function()
        local sheriff = findSheriff()
        if not sheriff then
            notify("XDarkHUB", "No sheriff to fling.")
            return
        end

        miniFling(sheriff)
    end)

    makeToggle(farmC, 9, "Auto Farm", function(s)
        isActive = s

        if s then
            startFarming()
        else
            farmStopped = true
        end
    end)

    makeToggle(farmC, 10, "Anti-AFK", function(s)
        antiAFK = s
    end)

    local visC = contents["Visuals"]
    local visualToggles = {}

    visualToggles.wings = makeToggle(visC, 1, "Crimson Wings", function(s)
        visualState.wings = s
        if s then applyVisualSafe("wings") else clearVisual("wings") end
    end)

    visualToggles.circle = makeToggle(visC, 2, "Magic Circle", function(s)
        visualState.circle = s
        if s then applyVisualSafe("circle") else clearVisual("circle") end
    end)

    visualToggles.halo = makeToggle(visC, 3, "Halo", function(s)
        visualState.halo = s
        if s then applyVisualSafe("halo") else clearVisual("halo") end
    end)

    visualToggles.aura = makeToggle(visC, 4, "Red Aura", function(s)
        visualState.aura = s
        if s then applyVisualSafe("aura") else clearVisual("aura") end
    end)

    visualToggles.fire = makeToggle(visC, 5, "Fire Aura", function(s)
        visualState.fire = s
        if s then applyVisualSafe("fire") else clearVisual("fire") end
    end)

    visualToggles.smoke = makeToggle(visC, 6, "Dark Smoke", function(s)
        visualState.smoke = s
        if s then applyVisualSafe("smoke") else clearVisual("smoke") end
    end)

    visualToggles.trails = makeToggle(visC, 7, "Neon Trails", function(s)
        visualState.trails = s
        if s then applyVisualSafe("trails") else clearVisual("trails") end
    end)

    visualToggles.eyes = makeToggle(visC, 8, "Glowing Eyes", function(s)
        visualState.eyes = s
        if s then applyVisualSafe("eyes") else clearVisual("eyes") end
    end)

    visualToggles.light = makeToggle(visC, 9, "Red Light", function(s)
        visualState.light = s
        if s then applyVisualSafe("light") else clearVisual("light") end
    end)

    makeButton(visC, 10, "FULL SET - ALL EFFECTS", Color3.fromRGB(200, 35, 60), function()
        for _, t in pairs(visualToggles) do
            t:Set(true)
        end
        notify("XDarkHUB", "Full visual set ON!")
    end)

    makeButton(visC, 11, "CLEAR ALL EFFECTS", Color3.fromRGB(70, 70, 80), function()
        for _, t in pairs(visualToggles) do
            t:Set(false)
        end
        notify("XDarkHUB", "All visuals cleared!")
    end)

    local mBtn = Instance.new("TextButton")
    mBtn.Size = UDim2.new(0, 60, 0, 60)
    mBtn.Position = UDim2.new(0, 16, 1, -76)
    mBtn.BackgroundColor3 = Color3.fromRGB(200, 35, 60)
    mBtn.Text = "X"
    mBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mBtn.Font = Enum.Font.GothamBlack
    mBtn.TextScaled = true
    mBtn.BorderSizePixel = 0
    mBtn.ZIndex = 50
    mBtn.Parent = guiUI
    corner(mBtn, 30)

    mBtn.MouseButton1Click:Connect(function()
        playClick()
        frame.Visible = not frame.Visible
    end)

    player.CharacterAdded:Connect(function(ch)
        character = ch
        rootPart = ch:WaitForChild("HumanoidRootPart")
        visitedPositions = {}
        farmStopped = false

        xdWait(1.25)

        checkRole()

        pcall(function()
            updateRoleUI()
        end)

        reapplyVisuals()
    end)

    player.Idled:Connect(function()
        if antiAFK then
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                xdWait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
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

    pcall(function()
        updateRoleUI()
    end)

    pcall(function()
        updateBagUI()
    end)

    switchTab("Sheriff")

    notify("XDarkHUB", "v36 Loaded!")
    notify("XDarkHUB", "Если меню нет, смотри красную надпись сверху.")

    xdStatus("XDarkHUB v36: меню готово", Color3.fromRGB(80, 255, 120))

    xdDelay(4, function()
        pcall(function()
            if statusLabel then
                statusLabel.Visible = false
            end
        end)
    end)
end, function(err)
    xdError(err)
end)
