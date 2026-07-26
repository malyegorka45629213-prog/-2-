-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║              XDarkHUB v41 · MM2 FULL MODULE · BASED ON YARHM                ║
-- ║              ВСЕ ФУНКЦИИ ИЗ YARHM + НАШ UI + АВТОФАРМ + КРЫЛЬЯ              ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

-- ═══════════════════════════════════════════════════════════════════════════════
--  СЕРВИСЫ
-- ═══════════════════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")

local localplayer = Players.LocalPlayer
local character = localplayer.Character or localplayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ═══════════════════════════════════════════════════════════════════════════════
--  ПЕРЕМЕННЫЕ СОСТОЯНИЯ
-- ═══════════════════════════════════════════════════════════════════════════════
local playerESP = false
local sheriffAimbot = false
local coinAutoCollect = false
local autoShooting = false
local shootOffset = 2.8
local offsetToPingMult = 1
local gunDropESP = false
local trapDetection = false
local autoGetDroppedGun = false
local simulateKnifeThrow = false
local playerData = {}
local claimedCoins = {}
local hideMeEsp = false

-- Автофарм
local coinFarming = false
local coinFarmConnection = nil
local coinCollected = 0
local coinBag = 0
local coinLimit = 50
local coinBlacklists = {}
local FARM_SPEED = 30

-- Крылья
local wingsEnabled = false
local wingsParts = {}

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
--  ESP INDICATOR (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════
local espModule = {}
espModule.__index = espModule

local httpService = game:GetService("HttpService")

espModule.Groups = {}
espModule.TargetIndex = {}
espModule.Defaults = {
    AccentColor = Color3.new(1, 1, 0),
    HighlightFillTransparency = 0.7,
    HighlightOutlineTransparency = 0,
    HighlightDepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
    ArrowShow = false,
    ArrowEdgePadding = 50,
    ArrowMinDistance = 0,
    ArrowSize = UDim2.new(0, 30, 0, 30),
    ArrowImage = "rbxassetid://97136202386756",
    ArrowShowDistanceText = true,
    ArrowDistanceFont = Enum.Font.Montserrat,
    ArrowDistanceTextSize = 18,
    ShowLabel = false,
    LabelText = "Target",
    LabelMaxDistance = 99999,
    LabelOffset = Vector3.new(0, 2, 0),
    Parent = game:GetService("CoreGui")
}

function espModule.new(settings)
    local self = setmetatable({}, espModule)
    self.Settings = {}
    for key, default in pairs(espModule.Defaults) do
        self.Settings[key] = (settings and settings[key] ~= nil) and settings[key] or default
    end
    local parent = self.Settings.Parent or localplayer:WaitForChild("PlayerGui")
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ESPIndicators"
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = parent
    self.ArrowTemplate = Instance.new("ImageLabel")
    self.ArrowTemplate.Name = "ArrowTemplate"
    self.ArrowTemplate.Size = self.Settings.ArrowSize
    self.ArrowTemplate.AnchorPoint = Vector2.new(0.5, 0.5)
    self.ArrowTemplate.BackgroundTransparency = 1
    self.ArrowTemplate.Image = self.Settings.ArrowImage
    self.ArrowTemplate.ImageColor3 = self.Settings.AccentColor
    self.ArrowTemplate.Visible = false
    self.ArrowTemplate.Parent = self.ScreenGui
    self.Scaler = Instance.new("UIScale")
    self.Scaler.Name = "Scaler"
    self.Scaler.Scale = 0
    self.Scaler.Parent = self.ArrowTemplate
    self.Indicators = {}
    self._updateConn = RunService.RenderStepped:Connect(function() self:_update() end)
    return self
end

function espModule:AddGroup(groupName)
    local group = espModule.Groups[groupName]
    if not group then
        group = {enabled = true, properties = {}, targets = {}}
        espModule.Groups[groupName] = group
    end
    return group
end

function espModule:Add(target, options)
    assert(target, "ESPIndicator:Add requires a non-nil target")
    options = options or {}
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight_" .. httpService:GenerateGUID(false)
    highlight.Adornee = target
    highlight.FillTransparency = options.HighlightFillTransparency or self.Settings.HighlightFillTransparency
    highlight.FillColor = options.AccentColor or self.Settings.AccentColor
    highlight.OutlineColor = options.AccentColor or self.Settings.AccentColor
    highlight.OutlineTransparency = options.HighlightOutlineTransparency or self.Settings.HighlightOutlineTransparency
    highlight.DepthMode = options.HighlightDepthMode or self.Settings.HighlightDepthMode
    highlight.Parent = self.ScreenGui
    
    local arrow, scaler, distanceLabel
    if (options.ArrowShow or self.Settings.ArrowShow) then
        arrow = self.ArrowTemplate:Clone()
        arrow.Name = "Arrow_" .. httpService:GenerateGUID(false)
        arrow.ImageColor3 = options.AccentColor or self.Settings.AccentColor
        arrow.Visible = true
        arrow.Parent = self.ScreenGui
        scaler = arrow:FindFirstChild("Scaler")
        if (options.ArrowShowDistanceText or self.Settings.ArrowShowDistanceText) then
            distanceLabel = Instance.new("TextLabel")
            distanceLabel.Name = "DistanceLabel"
            distanceLabel.AnchorPoint = Vector2.new(0.5, 0)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.Font = options.ArrowDistanceFont or self.Settings.ArrowDistanceFont
            distanceLabel.TextSize = options.ArrowDistanceTextSize or self.Settings.ArrowDistanceTextSize
            distanceLabel.TextColor3 = options.AccentColor or self.Settings.AccentColor
            distanceLabel.Parent = arrow
        end
    end
    
    local label
    if (options.ShowLabel or self.Settings.ShowLabel) then
        label = Instance.new("BillboardGui")
        label.Name = "Label_" .. httpService:GenerateGUID(false)
        label.AlwaysOnTop = true
        label.MaxDistance = self.Settings.LabelMaxDistance
        label.Size = UDim2.new(0, 70, 0, 70)
        label.StudsOffset = self.Settings.LabelOffset
        label.Adornee = target
        label.Parent = self.ScreenGui
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "TextLabel"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextScaled = true
        textLabel.TextWrapped = true
        textLabel.TextSize = 14
        textLabel.TextColor3 = options.AccentColor or self.Settings.AccentColor
        textLabel.Text = options.LabelText or self.Settings.LabelText
        textLabel.Parent = label
        Instance.new("UIStroke", textLabel)
    end
    
    self.Indicators[target] = {
        Highlight = highlight,
        Arrow = arrow,
        Scaler = scaler,
        DistanceLabel = distanceLabel,
        Label = label,
        Options = options
    }
    
    local groupName = options.GroupName or self.Settings.GroupName
    if groupName then
        self:AddToGroup(target, groupName)
    end
end

function espModule:Remove(target)
    local indicator = self.Indicators[target]
    if not indicator then return end
    if indicator.Highlight then
        indicator.Highlight.Adornee = nil
        indicator.Highlight:Destroy()
    end
    if indicator.Arrow then indicator.Arrow:Destroy() end
    if indicator.Label then indicator.Label:Destroy() end
    self.Indicators[target] = nil
end

function espModule:RemoveGroup(groupName)
    local group = espModule.Groups[groupName]
    if not group then return false end
    for _, target in ipairs(group.targets) do
        self:Remove(target)
    end
    espModule.Groups[groupName] = nil
    return true
end

function espModule:ClearAllGroups()
    for name, _ in pairs(espModule.Groups) do
        self:RemoveGroup(name)
    end
end

function espModule:AddToGroup(target, groupName)
    local group = self:AddGroup(groupName)
    if not table.find(group.targets, target) then
        table.insert(group.targets, target)
    end
    return true
end

function espModule:_update()
    local camera = workspace.CurrentCamera
    local viewportSize = camera.ViewportSize
    local width, height = viewportSize.X, viewportSize.Y
    
    for _, indicator in pairs(self.Indicators) do
        local options = indicator.Options
        local arrow = indicator.Arrow
        local scaler = indicator.Scaler
        
        if not arrow then continue end
        
        local targetPosition
        if indicator.Highlight and indicator.Highlight.Adornee then
            local adornee = indicator.Highlight.Adornee
            if adornee:IsA("Model") then
                targetPosition = (adornee.PrimaryPart and adornee.PrimaryPart.Position) or adornee:GetPivot().Position
            elseif adornee:IsA("BasePart") then
                targetPosition = adornee.Position
            else
                continue
            end
        else
            continue
        end
        
        local screenPosition, onScreen = camera:WorldToViewportPoint(targetPosition)
        local distance = (camera.CFrame.Position - targetPosition).Magnitude
        local minDistance = options.ArrowMinDistance or self.Settings.ArrowMinDistance
        local edgePadding = options.ArrowEdgePadding or self.Settings.ArrowEdgePadding
        
        if onScreen and distance > minDistance then
            TweenService:Create(scaler, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0}):Play()
        else
            TweenService:Create(scaler, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
            
            local safeWidth, safeHeight = width - edgePadding * 2, height - edgePadding * 2
            local cameraCFrame = camera.CFrame
            local diagonal = math.sqrt((safeWidth / 2) ^ 2 + (safeHeight / 2) ^ 2)
            local relativePos = targetPosition - cameraCFrame.Position
            local objectSpacePos = cameraCFrame:VectorToObjectSpace(relativePos)
            local direction = Vector2.new(objectSpacePos.X, objectSpacePos.Y).Unit
            
            local clampedX = math.clamp(screenPosition.X, edgePadding, width - edgePadding)
            local clampedY = math.clamp(screenPosition.Y, edgePadding, height - edgePadding)
            
            if clampedX == screenPosition.X and clampedY == screenPosition.Y and onScreen then
                TweenService:Create(scaler, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0}):Play()
            else
                local offset = direction * diagonal
                local finalOffset
                if math.abs(offset.Y) > safeHeight / 2 then
                    finalOffset = offset * math.abs((safeHeight / 2) / offset.Y)
                else
                    finalOffset = offset * math.abs((safeWidth / 2) / offset.X)
                end
                local arrowX = width / 2 + finalOffset.X
                local arrowY = height / 2 - finalOffset.Y
                local rotation = math.atan2(direction.X, direction.Y)
                TweenService:Create(arrow, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.fromOffset(arrowX, arrowY),
                    Rotation = math.deg(rotation)
                }):Play()
            end
            
            if indicator.DistanceLabel then
                indicator.DistanceLabel.Text = string.format("%dm", math.round(distance))
                local labelOffset = (options.ArrowSize and options.ArrowSize.Y.Offset or self.Settings.ArrowSize.Y.Offset) + 16
                indicator.DistanceLabel.Position = UDim2.new(0.5, 0, 0, labelOffset)
            end
        end
    end
end

function espModule:Destroy()
    if self._updateConn then self._updateConn:Disconnect() end
    self:ClearAllGroups()
    for _, indicator in pairs(self.Indicators) do
        if indicator.Highlight then indicator.Highlight:Destroy() end
        if indicator.Arrow then indicator.Arrow:Destroy() end
        if indicator.Label then indicator.Label:Destroy() end
    end
    self.ScreenGui:Destroy()
    self.Indicators = {}
    espModule.Groups = {}
end

-- Создаём ESP контейнер
local espcontainer = espModule.new({ArrowEdgePadding = 50, ArrowShowDistanceText = false})

-- ═══════════════════════════════════════════════════════════════════════════════
--  MM2 ФУНКЦИИ (ИЗ YARHM)
-- ═══════════════════════════════════════════════════════════════════════════════

function findMurderer()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Knife") then return i end
    end
    for _, i in ipairs(Players:GetPlayers()) do
        if not i.Character then continue end
        if i.Character:FindFirstChild("Knife") then return i end
    end
    if playerData then
        for player, data in pairs(playerData) do
            if data.Role == "Murderer" then
                if Players:FindFirstChild(player) then return Players:FindFirstChild(player) end
            end
        end
    end
    return nil
end

function findSheriff()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Gun") then return i end
    end
    for _, i in ipairs(Players:GetPlayers()) do
        if not i.Character then continue end
        if i.Character:FindFirstChild("Gun") then return i end
    end
    if playerData then
        for player, data in pairs(playerData) do
            if data.Role == "Sheriff" then
                if Players:FindFirstChild(player) then return Players:FindFirstChild(player) end
            end
        end
    end
    return nil
end

function findSheriffThatsNotMe()
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

function getMap()
    for _, o in ipairs(workspace:GetChildren()) do
        if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then
            return o
        end
    end
    return nil
end

function findNearestPlayer()
    local nearestPlayer = nil
    local shortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localplayer and player.Character then
            local localRootPart = localplayer.Character:FindFirstChild("HumanoidRootPart")
            local otherRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if localRootPart and otherRootPart then
                local distance = (localRootPart.Position - otherRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    return nearestPlayer
end

function reloadESP()
    if not playerESP then return end
    espcontainer:RemoveGroup("players")
    local listplayers = Players:GetChildren()
    for _, player in ipairs(listplayers) do
        if player == localplayer and hideMeEsp then continue end
        if player.Character ~= nil then
            local character = player.Character
            task.spawn(function()
                if player == findMurderer() then
                    espcontainer:Add(character, {
                        AccentColor = Color3.new(1, 0, 0.0156863),
                        ArrowShow = true,
                        ArrowMinDistance = 999999,
                        ArrowSize = UDim2.new(0, 40, 0, 40),
                        LabelText = "Murderer",
                        ShowLabel = true,
                        GroupName = "players"
                    })
                elseif player == findSheriff() then
                    espcontainer:Add(character, {
                        AccentColor = Color3.new(0, 0.6, 1),
                        ArrowShow = false,
                        ShowLabel = false,
                        GroupName = "players"
                    })
                else
                    espcontainer:Add(character, {
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

-- MINI FLING (ИЗ YARHM)
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
            notify("XDarkHUB", "Can't find a proper part of target player to fling.")
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
        
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    else
        notify("XDarkHUB", "No valid character of said target player. May have died.")
    end
end

function getPredictedPosition(player, shootOffset)
    local ogplayer = player
    pcall(function()
        player = player.Character
        if not player.Character then return end
    end)
    local playerHRP = player:FindFirstChild("UpperTorso") or player:FindFirstChild("HumanoidRootPart")
    local playerHum = player:FindFirstChild("Humanoid")
    if not playerHRP or not playerHum then
        return Vector3.new(0, 0, 0)
    end
    local velocity = playerHRP.AssemblyLinearVelocity
    local playerMoveDirection = playerHum.MoveDirection
    local predictedPosition = playerHRP.Position + ((velocity * Vector3.new(0.75, 0.5, 0.75))) * (shootOffset / 15) + playerMoveDirection * shootOffset
    predictedPosition = predictedPosition * (((localplayer:GetNetworkPing() * 1000) * ((offsetToPingMult - 1) * 0.01)) + 1)
    return predictedPosition
end

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
    if not murdererHRP then return end
    local predictedPosition = getPredictedPosition(murderer, shootOffset)
    local args = {
        CFrame.new(localplayer.Character.RightHand.Position),
        CFrame.new(predictedPosition)
    }
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
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= localplayer then
            player.Character:FindFirstChild("HumanoidRootPart").Anchored = true
            player.Character:FindFirstChild("HumanoidRootPart").CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 1
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
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= localplayer then
            player.Character:FindFirstChild("HumanoidRootPart").Anchored = true
            player.Character:FindFirstChild("HumanoidRootPart").CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 5
        end
    end
    notify("XDarkHUB", "All players held hostage!")
end

function teleportToGun()
    if not getMap() or not getMap():FindFirstChild("GunDrop") then
        notify("XDarkHUB", "No dropped gun.")
        return
    end
    local previousPosition = localplayer.Character:GetPivot()
    localplayer.Character:PivotTo(getMap():FindFirstChild("GunDrop"):GetPivot())
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
    local spawnsFolder = getMap() and getMap():FindFirstChild("Spawns")
    if spawnsFolder then
        local spawns = spawnsFolder:GetChildren()
        local randomSpawn = spawns[math.random(1, #spawns)]
        localplayer.Character:MoveTo(randomSpawn.Position)
        notify("XDarkHUB", "Teleported to map!")
    else
        notify("XDarkHUB", "No map to teleport to.")
    end
end

function sendNamesToChat()
    local textchannels = game:GetService("TextChatService"):WaitForChild("TextChannels"):GetChildren()
    for _, textchannel in ipairs(textchannels) do
        if textchannel.Name == "RBXSystem" then continue end
        local murd = findMurderer()
        local sher = findSheriff()
        local murdName = murd and murd.Name or "-"
        local sherName = sher and sher.Name or "-"
        local message = string.format("Murderer: %s | Sheriff: %s | <<XDarkHUB>>", murdName, sherName)
        pcall(function() textchannel:SendAsync(message) end)
    end
    notify("XDarkHUB", "Names sent to chat!")
end

local killAuraCon = nil
function toggleKillAura(state)
    if killAuraCon then killAuraCon:Disconnect() end
    if state then
        killAuraCon = RunService.Heartbeat:Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= localplayer then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
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
    end
end

-- ESP Listeners
workspace.ChildAdded:Connect(function(ch)
    if ch == getMap() and playerESP then
        notify("XDarkHUB", "Map loaded, waiting for roles...")
        repeat task.wait(1) until findMurderer() or findSheriff()
        notify("XDarkHUB", "Player ESP reloaded.")
        reloadESP()
    end
end)

workspace.ChildRemoved:Connect(function(ch)
    if ch == getMap() and playerESP then
        notify("XDarkHUB", "Game ended, removing ESPs.")
        playerData = {}
        espcontainer:ClearAllGroups()
    end
end)

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
        notify("XDarkHUB", "Murderer has placed a trap!")
    end
    if gunDropESP and ch.Name == "GunDrop" then
        espcontainer:Add(ch, {
            AccentColor = Color3.new(0.952941, 1, 0.0745098),
            ArrowShow = true,
            ArrowMinDistance = 999999,
            ArrowSize = UDim2.new(0, 40, 0, 40),
            LabelText = "Dropped gun!",
            ShowLabel = true,
            GroupName = "gun"
        })
        notify("XDarkHUB", "Gun dropped!")
        if autoGetDroppedGun then
            task.wait(1)
            if not getMap() or not getMap():FindFirstChild("GunDrop") then return end
            local previousPosition = localplayer.Character:GetPivot()
            localplayer.Character:MoveTo(getMap():FindFirstChild("GunDrop").Position)
            localplayer.Backpack.ChildAdded:Wait()
            localplayer.Character:PivotTo(previousPosition)
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

-- Player Data Listener
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

-- Auto Shoot Loop
task.spawn(function()
    while task.wait(1) do
        if findSheriff() == localplayer and autoShooting then
            notify("XDarkHUB", "Auto-shooting started.")
            repeat
                task.wait(0.1)
                local murderer = findMurderer()
                if not murderer then continue end
                if not localplayer.Character:FindFirstChild("Gun") then
                    local hum = localplayer.Character:FindFirstChild("Humanoid")
                    if localplayer.Backpack:FindFirstChild("Gun") then
                        hum:EquipTool(localplayer.Backpack:FindFirstChild("Gun"))
                    else
                        return
                    end
                end
                local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
                if not murdererHRP then return end
                local predictedPosition = getPredictedPosition(murderer, shootOffset)
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

-- Auto Knife Throw Loop
local loopThrow = false
task.spawn(function()
    while task.wait(1.5) do
        if loopThrow then
            pcall(function() knifeThrow() end)
        end
    end
end)

-- Coin Auto Collect
task.spawn(function()
    while task.wait(0.1) do
        if not coinAutoCollect then continue end
        if getMap() then
            if getMap():FindFirstChild("CoinContainer") and #getMap():FindFirstChild("CoinContainer"):GetChildren() > 1 then
                local closestCoin = nil
                local minDist = math.huge
                for _, coin in ipairs(getMap():FindFirstChild("CoinContainer"):GetChildren()) do
                    if coin:IsA("BasePart") and not claimedCoins[coin] then
                        local dist = (localplayer.Character:FindFirstChild("HumanoidRootPart").Position - coin.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closestCoin = coin
                        end
                    end
                end
                if closestCoin then
                    local distance = (localplayer.Character:FindFirstChild("HumanoidRootPart").Position - closestCoin.Position).Magnitude
                    local toclosestcoin = TweenService:Create(localplayer.Character:FindFirstChild("HumanoidRootPart"), TweenInfo.new(distance * 0.05, Enum.EasingStyle.Linear), {
                        CFrame = closestCoin.CFrame
                    })
                    toclosestcoin:Play()
                    toclosestcoin.Completed:Wait()
                    task.wait(0.1)
                    closestCoin:Destroy()
                    claimedCoins[closestCoin] = true
                end
            end
        end
    end
end)

-- Coin Farming
local function isPlayerInLobby()
    local coinFolder = workspace:FindFirstChild("CoinContainer", true) or workspace:FindFirstChild("CoinVisuals", true) or workspace:FindFirstChild("Coins", true)
    if not coinFolder then return true end
    local lobby = workspace:FindFirstChild("Lobby")
    if lobby and localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (localplayer.Character.HumanoidRootPart.Position - lobby:GetPivot().Position).Magnitude
        if dist < 200 then return true end
    end
    return false
end

local function getNearestCoin(hrp)
    local container = workspace:FindFirstChild("CoinContainer", true) or workspace:FindFirstChild("CoinVisuals", true) or workspace:FindFirstChild("Coins", true)
    if not container then return nil end
    local nearest, minDist = nil, math.huge
    for _, coin in ipairs(container:GetChildren()) do
        if coin:IsA("BasePart") and not coinBlacklists[coin] and (coin.Name == "Coin_Server" or coin:FindFirstChildWhichIsA("TouchTransmitter")) then
            local visual = coin:FindFirstChild("CoinVisual")
            if not visual or visual.Transparency == 0 then
                local dist = (hrp.Position - coin.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = coin
                end
            end
        end
    end
    return nearest
end

local function startCoinFarm()
    if coinFarming then notify("XDarkHUB", "Already coin farming.") return end
    coinFarming = true
    coinFarmConnection = RunService.Heartbeat:Connect(function()
        local char = Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        if isPlayerInLobby() then
            coinBag = 0
            coinBlacklists = {}
            hrp.Velocity = Vector3.zero
            notify("XDarkHUB", "Coin farming | IN LOBBY: " .. coinCollected .. " coins collected.")
            return
        end
        if coinBag >= coinLimit then
            hrp.Velocity = Vector3.zero
            notify("XDarkHUB", "Coin farming | COIN MAX: " .. coinCollected .. " coins collected.")
            return
        end
        local target = getNearestCoin(hrp)
        if target then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            local direction = (target.Position - hrp.Position).Unit
            hrp.Velocity = direction * FARM_SPEED
            hrp.CFrame = CFrame.new(hrp.Position, target.Position)
            local distance = (target.Position - hrp.Position).Magnitude
            if distance < 3 then
                local touch = target:FindFirstChildWhichIsA("TouchTransmitter", true) or target
                if firetouchinterest then
                    firetouchinterest(hrp, touch.Parent or touch, 0)
                    task.spawn(function()
                        task.wait()
                        firetouchinterest(hrp, touch.Parent or touch, 1)
                    end)
                end
                coinCollected = coinCollected + 1
                coinBlacklists[target] = true
            end
        else
            hrp.Velocity = Vector3.zero
        end
        notify("XDarkHUB", "Coin farming: " .. coinBag .. " / " .. coinLimit .. " in bag. Total: " .. coinCollected)
    end)
end

local function stopCoinFarm()
    if not coinFarming then notify("XDarkHUB", "You're not coin farming.") return end
    notify("XDarkHUB", "Stopped coin farming. Collected " .. coinCollected .. " coins.")
    coinFarming = false
    if coinFarmConnection then
        coinFarmConnection:Disconnect()
        coinFarmConnection = nil
    end
    coinCollected = 0
    coinBlacklists = {}
    coinBag = 0
    local char = localplayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.zero end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  3D КРЫЛЬЯ
-- ═══════════════════════════════════════════════════════════════════════════════
local function removeWings()
    for _, part in ipairs(wingsParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    wingsParts = {}
    wingsEnabled = false
end

local function createWings()
    if wingsEnabled then removeWings() end
    
    character = localplayer.Character
    if not character then return end
    
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if not torso then return end
    
    wingsEnabled = true
    
    -- Левое крыло
    local leftWing = Instance.new("WedgePart")
    leftWing.Name = "LeftWing"
    leftWing.Size = Vector3.new(0.3, 3, 6)
    leftWing.Color = Color3.fromRGB(255, 30, 50)
    leftWing.Material = Enum.Material.Neon
    leftWing.Transparency = 0.3
    leftWing.Anchored = false
    leftWing.CanCollide = false
    leftWing.TopSurface = Enum.SurfaceType.Smooth
    leftWing.BottomSurface = Enum.SurfaceType.Smooth
    leftWing.Parent = character
    
    local leftWeld = Instance.new("WeldConstraint")
    leftWeld.Part0 = torso
    leftWeld.Part1 = leftWing
    leftWeld.Parent = leftWing
    leftWing.CFrame = torso.CFrame * CFrame.new(-2.5, 0.5, 1) * CFrame.Angles(0, math.rad(20), math.rad(-15))
    
    -- Правое крыло
    local rightWing = Instance.new("WedgePart")
    rightWing.Name = "RightWing"
    rightWing.Size = Vector3.new(0.3, 3, 6)
    rightWing.Color = Color3.fromRGB(255, 30, 50)
    rightWing.Material = Enum.Material.Neon
    rightWing.Transparency = 0.3
    rightWing.Anchored = false
    rightWing.CanCollide = false
    rightWing.TopSurface = Enum.SurfaceType.Smooth
    rightWing.BottomSurface = Enum.SurfaceType.Smooth
    rightWing.Parent = character
    
    local rightWeld = Instance.new("WeldConstraint")
    rightWeld.Part0 = torso
    rightWeld.Part1 = rightWing
    rightWeld.Parent = rightWing
    rightWing.CFrame = torso.CFrame * CFrame.new(2.5, 0.5, 1) * CFrame.Angles(0, math.rad(-20), math.rad(15))
    
    -- Маленькие верхние крылья
    local leftWingSmall = Instance.new("WedgePart")
    leftWingSmall.Name = "LeftWingSmall"
    leftWingSmall.Size = Vector3.new(0.2, 2, 4)
    leftWingSmall.Color = Color3.fromRGB(255, 80, 100)
    leftWingSmall.Material = Enum.Material.Neon
    leftWingSmall.Transparency = 0.5
    leftWingSmall.Anchored = false
    leftWingSmall.CanCollide = false
    leftWingSmall.Parent = character
    
    local leftSmallWeld = Instance.new("WeldConstraint")
    leftSmallWeld.Part0 = torso
    leftSmallWeld.Part1 = leftWingSmall
    leftSmallWeld.Parent = leftWingSmall
    leftWingSmall.CFrame = torso.CFrame * CFrame.new(-1.8, 1.5, 1.5) * CFrame.Angles(0, math.rad(30), math.rad(-25))
    
    local rightWingSmall = Instance.new("WedgePart")
    rightWingSmall.Name = "RightWingSmall"
    rightWingSmall.Size = Vector3.new(0.2, 2, 4)
    rightWingSmall.Color = Color3.fromRGB(255, 80, 100)
    rightWingSmall.Material = Enum.Material.Neon
    rightWingSmall.Transparency = 0.5
    rightWingSmall.Anchored = false
    rightWingSmall.CanCollide = false
    rightWingSmall.Parent = character
    
    local rightSmallWeld = Instance.new("WeldConstraint")
    rightSmallWeld.Part0 = torso
    rightSmallWeld.Part1 = rightWingSmall
    rightSmallWeld.Parent = rightWingSmall
    rightWingSmall.CFrame = torso.CFrame * CFrame.new(1.8, 1.5, 1.5) * CFrame.Angles(0, math.rad(-30), math.rad(25))
    
    -- ParticleEmitter на каждом крыле
    for _, wing in ipairs({leftWing, rightWing, leftWingSmall, rightWingSmall}) do
        local emitter = Instance.new("ParticleEmitter")
        emitter.Name = "WingParticles"
        emitter.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 70)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 120))
        })
        emitter.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(1, 0)
        })
        emitter.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(1, 1)
        })
        emitter.Lifetime = NumberRange.new(0.5, 1)
        emitter.Rate = 15
        emitter.Speed = NumberRange.new(1, 3)
        emitter.SpreadAngle = Vector2.new(30, 30)
        emitter.LightEmission = 1
        emitter.Parent = wing
    end
    
    table.insert(wingsParts, leftWing)
    table.insert(wingsParts, rightWing)
    table.insert(wingsParts, leftWingSmall)
    table.insert(wingsParts, rightWingSmall)
    
    -- Анимация взмахов крыльев
    task.spawn(function()
        local angle = 0
        while wingsEnabled and leftWing.Parent and rightWing.Parent do
            angle = angle + 0.1
            local flapAngle = math.sin(angle) * 0.3
            local flapAngleSmall = math.sin(angle * 1.5) * 0.4
            
            leftWing.CFrame = torso.CFrame * CFrame.new(-2.5, 0.5, 1) * CFrame.Angles(flapAngle, math.rad(20), math.rad(-15))
            rightWing.CFrame = torso.CFrame * CFrame.new(2.5, 0.5, 1) * CFrame.Angles(flapAngle, math.rad(-20), math.rad(15))
            leftWingSmall.CFrame = torso.CFrame * CFrame.new(-1.8, 1.5, 1.5) * CFrame.Angles(flapAngleSmall, math.rad(30), math.rad(-25))
            rightWingSmall.CFrame = torso.CFrame * CFrame.new(1.8, 1.5, 1.5) * CFrame.Angles(flapAngleSmall, math.rad(-30), math.rad(25))
            
            task.wait(0.02)
        end
    end)
    
    notify("XDarkHUB", "3D Wings activated!")
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  НАШ КРАСИВЫЙ UI
-- ═══════════════════════════════════════════════════════════════════════════════

-- Цвета UI
local COL = {
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
local ACCENT = {
    base = Color3.fromRGB(235, 35, 60),
    dim = Color3.fromRGB(65, 12, 24),
    lit = Color3.fromRGB(255, 90, 115),
    neo = Color3.fromRGB(255, 35, 62),
    soft = Color3.fromRGB(190, 45, 70),
}

-- UI Helpers
local function crn(o, r)
    Instance.new("UICorner", o).CornerRadius = UDim.new(0, r or 8)
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

-- Очистка старого GUI
do
    local old = localplayer:WaitForChild("PlayerGui"):FindFirstChild("XDarkHUB")
    if old then old:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "XDarkHUB"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = localplayer:WaitForChild("PlayerGui")

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 500)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
mainFrame.BackgroundColor3 = COL.bg
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui
crn(mainFrame, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = ACCENT.base
mainStroke.Thickness = 2

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = COL.panel
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.Parent = mainFrame
crn(titleBar, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 50, 0, 0)
title.BackgroundTransparency = 1
title.Text = "XDarkHUB · MM2"
title.TextColor3 = ACCENT.lit
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local logo = Instance.new("Frame")
logo.Size = UDim2.new(0, 32, 0, 32)
logo.Position = UDim2.new(0, 12, 0.5, -16)
logo.BackgroundColor3 = ACCENT.base
logo.BorderSizePixel = 0
logo.Parent = titleBar
crn(logo, 8)

local logoX = Instance.new("TextLabel")
logoX.Size = UDim2.new(1, 0, 1, 0)
logoX.BackgroundTransparency = 1
logoX.Text = "X"
logoX.Font = Enum.Font.GothamBlack
logoX.TextSize = 20
logoX.TextColor3 = COL.wht
logoX.Parent = logo

-- Dragging
do
    local dragging, dragStart, startPos = false, nil, nil
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Tabs Container
local tabsContainer = Instance.new("Frame")
tabsContainer.Size = UDim2.new(1, 0, 0, 40)
tabsContainer.Position = UDim2.new(0, 0, 0, 45)
tabsContainer.BackgroundColor3 = COL.panel
tabsContainer.BorderSizePixel = 0
tabsContainer.Parent = mainFrame

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, 0, 1, -85)
contentArea.Position = UDim2.new(0, 0, 0, 85)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

-- Tab System
local tabFrames = {}
local currentTab = nil

local function createTab(tabName, label)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 120, 1, 0)
    tabBtn.Position = UDim2.new(0, (#tabsContainer:GetChildren() - 1) * 120, 0, 0)
    tabBtn.BackgroundColor3 = COL.card
    tabBtn.Text = label
    tabBtn.TextColor3 = COL.txt
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 13
    tabBtn.BorderSizePixel = 0
    tabBtn.Parent = tabsContainer
    crn(tabBtn, 6)
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 3
    tabContent.ScrollBarImageColor3 = ACCENT.base
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.Visible = false
    tabContent.Parent = contentArea
    
    local list = Instance.new("UIListLayout", tabContent)
    list.Padding = UDim.new(0, 8)
    local pad = Instance.new("UIPadding", tabContent)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingTop = UDim.new(0, 12)
    
    tabFrames[tabName] = {button = tabBtn, frame = tabContent}
    
    tabBtn.MouseButton1Click:Connect(function()
        for n, t in pairs(tabFrames) do
            t.button.BackgroundColor3 = COL.card
            t.button.TextColor3 = COL.txt
            t.frame.Visible = false
        end
        tabBtn.BackgroundColor3 = ACCENT.base
        tabBtn.TextColor3 = COL.wht
        tabContent.Visible = true
        currentTab = tabName
    end)
end

-- UI Components
local function addLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = ACCENT.lit
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function addButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundColor3 = COL.card
    button.Text = text
    button.TextColor3 = COL.wht
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.BorderSizePixel = 0
    button.Parent = parent
    crn(button, 6)
    local btnStroke = Instance.new("UIStroke", button)
    btnStroke.Color = ACCENT.base
    btnStroke.Thickness = 1
    button.MouseButton1Click:Connect(callback)
    return button
end

local function addToggle(parent, text, callback)
    local state = false
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundColor3 = COL.card
    button.Text = text .. " [OFF]"
    button.TextColor3 = COL.wht
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.BorderSizePixel = 0
    button.Parent = parent
    crn(button, 6)
    local btnStroke = Instance.new("UIStroke", button)
    btnStroke.Color = ACCENT.base
    btnStroke.Thickness = 1
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = text .. (state and " [ON]" or " [OFF]")
        button.BackgroundColor3 = state and ACCENT.base or COL.card
        callback(state)
    end)
    return button
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  СОЗДАНИЕ ВКЛАДОК
-- ═══════════════════════════════════════════════════════════════════════════════

createTab("ESP", "👁️ ESP")
createTab("Sheriff", "⭐ Sheriff")
createTab("Murderer", "🔪 Murderer")
createTab("Teleports", "🗺️ TP")
createTab("Visuals", "🦋 Visuals")
createTab("Misc", "⚙️ Misc")

-- ═══════════════════════════════════════════════════════════════════════════════
--  ESP TAB
-- ═══════════════════════════════════════════════════════════════════════════════

local espTab = tabFrames["ESP"].frame
addLabel(espTab, "ESPs")
addToggle(espTab, "Players ESP", function(state)
    playerESP = state
    if state then
        if not findMurderer() or not findSheriff() then
            notify("XDarkHUB", "No roles yet. Waiting for roles...")
            repeat task.wait(1) until findSheriff() or findMurderer()
        end
        reloadESP()
    else
        espcontainer:RemoveGroup("players")
    end
end)
addToggle(espTab, "Dropped Gun ESP", function(state)
    gunDropESP = state
    if state then
        if getMap() and getMap():FindFirstChild("GunDrop") then
            espcontainer:Add(getMap():FindFirstChild("GunDrop"), {
                AccentColor = Color3.new(0.952941, 1, 0.0745098),
                ArrowShow = true,
                ArrowMinDistance = 999999,
                ArrowSize = UDim2.new(0, 40, 0, 40),
                LabelText = "Dropped gun!",
                ShowLabel = true,
                GroupName = "gun"
            })
            notify("XDarkHUB", "Gun ESP enabled!")
        end
    else
        espcontainer:RemoveGroup("gun")
    end
end)
addToggle(espTab, "Traps ESP", function(state)
    trapDetection = state
    if state then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "Trap" and (v.Parent:IsA("Folder") or v.Parent:IsA("Model")) then
                v.Transparency = 0
                espcontainer:Add(v, {
                    AccentColor = Color3.new(1, 0, 0),
                    ArrowShow = false,
                    ShowLabel = true,
                    LabelText = "Trap",
                    GroupName = "trap"
                })
            end
        end
    else
        espcontainer:RemoveGroup("trap")
    end
end)
addToggle(espTab, "Hide my own ESP", function(state)
    hideMeEsp = state
    reloadESP()
end)
addButton(espTab, "Reload ESP", function()
    reloadESP()
    notify("XDarkHUB", "ESP reloaded!")
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  SHERIFF TAB
-- ═══════════════════════════════════════════════════════════════════════════════

local sheriffTab = tabFrames["Sheriff"].frame
addLabel(sheriffTab, "Tools")
addButton(sheriffTab, "Shoot murderer", shootMurderer)
addToggle(sheriffTab, "Auto shoot murderer", function(state)
    autoShooting = state
end)
addToggle(sheriffTab, "Instakill murderer as sheriff", function(state)
    instakillshoot = state
end)
addToggle(sheriffTab, "Automatically get gun on drop", function(state)
    autoGetDroppedGun = state
end)
addButton(sheriffTab, "Teleport to dropped gun", teleportToGun)
addButton(sheriffTab, "Fling Sheriff", function()
    if not findSheriff() then
        notify("XDarkHUB", "No sheriff/hero to fling.")
        return
    end
    miniFling(findSheriff())
end)
addButton(sheriffTab, "Send Sheriff and Murderer names into chat", sendNamesToChat)
addButton(sheriffTab, "Copy murderer username", function()
    if not findMurderer() then
        notify("XDarkHUB", "No murderer to copy.")
        return
    end
    if setclipboard then setclipboard(findMurderer().Name) end
    notify("XDarkHUB", "Copied to clipboard.")
end)
addButton(sheriffTab, "Copy sheriff username", function()
    if not findSheriff() then
        notify("XDarkHUB", "No sheriff/hero to copy.")
        return
    end
    if setclipboard then setclipboard(findSheriff().Name) end
    notify("XDarkHUB", "Copied to clipboard.")
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  MURDERER TAB
-- ═══════════════════════════════════════════════════════════════════════════════

local murdererTab = tabFrames["Murderer"].frame
addLabel(murdererTab, "Tools")
addButton(murdererTab, "Knife throw to closest", knifeThrow)
addToggle(murdererTab, "Auto knife throw", function(state)
    loopThrow = state
end)
addToggle(murdererTab, "Spawn knife throw near player", function(state)
    spawnAtPlayer = state
end)
addButton(murdererTab, "Kill closest player as murderer", killClosest)
addButton(murdererTab, "Kill EVERYONE as murderer", killEveryone)
addButton(murdererTab, "Hold everyone hostage", holdHostage)
addToggle(murdererTab, "Murderer kill aura", function(state)
    toggleKillAura(state)
end)
addButton(murdererTab, "Fling Murderer", function()
    if not findMurderer() then
        notify("XDarkHUB", "No murderer to fling.")
        return
    end
    miniFling(findMurderer())
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  TELEPORTS TAB
-- ═══════════════════════════════════════════════════════════════════════════════

local teleportsTab = tabFrames["Teleports"].frame
addLabel(teleportsTab, "Teleports")
addButton(teleportsTab, "Teleport to lobby", teleportToLobby)
addButton(teleportsTab, "Teleport to map", teleportToMap)
addButton(teleportsTab, "Teleport to dropped gun", teleportToGun)

-- ═══════════════════════════════════════════════════════════════════════════════
--  VISUALS TAB (3D WINGS + COIN FARMING)
-- ═══════════════════════════════════════════════════════════════════════════════

local visualsTab = tabFrames["Visuals"].frame
addLabel(visualsTab, "3D Visuals")
addButton(visualsTab, "🦋 Toggle 3D Wings", function()
    if wingsEnabled then
        removeWings()
        notify("XDarkHUB", "Wings removed!")
    else
        createWings()
    end
end)

addLabel(visualsTab, "Coin Farming")
addButton(visualsTab, "Start coin farming", startCoinFarm)
addButton(visualsTab, "Stop coin farming", stopCoinFarm)

-- ═══════════════════════════════════════════════════════════════════════════════
--  MISC TAB
-- ═══════════════════════════════════════════════════════════════════════════════

local miscTab = tabFrames["Misc"].frame
addLabel(miscTab, "Miscellaneous")
addButton(miscTab, "God mode (Very, VERY UNSTABLE)", function()
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
end)
addButton(miscTab, "Anti AFK detection", function()
    local pl = Players.LocalPlayer
    if getconnections then
        for _, connection in pairs(getconnections(pl.Idled)) do
            if connection["Disable"] then
                connection["Disable"](connection)
            elseif connection["Disconnect"] then
                connection["Disconnect"](connection)
            end
        end
    else
        pl.Idled:Connect(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
    end
    notify("XDarkHUB", "Anti-AFK activated!")
end)
addToggle(miscTab, "Ignore knife throws", function(state)
    ignoreknifethrow = state
end)

-- Show first tab
tabFrames["ESP"].button.BackgroundColor3 = ACCENT.base
tabFrames["ESP"].button.TextColor3 = COL.wht
tabFrames["ESP"].frame.Visible = true
currentTab = "ESP"

notify("XDarkHUB", "v41 Loaded!", 3)
notify("XDarkHUB", "All YARHM functions included!", 3)
notify("XDarkHUB", "3D Wings + Coin Farming added!", 3)

-- Character Added Listener
localplayer.CharacterAdded:Connect(function(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
    if wingsEnabled then
        task.wait(2)
        createWings()
    end
end)
