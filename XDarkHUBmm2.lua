-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║              XDarkHUB v36 · FULL MM2 · ESPIndicator FROM YARHM              ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Debris = game:GetService("Debris")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local localplayer = Players.LocalPlayer
local player = localplayer
local character = localplayer.Character or localplayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ═══════════════════════════════════════════════════════════════════════════════
--  STATE VARIABLES
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
local MAX_BAG = 40

-- MM2 variables (from YARHM)
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
local killAuraCon = nil
local playerData = {}
local claimedCoins = {}

-- ═══════════════════════════════════════════════════════════════════════════════
--  SOUNDS
-- ═══════════════════════════════════════════════════════════════════════════════
local collectSound = Instance.new("Sound"); collectSound.SoundId = "rbxassetid://12221967"; collectSound.Volume = 1
local killSound = Instance.new("Sound"); killSound.SoundId = "rbxassetid://9120392731"; killSound.Volume = 0.8
local deathSound = Instance.new("Sound"); deathSound.SoundId = "rbxassetid://9120392731"; deathSound.Volume = 0.6
local clickSnd = Instance.new("Sound"); clickSnd.SoundId = "rbxassetid://169759176"; clickSnd.Volume = 0.25

local function notify(title, text, duration)
    pcall(function() StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 3}) end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  MM2 FUNCTIONS (FROM YARHM)
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
        if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then return o end
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
    local pl = targetPlayer
    pcall(function() pl = targetPlayer.Character end)
    local playerHRP = pl:FindFirstChild("UpperTorso") or pl:FindFirstChild("HumanoidRootPart")
    local playerHum = pl:FindFirstChild("Humanoid")
    if not playerHRP or not playerHum then return Vector3.new(0,0,0) end
    local velocity = playerHRP.AssemblyLinearVelocity
    local playerMoveDirection = playerHum.MoveDirection
    local predictedPosition = playerHRP.Position + ((velocity * Vector3.new(0.75, 0.5, 0.75))) * (shootOffset / 15) + playerMoveDirection * shootOffset
    predictedPosition = predictedPosition * (((localplayer:GetNetworkPing() * 1000) * ((offsetToPingMult - 1) * 0.01)) + 1)
    return predictedPosition
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

local function getCollectedCoins() return getPlayerCoins(localplayer) - initialCoins end

local function checkRole()
    local r = getPlayerRole(localplayer)
    isMurderer = (r == "Murderer")
    isSheriff = (r == "Sheriff")
end

function getPlayerRole(p)
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

-- ═══════════════════════════════════════════════════════════════════════════════
--  🔥 ESP INDICATOR MODULE (FROM YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
local ESPContainer = {}
ESPContainer.Indicators = {}
ESPContainer.Groups = {}
ESPContainer.ScreenGui = nil

function ESPContainer:Init()
    if self.ScreenGui then return end
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "XDarkHUB_ESP"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.DisplayOrder = 998
    pcall(function()
        local coregui = game:GetService("CoreGui")
        self.ScreenGui.Parent = coregui
    end)
    if not self.ScreenGui.Parent then
        self.ScreenGui.Parent = localplayer:WaitForChild("PlayerGui")
    end
end

function ESPContainer:Add(target, options)
    if not target then return end
    self:Init()
    
    -- Remove old if exists
    if self.Indicators[target] then
        self:Remove(target)
    end
    
    local color = options.AccentColor or Color3.new(1, 1, 1)
    local groupName = options.GroupName or "default"
    local showLabel = options.ShowLabel or false
    local labelText = options.LabelText or ""
    local arrowShow = options.ArrowShow or false
    
    -- Create Highlight
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = target
    highlight.Parent = self.ScreenGui
    
    -- Create BillboardGui for label
    local billboard = nil
    local label = nil
    if showLabel then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPLabel_" .. tostring(target)
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 120, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = target
        billboard.Parent = self.ScreenGui
        
        label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = color
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        label.Parent = billboard
        
        local labelStroke = Instance.new("UIStroke")
        labelStroke.Color = Color3.new(0, 0, 0)
        labelStroke.Thickness = 2
        labelStroke.Parent = label
    end
    
    -- Create Arrow (BillboardGui with arrow image)
    local arrowGui = nil
    if arrowShow then
        arrowGui = Instance.new("BillboardGui")
        arrowGui.Name = "ESPArrow_" .. tostring(target)
        arrowGui.AlwaysOnTop = true
        arrowGui.Size = UDim2.new(0, 40, 0, 40)
        arrowGui.StudsOffset = Vector3.new(0, 5, 0)
        arrowGui.Adornee = target
        arrowGui.Parent = self.ScreenGui
        
        local arrowLabel = Instance.new("TextLabel")
        arrowLabel.Size = UDim2.new(1, 0, 1, 0)
        arrowLabel.BackgroundTransparency = 1
        arrowLabel.Text = "▼"
        arrowLabel.TextColor3 = color
        arrowLabel.Font = Enum.Font.GothamBlack
        arrowLabel.TextScaled = true
        arrowLabel.Parent = arrowGui
    end
    
    -- Store indicator
    self.Indicators[target] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
        Arrow = arrowGui,
        Group = groupName
    }
    
    -- Add to group
    if not self.Groups[groupName] then
        self.Groups[groupName] = {}
    end
    table.insert(self.Groups[groupName], target)
end

function ESPContainer:Remove(target)
    local indicator = self.Indicators[target]
    if not indicator then return end
    
    if indicator.Highlight then indicator.Highlight:Destroy() end
    if indicator.Billboard then indicator.Billboard:Destroy() end
    if indicator.Arrow then indicator.Arrow:Destroy() end
    
    -- Remove from group
    if indicator.Group and self.Groups[indicator.Group] then
        for i, v in ipairs(self.Groups[indicator.Group]) do
            if v == target then
                table.remove(self.Groups[indicator.Group], i)
                break
            end
        end
    end
    
    self.Indicators[target] = nil
end

function ESPContainer:RemoveGroup(groupName)
    if not self.Groups[groupName] then return end
    for _, target in ipairs(self.Groups[groupName]) do
        if self.Indicators[target] then
            if self.Indicators[target].Highlight then self.Indicators[target].Highlight:Destroy() end
            if self.Indicators[target].Billboard then self.Indicators[target].Billboard:Destroy() end
            if self.Indicators[target].Arrow then self.Indicators[target].Arrow:Destroy() end
            self.Indicators[target] = nil
        end
    end
    self.Groups[groupName] = {}
end

function ESPContainer:ClearAllGroups()
    for target, indicator in pairs(self.Indicators) do
        if indicator.Highlight then indicator.Highlight:Destroy() end
        if indicator.Billboard then indicator.Billboard:Destroy() end
        if indicator.Arrow then indicator.Arrow:Destroy() end
    end
    self.Indicators = {}
    self.Groups = {}
end

-- Create ESP container instance
local espcontainer = ESPContainer

-- ═══════════════════════════════════════════════════════════════════════════════
--  ESP RELOAD FUNCTIONS (FROM YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
function reloadESP()
    if not playerESP then return end
    espcontainer:RemoveGroup("players")
    
    local listplayers = Players:GetChildren()
    for _, pl in ipairs(listplayers) do
        if pl == localplayer and hideMeEsp then continue end
        if pl.Character ~= nil then
            local ch = pl.Character
            task.spawn(function()
                if pl == findMurderer() then
                    espcontainer:Add(ch, {
                        AccentColor = Color3.new(1, 0, 0.0156863),
                        ArrowShow = true,
                        LabelText = "Murderer",
                        ShowLabel = true,
                        GroupName = "players"
                    })
                elseif pl == findSheriff() then
                    espcontainer:Add(ch, {
                        AccentColor = Color3.new(0, 0.6, 1),
                        ArrowShow = false,
                        ShowLabel = false,
                        GroupName = "players"
                    })
                else
                    espcontainer:Add(ch, {
                        AccentColor = Color3.new(0, 1, 0.0313725),
                        ArrowShow = false,
                        ShowLabel = false,
                        GroupName = "players"
                    })
                end
            end)
        end
    end
end

function reloadTrapESP()
    espcontainer:RemoveGroup("trap")
    if not trapDetection then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Trap" and (obj.Parent:IsA("Folder") or obj.Parent:IsA("Model")) then
            obj.Transparency = 0
            espcontainer:Add(obj, {
                AccentColor = Color3.new(1, 0, 0.0156863),
                ArrowShow = false,
                ShowLabel = true,
                LabelText = "Trap",
                GroupName = "trap"
            })
        end
    end
end

function reloadGunESP()
    espcontainer:RemoveGroup("gun")
    if not gunDropESP then return end
    local map = getMap()
    if map and map:FindFirstChild("GunDrop") then
        espcontainer:Add(map:FindFirstChild("GunDrop"), {
            AccentColor = Color3.new(0.952941, 1, 0.0745098),
            ArrowShow = true,
            ShowLabel = true,
            LabelText = "Dropped gun!",
            GroupName = "gun"
        })
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ESP AUTO-UPDATE LISTENERS (FROM YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Listen for map load
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
        espcontainer:ClearAllGroups()
    end
end)

-- Listen for traps and gun drops
workspace.DescendantAdded:Connect(function(ch)
    if trapDetection and ch.Name == "Trap" and (ch.Parent:IsA("Folder") or ch.Parent:IsA("Model")) then
        ch.Transparency = 0
        espcontainer:Add(ch, {
            AccentColor = Color3.new(1, 0, 0.0156863),
            ArrowShow = false,
            ShowLabel = true,
            LabelText = "Trap",
            GroupName = "trap"
        })
        notify("XDarkHUB", "Murderer placed a trap!")
    end
    if gunDropESP and ch.Name == "GunDrop" then
        espcontainer:Add(ch, {
            AccentColor = Color3.new(0.952941, 1, 0.0745098),
            ArrowShow = true,
            ShowLabel = true,
            LabelText = "Dropped gun!",
            GroupName = "gun"
        })
        notify("XDarkHUB", "Gun dropped!")
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

workspace.DescendantRemoving:Connect(function(ch)
    if gunDropESP and ch.Name == "GunDrop" then
        espcontainer:RemoveGroup("gun")
        notify("XDarkHUB", "Someone took the gun.")
        if findSheriff() then
            notify("XDarkHUB", "Hero is " .. findSheriff().DisplayName .. ".")
        end
        reloadESP()
    end
end)

-- Listen for player data changes
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

-- Auto reload ESP periodically
task.spawn(function()
    while true do
        if playerESP then reloadESP() end
        task.wait(3)
    end
end)

-- Ignore knife throws
workspace.ChildAdded:Connect(function(chi)
    if chi.Name == "ThrowingKnife" and ignoreknifethrow then
        chi:Destroy()
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  MM2 ACTIONS (FROM YARHM)
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
        CFrame.new(getPredictedPosition(NearestPlayer))
    }
    if spawnAtPlayer then
        argsThrowRemote[1] = CFrame.new(nearestHRP.Position + (nearestHRP.CFrame.LookVector * 5))
    end
    localplayer.Character:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(unpack(argsThrowRemote))
    notify("XDarkHUB", "Knife thrown!")
end

function killClosest()
    if findMurderer() ~= localplayer then notify("XDarkHUB", "You're not murderer.") return end
    if not localplayer.Character:FindFirstChild("Knife") then
        if localplayer.Backpack:FindFirstChild("Knife") then
            localplayer.Character:FindFirstChild("Humanoid"):EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
        else notify("XDarkHUB", "No knife.") return end
    end
    local NearestPlayer = findNearestPlayer()
    if not NearestPlayer or not NearestPlayer.Character then notify("XDarkHUB", "No player.") return end
    local nearestHRP = NearestPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not nearestHRP then return end
    nearestHRP.Anchored = true
    nearestHRP.CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 2
    task.wait(0.1)
    localplayer.Character.Knife.Stab:FireServer("Slash")
    notify("XDarkHUB", "Killed closest!")
end

function killEveryone()
    if findMurderer() ~= localplayer then notify("XDarkHUB", "You're not murderer.") return end
    if not localplayer.Character:FindFirstChild("Knife") then
        if localplayer.Backpack:FindFirstChild("Knife") then
            localplayer.Character:FindFirstChild("Humanoid"):EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
        else notify("XDarkHUB", "No knife.") return end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= localplayer then
            p.Character:FindFirstChild("HumanoidRootPart").Anchored = true
            p.Character:FindFirstChild("HumanoidRootPart").CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 1
        end
    end
    localplayer.Character.Knife.Stab:FireServer("Slash")
    notify("XDarkHUB", "Killed everyone!")
end

function holdHostage()
    if findMurderer() ~= localplayer then notify("XDarkHUB", "You're not murderer.") return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= localplayer then
            p.Character:FindFirstChild("HumanoidRootPart").Anchored = true
            p.Character:FindFirstChild("HumanoidRootPart").CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 5
        end
    end
    notify("XDarkHUB", "All held hostage!")
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
    if Script then Script.Disabled = true; task.wait(); Script.Disabled = false end
    nHuman.Health = nHuman.MaxHealth
    notify("XDarkHUB", "God mode activated!")
end

function teleportToGun()
    local map = getMap()
    if not map or not map:FindFirstChild("GunDrop") then notify("XDarkHUB", "No dropped gun.") return end
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
        if spawn then localplayer.Character:MoveTo(spawn.Position); notify("XDarkHUB", "Teleported to lobby!") end
    end
end

function teleportToMap()
    local map = getMap()
    if not map then notify("XDarkHUB", "No map.") return end
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
    if not murd then notify("XDarkHUB", "No murderer.") return end
    if setclipboard then setclipboard(murd.Name); notify("XDarkHUB", "Copied: " .. murd.Name) end
end

function copySheriffName()
    local sher = findSheriff()
    if not sher then notify("XDarkHUB", "No sheriff.") return end
    if setclipboard then setclipboard(sher.Name); notify("XDarkHUB", "Copied: " .. sher.Name) end
end

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

-- ═══════════════════════════════════════════════════════════════════════════════
--  MINI FLING (FROM YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
function miniFling(playerToFling)
    local Character = localplayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = playerToFling.Character
    local THumanoid, TRootPart, THead, Accessory, Handle
    if TCharacter:FindFirstChildOfClass("Humanoid") then THumanoid = TCharacter:FindFirstChildOfClass("Humanoid") end
    if THumanoid and THumanoid.RootPart then TRootPart = THumanoid.RootPart end
    if TCharacter:FindFirstChild("Head") then THead = TCharacter.Head end
    if TCharacter:FindFirstChildOfClass("Accessory") then Accessory = TCharacter:FindFirstChildOfClass("Accessory") end
    if Accessory and Accessory:FindFirstChild("Handle") then Handle = Accessory.Handle end
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
        if THead then workspace.CurrentCamera.CameraSubject = THead
        elseif not THead and Handle then workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then workspace.CurrentCamera.CameraSubject = THumanoid end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        local SFBasePart = function(BasePart)
            local TimeToWait = 2; local Time = tick(); local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0)); task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0)); task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)); task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0)); task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)); task.wait()
                    end
                else break end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= playerToFling.Character or playerToFling.Parent ~= Players or playerToFling.Character ~= TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end
        workspace.FallenPartsDestroyHeight = 0/0
        local BV = Instance.new("BodyVelocity"); BV.Name = "EpixVel"; BV.Parent = RootPart; BV.Velocity = Vector3.new(9e8, 9e8, 9e8); BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        if TRootPart and THead then if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then SFBasePart(THead) else SFBasePart(TRootPart) end
        elseif TRootPart and not THead then SFBasePart(TRootPart)
        elseif not TRootPart and THead then SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then SFBasePart(Handle)
        else notify("XDarkHUB", "Can't fling.") end
        BV:Destroy(); Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true); workspace.CurrentCamera.CameraSubject = Humanoid
        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0); Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
            Humanoid:ChangeState("GettingUp")
            table.foreach(Character:GetChildren(), function(_, x) if x:IsA("BasePart") then x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new() end end)
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH or -500
    else notify("XDarkHUB", "No character.") end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO LOOPS (FROM YARHM)
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
                        if localplayer.Backpack:FindFirstChild("Gun") then hum:EquipTool(localplayer.Backpack:FindFirstChild("Gun")) else continue end
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

task.spawn(function()
    while task.wait(1.5) do
        if loopThrow then pcall(function() knifeThrow() end) end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  FLOATING BUTTON SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════
local floatingButtons = {}
local floatingButtonGui = nil

local function createFloatingButton(name, text, color, callback, position)
    if not floatingButtonGui then
        floatingButtonGui = Instance.new("ScreenGui")
        floatingButtonGui.Name = "XDarkHUB_FloatingButtons"
        floatingButtonGui.ResetOnSpawn = false
        floatingButtonGui.IgnoreGuiInset = true
        floatingButtonGui.DisplayOrder = 999
        pcall(function() floatingButtonGui.Parent = game:GetService("CoreGui") end)
        if not floatingButtonGui.Parent then floatingButtonGui.Parent = localplayer:WaitForChild("PlayerGui") end
    end
    if floatingButtons[name] then floatingButtons[name]:Destroy(); floatingButtons[name] = nil end
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
    button.ZIndex = 999
    button.Parent = floatingButtonGui
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", button); stroke.Color = Color3.fromRGB(255, 255, 255); stroke.Thickness = 2
    button.MouseButton1Click:Connect(function() clickSnd:Play(); callback() end)
    button.MouseButton1Down:Connect(function(x, y)
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 145, 0, 48)}):Play()
        local ripple = Instance.new("Frame"); ripple.BackgroundColor3 = Color3.fromRGB(255,255,255); ripple.BackgroundTransparency = 1
        ripple.Position = UDim2.fromOffset(x - button.AbsolutePosition.X, y - button.AbsolutePosition.Y)
        ripple.Size = UDim2.fromOffset(50, 50); ripple.AnchorPoint = Vector2.new(0.5, 0.5); ripple.ZIndex = 1000; ripple.Parent = button
        Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
        TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {BackgroundTransparency = 0.6, Size = UDim2.fromOffset(150, 150)}):Play()
        task.spawn(function() task.wait(0.5); if ripple and ripple.Parent then ripple:Destroy() end end)
    end)
    local dragging, dragStart, startPos = false, nil, nil
    button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = button.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local d = input.Position - dragStart; button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false; TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 150, 0, 50)}):Play() end end)
    button.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(button, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 150, 0, 50)}):Play()
    floatingButtons[name] = button
    notify("XDarkHUB", "Button created: " .. text)
end

local function removeFloatingButton(name)
    if floatingButtons[name] then
        TweenService:Create(floatingButtons[name], TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.3); floatingButtons[name]:Destroy(); floatingButtons[name] = nil
        notify("XDarkHUB", "Button removed: " .. name)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  UI SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════
local CC = {bg=Color3.fromRGB(8,8,12),panel=Color3.fromRGB(12,12,18),card=Color3.fromRGB(18,18,26),cardHov=Color3.fromRGB(26,26,36),bdr=Color3.fromRGB(40,40,50),txt=Color3.fromRGB(245,245,255),mut=Color3.fromRGB(100,100,115),wht=Color3.fromRGB(255,255,255),dim=Color3.fromRGB(65,65,80)}
local AC = {base=Color3.fromRGB(235,35,60),dim=Color3.fromRGB(65,12,24),lit=Color3.fromRGB(255,90,115),neo=Color3.fromRGB(255,35,62),soft=Color3.fromRGB(190,45,70)}
local function crn(o,r) Instance.new("UICorner",o).CornerRadius=UDim.new(0,r or 8) end
local function stk(o,c,t,tr) local s=Instance.new("UIStroke",o) s.Color=c s.Thickness=t or 1 s.Transparency=tr or 0 end
local function grd(o,cs,rot) local g=Instance.new("UIGradient",o) g.Color=ColorSequence.new(cs) g.Rotation=rot or 0 end
local function ani(o,p,t,s) TweenService:Create(o,TweenInfo.new(t or 0.25,s or Enum.EasingStyle.Quint),p):Play() end

do local old=localplayer:WaitForChild("PlayerGui"):FindFirstChild("AutoFarmGui") if old then old:Destroy() end end

local gui=Instance.new("ScreenGui") gui.Name="AutoFarmGui" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.Parent=localplayer:WaitForChild("PlayerGui")
collectSound.Parent=gui killSound.Parent=gui deathSound.Parent=gui clickSnd.Parent=gui

local bgF=Instance.new("Frame") bgF.Size=UDim2.new(1,0,1,0) bgF.BackgroundColor3=CC.bg bgF.BackgroundTransparency=0.08 bgF.BorderSizePixel=0 bgF.ZIndex=0 bgF.Parent=gui crn(bgF,0)
grd(bgF,{ColorSequenceKeypoint.new(0,Color3.fromRGB(10,4,14)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(8,8,12)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,4,10))},45)
task.spawn(function() local r=0 while bgF.Parent do r=r+0.15 bgF.UIGradient.Rotation=r task.wait(0.05) end end)
local pCols={AC.base,AC.neo,AC.lit,Color3.fromRGB(255,20,40),Color3.fromRGB(255,115,135)}
for i=1,28 do local sz=math.random(2,11) local p=Instance.new("Frame") p.Size=UDim2.new(0,sz,0,sz) p.Position=UDim2.new(math.random(),0,math.random(),0) p.BackgroundColor3=pCols[math.random(1,#pCols)] p.BackgroundTransparency=math.random(45,82)/100 p.BorderSizePixel=0 p.ZIndex=0 p.Parent=bgF crn(p,math.random(1,5)) task.spawn(function() while p.Parent do ani(p,{Position=UDim2.new(math.random(),0,math.random(),0),BackgroundTransparency=math.random(35,82)/100},math.random(16,36),Enum.EasingStyle.Sine) task.wait(math.random(16,36)) end end) end

local frame=Instance.new("Frame") frame.Size=UDim2.new(0,800,0,600) frame.Position=UDim2.new(0.5,-400,0.5,-300) frame.BackgroundColor3=CC.bg frame.BackgroundTransparency=0.03 frame.BorderSizePixel=0 frame.ClipsDescendants=true frame.ZIndex=1 frame.Parent=gui crn(frame,10) stk(frame,AC.base,1.5,0.4)
frame.Size=UDim2.new(0,0,0,0) frame.Position=UDim2.new(0.5,0,0.5,0) ani(frame,{Size=UDim2.new(0,800,0,600),Position=UDim2.new(0.5,-400,0.5,-300)},0.6,Enum.EasingStyle.Back)

local tBar=Instance.new("Frame") tBar.Size=UDim2.new(1,0,0,60) tBar.BackgroundColor3=CC.panel tBar.BackgroundTransparency=0.04 tBar.BorderSizePixel=0 tBar.Active=true tBar.ZIndex=2 tBar.Parent=frame crn(tBar,10) grd(tBar,{ColorSequenceKeypoint.new(0,Color3.fromRGB(20,14,24)),ColorSequenceKeypoint.new(1,Color3.fromRGB(12,10,16))})
local logo=Instance.new("Frame") logo.Size=UDim2.new(0,40,0,40) logo.Position=UDim2.new(0,15,0.5,-20) logo.BackgroundColor3=AC.base logo.BorderSizePixel=0 logo.ZIndex=3 logo.Parent=tBar crn(logo,10) stk(logo,AC.neo,1.5,0.3)
local logoX=Instance.new("TextLabel") logoX.Size=UDim2.new(1,0,1,0) logoX.BackgroundTransparency=1 logoX.Text="X" logoX.Font=Enum.Font.GothamBlack logoX.TextSize=26 logoX.TextColor3=CC.wht logoX.ZIndex=4 logoX.Parent=logo
local tLbl=Instance.new("TextLabel") tLbl.Size=UDim2.new(1,-150,1,0) tLbl.Position=UDim2.new(0,65,0,0) tLbl.BackgroundTransparency=1 tLbl.Text="XDarkHUB" tLbl.Font=Enum.Font.GothamBlack tLbl.TextSize=24 tLbl.TextColor3=AC.lit tLbl.TextXAlignment=Enum.TextXAlignment.Left tLbl.ZIndex=3 tLbl.Parent=tBar
Instance.new("TextLabel",{Size=UDim2.new(0,80,1,0),Position=UDim2.new(1,-90,0,0),BackgroundTransparency=1,Text="[v36]",Font=Enum.Font.Code,TextSize=12,TextColor3=CC.mut,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=3,Parent=tBar})

do local dr,ds,sp=false,nil,nil tBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true;ds=i.Position;sp=frame.Position end end) UserInputService.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ds frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end) UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end) end

local ctr=Instance.new("Frame") ctr.Size=UDim2.new(1,0,1,-65) ctr.Position=UDim2.new(0,0,0,65) ctr.BackgroundTransparency=1 ctr.Parent=frame
local lPan=Instance.new("Frame") lPan.Size=UDim2.new(0,200,1,0) lPan.BackgroundColor3=CC.panel lPan.BackgroundTransparency=0.04 lPan.BorderSizePixel=0 lPan.ZIndex=2 lPan.Parent=ctr
local vLine=Instance.new("Frame") vLine.Size=UDim2.new(0,1,1,0) vLine.Position=UDim2.new(0,200,0,0) vLine.BackgroundColor3=AC.base vLine.BackgroundTransparency=0.65 vLine.BorderSizePixel=0 vLine.ZIndex=3 vLine.Parent=ctr
local rPan=Instance.new("Frame") rPan.Size=UDim2.new(1,-205,1,0) rPan.Position=UDim2.new(0,205,0,0) rPan.BackgroundTransparency=1 rPan.ZIndex=2 rPan.Parent=ctr

local tabs={} local tabContents={} local currentTab=nil
local function createTab(name,icon,order) local btn=Instance.new("TextButton") btn.Size=UDim2.new(1,-20,0,55) btn.Position=UDim2.new(0,10,0,15+(order-1)*60) btn.BackgroundColor3=CC.card btn.BackgroundTransparency=1 btn.Text="" btn.BorderSizePixel=0 btn.ZIndex=5 btn.Active=true btn.AutoButtonColor=false btn.Parent=lPan crn(btn,10) local ind=Instance.new("Frame") ind.Size=UDim2.new(0,3,0,30) ind.Position=UDim2.new(0,0,0.5,-15) ind.BackgroundColor3=AC.base ind.BackgroundTransparency=1 ind.BorderSizePixel=0 ind.ZIndex=6 ind.Parent=btn crn(ind,2) local ic=Instance.new("TextLabel") ic.Size=UDim2.new(0,40,1,0) ic.Position=UDim2.new(0,15,0,0) ic.BackgroundTransparency=1 ic.Text=icon ic.Font=Enum.Font.GothamBold ic.TextSize=22 ic.TextColor3=CC.mut ic.ZIndex=6 ic.Parent=btn local lbl=Instance.new("TextLabel") lbl.Size=UDim2.new(1,-60,1,0) lbl.Position=UDim2.new(0,55,0,0) lbl.BackgroundTransparency=1 lbl.Text=name lbl.Font=Enum.Font.GothamBold lbl.TextSize=14 lbl.TextColor3=CC.mut lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=6 lbl.Parent=btn tabs[name]={btn=btn,ic=ic,ind=ind,lbl=lbl} btn.MouseEnter:Connect(function() if currentTab~=name then ani(btn,{BackgroundTransparency=0.3},0.15) ani(ic,{TextColor3=CC.txt},0.15) end end) btn.MouseLeave:Connect(function() if currentTab~=name then ani(btn,{BackgroundTransparency=1},0.15) ani(ic,{TextColor3=CC.mut},0.15) end end) end
local function createTabContent(name) local c=Instance.new("ScrollingFrame") c.Size=UDim2.new(1,0,1,0) c.BackgroundTransparency=1 c.BorderSizePixel=0 c.ScrollBarThickness=3 c.ScrollBarImageColor3=AC.base c.CanvasSize=UDim2.new(0,0,0,0) c.AutomaticCanvasSize=Enum.AutomaticSize.Y c.Visible=false c.ZIndex=2 c.Parent=rPan local p=Instance.new("UIPadding",c) p.PaddingLeft=UDim.new(0,25) p.PaddingRight=UDim.new(0,25) p.PaddingTop=UDim.new(0,20) p.PaddingBottom=UDim.new(0,20) local l=Instance.new("UIListLayout",c) l.SortOrder=Enum.SortOrder.LayoutOrder l.Padding=UDim.new(0,12) tabContents[name]=c end
local function switchTab(name) for n,t in pairs(tabs) do t.btn.BackgroundTransparency=1 t.btn.BackgroundColor3=CC.card t.ic.TextColor3=CC.mut t.lbl.TextColor3=CC.mut t.ind.BackgroundTransparency=1 end if tabs[name] then tabs[name].btn.BackgroundTransparency=0.35 tabs[name].btn.BackgroundColor3=Color3.fromRGB(20,20,28) tabs[name].ic.TextColor3=AC.neo tabs[name].lbl.TextColor3=CC.wht tabs[name].ind.BackgroundTransparency=0 tabs[name].ind.BackgroundColor3=AC.neo end for n,c in pairs(tabContents) do if n==name then c.Visible=true c.Position=UDim2.new(0,50,0,0) ani(c,{Position=UDim2.new(0,0,0,0)},0.35,Enum.EasingStyle.Back) else c.Visible=false end end currentTab=name end

createTab("Sheriff","⭐",1) createTab("Murderer","🔪",2) createTab("ESP","👁️",3) createTab("Player","🎯",4) createTab("Farm","⚙️",5)
for n in pairs(tabs) do createTabContent(n) end
for n,t in pairs(tabs) do t.btn.MouseButton1Click:Connect(function() clickSnd:Play() switchTab(n) end) end

local function secT(par,ord,txt) local l=Instance.new("TextLabel") l.Size=UDim2.new(1,0,0,26) l.BackgroundTransparency=1 l.Text=txt l.TextColor3=AC.soft l.Font=Enum.Font.GothamBold l.TextSize=13 l.TextXAlignment=Enum.TextXAlignment.Left l.LayoutOrder=ord l.ZIndex=2 l.Parent=par local ln=Instance.new("Frame") ln.Size=UDim2.new(1,0,0,1) ln.BackgroundColor3=AC.base ln.BackgroundTransparency=0.82 ln.BorderSizePixel=0 ln.LayoutOrder=ord+0.1 ln.ZIndex=2 ln.Parent=par end
local function statR(par,ord,name) local r=Instance.new("Frame") r.Size=UDim2.new(1,0,0,40) r.BackgroundTransparency=1 r.LayoutOrder=ord r.ZIndex=2 r.Parent=par local ln=Instance.new("Frame") ln.Size=UDim2.new(1,0,0,1) ln.Position=UDim2.new(0,0,1,0) ln.BackgroundColor3=CC.bdr ln.BackgroundTransparency=0.65 ln.BorderSizePixel=0 ln.ZIndex=2 ln.Parent=r local dot=Instance.new("Frame") dot.Size=UDim2.new(0,5,0,5) dot.Position=UDim2.new(0,0,0.5,-2.5) dot.BackgroundColor3=AC.base dot.BorderSizePixel=0 dot.ZIndex=2 dot.Parent=r crn(dot,3) Instance.new("TextLabel",{Size=UDim2.new(0.6,0,1,0),Position=UDim2.new(0,18,0,0),BackgroundTransparency=1,Text=name,TextColor3=CC.mut,Font=Enum.Font.Gotham,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=r}) local v=Instance.new("TextLabel") v.Size=UDim2.new(0.4,-18,1,0) v.Position=UDim2.new(0.6,0,0,0) v.BackgroundTransparency=1 v.Text="0" v.TextColor3=AC.lit v.Font=Enum.Font.GothamBold v.TextSize=15 v.TextXAlignment=Enum.TextXAlignment.Right v.ZIndex=2 v.Parent=r return v end
local function togC(par,ord,label,onTog) local cd=Instance.new("Frame") cd.Size=UDim2.new(1,0,0,52) cd.BackgroundTransparency=1 cd.LayoutOrder=ord cd.ZIndex=2 cd.Parent=par local ln=Instance.new("Frame") ln.Size=UDim2.new(1,0,0,1) ln.Position=UDim2.new(0,0,1,0) ln.BackgroundColor3=CC.bdr ln.BackgroundTransparency=0.65 ln.BorderSizePixel=0 ln.ZIndex=2 ln.Parent=cd Instance.new("TextLabel",{Size=UDim2.new(1,-110,1,0),BackgroundTransparency=1,Text=label,TextColor3=CC.txt,Font=Enum.Font.GothamBold,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=cd}) local sw=Instance.new("Frame") sw.Size=UDim2.new(0,60,0,30) sw.Position=UDim2.new(1,-68,0.5,-15) sw.BackgroundColor3=CC.bdr sw.BorderSizePixel=0 sw.ZIndex=2 sw.Parent=cd crn(sw,15) stk(sw,Color3.fromRGB(55,55,70),1) local ind=Instance.new("Frame") ind.Size=UDim2.new(0,20,0,20) ind.Position=UDim2.new(0,5,0.5,-10) ind.BackgroundColor3=CC.mut ind.BorderSizePixel=0 ind.ZIndex=2 ind.Parent=sw crn(ind,10) local pl=Instance.new("TextLabel") pl.Size=UDim2.new(1,0,1,0) pl.Position=UDim2.new(0,28,0,0) pl.BackgroundTransparency=1 pl.Text="OFF" pl.TextColor3=CC.mut pl.Font=Enum.Font.GothamBold pl.TextSize=11 pl.TextXAlignment=Enum.TextXAlignment.Left pl.ZIndex=2 pl.Parent=sw local btn=Instance.new("TextButton") btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text="" btn.ZIndex=3 btn.Active=true btn.Parent=cd local st=false btn.MouseButton1Click:Connect(function() clickSnd:Play() st=not st if st then ani(sw,{BackgroundColor3=AC.dim},0.2) sw.UIStroke.Color=AC.base ani(ind,{Position=UDim2.new(0,35,0.5,-10),BackgroundColor3=AC.neo},0.25,Enum.EasingStyle.Back) pl.Text="ON" ani(pl,{TextColor3=AC.lit},0.2) ani(cd,{BackgroundColor3=Color3.fromRGB(20,16,22),BackgroundTransparency=0.5},0.2) else ani(sw,{BackgroundColor3=CC.bdr},0.2) sw.UIStroke.Color=Color3.fromRGB(55,55,70) ani(ind,{Position=UDim2.new(0,5,0.5,-10),BackgroundColor3=CC.mut},0.25,Enum.EasingStyle.Back) pl.Text="OFF" ani(pl,{TextColor3=CC.mut},0.2) cd.BackgroundTransparency=1 end if onTog then onTog(st) end end) btn.MouseEnter:Connect(function() if not st then ani(cd,{BackgroundColor3=Color3.fromRGB(18,18,24),BackgroundTransparency=0.5},0.15) end end) btn.MouseLeave:Connect(function() if not st then cd.BackgroundTransparency=1 end end) end
local function mkBtn(par,ord,text,color,callback) local b=Instance.new("TextButton") b.Size=UDim2.new(1,0,0,52) b.BackgroundColor3=color or AC.base b.Text=text b.TextColor3=CC.wht b.Font=Enum.Font.GothamBlack b.TextSize=15 b.AutoButtonColor=false b.BorderSizePixel=0 b.LayoutOrder=ord b.ZIndex=2 b.Active=true b.Parent=par crn(b,10) stk(b,AC.neo,1.5) b.MouseEnter:Connect(function() ani(b,{BackgroundColor3=AC.neo},0.15) end) b.MouseLeave:Connect(function() ani(b,{BackgroundColor3=color or AC.base},0.15) end) b.MouseButton1Click:Connect(function() clickSnd:Play() callback() end) end

-- ═══ SHERIFF TAB ═══
local sheriffC=tabContents["Sheriff"] secT(sheriffC,1,"⭐ SHERIFF TOOLS")
mkBtn(sheriffC,2,"🔫 SHOOT MURDERER",AC.base,shootMurderer)
mkBtn(sheriffC,3,"🔫 TP TO DROPPED GUN",Color3.fromRGB(255,200,0),teleportToGun)
mkBtn(sheriffC,4,"📌 FLOATING: TP TO GUN",Color3.fromRGB(100,100,0),function() if floatingButtons["TP_TO_GUN"] then removeFloatingButton("TP_TO_GUN") else createFloatingButton("TP_TO_GUN","🔫 TP TO GUN",Color3.fromRGB(255,200,0),teleportToGun,UDim2.new(0,125,0,90)) end end)
mkBtn(sheriffC,5,"📌 FLOATING: SHOOT",Color3.fromRGB(100,20,30),function() if floatingButtons["SHOOT"] then removeFloatingButton("SHOOT") else createFloatingButton("SHOOT","🔫 SHOOT",AC.base,shootMurderer,UDim2.new(0,125,0,150)) end end)
togC(sheriffC,6,"Auto Shoot Murderer",function(s) autoShooting=s end)
togC(sheriffC,7,"Auto Get Gun On Drop",function(s) autoGetDroppedGun=s end)
togC(sheriffC,8,"Instakill Shoot",function(s) instakillshoot=s end)
mkBtn(sheriffC,9,"📋 SEND NAMES TO CHAT",Color3.fromRGB(50,100,200),sendNamesToChat)
mkBtn(sheriffC,10,"📋 COPY MURDERER NAME",Color3.fromRGB(80,80,80),copyMurdererName)
mkBtn(sheriffC,11,"📋 COPY SHERIFF NAME",Color3.fromRGB(80,80,80),copySheriffName)
mkBtn(sheriffC,12,"📌 RELOAD ESP",Color3.fromRGB(100,100,100),function() reloadESP() notify("XDarkHUB","ESP Reloaded!") end)

-- ═══ MURDERER TAB ═══
local murdererC=tabContents["Murderer"] secT(murdererC,1,"🔪 MURDERER TOOLS")
mkBtn(murdererC,2,"🔪 KNIFE THROW",AC.base,knifeThrow)
mkBtn(murdererC,3,"💀 KILL CLOSEST",Color3.fromRGB(200,0,0),killClosest)
mkBtn(murdererC,4,"💀 KILL EVERYONE",Color3.fromRGB(150,0,0),killEveryone)
mkBtn(murdererC,5,"🔒 HOLD HOSTAGE",Color3.fromRGB(100,0,50),holdHostage)
togC(murdererC,6,"Auto Knife Throw",function(s) loopThrow=s end)
togC(murdererC,7,"Kill Aura",function(s) toggleKillAura(s) end)
togC(murdererC,8,"Spawn Knife Near Player",function(s) spawnAtPlayer=s end)
togC(murdererC,9,"Ignore Knife Throws",function(s) ignoreknifethrow=s end)
mkBtn(murdererC,10,"⚡ GOD MODE",Color3.fromRGB(150,0,150),godMode)
mkBtn(murdererC,11,"🔪 FLING MURDERER",AC.base,function() local m=findMurderer() if m then miniFling(m) else notify("XDarkHUB","No murderer") end end)
mkBtn(murdererC,12,"⭐ FLING SHERIFF",Color3.fromRGB(50,150,255),function() local s=findSheriff() if s then miniFling(s) else notify("XDarkHUB","No sheriff") end end)

-- ═══ ESP TAB ═══
local espC=tabContents["ESP"] secT(espC,1,"👁️ ESP (ESPIndicator from YARHM)")
togC(espC,2,"Players ESP",function(s) playerESP=s if s then if not findMurderer() and not findSheriff() then notify("XDarkHUB","Waiting for roles...") repeat task.wait(1) until findSheriff() or findMurderer() end reloadESP() else espcontainer:RemoveGroup("players") end end)
togC(espC,3,"Dropped Gun ESP",function(s) gunDropESP=s reloadGunESP() end)
togC(espC,4,"Traps ESP",function(s) trapDetection=s reloadTrapESP() end)
togC(espC,5,"Hide My Own ESP",function(s) hideMeEsp=s reloadESP() end)

-- ═══ PLAYER TAB ═══
local playerC=tabContents["Player"] secT(playerC,1,"🎯 TELEPORTS")
mkBtn(playerC,2,"🏠 TP TO LOBBY",Color3.fromRGB(50,100,200),teleportToLobby)
mkBtn(playerC,3,"🗺️ TP TO MAP",Color3.fromRGB(50,150,50),teleportToMap)
secT(playerC,4,"⚙️ SETTINGS")
do local cd=Instance.new("Frame") cd.Size=UDim2.new(1,0,0,52) cd.BackgroundTransparency=1 cd.LayoutOrder=5 cd.ZIndex=2 cd.Parent=playerC Instance.new("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=CC.bdr,BackgroundTransparency=0.65,BorderSizePixel=0,ZIndex=2,Parent=cd}) Instance.new("TextLabel",{Size=UDim2.new(0.5,0,1,0),BackgroundTransparency=1,Text="Shoot Offset",TextColor3=CC.txt,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=cd}) local input=Instance.new("TextBox") input.Size=UDim2.new(0.4,0,1,0) input.Position=UDim2.new(0.55,0,0,0) input.BackgroundColor3=CC.card input.Text=tostring(shootOffset) input.TextColor3=CC.wht input.Font=Enum.Font.GothamBold input.TextSize=13 input.PlaceholderText="2.8" input.BorderSizePixel=0 input.ZIndex=2 input.Parent=cd crn(input,8) input.FocusLost:Connect(function() local val=tonumber(input.Text) if val then shootOffset=val notify("XDarkHUB","Offset: "..val) end end) end
do local cd=Instance.new("Frame") cd.Size=UDim2.new(1,0,0,52) cd.BackgroundTransparency=1 cd.LayoutOrder=6 cd.ZIndex=2 cd.Parent=playerC Instance.new("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=CC.bdr,BackgroundTransparency=0.65,BorderSizePixel=0,ZIndex=2,Parent=cd}) Instance.new("TextLabel",{Size=UDim2.new(0.5,0,1,0),BackgroundTransparency=1,Text="Ping Multiplier",TextColor3=CC.txt,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=cd}) local input=Instance.new("TextBox") input.Size=UDim2.new(0.4,0,1,0) input.Position=UDim2.new(0.55,0,0,0) input.BackgroundColor3=CC.card input.Text=tostring(offsetToPingMult) input.TextColor3=CC.wht input.Font=Enum.Font.GothamBold input.TextSize=13 input.PlaceholderText="1" input.BorderSizePixel=0 input.ZIndex=2 input.Parent=cd crn(input,8) input.FocusLost:Connect(function() local val=tonumber(input.Text) if val then offsetToPingMult=val notify("XDarkHUB","Ping mult: "..val) end end) end

-- ═══ FARM TAB ═══
local fC=tabContents["Farm"] secT(fC,1,"📊 STATS")
local counterV=statR(fC,2,"Coins") local timerV=statR(fC,3,"Time") local rateV=statR(fC,4,"Rate") local pCoinV=statR(fC,5,"Total")
secT(fC,6,"ROLE") local roleV=statR(fC,7,"Status") secT(fC,8,"BAG") local bagVal=statR(fC,9,"State")
togC(fC,10,"Auto Farm",function(s) isActive=s end)
togC(fC,11,"Anti-AFK",function(s) antiAFK=s end)

-- ═══ UI UPDATE ═══
function updateRoleUI() checkRole() if isMurderer then roleV.Text="Murderer" roleV.TextColor3=Color3.fromRGB(255,50,50) elseif isSheriff then roleV.Text="Sheriff" roleV.TextColor3=Color3.fromRGB(50,150,255) else roleV.Text="Innocent" roleV.TextColor3=Color3.fromRGB(50,255,50) end end
function updateBagUI() local cc=getCollectedCoins() if farmStopped then bagVal.Text="Stopped" bagVal.TextColor3=Color3.fromRGB(255,80,80) elseif cc>=MAX_BAG then bagVal.Text="Full" bagVal.TextColor3=Color3.fromRGB(255,200,0) else bagVal.Text=cc.."/"..MAX_BAG bagVal.TextColor3=AC.lit end end
function stopFarming() farmStopped=true updateBagUI() notify("XDarkHUB","Stopped") end

function flyTo(pos,spd) if not rootPart or farmStopped then return false end local d=(pos-rootPart.Position).Magnitude local dur=math.max(0.1,d/spd) local tw=TweenService:Create(rootPart,TweenInfo.new(dur,Enum.EasingStyle.Linear),{CFrame=CFrame.new(pos)}) tw:Play() local c=false local to=task.delay(dur+2,function() c=true tw:Cancel() end) tw.Completed:Wait() if not c then task.cancel(to) end return not c end

function startFarming() initialCoins=getPlayerCoins(localplayer) startTime=tick() visitedPositions={} bagFull=false farmStopped=false counterV.Text="0" timerV.Text="0s" rateV.Text="0" updateRoleUI() updateBagUI() notify("XDarkHUB","Farm ON") task.spawn(function() while isActive do local e=tick()-startTime timerV.Text=math.floor(e).."s" local cc=getCollectedCoins() rateV.Text=tostring(e>0 and math.floor(cc/e*3600) or 0) pCoinV.Text=tostring(getPlayerCoins(localplayer)) task.wait(0.1) end end) task.spawn(function() while isActive do if farmStopped then task.wait(1) continue end character=localplayer.Character if not character then task.wait(0.5) continue end rootPart=character:FindFirstChild("HumanoidRootPart") if not rootPart then task.wait(0.5) continue end checkRole() local cl,sh=nil,math.huge for _,o in ipairs(workspace:GetDescendants()) do if o:IsA("BasePart") and o.Name=="Coin_Server" then local ic=false for _,p in ipairs(Players:GetPlayers()) do if p.Character and o:IsDescendantOf(p.Character) then ic=true break end end if not ic and o.Parent and o:IsDescendantOf(workspace) and not visitedPositions[o] then local d=(o.Position-rootPart.Position).Magnitude if d<sh and d<300 then cl=o sh=d end end end end if cl then local cp=cl.Position local cr=cl if farmStopped then continue end if flyTo(cp,flySpeed) and not farmStopped then task.wait(0.3) if cr.Parent and cr:IsDescendantOf(workspace) then local ic=false for _,p in ipairs(Players:GetPlayers()) do if p.Character and cr:IsDescendantOf(p.Character) then ic=true break end end if not ic and (cr.Position-rootPart.Position).Magnitude<5 then collectSound:Play() updateBagUI() visitedPositions[cr]=true else visitedPositions[cr]=true end else visitedPositions[cr]=true end end else if next(visitedPositions) then visitedPositions={} end task.wait(1) end task.wait(0.1) end end) end

-- Menu button
local mBtn=Instance.new("TextButton") mBtn.Size=UDim2.new(0,70,0,70) mBtn.Position=UDim2.new(0,20,1,-90) mBtn.BackgroundColor3=AC.base mBtn.Text="X" mBtn.TextColor3=CC.wht mBtn.Font=Enum.Font.GothamBlack mBtn.TextSize=30 mBtn.BorderSizePixel=0 mBtn.ZIndex=10 mBtn.Active=true mBtn.AutoButtonColor=false mBtn.Parent=gui crn(mBtn,35) stk(mBtn,AC.neo,1.5,0.4)
task.spawn(function() while mBtn.Parent do ani(mBtn,{Size=UDim2.new(0,75,0,75)},1.5,Enum.EasingStyle.Sine) task.wait(1.5) ani(mBtn,{Size=UDim2.new(0,70,0,70)},1.5,Enum.EasingStyle.Sine) task.wait(1.5) end end)
do local dr,ds,sp=false,nil,nil mBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true ds=i.Position sp=mBtn.Position end end) UserInputService.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ds mBtn.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end) UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end) end
mBtn.MouseButton1Click:Connect(function() clickSnd:Play() local v=frame.Visible frame.Visible=not v bgF.Visible=not v end)

localplayer.CharacterAdded:Connect(function(ch) character=ch rootPart=ch:WaitForChild("HumanoidRootPart") visitedPositions={} farmStopped=false task.wait(1.5) checkRole() updateRoleUI() end)
localplayer.Idled:Connect(function() if antiAFK then VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame) task.wait(1) VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) end end)
RunService.Stepped:Connect(function() if isActive and character and not farmStopped then for _,v in ipairs(character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end end end)

updateRoleUI() updateBagUI() switchTab("Sheriff")
notify("XDarkHUB","v36 Loaded!",3)
notify("XDarkHUB","ESPIndicator from YARHM!",3)
