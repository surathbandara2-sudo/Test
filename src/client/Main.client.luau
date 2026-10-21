local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local Run=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local Config=require(RS:WaitForChild("VTR"):WaitForChild("Config"))
local remote=RS.VTR:WaitForChild("RoundEvent"); local vote=RS.VTR:WaitForChild("Vote")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui"); gui.Name="CitadelInterface"; gui.ResetOnSpawn=false; gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets; gui.Parent=player:WaitForChild("PlayerGui")
local ink=Color3.fromRGB(16,29,41); local cream=Color3.fromRGB(237,232,211); local gold=Color3.fromRGB(231,189,112)
local function round(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 16) end
local function label(parent,text,size,pos,dim)
 local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=text; t.Font=Enum.Font.GothamBold; t.TextColor3=cream; t.TextSize=size; t.Position=pos; t.Size=dim; t.TextWrapped=true; t.Parent=parent; return t
end
local function panel(size,pos)
 local f=Instance.new("Frame"); f.Size=size; f.Position=pos; f.BackgroundColor3=ink; f.BackgroundTransparency=.08; f.Parent=gui; round(f)
 local s=Instance.new("UIStroke",f); s.Color=gold; s.Transparency=.65; return f
end
local header=panel(UDim2.new(.86,0,0,86),UDim2.new(.07,0,0,16)); local constraint=Instance.new("UISizeConstraint",header); constraint.MaxSize=Vector2.new(690,86); header.AnchorPoint=Vector2.new(.5,0); header.Position=UDim2.new(.5,0,0,16)
local brand=label(header,"VOTE TO RUIN IT",12,UDim2.new(0,18,0,10),UDim2.new(.72,0,0,18)); brand.TextColor3=gold; brand.TextXAlignment=Enum.TextXAlignment.Left
local phase=label(header,"THE CITADEL AWAITS",20,UDim2.new(0,18,0,34),UDim2.new(.74,0,0,35)); phase.TextXAlignment=Enum.TextXAlignment.Left
local timer=label(header,"--",32,UDim2.new(1,-84,0,21),UDim2.new(0,70,0,46))
local votePanel=panel(UDim2.new(.9,0,.43,0),UDim2.new(.05,0,.51,0)); votePanel.Visible=false
local max=Instance.new("UISizeConstraint",votePanel); max.MaxSize=Vector2.new(960,350); votePanel.AnchorPoint=Vector2.new(.5,0); votePanel.Position=UDim2.new(.5,0,.51,0)
label(votePanel,"CHOOSE YOUR CATASTROPHE",16,UDim2.new(.04,0,.035,0),UDim2.new(.92,0,.12,0))
local cards={}; local selected=nil
for i=1,3 do
 local b=Instance.new("TextButton"); b.Text=""; b.AutoButtonColor=false; b.BackgroundColor3=Color3.fromRGB(36,56,70); b.Position=UDim2.new(.025+(i-1)*.325,0,.2,0); b.Size=UDim2.new(.3,0,.73,0); b.Parent=votePanel; round(b,12)
 local scale=Instance.new("UIScale",b)
 local number=label(b,string.format("0%d /",i),14,UDim2.new(.08,0,.05,0),UDim2.new(.84,0,.14,0)); number.TextColor3=gold
 local title=label(b,"",17,UDim2.new(.08,0,.23,0),UDim2.new(.84,0,.24,0))
 local desc=label(b,"",12,UDim2.new(.08,0,.49,0),UDim2.new(.84,0,.27,0)); desc.Font=Enum.Font.Gotham
 local count=label(b,"0 VOTES",13,UDim2.new(.08,0,.8,0),UDim2.new(.84,0,.13,0))
 b.MouseEnter:Connect(function() Tween:Create(scale,TweenInfo.new(.16),{Scale=1.025}):Play() end)
 b.MouseLeave:Connect(function() Tween:Create(scale,TweenInfo.new(.16),{Scale=1}):Play() end)
 b.Activated:Connect(function() selected=i; vote:FireServer(i) end)
 cards[i]={button=b,title=title,desc=desc,count=count}
end
local banner=panel(UDim2.new(.86,0,0,146),UDim2.new(.07,0,.27,0)); banner.Visible=false
local headline=label(banner,"",27,UDim2.new(.04,0,.12,0),UDim2.new(.92,0,.4,0))
local subtitle=label(banner,"",15,UDim2.new(.06,0,.55,0),UDim2.new(.88,0,.34,0)); subtitle.Font=Enum.Font.Gotham
local tip=label(gui,"THE SKYBOUND CITADEL  /  YOUR VOTE. EVERYONE’S PROBLEM.",11,UDim2.new(.05,0,1,-30),UDim2.new(.9,0,0,22)); tip.TextColor3=gold
local shopRemote=RS.VTR:WaitForChild("Cosmetics")
local shop=panel(UDim2.new(.88,0,0,300),UDim2.new(.06,0,.3,0)); shop.Visible=false
label(shop,"THE EXCHANGE",22,UDim2.new(.05,0,.05,0),UDim2.new(.75,0,0,34))
label(shop,"Auras unlock with wins in this session. No purchases.",12,UDim2.new(.05,0,.19,0),UDim2.new(.9,0,0,32))
local close=Instance.new("TextButton",shop); close.Text="×"; close.TextSize=24; close.TextColor3=cream; close.BackgroundTransparency=1; close.Size=UDim2.new(0,40,0,40); close.Position=UDim2.new(1,-48,0,8); close.Activated:Connect(function() shop.Visible=false end)
local shopButtons={}
for i,item in ipairs(Config.Cosmetics) do
 local b=Instance.new("TextButton",shop); b.Size=UDim2.new(.9,0,0,46); b.Position=UDim2.new(.05,0,0,91+(i-1)*59); b.BackgroundColor3=Color3.fromRGB(36,56,70); b.TextColor3=item.color; b.TextSize=15; b.Font=Enum.Font.GothamBold; b.Text=item.name.."  /  "..item.wins.." WINS"; round(b,10); shopButtons[i]=b
 b.Activated:Connect(function() shopRemote:FireServer(i) end)
end
shopRemote.OnClientEvent:Connect(function(kind,index)
 if kind=="Open" then shop.Visible=true elseif kind=="Equipped" then for i,b in ipairs(shopButtons) do local item=Config.Cosmetics[i]; b.Text=(i==index and "✓  " or "")..item.name.."  /  "..item.wins.." WINS" end end
end)
local SoundService=game:GetService("SoundService")
local function sound(name,looped)
 local id=Config.Audio[name]; if not id or not string.match(id,"^rbxassetid://%d+$") then return end
 local s=Instance.new("Sound",SoundService); s.SoundId=id; s.Volume=name=="Ambient" and .18 or .4; s.Looped=looped or false; s:Play()
 if not looped then game:GetService("Debris"):AddItem(s,15) end
end
sound("Ambient",true)
local bannerVersion=0
local function announce(title,description,color)
 bannerVersion+=1; local version=bannerVersion; headline.Text=title; headline.TextColor3=color; subtitle.Text=description; banner.Visible=true; banner.BackgroundTransparency=1
 Tween:Create(banner,TweenInfo.new(.35),{BackgroundTransparency=.08}):Play()
 task.delay(4,function() if bannerVersion==version then banner.Visible=false end end)
end
local reduced=false
local motion=Instance.new("TextButton",gui); motion.Name="MotionSetting"; motion.Size=UDim2.new(0,132,0,32); motion.Position=UDim2.new(1,-144,0,112); motion.BackgroundColor3=ink; motion.TextColor3=cream; motion.Font=Enum.Font.GothamMedium; motion.TextSize=12; motion.Text="MOTION: FULL"; round(motion,8)
motion.Activated:Connect(function() reduced=not reduced; motion.Text=reduced and "MOTION: REDUCED" or "MOTION: FULL" end)
local trail=nil
local function clearTrail() if trail then for _,o in ipairs(trail) do o:Destroy() end; trail=nil end end
local function movementFX(id)
 clearTrail()
 local char=player.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); if not root or reduced then return end
 if id=="Speed" or id=="Gravity" then
  local a=Instance.new("Attachment",root); a.Position=Vector3.new(-.8,0,0)
  local b=Instance.new("Attachment",root); b.Position=Vector3.new(.8,0,0)
  local t=Instance.new("Trail",root); t.Attachment0=a; t.Attachment1=b; t.Lifetime=.35; t.MinLength=.2; t.Color=ColorSequence.new(id=="Speed" and Color3.fromRGB(117,245,175) or Color3.fromRGB(146,129,255)); t.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.35),NumberSequenceKeypoint.new(1,1)}); trail={a,b,t}
 end
end
player.CharacterAdded:Connect(clearTrail)
local lastPhase=""
local shake=0; local previousOffset=CFrame.identity; local fxCount=0
Run:BindToRenderStep("CitadelCamera",Enum.RenderPriority.Camera.Value+1,function(dt)
 local camera=workspace.CurrentCamera; if not camera then return end
 camera.CFrame=camera.CFrame*previousOffset:Inverse(); previousOffset=CFrame.identity
 if reduced then shake=0 end
 if shake>0 then shake=math.max(0,shake-dt*1.8); previousOffset=CFrame.new((math.random()-.5)*shake,(math.random()-.5)*shake,0); camera.CFrame*=previousOffset end
end)
local function burst(pos,color)
 if reduced or fxCount>=8 then return end; fxCount+=1
 local p=Instance.new("Part"); p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Transparency=1; p.Position=pos; p.Parent=workspace
 local emitter=Instance.new("ParticleEmitter",p); emitter.Texture="rbxasset://textures/particles/smoke_main.dds"; emitter.Rate=0; emitter.Lifetime=NumberRange.new(.5,1.2); emitter.Speed=NumberRange.new(8,20); emitter.SpreadAngle=Vector2.new(180,180); emitter.Color=ColorSequence.new(color); emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,3),NumberSequenceKeypoint.new(1,7)}); emitter.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.3),NumberSequenceKeypoint.new(1,1)}); emitter:Emit(20)
 task.delay(1.5,function() p:Destroy(); fxCount-=1 end)
end
remote.OnClientEvent:Connect(function(kind,a,b)
 if kind=="State" then
  if a.phase~=lastPhase then
   if a.phase=="Survive" then movementFX(a.disaster) else clearTrail() end
   lastPhase=a.phase
  end
  phase.Text=string.upper(a.phase)..(a.phase=="Survive" and ("  •  "..a.alive.." LEFT") or "")
  timer.Text=string.format("%02d",a.remaining); timer.TextColor3=a.remaining<=5 and Color3.fromRGB(255,137,105) or cream
  local was=votePanel.Visible; votePanel.Visible=a.phase=="Voting"
  if votePanel.Visible and not was then selected=nil; votePanel.BackgroundTransparency=1; Tween:Create(votePanel,TweenInfo.new(.25),{BackgroundTransparency=.08}):Play() end
  for i,c in ipairs(cards) do local d=a.choices[i]; if d then c.title.Text=d.title; c.title.TextColor3=d.color; c.desc.Text=d.description; c.count.Text=(selected==i and "✓  " or "")..tostring(a.counts[i]).." VOTES"; c.button.BackgroundColor3=selected==i and Color3.fromRGB(58,83,95) or Color3.fromRGB(36,56,70) end end
 elseif kind=="Intro" then sound("Disaster"); shop.Visible=false; announce(a.title,a.description,a.color)
 elseif kind=="Victory" then sound("Victory"); announce(#a>0 and "CITADEL SURVIVORS" or "THE CITADEL CLAIMED EVERYONE",#a>0 and table.concat(a," • ") or "A new vote. A new chance.",gold); if #a>0 and player.Character and player.Character.PrimaryPart then burst(player.Character.PrimaryPart.Position,gold) end
 elseif kind=="Effect" then
  local camera=workspace.CurrentCamera; local distance=camera and (camera.CFrame.Position-b).Magnitude or 999
  if distance<230 then
   if a=="Impact" then sound("Impact"); shake=math.max(shake,math.clamp(1-distance/180,0,.8)); burst(b,Color3.fromRGB(255,157,67)) elseif a=="Dust" then burst(b,Color3.fromRGB(176,166,139)) end
  end
 end
end)
-- Local cosmetic cycle; gameplay cues remain server controlled.
local elapsed=0
Run.Heartbeat:Connect(function(dt) elapsed+=dt; if elapsed>=1 then elapsed=0; Lighting.ClockTime=(Lighting.ClockTime+.008)%24 end end)
