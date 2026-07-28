local HUB_NAME = "XDarkHUB"   -- <-- СЮДА СВОЁ НАЗВАНИЕ

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
    table.insert(attempts, function() local pl = game:GetService("Players").LocalPlayer return pl and pl:FindFirstChild("PlayerGui") end)
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
            statusGui = Instance.new("ScreenGui"); statusGui.Name = "XDarkStatus"; statusGui.ResetOnSpawn = false
            pcall(function() statusGui.IgnoreGuiInset = true end); pcall(function() statusGui.DisplayOrder = 999999999 end)
            if not safeParentGui(statusGui) then return end
            statusLabel = Instance.new("TextLabel"); statusLabel.Size = UDim2.new(0, 560, 0, 80); statusLabel.Position = UDim2.new(0.5, -280, 0, 8)
            statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0); statusLabel.BackgroundTransparency = 0.35; statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            statusLabel.Font = Enum.Font.GothamBold; statusLabel.TextScaled = true; statusLabel.TextWrapped = true; statusLabel.ZIndex = 999999; statusLabel.Text = ""
            statusLabel.Parent = statusGui; pcall(function() Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 10) end)
        end
        if statusLabel then statusLabel.Visible = true; statusLabel.Text = text; statusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255) end
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
    local Lighting = game:GetService("Lighting")

    local player = Players.LocalPlayer
    while not player do xdWait(0.1); player = Players.LocalPlayer end
    local localplayer = player
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    xdSpawn(function() if character and not rootPart then rootPart = character:WaitForChild("HumanoidRootPart", 10) end end)

    local visitedPositions = {}; local isActive = false; local flySpeed = 16; local bagSize = 40; local initialCoins = 0; local startTime = 0
    local antiAFK = false; local isMurderer = false; local isSheriff = false; local isHero = false; local farmStopped = false; local farmRunning = false
    local flingOnFullBag = false; local alreadyFlungOnFull = false; local bagFullNotified = false
    local playerESP = false; local autoShooting = false; local shootOffset = 2.8; local offsetToPingMult = 1; local gunDropESP = false; local trapDetection = false
    local autoGetDroppedGun = false; local playerData = {}; local hideMeEsp = false; local instakillshoot = false; local spawnAtPlayer = false; local loopThrow = false
    local ignoreknifethrow = false; local killAuraCon = nil; local xdG = (getgenv and getgenv()) or _G

    local COL = {
        bgDeep = Color3.fromRGB(11, 11, 14), bg = Color3.fromRGB(17, 17, 21), panel = Color3.fromRGB(23, 23, 28),
        card = Color3.fromRGB(31, 31, 37), cardHover = Color3.fromRGB(42, 42, 49),
        accent = Color3.fromRGB(224, 49, 62), accentHot = Color3.fromRGB(244, 86, 98), accentDim = Color3.fromRGB(104, 24, 32),
        ember = Color3.fromRGB(242, 110, 90), gold = Color3.fromRGB(240, 180, 90),
        text = Color3.fromRGB(234, 234, 238), textDim = Color3.fromRGB(132, 132, 142),
        border = Color3.fromRGB(38, 38, 45), track = Color3.fromRGB(52, 52, 59), line = Color3.fromRGB(34, 34, 40), knob = Color3.fromRGB(246, 246, 250),
    }

    local function corner(o, r) local ok, c = pcall(function() local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0, r or 8); cr.Parent = o; return cr end); if ok then return c end; return nil end
    local function stroke(o, color, thickness, transparency) local ok, s = pcall(function() local st = Instance.new("UIStroke"); st.Color = color; st.Thickness = thickness or 1; st.Transparency = transparency or 0; st.Parent = o; return s end); if ok then return s end; return nil end
    local function gradient(o, keypoints, rotation) local ok, g = pcall(function() local gr = Instance.new("UIGradient"); gr.Color = ColorSequence.new(keypoints); gr.Rotation = rotation or 0; gr.Parent = o; return g end); if ok then return g end; return nil end
    local function tween(o, props, time, style, dir) pcall(function() TweenService:Create(o, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play() end) end

    local toastHolder = nil; local toastOrder = 0
    local function notify(title, text, duration)
        local handled = false
        if toastHolder and toastHolder.Parent then
            handled = pcall(function()
                toastOrder = toastOrder + 1
                local t = Instance.new("Frame"); t.Size = UDim2.new(1, 0, 0, 44); t.BackgroundColor3 = Color3.fromRGB(26, 26, 31); t.BackgroundTransparency = 1
                t.LayoutOrder = toastOrder; t.ZIndex = 201; t.Parent = toastHolder; corner(t, 10); stroke(t, COL.accent, 1, 0.35)
                local bar = Instance.new("Frame"); bar.Size = UDim2.new(0, 3, 1, -16); bar.Position = UDim2.new(0, 0, 0, 8); bar.BackgroundColor3 = COL.accentHot; bar.BackgroundTransparency = 1; bar.ZIndex = 202; bar.Parent = t; corner(bar, 2)
                local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -22, 1, 0); lbl.Position = UDim2.new(0, 13, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12; lbl.TextColor3 = COL.text; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextWrapped = true; lbl.TextTransparency = 1; lbl.ZIndex = 202; lbl.Parent = t
                tween(t, {BackgroundTransparency = 0.12}, 0.3); tween(lbl, {TextTransparency = 0}, 0.3); tween(bar, {BackgroundTransparency = 0}, 0.3)
                xdSpawn(function() xdWait(duration or 3); tween(t, {BackgroundTransparency = 1}, 0.4); tween(lbl, {TextTransparency = 1}, 0.4); tween(bar, {BackgroundTransparency = 1}, 0.4); xdWait(0.45); t:Destroy() end)
            end)
        end
        if not handled then pcall(function() StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 3}) end) end
    end

    local function normalizeRoleName(value)
        if type(value) == "number" then if value == 1 then return "Sheriff" end if value == 2 then return "Murderer" end if value == 0 then return "Innocent" end return nil end
        if type(value) ~= "string" then return nil end; local v = value:lower()
        if v:find("murder") or v:find("killer") then return "Murderer" end; if v:find("hero") then return "Hero" end
        if v:find("sheriff") or v:find("cop") then return "Sheriff" end; if v:find("innocent") or v:find("civilian") or v:find("none") then return "Innocent" end; return nil
    end
    local function readRoleFromTable(tbl) if type(tbl) ~= "table" then return nil end return normalizeRoleName(tbl.Role or tbl.role or tbl.RoleName or tbl.rolename or tbl.Status or tbl.status or tbl.Team or tbl.team or tbl.PlayerRole or tbl.playerRole) end
    local function getPlayerRole(pl)
        if not pl then return "Innocent" end
        local function hasTool(n) if pl.Backpack and pl.Backpack:FindFirstChild(n) then return true end if pl.Character and pl.Character:FindFirstChild(n) then return true end return false end
        if hasTool("Knife") then return "Murderer" end
        if hasTool("Gun") or hasTool("Revolver") or hasTool("Pistol") then
            local cached = playerData[pl.Name] or playerData[pl] or playerData[pl.UserId]
            if type(cached) == "string" and cached:lower():find("hero") then return "Hero" end
            if type(cached) == "table" and readRoleFromTable(cached) == "Hero" then return "Hero" end; return "Sheriff"
        end
        for _, key in ipairs({pl, pl.Name, pl.UserId}) do local data = playerData[key] if data ~= nil then if type(data) == "table" then local role = readRoleFromTable(data); if role then return role end else local role = normalizeRoleName(data); if role then return role end end end end
        for key, data in pairs(playerData) do
            local target = nil
            if typeof(key) == "Instance" and key:IsA("Player") then target = key elseif type(key) == "string" then target = Players:FindFirstChild(key) end
            if type(data) == "table" then local p = data.Player or data.player or data.PlayerName or data.playerName or data.Name or data.name if typeof(p) == "Instance" and p:IsA("Player") then target = p elseif type(p) == "string" then target = Players:FindFirstChild(p) end end
            if target == pl then if type(data) == "table" then local role = readRoleFromTable(data); if role then return role end else local role = normalizeRoleName(data); if role then return role end end end
        end
        return "Innocent"
    end
    local function isGoodGuy(pl) local r = getPlayerRole(pl) return r == "Sheriff" or r == "Hero" end
    local function findMurderer() for _, pl in ipairs(Players:GetPlayers()) do if getPlayerRole(pl) == "Murderer" then return pl end end return nil end
    local function findSheriff() for _, pl in ipairs(Players:GetPlayers()) do if isGoodGuy(pl) then return pl end end return nil end
    local function findSheriffThatsNotMe() for _, pl in ipairs(Players:GetPlayers()) do if pl ~= localplayer and isGoodGuy(pl) then return pl end end return nil end
    local function getMap() for _, o in ipairs(workspace:GetChildren()) do if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then return o end end return nil end
    local function findNearestPlayer()
        local np = nil; local sd = math.huge
        for _, p in ipairs(Players:GetPlayers()) do if p ~= localplayer and p.Character then local lrp = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart"); local orp = p.Character:FindFirstChild("HumanoidRootPart"); if lrp and orp then local d = (lrp.Position - orp.Position).Magnitude if d < sd then sd = d; np = p end end end end
        return np
    end
    local function getPredictedPosition(tp)
        local char = tp and tp.Character; if not char then return Vector3.new(0, 0, 0) end
        local phrp = char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart"); local phum = char:FindFirstChild("Humanoid")
        if not phrp or not phum then return Vector3.new(0, 0, 0) end
        local vel = phrp.AssemblyLinearVelocity; local md = phum.MoveDirection
        local pred = phrp.Position + ((vel * Vector3.new(0.75, 0.5, 0.75)) * (shootOffset / 15)) + md * shootOffset
        local ping = 0; pcall(function() ping = localplayer:GetNetworkPing() * 1000 end); pred = pred * ((ping * ((offsetToPingMult - 1) * 0.01)) + 1); return pred
    end

    function miniFling(playerToFling)
        local Character = player.Character; local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid"); local RootPart = Humanoid and Humanoid.RootPart
        local TCharacter = playerToFling and playerToFling.Character; if not TCharacter then notify(HUB_NAME, "Нет цели."); return end
        local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid"); local TRootPart = THumanoid and THumanoid.RootPart; local THead = TCharacter:FindFirstChild("Head")
        local Accessory = TCharacter:FindFirstChildOfClass("Accessory"); local Handle = Accessory and Accessory:FindFirstChild("Handle")
        if not (Character and Humanoid and RootPart) then notify(HUB_NAME, "Нет персонажа."); return end
        pcall(function() Character.PrimaryPart = RootPart end); if RootPart.Velocity.Magnitude < 50 then xdG.OldPos = RootPart.CFrame end
        local function setCam(s) pcall(function() workspace.CurrentCamera.CameraSubject = s end) end
        if THead then setCam(THead) elseif Handle then setCam(Handle) elseif THumanoid then setCam(THumanoid) end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then notify(HUB_NAME, "Не за что флингануть."); return end
        local FPos = function(bp, pos, ang) RootPart.CFrame = CFrame.new(bp.Position) * pos * ang; pcall(function() Character:SetPrimaryPartCFrame(CFrame.new(bp.Position) * pos * ang) end); RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7); RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8) end
        local SFBasePart = function(bp)
            local Time = tick(); local Angle = 0
            repeat
                if RootPart and THumanoid then
                    local trVel = (TRootPart and TRootPart.Velocity.Magnitude) or bp.Velocity.Magnitude
                    if bp.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(bp, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * bp.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); xdWait()
                        FPos(bp, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * bp.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); xdWait()
                        FPos(bp, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * bp.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); xdWait()
                        FPos(bp, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * bp.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); xdWait()
                        FPos(bp, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)); xdWait()
                        FPos(bp, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)); xdWait()
                    else
                        FPos(bp, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); xdWait()
                        FPos(bp, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0)); xdWait()
                        FPos(bp, CFrame.new(0, 1.5, trVel / 1.25), CFrame.Angles(math.rad(90), 0, 0)); xdWait()
                        FPos(bp, CFrame.new(0, -1.5, -trVel / 1.25), CFrame.Angles(0, 0, 0)); xdWait()
                        FPos(bp, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0)); xdWait()
                        FPos(bp, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)); xdWait()
                    end
                else break end
            until bp.Velocity.Magnitude > 500 or bp.Parent ~= playerToFling.Character or playerToFling.Parent ~= Players or (THumanoid and THumanoid.Sit) or Humanoid.Health <= 0 or tick() > Time + 2
        end
        local oldFPDH; pcall(function() oldFPDH = workspace.FallenPartsDestroyHeight; workspace.FallenPartsDestroyHeight = -1e6 end)
        local BV = Instance.new("BodyVelocity"); BV.Parent = RootPart; BV.Velocity = Vector3.new(9e8, 9e8, 9e8); BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        if TRootPart and THead then if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then SFBasePart(THead) else SFBasePart(TRootPart) end elseif TRootPart then SFBasePart(TRootPart) elseif THead then SFBasePart(THead) elseif Handle then SFBasePart(Handle) else notify(HUB_NAME, "Не за что флингануть.") end
        BV:Destroy(); Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true); setCam(Humanoid)
        local oldPos = xdG.OldPos or RootPart.CFrame; local returnTime = tick() + 3
        repeat RootPart.CFrame = oldPos * CFrame.new(0, 0.5, 0); pcall(function() Character:SetPrimaryPartCFrame(oldPos * CFrame.new(0, 0.5, 0)) end); Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp); for _, x in ipairs(Character:GetChildren()) do if x:IsA("BasePart") then x.Velocity = Vector3.new(); x.RotVelocity = Vector3.new() end end; xdWait() until (RootPart.Position - oldPos.p).Magnitude < 25 or Humanoid.Health <= 0 or tick() > returnTime
        pcall(function() workspace.FallenPartsDestroyHeight = oldFPDH or -500 end)
    end

    local espObjects = {}; local trapHighlights = {}; local gunHighlight = nil; local espWatcherRunning = false; local highlightParent = player:FindFirstChild("PlayerGui"); local highlightSupported = true; local refreshESP; local onRolesChanged
    local function newHighlight(props) if not highlightSupported then return nil end local ok, h = pcall(function() local obj = Instance.new("Highlight"); for k, v in pairs(props) do if k ~= "Parent" then obj[k] = v end end return obj end); if ok and h then return h end; highlightSupported = false; return nil end
    local function clearPlayerHighlight(pl) if espObjects[pl] then pcall(function() espObjects[pl]:Destroy() end); espObjects[pl] = nil end end
    refreshESP = function()
        if not playerESP then for _, h in pairs(espObjects) do pcall(function() h:Destroy() end) end; espObjects = {}; return end
        if not highlightSupported then return end; if not highlightParent then highlightParent = player:FindFirstChild("PlayerGui") end; if not highlightParent then return end
        local alive = {}
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= localplayer or not hideMeEsp then
                local char = pl.Character
                if char and char.Parent then
                    alive[pl] = true; local h = espObjects[pl]
                    if not h or not h.Parent then h = newHighlight({FillTransparency = 0.5, OutlineTransparency = 0, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop}); if not h then return end; pcall(function() h.Parent = highlightParent end); espObjects[pl] = h end
                    h.Adornee = char; local role = getPlayerRole(pl); local color
                    if role == "Murderer" then color = Color3.fromRGB(255, 0, 4) elseif role == "Sheriff" then color = Color3.fromRGB(0, 153, 255) elseif role == "Hero" then color = Color3.fromRGB(255, 200, 0) else color = Color3.fromRGB(0, 255, 8) end
                    h.FillColor = color; h.OutlineColor = color
                else clearPlayerHighlight(pl) end
            else clearPlayerHighlight(pl) end
        end
        for pl in pairs(espObjects) do if not alive[pl] then clearPlayerHighlight(pl) end end
    end
    local function ensureEspWatcher() if espWatcherRunning then return end; espWatcherRunning = true; xdSpawn(function() while playerESP do pcall(refreshESP); xdWait(0.8) end; espWatcherRunning = false end) end
    onRolesChanged = function() xdSpawn(function() if playerESP then pcall(refreshESP) end; if updateRoleUI then pcall(updateRoleUI) end end) end
    local function reloadTrapESP()
        for _, h in pairs(trapHighlights) do pcall(function() h:Destroy() end) end; trapHighlights = {}
        if not trapDetection or not highlightSupported then return end; if not highlightParent then highlightParent = player:FindFirstChild("PlayerGui") end; if not highlightParent then return end
        for _, v in ipairs(workspace:GetDescendants()) do if v.Name == "Trap" and v.Parent and (v.Parent:IsA("Folder") or v.Parent:IsA("Model")) then local h = newHighlight({FillColor = Color3.fromRGB(255,0,0), OutlineColor = Color3.fromRGB(255,0,0), FillTransparency = 0.5, OutlineTransparency = 0, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Adornee = v}); if h then pcall(function() h.Parent = highlightParent end); trapHighlights[v] = h end; if v:IsA("BasePart") then v.Transparency = 0 end end end
    end
    local function reloadGunESP()
        if gunHighlight then pcall(function() gunHighlight:Destroy() end); gunHighlight = nil end
        if not gunDropESP or not highlightSupported then return end; if not highlightParent then highlightParent = player:FindFirstChild("PlayerGui") end; if not highlightParent then return end
        local map = getMap(); if map and map:FindFirstChild("GunDrop") then gunHighlight = newHighlight({FillColor = Color3.fromRGB(255,255,0), OutlineColor = Color3.fromRGB(255,255,0), FillTransparency = 0.5, OutlineTransparency = 0, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Adornee = map:FindFirstChild("GunDrop")}); if gunHighlight then pcall(function() gunHighlight.Parent = highlightParent end) end end
    end

    function shootMurderer()
        if findSheriff() ~= localplayer then notify(HUB_NAME, "Ты не шериф и не герой."); return end
        local murderer = findMurderer() or findSheriffThatsNotMe(); if not murderer or not murderer.Character then notify(HUB_NAME, "Нет убийцы для выстрела."); return end
        if not localplayer.Character:FindFirstChild("Gun") then local hum = localplayer.Character:FindFirstChild("Humanoid"); local bpGun = localplayer.Backpack and localplayer.Backpack:FindFirstChild("Gun"); if hum and bpGun then hum:EquipTool(bpGun); xdWait(0.15) end end
        local gun = localplayer.Character and localplayer.Character:FindFirstChild("Gun"); if not gun then notify(HUB_NAME, "У тебя нет пистолета."); return end
        if not (murderer.Character:FindFirstChild("Head") or murderer.Character:FindFirstChild("HumanoidRootPart")) then notify(HUB_NAME, "Не найдена цель."); return end
        xdSpawn(function() for shot = 1, 3 do local mhrp = murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart"); if not mhrp then break end; local predicted = getPredictedPosition(murderer); local aim = instakillshoot and (mhrp.Position + Vector3.new(0, 1, 0)) or predicted; local rh = localplayer.Character:FindFirstChild("RightHand"); local origin = rh and rh.Position or localplayer.Character:GetPivot().Position; pcall(function() gun:WaitForChild("Shoot"):FireServer(CFrame.new(origin), CFrame.new(aim)) end); xdWait(0.12) end; notify(HUB_NAME, "Очередь по убийце!") end)
    end
    function knifeThrow()
        if findMurderer() ~= localplayer then notify(HUB_NAME, "Ты не убийца."); return end
        if not localplayer.Character:FindFirstChild("Knife") then local hum = localplayer.Character:FindFirstChild("Humanoid"); if localplayer.Backpack:FindFirstChild("Knife") then hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife")) else notify(HUB_NAME, "У тебя нет ножа."); return end end
        local Nearest = findNearestPlayer(); if not Nearest or not Nearest.Character then notify(HUB_NAME, "Не найден игрок."); return end
        local nhrp = Nearest.Character:FindFirstChild("HumanoidRootPart"); if not nhrp then return end
        local rh = localplayer.Character:FindFirstChild("RightHand"); local origin = rh and rh.Position or localplayer.Character:GetPivot().Position; local args = {CFrame.new(origin), CFrame.new(getPredictedPosition(Nearest))}
        if spawnAtPlayer then args[1] = CFrame.new(nhrp.Position + (nhrp.CFrame.LookVector * 5)) end
        pcall(function() localplayer.Character:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(unpack(args)) end); notify(HUB_NAME, "Нож брошен!")
    end
    function killClosest()
        if findMurderer() ~= localplayer then notify(HUB_NAME, "Ты не убийца."); return end
        if not localplayer.Character:FindFirstChild("Knife") then local hum = localplayer.Character:FindFirstChild("Humanoid"); if localplayer.Backpack:FindFirstChild("Knife") then hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife")) else notify(HUB_NAME, "У тебя нет ножа."); return end end
        local Nearest = findNearestPlayer(); if not Nearest or not Nearest.Character then notify(HUB_NAME, "Не найден игрок."); return end
        local nhrp = Nearest.Character:FindFirstChild("HumanoidRootPart"); local myHRP = localplayer.Character:FindFirstChild("HumanoidRootPart"); if not nhrp or not myHRP then return end
        nhrp.Anchored = true; nhrp.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 2; xdWait(0.1); pcall(function() localplayer.Character:WaitForChild("Knife"):WaitForChild("Stab"):FireServer("Slash") end); notify(HUB_NAME, "Убил ближайшего!")
    end
    function killEveryone()
        if findMurderer() ~= localplayer then notify(HUB_NAME, "Ты не убийца."); return end
        if not localplayer.Character:FindFirstChild("Knife") then local hum = localplayer.Character:FindFirstChild("Humanoid"); if localplayer.Backpack:FindFirstChild("Knife") then hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife")) else notify(HUB_NAME, "У тебя нет ножа."); return end end
        local myHRP = localplayer.Character:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
        for _, p in ipairs(Players:GetPlayers()) do if p ~= localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.Anchored = true; p.Character.HumanoidRootPart.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 1 end end
        pcall(function() localplayer.Character:WaitForChild("Knife"):WaitForChild("Stab"):FireServer("Slash") end); notify(HUB_NAME, "Убил всех!")
    end
    function holdHostage()
        if findMurderer() ~= localplayer then notify(HUB_NAME, "Ты не убийца."); return end
        local myHRP = localplayer.Character:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
        for _, p in ipairs(Players:GetPlayers()) do if p ~= localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.Anchored = true; p.Character.HumanoidRootPart.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 5 end end
        notify(HUB_NAME, "Все взяты в заложники!")
    end
    function godMode()
        local Cam = workspace.CurrentCamera; local Pos, Char = Cam.CFrame, localplayer.Character; local Human = Char and Char:FindFirstChildWhichIsA("Humanoid"); if not Human then notify(HUB_NAME, "Нет гуманоида."); return end
        local nHuman = Human:Clone(); nHuman.Parent = Char; localplayer.Character = nil; nHuman:SetStateEnabled(15, false); nHuman:SetStateEnabled(1, false); nHuman:SetStateEnabled(0, false); nHuman.BreakJointsOnDeath = true; Human:Destroy(); localplayer.Character = Char
        Cam.CameraSubject = nHuman; Cam.CFrame = Pos; nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        local Script = Char:FindFirstChild("Animate"); if Script then Script.Disabled = true; xdWait(); Script.Disabled = false end; nHuman.Health = nHuman.MaxHealth; notify(HUB_NAME, "God mode активирован!")
    end
    function teleportToGun()
        local map = getMap(); if not map or not map:FindFirstChild("GunDrop") then notify(HUB_NAME, "Нет выпавшего пистолета."); return end
        local prev = localplayer.Character:GetPivot(); localplayer.Character:PivotTo(map:FindFirstChild("GunDrop"):GetPivot()); localplayer.Backpack.ChildAdded:Wait(); localplayer.Character:PivotTo(prev); notify(HUB_NAME, "Пистолет подобран!")
    end
    function teleportToLobby() local lobby = workspace:FindFirstChild("Lobby"); if lobby and lobby:FindFirstChild("Spawns") then local spawn = lobby.Spawns:FindFirstChildWhichIsA("SpawnLocation"); if spawn then localplayer.Character:MoveTo(spawn.Position); notify(HUB_NAME, "Телепорт в лобби!") end end end
    function teleportToMap() local map = getMap(); if not map then notify(HUB_NAME, "Нет карты для телепорта."); return end; local sf = map:FindFirstChild("Spawns"); if sf then local spawns = sf:GetChildren(); if #spawns > 0 then localplayer.Character:MoveTo(spawns[math.random(1, #spawns)].Position); notify(HUB_NAME, "Телепорт на карту!") end end end
    function sendNamesToChat()
        local murd = findMurderer(); local sher = findSheriff(); local message = string.format("Murderer: %s | Sheriff: %s | <<%s>>", murd and murd.Name or "-", sher and sher.Name or "-", HUB_NAME)
        pcall(function() local channels = TextChatService:FindFirstChild("TextChannels"); if channels then for _, tc in ipairs(channels:GetChildren()) do if tc.Name ~= "RBXSystem" then pcall(function() tc:SendAsync(message) end) end end end end); notify(HUB_NAME, "Имена отправлены в чат!")
    end
    function copyMurdererName() local murd = findMurderer(); if not murd then notify(HUB_NAME, "Нет убийцы."); return end; if setclipboard then setclipboard(murd.Name); notify(HUB_NAME, "Скопировано: " .. murd.Name) end end
    function copySheriffName() local sher = findSheriff(); if not sher then notify(HUB_NAME, "Нет шерифа."); return end; if setclipboard then setclipboard(sher.Name); notify(HUB_NAME, "Скопировано: " .. sher.Name) end end

    xdSpawn(function() while xdWait(0.5) do if autoShooting and findSheriff() == localplayer then pcall(function() local murderer = findMurderer(); if murderer and murderer.Character and localplayer.Character then if not localplayer.Character:FindFirstChild("Gun") then local hum = localplayer.Character:FindFirstChild("Humanoid"); local bp = localplayer.Backpack and localplayer.Backpack:FindFirstChild("Gun"); if hum and bp then hum:EquipTool(bp) end end; local gun = localplayer.Character:FindFirstChild("Gun"); local mhrp = murderer.Character:FindFirstChild("HumanoidRootPart"); if gun and mhrp then local predicted = getPredictedPosition(murderer); local rh = localplayer.Character:FindFirstChild("RightHand"); local origin = rh and rh.Position or localplayer.Character:GetPivot().Position; gun:WaitForChild("Shoot"):FireServer(CFrame.new(origin), CFrame.new(predicted)) end end end) end end end)
    xdSpawn(function() while xdWait(1.5) do if loopThrow then pcall(function() knifeThrow() end) end end end)
    function toggleKillAura(state)
        if state then
            if killAuraCon then killAuraCon:Disconnect() end
            killAuraCon = RunService.Heartbeat:Connect(function() pcall(function() if findMurderer() ~= localplayer then return end; local myHRP = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart"); if not myHRP then return end; for _, p in ipairs(Players:GetPlayers()) do if p ~= localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local hrp = p.Character.HumanoidRootPart; if (hrp.Position - myHRP.Position).Magnitude < 7 then hrp.Anchored = true; hrp.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 2; xdWait(0.1); pcall(function() localplayer.Character:WaitForChild("Knife"):WaitForChild("Stab"):FireServer("Slash") end); return end end end end) end)
        else if killAuraCon then killAuraCon:Disconnect() end; killAuraCon = nil end
    end
    workspace.DescendantAdded:Connect(function(ch) pcall(function() if trapDetection and ch.Name == "Trap" and ch.Parent and (ch.Parent:IsA("Folder") or ch.Parent:IsA("Model")) then if ch:IsA("BasePart") then ch.Transparency = 0 end; reloadTrapESP(); notify(HUB_NAME, "Убийца поставил ловушку!") end; if gunDropESP and ch.Name == "GunDrop" then reloadGunESP(); notify(HUB_NAME, "Пистолет выпал!"); if autoGetDroppedGun then xdWait(1); local map = getMap(); if not map or not map:FindFirstChild("GunDrop") then return end; local prev = localplayer.Character:GetPivot(); localplayer.Character:MoveTo(map:FindFirstChild("GunDrop").Position); localplayer.Backpack.ChildAdded:Wait(); localplayer.Character:PivotTo(prev) end end end) end)
    workspace.DescendantRemoving:Connect(function(ch) pcall(function() if gunDropESP and ch.Name == "GunDrop" then reloadGunESP() end; if trapDetection and ch.Name == "Trap" then reloadTrapESP() end end) end)
    workspace.ChildAdded:Connect(function(chi) if chi.Name == "ThrowingKnife" and ignoreknifethrow then chi:Destroy() end end)

    local function applyRolePayload(payload, sourceName)
        local changed = false
        local function setRole(pl, raw) local role = normalizeRoleName(raw); if pl and role then playerData[pl] = role; playerData[pl.Name] = role; playerData[pl.UserId] = role; changed = true end end
        if type(payload) == "table" then
            local explicit = readRoleFromTable(payload); if explicit then setRole(localplayer, explicit) end
            for k, v in pairs(payload) do
                local target = nil; if typeof(k) == "Instance" and k:IsA("Player") then target = k elseif type(k) == "string" then target = Players:FindFirstChild(k) end
                if target then if type(v) == "table" then setRole(target, readRoleFromTable(v)) else setRole(target, v) end
                elseif type(v) == "table" then local p = v.Player or v.player or v.PlayerName or v.playerName or v.Name or v.name; if typeof(p) == "Instance" and p:IsA("Player") then target = p elseif type(p) == "string" then target = Players:FindFirstChild(p) end; if target then setRole(target, readRoleFromTable(v)) end end
            end
        elseif type(payload) == "string" or type(payload) == "number" then local rn = tostring(sourceName or ""):lower(); if rn:find("role") or rn:find("playerdata") or rn:find("gamedata") or rn:find("game") then setRole(localplayer, payload) end end
        if changed and onRolesChanged then onRolesChanged() end
    end
    pcall(function() local remotes = ReplicatedStorage:FindFirstChild("Remotes"); if remotes then local gameplay = remotes:FindFirstChild("Gameplay"); if gameplay then local pd = gameplay:FindFirstChild("PlayerDataChanged"); if pd and pd:IsA("RemoteEvent") then pd.OnClientEvent:Connect(function(...) for _, arg in ipairs({...}) do applyRolePayload(arg, "PlayerDataChanged") end end) end end end end)
    pcall(function() local connected = {}; local function hookRemote(inst) if connected[inst] then return end; if inst:IsA("RemoteEvent") then connected[inst] = true; pcall(function() inst.OnClientEvent:Connect(function(...) for _, arg in ipairs({...}) do applyRolePayload(arg, inst.Name) end end) end) end end; for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do hookRemote(inst) end; ReplicatedStorage.DescendantAdded:Connect(hookRemote) end)
    pcall(function() local hookedPlayers = {}; local function hookPlayerRoleEvents(pl) if hookedPlayers[pl] then return end; hookedPlayers[pl] = true; pcall(function() pl.CharacterAdded:Connect(function(char) xdWait(0.1); if onRolesChanged then onRolesChanged() end; pcall(function() char.ChildAdded:Connect(function() xdWait(0.05); if onRolesChanged then onRolesChanged() end end); char.ChildRemoved:Connect(function() xdWait(0.05); if onRolesChanged then onRolesChanged() end end) end) end) end); pcall(function() if pl.Backpack then pl.Backpack.ChildAdded:Connect(function() if onRolesChanged then onRolesChanged() end end); pl.Backpack.ChildRemoved:Connect(function() if onRolesChanged then onRolesChanged() end end) end end) end; for _, pl in ipairs(Players:GetPlayers()) do hookPlayerRoleEvents(pl) end; Players.PlayerAdded:Connect(hookPlayerRoleEvents); Players.PlayerRemoving:Connect(function(pl) hookedPlayers[pl] = nil; playerData[pl] = nil; playerData[pl.Name] = nil; playerData[pl.UserId] = nil; if clearPlayerHighlight then clearPlayerHighlight(pl) end end) end)

    -- ================= ВИЗУАЛЫ: BEAM-ЛЕНТЫ (без граней) + МЯГКИЕ ЧАСТИЦЫ + BLOOM =================
    local visualState = {wings = true, circle = true, halo = true, bloom = true, aura = false, fire = false, smoke = false, trails = false, eyes = false, light = false, lightning = false}
    local visualObjects = {}
    local wingBeams = {}     -- {tip=Attachment, side, t, len, baseSpread}
    local haloRings = {}     -- {anchor=Part, tiltX, tiltZ, spin}
    local floorWaves = {}
    local floorPool = nil; local floorPoolGlow = nil
    local floorPillar = nil; local floorPillarGlow = nil
    local eyeParts = {}
    local bloomEffect = nil

    local CORE = Color3.fromRGB(255, 238, 234)
    local MID  = Color3.fromRGB(255, 130, 142)
    local GLOW = Color3.fromRGB(240, 45, 60)
    local DEEP = Color3.fromRGB(170, 18, 38)

    local function setBloom(on)
        if on then
            if not bloomEffect then
                pcall(function()
                    local b = Instance.new("BloomEffect", Lighting)
                    b.Intensity = 1.15; b.Size = 42; b.Threshold = 0.62
                    bloomEffect = b
                end)
            end
            if bloomEffect then bloomEffect.Enabled = true end
        else
            if bloomEffect then bloomEffect.Enabled = false end
        end
    end

    local function registerVisual(name, obj) visualObjects[name] = visualObjects[name] or {}; table.insert(visualObjects[name], obj) end
    local function clearVisual(name)
        if visualObjects[name] then for _, obj in ipairs(visualObjects[name]) do pcall(function() obj:Destroy() end) end; visualObjects[name] = nil end
        if name == "wings" then wingBeams = {} end
        if name == "halo" then haloRings = {} end
        if name == "circle" then floorWaves = {}; floorPool = nil; floorPoolGlow = nil; floorPillar = nil; floorPillarGlow = nil end
        if name == "eyes" then eyeParts = {} end
        if name == "bloom" then setBloom(false) end
    end
    local function clearAllVisuals() local names = {}; for name in pairs(visualObjects) do table.insert(names, name) end; for _, name in ipairs(names) do clearVisual(name) end end
    local function neon(props, meshScale)
        local p = Instance.new("Part"); p.Material = Enum.Material.Neon; p.Anchored = true; p.CanCollide = false; p.CastShadow = false
        p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
        for k, v in pairs(props) do p[k] = v end
        if meshScale then p.Size = Vector3.new(1, 1, 1); pcall(function() local m = Instance.new("SpecialMesh"); m.MeshType = Enum.MeshType.Sphere; m.Scale = meshScale; m.Parent = p end) end
        return p
    end
    -- сплошная светящаяся лента без граней (именно то, что на фото)
    local function makeBeam(a0, a1, w0, w1, colorSeq, transSeq)
        local b = Instance.new("Beam")
        b.Attachment0 = a0; b.Attachment1 = a1
        b.Width0 = w0; b.Width1 = w1
        b.Color = colorSeq; b.Transparency = transSeq
        b.LightEmission = 1; b.LightInfluence = 0
        b.FaceCamera = true; b.Texture = ""; b.Segments = 10
        b.ZOffset = 0
        return b
    end

    -- КРЫЛЬЯ: веер из Beam-лент (широкий мягкий ореол + узкое яркое ядро на каждое перо)
    local function applyWings()
        clearVisual("wings")
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local count = 11
        local softTrans = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(0.5, 0.4), NumberSequenceKeypoint.new(1, 0.95)})
        local coreTrans = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(0.55, 0.0), NumberSequenceKeypoint.new(1, 0.85)})
        for side = -1, 1, 2 do
            for i = 1, count do
                local t = (i - 1) / (count - 1)
                local len = 2.0 + math.sin(t * math.pi) * 1.4
                local baseSpread = 12 + t * 112
                local rootAtt = Instance.new("Attachment", hrp)
                rootAtt.Position = Vector3.new(side * 0.42, 0.95 - t * 0.55, 0.55)
                registerVisual("wings", rootAtt)
                local tipAtt = Instance.new("Attachment", hrp)
                tipAtt.Position = rootAtt.Position
                registerVisual("wings", tipAtt)
                -- широкий мягкий ореол пера
                local bSoft = makeBeam(rootAtt, tipAtt, 1.7 - t * 0.5, 0.12, ColorSequence.new(GLOW, DEEP), softTrans)
                registerVisual("wings", bSoft)
                -- узкое раскалённое ядро пера
                local bCore = makeBeam(rootAtt, tipAtt, 0.75 - t * 0.2, 0.04, ColorSequence.new(CORE, MID), coreTrans)
                registerVisual("wings", bCore)
                table.insert(wingBeams, {tip = tipAtt, side = side, t = t, len = len, baseSpread = baseSpread})
            end
        end
        -- мягкая дымка-ореол позади крыльев (частицы, не парты)
        local att = Instance.new("Attachment", hrp); att.Position = Vector3.new(0, 1.1, 0.5); registerVisual("wings", att)
        local em = Instance.new("ParticleEmitter", att)
        em.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        em.Color = ColorSequence.new(CORE, GLOW)
        em.Rate = 60; em.Lifetime = NumberRange.new(0.8, 1.6); em.Speed = NumberRange.new(0.6, 2.0)
        em.SpreadAngle = Vector2.new(180, 180); em.LightEmission = 1; em.LightInfluence = 0
        em.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.6), NumberSequenceKeypoint.new(1, 0.2)})
        em.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1)})
        registerVisual("wings", em)
        local wl = Instance.new("PointLight"); wl.Color = Color3.fromRGB(255, 100, 115); wl.Brightness = 3.8; wl.Range = 32; wl.Parent = hrp; registerVisual("wings", wl)
    end

    -- НИМБ: сплошные Beam-обручи (замкнутая лента по кругу), 3 шт разного наклона => намотка
    local function buildRing(char, rad, width, count, tiltX, tiltZ, spin)
        local anchor = Instance.new("Part")
        anchor.Name = "XHaloAnchor"; anchor.Transparency = 1; anchor.Anchored = true; anchor.CanCollide = false
        anchor.Size = Vector3.new(0.1, 0.1, 0.1); anchor.Parent = char
        registerVisual("halo", anchor)
        local atts = {}
        for k = 1, count do
            local a = (k / count) * math.pi * 2
            local at = Instance.new("Attachment", anchor)
            at.Position = Vector3.new(math.cos(a) * rad, math.sin(a) * rad, 0)
            registerVisual("halo", at)
            atts[k] = at
        end
        local colSeq = ColorSequence.new(CORE, MID)
        local trSeq = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.18), NumberSequenceKeypoint.new(0.5, 0.02), NumberSequenceKeypoint.new(1, 0.18)})
        for k = 1, count do
            local b = makeBeam(atts[k], atts[(k % count) + 1], width, width, colSeq, trSeq)
            registerVisual("halo", b)
        end
        -- тонкая дымка вдоль обруча
        local haze = Instance.new("Attachment", anchor); haze.Position = Vector3.new(0, 0, 0); registerVisual("halo", haze)
        local pe = Instance.new("ParticleEmitter", haze)
        pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        pe.Color = ColorSequence.new(CORE, GLOW)
        pe.Rate = 26; pe.Lifetime = NumberRange.new(0.5, 1.1); pe.Speed = NumberRange.new(0.3, 1.2)
        pe.SpreadAngle = Vector2.new(180, 180); pe.LightEmission = 1; pe.LightInfluence = 0
        pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 0.1)})
        pe.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1)})
        registerVisual("halo", pe)
        table.insert(haloRings, {anchor = anchor, tiltX = tiltX, tiltZ = tiltZ, spin = spin})
    end
    local function applyHalo()
        clearVisual("halo")
        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        if not head then return end
        buildRing(char, 2.6, 0.34, 28, 0, 0, 1.0)
        buildRing(char, 2.35, 0.26, 26, 16, 12, -1.4)
        buildRing(char, 2.85, 0.22, 26, -12, 20, 0.7)
        local hl = Instance.new("PointLight"); hl.Color = Color3.fromRGB(255, 100, 115); hl.Brightness = 3.0; hl.Range = 16; hl.Parent = head; registerVisual("halo", hl)
    end

    -- ЛУЖА: мягкое световое пятно + расходящиеся волны + дымка в пол + столб
    local function applyCircle()
        clearVisual("circle")
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        floorPool = neon({Name = "XPool", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.1, 11, 11), Color = GLOW, Transparency = 0.86, Parent = char}); registerVisual("circle", floorPool)
        floorPoolGlow = neon({Name = "XPoolG", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 12.4, 12.4), Color = GLOW, Transparency = 0.92, Parent = char}); registerVisual("circle", floorPoolGlow)
        floorPillar = neon({Name = "XPillar", Shape = Enum.PartType.Cylinder, Size = Vector3.new(3.4, 0.5, 0.5), Color = GLOW, Transparency = 0.8, Parent = char}); registerVisual("circle", floorPillar)
        floorPillarGlow = neon({Name = "XPillarG", Shape = Enum.PartType.Cylinder, Size = Vector3.new(3.4, 1.2, 1.2), Color = GLOW, Transparency = 0.9, Parent = char}); registerVisual("circle", floorPillarGlow)
        for i = 1, 4 do
            local disc = neon({Name = "XWave", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.05, 2.4, 2.4), Color = CORE, Transparency = 0.5, Parent = char})
            registerVisual("circle", disc)
            table.insert(floorWaves, {part = disc, phase = (i - 1) / 4})
        end
        -- дымка свечения в пол (частицы)
        local att = Instance.new("Attachment", hrp); att.Position = Vector3.new(0, -2.9, 0); registerVisual("circle", att)
        local pe = Instance.new("ParticleEmitter", att)
        pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        pe.Color = ColorSequence.new(CORE, GLOW)
        pe.Rate = 40; pe.Lifetime = NumberRange.new(0.8, 1.6); pe.Speed = NumberRange.new(0.4, 1.4)
        pe.SpreadAngle = Vector2.new(180, 30); pe.LightEmission = 1; pe.LightInfluence = 0
        pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2.2), NumberSequenceKeypoint.new(1, 0.4)})
        pe.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 1)})
        registerVisual("circle", pe)
        local cl = Instance.new("PointLight"); cl.Color = Color3.fromRGB(255, 90, 105); cl.Brightness = 3.2; cl.Range = 26; cl.Parent = hrp; registerVisual("circle", cl)
    end

    local function applyEmitter(name, texture, c1, c2, rate, speed, spread, sizeStart, attPos, emissionDir)
        clearVisual(name); local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local att = Instance.new("Attachment", hrp); att.Position = attPos or Vector3.new(0, 0, 0); registerVisual(name, att)
        local em = Instance.new("ParticleEmitter", att); em.Texture = texture; em.Color = ColorSequence.new(c1, c2); em.Rate = rate; em.Lifetime = NumberRange.new(0.6, 1.2)
        em.Speed = NumberRange.new(speed * 0.6, speed); em.SpreadAngle = Vector2.new(spread, spread); em.LightEmission = 1
        if emissionDir then em.EmissionDirection = emissionDir end
        em.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, sizeStart), NumberSequenceKeypoint.new(1, 0)}); em.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)}); registerVisual(name, em)
    end
    local function applyTrails()
        clearVisual("trails"); local char = player.Character; if not char then return end
        for _, hn in ipairs({"LeftHand", "RightHand", "Left Arm", "Right Arm"}) do local hand = char:FindFirstChild(hn); if hand then local a0 = Instance.new("Attachment", hand); a0.Position = Vector3.new(0, 0.35, 0); local a1 = Instance.new("Attachment", hand); a1.Position = Vector3.new(0, -0.35, 0); local trail = Instance.new("Trail", hand); trail.Attachment0 = a0; trail.Attachment1 = a1; trail.Color = ColorSequence.new(GLOW, CORE); trail.Lifetime = 0.45; trail.LightEmission = 1; trail.LightInfluence = 0; trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 1)}); registerVisual("trails", a0); registerVisual("trails", a1); registerVisual("trails", trail) end end
    end
    local function applyEyes()
        clearVisual("eyes"); local char = player.Character; local head = char and char:FindFirstChild("Head"); if not head then return end
        for side = -1, 1, 2 do local eye = neon({Name = "XEye", Size = Vector3.new(0.12, 0.14, 0.14), Color = GLOW, Transparency = 0, Parent = char}); registerVisual("eyes", eye); table.insert(eyeParts, {part = eye, side = side}) end
        local el = Instance.new("PointLight"); el.Color = GLOW; el.Brightness = 0.9; el.Range = 7; el.Parent = head; registerVisual("eyes", el)
    end
    local function applyLight() clearVisual("light"); local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end; local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 40, 60); l.Brightness = 2.2; l.Range = 20; l.Parent = hrp; registerVisual("light", l) end
    local function applyLightning() clearVisual("lightning"); local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end; local att = Instance.new("Attachment", hrp); registerVisual("lightning", att); local em = Instance.new("ParticleEmitter", att); em.Texture = "rbxasset://textures/particles/sparkles_main.dds"; em.Color = ColorSequence.new(Color3.fromRGB(255, 220, 180), GLOW); em.Rate = 70; em.Lifetime = NumberRange.new(0.08, 0.25); em.Speed = NumberRange.new(8, 15); em.SpreadAngle = Vector2.new(180, 180); em.LightEmission = 1; em.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.22), NumberSequenceKeypoint.new(1, 0)}); registerVisual("lightning", em) end

    local function applyVisual(name)
        if name == "wings" then applyWings()
        elseif name == "circle" then applyCircle()
        elseif name == "halo" then applyHalo()
        elseif name == "bloom" then setBloom(true)
        elseif name == "aura" then applyEmitter("aura", "rbxasset://textures/particles/sparkles_main.dds", GLOW, CORE, 55, 4, 180, 0.45, Vector3.new(0, -0.5, 0), nil)
        elseif name == "fire" then applyEmitter("fire", "rbxasset://textures/particles/fire_main.dds", Color3.fromRGB(255, 80, 50), Color3.fromRGB(150, 0, 0), 45, 5, 22, 1.1, Vector3.new(0, -2.6, 0), Enum.NormalId.Top)
        elseif name == "smoke" then applyEmitter("smoke", "rbxasset://textures/particles/smoke_main.dds", Color3.fromRGB(100, 8, 18), Color3.fromRGB(35, 0, 6), 30, 2.5, 30, 1.5, Vector3.new(0, -2.2, 0), Enum.NormalId.Top)
        elseif name == "trails" then applyTrails()
        elseif name == "eyes" then applyEyes()
        elseif name == "light" then applyLight()
        elseif name == "lightning" then applyLightning()
        end
    end
    local function applyVisualSafe(name) pcall(function() applyVisual(name) end) end
    local function reapplyVisuals() clearAllVisuals(); for name, on in pairs(visualState) do if on then applyVisualSafe(name) end end end

    RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local t = tick()
            -- КРЫЛЬЯ: двигаю кончики Beam-лент (ленты сами тянутся, FaceCamera держит их к камере)
            if visualState.wings and hrp then
                local flap = math.sin(t * 1.8) * 5
                local sway = math.sin(t * 1.1) * 3
                local bob = math.sin(t * 1.8 + 0.5) * 0.1
                local breathe = 1 + math.sin(t * 1.8) * 0.05
                for _, f in ipairs(wingBeams) do
                    if f.tip.Parent then
                        local spread = f.baseSpread + sway + flap
                        local dir = CFrame.Angles(0, 0, math.rad(f.side * spread)) * Vector3.new(0, 1, 0)
                        local tipLocal = dir * (f.len * breathe) + Vector3.new(0, bob, -0.35)
                        f.tip.Position = Vector3.new(f.side * 0.42, 0.95 - f.t * 0.55, 0.55) + tipLocal
                    end
                end
            end
            -- НИМБ: кручу якоря обручей (Beam-кольца вращаются целиком)
            if visualState.halo and #haloRings > 0 then
                local head = char:FindFirstChild("Head")
                if head then
                    local bob = math.sin(t * 2.0) * 0.1
                    local baseCF = head.CFrame * CFrame.new(0, 1.95 + bob, 0) * CFrame.Angles(math.rad(70), t * 0.5, math.rad(8))
                    for _, r in ipairs(haloRings) do
                        if r.anchor.Parent then
                            r.anchor.CFrame = baseCF * CFrame.Angles(math.rad(r.tiltX), t * r.spin, math.rad(r.tiltZ))
                        end
                    end
                end
            end
            -- ЛУЖА
            if visualState.circle and hrp then
                local cx, cz = hrp.Position.X, hrp.Position.Z
                local cy = hrp.Position.Y - 2.95
                local poolCF = CFrame.new(cx, cy, cz) * CFrame.Angles(math.rad(90), 0, 0)
                if floorPool and floorPool.Parent then floorPool.CFrame = poolCF; floorPool.Transparency = 0.84 + math.sin(t * 1.4) * 0.05 end
                if floorPoolGlow and floorPoolGlow.Parent then floorPoolGlow.CFrame = poolCF end
                local pillarCF = CFrame.new(cx, cy + 1.6, cz) * CFrame.Angles(0, 0, math.rad(90))
                if floorPillar and floorPillar.Parent then floorPillar.CFrame = pillarCF; floorPillar.Transparency = 0.78 + math.sin(t * 2.2) * 0.08 end
                if floorPillarGlow and floorPillarGlow.Parent then floorPillarGlow.CFrame = pillarCF end
                for _, w in ipairs(floorWaves) do
                    if w.part.Parent then
                        local ph = ((t * 0.28 + w.phase) % 1)
                        local r = 1.2 + ph * 5.0
                        local tr = 0.3 + ph * 0.62
                        local cf = CFrame.new(cx, cy + 0.01, cz) * CFrame.Angles(math.rad(90), 0, t * 0.3)
                        w.part.CFrame = cf; w.part.Size = Vector3.new(0.05, r * 2, r * 2); w.part.Transparency = tr
                    end
                end
            end
            if visualState.eyes and #eyeParts > 0 then local head = char:FindFirstChild("Head"); if head then for _, e in ipairs(eyeParts) do if e.part.Parent then e.part.CFrame = head.CFrame * CFrame.new(e.side * 0.35, 0.12, -0.52) end end end end
        end)
    end)

    -- ================= GUI: ПЛОСКИЙ SHITARO-ЛЕЙАУТ, ПОНЯТНЫЕ ПОДПИСИ =================
    ban("[" .. HUB_NAME .. "] строю меню...")
    local guiOK, guiERR = pcall(function()
        local viewport = Vector2.new(1000, 700); pcall(function() viewport = workspace.CurrentCamera.ViewportSize end)
        local function clamp(n, min, max) return math.min(max, math.max(min, n)) end
        local guiW = clamp(viewport.X * 0.72, 540, 780); local guiH = clamp(viewport.Y * 0.74, 380, 540)
        pcall(function() local pg = player:FindFirstChild("PlayerGui"); if pg then local old = pg:FindFirstChild("AutoFarmGui"); if old then old:Destroy() end end end)

        local guiUI = Instance.new("ScreenGui"); guiUI.Name = "AutoFarmGui"; guiUI.ResetOnSpawn = false; guiUI.Enabled = true
        pcall(function() guiUI.IgnoreGuiInset = true end); pcall(function() guiUI.DisplayOrder = 999999 end)
        if not safeParentGui(guiUI) then error("GUI parent not found") end
        local guiScale = Instance.new("UIScale", guiUI); guiScale.Scale = 0.92

        local clickSnd = Instance.new("Sound"); clickSnd.SoundId = "rbxassetid://169759176"; clickSnd.Volume = 0.25; clickSnd.Parent = guiUI
        local collectSound = Instance.new("Sound"); collectSound.SoundId = "rbxassetid://12221967"; collectSound.Volume = 1; collectSound.Parent = guiUI
        local function playClick() pcall(function() clickSnd:Play() end) end

        toastHolder = Instance.new("Frame"); toastHolder.Size = UDim2.new(0, 300, 1, -20); toastHolder.Position = UDim2.new(1, -310, 0, 10); toastHolder.BackgroundTransparency = 1; toastHolder.ZIndex = 200; toastHolder.Parent = guiUI
        local toastLayout = Instance.new("UIListLayout", toastHolder); toastLayout.Padding = UDim.new(0, 8); toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right; toastLayout.VerticalAlignment = Enum.VerticalAlignment.Top; toastLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local function makeDraggable(handle, obj)
            local dragInput, dragStart, startPos, moved = nil, nil, nil, false
            handle.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragInput = i; dragStart = i.Position; startPos = obj.Position; moved = false end end)
            UserInputService.InputChanged:Connect(function(i) if dragInput and i == dragInput and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dragStart; if math.abs(d.X) > 8 or math.abs(d.Y) > 8 then moved = true end; if moved then obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end end)
            UserInputService.InputEnded:Connect(function(i) if i == dragInput then dragInput = nil end end)
            return function() return moved end
        end

        local frame = Instance.new("Frame"); frame.Size = UDim2.new(0, guiW, 0, guiH); frame.Position = UDim2.new(0.5, -guiW / 2, 0.5, -guiH / 2)
        frame.BackgroundColor3 = COL.bg; frame.BorderSizePixel = 0; frame.Visible = true; frame.Active = true; frame.ClipsDescendants = true; frame.ZIndex = 5; frame.Parent = guiUI
        corner(frame, 14); stroke(frame, COL.border, 1, 0)
        local function softGlow(px, py, sz, col, tr) local b = Instance.new("Frame"); b.Size = UDim2.new(0, sz, 0, sz); b.Position = UDim2.new(px, -sz / 2, py, -sz / 2); b.BackgroundColor3 = col; b.BackgroundTransparency = tr or 0.9; b.BorderSizePixel = 0; b.ZIndex = 5; b.Parent = frame; corner(b, sz / 2); return b end
        softGlow(0.08, 0.06, 260, COL.accent, 0.93); softGlow(0.95, 0.97, 220, COL.ember, 0.94)
        for _, top in ipairs({true, false}) do
            local sh = Instance.new("Frame"); sh.Size = UDim2.new(1, 0, 0, 60); sh.Position = top and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 0, 1, -60); sh.BackgroundColor3 = Color3.fromRGB(0, 0, 0); sh.BorderSizePixel = 0; sh.ZIndex = 6; sh.Parent = frame
            pcall(function() local g = Instance.new("UIGradient", sh); g.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)); g.Transparency = top and NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)}) or NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.5)}) end)
        end
        for i = 1, 8 do
            local dot = Instance.new("Frame"); local sz = math.random(2, 4); dot.Size = UDim2.new(0, sz, 0, sz); dot.Position = UDim2.new(math.random(18, 82) / 100, 0, math.random(20, 90) / 100, 0); dot.BackgroundColor3 = COL.accent; dot.BackgroundTransparency = math.random(72, 90) / 100; dot.BorderSizePixel = 0; dot.ZIndex = 5; dot.Parent = frame; corner(dot, sz)
            xdSpawn(function() while dot.Parent do local dur = math.random(7, 14); tween(dot, {Position = UDim2.new(dot.Position.X.Scale + math.random(-10, 10) / 100, 0, dot.Position.Y.Scale + math.random(-12, 8) / 100, 0), BackgroundTransparency = math.random(82, 96) / 100}, dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut); xdWait(dur) end end)
        end

        local topBar = Instance.new("Frame"); topBar.Size = UDim2.new(1, 0, 0, 56); topBar.BackgroundColor3 = COL.panel; topBar.BackgroundTransparency = 0.15; topBar.BorderSizePixel = 0; topBar.Active = true; topBar.ZIndex = 7; topBar.Parent = frame
        local ava = Instance.new("Frame"); ava.Size = UDim2.new(0, 36, 0, 36); ava.Position = UDim2.new(0, 14, 0.5, -18); ava.BorderSizePixel = 0; ava.ZIndex = 9; ava.Parent = topBar; corner(ava, 9)
        gradient(ava, {ColorSequenceKeypoint.new(0, COL.accentHot), ColorSequenceKeypoint.new(1, COL.accentDim)}, 45)
        local avaTxt = Instance.new("TextLabel"); avaTxt.Size = UDim2.new(1, 0, 1, 0); avaTxt.BackgroundTransparency = 1; avaTxt.Text = string.upper(string.sub(HUB_NAME, 1, 1)); avaTxt.Font = Enum.Font.GothamBlack; avaTxt.TextSize = 19; avaTxt.TextColor3 = COL.knob; avaTxt.ZIndex = 10; avaTxt.Parent = ava
        local nameT = Instance.new("TextLabel"); nameT.Size = UDim2.new(0, 200, 0, 19); nameT.Position = UDim2.new(0, 60, 0, 10); nameT.BackgroundTransparency = 1; nameT.Text = HUB_NAME; nameT.Font = Enum.Font.GothamBlack; nameT.TextSize = 16; nameT.TextColor3 = COL.text; nameT.TextXAlignment = Enum.TextXAlignment.Left; nameT.ZIndex = 9; nameT.Parent = topBar
        local subT = Instance.new("TextLabel"); subT.Size = UDim2.new(0, 200, 0, 14); subT.Position = UDim2.new(0, 60, 0, 29); subT.BackgroundTransparency = 1; subT.Text = "v42  ·  never"; subT.Font = Enum.Font.GothamMedium; subT.TextSize = 11; subT.TextColor3 = COL.textDim; subT.TextXAlignment = Enum.TextXAlignment.Left; subT.ZIndex = 9; subT.Parent = topBar
        local eqBox = Instance.new("Frame"); eqBox.Size = UDim2.new(0, 22, 0, 14); eqBox.Position = UDim2.new(0, 60, 0, 30); eqBox.BackgroundTransparency = 1; eqBox.ZIndex = 9; eqBox.Parent = topBar
        for bi = 1, 4 do
            local bar = Instance.new("Frame"); bar.Size = UDim2.new(0, 3, 0.4, 0); bar.Position = UDim2.new(0, (bi - 1) * 5, 1, 0); bar.AnchorPoint = Vector2.new(0, 1); bar.BackgroundColor3 = COL.accentHot; bar.BorderSizePixel = 0; bar.ZIndex = 10; bar.Parent = eqBox; corner(bar, 1)
            xdSpawn(function() local phase = bi * 0.7; while bar.Parent do local h = 0.3 + (math.sin(tick() * 6 + phase) + 1) * 0.35; tween(bar, {Size = UDim2.new(0, 3, h, 0)}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out); xdWait(0.2) end end)
        end
        local dd = Instance.new("TextButton"); dd.Size = UDim2.new(0, 92, 0, 28); dd.Position = UDim2.new(1, -138, 0.5, -14); dd.BackgroundColor3 = COL.card; dd.BorderSizePixel = 0; dd.Text = "  legit    ⌄"; dd.Font = Enum.Font.GothamBold; dd.TextSize = 12; dd.TextColor3 = COL.text; dd.AutoButtonColor = false; dd.ZIndex = 9; dd.Parent = topBar; corner(dd, 8); stroke(dd, COL.border, 1, 0.4)
        local ddIco = Instance.new("TextLabel"); ddIco.Size = UDim2.new(0, 16, 1, 0); ddIco.Position = UDim2.new(0, 8, 0, 0); ddIco.BackgroundTransparency = 1; ddIco.Text = "▣"; ddIco.Font = Enum.Font.GothamBold; ddIco.TextSize = 12; ddIco.TextColor3 = COL.accentHot; ddIco.ZIndex = 10; ddIco.Parent = dd
        local search = Instance.new("TextButton"); search.Size = UDim2.new(0, 28, 0, 28); search.Position = UDim2.new(1, -42, 0.5, -14); search.BackgroundColor3 = COL.card; search.BorderSizePixel = 0; search.Text = "⌕"; search.Font = Enum.Font.GothamBold; search.TextSize = 15; search.TextColor3 = COL.textDim; search.AutoButtonColor = false; search.ZIndex = 9; search.Parent = topBar; corner(search, 8)
        search.MouseEnter:Connect(function() tween(search, {BackgroundColor3 = COL.cardHover}, 0.12) end); search.MouseLeave:Connect(function() tween(search, {BackgroundColor3 = COL.card}, 0.12) end)
        local statusDot = Instance.new("Frame"); statusDot.Size = UDim2.new(0, 8, 0, 8); statusDot.Position = UDim2.new(1, -152, 0.5, -4); statusDot.BackgroundColor3 = Color3.fromRGB(80, 220, 120); statusDot.BorderSizePixel = 0; statusDot.ZIndex = 10; statusDot.Parent = topBar; corner(statusDot, 4)
        local dotGlow = Instance.new("Frame"); dotGlow.Size = UDim2.new(0, 16, 0, 16); dotGlow.Position = UDim2.new(1, -156, 0.5, -8); dotGlow.BackgroundColor3 = Color3.fromRGB(80, 220, 120); dotGlow.BackgroundTransparency = 0.7; dotGlow.BorderSizePixel = 0; dotGlow.ZIndex = 9; dotGlow.Parent = topBar; corner(dotGlow, 8)
        xdSpawn(function() while statusDot.Parent do tween(statusDot, {BackgroundTransparency = 0.55}, 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut); tween(dotGlow, {BackgroundTransparency = 0.92}, 0.8); xdWait(0.8); tween(statusDot, {BackgroundTransparency = 0}, 0.8); tween(dotGlow, {BackgroundTransparency = 0.7}, 0.8); xdWait(0.8) end end)
        local accentLine = Instance.new("Frame"); accentLine.Size = UDim2.new(1, 0, 0, 2); accentLine.Position = UDim2.new(0, 0, 1, -2); accentLine.BackgroundColor3 = COL.accent; accentLine.BorderSizePixel = 0; accentLine.ZIndex = 8; accentLine.Parent = topBar
        local lineGrad = gradient(accentLine, {ColorSequenceKeypoint.new(0, COL.accentDim), ColorSequenceKeypoint.new(0.4, COL.accentHot), ColorSequenceKeypoint.new(0.6, COL.ember), ColorSequenceKeypoint.new(1, COL.accentDim)}, 0)
        if lineGrad then xdSpawn(function() while lineGrad.Parent do tween(lineGrad, {Offset = Vector2.new(0.7, 0)}, 2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut); xdWait(2.6); lineGrad.Offset = Vector2.new(-0.7, 0) end end) end
        makeDraggable(topBar, frame)

        local sidebar = Instance.new("Frame"); sidebar.Size = UDim2.new(0, 156, 1, -56); sidebar.Position = UDim2.new(0, 0, 0, 56); sidebar.BackgroundColor3 = COL.panel; sidebar.BackgroundTransparency = 0.25; sidebar.BorderSizePixel = 0; sidebar.ZIndex = 7; sidebar.Parent = frame
        local sideLine = Instance.new("Frame"); sideLine.Size = UDim2.new(0, 1, 1, 0); sideLine.Position = UDim2.new(1, -1, 0, 0); sideLine.BackgroundColor3 = COL.line; sideLine.BorderSizePixel = 0; sideLine.ZIndex = 8; sideLine.Parent = sidebar
        local tabScroll = Instance.new("ScrollingFrame"); tabScroll.Size = UDim2.new(1, 0, 1, -128); tabScroll.BackgroundTransparency = 1; tabScroll.BorderSizePixel = 0; tabScroll.ScrollBarThickness = 0; tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0); tabScroll.ZIndex = 8; tabScroll.Parent = sidebar
        pcall(function() tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
        local sideLayout = Instance.new("UIListLayout", tabScroll); sideLayout.Padding = UDim.new(0, 2); sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local sidePad = Instance.new("UIPadding", tabScroll); sidePad.PaddingTop = UDim.new(0, 10); sidePad.PaddingLeft = UDim.new(0, 8); sidePad.PaddingRight = UDim.new(0, 8)
        local hkHead = Instance.new("TextLabel"); hkHead.Size = UDim2.new(1, -16, 0, 18); hkHead.Position = UDim2.new(0, 8, 1, -116); hkHead.BackgroundTransparency = 1; hkHead.Text = "HOTKEYS"; hkHead.Font = Enum.Font.GothamBold; hkHead.TextSize = 10; hkHead.TextColor3 = COL.textDim; hkHead.TextXAlignment = Enum.TextXAlignment.Left; hkHead.ZIndex = 9; hkHead.Parent = sidebar
        local hk1 = Instance.new("TextLabel"); hk1.Size = UDim2.new(1, -16, 0, 16); hk1.Position = UDim2.new(0, 8, 1, -96); hk1.BackgroundTransparency = 1; hk1.Text = "●  Свернуть    X"; hk1.Font = Enum.Font.GothamMedium; hk1.TextSize = 11; hk1.TextColor3 = COL.textDim; hk1.TextXAlignment = Enum.TextXAlignment.Left; hk1.ZIndex = 9; hk1.Parent = sidebar
        local hk2 = Instance.new("TextLabel"); hk2.Size = UDim2.new(1, -16, 0, 16); hk2.Position = UDim2.new(0, 8, 1, -78); hk2.BackgroundTransparency = 1; hk2.Text = "●  Фарм   F"; hk2.Font = Enum.Font.GothamMedium; hk2.TextSize = 11; hk2.TextColor3 = COL.textDim; hk2.TextXAlignment = Enum.TextXAlignment.Left; hk2.ZIndex = 9; hk2.Parent = sidebar
        local farmBarBg = Instance.new("Frame"); farmBarBg.Size = UDim2.new(1, -16, 0, 4); farmBarBg.Position = UDim2.new(0, 8, 1, -60); farmBarBg.BackgroundColor3 = COL.track; farmBarBg.BorderSizePixel = 0; farmBarBg.ZIndex = 9; farmBarBg.Parent = sidebar; corner(farmBarBg, 2)
        local farmBarFill = Instance.new("Frame"); farmBarFill.Size = UDim2.new(0, 0, 1, 0); farmBarFill.BackgroundColor3 = COL.accent; farmBarFill.BorderSizePixel = 0; farmBarFill.ZIndex = 10; farmBarFill.Parent = farmBarBg; corner(farmBarFill, 2)
        local prof = Instance.new("Frame"); prof.Size = UDim2.new(1, -16, 0, 42); prof.Position = UDim2.new(0, 8, 1, -50); prof.BackgroundColor3 = COL.card; prof.BorderSizePixel = 0; prof.ZIndex = 9; prof.Parent = sidebar; corner(prof, 9); stroke(prof, COL.border, 1, 0.5)
        local profIco = Instance.new("Frame"); profIco.Size = UDim2.new(0, 28, 0, 28); profIco.Position = UDim2.new(0, 7, 0.5, -14); profIco.BackgroundColor3 = COL.accentDim; profIco.BorderSizePixel = 0; profIco.ZIndex = 10; profIco.Parent = prof; corner(profIco, 7)
        local profIcoT = Instance.new("TextLabel"); profIcoT.Size = UDim2.new(1, 0, 1, 0); profIcoT.BackgroundTransparency = 1; profIcoT.Text = "☠"; profIcoT.Font = Enum.Font.GothamBold; profIcoT.TextSize = 14; profIcoT.TextColor3 = COL.accentHot; profIcoT.ZIndex = 11; profIcoT.Parent = profIco
        local profName = Instance.new("TextLabel"); profName.Size = UDim2.new(1, -56, 0, 17); profName.Position = UDim2.new(0, 42, 0, 6); profName.BackgroundTransparency = 1; profName.Text = localplayer.Name; profName.Font = Enum.Font.GothamBold; profName.TextSize = 12; profName.TextColor3 = COL.text; profName.TextXAlignment = Enum.TextXAlignment.Left; profName.TextTruncate = Enum.TextTruncate.AtEnd; profName.ZIndex = 10; profName.Parent = prof
        local profSub = Instance.new("TextLabel"); profSub.Size = UDim2.new(1, -56, 0, 13); profSub.Position = UDim2.new(0, 42, 0, 22); profSub.BackgroundTransparency = 1; profSub.Text = "never"; profSub.Font = Enum.Font.GothamMedium; profSub.TextSize = 10; profSub.TextColor3 = COL.textDim; profSub.TextXAlignment = Enum.TextXAlignment.Left; profSub.ZIndex = 10; profSub.Parent = prof
        local profArr = Instance.new("TextLabel"); profArr.Size = UDim2.new(0, 16, 1, 0); profArr.Position = UDim2.new(1, -20, 0, 0); profArr.BackgroundTransparency = 1; profArr.Text = "›"; profArr.Font = Enum.Font.GothamBlack; profArr.TextSize = 20; profArr.TextColor3 = COL.textDim; profArr.ZIndex = 10; profArr.Parent = prof
        prof.MouseEnter:Connect(function() tween(prof, {BackgroundColor3 = COL.cardHover}, 0.12) end); prof.MouseLeave:Connect(function() tween(prof, {BackgroundColor3 = COL.card}, 0.12) end)

        local content = Instance.new("Frame"); content.Size = UDim2.new(1, -156, 1, -56); content.Position = UDim2.new(0, 156, 0, 56); content.BackgroundTransparency = 1; content.ZIndex = 7; content.Parent = frame
        local function ripple(row) pcall(function() local r = Instance.new("Frame"); r.BackgroundColor3 = COL.accentHot; r.BackgroundTransparency = 0.55; r.BorderSizePixel = 0; r.Size = UDim2.new(0, 8, 0, 8); r.Position = UDim2.new(0.5, -4, 0.5, -4); r.ZIndex = 7; r.Parent = row; corner(r, 4); tween(r, {Size = UDim2.new(1, 40, 1, 30), Position = UDim2.new(0, -20, 0.5, -15), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out); xdDelay(0.42, function() r:Destroy() end) end) end
        local function rowFrame(parent, order, h) local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, h or 36); row.BackgroundColor3 = COL.cardHover; row.BackgroundTransparency = 1; row.LayoutOrder = order; row.ZIndex = 8; row.ClipsDescendants = true; row.Parent = parent; corner(row, 6); return row end
        local function headRow(parent, order, text)
            local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 28); row.BackgroundTransparency = 1; row.LayoutOrder = order; row.ZIndex = 8; row.Parent = parent
            local dot = Instance.new("Frame"); dot.Size = UDim2.new(0, 4, 0, 4); dot.Position = UDim2.new(0, 4, 0.5, -2); dot.BackgroundColor3 = COL.accentHot; dot.BorderSizePixel = 0; dot.ZIndex = 9; dot.Parent = row; corner(dot, 2)
            local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -16, 1, 0); l.Position = UDim2.new(0, 14, 0, 0); l.BackgroundTransparency = 1; l.Text = text; l.Font = Enum.Font.GothamBold; l.TextSize = 10; l.TextColor3 = COL.textDim; l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 9; l.Parent = row
            return row
        end
        local function labelOf(row, text) local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -86, 1, 0); l.Position = UDim2.new(0, 8, 0, 0); l.BackgroundTransparency = 1; l.Text = text; l.Font = Enum.Font.GothamMedium; l.TextSize = 13; l.TextColor3 = COL.text; l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 9; l.Parent = row; return l end
        local function dotsOf(row) local d = Instance.new("TextButton"); d.Size = UDim2.new(0, 24, 1, 0); d.Position = UDim2.new(1, -72, 0, 0); d.BackgroundTransparency = 1; d.Text = "···"; d.Font = Enum.Font.GothamBold; d.TextSize = 13; d.TextColor3 = COL.textDim; d.AutoButtonColor = false; d.ZIndex = 9; d.Parent = row; d.MouseEnter:Connect(function() tween(d, {TextColor3 = COL.accentHot}, 0.1) end); d.MouseLeave:Connect(function() tween(d, {TextColor3 = COL.textDim}, 0.1) end); return d end
        local function switchOf(row, default, cb)
            local sw = Instance.new("TextButton"); sw.Size = UDim2.new(0, 40, 0, 22); sw.Position = UDim2.new(1, -46, 0.5, -11); sw.BackgroundColor3 = COL.track; sw.BorderSizePixel = 0; sw.Text = ""; sw.AutoButtonColor = false; sw.ZIndex = 10; sw.Parent = row; corner(sw, 11)
            local swStroke = stroke(sw, COL.border, 1, 0.6)
            local kn = Instance.new("Frame"); kn.Size = UDim2.new(0, 16, 0, 16); kn.Position = UDim2.new(0, 3, 0.5, -8); kn.BackgroundColor3 = COL.knob; kn.BorderSizePixel = 0; kn.ZIndex = 11; kn.Parent = sw; corner(kn, 8)
            local st = default and true or false
            local function render()
                if st then tween(sw, {BackgroundColor3 = COL.accent}, 0.16); if swStroke then tween(swStroke, {Color = COL.accentHot, Transparency = 0}, 0.16) end; tween(kn, {Position = UDim2.new(1, -19, 0.5, -8)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                else tween(sw, {BackgroundColor3 = COL.track}, 0.16); if swStroke then tween(swStroke, {Color = COL.border, Transparency = 0.6}, 0.16) end; tween(kn, {Position = UDim2.new(0, 3, 0.5, -8)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out) end
            end
            render()
            local function set(v, fire) st = v and true or false; render(); if fire ~= false then pcall(function() cb(st) end) end end
            sw.MouseButton1Click:Connect(function() playClick(); ripple(row); set(not st) end)
            return {Set = function(_, v) if (v and true or false) ~= st then set(v) end end}
        end
        local function hoverRow(row) row.MouseEnter:Connect(function() tween(row, {BackgroundTransparency = 0.55}, 0.12) end); row.MouseLeave:Connect(function() tween(row, {BackgroundTransparency = 1}, 0.12) end) end
        local function makeToggle(col, order, text, default, cb) local r = rowFrame(col, order, 36); hoverRow(r); labelOf(r, text); dotsOf(r); return switchOf(r, default, cb) end
        local function makeButton(col, order, text, cb)
            local r = rowFrame(col, order, 36); hoverRow(r); labelOf(r, text); dotsOf(r)
            local badge = Instance.new("Frame"); badge.Size = UDim2.new(0, 40, 0, 22); badge.Position = UDim2.new(1, -46, 0.5, -11); badge.BackgroundColor3 = COL.card; badge.BorderSizePixel = 0; badge.ZIndex = 10; badge.Parent = r; corner(badge, 7); stroke(badge, COL.border, 1, 0.5)
            local bt = Instance.new("TextLabel"); bt.Size = UDim2.new(1, 0, 1, 0); bt.BackgroundTransparency = 1; bt.Text = "GO"; bt.Font = Enum.Font.GothamBold; bt.TextSize = 10; bt.TextColor3 = COL.textDim; bt.ZIndex = 11; bt.Parent = badge
            local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 12; btn.Parent = r
            btn.MouseButton1Click:Connect(function() playClick(); ripple(r); tween(badge, {BackgroundColor3 = COL.accent}, 0.08); tween(bt, {TextColor3 = COL.knob}, 0.08); xdDelay(0.14, function() tween(badge, {BackgroundColor3 = COL.card}, 0.14); tween(bt, {TextColor3 = COL.textDim}, 0.14) end); pcall(cb) end)
            return btn
        end
        local function makeInput(col, order, label, default, cb)
            local r = rowFrame(col, order, 36); hoverRow(r); labelOf(r, label)
            local box = Instance.new("TextBox"); box.Size = UDim2.new(0, 66, 0, 24); box.Position = UDim2.new(1, -72, 0.5, -12); box.BackgroundColor3 = COL.card; box.BorderSizePixel = 0; box.Text = tostring(default); box.TextColor3 = COL.accentHot; box.Font = Enum.Font.GothamBold; box.TextSize = 12; box.ZIndex = 10; box.Parent = r; corner(box, 7); stroke(box, COL.border, 1, 0.5)
            box.Focused:Connect(function() tween(box, {BackgroundColor3 = COL.cardHover}, 0.1) end)
            box.FocusLost:Connect(function() tween(box, {BackgroundColor3 = COL.card}, 0.1); local v = tonumber(box.Text); if v then pcall(function() cb(v) end) else box.Text = tostring(default) end end)
            return box
        end
        local function makeStat(col, order, label)
            local r = rowFrame(col, order, 34)
            local l = Instance.new("TextLabel"); l.Size = UDim2.new(0.55, -8, 1, 0); l.Position = UDim2.new(0, 8, 0, 0); l.BackgroundTransparency = 1; l.Text = label; l.Font = Enum.Font.GothamMedium; l.TextSize = 12; l.TextColor3 = COL.textDim; l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 9; l.Parent = r
            local v = Instance.new("TextLabel"); v.Size = UDim2.new(0.45, -10, 1, 0); v.Position = UDim2.new(0.55, 0, 0, 0); v.BackgroundTransparency = 1; v.Text = "0"; v.Font = Enum.Font.Code; v.TextSize = 13; v.TextColor3 = COL.accentHot; v.TextXAlignment = Enum.TextXAlignment.Right; v.ZIndex = 9; v.Parent = r
            return v
        end

        local tabs = {}; local pages = {}; local currentTab = nil
        local function switchTab(name)
            for n, d in pairs(tabs) do d.btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); d.btn.BackgroundTransparency = 1; d.icon.TextColor3 = COL.textDim; d.label.TextColor3 = COL.textDim; d.bar.BackgroundTransparency = 1 end
            for n, pg in pairs(pages) do pg.Visible = false end
            if tabs[name] then local d = tabs[name]; d.btn.BackgroundColor3 = COL.cardHover; d.btn.BackgroundTransparency = 0; d.icon.TextColor3 = COL.accentHot; d.label.TextColor3 = COL.text; d.bar.BackgroundTransparency = 0 end
            if pages[name] then pages[name].Visible = true end
            currentTab = name
        end
        local function makeCol(parent, xScale, xOff)
            local c = Instance.new("ScrollingFrame"); c.Size = UDim2.new(0.5, -8, 1, -10); c.Position = UDim2.new(xScale, xOff, 0, 5); c.BackgroundTransparency = 1; c.BorderSizePixel = 0; c.ScrollBarThickness = 3; c.ScrollBarImageColor3 = COL.accent; c.ScrollBarImageTransparency = 0.4; c.CanvasSize = UDim2.new(0, 0, 0, 0); c.ZIndex = 8; c.Parent = parent
            pcall(function() c.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
            local l = Instance.new("UIListLayout", c); l.Padding = UDim.new(0, 1); l.SortOrder = Enum.SortOrder.LayoutOrder
            local pad = Instance.new("UIPadding", c); pad.PaddingLeft = UDim.new(0, 4); pad.PaddingRight = UDim.new(0, 4); pad.PaddingTop = UDim.new(0, 4)
            return c
        end
        local function addTab(name, icon, order)
            local b = Instance.new("TextButton"); b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundTransparency = 1; b.Text = ""; b.AutoButtonColor = false; b.LayoutOrder = order; b.ZIndex = 9; b.Parent = tabScroll; corner(b, 8)
            local bar = Instance.new("Frame"); bar.Size = UDim2.new(0, 3, 0, 20); bar.Position = UDim2.new(0, 0, 0.5, -10); bar.BackgroundColor3 = COL.accentHot; bar.BackgroundTransparency = 1; bar.BorderSizePixel = 0; bar.ZIndex = 10; bar.Parent = b; corner(bar, 2)
            local ic = Instance.new("TextLabel"); ic.Size = UDim2.new(0, 26, 1, 0); ic.Position = UDim2.new(0, 12, 0, 0); ic.BackgroundTransparency = 1; ic.Text = icon; ic.Font = Enum.Font.GothamBold; ic.TextSize = 15; ic.TextColor3 = COL.textDim; ic.ZIndex = 10; ic.Parent = b
            local nm = Instance.new("TextLabel"); nm.Size = UDim2.new(1, -42, 1, 0); nm.Position = UDim2.new(0, 40, 0, 0); nm.BackgroundTransparency = 1; nm.Text = name; nm.Font = Enum.Font.GothamBold; nm.TextSize = 13; nm.TextColor3 = COL.textDim; nm.TextXAlignment = Enum.TextXAlignment.Left; nm.ZIndex = 10; nm.Parent = b
            tabs[name] = {btn = b, icon = ic, label = nm, bar = bar}
            b.MouseEnter:Connect(function() if currentTab ~= name then tween(b, {BackgroundColor3 = COL.card, BackgroundTransparency = 0.5}, 0.12); tween(ic, {TextColor3 = COL.text}, 0.12) end end)
            b.MouseLeave:Connect(function() if currentTab ~= name then tween(b, {BackgroundTransparency = 1}, 0.12); tween(ic, {TextColor3 = COL.textDim}, 0.12) end end)
            b.MouseButton1Click:Connect(function() playClick(); switchTab(name) end)
            local pg = Instance.new("Frame"); pg.Size = UDim2.new(1, 0, 1, 0); pg.BackgroundTransparency = 1; pg.Visible = false; pg.ZIndex = 8; pg.Parent = content
            local left = makeCol(pg, 0, 2); local right = makeCol(pg, 0.5, 6)
            pages[name] = pg
            return left, right
        end

        local floatingButtons = {}
        local function createFloatingButton(name, text, color, callback, position)
            if floatingButtons[name] then floatingButtons[name]:Destroy(); floatingButtons[name] = nil end
            local b = Instance.new("TextButton"); b.Name = name; b.Size = UDim2.new(0, 160, 0, 52); b.Position = position or UDim2.new(0, 120, 0, 80); b.BackgroundColor3 = color or COL.accent; b.Text = text; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.GothamBlack; b.TextSize = 15; b.BorderSizePixel = 0; b.AutoButtonColor = false; b.ZIndex = 100; b.Parent = guiUI; corner(b, 12)
            gradient(b, {ColorSequenceKeypoint.new(0, COL.accentHot), ColorSequenceKeypoint.new(1, color or COL.accent)}, 90); stroke(b, COL.accentHot, 1.5, 0.3); local wasMoved = makeDraggable(b, b)
            b.MouseButton1Click:Connect(function() if wasMoved() then return end; playClick(); pcall(callback) end); floatingButtons[name] = b; notify(HUB_NAME, "Кнопка создана: " .. text)
        end
        local function removeFloatingButton(name) if floatingButtons[name] then floatingButtons[name]:Destroy(); floatingButtons[name] = nil; notify(HUB_NAME, "Кнопка убрана: " .. name) end end

        local sL, sR = addTab("Шериф", "★", 1)
        headRow(sL, 0, "ШЕРИФ / ГЕРОЙ"); headRow(sR, 0, "АВТОМАТИКА")
        makeButton(sL, 1, "Выстрел в убийцу", shootMurderer)
        makeButton(sL, 2, "Телепорт к пистолету", teleportToGun)
        makeButton(sL, 3, "Имена в чат", sendNamesToChat)
        makeButton(sL, 4, "Скопировать шерифа", copySheriffName)
        makeButton(sL, 5, "Скопировать убийцу", copyMurdererName)
        makeToggle(sR, 1, "Авто-стрельба", false, function(s) autoShooting = s end)
        makeToggle(sR, 2, "Авто-подбор пушки", false, function(s) autoGetDroppedGun = s end)
        makeToggle(sR, 3, "Убийство в голову", false, function(s) instakillshoot = s end)
        makeButton(sR, 4, "Плавающая: к пушке", function() if floatingButtons["TP_GUN"] then removeFloatingButton("TP_GUN") else createFloatingButton("TP_GUN", "🔫 К ПУШКЕ", COL.accent, teleportToGun, UDim2.new(0, 120, 0, 80)) end end)
        makeButton(sR, 5, "Плавающая: выстрел", function() if floatingButtons["SHOOT"] then removeFloatingButton("SHOOT") else createFloatingButton("SHOOT", "🔫 ВЫСТРЕЛ", COL.accent, shootMurderer, UDim2.new(0, 120, 0, 145)) end end)

        local mL, mR = addTab("Убийца", "☠", 2)
        headRow(mL, 0, "УБИЙЦА"); headRow(mR, 0, "АУРА / АВТО")
        makeButton(mL, 1, "Бросок ножа", knifeThrow)
        makeButton(mL, 2, "Убить ближайшего", killClosest)
        makeButton(mL, 3, "Убить всех", killEveryone)
        makeButton(mL, 4, "Взять в заложники", holdHostage)
        makeButton(mL, 5, "God Mode", godMode)
        makeToggle(mR, 1, "Авто-бросок ножа", false, function(s) loopThrow = s end)
        makeToggle(mR, 2, "Kill Aura", false, function(s) toggleKillAura(s) end)
        makeToggle(mR, 3, "Спавн ножа у цели", false, function(s) spawnAtPlayer = s end)
        makeToggle(mR, 4, "Игнор. чужие ножи", false, function(s) ignoreknifethrow = s end)

        local eL, eR = addTab("ESP", "◉", 3)
        headRow(eL, 0, "ИГРОКИ"); headRow(eR, 0, "МИР")
        makeToggle(eL, 1, "ESP игроков (роли)", false, function(s) playerESP = s; if s then ensureEspWatcher(); notify(HUB_NAME, "ESP включён") end; refreshESP() end)
        makeToggle(eL, 2, "Скрыть свой ESP", false, function(s) hideMeEsp = s; refreshESP() end)
        makeToggle(eR, 1, "ESP выпавшей пушки", false, function(s) gunDropESP = s; reloadGunESP() end)
        makeToggle(eR, 2, "ESP ловушек", false, function(s) trapDetection = s; reloadTrapESP() end)

        local pL, pR = addTab("Игрок", "◎", 4)
        headRow(pL, 0, "ТЕЛЕПОРТЫ"); headRow(pR, 0, "НАСТРОЙКИ")
        makeButton(pL, 1, "В лобби", teleportToLobby)
        makeButton(pL, 2, "На карту", teleportToMap)
        makeInput(pR, 1, "Смещение выстрела", shootOffset, function(v) shootOffset = v end)
        makeInput(pR, 2, "Множитель пинга", offsetToPingMult, function(v) offsetToPingMult = v end)

        local fL, fR = addTab("Фарм", "⚙", 5)
        headRow(fL, 0, "ФАРМ"); headRow(fR, 0, "СТАТИСТИКА")
        makeToggle(fL, 1, "Авто-фарм монет", false, function(s) isActive = s; if s then startFarming() else farmStopped = true end end)
        makeToggle(fL, 2, "Анти-АФК", false, function(s) antiAFK = s end)
        makeToggle(fL, 3, "Флинг при полном мешке", false, function(s) flingOnFullBag = s end)
        makeInput(fL, 4, "Скорость полёта", flySpeed, function(v) flySpeed = clamp(v, 4, 60) end)
        makeInput(fL, 5, "Размер мешка", bagSize, function(v) bagSize = clamp(math.floor(v), 1, 999) end)
        makeButton(fL, 6, "Флинг убийцы", function() local m = findMurderer(); if not m then notify(HUB_NAME, "Нет убийцы."); return end; miniFling(m) end)
        makeButton(fL, 7, "Флинг шерифа", function() local s = findSheriff(); if not s then notify(HUB_NAME, "Нет шерифа."); return end; miniFling(s) end)
        local roleV = makeStat(fR, 1, "Роль"); local counterV = makeStat(fR, 2, "Монеты"); local timerV = makeStat(fR, 3, "Время"); local rateV = makeStat(fR, 4, "Скорость"); local pCoinV = makeStat(fR, 5, "Всего"); local bagVal = makeStat(fR, 6, "Мешок")

        local vL, vR = addTab("Визуал", "✦", 6)
        headRow(vL, 0, "ЭФФЕКТЫ"); headRow(vR, 0, "СВЕТ / АУРА")
        local visualToggles = {}
        visualToggles.wings = makeToggle(vL, 1, "Крылья-ленты (Beam)", true, function(s) visualState.wings = s; if s then applyVisualSafe("wings") else clearVisual("wings") end end)
        visualToggles.halo = makeToggle(vL, 2, "Нимб-намотка (Beam)", true, function(s) visualState.halo = s; if s then applyVisualSafe("halo") else clearVisual("halo") end end)
        visualToggles.circle = makeToggle(vL, 3, "Лужа-рябь под ногами", true, function(s) visualState.circle = s; if s then applyVisualSafe("circle") else clearVisual("circle") end end)
        visualToggles.bloom = makeToggle(vL, 4, "Bloom (свечение)", true, function(s) visualState.bloom = s; if s then applyVisualSafe("bloom") else clearVisual("bloom") end end)
        visualToggles.trails = makeToggle(vL, 5, "Неоновые трейлы", false, function(s) visualState.trails = s; if s then applyVisualSafe("trails") else clearVisual("trails") end end)
        visualToggles.eyes = makeToggle(vL, 6, "Светящиеся глаза", false, function(s) visualState.eyes = s; if s then applyVisualSafe("eyes") else clearVisual("eyes") end end)
        visualToggles.aura = makeToggle(vR, 1, "Красная аура", false, function(s) visualState.aura = s; if s then applyVisualSafe("aura") else clearVisual("aura") end end)
        visualToggles.fire = makeToggle(vR, 2, "Огненная аура", false, function(s) visualState.fire = s; if s then applyVisualSafe("fire") else clearVisual("fire") end end)
        visualToggles.smoke = makeToggle(vR, 3, "Тёмный дым", false, function(s) visualState.smoke = s; if s then applyVisualSafe("smoke") else clearVisual("smoke") end end)
        visualToggles.lightning = makeToggle(vR, 4, "Багровые молнии", false, function(s) visualState.lightning = s; if s then applyVisualSafe("lightning") else clearVisual("lightning") end end)
        visualToggles.light = makeToggle(vR, 5, "Красная подсветка", false, function(s) visualState.light = s; if s then applyVisualSafe("light") else clearVisual("light") end end)
        makeButton(vR, 6, "Включить всё", function() for _, t in pairs(visualToggles) do t:Set(true) end; notify(HUB_NAME, "Все эффекты включены!") end)
        makeButton(vR, 7, "Выключить всё", function() for _, t in pairs(visualToggles) do t:Set(false) end; notify(HUB_NAME, "Все эффекты выключены!") end)

        local function checkRole() local r = getPlayerRole(player); isMurderer = (r == "Murderer"); isSheriff = (r == "Sheriff"); isHero = (r == "Hero") end
        local function getPlayerCoins(p) local ls = p:FindFirstChild("leaderstats"); if ls then for _, v in ipairs(ls:GetChildren()) do if v:IsA("IntValue") or v:IsA("NumberValue") then local n = v.Name:lower(); if n:find("coin") or n:find("money") or n:find("cash") or n:find("gold") then return v.Value end end end; for _, v in ipairs(ls:GetChildren()) do if v:IsA("IntValue") or v:IsA("NumberValue") then return v.Value end end end; return 0 end
        local function getCollectedCoins() return getPlayerCoins(player) - initialCoins end
        function updateRoleUI() checkRole(); local rn, rc; if isMurderer then rn = "Убийца"; rc = Color3.fromRGB(255, 70, 80) elseif isSheriff then rn = "Шериф"; rc = Color3.fromRGB(90, 160, 255) elseif isHero then rn = "Герой"; rc = Color3.fromRGB(255, 200, 96) else rn = "Мирный"; rc = Color3.fromRGB(90, 220, 120) end; if roleV then roleV.Text = rn; roleV.TextColor3 = rc end end
        function updateBagUI() local cc = getCollectedCoins(); if farmStopped then bagVal.Text = "стоп"; bagVal.TextColor3 = Color3.fromRGB(255, 80, 80) elseif cc >= bagSize then bagVal.Text = "полон"; bagVal.TextColor3 = Color3.fromRGB(255, 200, 0) else bagVal.Text = cc .. "/" .. bagSize; bagVal.TextColor3 = COL.accentHot end; pcall(function() local f = math.min(1, cc / math.max(1, bagSize)); tween(farmBarFill, {Size = UDim2.new(f, 0, 1, 0)}, 0.3) end) end
        function stopFarming() farmStopped = true; isActive = false; updateBagUI(); notify(HUB_NAME, "Остановлено") end
        function flyTo(pos, spd) if not rootPart or farmStopped then return false end; local d = (pos - rootPart.Position).Magnitude; local dur = math.max(0.1, d / spd); local tw = TweenService:Create(rootPart, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)}); tw:Play(); local c = false; local to = xdDelay(dur + 2, function() c = true; tw:Cancel() end); tw.Completed:Wait(); if not c then pcall(function() task.cancel(to) end) end; return not c end
        function startFarming()
            if farmRunning then return end; farmRunning = true; initialCoins = getPlayerCoins(player); startTime = tick(); visitedPositions = {}; farmStopped = false; alreadyFlungOnFull = false; bagFullNotified = false
            counterV.Text = "0"; timerV.Text = "0s"; rateV.Text = "0"; updateRoleUI(); updateBagUI(); notify(HUB_NAME, "Фарм включён")
            xdSpawn(function() while isActive do local e = tick() - startTime; local cc = getCollectedCoins(); timerV.Text = math.floor(e) .. "s"; counterV.Text = tostring(cc); rateV.Text = tostring(e > 0 and math.floor(cc / e * 3600) or 0); pCoinV.Text = tostring(getPlayerCoins(player)); updateRoleUI(); updateBagUI(); xdWait(0.25) end end)
            xdSpawn(function()
                while isActive do
                    if farmStopped then xdWait(1); continue end
                    character = player.Character; if not character then xdWait(0.5); continue end; rootPart = character:FindFirstChild("HumanoidRootPart"); if not rootPart then xdWait(0.5); continue end
                    local cc = getCollectedCoins()
                    if cc >= bagSize then
                        if flingOnFullBag and not alreadyFlungOnFull then alreadyFlungOnFull = true; local murderer = findMurderer(); if murderer then notify(HUB_NAME, "Мешок полный — флингаю убийцу!"); xdSpawn(function() pcall(function() miniFling(murderer) end) end) end end
                        if not bagFullNotified then bagFullNotified = true; notify(HUB_NAME, "Мешок полный (" .. cc .. "/" .. bagSize .. ")") end; updateBagUI(); xdWait(1); continue
                    end
                    bagFullNotified = false; alreadyFlungOnFull = false; checkRole(); local cl, sh = nil, math.huge
                    for _, o in ipairs(workspace:GetDescendants()) do if o:IsA("BasePart") and o.Name == "Coin_Server" then local ic = false; for _, p in ipairs(Players:GetPlayers()) do if p.Character and o:IsDescendantOf(p.Character) then ic = true; break end end; if not ic and o.Parent and o:IsDescendantOf(workspace) and not visitedPositions[o] then local d = (o.Position - rootPart.Position).Magnitude; if d < sh and d < 300 then cl = o; sh = d end end end end
                    if cl then local cp = cl.Position; local cr = cl; if flyTo(cp, flySpeed) and not farmStopped then xdWait(0.3); if cr.Parent and cr:IsDescendantOf(workspace) then local ic = false; for _, p in ipairs(Players:GetPlayers()) do if p.Character and cr:IsDescendantOf(p.Character) then ic = true; break end end; if not ic and (cr.Position - rootPart.Position).Magnitude < 5 then pcall(function() collectSound:Play() end); updateBagUI() end; visitedPositions[cr] = true else visitedPositions[cr] = true end end else if next(visitedPositions) then visitedPositions = {} end; xdWait(1) end
                    xdWait(0.1)
                end; farmRunning = false
            end)
        end

        local mBtn = Instance.new("TextButton"); mBtn.Size = UDim2.new(0, 50, 0, 50); mBtn.Position = UDim2.new(0, 14, 1, -64); mBtn.BackgroundColor3 = COL.accent; mBtn.Text = "X"; mBtn.TextColor3 = COL.knob; mBtn.Font = Enum.Font.GothamBlack; mBtn.TextSize = 20; mBtn.BorderSizePixel = 0; mBtn.AutoButtonColor = false; mBtn.ZIndex = 50; mBtn.Parent = guiUI; corner(mBtn, 25); stroke(mBtn, COL.accentHot, 1.5, 0.3)
        xdSpawn(function() while mBtn.Parent do tween(mBtn, {Size = UDim2.new(0, 55, 0, 55)}, 1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut); xdWait(1.3); tween(mBtn, {Size = UDim2.new(0, 50, 0, 50)}, 1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut); xdWait(1.3) end end)
        mBtn.MouseButton1Click:Connect(function() playClick(); frame.Visible = not frame.Visible end)

        local fpsCount = 0; RunService.RenderStepped:Connect(function() fpsCount = fpsCount + 1 end)
        xdSpawn(function() while true do xdWait(1); pcall(function() local ping = math.floor(localplayer:GetNetworkPing() * 1000); dd.Text = "  " .. fpsCount .. "·" .. ping .. "  ⌄" end); fpsCount = 0 end end)

        player.CharacterAdded:Connect(function(ch) character = ch; rootPart = ch:WaitForChild("HumanoidRootPart"); visitedPositions = {}; farmStopped = false; alreadyFlungOnFull = false; bagFullNotified = false; xdWait(1.25); checkRole(); pcall(function() updateRoleUI() end); reapplyVisuals() end)
        player.Idled:Connect(function() if antiAFK then pcall(function() VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame); xdWait(1); VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame) end) end end)
        RunService.Stepped:Connect(function() if isActive and character and not farmStopped then for _, v in ipairs(character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end end)

        pcall(function() updateRoleUI() end); pcall(function() updateBagUI() end); switchTab("Шериф"); reapplyVisuals()
        tween(guiScale, {Scale = 1}, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        notify(HUB_NAME, "v42 loaded"); notify(HUB_NAME, "Beam-крылья + нимб-намотка + bloom")
    end)

    if not guiOK then
        ban(HUB_NAME .. " — GUI build error:\n" .. tostring(guiERR), Color3.fromRGB(255, 90, 90)); warn("[GUI BUILD ERROR] " .. tostring(guiERR))
    else
        ban("[" .. HUB_NAME .. "] READY ✓", Color3.fromRGB(90, 255, 130))
    end
    xdStatus(HUB_NAME .. " v42: ready", Color3.fromRGB(80, 255, 120)); xdDelay(4, function() pcall(function() if statusLabel then statusLabel.Visible = false end end) end)
end, function(err) xdError(err) end)
