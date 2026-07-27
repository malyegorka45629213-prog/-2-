local function safeParentGui(obj)
    local function try(fn) local ok,res=pcall(fn); if ok and res then local ok2=pcall(function() obj.Parent=res end); if ok2 and obj.Parent==res then return res end end; return nil end
    if gethui and type(gethui)=="function" then local r=try(function() return gethui() end); if r then return r end end
    if get_hidden_gui and type(get_hidden_gui)=="function" then local r=try(function() return get_hidden_gui() end); if r then return r end end
    local Players=game:GetService("Players"); local deadline=tick()+7
    while tick()<deadline do
        local pl=Players.LocalPlayer
        if pl then local pg=pl:FindFirstChild("PlayerGui"); if pg then local r=try(function() return pg end); if r then return r end end end
        local r2=try(function() return game:GetService("CoreGui") end); if r2 then return r2 end
        wait(0.25)
    end
    return nil
end
local statusGui,statusLabel
local function xdStatus(text,color)
    pcall(function()
        if not statusGui or not statusGui.Parent then
            statusGui=Instance.new("ScreenGui"); statusGui.Name="XDarkStatus"; statusGui.ResetOnSpawn=false
            pcall(function() statusGui.IgnoreGuiInset=true end); pcall(function() statusGui.DisplayOrder=999999999 end)
            if not safeParentGui(statusGui) then return end
            statusLabel=Instance.new("TextLabel"); statusLabel.Size=UDim2.new(0,560,0,80); statusLabel.Position=UDim2.new(0.5,-280,0,8)
            statusLabel.BackgroundColor3=Color3.fromRGB(0,0,0); statusLabel.BackgroundTransparency=0.35; statusLabel.TextColor3=Color3.fromRGB(255,255,255)
            statusLabel.Font=Enum.Font.GothamBold; statusLabel.TextScaled=true; statusLabel.TextWrapped=true; statusLabel.ZIndex=999999; statusLabel.Text=""
            statusLabel.Parent=statusGui; pcall(function() Instance.new("UICorner",statusLabel).CornerRadius=UDim.new(0,10) end)
        end
        if statusLabel then statusLabel.Visible=true; statusLabel.Text=text; statusLabel.TextColor3=color or Color3.fromRGB(255,255,255) end
    end)
end
local function xdError(err)
    pcall(function() warn("[XDarkHUB ERROR] "..tostring(err)) end)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="XDarkHUB ERROR",Text=tostring(err):sub(1,140),Duration=9}) end)
    xdStatus("XDarkHUB ERROR: "..tostring(err),Color3.fromRGB(255,70,70))
end
local xdWait=(task and task.wait) or wait
local xdDelay=function(t,f) if task and task.delay then task.delay(t,f) else delay(t,f) end end
local xdSpawn=function(f) if task and task.spawn then task.spawn(f) else spawn(f) end end
xdStatus("XDarkHUB: загрузка...",Color3.fromRGB(255,255,255))
pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="XDarkHUB",Text="инжект пойман — грузим меню...",Duration=2}) end)
xpcall(function()
    local Players=game:GetService("Players"); local TweenService=game:GetService("TweenService"); local RunService=game:GetService("RunService")
    local UserInputService=game:GetService("UserInputService"); local VirtualUser=game:GetService("VirtualUser"); local StarterGui=game:GetService("StarterGui")
    local TextChatService=game:GetService("TextChatService"); local ReplicatedStorage=game:GetService("ReplicatedStorage")
    local player=Players.LocalPlayer; while not player do xdWait(0.1); player=Players.LocalPlayer end
    local localplayer=player; local character=player.Character; local rootPart=character and character:FindFirstChild("HumanoidRootPart")
    xdSpawn(function() if character and not rootPart then rootPart=character:WaitForChild("HumanoidRootPart",10) end end)
    local visitedPositions={}; local isActive=false; local flySpeed=16; local bagSize=40; local initialCoins=0; local startTime=0
    local antiAFK=false; local isMurderer=false; local isSheriff=false; local isHero=false; local farmStopped=false; local farmRunning=false
    local flingOnFullBag=false; local alreadyFlungOnFull=false; local bagFullNotified=false
    local playerESP=false; local autoShooting=false; local shootOffset=2.8; local offsetToPingMult=1; local gunDropESP=false; local trapDetection=false
    local autoGetDroppedGun=false; local playerData={}; local hideMeEsp=false; local instakillshoot=false; local spawnAtPlayer=false; local loopThrow=false
    local ignoreknifethrow=false; local killAuraCon=nil; local xdG=(getgenv and getgenv()) or _G
    local COL={
        bgDeep=Color3.fromRGB(14,14,16); bg=Color3.fromRGB(20,20,23); panel=Color3.fromRGB(27,27,31); card=Color3.fromRGB(35,35,40); cardHover=Color3.fromRGB(46,46,52)
        track=Color3.fromRGB(50,50,56); line=Color3.fromRGB(42,42,48); border=Color3.fromRGB(42,42,48); accent=Color3.fromRGB(224,49,62); accentHot=Color3.fromRGB(242,82,94)
        accentDim=Color3.fromRGB(112,26,34); ember=Color3.fromRGB(242,110,90); gold=Color3.fromRGB(240,180,90); text=Color3.fromRGB(232,232,236); textDim=Color3.fromRGB(142,142,152); knob=Color3.fromRGB(245,245,248)
    }
    local function corner(o,r) local ok,c=pcall(function() local cr=Instance.new("UICorner"); cr.CornerRadius=UDim.new(0,r or 8); cr.Parent=o; return cr end); if ok then return c end; return nil end
    local function stroke(o,color,thickness,transparency) local ok,s=pcall(function() local st=Instance.new("UIStroke"); st.Color=color; st.Thickness=thickness or 1; st.Transparency=transparency or 0; st.Parent=o; return s end); if ok then return s end; return nil end
    local function gradient(o,keypoints,rotation) local ok,g=pcall(function() local gr=Instance.new("UIGradient"); gr.Color=ColorSequence.new(keypoints); gr.Rotation=rotation or 0; gr.Parent=o; return g end); if ok then return g end; return nil end
    local function tween(o,props,time,style,dir) pcall(function() TweenService:Create(o,TweenInfo.new(time or 0.2,style or Enum.EasingStyle.Quint,dir or Enum.EasingDirection.Out),props):Play() end) end
    local function rotY(v,a) local c,s=math.cos(a),math.sin(a) return Vector3.new(v.X*c+v.Z*s,v.Y,-v.X*s+v.Z*c) end
    local function rotX(v,a) local c,s=math.cos(a),math.sin(a) return Vector3.new(v.X,v.Y*c-v.Z*s,v.Y*s+v.Z*c) end
    local toastHolder=nil; local toastOrder=0
    local function notify(title,text,duration)
        local handled=false
        if toastHolder and toastHolder.Parent then
            handled=pcall(function()
                toastOrder=toastOrder+1; local t=Instance.new("Frame"); t.Size=UDim2.new(1,0,0,44); t.BackgroundColor3=COL.card; t.BackgroundTransparency=1
                t.LayoutOrder=toastOrder; t.ZIndex=201; t.Parent=toastHolder; corner(t,10); stroke(t,COL.accent,1,0.35)
                local bar=Instance.new("Frame"); bar.Size=UDim2.new(0,3,1,-16); bar.Position=UDim2.new(0,0,0,8); bar.BackgroundColor3=COL.accentHot; bar.BackgroundTransparency=1; bar.ZIndex=202; bar.Parent=t; corner(bar,2)
                local ttl=Instance.new("TextLabel"); ttl.Size=UDim2.new(1,-16,0,16); ttl.Position=UDim2.new(0,13,0,5); ttl.BackgroundTransparency=1; ttl.Text=title or "XDarkHUB"; ttl.Font=Enum.Font.GothamBold; ttl.TextSize=12; ttl.TextColor3=COL.accentHot; ttl.TextXAlignment=Enum.TextXAlignment.Left; ttl.TextTransparency=1; ttl.ZIndex=202; ttl.Parent=t
                local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-16,0,16); lbl.Position=UDim2.new(0,13,0,21); lbl.BackgroundTransparency=1; lbl.Text=text or ""; lbl.Font=Enum.Font.GothamMedium; lbl.TextSize=11; lbl.TextColor3=COL.text; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextWrapped=true; lbl.TextTransparency=1; lbl.ZIndex=202; lbl.Parent=t
                tween(t,{BackgroundTransparency=0.1},0.3); tween(ttl,{TextTransparency=0},0.3); tween(lbl,{TextTransparency=0},0.3); tween(bar,{BackgroundTransparency=0},0.3)
                xdSpawn(function() xdWait(duration or 3); tween(t,{BackgroundTransparency=1},0.4); tween(ttl,{TextTransparency=1},0.4); tween(lbl,{TextTransparency=1},0.4); tween(bar,{BackgroundTransparency=1},0.4); xdWait(0.45); t:Destroy() end)
            end)
        end
        if not handled then pcall(function() StarterGui:SetCore("SendNotification",{Title=title,Text=text,Duration=duration or 3}) end) end
    end
    local function normalizeRoleName(value)
        if type(value)=="number" then if value==1 then return "Sheriff" end if value==2 then return "Murderer" end if value==0 then return "Innocent" end return nil end
        if type(value)~="string" then return nil end; local v=value:lower()
        if v:find("murder") or v:find("killer") then return "Murderer" end; if v:find("hero") then return "Hero" end
        if v:find("sheriff") or v:find("cop") then return "Sheriff" end; if v:find("innocent") or v:find("civilian") or v:find("none") then return "Innocent" end; return nil
    end
    local function readRoleFromTable(tbl) if type(tbl)~="table" then return nil end return normalizeRoleName(tbl.Role or tbl.role or tbl.RoleName or tbl.rolename or tbl.Status or tbl.status or tbl.Team or tbl.team or tbl.PlayerRole or tbl.playerRole) end
    local function getPlayerRole(pl)
        if not pl then return "Innocent" end
        local function hasTool(n) if pl.Backpack and pl.Backpack:FindFirstChild(n) then return true end if pl.Character and pl.Character:FindFirstChild(n) then return true end return false end
        if hasTool("Knife") then return "Murderer" end
        if hasTool("Gun") or hasTool("Revolver") or hasTool("Pistol") then
            local cached=playerData[pl.Name] or playerData[pl] or playerData[pl.UserId]
            if type(cached)=="string" and cached:lower():find("hero") then return "Hero" end
            if type(cached)=="table" and readRoleFromTable(cached)=="Hero" then return "Hero" end; return "Sheriff"
        end
        for _,key in ipairs({pl,pl.Name,pl.UserId}) do local data=playerData[key] if data~=nil then if type(data)=="table" then local role=readRoleFromTable(data); if role then return role end else local role=normalizeRoleName(data); if role then return role end end end end
        for key,data in pairs(playerData) do
            local target=nil
            if typeof(key)=="Instance" and key:IsA("Player") then target=key elseif type(key)=="string" then target=Players:FindFirstChild(key) end
            if type(data)=="table" then local p=data.Player or data.player or data.PlayerName or data.playerName or data.Name or data.name if typeof(p)=="Instance" and p:IsA("Player") then target=p elseif type(p)=="string" then target=Players:FindFirstChild(p) end end
            if target==pl then if type(data)=="table" then local role=readRoleFromTable(data); if role then return role end else local role=normalizeRoleName(data); if role then return role end end end
        end
        return "Innocent"
    end
    local function isGoodGuy(pl) local r=getPlayerRole(pl) return r=="Sheriff" or r=="Hero" end
    local function findMurderer() for _,pl in ipairs(Players:GetPlayers()) do if getPlayerRole(pl)=="Murderer" then return pl end end return nil end
    local function findSheriff() for _,pl in ipairs(Players:GetPlayers()) do if isGoodGuy(pl) then return pl end end return nil end
    local function findSheriffThatsNotMe() for _,pl in ipairs(Players:GetPlayers()) do if pl~=localplayer and isGoodGuy(pl) then return pl end end return nil end
    local function getMap() for _,o in ipairs(workspace:GetChildren()) do if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then return o end end return nil end
    local function findNearestPlayer()
        local np=nil; local sd=math.huge
        for _,p in ipairs(Players:GetPlayers()) do if p~=localplayer and p.Character then local lrp=localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart"); local orp=p.Character:FindFirstChild("HumanoidRootPart"); if lrp and orp then local d=(lrp.Position-orp.Position).Magnitude if d<sd then sd=d; np=p end end end end
        return np
    end
    local function getPredictedPosition(tp)
        local char=tp and tp.Character; if not char then return Vector3.new(0,0,0) end
        local phrp=char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart"); local phum=char:FindFirstChild("Humanoid")
        if not phrp or not phum then return Vector3.new(0,0,0) end
        local vel=phrp.AssemblyLinearVelocity; local md=phum.MoveDirection
        local pred=phrp.Position+((vel*Vector3.new(0.75,0.5,0.75))*(shootOffset/15))+md*shootOffset
        local ping=0; pcall(function() ping=localplayer:GetNetworkPing()*1000 end); pred=pred*((ping*((offsetToPingMult-1)*0.01))+1); return pred
    end
    function miniFling(playerToFling)
        local Character=player.Character; local Humanoid=Character and Character:FindFirstChildOfClass("Humanoid"); local RootPart=Humanoid and Humanoid.RootPart
        local TCharacter=playerToFling and playerToFling.Character; if not TCharacter then notify("XDarkHUB","Нет цели."); return end
        local THumanoid=TCharacter:FindFirstChildOfClass("Humanoid"); local TRootPart=THumanoid and THumanoid.RootPart; local THead=TCharacter:FindFirstChild("Head")
        local Accessory=TCharacter:FindFirstChildOfClass("Accessory"); local Handle=Accessory and Accessory:FindFirstChild("Handle")
        if not (Character and Humanoid and RootPart) then notify("XDarkHUB","Нет персонажа."); return end
        pcall(function() Character.PrimaryPart=RootPart end); if RootPart.Velocity.Magnitude<50 then xdG.OldPos=RootPart.CFrame end
        local function setCam(s) pcall(function() workspace.CurrentCamera.CameraSubject=s end) end
        if THead then setCam(THead) elseif Handle then setCam(Handle) elseif THumanoid then setCam(THumanoid) end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then notify("XDarkHUB","Не за что флингануть."); return end
        local FPos=function(bp,pos,ang) RootPart.CFrame=CFrame.new(bp.Position)*pos*ang; pcall(function() Character:SetPrimaryPartCFrame(CFrame.new(bp.Position)*pos*ang) end); RootPart.Velocity=Vector3.new(9e7,9e7*10,9e7); RootPart.RotVelocity=Vector3.new(9e8,9e8,9e8) end
        local SFBasePart=function(bp)
            local Time=tick(); local Angle=0
            repeat
                if RootPart and THumanoid then
                    local trVel=(TRootPart and TRootPart.Velocity.Magnitude) or bp.Velocity.Magnitude
                    if bp.Velocity.Magnitude<50 then
                        Angle=Angle+100
                        FPos(bp,CFrame.new(0,1.5,0)+THumanoid.MoveDirection*bp.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0)); xdWait()
                        FPos(bp,CFrame.new(0,-1.5,0)+THumanoid.MoveDirection*bp.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0)); xdWait()
                        FPos(bp,CFrame.new(2.25,1.5,-2.25)+THumanoid.MoveDirection*bp.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0)); xdWait()
                        FPos(bp,CFrame.new(-2.25,-1.5,2.25)+THumanoid.MoveDirection*bp.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0)); xdWait()
                        FPos(bp,CFrame.new(0,1.5,0)+THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle),0,0)); xdWait()
                        FPos(bp,CFrame.new(0,-1.5,0)+THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle),0,0)); xdWait()
                    else
                        FPos(bp,CFrame.new(0,1.5,THumanoid.WalkSpeed),CFrame.Angles(math.rad(90),0,0)); xdWait()
                        FPos(bp,CFrame.new(0,-1.5,-THumanoid.WalkSpeed),CFrame.Angles(0,0,0)); xdWait()
                        FPos(bp,CFrame.new(0,1.5,trVel/1.25),CFrame.Angles(math.rad(90),0,0)); xdWait()
                        FPos(bp,CFrame.new(0,-1.5,-trVel/1.25),CFrame.Angles(0,0,0)); xdWait()
                        FPos(bp,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(-90),0,0)); xdWait()
                        FPos(bp,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0)); xdWait()
                    end
                else break end
            until bp.Velocity.Magnitude>500 or bp.Parent~=playerToFling.Character or playerToFling.Parent~=Players or (THumanoid and THumanoid.Sit) or Humanoid.Health<=0 or tick()>Time+2
        end
        local oldFPDH; pcall(function() oldFPDH=workspace.FallenPartsDestroyHeight; workspace.FallenPartsDestroyHeight=-1e6 end)
        local BV=Instance.new("BodyVelocity"); BV.Parent=RootPart; BV.Velocity=Vector3.new(9e8,9e8,9e8); BV.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
        if TRootPart and THead then if (TRootPart.CFrame.p-THead.CFrame.p).Magnitude>5 then SFBasePart(THead) else SFBasePart(TRootPart) end elseif TRootPart then SFBasePart(TRootPart) elseif THead then SFBasePart(THead) elseif Handle then SFBasePart(Handle) else notify("XDarkHUB","Не за что флингануть.") end
        BV:Destroy(); Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true); setCam(Humanoid)
        local oldPos=xdG.OldPos or RootPart.CFrame; local returnTime=tick()+3
        repeat RootPart.CFrame=oldPos*CFrame.new(0,0.5,0); pcall(function() Character:SetPrimaryPartCFrame(oldPos*CFrame.new(0,0.5,0)) end); Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp); for _,x in ipairs(Character:GetChildren()) do if x:IsA("BasePart") then x.Velocity=Vector3.new(); x.RotVelocity=Vector3.new() end end; xdWait() until (RootPart.Position-oldPos.p).Magnitude<25 or Humanoid.Health<=0 or tick()>returnTime
        pcall(function() workspace.FallenPartsDestroyHeight=oldFPDH or -500 end)
    end
    local espObjects={}; local trapHighlights={}; local gunHighlight=nil; local espWatcherRunning=false; local highlightParent=player:FindFirstChild("PlayerGui"); local highlightSupported=true; local refreshESP; local onRolesChanged
    local function newHighlight(props) if not highlightSupported then return nil end local ok,h=pcall(function() local obj=Instance.new("Highlight"); for k,v in pairs(props) do if k~="Parent" then obj[k]=v end end return obj end); if ok and h then return h end; highlightSupported=false; return nil end
    local function clearPlayerHighlight(pl) if espObjects[pl] then pcall(function() espObjects[pl]:Destroy() end); espObjects[pl]=nil end end
    refreshESP=function()
        if not playerESP then for _,h in pairs(espObjects) do pcall(function() h:Destroy() end) end; espObjects={}; return end
        if not highlightSupported then return end; if not highlightParent then highlightParent=player:FindFirstChild("PlayerGui") end; if not highlightParent then return end
        local alive={}
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=localplayer or not hideMeEsp then
                local char=pl.Character
                if char and char.Parent then
                    alive[pl]=true; local h=espObjects[pl]
                    if not h or not h.Parent then h=newHighlight({FillTransparency=0.5,OutlineTransparency=0,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop}); if not h then return end; pcall(function() h.Parent=highlightParent end); espObjects[pl]=h end
                    h.Adornee=char; local role=getPlayerRole(pl); local color
                    if role=="Murderer" then color=Color3.fromRGB(255,0,4) elseif role=="Sheriff" then color=Color3.fromRGB(0,153,255) elseif role=="Hero" then color=Color3.fromRGB(255,200,0) else color=Color3.fromRGB(0,255,8) end
                    h.FillColor=color; h.OutlineColor=color
                else clearPlayerHighlight(pl) end
            else clearPlayerHighlight(pl) end
        end
        for pl in pairs(espObjects) do if not alive[pl] then clearPlayerHighlight(pl) end end
    end
    local function ensureEspWatcher() if espWatcherRunning then return end; espWatcherRunning=true; xdSpawn(function() while playerESP do pcall(refreshESP); xdWait(0.8) end; espWatcherRunning=false end) end
    onRolesChanged=function() xdSpawn(function() if playerESP then pcall(refreshESP) end; if updateRoleUI then pcall(updateRoleUI) end end) end
    local function reloadTrapESP()
        for _,h in pairs(trapHighlights) do pcall(function() h:Destroy() end) end; trapHighlights={}
        if not trapDetection or not highlightSupported then return end; if not highlightParent then highlightParent=player:FindFirstChild("PlayerGui") end; if not highlightParent then return end
        for _,v in ipairs(workspace:GetDescendants()) do if v.Name=="Trap" and v.Parent and (v.Parent:IsA("Folder") or v.Parent:IsA("Model")) then local h=newHighlight({FillColor=Color3.fromRGB(255,0,0),OutlineColor=Color3.fromRGB(255,0,0),FillTransparency=0.5,OutlineTransparency=0,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,Adornee=v}); if h then pcall(function() h.Parent=highlightParent end); trapHighlights[v]=h end; if v:IsA("BasePart") then v.Transparency=0 end end end
    end
    local function reloadGunESP()
        if gunHighlight then pcall(function() gunHighlight:Destroy() end); gunHighlight=nil end
        if not gunDropESP or not highlightSupported then return end; if not highlightParent then highlightParent=player:FindFirstChild("PlayerGui") end; if not highlightParent then return end
        local map=getMap(); if map and map:FindFirstChild("GunDrop") then gunHighlight=newHighlight({FillColor=Color3.fromRGB(255,255,0),OutlineColor=Color3.fromRGB(255,255,0),FillTransparency=0.5,OutlineTransparency=0,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,Adornee=map:FindFirstChild("GunDrop")}); if gunHighlight then pcall(function() gunHighlight.Parent=highlightParent end) end end
    end
    function shootMurderer()
        if findSheriff()~=localplayer then notify("XDarkHUB","Ты не шериф и не герой."); return end
        local murderer=findMurderer() or findSheriffThatsNotMe(); if not murderer or not murderer.Character then notify("XDarkHUB","Нет убийцы для выстрела."); return end
        if not localplayer.Character:FindFirstChild("Gun") then local hum=localplayer.Character:FindFirstChild("Humanoid"); local bpGun=localplayer.Backpack and localplayer.Backpack:FindFirstChild("Gun"); if hum and bpGun then hum:EquipTool(bpGun); xdWait(0.15) end end
        local gun=localplayer.Character and localplayer.Character:FindFirstChild("Gun"); if not gun then notify("XDarkHUB","У тебя нет пистолета."); return end
        if not (murderer.Character:FindFirstChild("Head") or murderer.Character:FindFirstChild("HumanoidRootPart")) then notify("XDarkHUB","Не найдена цель."); return end
        xdSpawn(function() for shot=1,3 do local mhrp=murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart"); if not mhrp then break end; local predicted=getPredictedPosition(murderer); local aim=instakillshoot and (mhrp.Position+Vector3.new(0,1,0)) or predicted; local rh=localplayer.Character:FindFirstChild("RightHand"); local origin=rh and rh.Position or localplayer.Character:GetPivot().Position; pcall(function() gun:WaitForChild("Shoot"):FireServer(CFrame.new(origin),CFrame.new(aim)) end); xdWait(0.12) end; notify("XDarkHUB","Очередь по убийце!") end)
    end
    function knifeThrow()
        if findMurderer()~=localplayer then notify("XDarkHUB","Ты не убийца."); return end
        if not localplayer.Character:FindFirstChild("Knife") then local hum=localplayer.Character:FindFirstChild("Humanoid"); if localplayer.Backpack:FindFirstChild("Knife") then hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife")) else notify("XDarkHUB","У тебя нет ножа."); return end end
        local Nearest=findNearestPlayer(); if not Nearest or not Nearest.Character then notify("XDarkHUB","Не найден игрок."); return end
        local nhrp=Nearest.Character:FindFirstChild("HumanoidRootPart"); if not nhrp then return end
        local rh=localplayer.Character:FindFirstChild("RightHand"); local origin=rh and rh.Position or localplayer.Character:GetPivot().Position; local args={CFrame.new(origin),CFrame.new(getPredictedPosition(Nearest))}
        if spawnAtPlayer then args[1]=CFrame.new(nhrp.Position+(nhrp.CFrame.LookVector*5)) end
        pcall(function() localplayer.Character:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(unpack(args)) end); notify("XDarkHUB","Нож брошен!")
    end
    function killClosest()
        if findMurderer()~=localplayer then notify("XDarkHUB","Ты не убийца."); return end
        if not localplayer.Character:FindFirstChild("Knife") then local hum=localplayer.Character:FindFirstChild("Humanoid"); if localplayer.Backpack:FindFirstChild("Knife") then hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife")) else notify("XDarkHUB","У тебя нет ножа."); return end end
        local Nearest=findNearestPlayer(); if not Nearest or not Nearest.Character then notify("XDarkHUB","Не найден игрок."); return end
        local nhrp=Nearest.Character:FindFirstChild("HumanoidRootPart"); local myHRP=localplayer.Character:FindFirstChild("HumanoidRootPart"); if not nhrp or not myHRP then return end
        nhrp.Anchored=true; nhrp.CFrame=myHRP.CFrame+myHRP.CFrame.LookVector*2; xdWait(0.1); pcall(function() localplayer.Character:WaitForChild("Knife"):WaitForChild("Stab"):FireServer("Slash") end); notify("XDarkHUB","Убил ближайшего!")
    end
    function killEveryone()
        if findMurderer()~=localplayer then notify("XDarkHUB","Ты не убийца."); return end
        if not localplayer.Character:FindFirstChild("Knife") then local hum=localplayer.Character:FindFirstChild("Humanoid"); if localplayer.Backpack:FindFirstChild("Knife") then hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife")) else notify("XDarkHUB","У тебя нет ножа."); return end end
        local myHRP=localplayer.Character:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
        for _,p in ipairs(Players:GetPlayers()) do if p~=localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.Anchored=true; p.Character.HumanoidRootPart.CFrame=myHRP.CFrame+myHRP.CFrame.LookVector*1 end end
        pcall(function() localplayer.Character:WaitForChild("Knife"):WaitForChild("Stab"):FireServer("Slash") end); notify("XDarkHUB","Убил всех!")
    end
    function holdHostage()
        if findMurderer()~=localplayer then notify("XDarkHUB","Ты не убийца."); return end
        local myHRP=localplayer.Character:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
        for _,p in ipairs(Players:GetPlayers()) do if p~=localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.Anchored=true; p.Character.HumanoidRootPart.CFrame=myHRP.CFrame+myHRP.CFrame.LookVector*5 end end
        notify("XDarkHUB","Все взяты в заложники!")
    end
    function godMode()
        local Cam=workspace.CurrentCamera; local Pos,Char=Cam.CFrame,localplayer.Character; local Human=Char and Char:FindFirstChildWhichIsA("Humanoid"); if not Human then notify("XDarkHUB","Нет гуманоида."); return end
        local nHuman=Human:Clone(); nHuman.Parent=Char; localplayer.Character=nil; nHuman:SetStateEnabled(15,false); nHuman:SetStateEnabled(1,false); nHuman:SetStateEnabled(0,false); nHuman.BreakJointsOnDeath=true; Human:Destroy(); localplayer.Character=Char
        Cam.CameraSubject=nHuman; Cam.CFrame=Pos; nHuman.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
        local Script=Char:FindFirstChild("Animate"); if Script then Script.Disabled=true; xdWait(); Script.Disabled=false end; nHuman.Health=nHuman.MaxHealth; notify("XDarkHUB","God mode активирован!")
    end
    function teleportToGun()
        local map=getMap(); if not map or not map:FindFirstChild("GunDrop") then notify("XDarkHUB","Нет выпавшего пистолета."); return end
        local prev=localplayer.Character:GetPivot(); localplayer.Character:PivotTo(map:FindFirstChild("GunDrop"):GetPivot()); localplayer.Backpack.ChildAdded:Wait(); localplayer.Character:PivotTo(prev); notify("XDarkHUB","Пистолет подобран!")
    end
    function teleportToLobby() local lobby=workspace:FindFirstChild("Lobby"); if lobby and lobby:FindFirstChild("Spawns") then local spawn=lobby.Spawns:FindFirstChildWhichIsA("SpawnLocation"); if spawn then localplayer.Character:MoveTo(spawn.Position); notify("XDarkHUB","Телепорт в лобби!") end end end
    function teleportToMap() local map=getMap(); if not map then notify("XDarkHUB","Нет карты для телепорта."); return end; local sf=map:FindFirstChild("Spawns"); if sf then local spawns=sf:GetChildren(); if #spawns>0 then localplayer.Character:MoveTo(spawns[math.random(1,#spawns)].Position); notify("XDarkHUB","Телепорт на карту!") end end end
    function sendNamesToChat()
        local murd=findMurderer(); local sher=findSheriff(); local message=string.format("Murderer: %s | Sheriff: %s | <<XDarkHUB>>",murd and murd.Name or "-",sher and sher.Name or "-")
        pcall(function() local channels=TextChatService:FindFirstChild("TextChannels"); if channels then for _,tc in ipairs(channels:GetChildren()) do if tc.Name~="RBXSystem" then pcall(function() tc:SendAsync(message) end) end end end end); notify("XDarkHUB","Имена отправлены в чат!")
    end
    function copyMurdererName() local murd=findMurderer(); if not murd then notify("XDarkHUB","Нет убийцы."); return end; if setclipboard then setclipboard(murd.Name); notify("XDarkHUB","Скопировано: "..murd.Name) end end
    function copySheriffName() local sher=findSheriff(); if not sher then notify("XDarkHUB","Нет шерифа."); return end; if setclipboard then setclipboard(sher.Name); notify("XDarkHUB","Скопировано: "..sher.Name) end end
    xdSpawn(function() while xdWait(0.5) do if autoShooting and findSheriff()==localplayer then pcall(function() local murderer=findMurderer(); if murderer and murderer.Character and localplayer.Character then if not localplayer.Character:FindFirstChild("Gun") then local hum=localplayer.Character:FindFirstChild("Humanoid"); local bp=localplayer.Backpack and localplayer.Backpack:FindFirstChild("Gun"); if hum and bp then hum:EquipTool(bp) end end; local gun=localplayer.Character:FindFirstChild("Gun"); local mhrp=murderer.Character:FindFirstChild("HumanoidRootPart"); if gun and mhrp then local predicted=getPredictedPosition(murderer); local rh=localplayer.Character:FindFirstChild("RightHand"); local origin=rh and rh.Position or localplayer.Character:GetPivot().Position; gun:WaitForChild("Shoot"):FireServer(CFrame.new(origin),CFrame.new(predicted)) end end end) end end end)
    xdSpawn(function() while xdWait(1.5) do if loopThrow then pcall(function() knifeThrow() end) end end end)
    function toggleKillAura(state)
        if state then
            if killAuraCon then killAuraCon:Disconnect() end
            killAuraCon=RunService.Heartbeat:Connect(function() pcall(function() if findMurderer()~=localplayer then return end; local myHRP=localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart"); if not myHRP then return end; for _,p in ipairs(Players:GetPlayers()) do if p~=localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local hrp=p.Character.HumanoidRootPart; if (hrp.Position-myHRP.Position).Magnitude<7 then hrp.Anchored=true; hrp.CFrame=myHRP.CFrame+myHRP.CFrame.LookVector*2; xdWait(0.1); pcall(function() localplayer.Character:WaitForChild("Knife"):WaitForChild("Stab"):FireServer("Slash") end); return end end end end) end)
        else if killAuraCon then killAuraCon:Disconnect() end; killAuraCon=nil end
    end
    workspace.DescendantAdded:Connect(function(ch) pcall(function() if trapDetection and ch.Name=="Trap" and ch.Parent and (ch.Parent:IsA("Folder") or ch.Parent:IsA("Model")) then if ch:IsA("BasePart") then ch.Transparency=0 end; reloadTrapESP(); notify("XDarkHUB","Убийца поставил ловушку!") end; if gunDropESP and ch.Name=="GunDrop" then reloadGunESP(); notify("XDarkHUB","Пистолет выпал!"); if autoGetDroppedGun then xdWait(1); local map=getMap(); if not map or not map:FindFirstChild("GunDrop") then return end; local prev=localplayer.Character:GetPivot(); localplayer.Character:MoveTo(map:FindFirstChild("GunDrop").Position); localplayer.Backpack.ChildAdded:Wait(); localplayer.Character:PivotTo(prev) end end end) end)
    workspace.DescendantRemoving:Connect(function(ch) pcall(function() if gunDropESP and ch.Name=="GunDrop" then reloadGunESP() end; if trapDetection and ch.Name=="Trap" then reloadTrapESP() end end) end)
    workspace.ChildAdded:Connect(function(chi) if chi.Name=="ThrowingKnife" and ignoreknifethrow then chi:Destroy() end end)
    local function applyRolePayload(payload,sourceName)
        local changed=false
        local function setRole(pl,raw) local role=normalizeRoleName(raw); if pl and role then playerData[pl]=role; playerData[pl.Name]=role; playerData[pl.UserId]=role; changed=true end end
        if type(payload)=="table" then
            local explicit=readRoleFromTable(payload); if explicit then setRole(localplayer,explicit) end
            for k,v in pairs(payload) do
                local target=nil; if typeof(k)=="Instance" and k:IsA("Player") then target=k elseif type(k)=="string" then target=Players:FindFirstChild(k) end
                if target then if type(v)=="table" then setRole(target,readRoleFromTable(v)) else setRole(target,v) end
                elseif type(v)=="table" then local p=v.Player or v.player or v.PlayerName or v.playerName or v.Name or v.name; if typeof(p)=="Instance" and p:IsA("Player") then target=p elseif type(p)=="string" then target=Players:FindFirstChild(p) end; if target then setRole(target,readRoleFromTable(v)) end end
            end
        elseif type(payload)=="string" or type(payload)=="number" then local rn=tostring(sourceName or ""):lower(); if rn:find("role") or rn:find("playerdata") or rn:find("gamedata") or rn:find("game") then setRole(localplayer,payload) end end
        if changed and onRolesChanged then onRolesChanged() end
    end
    pcall(function() local remotes=ReplicatedStorage:FindFirstChild("Remotes"); if remotes then local gameplay=remotes:FindFirstChild("Gameplay"); if gameplay then local pd=gameplay:FindFirstChild("PlayerDataChanged"); if pd and pd:IsA("RemoteEvent") then pd.OnClientEvent:Connect(function(...) for _,arg in ipairs({...}) do applyRolePayload(arg,"PlayerDataChanged") end end) end end end end)
    pcall(function() local connected={}; local function hookRemote(inst) if connected[inst] then return end; if inst:IsA("RemoteEvent") then connected[inst]=true; pcall(function() inst.OnClientEvent:Connect(function(...) for _,arg in ipairs({...}) do applyRolePayload(arg,inst.Name) end end) end) end end; for _,inst in ipairs(ReplicatedStorage:GetDescendants()) do hookRemote(inst) end; ReplicatedStorage.DescendantAdded:Connect(hookRemote) end)
    pcall(function() local hookedPlayers={}; local function hookPlayerRoleEvents(pl) if hookedPlayers[pl] then return end; hookedPlayers[pl]=true; pcall(function() pl.CharacterAdded:Connect(function(char) xdWait(0.1); if onRolesChanged then onRolesChanged() end; pcall(function() char.ChildAdded:Connect(function() xdWait(0.05); if onRolesChanged then onRolesChanged() end end); char.ChildRemoved:Connect(function() xdWait(0.05); if onRolesChanged then onRolesChanged() end end) end) end) end); pcall(function() if pl.Backpack then pl.Backpack.ChildAdded:Connect(function() if onRolesChanged then onRolesChanged() end end); pl.Backpack.ChildRemoved:Connect(function() if onRolesChanged then onRolesChanged() end end) end end) end; for _,pl in ipairs(Players:GetPlayers()) do hookPlayerRoleEvents(pl) end; Players.PlayerAdded:Connect(hookPlayerRoleEvents); Players.PlayerRemoving:Connect(function(pl) hookedPlayers[pl]=nil; playerData[pl]=nil; playerData[pl.Name]=nil; playerData[pl.UserId]=nil; if clearPlayerHighlight then clearPlayerHighlight(pl) end end) end)

    -- ================= ВИЗУАЛЫ (полная геометрия + bloom в красном) =================
    local visualState={wings=false,circle=false,halo=false,aura=false,fire=false,smoke=false,trails=false,eyes=false,light=false,lightning=false}
    local visualObjects={}; local wingFeathers={}; local wingMembranes={}; local wingSpine=nil; local wingSpineGlow=nil
    local circleGlow=nil; local circleInnerDisc=nil; local circleCore=nil; local circleOuterSegs={}; local circleMiddleSegs={}; local circleRunes={}; local circleOrbs={}; local circlePillars={}; local gyroRing1={}; local gyroRing2={}; local circleColumn=nil; local circleColumnInner=nil; local circleLight=nil
    local haloDisc=nil; local haloDiscGlow=nil; local haloMotes={}; local eyeParts={}
    local function registerVisual(name,obj) visualObjects[name]=visualObjects[name] or {}; table.insert(visualObjects[name],obj) end
    local function clearVisual(name)
        if visualObjects[name] then for _,obj in ipairs(visualObjects[name]) do pcall(function() obj:Destroy() end) end; visualObjects[name]=nil end
        if name=="wings" then wingFeathers={}; wingMembranes={}; wingSpine=nil; wingSpineGlow=nil end
        if name=="circle" then circleGlow=nil; circleInnerDisc=nil; circleCore=nil; circleOuterSegs={}; circleMiddleSegs={}; circleRunes={}; circleOrbs={}; circlePillars={}; gyroRing1={}; gyroRing2={}; circleColumn=nil; circleColumnInner=nil; circleLight=nil end
        if name=="halo" then haloDisc=nil; haloDiscGlow=nil; haloMotes={} end
        if name=="eyes" then eyeParts={} end
    end
    local function clearAllVisuals() local names={}; for name in pairs(visualObjects) do table.insert(names,name) end; for _,name in ipairs(names) do clearVisual(name) end; wingFeathers={}; wingMembranes={}; wingSpine=nil; wingSpineGlow=nil; circleGlow=nil; circleInnerDisc=nil; circleCore=nil; circleOuterSegs={}; circleMiddleSegs={}; circleRunes={}; circleOrbs={}; circlePillars={}; gyroRing1={}; gyroRing2={}; circleColumn=nil; circleColumnInner=nil; circleLight=nil; haloDisc=nil; haloDiscGlow=nil; haloMotes={}; eyeParts={} end
    local function makeNeonPart(props) local p=Instance.new("Part"); p.Material=Enum.Material.Neon; p.Anchored=true; p.CanCollide=false; p.CastShadow=false; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; for k,v in pairs(props) do p[k]=v end; return p end
    local function makeSmoothPart(props,meshScale) local p=Instance.new("Part"); p.Material=Enum.Material.Neon; p.Anchored=true; p.CanCollide=false; p.CastShadow=false; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; for k,v in pairs(props) do p[k]=v end; p.Size=Vector3.new(1,1,1); pcall(function() local m=Instance.new("SpecialMesh"); m.MeshType=Enum.MeshType.Sphere; m.Scale=meshScale; m.Parent=p end); return p end
    local function glowClone(src,extraScale,transp) local g=src:Clone(); g.Name=src.Name.."_glow"; g.Transparency=transp or 0.6; if g:FindFirstChildOfClass("SpecialMesh") then local m0=src:FindFirstChildOfClass("SpecialMesh"); g:FindFirstChildOfClass("SpecialMesh").Scale=m0.Scale*(extraScale or 1.6) else g.Size=src.Size*(extraScale or 1.6) end; g.Parent=src.Parent; return g end
    local function applyWings()
        clearVisual("wings"); local char=player.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local darkRed=Color3.fromRGB(150,12,28); local midRed=Color3.fromRGB(255,70,85); local emberC=Color3.fromRGB(255,130,95); local gold=Color3.fromRGB(255,210,130); local featherLite=Color3.fromRGB(255,180,180); local glowC=Color3.fromRGB(255,35,50)
        for side=-1,1,2 do
            local membrane=makeSmoothPart({Name="XDarkMembrane",Color=Color3.fromRGB(120,8,24),Transparency=0.6,Parent=char},Vector3.new(0.22,3.6,3.0))
            local membraneGlow=glowClone(membrane,1.5,0.78); membraneGlow.Color=glowC
            registerVisual("wings",membrane); registerVisual("wings",membraneGlow); table.insert(wingMembranes,{part=membrane,glow=membraneGlow,side=side})
            for i=1,9 do
                local t=i/9; local len1=2.4-t*1.0; local len2=1.8-t*0.8; local width=1.15-t*0.5
                local base=makeSmoothPart({Name="XDarkPrimB",Color=darkRed:lerp(midRed,t*0.55),Transparency=0.04,Parent=char},Vector3.new(0.42,len1,width))
                local baseGlow=glowClone(base,1.5,0.66); baseGlow.Color=glowC
                local tip=makeSmoothPart({Name="XDarkPrimT",Color=midRed:lerp(featherLite,t*t),Transparency=0.03+t*0.1,Parent=char},Vector3.new(0.36,len2,width*0.7))
                registerVisual("wings",base); registerVisual("wings",baseGlow); registerVisual("wings",tip)
                table.insert(wingFeathers,{base=base,glow=baseGlow,tip=tip,len1=len1,len2=len2,side=side,i=i,layer="prim",curve=0.18+t*0.24})
            end
            for i=1,6 do
                local t=i/6; local len1=1.6-t*0.5; local len2=1.0-t*0.3
                local base=makeSmoothPart({Name="XDarkSecB",Color=midRed:lerp(emberC,t*0.5),Transparency=0.06,Parent=char},Vector3.new(0.36,len1,0.75-t*0.2))
                local tip=makeSmoothPart({Name="XDarkSecT",Color=emberC,Transparency=0.06,Parent=char},Vector3.new(0.3,len2,0.58-t*0.15))
                registerVisual("wings",base); registerVisual("wings",tip)
                table.insert(wingFeathers,{base=base,tip=tip,len1=len1,len2=len2,side=side,i=i,layer="sec",curve=0.12})
            end
            for i=1,4 do
                local cov=makeSmoothPart({Name="XDarkCovert",Color=gold,Transparency=0.08,Parent=char},Vector3.new(0.32,0.75-i*0.1,0.5))
                registerVisual("wings",cov); table.insert(wingFeathers,{base=cov,tip=nil,len1=0.75-i*0.1,len2=0,side=side,i=i,layer="cov",curve=0})
            end
        end
        wingSpine=makeSmoothPart({Name="XDarkSpine",Color=Color3.fromRGB(255,70,90),Transparency=0.05,Parent=char},Vector3.new(0.42,2.0,0.42))
        wingSpineGlow=glowClone(wingSpine,1.5,0.6); wingSpineGlow.Color=glowC
        registerVisual("wings",wingSpine); registerVisual("wings",wingSpineGlow)
        local att=Instance.new("Attachment",hrp); att.Position=Vector3.new(0,1.2,1); registerVisual("wings",att)
        local em=Instance.new("ParticleEmitter",att); em.Texture="rbxasset://textures/particles/sparkles_main.dds"; em.Color=ColorSequence.new(Color3.fromRGB(255,120,120),Color3.fromRGB(255,200,120)); em.Rate=45; em.Lifetime=NumberRange.new(0.6,1.3); em.Speed=NumberRange.new(1,3.5); em.SpreadAngle=Vector2.new(180,180); em.LightEmission=1; em.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.32),NumberSequenceKeypoint.new(1,0)}); registerVisual("wings",em)
        local wingLight=Instance.new("PointLight"); wingLight.Color=Color3.fromRGB(255,55,70); wingLight.Brightness=3.0; wingLight.Range=22; wingLight.Parent=hrp; registerVisual("wings",wingLight)
    end
    local function applyCircle()
        clearVisual("circle"); local char=player.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        circleGlow=makeNeonPart({Name="XDarkGlow",Shape=Enum.PartType.Cylinder,Size=Vector3.new(0.15,11,11),Color=Color3.fromRGB(180,15,35),Transparency=0.78,Parent=char}); registerVisual("circle",circleGlow)
        circleInnerDisc=makeNeonPart({Name="XDarkInner",Shape=Enum.PartType.Cylinder,Size=Vector3.new(0.16,4.4,4.4),Color=Color3.fromRGB(255,70,90),Transparency=0.55,Parent=char}); registerVisual("circle",circleInnerDisc)
        circleCore=makeNeonPart({Name="XDarkCore",Shape=Enum.PartType.Cylinder,Size=Vector3.new(0.18,2.0,2.0),Color=Color3.fromRGB(255,170,100),Transparency=0.35,Parent=char}); registerVisual("circle",circleCore)
        for k=1,16 do local seg=makeNeonPart({Name="XDarkOutSeg",Size=Vector3.new(1.5,0.12,0.28),Color=Color3.fromRGB(255,40,60),Transparency=0.15,Parent=char}); registerVisual("circle",seg); table.insert(circleOuterSegs,{part=seg,k=k}) end
        for k=1,12 do local seg=makeNeonPart({Name="XDarkMidSeg",Size=Vector3.new(1.3,0.12,0.24),Color=Color3.fromRGB(255,130,80),Transparency=0.2,Parent=char}); registerVisual("circle",seg); table.insert(circleMiddleSegs,{part=seg,k=k}) end
        for k=1,8 do local rune=makeNeonPart({Name="XDarkRune",Size=Vector3.new(0.5,0.5,0.12),Color=Color3.fromRGB(255,210,120),Transparency=0.1,Parent=char}); registerVisual("circle",rune); table.insert(circleRunes,{part=rune,k=k}) end
        for k=1,8 do local orb=makeNeonPart({Name="XDarkOrb",Shape=Enum.PartType.Ball,Size=Vector3.new(0.34,0.34,0.34),Color=(k%2==0) and Color3.fromRGB(255,190,100) or Color3.fromRGB(255,60,80),Transparency=0.08,Parent=char}); registerVisual("circle",orb); table.insert(circleOrbs,{part=orb,k=k}) end
        for k=1,6 do local pillar=makeNeonPart({Name="XDarkPillar",Size=Vector3.new(0.18,7,0.18),Color=Color3.fromRGB(255,70,90),Transparency=0.55,Parent=char}); registerVisual("circle",pillar); table.insert(circlePillars,{part=pillar,k=k}) end
        for k=1,14 do local orb=makeNeonPart({Name="XDarkGyro1",Shape=Enum.PartType.Ball,Size=Vector3.new(0.22,0.22,0.22),Color=Color3.fromRGB(255,95,110),Transparency=0.1,Parent=char}); registerVisual("circle",orb); table.insert(gyroRing1,{part=orb,k=k}) end
        for k=1,14 do local orb=makeNeonPart({Name="XDarkGyro2",Shape=Enum.PartType.Ball,Size=Vector3.new(0.18,0.18,0.18),Color=Color3.fromRGB(255,185,105),Transparency=0.12,Parent=char}); registerVisual("circle",orb); table.insert(gyroRing2,{part=orb,k=k}) end
        circleColumn=makeNeonPart({Name="XDarkColumn",Shape=Enum.PartType.Cylinder,Size=Vector3.new(8,0.9,0.9),Color=Color3.fromRGB(255,65,85),Transparency=0.68,Parent=char}); registerVisual("circle",circleColumn)
        circleColumnInner=makeNeonPart({Name="XDarkColumnIn",Shape=Enum.PartType.Cylinder,Size=Vector3.new(8,0.35,0.35),Color=Color3.fromRGB(255,200,120),Transparency=0.4,Parent=char}); registerVisual("circle",circleColumnInner)
        local att=Instance.new("Attachment",hrp); att.Position=Vector3.new(0,-3,0); registerVisual("circle",att)
        local em=Instance.new("ParticleEmitter",att); em.Texture="rbxasset://textures/particles/sparkles_main.dds"; em.Color=ColorSequence.new(Color3.fromRGB(255,60,80),Color3.fromRGB(255,180,100)); em.Rate=60; em.Lifetime=NumberRange.new(0.9,1.6); em.Speed=NumberRange.new(3,6); em.SpreadAngle=Vector2.new(180,180); em.LightEmission=1; em.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.35),NumberSequenceKeypoint.new(1,0)}); em.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(1,1)}); registerVisual("circle",em)
        circleLight=Instance.new("PointLight"); circleLight.Color=Color3.fromRGB(255,50,70); circleLight.Brightness=2.6; circleLight.Range=22; circleLight.Parent=hrp; registerVisual("circle",circleLight)
    end
    local function applyHalo()
        clearVisual("halo"); local char=player.Character; local head=char and char:FindFirstChild("Head"); if not head then return end
        haloDisc=makeNeonPart({Name="XDarkHalo",Shape=Enum.PartType.Cylinder,Size=Vector3.new(0.12,2.6,2.6),Color=Color3.fromRGB(255,170,170),Transparency=0.12,Parent=char}); registerVisual("halo",haloDisc)
        haloDiscGlow=glowClone(haloDisc,1.7,0.6); haloDiscGlow.Color=Color3.fromRGB(255,40,55); registerVisual("halo",haloDiscGlow)
        for k=1,6 do local mote=makeNeonPart({Name="XDarkHaloMote",Shape=Enum.PartType.Ball,Size=Vector3.new(0.18,0.18,0.18),Color=Color3.fromRGB(255,130,100),Transparency=0.1,Parent=char}); registerVisual("halo",mote); table.insert(haloMotes,{part=mote,k=k}) end
        local hl=Instance.new("PointLight"); hl.Color=Color3.fromRGB(255,60,70); hl.Brightness=2.4; hl.Range=12; hl.Parent=head; registerVisual("halo",hl)
    end
    local function applyEmitter(name,texture,c1,c2,rate,speed,spread,sizeStart,attPos,emissionDir)
        clearVisual(name); local char=player.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local att=Instance.new("Attachment",hrp); att.Position=attPos or Vector3.new(0,0,0); registerVisual(name,att)
        local em=Instance.new("ParticleEmitter",att); em.Texture=texture; em.Color=ColorSequence.new(c1,c2); em.Rate=rate; em.Lifetime=NumberRange.new(0.6,1.2); em.Speed=NumberRange.new(speed*0.6,speed); em.SpreadAngle=Vector2.new(spread,spread); em.LightEmission=1
        if emissionDir then em.EmissionDirection=emissionDir end
        em.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,sizeStart),NumberSequenceKeypoint.new(1,0)}); em.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(1,1)}); registerVisual(name,em)
    end
    local function applyTrails()
        clearVisual("trails"); local char=player.Character; if not char then return end
        for _,hn in ipairs({"LeftHand","RightHand","Left Arm","Right Arm"}) do local hand=char:FindFirstChild(hn); if hand then local a0=Instance.new("Attachment",hand); a0.Position=Vector3.new(0,0.35,0); local a1=Instance.new("Attachment",hand); a1.Position=Vector3.new(0,-0.35,0); local trail=Instance.new("Trail",hand); trail.Attachment0=a0; trail.Attachment1=a1; trail.Color=ColorSequence.new(Color3.fromRGB(255,45,60),Color3.fromRGB(255,150,80)); trail.Lifetime=0.45; trail.LightEmission=1; trail.LightInfluence=0; trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.15),NumberSequenceKeypoint.new(1,1)}); registerVisual("trails",a0); registerVisual("trails",a1); registerVisual("trails",trail) end end
    end
    local function applyEyes()
        clearVisual("eyes"); local char=player.Character; local head=char and char:FindFirstChild("Head"); if not head then return end
        for side=-1,1,2 do local eye=makeNeonPart({Name="XDarkEye",Size=Vector3.new(0.12,0.14,0.14),Color=Color3.fromRGB(255,30,50),Transparency=0,Parent=char}); registerVisual("eyes",eye); table.insert(eyeParts,{part=eye,side=side}) end
        local el=Instance.new("PointLight"); el.Color=Color3.fromRGB(255,35,55); el.Brightness=0.9; el.Range=7; el.Parent=head; registerVisual("eyes",el)
    end
    local function applyLight() clearVisual("light"); local char=player.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end; local l=Instance.new("PointLight"); l.Color=Color3.fromRGB(255,40,60); l.Brightness=2.4; l.Range=20; l.Parent=hrp; registerVisual("light",l) end
    local function applyLightning() clearVisual("lightning"); local char=player.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end; local att=Instance.new("Attachment",hrp); registerVisual("lightning",att); local em=Instance.new("ParticleEmitter",att); em.Texture="rbxasset://textures/particles/sparkles_main.dds"; em.Color=ColorSequence.new(Color3.fromRGB(255,220,180),Color3.fromRGB(255,60,60)); em.Rate=70; em.Lifetime=NumberRange.new(0.08,0.25); em.Speed=NumberRange.new(8,15); em.SpreadAngle=Vector2.new(180,180); em.LightEmission=1; em.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.22),NumberSequenceKeypoint.new(1,0)}); registerVisual("lightning",em) end
    local function applyVisual(name)
        if name=="wings" then applyWings() elseif name=="circle" then applyCircle() elseif name=="halo" then applyHalo()
        elseif name=="aura" then applyEmitter("aura","rbxasset://textures/particles/sparkles_main.dds",Color3.fromRGB(255,55,70),Color3.fromRGB(255,150,80),55,4,180,0.45,Vector3.new(0,-0.5,0),nil)
        elseif name=="fire" then applyEmitter("fire","rbxasset://textures/particles/fire_main.dds",Color3.fromRGB(255,80,50),Color3.fromRGB(150,0,0),45,5,22,1.1,Vector3.new(0,-2.6,0),Enum.NormalId.Top)
        elseif name=="smoke" then applyEmitter("smoke","rbxasset://textures/particles/smoke_main.dds",Color3.fromRGB(100,8,18),Color3.fromRGB(35,0,6),30,2.5,30,1.5,Vector3.new(0,-2.2,0),Enum.NormalId.Top)
        elseif name=="trails" then applyTrails() elseif name=="eyes" then applyEyes() elseif name=="light" then applyLight() elseif name=="lightning" then applyLightning() end
    end
    local function applyVisualSafe(name) pcall(function() applyVisual(name) end) end
    local function reapplyVisuals() clearAllVisuals(); for name,on in pairs(visualState) do if on then applyVisualSafe(name) end end end
    RunService.Heartbeat:Connect(function()
        pcall(function()
            local char=player.Character; if not char then return end; local hrp=char:FindFirstChild("HumanoidRootPart"); local t=tick()
            if visualState.wings and hrp and #wingFeathers>0 then
                local bob=math.sin(t*2.4+0.5)*0.1; local flap=math.sin(t*2.4)
                for _,f in ipairs(wingFeathers) do
                    if f.base.Parent then
                        local i,side=f.i,f.side; local baseCF
                        if f.layer=="prim" then
                            local phase=math.sin(t*2.4-i*0.22); local spread=12+i*8+phase*16*(0.4+i*0.07); local lift=-4-i*2+phase*8; local zSweep=0.78+i*0.045
                            baseCF=hrp.CFrame*CFrame.new(side*(0.35+i*0.17),1.55-i*0.1+bob,zSweep)*CFrame.Angles(0,math.rad(side*spread),math.rad(side*lift))
                        elseif f.layer=="sec" then
                            local phase=math.sin(t*2.4-i*0.28); local spread=8+i*11+phase*10
                            baseCF=hrp.CFrame*CFrame.new(side*(0.3+i*0.12),1.05-i*0.12+bob,0.62)*CFrame.Angles(0,math.rad(side*spread),math.rad(side*-3))
                        else
                            local spread=5+i*14; baseCF=hrp.CFrame*CFrame.new(side*(0.28+i*0.1),0.75-i*0.1+bob,0.55)*CFrame.Angles(0,math.rad(side*spread),0)
                        end
                        f.base.CFrame=baseCF*CFrame.new(0,f.len1/2,0)
                        if f.glow and f.glow.Parent then f.glow.CFrame=f.base.CFrame end
                        if f.tip then f.tip.CFrame=baseCF*CFrame.new(0,f.len1+f.len2/2,f.curve)*CFrame.Angles(math.rad(20),0,0) end
                    end
                end
                for _,m in ipairs(wingMembranes) do if m.part.Parent then local spread=28+flap*12; local cf=hrp.CFrame*CFrame.new(m.side*1.0,1.2+bob,1.12)*CFrame.Angles(0,math.rad(m.side*spread),math.rad(m.side*-10)); m.part.CFrame=cf; if m.glow and m.glow.Parent then m.glow.CFrame=cf end end end
                if wingSpine and wingSpine.Parent then local cf=hrp.CFrame*CFrame.new(0,1.2+bob,0.92); wingSpine.CFrame=cf; if wingSpineGlow and wingSpineGlow.Parent then wingSpineGlow.CFrame=cf end end
            end
            if visualState.circle and hrp then
                local centerY=hrp.Position.Y-3.1; local pulse=(math.sin(t*3)+1)/2; local cx,cz=hrp.Position.X,hrp.Position.Z
                if circleGlow and circleGlow.Parent then circleGlow.CFrame=CFrame.new(cx,centerY,cz)*CFrame.Angles(0,0,math.rad(90)); circleGlow.Transparency=0.72+pulse*0.12 end
                if circleInnerDisc and circleInnerDisc.Parent then circleInnerDisc.CFrame=CFrame.new(cx,centerY,cz)*CFrame.Angles(0,0,math.rad(90))*CFrame.Angles(t*1.5,0,0) end
                if circleCore and circleCore.Parent then circleCore.CFrame=CFrame.new(cx,centerY,cz)*CFrame.Angles(0,0,math.rad(90))*CFrame.Angles(-t*2.5,0,0); circleCore.Transparency=0.3+pulse*0.2 end
                for _,s in ipairs(circleOuterSegs) do if s.part.Parent then local ang=(s.k/16)*math.pi*2+t*0.8; local pos=Vector3.new(cx+math.cos(ang)*4.5,centerY,cz+math.sin(ang)*4.5); s.part.CFrame=CFrame.new(pos)*CFrame.Angles(0,math.pi/2-ang,0) end end
                for _,s in ipairs(circleMiddleSegs) do if s.part.Parent then local ang=(s.k/12)*math.pi*2-t*1.3; local pos=Vector3.new(cx+math.cos(ang)*3.3,centerY,cz+math.sin(ang)*3.3); s.part.CFrame=CFrame.new(pos)*CFrame.Angles(0,math.pi/2-ang,0) end end
                for _,r in ipairs(circleRunes) do if r.part.Parent then local ang=(r.k/8)*math.pi*2+t*0.5; local bobY=centerY+0.5+math.sin(t*2.5+r.k)*0.25; local pos=Vector3.new(cx+math.cos(ang)*3.9,bobY,cz+math.sin(ang)*3.9); r.part.CFrame=CFrame.new(pos)*CFrame.Angles(0,math.pi/2-ang,math.rad(45)) end end
                for _,o in ipairs(circleOrbs) do if o.part.Parent then local ang=(o.k/8)*math.pi*2+t*1.8; local bobY=centerY+0.3+math.sin(t*3.2+o.k)*0.35; local pos=Vector3.new(cx+math.cos(ang)*4.8,bobY,cz+math.sin(ang)*4.8); o.part.CFrame=CFrame.new(pos) end end
                for _,p in ipairs(circlePillars) do if p.part.Parent then local ang=(p.k/6)*math.pi*2+t*0.8; local pos=Vector3.new(cx+math.cos(ang)*4.5,centerY+3.5,cz+math.sin(ang)*4.5); p.part.CFrame=CFrame.new(pos); p.part.Transparency=0.45+pulse*0.25 end end
                for _,g in ipairs(gyroRing1) do if g.part.Parent then local theta=(g.k/14)*math.pi*2; local v=Vector3.new(math.cos(theta)*3.2,0,math.sin(theta)*3.2); v=rotX(v,math.rad(65)); v=rotY(v,t*1.4); g.part.CFrame=CFrame.new(hrp.Position+Vector3.new(0,0.6,0)+v) end end
                for _,g in ipairs(gyroRing2) do if g.part.Parent then local theta=(g.k/14)*math.pi*2; local v=Vector3.new(math.cos(theta)*2.6,0,math.sin(theta)*2.6); v=rotX(v,math.rad(-50)); v=rotY(v,-t*1.9); g.part.CFrame=CFrame.new(hrp.Position+Vector3.new(0,1.3,0)+v) end end
                if circleColumn and circleColumn.Parent then circleColumn.CFrame=CFrame.new(cx,hrp.Position.Y+0.9,cz)*CFrame.Angles(0,0,math.rad(90)); circleColumn.Transparency=0.62+pulse*0.15 end
                if circleColumnInner and circleColumnInner.Parent then circleColumnInner.CFrame=CFrame.new(cx,hrp.Position.Y+0.9,cz)*CFrame.Angles(0,0,math.rad(90)) end
                if circleLight then circleLight.Brightness=1.8+pulse*1.4 end
            end
            if visualState.halo and haloDisc and haloDisc.Parent then
                local head=char:FindFirstChild("Head")
                if head then
                    local bob=math.sin(t*2.2)*0.12; local cf=head.CFrame*CFrame.new(0,1.8+bob,0)*CFrame.Angles(0,0,math.rad(90))*CFrame.Angles(t*2.5,0,0)
                    haloDisc.CFrame=cf; if haloDiscGlow and haloDiscGlow.Parent then haloDiscGlow.CFrame=cf end
                    for _,m in ipairs(haloMotes) do if m.part.Parent then local ang=t*2+(m.k/6)*math.pi*2; m.part.CFrame=CFrame.new(head.Position+Vector3.new(math.cos(ang)*1.4,1.8+bob+math.sin(t*4+m.k)*0.1,math.sin(ang)*1.4)) end end
                end
            end
            if visualState.eyes and #eyeParts>0 then local head=char:FindFirstChild("Head"); if head then for _,e in ipairs(eyeParts) do if e.part.Parent then e.part.CFrame=head.CFrame*CFrame.new(e.side*0.35,0.12,-0.52) end end end end
        end)
    end)

    -- ================= GUI (тёмный + красный) =================
    local viewport=Vector2.new(1000,700); pcall(function() viewport=workspace.CurrentCamera.ViewportSize end)
    local function clamp(n,min,max) return math.min(max,math.max(min,n)) end
    local guiW=clamp(viewport.X*0.55,440,600); local guiH=clamp(viewport.Y*0.62,320,440)
    pcall(function() local pg=player:FindFirstChild("PlayerGui"); if pg then local old=pg:FindFirstChild("AutoFarmGui"); if old then old:Destroy() end end end)
    local guiUI=Instance.new("ScreenGui"); guiUI.Name="AutoFarmGui"; guiUI.ResetOnSpawn=false; guiUI.Enabled=true
    pcall(function() guiUI.IgnoreGuiInset=true end); pcall(function() guiUI.DisplayOrder=999999 end)
    local guiParent=nil
    for attempt=1,4 do guiParent=safeParentGui(guiUI); if guiParent then break end; pcall(function() StarterGui:SetCore("SendNotification",{Title="XDarkHUB",Text="ищу куда вставить GUI (попытка "..attempt..")...",Duration=2}) end); xdWait(1) end
    if not guiParent then pcall(function() StarterGui:SetCore("SendNotification",{Title="XDarkHUB ERROR",Text="Exploit не дал gethui/PlayerGui/CoreGui — обнови эксплойт или дай права.",Duration=10}) end); warn("[XDarkHUB] no gui parent"); return end
    local guiScale=Instance.new("UIScale",guiUI); guiScale.Scale=1
    pcall(function() StarterGui:SetCore("SendNotification",{Title="XDarkHUB",Text="GUI вставлен ("..tostring(guiParent.Name).."), строим меню...",Duration=2}) end)
    local clickSnd=Instance.new("Sound"); clickSnd.SoundId="rbxassetid://169759176"; clickSnd.Volume=0.25; clickSnd.Parent=guiUI
    local collectSound=Instance.new("Sound"); collectSound.SoundId="rbxassetid://12221967"; collectSound.Volume=1; collectSound.Parent=guiUI
    local clickEnabled=true; local function playClick() if clickEnabled then pcall(function() clickSnd:Play() end) end end
    local bgParticlesOn=false
    local bgLayer=Instance.new("Frame"); bgLayer.Size=UDim2.new(1,0,1,0); bgLayer.Position=UDim2.new(0,0,0,0); bgLayer.BackgroundColor3=Color3.fromRGB(34,34,38); bgLayer.BackgroundTransparency=0.5; bgLayer.BorderSizePixel=0; bgLayer.ZIndex=0; bgLayer.Active=false; pcall(function() bgLayer.InputTransparent=true end); bgLayer.Visible=false; bgLayer.Parent=guiUI
    for i=1,45 do
        local p=Instance.new("Frame"); local sz=math.random(2,7); p.Size=UDim2.new(0,sz,0,sz); p.Position=UDim2.new(math.random(),0,math.random(),0)
        local gt=math.random(140,235); p.BackgroundColor3=Color3.fromRGB(gt,gt,gt+8); p.BackgroundTransparency=math.random(25,65)/100; p.BorderSizePixel=0; p.ZIndex=0; p.Parent=bgLayer; corner(p,sz)
        xdSpawn(function() while p.Parent do local dur=math.random(8,20); local sx=p.Position.X.Scale; tween(p,{Position=UDim2.new(sx+math.random(-15,15)/100,0,-0.06,0),BackgroundTransparency=0.92},dur,Enum.EasingStyle.Linear); xdWait(dur); p.Position=UDim2.new(math.random(),0,1.06,0); p.BackgroundTransparency=math.random(25,65)/100 end end)
    end
    toastHolder=Instance.new("Frame"); toastHolder.Size=UDim2.new(0,300,1,-20); toastHolder.Position=UDim2.new(1,-310,0,10); toastHolder.BackgroundTransparency=1; toastHolder.ZIndex=200; toastHolder.Parent=guiUI
    local toastLayout=Instance.new("UIListLayout",toastHolder); toastLayout.Padding=UDim.new(0,8); toastLayout.HorizontalAlignment=Enum.HorizontalAlignment.Right; toastLayout.VerticalAlignment=Enum.VerticalAlignment.Top; toastLayout.SortOrder=Enum.SortOrder.LayoutOrder
    local function makeDraggable(handle,obj)
        local dragInput,dragStart,startPos,moved=false
        handle.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragInput=i; dragStart=i.Position; startPos=obj.Position; moved=false end end)
        UserInputService.InputChanged:Connect(function(i) if dragInput and i==dragInput and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-dragStart; if math.abs(d.X)>10 or math.abs(d.Y)>10 then moved=true end; if moved then obj.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end end)
        UserInputService.InputEnded:Connect(function(i) if i==dragInput then dragInput=nil end end)
        return function() return moved end
    end
    local frame=Instance.new("Frame"); frame.Size=UDim2.new(0,guiW,0,guiH); frame.Position=UDim2.new(0.5,-guiW/2,0.5,-guiH/2); frame.BackgroundColor3=COL.bg; frame.BorderSizePixel=0; frame.Visible=true; frame.Active=true; frame.ClipsDescendants=true; frame.ZIndex=5; frame.Parent=guiUI; corner(frame,14); stroke(frame,COL.accent,1.5,0.3)
    local frameGrad=gradient(frame,{ColorSequenceKeypoint.new(0,Color3.fromRGB(28,14,18)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(18,18,21)),ColorSequenceKeypoint.new(1,Color3.fromRGB(30,14,18))},100)
    if frameGrad then xdSpawn(function() local rot=100 while frameGrad.Parent do rot=rot+0.035; frameGrad.Rotation=rot; xdWait(0.08) end end) end
    local function softGlow(posX,posY,size,color) for i=1,3 do local s=size*(i/3); local b=Instance.new("Frame"); b.Size=UDim2.new(0,s,0,s); b.Position=UDim2.new(posX,-s/2,posY,-s/2); b.BackgroundColor3=color; b.BackgroundTransparency=0.88+(i*0.03); b.BorderSizePixel=0; b.ZIndex=5; b.Parent=frame; corner(b,s/2) end end
    softGlow(0.12,0.08,300,COL.accent); softGlow(0.92,0.95,260,COL.ember); softGlow(0.85,0.1,200,COL.gold)
    for i=1,20 do
        local ember=Instance.new("Frame"); local sz=math.random(2,6); ember.Size=UDim2.new(0,sz,0,sz); ember.Position=UDim2.new(math.random(),0,1,0)
        ember.BackgroundColor3=({COL.accent,COL.ember,COL.gold})[math.random(1,3)]; ember.BackgroundTransparency=math.random(45,78)/100; ember.BorderSizePixel=0; ember.ZIndex=5; ember.Parent=frame; corner(ember,sz)
        xdSpawn(function() while ember.Parent do local dur=math.random(6,14); tween(ember,{Position=UDim2.new(ember.Position.X.Scale+math.random(-20,20)/100,0,-0.1,0),BackgroundTransparency=1},dur,Enum.EasingStyle.Linear); xdWait(dur); ember.Position=UDim2.new(math.random(),0,1.05,0); ember.BackgroundTransparency=math.random(45,78)/100 end end)
    end
    local topBar=Instance.new("Frame"); topBar.Size=UDim2.new(1,0,0,48); topBar.BackgroundColor3=COL.panel; topBar.BackgroundTransparency=0.1; topBar.BorderSizePixel=0; topBar.Active=true; topBar.ZIndex=7; topBar.Parent=frame
    local accentLine=Instance.new("Frame"); accentLine.Size=UDim2.new(1,0,0,2); accentLine.Position=UDim2.new(0,0,1,-2); accentLine.BackgroundColor3=COL.accent; accentLine.BorderSizePixel=0; accentLine.ZIndex=8; accentLine.Parent=topBar
    local lineGrad=gradient(accentLine,{ColorSequenceKeypoint.new(0,COL.accentDim),ColorSequenceKeypoint.new(0.35,COL.accentHot),ColorSequenceKeypoint.new(0.65,COL.ember),ColorSequenceKeypoint.new(1,COL.accentDim)},0)
    if lineGrad then xdSpawn(function() while lineGrad.Parent do tween(lineGrad,{Offset=Vector2.new(0.6,0)},2.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut); xdWait(2.4); lineGrad.Offset=Vector2.new(-0.6,0) end end) end
    local logoRing=Instance.new("Frame"); logoRing.Size=UDim2.new(0,32,0,32); logoRing.Position=UDim2.new(0,12,0.5,-16); logoRing.BackgroundColor3=COL.accentDim; logoRing.BorderSizePixel=0; logoRing.ZIndex=9; logoRing.Parent=topBar; corner(logoRing,16)
    local ringGrad=gradient(logoRing,{ColorSequenceKeypoint.new(0,COL.accentHot),ColorSequenceKeypoint.new(0.5,COL.ember),ColorSequenceKeypoint.new(1,COL.accentDim)},0)
    if ringGrad then xdSpawn(function() local rot=0 while ringGrad.Parent do rot=rot+2.2; ringGrad.Rotation=rot; xdWait(0.03) end end) end
    local logo=Instance.new("Frame"); logo.Size=UDim2.new(0,26,0,26); logo.Position=UDim2.new(0,3,0,3); logo.BackgroundColor3=Color3.fromRGB(20,12,15); logo.BorderSizePixel=0; logo.ZIndex=10; logo.Parent=logoRing; corner(logo,13)
    local logoX=Instance.new("TextLabel"); logoX.Size=UDim2.new(1,0,1,0); logoX.BackgroundTransparency=1; logoX.Text="X"; logoX.Font=Enum.Font.GothamBlack; logoX.TextSize=16; logoX.TextColor3=COL.accentHot; logoX.ZIndex=11; logoX.Parent=logo
    local titleText=Instance.new("TextLabel"); titleText.Size=UDim2.new(0,150,1,0); titleText.Position=UDim2.new(0,52,0,0); titleText.BackgroundTransparency=1; titleText.Text="XDarkHUB"; titleText.Font=Enum.Font.GothamBlack; titleText.TextSize=16; titleText.TextColor3=COL.text; titleText.TextXAlignment=Enum.TextXAlignment.Left; titleText.ZIndex=9; titleText.Parent=topBar
    local verBadge=Instance.new("TextLabel"); verBadge.Size=UDim2.new(0,38,0,16); verBadge.Position=UDim2.new(0,150,0.5,-8); verBadge.BackgroundColor3=COL.accentDim; verBadge.BorderSizePixel=0; verBadge.Text="v42"; verBadge.Font=Enum.Font.GothamBold; verBadge.TextSize=10; verBadge.TextColor3=COL.accentHot; verBadge.ZIndex=9; verBadge.Parent=topBar; corner(verBadge,8)
    local perfChip=Instance.new("TextLabel"); perfChip.Size=UDim2.new(0,100,0,22); perfChip.Position=UDim2.new(1,-110,0.5,-11); perfChip.BackgroundColor3=COL.card; perfChip.BorderSizePixel=0; perfChip.Text="— FPS · — ms"; perfChip.Font=Enum.Font.Code; perfChip.TextSize=10; perfChip.TextColor3=COL.textDim; perfChip.ZIndex=9; perfChip.Parent=topBar; corner(perfChip,11); stroke(perfChip,COL.border,1,0.5)
    makeDraggable(topBar,frame)
    local sidebar=Instance.new("Frame"); sidebar.Size=UDim2.new(0,150,1,-48); sidebar.Position=UDim2.new(0,0,0,48); sidebar.BackgroundColor3=COL.panel; sidebar.BackgroundTransparency=0.2; sidebar.BorderSizePixel=0; sidebar.ZIndex=7; sidebar.Parent=frame
    local sideLine=Instance.new("Frame"); sideLine.Size=UDim2.new(0,1,1,0); sideLine.Position=UDim2.new(1,-1,0,0); sideLine.BackgroundColor3=COL.line; sideLine.BackgroundTransparency=0.4; sideLine.BorderSizePixel=0; sideLine.ZIndex=8; sideLine.Parent=sidebar
    local tabScroll=Instance.new("ScrollingFrame"); tabScroll.Size=UDim2.new(1,0,1,-44); tabScroll.BackgroundTransparency=1; tabScroll.BorderSizePixel=0; tabScroll.ScrollBarThickness=0; tabScroll.CanvasSize=UDim2.new(0,0,0,0); tabScroll.ZIndex=8; tabScroll.Parent=sidebar
    pcall(function() tabScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y end)
    local sideLayout=Instance.new("UIListLayout",tabScroll); sideLayout.Padding=UDim.new(0,4); sideLayout.SortOrder=Enum.SortOrder.LayoutOrder
    local sidePad=Instance.new("UIPadding",tabScroll); sidePad.PaddingTop=UDim.new(0,8); sidePad.PaddingLeft=UDim.new(0,6); sidePad.PaddingRight=UDim.new(0,6)
    local roleStatus=Instance.new("TextLabel"); roleStatus.Size=UDim2.new(1,-12,0,32); roleStatus.Position=UDim2.new(0,6,1,-38); roleStatus.BackgroundColor3=COL.card; roleStatus.BorderSizePixel=0; roleStatus.Text="Роль: —"; roleStatus.Font=Enum.Font.GothamBold; roleStatus.TextSize=12; roleStatus.TextColor3=COL.textDim; roleStatus.ZIndex=9; roleStatus.Parent=sidebar; corner(roleStatus,9); stroke(roleStatus,COL.border,1,0.45)
    local content=Instance.new("Frame"); content.Size=UDim2.new(1,-150,1,-48); content.Position=UDim2.new(0,150,0,48); content.BackgroundTransparency=1; content.ZIndex=7; content.Parent=frame
    local function newRow(parent,order,height) local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,height or 46); row.BackgroundColor3=COL.cardHover; row.BackgroundTransparency=1; row.LayoutOrder=order; row.ZIndex=8; row.Parent=parent; local line=Instance.new("Frame"); line.Size=UDim2.new(1,-8,0,1); line.Position=UDim2.new(0,4,1,-1); line.BackgroundColor3=COL.line; line.BackgroundTransparency=0.4; line.BorderSizePixel=0; line.ZIndex=8; line.Parent=row; return row end
    local function rowLabel(row,text) local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-150,1,0); l.Position=UDim2.new(0,6,0,0); l.BackgroundTransparency=1; l.Text=text; l.Font=Enum.Font.GothamMedium; l.TextSize=13; l.TextColor3=COL.text; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=9; l.Parent=row; return l end
    local function makeSwitch(row,default,callback)
        local switch=Instance.new("TextButton"); switch.Size=UDim2.new(0,40,0,22); switch.Position=UDim2.new(1,-46,0.5,-11); switch.BackgroundColor3=COL.track; switch.BorderSizePixel=0; switch.Text=""; switch.AutoButtonColor=false; switch.ZIndex=10; switch.Parent=row; corner(switch,11)
        local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,16,0,16); knob.Position=UDim2.new(0,3,0.5,-8); knob.BackgroundColor3=COL.knob; knob.BorderSizePixel=0; knob.ZIndex=11; knob.Parent=switch; corner(knob,8)
        local state=default and true or false
        local function render() if state then tween(switch,{BackgroundColor3=COL.accent},0.18); tween(knob,{Position=UDim2.new(1,-19,0.5,-8)},0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out) else tween(switch,{BackgroundColor3=COL.track},0.18); tween(knob,{Position=UDim2.new(0,3,0.5,-8)},0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out) end end; render()
        local function set(v,cb) state=v and true or false; render(); if cb~=false then pcall(function() callback(state) end) end end
        switch.MouseButton1Click:Connect(function() playClick(); set(not state) end); return {Set=function(_,v) if (v and true or false)~=state then set(v) end end}
    end
    local function makeToggleRow(parent,order,text,default,callback) local row=newRow(parent,order,46); rowLabel(row,text); return makeSwitch(row,default,callback) end
    local function makeButtonRow(parent,order,text,callback,hot)
        local row=newRow(parent,order,46); local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.AutoButtonColor=false; btn.ZIndex=9; btn.Parent=row; rowLabel(row,text)
        local badge=Instance.new("Frame"); badge.Size=UDim2.new(0,52,0,26); badge.Position=UDim2.new(1,-58,0.5,-13); badge.BackgroundColor3=hot and COL.accent or COL.card; badge.BorderSizePixel=0; badge.ZIndex=10; badge.Parent=row; corner(badge,7)
        local btxt=Instance.new("TextLabel"); btxt.Size=UDim2.new(1,0,1,0); btxt.BackgroundTransparency=1; btxt.Text=hot and "RUN" or "GO"; btxt.Font=Enum.Font.GothamBold; btxt.TextSize=11; btxt.TextColor3=hot and COL.knob or COL.textDim; btxt.ZIndex=11; btxt.Parent=badge
        btn.MouseEnter:Connect(function() tween(row,{BackgroundTransparency=0.7},0.12) end); btn.MouseLeave:Connect(function() tween(row,{BackgroundTransparency=1},0.12) end)
        btn.MouseButton1Click:Connect(function() playClick(); tween(badge,{BackgroundColor3=COL.accentHot},0.08); xdDelay(0.12,function() tween(badge,{BackgroundColor3=hot and COL.accent or COL.card},0.12) end); pcall(callback) end)
    end
    local function makeSliderRow(parent,order,text,min,max,default,decimals,callback)
        decimals=decimals or 0; local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,52); row.BackgroundColor3=COL.cardHover; row.BackgroundTransparency=1; row.LayoutOrder=order; row.ZIndex=8; row.Parent=parent
        local line=Instance.new("Frame"); line.Size=UDim2.new(1,-8,0,1); line.Position=UDim2.new(0,4,1,-1); line.BackgroundColor3=COL.line; line.BackgroundTransparency=0.4; line.BorderSizePixel=0; line.ZIndex=8; line.Parent=row
        local l=Instance.new("TextLabel"); l.Size=UDim2.new(0.6,-8,0,22); l.Position=UDim2.new(0,6,0,6); l.BackgroundTransparency=1; l.Text=text; l.Font=Enum.Font.GothamMedium; l.TextSize=13; l.TextColor3=COL.text; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=9; l.Parent=row
        local value=Instance.new("TextLabel"); value.Size=UDim2.new(0.4,-8,0,22); value.Position=UDim2.new(0.6,0,0,6); value.BackgroundTransparency=1; value.Font=Enum.Font.GothamBold; value.TextSize=13; value.TextColor3=COL.accentHot; value.TextXAlignment=Enum.TextXAlignment.Right; value.ZIndex=9; value.Parent=row
        local track=Instance.new("TextButton"); track.Size=UDim2.new(1,-8,0,4); track.Position=UDim2.new(0,4,0,34); track.BackgroundColor3=COL.track; track.BorderSizePixel=0; track.Text=""; track.AutoButtonColor=false; track.ZIndex=9; track.Parent=row; corner(track,2)
        local fill=Instance.new("Frame"); fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=COL.accent; fill.BorderSizePixel=0; fill.ZIndex=10; fill.Parent=track; corner(fill,2)
        local function fmt(v) return string.format("%."..decimals.."f",v) end
        local function setVal(v,cb) v=clamp(v,min,max); fill.Size=UDim2.new((v-min)/(max-min),0,1,0); value.Text=fmt(v); if cb then pcall(function() callback(v) end) end end; setVal(default,false)
        local dragging=false; local function fromX(x) local rel=clamp((x-track.AbsolutePosition.X)/math.max(1,track.AbsoluteSize.X),0,1); setVal(min+rel*(max-min),true) end
        track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; playClick(); fromX(i.Position.X) end end)
        UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then fromX(i.Position.X) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
        return {Set=function(_,v) setVal(v,false) end}
    end
    local function makeStatRow(parent,order,text) local row=newRow(parent,order,40); rowLabel(row,text); local v=Instance.new("TextLabel"); v.Size=UDim2.new(0,130,1,0); v.Position=UDim2.new(1,-134,0,0); v.BackgroundTransparency=1; v.Text="0"; v.Font=Enum.Font.GothamBold; v.TextSize=13; v.TextColor3=COL.accentHot; v.TextXAlignment=Enum.TextXAlignment.Right; v.ZIndex=9; v.Parent=row; return v end
    local function makeSection(parent,order,text) local h=Instance.new("Frame"); h.Size=UDim2.new(1,0,0,28); h.BackgroundTransparency=1; h.LayoutOrder=order; h.ZIndex=8; h.Parent=parent; local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.Text=text; l.Font=Enum.Font.GothamBold; l.TextSize=11; l.TextColor3=COL.textDim; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=8; l.Parent=h; return h end
    local function makeSegmented(parent,order,labelText,options,defaultIdx,callback)
        local row=newRow(parent,order,50); rowLabel(row,labelText); local holder=Instance.new("Frame"); holder.Size=UDim2.new(0,172,0,28); holder.Position=UDim2.new(1,-178,0.5,-14); holder.BackgroundColor3=COL.card; holder.BorderSizePixel=0; holder.ZIndex=10; holder.Parent=row; corner(holder,8)
        local btns={}; local n=#options; local bw=172/n; local sel
        for i,opt in ipairs(options) do local b=Instance.new("TextButton"); b.Size=UDim2.new(0,bw-3,1,-4); b.Position=UDim2.new(0,(i-1)*bw+2,0,2); b.BackgroundColor3=Color3.fromRGB(0,0,0); b.BackgroundTransparency=1; b.Text=opt; b.Font=Enum.Font.GothamBold; b.TextSize=11; b.TextColor3=COL.textDim; b.BorderSizePixel=0; b.AutoButtonColor=false; b.ZIndex=11; b.Parent=holder; corner(b,6); btns[i]=b; b.MouseButton1Click:Connect(function() playClick(); sel(i) end) end
        sel=function(idx) for i,b in ipairs(btns) do if i==idx then b.BackgroundColor3=COL.accent; b.BackgroundTransparency=0; b.TextColor3=COL.knob else b.BackgroundColor3=Color3.fromRGB(0,0,0); b.BackgroundTransparency=1; b.TextColor3=COL.textDim end end; pcall(function() callback(idx) end) end; sel(defaultIdx or 1); return {Set=function(_,i) sel(i) end}
    end
    local tabs={}; local contents={}; local currentTab=nil
    local function switchTab(name) for n,d in pairs(tabs) do tween(d.btn,{BackgroundTransparency=1},0.15); d.icon.TextColor3=COL.textDim; d.label.TextColor3=COL.textDim; d.bar.BackgroundTransparency=1 end; for n,c in pairs(contents) do c.Visible=false end; if tabs[name] then local d=tabs[name]; d.btn.BackgroundColor3=COL.accent; d.btn.BackgroundTransparency=0; d.icon.TextColor3=COL.knob; d.label.TextColor3=COL.knob; d.bar.BackgroundTransparency=0 end; if contents[name] then contents[name].Visible=true end; currentTab=name end
    local function addTab(name,icon,order)
        local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-12,0,38); b.BackgroundTransparency=1; b.Text=""; b.AutoButtonColor=false; b.LayoutOrder=order; b.ZIndex=9; b.Parent=tabScroll; corner(b,8)
        local bar=Instance.new("Frame"); bar.Size=UDim2.new(0,3,0,18); bar.Position=UDim2.new(0,0,0.5,-9); bar.BackgroundColor3=COL.knob; bar.BackgroundTransparency=1; bar.BorderSizePixel=0; bar.ZIndex=10; bar.Parent=b; corner(bar,2)
        local ic=Instance.new("TextLabel"); ic.Size=UDim2.new(0,24,1,0); ic.Position=UDim2.new(0,8,0,0); ic.BackgroundTransparency=1; ic.Text=icon; ic.Font=Enum.Font.GothamBold; ic.TextSize=13; ic.TextColor3=COL.textDim; ic.ZIndex=10; ic.Parent=b
        local nm=Instance.new("TextLabel"); nm.Size=UDim2.new(1,-36,1,0); nm.Position=UDim2.new(0,32,0,0); nm.BackgroundTransparency=1; nm.Text=name; nm.Font=Enum.Font.GothamBold; nm.TextSize=13; nm.TextColor3=COL.textDim; nm.TextXAlignment=Enum.TextXAlignment.Left; nm.ZIndex=10; nm.Parent=b
        tabs[name]={btn=b,bar=bar,icon=ic,label=nm}
        b.MouseEnter:Connect(function() if currentTab~=name then tween(b,{BackgroundColor3=COL.card,BackgroundTransparency=0.4},0.12) end end); b.MouseLeave:Connect(function() if currentTab~=name then tween(b,{BackgroundTransparency=1},0.12) end end); b.MouseButton1Click:Connect(function() playClick(); switchTab(name) end)
        local c=Instance.new("ScrollingFrame"); c.Size=UDim2.new(1,0,1,0); c.BackgroundTransparency=1; c.BorderSizePixel=0; c.ScrollBarThickness=3; c.ScrollBarImageColor3=COL.accent; c.CanvasSize=UDim2.new(0,0,0,0); c.Visible=false; c.ZIndex=8; c.Parent=content
        pcall(function() c.AutomaticCanvasSize=Enum.AutomaticSize.Y end); local l=Instance.new("UIListLayout",c); l.Padding=UDim.new(0,2); l.SortOrder=Enum.SortOrder.LayoutOrder
        local pad=Instance.new("UIPadding",c); pad.PaddingTop=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,16); pad.PaddingLeft=UDim.new(0,10); pad.PaddingRight=UDim.new(0,10); contents[name]=c
    end
    addTab("Main","●",1); addTab("RageBot","■",2); addTab("ESP","◉",3); addTab("Visuals","★",4); addTab("Flings / Troll","◆",5); addTab("Theme","▲",6)
    local floatingButtons={}
    local function createFloatingButton(name,text,color,callback,position)
        if floatingButtons[name] then floatingButtons[name]:Destroy(); floatingButtons[name]=nil end
        local b=Instance.new("TextButton"); b.Name=name; b.Size=UDim2.new(0,160,0,52); b.Position=position or UDim2.new(0,120,0,80); b.BackgroundColor3=color or COL.accent; b.Text=text; b.TextColor3=Color3.fromRGB(255,255,255); b.Font=Enum.Font.GothamBlack; b.TextSize=15; b.BorderSizePixel=0; b.AutoButtonColor=false; b.ZIndex=100; b.Parent=guiUI; corner(b,12)
        gradient(b,{ColorSequenceKeypoint.new(0,COL.accentHot),ColorSequenceKeypoint.new(1,color or COL.accent)},90); stroke(b,COL.accentHot,1.5,0.3); local wasMoved=makeDraggable(b,b)
        b.MouseButton1Down:Connect(function() tween(b,{BackgroundTransparency=0.25},0.07) end); b.MouseButton1Up:Connect(function() tween(b,{BackgroundTransparency=0},0.07) end)
        b.MouseButton1Click:Connect(function() if wasMoved() then return end; playClick(); pcall(callback) end)
        floatingButtons[name]=b; notify("XDarkHUB","Кнопка создана: "..text)
    end
    local function removeFloatingButton(name) if floatingButtons[name] then floatingButtons[name]:Destroy(); floatingButtons[name]=nil; notify("XDarkHUB","Кнопка убрана: "..name) end end
    local counterV,timerV,rateV,pCoinV,roleV,bagVal
    local mainC=contents["Main"]
    makeSection(mainC,0,"СТАТИСТИКА"); roleV=makeStatRow(mainC,1,"Роль"); counterV=makeStatRow(mainC,2,"Монеты"); timerV=makeStatRow(mainC,3,"Время"); rateV=makeStatRow(mainC,4,"Скорость"); pCoinV=makeStatRow(mainC,5,"Всего"); bagVal=makeStatRow(mainC,6,"Мешок")
    makeSection(mainC,7,"ТЕЛЕПОРТЫ"); makeButtonRow(mainC,8,"🏠  В лобби",teleportToLobby,false); makeButtonRow(mainC,9,"🗺  На карту",teleportToMap,false)
    makeSection(mainC,10,"НАСТРОЙКИ"); makeSliderRow(mainC,11,"Shoot Offset",0,10,shootOffset,1,function(v) shootOffset=v end); makeSliderRow(mainC,12,"Ping Multiplier",0,3,offsetToPingMult,2,function(v) offsetToPingMult=v end)
    makeToggleRow(mainC,13,"Анти-АФК",antiAFK,function(s) antiAFK=s end); makeToggleRow(mainC,14,"Авто-фарм монет",false,function(s) isActive=s; if s then startFarming() else farmStopped=true end end)
    local rageC=contents["RageBot"]
    makeSegmented(rageC,0,"Device Mode:",{"PC / Laptop","Phone UI"},1,function(i) guiScale.Scale=(i==1) and 1 or 0.8 end)
    makeSection(rageC,1,"ШЕРИФ / ГЕРОЙ"); makeButtonRow(rageC,2,"🔫  Выстрел в убийцу",shootMurderer,true); makeToggleRow(rageC,3,"Авто-стрельба",false,function(s) autoShooting=s end); makeToggleRow(rageC,4,"Мгновенное убийство",false,function(s) instakillshoot=s end); makeToggleRow(rageC,5,"Авто-подбор пистолета",false,function(s) autoGetDroppedGun=s end); makeButtonRow(rageC,6,"💰  Телепорт к пистолету",teleportToGun,false)
    makeSection(rageC,7,"УБИЙЦА"); makeButtonRow(rageC,8,"🔪  Бросок ножа",knifeThrow,true); makeToggleRow(rageC,9,"Авто-бросок ножа",false,function(s) loopThrow=s end); makeButtonRow(rageC,10,"💀  Убить ближайшего",killClosest,true); makeButtonRow(rageC,11,"☠  Убить всех",killEveryone,true); makeButtonRow(rageC,12,"🔒  Взять в заложники",holdHostage,false); makeToggleRow(rageC,13,"Kill Aura",false,function(s) toggleKillAura(s) end); makeToggleRow(rageC,14,"Спавн ножа у игрока",false,function(s) spawnAtPlayer=s end); makeToggleRow(rageC,15,"Игнорировать ножи",false,function(s) ignoreknifethrow=s end); makeButtonRow(rageC,16,"⚡  God Mode (нестабильно)",godMode,false)
    local espC=contents["ESP"]
    makeSection(espC,0,"ПОДСВЕТКА"); makeToggleRow(espC,1,"ESP игроков (роли)",false,function(s) playerESP=s; if s then ensureEspWatcher(); notify("XDarkHUB","ESP включён") end; refreshESP() end); makeToggleRow(espC,2,"ESP выпавшей пушки",false,function(s) gunDropESP=s; reloadGunESP() end); makeToggleRow(espC,3,"ESP ловушек",false,function(s) trapDetection=s; reloadTrapESP() end); makeToggleRow(espC,4,"Скрыть свой ESP",false,function(s) hideMeEsp=s; refreshESP() end)
    local visC=contents["Visuals"]; local visualToggles={}
    makeSection(visC,0,"ВИЗУАЛЬНЫЕ ЭФФЕКТЫ")
    visualToggles.wings=makeToggleRow(visC,1,"🪽  Светящиеся крылья",false,function(s) visualState.wings=s; if s then applyVisualSafe("wings") else clearVisual("wings") end end)
    visualToggles.halo=makeToggleRow(visC,2,"😇  Орб / нимб над головой",false,function(s) visualState.halo=s; if s then applyVisualSafe("halo") else clearVisual("halo") end end)
    visualToggles.circle=makeToggleRow(visC,3,"🌀  Круг-печать под ногами",false,function(s) visualState.circle=s; if s then applyVisualSafe("circle") else clearVisual("circle") end end)
    visualToggles.aura=makeToggleRow(visC,4,"✨  Красная аура",false,function(s) visualState.aura=s; if s then applyVisualSafe("aura") else clearVisual("aura") end end)
    visualToggles.fire=makeToggleRow(visC,5,"🔥  Огненная аура",false,function(s) visualState.fire=s; if s then applyVisualSafe("fire") else clearVisual("fire") end end)
    visualToggles.smoke=makeToggleRow(visC,6,"🌫  Тёмный дым",false,function(s) visualState.smoke=s; if s then applyVisualSafe("smoke") else clearVisual("smoke") end end)
    visualToggles.lightning=makeToggleRow(visC,7,"⚡  Багровые молнии",false,function(s) visualState.lightning=s; if s then applyVisualSafe("lightning") else clearVisual("lightning") end end)
    visualToggles.trails=makeToggleRow(visC,8,"〰  Неоновые трейлы",false,function(s) visualState.trails=s; if s then applyVisualSafe("trails") else clearVisual("trails") end end)
    visualToggles.eyes=makeToggleRow(visC,9,"👀  Светящиеся глаза",false,function(s) visualState.eyes=s; if s then applyVisualSafe("eyes") else clearVisual("eyes") end end)
    visualToggles.light=makeToggleRow(visC,10,"💡  Красная подсветка",false,function(s) visualState.light=s; if s then applyVisualSafe("light") else clearVisual("light") end end)
    makeButtonRow(visC,11,"🔥  ВКЛЮЧИТЬ ВСЁ",function() for _,t in pairs(visualToggles) do t:Set(true) end; notify("XDarkHUB","Все эффекты включены!") end,true)
    makeButtonRow(visC,12,"🧹  ВЫКЛЮЧИТЬ ВСЁ",function() for _,t in pairs(visualToggles) do t:Set(false) end; notify("XDarkHUB","Все эффекты выключены!") end,false)
    local flingC=contents["Flings / Troll"]
    makeSection(flingC,0,"ФЛИНГ"); makeButtonRow(flingC,1,"🔪  Флинг убийцы",function() local m=findMurderer(); if not m then notify("XDarkHUB","Нет убийцы для флинга."); return end; miniFling(m) end,true); makeButtonRow(flingC,2,"⭐  Флинг шерифа",function() local s=findSheriff(); if not s then notify("XDarkHUB","Нет шерифа для флинга."); return end; miniFling(s) end,false); makeToggleRow(flingC,3,"Флинг убийцы при полном мешке",false,function(s) flingOnFullBag=s end)
    makeSection(flingC,4,"ПЛАВАЮЩИЕ КНОПКИ"); makeButtonRow(flingC,5,"📌  Телепорт к пушке",function() if floatingButtons["TP_GUN"] then removeFloatingButton("TP_GUN") else createFloatingButton("TP_GUN","🔫 К ПУШКЕ",COL.accent,teleportToGun,UDim2.new(0,120,0,80)) end end,false); makeButtonRow(flingC,6,"📌  Выстрел",function() if floatingButtons["SHOOT"] then removeFloatingButton("SHOOT") else createFloatingButton("SHOOT","🔫 ВЫСТРЕЛ",COL.accent,shootMurderer,UDim2.new(0,120,0,135)) end end,false)
    makeSection(flingC,7,"ЧАТ / ИМЕНА"); makeButtonRow(flingC,8,"💬  Имена в чат",sendNamesToChat,false); makeButtonRow(flingC,9,"📋  Имя шерифа",copySheriffName,false); makeButtonRow(flingC,10,"📋  Имя убийцы",copyMurdererName,false)
    local themeC=contents["Theme"]
    makeSection(themeC,0,"ИНТЕРФЕЙС"); makeToggleRow(themeC,1,"🔊  Звук кликов",true,function(s) clickEnabled=s end); makeSliderRow(themeC,2,"Прозрачность меню",0,80,0,0,function(v) frame.BackgroundTransparency=v/100 end); makeToggleRow(themeC,3,"🌫  Частицы фона в игре",false,function(s) bgParticlesOn=s; bgLayer.Visible=frame.Visible or bgParticlesOn; notify("XDarkHUB",s and "Фон включён и в игре" or "Фон выключен") end)
    makeSection(themeC,4,"ИНФО"); local verStat=makeStatRow(themeC,5,"Версия"); verStat.Text="v42"; local buildStat=makeStatRow(themeC,6,"Сборка"); buildStat.Text="XDarkHUB"
    local function checkRole() local r=getPlayerRole(player); isMurderer=(r=="Murderer"); isSheriff=(r=="Sheriff"); isHero=(r=="Hero") end
    local function getPlayerCoins(p) local ls=p:FindFirstChild("leaderstats"); if ls then for _,v in ipairs(ls:GetChildren()) do if v:IsA("IntValue") or v:IsA("NumberValue") then local n=v.Name:lower(); if n:find("coin") or n:find("money") or n:find("cash") or n:find("gold") then return v.Value end end end; for _,v in ipairs(ls:GetChildren()) do if v:IsA("IntValue") or v:IsA("NumberValue") then return v.Value end end end; return 0 end
    local function getCollectedCoins() return getPlayerCoins(player)-initialCoins end
    function updateRoleUI() checkRole(); local roleName,roleColor; if isMurderer then roleName="Убийца"; roleColor=Color3.fromRGB(255,70,80) elseif isSheriff then roleName="Шериф"; roleColor=Color3.fromRGB(90,160,255) elseif isHero then roleName="Герой"; roleColor=Color3.fromRGB(255,200,96) else roleName="Мирный"; roleColor=Color3.fromRGB(90,220,120) end; if roleV then roleV.Text=roleName; roleV.TextColor3=roleColor end; roleStatus.Text="Роль: "..roleName; roleStatus.TextColor3=roleColor end
    function updateBagUI() local cc=getCollectedCoins(); if farmStopped then bagVal.Text="Стоп"; bagVal.TextColor3=Color3.fromRGB(255,80,80) elseif cc>=bagSize then bagVal.Text="Полная"; bagVal.TextColor3=Color3.fromRGB(255,200,0) else bagVal.Text=cc.."/"..bagSize; bagVal.TextColor3=COL.accentHot end end
    function stopFarming() farmStopped=true; isActive=false; updateBagUI(); notify("XDarkHUB","Остановлено") end
    function flyTo(pos,spd) if not rootPart or farmStopped then return false end; local d=(pos-rootPart.Position).Magnitude; local dur=math.max(0.1,d/spd); local tw=TweenService:Create(rootPart,TweenInfo.new(dur,Enum.EasingStyle.Linear),{CFrame=CFrame.new(pos)}); tw:Play(); local c=false; local to=xdDelay(dur+2,function() c=true; tw:Cancel() end); tw.Completed:Wait(); if not c then pcall(function() task.cancel(to) end) end; return not c end
    function startFarming()
        if farmRunning then return end; farmRunning=true; initialCoins=getPlayerCoins(player); startTime=tick(); visitedPositions={}; farmStopped=false; alreadyFlungOnFull=false; bagFullNotified=false
        counterV.Text="0"; timerV.Text="0s"; rateV.Text="0"; updateRoleUI(); updateBagUI(); notify("XDarkHUB","Фарм включён")
        xdSpawn(function() while isActive do local e=tick()-startTime; local cc=getCollectedCoins(); timerV.Text=math.floor(e).."s"; counterV.Text=tostring(cc); rateV.Text=tostring(e>0 and math.floor(cc/e*3600) or 0); pCoinV.Text=tostring(getPlayerCoins(player)); updateRoleUI(); updateBagUI(); xdWait(0.25) end end)
        xdSpawn(function()
            while isActive do
                if farmStopped then xdWait(1); continue end
                character=player.Character; if not character then xdWait(0.5); continue end; rootPart=character:FindFirstChild("HumanoidRootPart"); if not rootPart then xdWait(0.5); continue end
                local cc=getCollectedCoins()
                if cc>=bagSize then
                    if flingOnFullBag and not alreadyFlungOnFull then alreadyFlungOnFull=true; local murderer=findMurderer(); if murderer then notify("XDarkHUB","Мешок полный — флингаю убийцу!"); xdSpawn(function() pcall(function() miniFling(murderer) end) end) end end
                    if not bagFullNotified then bagFullNotified=true; notify("XDarkHUB","Мешок полный ("..cc.."/"..bagSize..") — к монетам не лечу") end; updateBagUI(); xdWait(1); continue
                end
                bagFullNotified=false; alreadyFlungOnFull=false; checkRole(); local cl,sh=nil,math.huge
                for _,o in ipairs(workspace:GetDescendants()) do if o:IsA("BasePart") and o.Name=="Coin_Server" then local ic=false; for _,p in ipairs(Players:GetPlayers()) do if p.Character and o:IsDescendantOf(p.Character) then ic=true; break end end; if not ic and o.Parent and o:IsDescendantOf(workspace) and not visitedPositions[o] then local d=(o.Position-rootPart.Position).Magnitude; if d<sh and d<300 then cl=o; sh=d end end end end
                if cl then local cp=cl.Position; local cr=cl; if flyTo(cp,flySpeed) and not farmStopped then xdWait(0.3); if cr.Parent and cr:IsDescendantOf(workspace) then local ic=false; for _,p in ipairs(Players:GetPlayers()) do if p.Character and cr:IsDescendantOf(p.Character) then ic=true; break end end; if not ic and (cr.Position-rootPart.Position).Magnitude<5 then pcall(function() collectSound:Play() end); updateBagUI() end; visitedPositions[cr]=true else visitedPositions[cr]=true end end else if next(visitedPositions) then visitedPositions={} end; xdWait(1) end
                xdWait(0.1)
            end; farmRunning=false
        end)
    end
    local mBtn=Instance.new("TextButton"); mBtn.Size=UDim2.new(0,50,0,50); mBtn.Position=UDim2.new(0,14,1,-64); mBtn.BackgroundColor3=COL.accent; mBtn.Text="X"; mBtn.TextColor3=COL.knob; mBtn.Font=Enum.Font.GothamBlack; mBtn.TextSize=20; mBtn.BorderSizePixel=0; mBtn.AutoButtonColor=false; mBtn.ZIndex=50; mBtn.Parent=guiUI; corner(mBtn,25)
    gradient(mBtn,{ColorSequenceKeypoint.new(0,COL.accentHot),ColorSequenceKeypoint.new(1,COL.accentDim)},45); stroke(mBtn,COL.accentHot,1.5,0.3)
    xdSpawn(function() while mBtn.Parent do tween(mBtn,{Size=UDim2.new(0,55,0,55)},1.3,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut); xdWait(1.3); tween(mBtn,{Size=UDim2.new(0,50,0,50)},1.3,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut); xdWait(1.3) end end)
    mBtn.MouseButton1Click:Connect(function() playClick(); frame.Visible=not frame.Visible; bgLayer.Visible=frame.Visible or bgParticlesOn end)
    local fpsCount=0; RunService.RenderStepped:Connect(function() fpsCount=fpsCount+1 end)
    xdSpawn(function() while true do xdWait(1); pcall(function() perfChip.Text=fpsCount.." FPS · "..math.floor(localplayer:GetNetworkPing()*1000).." ms" end); fpsCount=0 end end)
    -- безопасное появление: окно УЖЕ видимо и полноразмерно, анимируем только scale (если твин не сыграет — окно всё равно на месте)
    frame.Visible=true; frame.BackgroundTransparency=0
    pcall(function() guiScale.Scale=0.92; tween(guiScale,{Scale=1},0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out) end)
    xdDelay(0.6,function() pcall(function() guiScale.Scale=1 end); pcall(function() frame.Visible=true; frame.BackgroundTransparency=0 end) end)
    player.CharacterAdded:Connect(function(ch) character=ch; rootPart=ch:WaitForChild("HumanoidRootPart"); visitedPositions={}; farmStopped=false; alreadyFlungOnFull=false; bagFullNotified=false; xdWait(1.25); checkRole(); pcall(function() updateRoleUI() end); reapplyVisuals() end)
    player.Idled:Connect(function() if antiAFK then pcall(function() VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame); xdWait(1); VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) end) end end)
    RunService.Stepped:Connect(function() if isActive and character and not farmStopped then for _,v in ipairs(character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end end end)
    pcall(function() updateRoleUI() end); pcall(function() updateBagUI() end); switchTab("Main")
    notify("XDarkHUB","v42 загружен!"); notify("XDarkHUB","Крылья + орб + круг (bloom, красный)!")
    pcall(function() StarterGui:SetCore("SendNotification",{Title="XDarkHUB",Text="меню готово ✓ — кнопка X внизу слева",Duration=3}) end)
    xdStatus("XDarkHUB v42: меню готово",Color3.fromRGB(80,255,120)); xdDelay(4,function() pcall(function() if statusLabel then statusLabel.Visible=false end end) end)
end, function(err) xdError(err) end)
