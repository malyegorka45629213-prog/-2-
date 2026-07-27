local HUB_NAME = "XDarkHUB"   -- <-- СЮДА СВОЁ НАЗВАНИЕ ХАБА

local _banGui, _banTxt
local function ban(msg, col)
    pcall(function()
        if not _banGui then
            _banGui = Instance.new("ScreenGui")
            local pr
            if gethui then pcall(function() pr = gethui() end) end
            if not pr then pcall(function() pr = game:GetService("CoreGui") end) end
            if not pr then pcall(function() pr = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") end) end
            if pr then _banGui.Parent = pr end
            _banGui.ResetOnSpawn = false
            pcall(function() _banGui.DisplayOrder = 999999999 end)
            local f = Instance.new("Frame", _banGui)
            f.Size = UDim2.new(0, 660, 0, 150); f.Position = UDim2.new(0.5, -330, 0, 14)
            f.BackgroundColor3 = Color3.fromRGB(10, 10, 12); f.BorderSizePixel = 0
            pcall(function() Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12) end)
            pcall(function() local s = Instance.new("UIStroke", f); s.Color = Color3.fromRGB(224, 49, 62); s.Thickness = 2 end)
            _banTxt = Instance.new("TextLabel", f)
            _banTxt.Size = UDim2.new(1, -24, 1, -24); _banTxt.Position = UDim2.new(0, 12, 0, 12)
            _banTxt.BackgroundTransparency = 1; _banTxt.Font = Enum.Font.GothamBold; _banTxt.TextSize = 16
            _banTxt.TextWrapped = true; _banTxt.TextXAlignment = Enum.TextXAlignment.Left
            _banTxt.TextYAlignment = Enum.TextYAlignment.Top; _banTxt.ZIndex = 5
        end
        _banTxt.Text = msg; _banTxt.TextColor3 = col or Color3.fromRGB(245, 245, 248)
    end)
end
ban("[" .. HUB_NAME .. "] загрузка...")

local function safeParentGui(obj)
    local attempts = {}
    if gethui and type(gethui) == "function" then table.insert(attempts, function() return gethui() end) end
    if get_hidden_gui and type(get_hidden_gui) == "function" then table.insert(attempts, function() return get_hidden_gui() end) end
    table.insert(attempts, function()
        local pl = game:GetService("Players").LocalPlayer
        return pl and pl:FindFirstChild("PlayerGui")
    end)
    table.insert(attempts, function() return game:GetService("CoreGui") end)
    for _, fn in ipairs(attempts) do
        local ok, res = pcall(fn)
        if ok and res then
            local ok2 = pcall(function() obj.Parent = res end)
            if ok2 and obj.Parent == res then return res end
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
            pcall(function() statusGui.IgnoreGuiInset = true end)
            pcall(function() statusGui.DisplayOrder = 999999999 end)
            if not safeParentGui(statusGui) then return end
            statusLabel = Instance.new("TextLabel")
            statusLabel.Size = UDim2.new(0, 560, 0, 80)
            statusLabel.Position = UDim2.new(0.5, -280, 0, 8)
            statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            statusLabel.BackgroundTransparency = 0.35
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            statusLabel.Font = Enum.Font.GothamBold
            statusLabel.TextScaled = true
            statusLabel.TextWrapped = true
            statusLabel.ZIndex = 999999
            statusLabel.Text = ""
            statusLabel.Parent = statusGui
            pcall(function() Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 10) end)
        end
        if statusLabel then
            statusLabel.Visible = true
            statusLabel.Text = text
            statusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        end
    end)
end

local function xdError(err)
    pcall(function() warn("[" .. HUB_NAME .. " ERROR] " .. tostring(err)) end)
    ban("[" .. HUB_NAME .. " ERROR]\n" .. tostring(err), Color3.fromRGB(255, 90, 90))
    xdStatus(HUB_NAME .. " ERROR: " .. tostring(err), Color3.fromRGB(255, 70, 70))
end

local xdWait = (task and task.wait) or wait
local xdDelay = function(t, f) if task and task.delay then task.delay(t, f) else delay(t, f) end end
local xdSpawn = function(f) if task and task.spawn then task.spawn(f) else spawn(f) end end

xdStatus(HUB_NAME .. ": загрузка...", Color3.fromRGB(255, 255, 255))

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
    while not player do xdWait(0.1); player = Players.LocalPlayer end
    local localplayer = player
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    xdSpawn(function()
        if character and not rootPart then rootPart = character:WaitForChild("HumanoidRootPart", 10) end
    end)

    local visitedPositions = {}
    local isActive = false
    local flySpeed = 16
    local bagSize = 40
    local initialCoins = 0
    local startTime = 0
    local antiAFK = false
    local isMurderer = false
    local isSheriff = false
    local isHero = false
    local farmStopped = false
    local farmRunning = false
    local flingOnFullBag = false
    local alreadyFlungOnFull = false
    local bagFullNotified = false

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

    local COL = {
        bgDeep = Color3.fromRGB(14, 14, 16),
        bg = Color3.fromRGB(20, 20, 23),
        panel = Color3.fromRGB(27, 27, 31),
        card = Color3.fromRGB(35, 35, 40),
        cardHover = Color3.fromRGB(46, 46, 52),
        accent = Color3.fromRGB(224, 49, 62),
        accentHot = Color3.fromRGB(242, 82, 94),
        accentDim = Color3.fromRGB(112, 26, 34),
        ember = Color3.fromRGB(242, 110, 90),
        gold = Color3.fromRGB(240, 180, 90),
        text = Color3.fromRGB(232, 232, 236),
        textDim = Color3.fromRGB(142, 142, 152),
        border = Color3.fromRGB(42, 42, 48),
        track = Color3.fromRGB(52, 52, 58),
        line = Color3.fromRGB(40, 40, 46),
        knob = Color3.fromRGB(245, 245, 248),
    }

    local function corner(o, r)
        local ok, c = pcall(function()
            local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0, r or 8); cr.Parent = o; return cr
        end); if ok then return c end; return nil
    end
    local function stroke(o, color, thickness, transparency)
        local ok, s = pcall(function()
            local st = Instance.new("UIStroke"); st.Color = color; st.Thickness = thickness or 1
            st.Transparency = transparency or 0; st.Parent = o; return st
        end); if ok then return s end; return nil
    end
    local function gradient(o, keypoints, rotation)
        local ok, g = pcall(function()
            local gr = Instance.new("UIGradient"); gr.Color = ColorSequence.new(keypoints)
            gr.Rotation = rotation or 0; gr.Parent = o; return g
        end); if ok then return g end; return nil
    end
    local function tween(o, props, time, style, dir)
        pcall(function()
            TweenService:Create(o, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
        end)
    end
    local function rotY(v, a)
        local c, s = math.cos(a), math.sin(a)
        return Vector3.new(v.X * c + v.Z * s, v.Y, -v.X * s + v.Z * c)
    end
    local function rotX(v, a)
        local c, s = math.cos(a), math.sin(a)
        return Vector3.new(v.X, v.Y * c - v.Z * s, v.Y * s + v.Z * c)
    end

    local toastHolder = nil
    local toastOrder = 0
    local function notify(title, text, duration)
        local handled = false
        if toastHolder and toastHolder.Parent then
            handled = pcall(function()
                toastOrder = toastOrder + 1
                local t = Instance.new("Frame")
                t.Size = UDim2.new(1, 0, 0, 44)
                t.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
                t.BackgroundTransparency = 1
                t.LayoutOrder = toastOrder
                t.ZIndex = 201
                t.Parent = toastHolder
                corner(t, 10)
                stroke(t, COL.accent, 1, 0.35)
                local bar = Instance.new("Frame")
                bar.Size = UDim2.new(0, 3, 1, -16); bar.Position = UDim2.new(0, 0, 0, 8)
                bar.BackgroundColor3 = COL.accentHot; bar.BackgroundTransparency = 1
                bar.ZIndex = 202; bar.Parent = t; corner(bar, 2)
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -22, 1, 0); lbl.Position = UDim2.new(0, 13, 0, 0)
                lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 12; lbl.TextColor3 = COL.text; lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextWrapped = true; lbl.TextTransparency = 1; lbl.ZIndex = 202; lbl.Parent = t
                tween(t, {BackgroundTransparency = 0.12}, 0.3)
                tween(lbl, {TextTransparency = 0}, 0.3)
                tween(bar, {BackgroundTransparency = 0}, 0.3)
                xdSpawn(function()
                    xdWait(duration or 3)
                    tween(t, {BackgroundTransparency = 1}, 0.4)
                    tween(lbl, {TextTransparency = 1}, 0.4)
                    tween(bar, {BackgroundTransparency = 1}, 0.4)
                    xdWait(0.45); t:Destroy()
                end)
            end)
        end
        if not handled then
            pcall(function()
                StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 3})
            end)
        end
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
        if v:find("hero") then return "Hero" end
        if v:find("sheriff") or v:find("cop") then return "Sheriff" end
        if v:find("innocent") or v:find("civilian") or v:find("none") then return "Innocent" end
        return nil
    end

    local function readRoleFromTable(tbl)
        if type(tbl) ~= "table" then return nil end
        return normalizeRoleName(tbl.Role or tbl.role or tbl.RoleName or tbl.rolename or tbl.Status or tbl.status or tbl.Team or tbl.team or tbl.PlayerRole or tbl.playerRole)
    end

    local function getPlayerRole(pl)
        if not pl then return "Innocent" end
        local function hasTool(name)
            if pl.Backpack and pl.Backpack:FindFirstChild(name) then return true end
            if pl.Character and pl.Character:FindFirstChild(name) then return true end
            return false
        end
        if hasTool("Knife") then return "Murderer" end
        if hasTool("Gun") or hasTool("Revolver") or hasTool("Pistol") then
            local cached = playerData[pl.Name] or playerData[pl] or playerData[pl.UserId]
            if type(cached) == "string" and cached:lower():find("hero") then return "Hero" end
            if type(cached) == "table" and readRoleFromTable(cached) == "Hero" then return "Hero" end
            return "Sheriff"
        end
        for _, key in ipairs({pl, pl.Name, pl.UserId}) do
            local data = playerData[key]
            if data ~= nil then
                if type(data) == "table" then
                    local role = readRoleFromTable(data); if role then return role end
                else
                    local role = normalizeRoleName(data); if role then return role end
                end
            end
        end
        for key, data in pairs(playerData) do
            local target = nil
            if typeof(key) == "Instance" and key:IsA("Player") then target = key
            elseif type(key) == "string" then target = Players:FindFirstChild(key) end
            if type(data) == "table" then
                local p = data.Player or data.player or data.PlayerName or data.playerName or data.Name or data.name
                if typeof(p) == "Instance" and p:IsA("Player") then target = p
                elseif type(p) == "string" then target = Players:FindFirstChild(p) end
            end
            if target == pl then
                if type(data) == "table" then
                    local role = readRoleFromTable(data); if role then return role end
                else
                    local role = normalizeRoleName(data); if role then return role end
                end
            end
        end
        return "Innocent"
    end

    local function isGoodGuy(pl)
        local r = getPlayerRole(pl)
        return r == "Sheriff" or r == "Hero"
    end
    local function findMurderer()
        for _, pl in ipairs(Players:GetPlayers()) do
            if getPlayerRole(pl) == "Murderer" then return pl end
        end
        return nil
    end
    local function findSheriff()
        for _, pl in ipairs(Players:GetPlayers()) do
            if isGoodGuy(pl) then return pl end
        end
        return nil
    end
    local function findSheriffThatsNotMe()
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= localplayer and isGoodGuy(pl) then return pl end
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
        local nearestPlayer = nil; local shortestDistance = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localplayer and p.Character then
                local lrp = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
                local orp = p.Character:FindFirstChild("HumanoidRootPart")
                if lrp and orp then
                    local d = (lrp.Position - orp.Position).Magnitude
                    if d < shortestDistance then shortestDistance = d; nearestPlayer = p end
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
        local moveDir = playerHum.MoveDirection
        local predicted = playerHRP.Position + ((velocity * Vector3.new(0.75, 0.5, 0.75))) * (shootOffset / 15) + moveDir * shootOffset
        local ping = 0
        pcall(function() ping = localplayer:GetNetworkPing() * 1000 end)
        predicted = predicted * ((ping * ((offsetToPingMult - 1) * 0.01)) + 1)
        return predicted
    end

    function miniFling(playerToFling)
        local Character = player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Humanoid and Humanoid.RootPart
        local TCharacter = playerToFling and playerToFling.Character
        if not TCharacter then notify(HUB_NAME, "Нет цели."); return end
        local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
        local TRootPart = THumanoid and THumanoid.RootPart
        local THead = TCharacter:FindFirstChild("Head")
        local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
        local Handle = Accessory and Accessory:FindFirstChild("Handle")
        if not (Character and Humanoid and RootPart) then notify(HUB_NAME, "Нет персонажа."); return end
        pcall(function() Character.PrimaryPart = RootPart end)
        if RootPart.Velocity.Magnitude < 50 then xdG.OldPos = RootPart.CFrame end
        local function setCam(s) pcall(function() workspace.CurrentCamera.CameraSubject = s end) end
        if THead then setCam(THead) elseif Handle then setCam(Handle) elseif THumanoid then setCam(THumanoid) end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then notify(HUB_NAME, "Не за что флингануть."); return end
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            pcall(function() Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang) end)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        local SFBasePart = function(BasePart)
            local Time = tick(); local Angle = 0
            repeat
                if RootPart and THumanoid then
                    local trVel = (TRootPart and TRootPart.Velocity.Magnitude) or BasePart.Velocity.Magnitude
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); xdWait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); xdWait()
                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); xdWait()
                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); xdWait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)); xdWait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)); xdWait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); xdWait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0)); xdWait()
                        FPos(BasePart, CFrame.new(0, 1.5, trVel / 1.25), CFrame.Angles(math.rad(90), 0, 0)); xdWait()
                        FPos(BasePart, CFrame.new(0, -1.5, -trVel / 1.25), CFrame.Angles(0, 0, 0)); xdWait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0)); xdWait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)); xdWait()
                    end
                else break end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= playerToFling.Character or playerToFling.Parent ~= Players or (THumanoid and THumanoid.Sit) or Humanoid.Health <= 0 or tick() > Time + 2
        end
        local oldFPDH
        pcall(function() oldFPDH = workspace.FallenPartsDestroyHeight; workspace.FallenPartsDestroyHeight = -1e6 end)
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart; BV.Velocity = Vector3.new(9e8, 9e8, 9e8); BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then SFBasePart(THead) else SFBasePart(TRootPart) end
        elseif TRootPart then SFBasePart(TRootPart)
        elseif THead then SFBasePart(THead)
        elseif Handle then SFBasePart(Handle)
        else notify(HUB_NAME, "Не за что флингануть.") end
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        setCam(Humanoid)
        local oldPos = xdG.OldPos or RootPart.CFrame
        local returnTime = tick() + 3
        repeat
            RootPart.CFrame = oldPos * CFrame.new(0, 0.5, 0)
            pcall(function() Character:SetPrimaryPartCFrame(oldPos * CFrame.new(0, 0.5, 0)) end)
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            for _, x in ipairs(Character:GetChildren()) do
                if x:IsA("BasePart") then x.Velocity = Vector3.new(); x.RotVelocity = Vector3.new() end
            end
            xdWait()
        until (RootPart.Position - oldPos.p).Magnitude < 25 or Humanoid.Health <= 0 or tick() > returnTime
        pcall(function() workspace.FallenPartsDestroyHeight = oldFPDH or -500 end)
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
            for k, v in pairs(props) do if k ~= "Parent" then obj[k] = v end end
            return obj
        end)
        if ok and h then return h end
        highlightSupported = false
        return nil
    end
    local function clearPlayerHighlight(pl)
        if espObjects[pl] then pcall(function() espObjects[pl]:Destroy() end); espObjects[pl] = nil end
    end
    refreshESP = function()
        if not playerESP then
            for _, h in pairs(espObjects) do pcall(function() h:Destroy() end) end
            espObjects = {}; return
        end
        if not highlightSupported then return end
        if not highlightParent then highlightParent = player:FindFirstChild("PlayerGui") end
        if not highlightParent then return end
        local alive = {}
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= localplayer or not hideMeEsp then
                local char = pl.Character
                if char and char.Parent then
                    alive[pl] = true
                    local h = espObjects[pl]
                    if not h or not h.Parent then
                        h = newHighlight({FillTransparency = 0.5, OutlineTransparency = 0, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop})
                        if not h then return end
                        pcall(function() h.Parent = highlightParent end)
                        espObjects[pl] = h
                    end
                    h.Adornee = char
                    local role = getPlayerRole(pl); local color
                    if role == "Murderer" then color = Color3.fromRGB(255, 0, 4)
                    elseif role == "Sheriff" then color = Color3.fromRGB(0, 153, 255)
                    elseif role == "Hero" then color = Color3.fromRGB(255, 200, 0)
                    else color = Color3.fromRGB(0, 255, 8) end
                    h.FillColor = color; h.OutlineColor = color
                else clearPlayerHighlight(pl) end
            else clearPlayerHighlight(pl) end
        end
        for pl in pairs(espObjects) do if not alive[pl] then clearPlayerHighlight(pl) end end
    end
    local function ensureEspWatcher()
        if espWatcherRunning then return end
        espWatcherRunning = true
        xdSpawn(function()
            while playerESP do pcall(refreshESP); xdWait(0.8) end
            espWatcherRunning = false
        end)
    end
    onRolesChanged = function()
        xdSpawn(function()
            if playerESP then pcall(refreshESP) end
            if updateRoleUI then pcall(updateRoleUI) end
        end)
    end
    local function reloadTrapESP()
        for _, h in pairs(trapHighlights) do pcall(function() h:Destroy() end) end
        trapHighlights = {}
        if not trapDetection or not highlightSupported then return end
        if not highlightParent then highlightParent = player:FindFirstChild("PlayerGui") end
        if not highlightParent then return end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "Trap" and v.Parent and (v.Parent:IsA("Folder") or v.Parent:IsA("Model")) then
                local h = newHighlight({FillColor = Color3.fromRGB(255,0,0), OutlineColor = Color3.fromRGB(255,0,0), FillTransparency = 0.5, OutlineTransparency = 0, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Adornee = v})
                if h then pcall(function() h.Parent = highlightParent end); trapHighlights[v] = h end
                if v:IsA("BasePart") then v.Transparency = 0 end
            end
        end
    end
    local function reloadGunESP()
        if gunHighlight then pcall(function() gunHighlight:Destroy() end); gunHighlight = nil end
        if not gunDropESP or not highlightSupported then return end
        if not highlightParent then highlightParent = player:FindFirstChild("PlayerGui") end
        if not highlightParent then return end
        local map = getMap()
        if map and map:FindFirstChild("GunDrop") then
            gunHighlight = newHighlight({FillColor = Color3.fromRGB(255,255,0), OutlineColor = Color3.fromRGB(255,255,0), FillTransparency = 0.5, OutlineTransparency = 0, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Adornee = map:FindFirstChild("GunDrop")})
            if gunHighlight then pcall(function() gunHighlight.Parent = highlightParent end) end
        end
    end

    function shootMurderer()
        if findSheriff() ~= localplayer then notify(HUB_NAME, "Ты не шериф и не герой."); return end
        local murderer = findMurderer() or findSheriffThatsNotMe()
        if not murderer or not murderer.Character then notify(HUB_NAME, "Нет убийцы для выстрела."); return end
        if not localplayer.Character:FindFirstChild("Gun") then
            local hum = localplayer.Character:FindFirstChild("Humanoid")
            local bpGun = localplayer.Backpack and localplayer.Backpack:FindFirstChild("Gun")
            if hum and bpGun then hum:EquipTool(bpGun); xdWait(0.15) end
        end
        local gun = localplayer.Character and localplayer.Character:FindFirstChild("Gun")
        if not gun then notify(HUB_NAME, "У тебя нет пистолета."); return end
        if not (murderer.Character:FindFirstChild("Head") or murderer.Character:FindFirstChild("HumanoidRootPart")) then
            notify(HUB_NAME, "Не найдена цель."); return
        end
        xdSpawn(function()
            for shot = 1, 3 do
                local murdererHRP = murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
                if not murdererHRP then break end
                local predicted = getPredictedPosition(murderer)
                local aimPoint = instakillshoot and (murdererHRP.Position + Vector3.new(0, 1, 0)) or predicted
                local rightHand = localplayer.Character:FindFirstChild("RightHand")
                local origin = rightHand and rightHand.Position or localplayer.Character:GetPivot().Position
                pcall(function() gun:WaitForChild("Shoot"):FireServer(CFrame.new(origin), CFrame.new(aimPoint)) end)
                xdWait(0.12)
            end
            notify(HUB_NAME, "Очередь по убийце!")
        end)
    end
    function knifeThrow()
        if findMurderer() ~= localplayer then notify(HUB_NAME, "Ты не убийца."); return end
        if not localplayer.Character:FindFirstChild("Knife") then
            local hum = localplayer.Character:FindFirstChild("Humanoid")
            if localplayer.Backpack:FindFirstChild("Knife") then hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
            else notify(HUB_NAME, "У тебя нет ножа."); return end
        end
        local Nearest = findNearestPlayer()
        if not Nearest or not Nearest.Character then notify(HUB_NAME, "Не найден игрок."); return end
        local nearestHRP = Nearest.Character:FindFirstChild("HumanoidRootPart")
        if not nearestHRP then return end
        local rightHand = localplayer.Character:FindFirstChild("RightHand")
        local origin = rightHand and rightHand.Position or localplayer.Character:GetPivot().Position
        local args = {CFrame.new(origin), CFrame.new(getPredictedPosition(Nearest))}
        if spawnAtPlayer then args[1] = CFrame.new(nearestHRP.Position + (nearestHRP.CFrame.LookVector * 5)) end
        pcall(function() localplayer.Character:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(unpack(args)) end)
        notify(HUB_NAME, "Нож брошен!")
    end
    function killClosest()
        if findMurderer() ~= localplayer then notify(HUB_NAME, "Ты не убийца."); return end
        if not localplayer.Character:FindFirstChild("Knife") then
            local hum = localplayer.Character:FindFirstChild("Humanoid")
            if localplayer.Backpack:FindFirstChild("Knife") then hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
            else notify(HUB_NAME, "У тебя нет ножа."); return end
        end
        local Nearest = findNearestPlayer()
        if not Nearest or not Nearest.Character then notify(HUB_NAME, "Не найден игрок."); return end
        local nearestHRP = Nearest.Character:FindFirstChild("HumanoidRootPart")
        local myHRP = localplayer.Character:FindFirstChild("HumanoidRootPart")
        if not nearestHRP or not myHRP then return end
        nearestHRP.Anchored = true
        nearestHRP.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 2
        xdWait(0.1)
        pcall(function() localplayer.Character:WaitForChild("Knife"):WaitForChild("Stab"):FireServer("Slash") end)
        notify(HUB_NAME, "Убил ближайшего!")
    end
    function killEveryone()
        if findMurderer() ~= localplayer then notify(HUB_NAME, "Ты не убийца."); return end
        if not localplayer.Character:FindFirstChild("Knife") then
            local hum = localplayer.Character:FindFirstChild("Humanoid")
            if localplayer.Backpack:FindFirstChild("Knife") then hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
            else notify(HUB_NAME, "У тебя нет ножа."); return end
        end
        local myHRP = localplayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Anchored = true
                p.Character.HumanoidRootPart.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 1
            end
        end
        pcall(function() localplayer.Character:WaitForChild("Knife"):WaitForChild("Stab"):FireServer("Slash") end)
        notify(HUB_NAME, "Убил всех!")
    end
    function holdHostage()
        if findMurderer() ~= localplayer then notify(HUB_NAME, "Ты не убийца."); return end
        local myHRP = localplayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Anchored = true
                p.Character.HumanoidRootPart.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 5
            end
        end
        notify(HUB_NAME, "Все взяты в заложники!")
    end
    function godMode()
        local Cam = workspace.CurrentCamera
        local Pos, Char = Cam.CFrame, localplayer.Character
        local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
        if not Human then notify(HUB_NAME, "Нет гуманоида."); return end
        local nHuman = Human:Clone(); nHuman.Parent = Char
        localplayer.Character = nil
        nHuman:SetStateEnabled(15, false); nHuman:SetStateEnabled(1, false); nHuman:SetStateEnabled(0, false)
        nHuman.BreakJointsOnDeath = true
        Human:Destroy()
        localplayer.Character = Char
        Cam.CameraSubject = nHuman; Cam.CFrame = Pos
        nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        local Script = Char:FindFirstChild("Animate")
        if Script then Script.Disabled = true; xdWait(); Script.Disabled = false end
        nHuman.Health = nHuman.MaxHealth
        notify(HUB_NAME, "God mode активирован!")
    end
    function teleportToGun()
        local map = getMap()
        if not map or not map:FindFirstChild("GunDrop") then notify(HUB_NAME, "Нет выпавшего пистолета."); return end
        local prev = localplayer.Character:GetPivot()
        localplayer.Character:PivotTo(map:FindFirstChild("GunDrop"):GetPivot())
        localplayer.Backpack.ChildAdded:Wait()
        localplayer.Character:PivotTo(prev)
        notify(HUB_NAME, "Пистолет подобран!")
    end
    function teleportToLobby()
        local lobby = workspace:FindFirstChild("Lobby")
        if lobby and lobby:FindFirstChild("Spawns") then
            local spawn = lobby.Spawns:FindFirstChildWhichIsA("SpawnLocation")
            if spawn then localplayer.Character:MoveTo(spawn.Position); notify(HUB_NAME, "Телепорт в лобби!") end
        end
    end
    function teleportToMap()
        local map = getMap()
        if not map then notify(HUB_NAME, "Нет карты для телепорта."); return end
        local spawnsFolder = map:FindFirstChild("Spawns")
        if spawnsFolder then
            local spawns = spawnsFolder:GetChildren()
            if #spawns > 0 then
                localplayer.Character:MoveTo(spawns[math.random(1, #spawns)].Position)
                notify(HUB_NAME, "Телепорт на карту!")
            end
        end
    end
    function sendNamesToChat()
        local murd = findMurderer(); local sher = findSheriff()
        local message = string.format("Murderer: %s | Sheriff: %s | <<%s>>", murd and murd.Name or "-", sher and sher.Name or "-", HUB_NAME)
        pcall(function()
            local channels = TextChatService:FindFirstChild("TextChannels")
            if channels then
                for _, tc in ipairs(channels:GetChildren()) do
                    if tc.Name ~= "RBXSystem" then pcall(function() tc:SendAsync(message) end) end
                end
            end
        end)
        notify(HUB_NAME, "Имена отправлены в чат!")
    end
    function copyMurdererName()
        local murd = findMurderer()
        if not murd then notify(HUB_NAME, "Нет убийцы."); return end
        if setclipboard then setclipboard(murd.Name); notify(HUB_NAME, "Скопировано: " .. murd.Name) end
    end
    function copySheriffName()
        local sher = findSheriff()
        if not sher then notify(HUB_NAME, "Нет шерифа."); return end
        if setclipboard then setclipboard(sher.Name); notify(HUB_NAME, "Скопировано: " .. sher.Name) end
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
                            if hum and bp then hum:EquipTool(bp) end
                        end
                        local gun = localplayer.Character:FindFirstChild("Gun")
                        local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
                        if gun and murdererHRP then
                            local predicted = getPredictedPosition(murderer)
                            local rightHand = localplayer.Character:FindFirstChild("RightHand")
                            local origin = rightHand and rightHand.Position or localplayer.Character:GetPivot().Position
                            gun:WaitForChild("Shoot"):FireServer(CFrame.new(origin), CFrame.new(predicted))
                        end
                    end
                end)
            end
        end
    end)

    xdSpawn(function()
        while xdWait(1.5) do if loopThrow then pcall(function() knifeThrow() end) end end
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
                                pcall(function() localplayer.Character:WaitForChild("Knife"):WaitForChild("Stab"):FireServer("Slash") end)
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
                if ch:IsA("BasePart") then ch.Transparency = 0 end
                reloadTrapESP(); notify(HUB_NAME, "Убийца поставил ловушку!")
            end
            if gunDropESP and ch.Name == "GunDrop" then
                reloadGunESP(); notify(HUB_NAME, "Пистолет выпал!")
                if autoGetDroppedGun then
                    xdWait(1)
                    local map = getMap()
                    if not map or not map:FindFirstChild("GunDrop") then return end
                    local prev = localplayer.Character:GetPivot()
                    localplayer.Character:MoveTo(map:FindFirstChild("GunDrop").Position)
                    localplayer.Backpack.ChildAdded:Wait()
                    localplayer.Character:PivotTo(prev)
                end
            end
        end)
    end)
    workspace.DescendantRemoving:Connect(function(ch)
        pcall(function()
            if gunDropESP and ch.Name == "GunDrop" then reloadGunESP() end
            if trapDetection and ch.Name == "Trap" then reloadTrapESP() end
        end)
    end)
    workspace.ChildAdded:Connect(function(chi)
        if chi.Name == "ThrowingKnife" and ignoreknifethrow then chi:Destroy() end
    end)

    local function applyRolePayload(payload, sourceName)
        local changed = false
        local function setRole(pl, raw)
            local role = normalizeRoleName(raw)
            if pl and role then
                playerData[pl] = role; playerData[pl.Name] = role; playerData[pl.UserId] = role; changed = true
            end
        end
        if type(payload) == "table" then
            local explicit = readRoleFromTable(payload)
            if explicit then setRole(localplayer, explicit) end
            for k, v in pairs(payload) do
                local target = nil
                if typeof(k) == "Instance" and k:IsA("Player") then target = k
                elseif type(k) == "string" then target = Players:FindFirstChild(k) end
                if target then
                    if type(v) == "table" then setRole(target, readRoleFromTable(v)) else setRole(target, v) end
                elseif type(v) == "table" then
                    local p = v.Player or v.player or v.PlayerName or v.playerName or v.Name or v.name
                    if typeof(p) == "Instance" and p:IsA("Player") then target = p
                    elseif type(p) == "string" then target = Players:FindFirstChild(p) end
                    if target then setRole(target, readRoleFromTable(v)) end
                end
            end
        elseif type(payload) == "string" or type(payload) == "number" then
            local rn = tostring(sourceName or ""):lower()
            if rn:find("role") or rn:find("playerdata") or rn:find("gamedata") or rn:find("game") then
                setRole(localplayer, payload)
            end
        end
        if changed and onRolesChanged then onRolesChanged() end
    end

    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local gameplay = remotes:FindFirstChild("Gameplay")
            if gameplay then
                local pd = gameplay:FindFirstChild("PlayerDataChanged")
                if pd and pd:IsA("RemoteEvent") then
                    pd.OnClientEvent:Connect(function(...)
                        for _, arg in ipairs({...}) do applyRolePayload(arg, "PlayerDataChanged") end
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
                        for _, arg in ipairs({...}) do applyRolePayload(arg, inst.Name) end
                    end)
                end)
            end
        end
        for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do hookRemote(inst) end
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
                    if onRolesChanged then onRolesChanged() end
                    pcall(function()
                        char.ChildAdded:Connect(function() xdWait(0.05); if onRolesChanged then onRolesChanged() end end)
                        char.ChildRemoved:Connect(function() xdWait(0.05); if onRolesChanged then onRolesChanged() end end)
                    end)
                end)
            end)
            pcall(function()
                if pl.Backpack then
                    pl.Backpack.ChildAdded:Connect(function() if onRolesChanged then onRolesChanged() end end)
                    pl.Backpack.ChildRemoved:Connect(function() if onRolesChanged then onRolesChanged() end end)
                end
            end)
        end
        for _, pl in ipairs(Players:GetPlayers()) do hookPlayerRoleEvents(pl) end
        Players.PlayerAdded:Connect(hookPlayerRoleEvents)
        Players.PlayerRemoving:Connect(function(pl)
            hookedPlayers[pl] = nil
            playerData[pl] = nil; playerData[pl.Name] = nil; playerData[pl.UserId] = nil
            if clearPlayerHighlight then clearPlayerHighlight(pl) end
        end)
    end)

    local visualState = {wings=true, circle=true, halo=true, aura=false, fire=false, smoke=false, trails=false, eyes=false, light=false, lightning=false}
    local visualObjects = {}
    local wingFeathers = {}
    local wingMembranes = {}
    local wingSpine = nil
    local wingSpineGlow = nil
    local circleGlow = nil
    local circleInnerDisc = nil
    local circleCore = nil
    local circleCoreGlow = nil
    local circleOuterSegs = {}
    local circleMiddleSegs = {}
    local circleRunes = {}
    local circleOrbs = {}
    local circlePillars = {}
    local gyroRing1 = {}
    local gyroRing2 = {}
    local circleColumn = nil
    local circleColumnInner = nil
    local circleLight = nil
    local haloDisc = nil
    local haloDiscGlow = nil
    local haloMotes = {}
    local eyeParts = {}

    local function registerVisual(name, obj)
        visualObjects[name] = visualObjects[name] or {}
        table.insert(visualObjects[name], obj)
    end
    local function clearVisual(name)
        if visualObjects[name] then
            for _, obj in ipairs(visualObjects[name]) do pcall(function() obj:Destroy() end) end
            visualObjects[name] = nil
        end
        if name == "wings" then wingFeathers = {}; wingMembranes = {}; wingSpine = nil; wingSpineGlow = nil end
        if name == "circle" then
            circleGlow = nil; circleInnerDisc = nil; circleCore = nil; circleCoreGlow = nil
            circleOuterSegs = {}; circleMiddleSegs = {}; circleRunes = {}
            circleOrbs = {}; circlePillars = {}
            gyroRing1 = {}; gyroRing2 = {}
            circleColumn = nil; circleColumnInner = nil; circleLight = nil
        end
        if name == "halo" then haloDisc = nil; haloDiscGlow = nil; haloMotes = {} end
        if name == "eyes" then eyeParts = {} end
    end
    local function clearAllVisuals()
        local names = {}
        for name in pairs(visualObjects) do table.insert(names, name) end
        for _, name in ipairs(names) do clearVisual(name) end
    end
    local function makeNeonPart(props)
        local p = Instance.new("Part")
        p.Material = Enum.Material.Neon
        p.Anchored = true; p.CanCollide = false; p.CastShadow = false
        p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
        for k, v in pairs(props) do p[k] = v end
        return p
    end
    local function makeSmoothPart(props, meshScale)
        local p = Instance.new("Part")
        p.Material = Enum.Material.Neon
        p.Anchored = true; p.CanCollide = false; p.CastShadow = false
        p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
        for k, v in pairs(props) do p[k] = v end
        p.Size = Vector3.new(1, 1, 1)
        pcall(function()
            local m = Instance.new("SpecialMesh")
            m.MeshType = Enum.MeshType.Sphere
            m.Scale = meshScale
            m.Parent = p
        end)
        return p
    end
    local function glowClone(src, extraScale, transp, color)
        local g = nil
        pcall(function()
            g = src:Clone(); g.Name = src.Name .. "_glow"; g.Transparency = transp or 0.6
            if color then g.Color = color end
            if g:FindFirstChildOfClass("SpecialMesh") then
                local m0 = src:FindFirstChildOfClass("SpecialMesh")
                g:FindFirstChildOfClass("SpecialMesh").Scale = m0.Scale * (extraScale or 1.6)
            else
                g.Size = src.Size * (extraScale or 1.6)
            end
            g.Parent = src.Parent
        end)
        return g
    end

    local function applyWings()
        clearVisual("wings")
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local darkRed = Color3.fromRGB(165, 10, 30)
        local midRed = Color3.fromRGB(255, 70, 90)
        local emberC = Color3.fromRGB(255, 130, 95)
        local lightCore = Color3.fromRGB(255, 205, 205)
        local glowC = Color3.fromRGB(255, 40, 55)
        for side = -1, 1, 2 do
            local membrane = makeSmoothPart({Name="XDarkMembrane", Color=Color3.fromRGB(140, 10, 28), Transparency=0.55, Parent=char}, Vector3.new(0.22, 3.6, 3.0))
            local membraneGlow = glowClone(membrane, 1.5, 0.78, glowC)
            registerVisual("wings", membrane); if membraneGlow then registerVisual("wings", membraneGlow) end
            table.insert(wingMembranes, {part=membrane, glow=membraneGlow, side=side})
            for i = 1, 9 do
                local t = i / 9
                local len1 = 2.4 - t * 1.0
                local len2 = 1.8 - t * 0.8
                local width = 1.15 - t * 0.5
                local base = makeSmoothPart({Name="XDarkPrimB", Color=darkRed:lerp(midRed, t*0.5), Transparency=0.02, Parent=char}, Vector3.new(0.42, len1, width))
                local baseGlow = glowClone(base, 1.55, 0.62, glowC)
                local tip = makeSmoothPart({Name="XDarkPrimT", Color=midRed:lerp(lightCore, t*t), Transparency=0.0, Parent=char}, Vector3.new(0.36, len2, width*0.7))
                registerVisual("wings", base); if baseGlow then registerVisual("wings", baseGlow) end; registerVisual("wings", tip)
                table.insert(wingFeathers, {base=base, glow=baseGlow, tip=tip, len1=len1, len2=len2, side=side, i=i, layer="prim", curve=0.18 + t*0.24})
            end
            for i = 1, 6 do
                local t = i / 6
                local len1 = 1.6 - t * 0.5
                local len2 = 1.0 - t * 0.3
                local base = makeSmoothPart({Name="XDarkSecB", Color=midRed:lerp(emberC, t*0.5), Transparency=0.04, Parent=char}, Vector3.new(0.36, len1, 0.75 - t*0.2))
                local tip = makeSmoothPart({Name="XDarkSecT", Color=emberC:lerp(lightCore, t*0.6), Transparency=0.04, Parent=char}, Vector3.new(0.3, len2, 0.58 - t*0.15))
                registerVisual("wings", base); registerVisual("wings", tip)
                table.insert(wingFeathers, {base=base, tip=tip, len1=len1, len2=len2, side=side, i=i, layer="sec", curve=0.12})
            end
            for i = 1, 4 do
                local cov = makeSmoothPart({Name="XDarkCovert", Color=lightCore, Transparency=0.05, Parent=char}, Vector3.new(0.32, 0.75 - i*0.1, 0.5))
                registerVisual("wings", cov)
                table.insert(wingFeathers, {base=cov, tip=nil, len1=0.75 - i*0.1, len2=0, side=side, i=i, layer="cov", curve=0})
            end
        end
        wingSpine = makeSmoothPart({Name="XDarkSpine", Color=Color3.fromRGB(255, 90, 105), Transparency=0.03, Parent=char}, Vector3.new(0.42, 2.0, 0.42))
        wingSpineGlow = glowClone(wingSpine, 1.5, 0.6, glowC)
        registerVisual("wings", wingSpine); if wingSpineGlow then registerVisual("wings", wingSpineGlow) end
        local att = Instance.new("Attachment", hrp); att.Position = Vector3.new(0, 1.2, 1)
        registerVisual("wings", att)
        local em = Instance.new("ParticleEmitter", att)
        em.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        em.Color = ColorSequence.new(Color3.fromRGB(255, 150, 150), Color3.fromRGB(255, 60, 70))
        em.Rate = 50; em.Lifetime = NumberRange.new(0.6, 1.3); em.Speed = NumberRange.new(1, 3.5)
        em.SpreadAngle = Vector2.new(180, 180); em.LightEmission = 1
        em.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.36), NumberSequenceKeypoint.new(1, 0)})
        registerVisual("wings", em)
        local wingLight = Instance.new("PointLight")
        wingLight.Color = Color3.fromRGB(255, 70, 85); wingLight.Brightness = 3.0; wingLight.Range = 24
        wingLight.Parent = hrp
        registerVisual("wings", wingLight)
    end

    local function applyCircle()
        clearVisual("circle")
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        circleGlow = makeNeonPart({Name="XDarkGlow", Shape=Enum.PartType.Cylinder, Size=Vector3.new(0.15, 11, 11), Color=Color3.fromRGB(180, 15, 35), Transparency=0.74, Parent=char})
        registerVisual("circle", circleGlow)
        circleInnerDisc = makeNeonPart({Name="XDarkInner", Shape=Enum.PartType.Cylinder, Size=Vector3.new(0.16, 4.4, 4.4), Color=Color3.fromRGB(255, 80, 95), Transparency=0.45, Parent=char})
        registerVisual("circle", circleInnerDisc)
        circleCore = makeNeonPart({Name="XDarkCore", Shape=Enum.PartType.Cylinder, Size=Vector3.new(0.18, 2.0, 2.0), Color=Color3.fromRGB(255, 200, 150), Transparency=0.2, Parent=char})
        registerVisual("circle", circleCore)
        circleCoreGlow = glowClone(circleCore, 1.8, 0.5, Color3.fromRGB(255, 40, 55))
        if circleCoreGlow then registerVisual("circle", circleCoreGlow) end
        for k = 1, 16 do
            local seg = makeNeonPart({Name="XDarkOutSeg", Size=Vector3.new(1.5, 0.12, 0.28), Color=Color3.fromRGB(255, 50, 70), Transparency=0.1, Parent=char})
            registerVisual("circle", seg)
            table.insert(circleOuterSegs, {part=seg, k=k})
        end
        for k = 1, 12 do
            local seg = makeNeonPart({Name="XDarkMidSeg", Size=Vector3.new(1.3, 0.12, 0.24), Color=Color3.fromRGB(255, 130, 90), Transparency=0.15, Parent=char})
            registerVisual("circle", seg)
            table.insert(circleMiddleSegs, {part=seg, k=k})
        end
        for k = 1, 8 do
            local rune = makeNeonPart({Name="XDarkRune", Size=Vector3.new(0.5, 0.5, 0.12), Color=Color3.fromRGB(255, 210, 130), Transparency=0.08, Parent=char})
            registerVisual("circle", rune)
            table.insert(circleRunes, {part=rune, k=k})
        end
        for k = 1, 8 do
            local orb = makeNeonPart({Name="XDarkOrb", Shape=Enum.PartType.Ball, Size=Vector3.new(0.34, 0.34, 0.34), Color=(k%2==0) and Color3.fromRGB(255,190,110) or Color3.fromRGB(255,70,90), Transparency=0.05, Parent=char})
            registerVisual("circle", orb)
            table.insert(circleOrbs, {part=orb, k=k})
        end
        for k = 1, 6 do
            local pillar = makeNeonPart({Name="XDarkPillar", Size=Vector3.new(0.18, 7, 0.18), Color=Color3.fromRGB(255, 70, 90), Transparency=0.5, Parent=char})
            registerVisual("circle", pillar)
            table.insert(circlePillars, {part=pillar, k=k})
        end
        for k = 1, 14 do
            local orb = makeNeonPart({Name="XDarkGyro1", Shape=Enum.PartType.Ball, Size=Vector3.new(0.22, 0.22, 0.22), Color=Color3.fromRGB(255, 110, 120), Transparency=0.08, Parent=char})
            registerVisual("circle", orb)
            table.insert(gyroRing1, {part=orb, k=k})
        end
        for k = 1, 14 do
            local orb = makeNeonPart({Name="XDarkGyro2", Shape=Enum.PartType.Ball, Size=Vector3.new(0.18, 0.18, 0.18), Color=Color3.fromRGB(255, 190, 110), Transparency=0.1, Parent=char})
            registerVisual("circle", orb)
            table.insert(gyroRing2, {part=orb, k=k})
        end
        circleColumn = makeNeonPart({Name="XDarkColumn", Shape=Enum.PartType.Cylinder, Size=Vector3.new(8, 0.9, 0.9), Color=Color3.fromRGB(255, 70, 90), Transparency=0.62, Parent=char})
        registerVisual("circle", circleColumn)
        circleColumnInner = makeNeonPart({Name="XDarkColumnIn", Shape=Enum.PartType.Cylinder, Size=Vector3.new(8, 0.35, 0.35), Color=Color3.fromRGB(255, 200, 130), Transparency=0.35, Parent=char})
        registerVisual("circle", circleColumnInner)
        local att = Instance.new("Attachment", hrp); att.Position = Vector3.new(0, -3, 0)
        registerVisual("circle", att)
        local em = Instance.new("ParticleEmitter", att)
        em.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        em.Color = ColorSequence.new(Color3.fromRGB(255, 70, 85), Color3.fromRGB(255, 180, 110))
        em.Rate = 65; em.Lifetime = NumberRange.new(0.9, 1.6); em.Speed = NumberRange.new(3, 6)
        em.SpreadAngle = Vector2.new(180, 180); em.LightEmission = 1
        em.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.38), NumberSequenceKeypoint.new(1, 0)})
        em.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
        registerVisual("circle", em)
        circleLight = Instance.new("PointLight")
        circleLight.Color = Color3.fromRGB(255, 55, 70); circleLight.Brightness = 2.8; circleLight.Range = 24
        circleLight.Parent = hrp
        registerVisual("circle", circleLight)
    end

    local function applyHalo()
        clearVisual("halo")
        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        if not head then return end
        haloDisc = makeNeonPart({Name="XDarkHalo", Shape=Enum.PartType.Cylinder, Size=Vector3.new(0.14, 2.6, 2.6), Color=Color3.fromRGB(255, 200, 200), Transparency=0.08, Parent=char})
        registerVisual("halo", haloDisc)
        haloDiscGlow = glowClone(haloDisc, 1.7, 0.55, Color3.fromRGB(255, 40, 55))
        if haloDiscGlow then registerVisual("halo", haloDiscGlow) end
        for k = 1, 6 do
            local mote = makeNeonPart({Name="XDarkHaloMote", Shape=Enum.PartType.Ball, Size=Vector3.new(0.2, 0.2, 0.2), Color=Color3.fromRGB(255, 150, 120), Transparency=0.08, Parent=char})
            registerVisual("halo", mote)
            table.insert(haloMotes, {part=mote, k=k})
        end
        local hl = Instance.new("PointLight")
        hl.Color = Color3.fromRGB(255, 70, 85); hl.Brightness = 2.4; hl.Range = 13
        hl.Parent = head
        registerVisual("halo", hl)
    end

    local function applyEmitter(name, texture, c1, c2, rate, speed, spread, sizeStart, attPos, emissionDir)
        clearVisual(name)
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local att = Instance.new("Attachment", hrp); att.Position = attPos or Vector3.new(0, 0, 0)
        registerVisual(name, att)
        local em = Instance.new("ParticleEmitter", att)
        em.Texture = texture; em.Color = ColorSequence.new(c1, c2)
        em.Rate = rate; em.Lifetime = NumberRange.new(0.6, 1.2)
        em.Speed = NumberRange.new(speed * 0.6, speed); em.SpreadAngle = Vector2.new(spread, spread)
        em.LightEmission = 1
        if emissionDir then em.EmissionDirection = emissionDir end
        em.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, sizeStart), NumberSequenceKeypoint.new(1, 0)})
        em.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
        registerVisual(name, em)
    end

    local function applyTrails()
        clearVisual("trails")
        local char = player.Character
        if not char then return end
        for _, hn in ipairs({"LeftHand", "RightHand", "Left Arm", "Right Arm"}) do
            local hand = char:FindFirstChild(hn)
            if hand then
                local a0 = Instance.new("Attachment", hand); a0.Position = Vector3.new(0, 0.35, 0)
                local a1 = Instance.new("Attachment", hand); a1.Position = Vector3.new(0, -0.35, 0)
                local trail = Instance.new("Trail", hand)
                trail.Attachment0 = a0; trail.Attachment1 = a1
                trail.Color = ColorSequence.new(Color3.fromRGB(255, 60, 75), Color3.fromRGB(255, 150, 90))
                trail.Lifetime = 0.45; trail.LightEmission = 1; trail.LightInfluence = 0
                trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 1)})
                registerVisual("trails", a0); registerVisual("trails", a1); registerVisual("trails", trail)
            end
        end
    end

    local function applyEyes()
        clearVisual("eyes")
        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        if not head then return end
        for side = -1, 1, 2 do
            local eye = makeNeonPart({Name="XDarkEye", Size=Vector3.new(0.12, 0.14, 0.14), Color=Color3.fromRGB(255, 30, 50), Transparency=0, Parent=char})
            registerVisual("eyes", eye)
            table.insert(eyeParts, {part=eye, side=side})
        end
        local el = Instance.new("PointLight")
        el.Color = Color3.fromRGB(255, 35, 55); el.Brightness = 0.9; el.Range = 7
        el.Parent = head
        registerVisual("eyes", el)
    end

    local function applyLight()
        clearVisual("light")
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local l = Instance.new("PointLight")
        l.Color = Color3.fromRGB(255, 40, 60); l.Brightness = 2.2; l.Range = 20
        l.Parent = hrp
        registerVisual("light", l)
    end

    local function applyLightning()
        clearVisual("lightning")
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local att = Instance.new("Attachment", hrp)
        registerVisual("lightning", att)
        local em = Instance.new("ParticleEmitter", att)
        em.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        em.Color = ColorSequence.new(Color3.fromRGB(255, 220, 180), Color3.fromRGB(255, 60, 60))
        em.Rate = 70; em.Lifetime = NumberRange.new(0.08, 0.25); em.Speed = NumberRange.new(8, 15)
        em.SpreadAngle = Vector2.new(180, 180); em.LightEmission = 1
        em.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.22), NumberSequenceKeypoint.new(1, 0)})
        registerVisual("lightning", em)
    end

    local function applyVisual(name)
        if name == "wings" then applyWings()
        elseif name == "circle" then applyCircle()
        elseif name == "halo" then applyHalo()
        elseif name == "aura" then applyEmitter("aura", "rbxasset://textures/particles/sparkles_main.dds", Color3.fromRGB(255,60,75), Color3.fromRGB(255,150,90), 55, 4, 180, 0.45, Vector3.new(0,-0.5,0), nil)
        elseif name == "fire" then applyEmitter("fire", "rbxasset://textures/particles/fire_main.dds", Color3.fromRGB(255,80,50), Color3.fromRGB(150,0,0), 45, 5, 22, 1.1, Vector3.new(0,-2.6,0), Enum.NormalId.Top)
        elseif name == "smoke" then applyEmitter("smoke", "rbxasset://textures/particles/smoke_main.dds", Color3.fromRGB(100,8,18), Color3.fromRGB(35,0,6), 30, 2.5, 30, 1.5, Vector3.new(0,-2.2,0), Enum.NormalId.Top)
        elseif name == "trails" then applyTrails()
        elseif name == "eyes" then applyEyes()
        elseif name == "light" then applyLight()
        elseif name == "lightning" then applyLightning()
        end
    end
    local function applyVisualSafe(name) pcall(function() applyVisual(name) end) end
    local function reapplyVisuals()
        clearAllVisuals()
        for name, on in pairs(visualState) do if on then applyVisualSafe(name) end end
    end

    RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local t = tick()
            if visualState.wings and hrp and #wingFeathers > 0 then
                local bob = math.sin(t * 2.4 + 0.5) * 0.1
                local flap = math.sin(t * 2.4)
                for _, f in ipairs(wingFeathers) do
                    if f.base.Parent then
                        local i, side = f.i, f.side
                        local baseCF
                        if f.layer == "prim" then
                            local phase = math.sin(t * 2.4 - i * 0.22)
                            local spread = 12 + i * 8 + phase * 16 * (0.4 + i * 0.07)
                            local lift = -4 - i * 2 + phase * 8
                            local zSweep = 0.78 + i * 0.045
                            baseCF = hrp.CFrame * CFrame.new(side * (0.35 + i * 0.17), 1.55 - i * 0.1 + bob, zSweep) * CFrame.Angles(0, math.rad(side * spread), math.rad(side * lift))
                        elseif f.layer == "sec" then
                            local phase = math.sin(t * 2.4 - i * 0.28)
                            local spread = 8 + i * 11 + phase * 10
                            baseCF = hrp.CFrame * CFrame.new(side * (0.3 + i * 0.12), 1.05 - i * 0.12 + bob, 0.62) * CFrame.Angles(0, math.rad(side * spread), math.rad(side * -3))
                        else
                            local spread = 5 + i * 14
                            baseCF = hrp.CFrame * CFrame.new(side * (0.28 + i * 0.1), 0.75 - i * 0.1 + bob, 0.55) * CFrame.Angles(0, math.rad(side * spread), 0)
                        end
                        f.base.CFrame = baseCF * CFrame.new(0, f.len1 / 2, 0)
                        if f.glow and f.glow.Parent then f.glow.CFrame = f.base.CFrame end
                        if f.tip then
                            f.tip.CFrame = baseCF * CFrame.new(0, f.len1 + f.len2 / 2, f.curve) * CFrame.Angles(math.rad(20), 0, 0)
                        end
                    end
                end
                for _, m in ipairs(wingMembranes) do
                    if m.part.Parent then
                        local spread = 28 + flap * 12
                        local cf = hrp.CFrame * CFrame.new(m.side * 1.0, 1.2 + bob, 1.12) * CFrame.Angles(0, math.rad(m.side * spread), math.rad(m.side * -10))
                        m.part.CFrame = cf
                        if m.glow and m.glow.Parent then m.glow.CFrame = cf end
                    end
                end
                if wingSpine and wingSpine.Parent then
                    local cf = hrp.CFrame * CFrame.new(0, 1.2 + bob, 0.92)
                    wingSpine.CFrame = cf
                    if wingSpineGlow and wingSpineGlow.Parent then wingSpineGlow.CFrame = cf end
                end
            end
            if visualState.circle and hrp then
                local centerY = hrp.Position.Y - 3.1
                local pulse = (math.sin(t * 3) + 1) / 2
                local cx, cz = hrp.Position.X, hrp.Position.Z
                if circleGlow and circleGlow.Parent then
                    circleGlow.CFrame = CFrame.new(cx, centerY, cz) * CFrame.Angles(0, 0, math.rad(90))
                    circleGlow.Transparency = 0.7 + pulse * 0.12
                end
                if circleInnerDisc and circleInnerDisc.Parent then
                    circleInnerDisc.CFrame = CFrame.new(cx, centerY, cz) * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(t * 1.5, 0, 0)
                end
                if circleCore and circleCore.Parent then
                    local cf = CFrame.new(cx, centerY, cz) * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(-t * 2.5, 0, 0)
                    circleCore.CFrame = cf
                    circleCore.Transparency = 0.18 + pulse * 0.2
                    if circleCoreGlow and circleCoreGlow.Parent then circleCoreGlow.CFrame = cf end
                end
                for _, s in ipairs(circleOuterSegs) do
                    if s.part.Parent then
                        local ang = (s.k / 16) * math.pi * 2 + t * 0.8
                        local pos = Vector3.new(cx + math.cos(ang) * 4.5, centerY, cz + math.sin(ang) * 4.5)
                        s.part.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.pi / 2 - ang, 0)
                    end
                end
                for _, s in ipairs(circleMiddleSegs) do
                    if s.part.Parent then
                        local ang = (s.k / 12) * math.pi * 2 - t * 1.3
                        local pos = Vector3.new(cx + math.cos(ang) * 3.3, centerY, cz + math.sin(ang) * 3.3)
                        s.part.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.pi / 2 - ang, 0)
                    end
                end
                for _, r in ipairs(circleRunes) do
                    if r.part.Parent then
                        local ang = (r.k / 8) * math.pi * 2 + t * 0.5
                        local bobY = centerY + 0.5 + math.sin(t * 2.5 + r.k) * 0.25
                        local pos = Vector3.new(cx + math.cos(ang) * 3.9, bobY, cz + math.sin(ang) * 3.9)
                        r.part.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.pi / 2 - ang, math.rad(45))
                    end
                end
                for _, o in ipairs(circleOrbs) do
                    if o.part.Parent then
                        local ang = (o.k / 8) * math.pi * 2 + t * 1.8
                        local bobY = centerY + 0.3 + math.sin(t * 3.2 + o.k) * 0.35
                        local pos = Vector3.new(cx + math.cos(ang) * 4.8, bobY, cz + math.sin(ang) * 4.8)
                        o.part.CFrame = CFrame.new(pos)
                    end
                end
                for _, p in ipairs(circlePillars) do
                    if p.part.Parent then
                        local ang = (p.k / 6) * math.pi * 2 + t * 0.8
                        local pos = Vector3.new(cx + math.cos(ang) * 4.5, centerY + 3.5, cz + math.sin(ang) * 4.5)
                        p.part.CFrame = CFrame.new(pos)
                        p.part.Transparency = 0.42 + pulse * 0.25
                    end
                end
                for _, g in ipairs(gyroRing1) do
                    if g.part.Parent then
                        local theta = (g.k / 14) * math.pi * 2
                        local v = Vector3.new(math.cos(theta) * 3.2, 0, math.sin(theta) * 3.2)
                        v = rotX(v, math.rad(65))
                        v = rotY(v, t * 1.4)
                        g.part.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 0.6, 0) + v)
                    end
                end
                for _, g in ipairs(gyroRing2) do
                    if g.part.Parent then
                        local theta = (g.k / 14) * math.pi * 2
                        local v = Vector3.new(math.cos(theta) * 2.6, 0, math.sin(theta) * 2.6)
                        v = rotX(v, math.rad(-50))
                        v = rotY(v, -t * 1.9)
                        g.part.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 1.3, 0) + v)
                    end
                end
                if circleColumn and circleColumn.Parent then
                    circleColumn.CFrame = CFrame.new(cx, hrp.Position.Y + 0.9, cz) * CFrame.Angles(0, 0, math.rad(90))
                    circleColumn.Transparency = 0.58 + pulse * 0.15
                end
                if circleColumnInner and circleColumnInner.Parent then
                    circleColumnInner.CFrame = CFrame.new(cx, hrp.Position.Y + 0.9, cz) * CFrame.Angles(0, 0, math.rad(90))
                end
                if circleLight then
                    circleLight.Brightness = 2.0 + pulse * 1.4
                end
            end
            if visualState.halo and haloDisc and haloDisc.Parent then
                local head = char:FindFirstChild("Head")
                if head then
                    local bob = math.sin(t * 2.2) * 0.12
                    local cf = head.CFrame * CFrame.new(0, 1.9 + bob, 0) * CFrame.Angles(math.rad(68), t * 1.3, math.rad(12))
                    haloDisc.CFrame = cf
                    if haloDiscGlow and haloDiscGlow.Parent then haloDiscGlow.CFrame = cf end
                    for _, m in ipairs(haloMotes) do
                        if m.part.Parent then
                            local ang = t * 2 + (m.k / 6) * math.pi * 2
                            m.part.CFrame = CFrame.new(head.Position + Vector3.new(math.cos(ang) * 1.5, 1.9 + bob + math.sin(t * 4 + m.k) * 0.12, math.sin(ang) * 1.5))
                        end
                    end
                end
            end
            if visualState.eyes and #eyeParts > 0 then
                local head = char:FindFirstChild("Head")
                if head then
                    for _, e in ipairs(eyeParts) do
                        if e.part.Parent then e.part.CFrame = head.CFrame * CFrame.new(e.side * 0.35, 0.12, -0.52) end
                    end
                end
            end
        end)
    end)

    local viewport = Vector2.new(1000, 700)
    pcall(function() viewport = workspace.CurrentCamera.ViewportSize end)
    local function clamp(n, min, max) return math.min(max, math.max(min, n)) end
    local guiW = clamp(viewport.X * 0.62, 460, 680)
    local guiH = clamp(viewport.Y * 0.7, 340, 480)

    pcall(function()
        local pg = player:FindFirstChild("PlayerGui")
        if pg then local old = pg:FindFirstChild("AutoFarmGui"); if old then old:Destroy() end end
    end)

    local guiUI = Instance.new("ScreenGui")
    guiUI.Name = "AutoFarmGui"; guiUI.ResetOnSpawn = false; guiUI.Enabled = true
    pcall(function() guiUI.IgnoreGuiInset = true end)
    pcall(function() guiUI.DisplayOrder = 999999 end)
    if not safeParentGui(guiUI) then error("GUI parent not found") end

    local clickSnd = Instance.new("Sound")
    clickSnd.SoundId = "rbxassetid://169759176"; clickSnd.Volume = 0.25; clickSnd.Parent = guiUI
    local collectSound = Instance.new("Sound")
    collectSound.SoundId = "rbxassetid://12221967"; collectSound.Volume = 1; collectSound.Parent = guiUI
    local function playClick() pcall(function() clickSnd:Play() end) end

    local bgParticlesOn = false
    local bgLayer = Instance.new("Frame")
    bgLayer.Size = UDim2.new(1, 0, 1, 0)
    bgLayer.Position = UDim2.new(0, 0, 0, 0)
    bgLayer.BackgroundColor3 = Color3.fromRGB(34, 34, 38)
    bgLayer.BackgroundTransparency = 0.42
    bgLayer.BorderSizePixel = 0
    bgLayer.ZIndex = 0
    bgLayer.Active = false
    bgLayer.Visible = false
    pcall(function() bgLayer.InputTransparent = true end)
    bgLayer.Parent = guiUI

    toastHolder = Instance.new("Frame")
    toastHolder.Size = UDim2.new(0, 300, 1, -20)
    toastHolder.Position = UDim2.new(1, -310, 0, 10)
    toastHolder.BackgroundTransparency = 1
    toastHolder.ZIndex = 200
    toastHolder.Parent = guiUI
    local toastLayout = Instance.new("UIListLayout", toastHolder)
    toastLayout.Padding = UDim.new(0, 8)
    toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    toastLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    toastLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function makeDraggable(handle, obj)
        local dragInput = nil; local dragStart = nil; local startPos = nil; local moved = false
        handle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragInput = i; dragStart = i.Position; startPos = obj.Position; moved = false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragInput and i == dragInput and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - dragStart
                if math.abs(d.X) > 10 or math.abs(d.Y) > 10 then moved = true end
                if moved then
                    obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
                end
            end
        end)
        UserInputService.InputEnded:Connect(function(i) if i == dragInput then dragInput = nil end end)
        return function() return moved end
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, guiW, 0, guiH)
    frame.Position = UDim2.new(0.5, -guiW/2, 0.5, -guiH/2)
    frame.BackgroundColor3 = COL.bg
    frame.BorderSizePixel = 0; frame.Visible = true; frame.Active = true; frame.ClipsDescendants = true
    frame.ZIndex = 5
    frame.Parent = guiUI
    corner(frame, 12)
    stroke(frame, COL.line, 1, 0)

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 46)
    topBar.BackgroundColor3 = COL.panel
    topBar.BorderSizePixel = 0; topBar.Active = true; topBar.ZIndex = 7
    topBar.Parent = frame
    local topLine = Instance.new("Frame")
    topLine.Size = UDim2.new(1, 0, 0, 1)
    topLine.Position = UDim2.new(0, 0, 1, -1)
    topLine.BackgroundColor3 = COL.line
    topLine.BorderSizePixel = 0; topLine.ZIndex = 8
    topLine.Parent = topBar
    local logoBox = Instance.new("Frame")
    logoBox.Size = UDim2.new(0, 24, 0, 24)
    logoBox.Position = UDim2.new(0, 12, 0.5, -12)
    logoBox.BackgroundColor3 = COL.accent
    logoBox.BorderSizePixel = 0; logoBox.ZIndex = 9
    logoBox.Parent = topBar
    corner(logoBox, 6)
    local logoTxt = Instance.new("TextLabel")
    logoTxt.Size = UDim2.new(1, 0, 1, 0)
    logoTxt.BackgroundTransparency = 1
    logoTxt.Text = "X"
    logoTxt.Font = Enum.Font.GothamBlack
    logoTxt.TextSize = 15
    logoTxt.TextColor3 = COL.knob
    logoTxt.ZIndex = 10
    logoTxt.Parent = logoBox
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0, 220, 1, 0)
    titleText.Position = UDim2.new(0, 44, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = HUB_NAME
    titleText.Font = Enum.Font.GothamBlack
    titleText.TextSize = 16
    titleText.TextColor3 = COL.text
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.ZIndex = 9
    titleText.Parent = topBar
    local perfChip = Instance.new("TextLabel")
    perfChip.Size = UDim2.new(0, 100, 0, 22)
    perfChip.Position = UDim2.new(1, -108, 0.5, -11)
    perfChip.BackgroundColor3 = COL.card
    perfChip.BorderSizePixel = 0
    perfChip.Text = "— FPS · — ms"
    perfChip.Font = Enum.Font.Code
    perfChip.TextSize = 10
    perfChip.TextColor3 = COL.textDim
    perfChip.ZIndex = 9
    perfChip.Parent = topBar
    corner(perfChip, 6)
    makeDraggable(topBar, frame)

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 150, 1, -46)
    sidebar.Position = UDim2.new(0, 0, 0, 46)
    sidebar.BackgroundColor3 = COL.panel
    sidebar.BorderSizePixel = 0; sidebar.ZIndex = 7
    sidebar.Parent = frame
    local sideLine = Instance.new("Frame")
    sideLine.Size = UDim2.new(0, 1, 1, 0)
    sideLine.Position = UDim2.new(1, -1, 0, 0)
    sideLine.BackgroundColor3 = COL.line
    sideLine.BorderSizePixel = 0; sideLine.ZIndex = 8
    sideLine.Parent = sidebar
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Size = UDim2.new(1, 0, 1, -38)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 0
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.ZIndex = 8
    tabScroll.Parent = sidebar
    pcall(function() tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
    local sideLayout = Instance.new("UIListLayout", tabScroll)
    sideLayout.Padding = UDim.new(0, 3)
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local sidePad = Instance.new("UIPadding", tabScroll)
    sidePad.PaddingTop = UDim.new(0, 8); sidePad.PaddingLeft = UDim.new(0, 6); sidePad.PaddingRight = UDim.new(0, 6)
    local roleStatus = Instance.new("TextLabel")
    roleStatus.Size = UDim2.new(1, -12, 0, 30)
    roleStatus.Position = UDim2.new(0, 6, 1, -36)
    roleStatus.BackgroundTransparency = 1
    roleStatus.Text = "Роль: —"
    roleStatus.Font = Enum.Font.GothamBold
    roleStatus.TextSize = 12
    roleStatus.TextColor3 = COL.textDim
    roleStatus.TextXAlignment = Enum.TextXAlignment.Left
    roleStatus.ZIndex = 9
    roleStatus.Parent = sidebar
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -150, 1, -46)
    content.Position = UDim2.new(0, 150, 0, 46)
    content.BackgroundTransparency = 1
    content.ZIndex = 7
    content.Parent = frame

    local tabs = {}; local contents = {}; local currentTab = nil
    local function switchTab(name)
        for n, d in pairs(tabs) do
            d.btn.BackgroundColor3 = COL.accent; d.btn.BackgroundTransparency = 1
            d.icon.TextColor3 = COL.textDim; d.label.TextColor3 = COL.textDim
            d.indicator.BackgroundTransparency = 1
        end
        for n, c in pairs(contents) do c.Visible = false end
        if tabs[name] then
            local d = tabs[name]
            d.btn.BackgroundColor3 = COL.accent; d.btn.BackgroundTransparency = 0
            d.icon.TextColor3 = COL.knob; d.label.TextColor3 = COL.knob
            d.indicator.BackgroundTransparency = 0
        end
        if contents[name] then contents[name].Visible = true end
        currentTab = name
    end
    local function addTab(name, icon, order)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 40)
        b.BackgroundTransparency = 1
        b.Text = ""; b.BorderSizePixel = 0; b.AutoButtonColor = false
        b.LayoutOrder = order; b.ZIndex = 9
        b.Parent = tabScroll
        corner(b, 8)
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 3, 0, 20)
        indicator.Position = UDim2.new(0, 0, 0.5, -10)
        indicator.BackgroundColor3 = COL.knob
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0; indicator.ZIndex = 10
        indicator.Parent = b
        corner(indicator, 2)
        local iconLbl = Instance.new("TextLabel")
        iconLbl.Size = UDim2.new(0, 26, 1, 0)
        iconLbl.Position = UDim2.new(0, 10, 0, 0)
        iconLbl.BackgroundTransparency = 1
        iconLbl.Text = icon
        iconLbl.Font = Enum.Font.GothamBold
        iconLbl.TextSize = 15
        iconLbl.TextColor3 = COL.textDim
        iconLbl.ZIndex = 10
        iconLbl.Parent = b
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -40, 1, 0)
        nameLbl.Position = UDim2.new(0, 38, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = name
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 13
        nameLbl.TextColor3 = COL.textDim
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.ZIndex = 10
        nameLbl.Parent = b
        tabs[name] = {btn = b, icon = iconLbl, label = nameLbl, indicator = indicator}
        b.MouseEnter:Connect(function()
            if currentTab ~= name then tween(b, {BackgroundColor3 = COL.cardHover, BackgroundTransparency = 0.5}, 0.12) end
        end)
        b.MouseLeave:Connect(function()
            if currentTab ~= name then tween(b, {BackgroundTransparency = 1}, 0.12) end
        end)
        b.MouseButton1Click:Connect(function() playClick(); switchTab(name) end)
        local c = Instance.new("ScrollingFrame")
        c.Size = UDim2.new(1, 0, 1, 0)
        c.BackgroundTransparency = 1
        c.BorderSizePixel = 0
        c.ScrollBarThickness = 3
        c.ScrollBarImageColor3 = COL.accent
        c.CanvasSize = UDim2.new(0, 0, 0, 0)
        c.Visible = false; c.ZIndex = 8
        c.Parent = content
        pcall(function() c.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
        local l = Instance.new("UIListLayout", c)
        l.Padding = UDim.new(0, 0)
        l.SortOrder = Enum.SortOrder.LayoutOrder
        local p = Instance.new("UIPadding", c)
        p.PaddingTop = UDim.new(0, 6); p.PaddingBottom = UDim.new(0, 16)
        p.PaddingLeft = UDim.new(0, 8); p.PaddingRight = UDim.new(0, 8)
        contents[name] = c
    end
    addTab("Шериф", "⭐", 1)
    addTab("Убийца", "🔪", 2)
    addTab("ESP", "👁", 3)
    addTab("Игрок", "🎯", 4)
    addTab("Фарм", "⚙", 5)
    addTab("Визуал", "✨", 6)

    local function makeSection(parent, order, text)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, 0, 0, 30)
        holder.BackgroundTransparency = 1
        holder.LayoutOrder = order
        holder.ZIndex = 8
        holder.Parent = parent
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -8, 1, 0)
        lbl.Position = UDim2.new(0, 4, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextColor3 = COL.textDim
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 8
        lbl.Parent = holder
        return holder
    end
    local function makeButton(parent, order, text, color, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundTransparency = 1
        row.LayoutOrder = order
        row.ZIndex = 8
        row.Parent = parent
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, -4, 0, 1)
        line.Position = UDim2.new(0, 2, 1, -1)
        line.BackgroundColor3 = COL.line
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0; line.ZIndex = 8
        line.Parent = row
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -70, 1, 0)
        lbl.Position = UDim2.new(0, 4, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextColor3 = COL.text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 9
        lbl.Parent = row
        local badge = Instance.new("Frame")
        badge.Size = UDim2.new(0, 46, 0, 24)
        badge.Position = UDim2.new(1, -50, 0.5, -12)
        badge.BackgroundColor3 = COL.card
        badge.BorderSizePixel = 0; badge.ZIndex = 9
        badge.Parent = row
        corner(badge, 6)
        local btxt = Instance.new("TextLabel")
        btxt.Size = UDim2.new(1, 0, 1, 0)
        btxt.BackgroundTransparency = 1
        btxt.Text = "GO"
        btxt.Font = Enum.Font.GothamBold
        btxt.TextSize = 11
        btxt.TextColor3 = COL.textDim
        btxt.ZIndex = 10
        btxt.Parent = badge
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""; btn.AutoButtonColor = false
        btn.ZIndex = 11
        btn.Parent = row
        btn.MouseEnter:Connect(function() tween(row, {BackgroundTransparency = 0.6}, 0.12) end)
        btn.MouseLeave:Connect(function() tween(row, {BackgroundTransparency = 1}, 0.12) end)
        btn.MouseButton1Click:Connect(function()
            playClick()
            tween(badge, {BackgroundColor3 = COL.accent}, 0.08)
            xdDelay(0.12, function() tween(badge, {BackgroundColor3 = COL.card}, 0.12) end)
            pcall(callback)
        end)
        return btn
    end
    local function makeToggle(parent, order, text, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundTransparency = 1
        row.LayoutOrder = order
        row.ZIndex = 8
        row.Parent = parent
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, -4, 0, 1)
        line.Position = UDim2.new(0, 2, 1, -1)
        line.BackgroundColor3 = COL.line
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0; line.ZIndex = 8
        line.Parent = row
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -60, 1, 0)
        lbl.Position = UDim2.new(0, 4, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextColor3 = COL.text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 9
        lbl.Parent = row
        local switch = Instance.new("TextButton")
        switch.Size = UDim2.new(0, 40, 0, 22)
        switch.Position = UDim2.new(1, -44, 0.5, -11)
        switch.BackgroundColor3 = COL.track
        switch.BorderSizePixel = 0
        switch.Text = ""; switch.AutoButtonColor = false
        switch.ZIndex = 10
        switch.Parent = row
        corner(switch, 11)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new(0, 3, 0.5, -8)
        knob.BackgroundColor3 = COL.knob
        knob.BorderSizePixel = 0; knob.ZIndex = 11
        knob.Parent = switch
        corner(knob, 8)
        local state = false
        local function update(v)
            state = v
            if state then
                tween(switch, {BackgroundColor3 = COL.accent}, 0.18)
                tween(knob, {Position = UDim2.new(1, -19, 0.5, -8)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            else
                tween(switch, {BackgroundColor3 = COL.track}, 0.18)
                tween(knob, {Position = UDim2.new(0, 3, 0.5, -8)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            end
            pcall(function() callback(state) end)
        end
        switch.MouseButton1Click:Connect(function() playClick(); update(not state) end)
        return {Set = function(_, v) if state ~= v then update(v) end end}
    end
    local function makeInput(parent, order, label, default, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundTransparency = 1
        row.LayoutOrder = order
        row.ZIndex = 8
        row.Parent = parent
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, -4, 0, 1)
        line.Position = UDim2.new(0, 2, 1, -1)
        line.BackgroundColor3 = COL.line
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0; line.ZIndex = 8
        line.Parent = row
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.6, -8, 1, 0)
        l.Position = UDim2.new(0, 4, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = label
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 13
        l.TextColor3 = COL.text
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 9
        l.Parent = row
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0.38, -8, 0, 28)
        box.Position = UDim2.new(0.6, 0, 0.5, -14)
        box.BackgroundColor3 = COL.card
        box.BorderSizePixel = 0
        box.Text = tostring(default)
        box.TextColor3 = COL.accentHot
        box.Font = Enum.Font.GothamBold
        box.TextSize = 12
        box.ZIndex = 9
        box.Parent = row
        corner(box, 6)
        box.FocusLost:Connect(function()
            local v = tonumber(box.Text)
            if v then pcall(function() callback(v) end) else box.Text = tostring(default) end
        end)
        return box
    end
    local function makeStat(parent, order, label)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 40)
        row.BackgroundTransparency = 1
        row.LayoutOrder = order
        row.ZIndex = 8
        row.Parent = parent
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, -4, 0, 1)
        line.Position = UDim2.new(0, 2, 1, -1)
        line.BackgroundColor3 = COL.line
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0; line.ZIndex = 8
        line.Parent = row
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.6, -8, 1, 0)
        l.Position = UDim2.new(0, 4, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = label
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 12
        l.TextColor3 = COL.textDim
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 9
        l.Parent = row
        local v = Instance.new("TextLabel")
        v.Size = UDim2.new(0.4, -12, 1, 0)
        v.Position = UDim2.new(0.6, 0, 0, 0)
        v.BackgroundTransparency = 1
        v.Text = "0"
        v.Font = Enum.Font.GothamBold
        v.TextSize = 13
        v.TextColor3 = COL.accentHot
        v.TextXAlignment = Enum.TextXAlignment.Right
        v.ZIndex = 9
        v.Parent = row
        return v
    end

    local floatingButtons = {}
    local function createFloatingButton(name, text, color, callback, position)
        if floatingButtons[name] then floatingButtons[name]:Destroy(); floatingButtons[name] = nil end
        local b = Instance.new("TextButton")
        b.Name = name
        b.Size = UDim2.new(0, 160, 0, 52)
        b.Position = position or UDim2.new(0, 120, 0, 80)
        b.BackgroundColor3 = color or COL.accent
        b.Text = text
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamBlack
        b.TextSize = 15
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.ZIndex = 100
        b.Parent = guiUI
        corner(b, 12)
        gradient(b, {ColorSequenceKeypoint.new(0, COL.accentHot), ColorSequenceKeypoint.new(1, color or COL.accent)}, 90)
        stroke(b, COL.accentHot, 1.5, 0.3)
        local wasMoved = makeDraggable(b, b)
        b.MouseButton1Down:Connect(function() tween(b, {BackgroundTransparency = 0.25}, 0.07) end)
        b.MouseButton1Up:Connect(function() tween(b, {BackgroundTransparency = 0}, 0.07) end)
        b.MouseButton1Click:Connect(function()
            if wasMoved() then return end
            playClick(); pcall(callback)
        end)
        floatingButtons[name] = b
        notify(HUB_NAME, "Кнопка создана: " .. text)
    end
    local function removeFloatingButton(name)
        if floatingButtons[name] then
            floatingButtons[name]:Destroy(); floatingButtons[name] = nil
            notify(HUB_NAME, "Кнопка убрана: " .. name)
        end
    end

    local sheriffC = contents["Шериф"]
    makeSection(sheriffC, 0, "ИНСТРУМЕНТЫ ШЕРИФА / ГЕРОЯ")
    makeButton(sheriffC, 1, "🔫 Выстрел в убийцу (очередь)", COL.accent, shootMurderer)
    makeButton(sheriffC, 2, "💰 Телепорт к пистолету", Color3.fromRGB(200, 150, 0), teleportToGun)
    makeButton(sheriffC, 3, "📌 Плавающая: Телепорт к пушке", Color3.fromRGB(120, 90, 0), function()
        if floatingButtons["TP_GUN"] then removeFloatingButton("TP_GUN")
        else createFloatingButton("TP_GUN", "🔫 К ПУШКЕ", Color3.fromRGB(200, 150, 0), teleportToGun, UDim2.new(0, 120, 0, 80)) end
    end)
    makeButton(sheriffC, 4, "📌 Плавающая: Выстрел", Color3.fromRGB(140, 20, 40), function()
        if floatingButtons["SHOOT"] then removeFloatingButton("SHOOT")
        else createFloatingButton("SHOOT", "🔫 ВЫСТРЕЛ", COL.accent, shootMurderer, UDim2.new(0, 120, 0, 145)) end
    end)
    makeToggle(sheriffC, 5, "Авто-стрельба по убийце", function(s) autoShooting = s end)
    makeToggle(sheriffC, 6, "Авто-подбор пистолета", function(s) autoGetDroppedGun = s end)
    makeToggle(sheriffC, 7, "Мгновенное убийство", function(s) instakillshoot = s end)
    makeButton(sheriffC, 8, "💬 Имена в чат", Color3.fromRGB(50, 100, 200), sendNamesToChat)
    makeButton(sheriffC, 9, "📋 Имя шерифа", Color3.fromRGB(70, 70, 80), copySheriffName)
    makeButton(sheriffC, 10, "📋 Имя убийцы", Color3.fromRGB(70, 70, 80), copyMurdererName)

    local murdererC = contents["Убийца"]
    makeSection(murdererC, 0, "ИНСТРУМЕНТЫ УБИЙЦЫ")
    makeButton(murdererC, 1, "🔪 Бросок ножа в ближайшего", COL.accent, knifeThrow)
    makeButton(murdererC, 2, "💀 Убить ближайшего", Color3.fromRGB(170, 0, 0), killClosest)
    makeButton(murdererC, 3, "☠ Убить всех", Color3.fromRGB(130, 0, 0), killEveryone)
    makeButton(murdererC, 4, "🔒 Взять в заложники", Color3.fromRGB(100, 0, 50), holdHostage)
    makeToggle(murdererC, 5, "Авто-бросок ножа", function(s) loopThrow = s end)
    makeToggle(murdererC, 6, "Kill Aura", function(s) toggleKillAura(s) end)
    makeToggle(murdererC, 7, "Спавн ножа у игрока", function(s) spawnAtPlayer = s end)
    makeToggle(murdererC, 8, "Игнорировать ножи", function(s) ignoreknifethrow = s end)
    makeButton(murdererC, 9, "⚡ God Mode (нестабильно)", Color3.fromRGB(150, 0, 150), godMode)

    local espC = contents["ESP"]
    makeSection(espC, 0, "ПОДСВЕТКА")
    makeToggle(espC, 1, "ESP игроков (роли)", function(s)
        playerESP = s
        if s then ensureEspWatcher(); notify(HUB_NAME, "ESP включён") end
        refreshESP()
    end)
    makeToggle(espC, 2, "ESP выпавшей пушки", function(s) gunDropESP = s; reloadGunESP() end)
    makeToggle(espC, 3, "ESP ловушек", function(s) trapDetection = s; reloadTrapESP() end)
    makeToggle(espC, 4, "Скрыть свой ESP", function(s) hideMeEsp = s; refreshESP() end)

    local playerC = contents["Игрок"]
    makeSection(playerC, 0, "ТЕЛЕПОРТЫ")
    makeButton(playerC, 1, "🏠 В лобби", Color3.fromRGB(50, 100, 200), teleportToLobby)
    makeButton(playerC, 2, "🗺 На карту", Color3.fromRGB(50, 150, 50), teleportToMap)
    makeSection(playerC, 3, "НАСТРОЙКИ")
    makeInput(playerC, 4, "Shoot Offset", shootOffset, function(v) shootOffset = v; notify(HUB_NAME, "Offset: " .. v) end)
    makeInput(playerC, 5, "Ping Multiplier", offsetToPingMult, function(v) offsetToPingMult = v; notify(HUB_NAME, "Ping mult: " .. v) end)

    local farmC = contents["Фарм"]
    makeSection(farmC, 0, "СТАТИСТИКА")
    local counterV = makeStat(farmC, 1, "Монеты")
    local timerV = makeStat(farmC, 2, "Время")
    local rateV = makeStat(farmC, 3, "Скорость")
    local pCoinV = makeStat(farmC, 4, "Всего")
    makeSection(farmC, 5, "РОЛЬ")
    local roleV = makeStat(farmC, 6, "Статус")
    makeSection(farmC, 7, "СУМКА")
    local bagVal = makeStat(farmC, 8, "Состояние")

    local function checkRole()
        local r = getPlayerRole(player)
        isMurderer = (r == "Murderer")
        isSheriff = (r == "Sheriff")
        isHero = (r == "Hero")
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
    local function getCollectedCoins() return getPlayerCoins(player) - initialCoins end
    function updateRoleUI()
        checkRole()
        local roleName, roleColor
        if isMurderer then roleName = "Убийца"; roleColor = Color3.fromRGB(255, 50, 50)
        elseif isSheriff then roleName = "Шериф"; roleColor = Color3.fromRGB(50, 150, 255)
        elseif isHero then roleName = "Герой 🔫"; roleColor = Color3.fromRGB(255, 200, 96)
        else roleName = "Мирный"; roleColor = Color3.fromRGB(50, 255, 50) end
        roleV.Text = roleName
        roleV.TextColor3 = roleColor
        roleStatus.Text = "Роль: " .. roleName
        roleStatus.TextColor3 = roleColor
    end
    function updateBagUI()
        local cc = getCollectedCoins()
        if farmStopped then bagVal.Text = "Стоп"; bagVal.TextColor3 = Color3.fromRGB(255, 80, 80)
        elseif cc >= bagSize then bagVal.Text = "Полная"; bagVal.TextColor3 = Color3.fromRGB(255, 200, 0)
        else bagVal.Text = cc .. "/" .. bagSize; bagVal.TextColor3 = COL.accentHot end
    end
    function stopFarming()
        farmStopped = true; isActive = false
        updateBagUI(); notify(HUB_NAME, "Остановлено")
    end
    function flyTo(pos, spd)
        if not rootPart or farmStopped then return false end
        local d = (pos - rootPart.Position).Magnitude
        local dur = math.max(0.1, d / spd)
        local tw = TweenService:Create(rootPart, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
        tw:Play()
        local c = false
        local to = xdDelay(dur + 2, function() c = true; tw:Cancel() end)
        tw.Completed:Wait()
        if not c then pcall(function() task.cancel(to) end) end
        return not c
    end
    function startFarming()
        if farmRunning then return end
        farmRunning = true
        initialCoins = getPlayerCoins(player)
        startTime = tick()
        visitedPositions = {}
        farmStopped = false
        alreadyFlungOnFull = false
        bagFullNotified = false
        counterV.Text = "0"; timerV.Text = "0s"; rateV.Text = "0"
        updateRoleUI(); updateBagUI()
        notify(HUB_NAME, "Фарм включён")
        xdSpawn(function()
            while isActive do
                local e = tick() - startTime
                local cc = getCollectedCoins()
                timerV.Text = math.floor(e) .. "s"
                counterV.Text = tostring(cc)
                rateV.Text = tostring(e > 0 and math.floor(cc / e * 3600) or 0)
                pCoinV.Text = tostring(getPlayerCoins(player))
                updateRoleUI(); updateBagUI()
                xdWait(0.25)
            end
        end)
        xdSpawn(function()
            while isActive do
                if farmStopped then xdWait(1); continue end
                character = player.Character
                if not character then xdWait(0.5); continue end
                rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then xdWait(0.5); continue end
                local cc = getCollectedCoins()
                if cc >= bagSize then
                    if flingOnFullBag and not alreadyFlungOnFull then
                        alreadyFlungOnFull = true
                        local murderer = findMurderer()
                        if murderer then
                            notify(HUB_NAME, "Мешок полный — флингаю убийцу!")
                            xdSpawn(function() pcall(function() miniFling(murderer) end) end)
                        end
                    end
                    if not bagFullNotified then
                        bagFullNotified = true
                        notify(HUB_NAME, "Мешок полный (" .. cc .. "/" .. bagSize .. ") — к монетам не лечу")
                    end
                    updateBagUI()
                    xdWait(1)
                    continue
                end
                bagFullNotified = false
                alreadyFlungOnFull = false
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
                    local cp = cl.Position; local cr = cl
                    if flyTo(cp, flySpeed) and not farmStopped then
                        xdWait(0.3)
                        if cr.Parent and cr:IsDescendantOf(workspace) then
                            local ic = false
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p.Character and cr:IsDescendantOf(p.Character) then ic = true; break end
                            end
                            if not ic and (cr.Position - rootPart.Position).Magnitude < 5 then
                                pcall(function() collectSound:Play() end)
                                updateBagUI()
                            end
                            visitedPositions[cr] = true
                        else
                            visitedPositions[cr] = true
                        end
                    end
                else
                    if next(visitedPositions) then visitedPositions = {} end
                    xdWait(1)
                end
                xdWait(0.1)
            end
            farmRunning = false
        end)
    end

    makeButton(farmC, 9, "🔪 Флинг убийцы", COL.accent, function()
        local murderer = findMurderer()
        if not murderer then notify(HUB_NAME, "Нет убийцы для флинга."); return end
        miniFling(murderer)
    end)
    makeButton(farmC, 10, "⭐ Флинг шерифа", Color3.fromRGB(50, 150, 255), function()
        local sheriff = findSheriff()
        if not sheriff then notify(HUB_NAME, "Нет шерифа для флинга."); return end
        miniFling(sheriff)
    end)
    makeToggle(farmC, 11, "Авто-фарм монет", function(s)
        isActive = s
        if s then startFarming() else farmStopped = true end
    end)
    makeInput(farmC, 12, "⚡ Скорость полёта к монетам", flySpeed, function(v)
        flySpeed = clamp(v, 4, 60)
        notify(HUB_NAME, "Скорость полёта: " .. flySpeed)
    end)
    makeInput(farmC, 13, "🎒 Размер мешка (монет)", bagSize, function(v)
        bagSize = clamp(math.floor(v), 1, 999)
        notify(HUB_NAME, "Размер мешка: " .. bagSize)
    end)
    makeToggle(farmC, 14, "🔪 Флинг убийцы при полном мешке", function(s) flingOnFullBag = s end)
    makeToggle(farmC, 15, "Анти-АФК", function(s) antiAFK = s end)

    local visC = contents["Визуал"]
    local visualToggles = {}
    makeSection(visC, 0, "ВИЗУАЛЬНЫЕ ЭФФЕКТЫ")
    visualToggles.wings = makeToggle(visC, 1, "🪽 Светящиеся крылья", function(s)
        visualState.wings = s
        if s then applyVisualSafe("wings") else clearVisual("wings") end
    end)
    visualToggles.circle = makeToggle(visC, 2, "🌀 Круг-печать под ногами", function(s)
        visualState.circle = s
        if s then applyVisualSafe("circle") else clearVisual("circle") end
    end)
    visualToggles.halo = makeToggle(visC, 3, "😇 Орб / нимб над головой", function(s)
        visualState.halo = s
        if s then applyVisualSafe("halo") else clearVisual("halo") end
    end)
    visualToggles.aura = makeToggle(visC, 4, "✨ Красная аура", function(s)
        visualState.aura = s
        if s then applyVisualSafe("aura") else clearVisual("aura") end
    end)
    visualToggles.fire = makeToggle(visC, 5, "🔥 Огненная аура", function(s)
        visualState.fire = s
        if s then applyVisualSafe("fire") else clearVisual("fire") end
    end)
    visualToggles.smoke = makeToggle(visC, 6, "🌫 Тёмный дым", function(s)
        visualState.smoke = s
        if s then applyVisualSafe("smoke") else clearVisual("smoke") end
    end)
    visualToggles.lightning = makeToggle(visC, 7, "⚡ Багровые молнии", function(s)
        visualState.lightning = s
        if s then applyVisualSafe("lightning") else clearVisual("lightning") end
    end)
    visualToggles.trails = makeToggle(visC, 8, "〰 Неоновые трейлы", function(s)
        visualState.trails = s
        if s then applyVisualSafe("trails") else clearVisual("trails") end
    end)
    visualToggles.eyes = makeToggle(visC, 9, "👀 Светящиеся глаза", function(s)
        visualState.eyes = s
        if s then applyVisualSafe("eyes") else clearVisual("eyes") end
    end)
    visualToggles.light = makeToggle(visC, 10, "💡 Красная подсветка", function(s)
        visualState.light = s
        if s then applyVisualSafe("light") else clearVisual("light") end
    end)
    makeSection(visC, 11, "ФОН МЕНЮ")
    makeToggle(visC, 12, "🌫 Частицы фона на экране игры", function(s)
        bgParticlesOn = s
        bgLayer.Visible = frame.Visible or bgParticlesOn
        notify(HUB_NAME, s and "Фон включён и в игре" or "Фон только в меню")
    end)
    makeButton(visC, 13, "🔥 ВКЛЮЧИТЬ ВСЁ", COL.accent, function()
        for _, t in pairs(visualToggles) do t:Set(true) end
        notify(HUB_NAME, "Все эффекты включены!")
    end)
    makeButton(visC, 14, "🧹 ВЫКЛЮЧИТЬ ВСЁ", Color3.fromRGB(70, 70, 80), function()
        for _, t in pairs(visualToggles) do t:Set(false) end
        notify(HUB_NAME, "Все эффекты выключены!")
    end)

    local mBtn = Instance.new("TextButton")
    mBtn.Size = UDim2.new(0, 50, 0, 50)
    mBtn.Position = UDim2.new(0, 14, 1, -64)
    mBtn.BackgroundColor3 = COL.accent
    mBtn.Text = "X"
    mBtn.TextColor3 = COL.knob
    mBtn.Font = Enum.Font.GothamBlack
    mBtn.TextSize = 20
    mBtn.BorderSizePixel = 0
    mBtn.AutoButtonColor = false
    mBtn.ZIndex = 50
    mBtn.Parent = guiUI
    corner(mBtn, 25)
    mBtn.MouseButton1Click:Connect(function()
        playClick()
        frame.Visible = not frame.Visible
        bgLayer.Visible = frame.Visible or bgParticlesOn
    end)

    local fpsCount = 0
    RunService.RenderStepped:Connect(function() fpsCount = fpsCount + 1 end)
    xdSpawn(function()
        while true do
            xdWait(1)
            pcall(function()
                local ping = math.floor(localplayer:GetNetworkPing() * 1000)
                perfChip.Text = fpsCount .. " FPS · " .. ping .. " ms"
            end)
            fpsCount = 0
        end
    end)

    player.CharacterAdded:Connect(function(ch)
        character = ch
        rootPart = ch:WaitForChild("HumanoidRootPart")
        visitedPositions = {}
        farmStopped = false
        alreadyFlungOnFull = false
        bagFullNotified = false
        xdWait(1.25)
        checkRole()
        pcall(function() updateRoleUI() end)
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
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

    pcall(function() updateRoleUI() end)
    pcall(function() updateBagUI() end)
    switchTab("Шериф")
    reapplyVisuals()

    notify(HUB_NAME, "v42 загружен!")
    notify(HUB_NAME, "Плоский GUI + крылья/орб/круг горят!")
    ban("[" .. HUB_NAME .. "] ГОТОВО ✓ плоское меню + визуалы как на фото", Color3.fromRGB(90, 255, 130))

    xdStatus(HUB_NAME .. " v42: меню готово", Color3.fromRGB(80, 255, 120))
    xdDelay(4, function() pcall(function() if statusLabel then statusLabel.Visible = false end end) end)
end, function(err)
    xdError(err)
end)
