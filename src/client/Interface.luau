-- Original emergency-broadcast design. Responsive composition, not a desktop canvas scaled to a phone.
local Tween=game:GetService("TweenService")
local Players=game:GetService("Players")
local Config=require(game:GetService("ReplicatedStorage").VTR.Config)
local UI={}; UI.__index=UI
local ink=Color3.fromRGB(22,29,34); local panelColor=Color3.fromRGB(31,40,46)
local white=Color3.fromRGB(243,239,225); local muted=Color3.fromRGB(164,177,180); local amber=Color3.fromRGB(237,179,91)
local function corner(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 12) end
local function text(parent,value,size,pos,dim,color,font)
 local t=Instance.new("TextLabel"); t.Text=value; t.Font=font or Enum.Font.GothamBold; t.TextSize=size; t.TextColor3=color or white
 t.Position=pos; t.Size=dim; t.BackgroundTransparency=1; t.TextWrapped=true; t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=parent; return t
end
local function frame(parent,size,pos,color)
 local f=Instance.new("Frame"); f.Size=size; f.Position=pos; f.BackgroundColor3=color or panelColor; f.BorderSizePixel=0; f.Parent=parent; corner(f)
 local stroke=Instance.new("UIStroke",f); stroke.Color=Color3.fromRGB(85,104,111); stroke.Transparency=.6
 return f
end
local function animate(object,properties,duration)
 Tween:Create(object,TweenInfo.new(duration or .2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),properties):Play()
end
local function button(parent,title,size,pos)
 local b=Instance.new("TextButton"); b.Text=title; b.Font=Enum.Font.GothamBold; b.TextSize=12; b.TextColor3=white; b.Size=size; b.Position=pos; b.BackgroundColor3=Color3.fromRGB(49,64,73); b.BorderSizePixel=0; b.AutoButtonColor=false; b.Parent=parent; corner(b,8)
 b.MouseEnter:Connect(function() animate(b,{BackgroundColor3=Color3.fromRGB(67,83,91)}) end)
 b.MouseLeave:Connect(function() animate(b,{BackgroundColor3=Color3.fromRGB(49,64,73)}) end)
 return b
end
function UI.new(callbacks)
 local self=setmetatable({callbacks=callbacks,choice=nil,phase="",deadline=0,duration=1,round=0,mode="HIGH",reduced=false,bannerToken=0},UI)
 local gui=Instance.new("ScreenGui"); gui.Name="RuinBroadcast"; gui.ResetOnSpawn=false; gui.DisplayOrder=10; gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=Players.LocalPlayer:WaitForChild("PlayerGui"); self.gui=gui
 local header=frame(gui,UDim2.fromOffset(660,94),UDim2.new(.5,0,0,12),ink); header.AnchorPoint=Vector2.new(.5,0); self.header=header
 local badge=frame(header,UDim2.fromOffset(42,42),UDim2.fromOffset(15,15),amber)
 local emblem=text(badge,"!",29,UDim2.fromScale(0,0),UDim2.fromScale(1,1),ink); emblem.TextXAlignment=Enum.TextXAlignment.Center
 text(header,"VOTE TO RUIN IT",12,UDim2.fromOffset(70,13),UDim2.new(1,-163,0,19),amber)
 self.status=text(header,"RUPTURE VALLEY",20,UDim2.fromOffset(70,35),UDim2.new(1,-164,0,29))
 self.time=text(header,"--",32,UDim2.new(1,-81,0,17),UDim2.fromOffset(66,43)); self.time.TextXAlignment=Enum.TextXAlignment.Center
 self.detail=text(header,"DISASTER SURVIVAL / LIVE",10,UDim2.fromOffset(17,70),UDim2.new(1,-30,0,17),muted)
 local track=frame(header,UDim2.new(1,-30,0,3),UDim2.new(0,15,1,-7),Color3.fromRGB(54,64,69)); track.ClipsDescendants=true
 self.progress=Instance.new("Frame",track); self.progress.BackgroundColor3=amber; self.progress.BorderSizePixel=0; self.progress.Size=UDim2.fromScale(1,1)
 self.controls=frame(gui,UDim2.fromOffset(242,32),UDim2.new(1,-12,0,115),ink); self.controls.AnchorPoint=Vector2.new(1,0)
 local graphics=button(self.controls,"FX: HIGH",UDim2.fromOffset(108,26),UDim2.fromOffset(3,3))
 graphics.Activated:Connect(function() self.mode=self.mode=="HIGH" and "LOW" or "HIGH"; graphics.Text="FX: "..self.mode; callbacks.settings(self.mode,self.reduced) end)
 local motion=button(self.controls,"MOTION: ON",UDim2.fromOffset(123,26),UDim2.fromOffset(116,3))
 motion.Activated:Connect(function() self.reduced=not self.reduced; motion.Text=self.reduced and "MOTION: OFF" or "MOTION: ON"; callbacks.settings(self.mode,self.reduced) end)
 local voting=frame(gui,UDim2.fromOffset(900,294),UDim2.new(.5,0,1,-22),ink); voting.AnchorPoint=Vector2.new(.5,1); voting.Visible=false; self.voting=voting
 text(voting,"YOU CHOOSE THE DAMAGE",19,UDim2.fromOffset(18,12),UDim2.new(1,-36,0,28))
 self.voteHelp=text(voting,"CAST ONE VOTE • YOU CAN CHANGE YOUR MIND",10,UDim2.fromOffset(18,43),UDim2.new(1,-36,0,18),muted)
 self.cards={}
 for i=1,3 do
  local b=button(voting,"",UDim2.fromOffset(276,200),UDim2.fromOffset(15+(i-1)*291,77)); b.ClipsDescendants=true
  local accent=Instance.new("Frame",b); accent.BorderSizePixel=0; accent.Size=UDim2.new(1,0,0,4); accent.BackgroundColor3=amber
  local gradient=Instance.new("UIGradient",b); gradient.Color=ColorSequence.new(Color3.fromRGB(238,243,245),Color3.fromRGB(140,163,176)); gradient.Rotation=80
  local icon=text(b,"!",36,UDim2.fromOffset(14,15),UDim2.fromOffset(46,49),amber)
  local code=text(b,string.format("HAZARD / 0%d",i),10,UDim2.fromOffset(70,24),UDim2.new(1,-84,0,18),muted)
  local title=text(b,"",21,UDim2.fromOffset(14,76),UDim2.new(1,-28,0,29))
  local desc=text(b,"",13,UDim2.fromOffset(14,111),UDim2.new(1,-28,0,45),white,Enum.Font.GothamMedium)
  local count=text(b,"0 VOTES",12,UDim2.fromOffset(14,169),UDim2.new(1,-28,0,22),amber)
  local scale=Instance.new("UIScale",b)
  b.MouseEnter:Connect(function() if not self.reduced then animate(scale,{Scale=1.018}) end end)
  b.MouseLeave:Connect(function() animate(scale,{Scale=1}) end)
  b.MouseButton1Down:Connect(function() if not self.reduced then animate(scale,{Scale=.98},.08) end end)
  b.Activated:Connect(function() animate(scale,{Scale=1}); callbacks.vote(i) end)
  self.cards[i]={button=b,icon=icon,code=code,title=title,desc=desc,count=count,accent=accent}
 end
 self.banner=frame(gui,UDim2.fromOffset(650,158),UDim2.new(.5,0,.32,0),ink); self.banner.AnchorPoint=Vector2.new(.5,.5); self.banner.Visible=false
 self.bannerTag=text(self.banner,"EMERGENCY BROADCAST",10,UDim2.fromOffset(20,14),UDim2.new(1,-40,0,20),amber)
 self.bannerTitle=text(self.banner,"",30,UDim2.fromOffset(20,43),UDim2.new(1,-40,0,46))
 self.bannerDesc=text(self.banner,"",14,UDim2.fromOffset(20,94),UDim2.new(1,-40,0,48),muted,Enum.Font.GothamMedium); self.bannerDesc.TextTruncate=Enum.TextTruncate.AtEnd
 self.bottom=text(gui,"RUPTURE VALLEY  /  VOTE. RUN. SURVIVE.",10,UDim2.new(0,15,1,-23),UDim2.new(1,-30,0,18),muted); self.bottom.TextXAlignment=Enum.TextXAlignment.Center
 self.shop=frame(gui,UDim2.fromOffset(440,355),UDim2.fromScale(.5,.5),ink); self.shop.AnchorPoint=Vector2.new(.5,.5); self.shop.Visible=false
 text(self.shop,"SURVIVOR SUPPLY",22,UDim2.fromOffset(20,17),UDim2.new(1,-70,0,30))
 text(self.shop,"Unlock auras with session wins. No purchases.",12,UDim2.fromOffset(20,55),UDim2.new(1,-40,0,38),muted)
 button(self.shop,"×",UDim2.fromOffset(32,32),UDim2.new(1,-45,0,14)).Activated:Connect(function() self.shop.Visible=false end)
 self.shopButtons={}
 for i,item in ipairs(Config.Cosmetics) do
  local b=button(self.shop,item.name.." / "..item.wins.." WINS",UDim2.new(1,-40,0,53),UDim2.fromOffset(20,101+(i-1)*64)); b.TextColor3=item.color
  b.Activated:Connect(function() callbacks.cosmetic(i) end); self.shopButtons[i]=b
 end
 self.shopFeedback=text(self.shop,"Walk to the outpost Exchange to browse.",11,UDim2.fromOffset(20,302),UDim2.new(1,-40,0,35),muted)
 local function layout()
  local camera=workspace.CurrentCamera; if not camera then return end
  local viewport=gui.AbsoluteSize; if viewport.X<1 then viewport=camera.ViewportSize end; local width=math.max(280,viewport.X-32); local portrait=viewport.X<650 and viewport.Y>500
  header.Size=UDim2.fromOffset(math.min(660,width),94)
  self.status.TextSize=width<400 and 15 or 20
  voting.Size=UDim2.fromOffset(math.min(900,width),portrait and 405 or 294)
  voting.Position=UDim2.new(.5,0,1,-(portrait and 30 or 24))
  if viewport.Y<500 then voting.Size=UDim2.fromOffset(math.min(900,width),224) end
  for i,c in ipairs(self.cards) do
   if portrait then
    c.button.Position=UDim2.new(0,12,0,75+(i-1)*105); c.button.Size=UDim2.new(1,-24,0,97)
    c.icon.Position=UDim2.fromOffset(12,13); c.icon.Size=UDim2.fromOffset(38,46); c.icon.TextSize=29
    c.code.Visible=false; c.title.TextSize=17; c.title.Position=UDim2.fromOffset(62,10); c.title.Size=UDim2.new(1,-75,0,22)
    c.desc.Position=UDim2.fromOffset(62,34); c.desc.Size=UDim2.new(1,-75,0,34); c.desc.TextSize=11
    c.count.Position=UDim2.fromOffset(62,70); c.count.Size=UDim2.new(1,-75,0,18)
   else
    local short=viewport.Y<500
    c.button.Position=UDim2.new((i-1)/3,14,0,short and 64 or 77); c.button.Size=UDim2.new(1/3,-22,1,short and -76 or -94)
    c.icon.Position=UDim2.fromOffset(12,short and 6 or 15); c.icon.Size=UDim2.fromOffset(42,short and 33 or 49); c.icon.TextSize=short and 25 or 36
    c.code.Visible=true; c.code.Position=UDim2.fromOffset(62,short and 15 or 24)
    c.title.TextSize=short and 17 or 20; c.title.Position=UDim2.fromOffset(14,short and 43 or 72); c.title.Size=UDim2.new(1,-28,0,27)
    c.desc.TextSize=short and 11 or 13; c.desc.Position=UDim2.fromOffset(14,short and 73 or 104); c.desc.Size=UDim2.new(1,-28,0,short and 34 or 45)
    c.count.Position=UDim2.new(0,14,1,-28); c.count.Size=UDim2.new(1,-28,0,20)
   end
  end
  self.banner.Size=UDim2.fromOffset(math.min(650,width),158); self.bannerTitle.TextSize=width<440 and 23 or 30
  self.shop.Size=UDim2.fromOffset(math.min(440,width),355)
  self.controls.Position=UDim2.new(1,-12,0,viewport.Y<500 and 8 or 115)
  if viewport.Y<500 then header.Size=UDim2.fromOffset(math.min(500,math.max(280,viewport.X-285)),94); header.Position=UDim2.fromOffset(12,8); header.AnchorPoint=Vector2.zero
  else header.Position=UDim2.new(.5,0,0,12); header.AnchorPoint=Vector2.new(.5,0) end
 end
 local cameraConnection
 local function bindCamera()
  if cameraConnection then cameraConnection:Disconnect() end
  local camera=workspace.CurrentCamera; if camera then cameraConnection=camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout) end; layout()
 end
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
 workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera); bindCamera()
 return self
end
function UI:update(state)
 local changed=state.phase~=self.phase or state.round~=self.round
 if changed and state.phase=="Voting" then for _,c in ipairs(self.cards) do c.accent.Size=UDim2.new(1,0,0,4) end; self.choice=nil; self.voteHelp.Text="CAST ONE VOTE • YOU CAN CHANGE YOUR MIND" end
 self.phase=state.phase; self.round=state.round; self.deadline=state.deadline; self.duration=state.duration
 local names={Intermission="NEXT ROUND INCOMING",Voting="CAST YOUR VOTE",Prepare="BRACE FOR IMPACT",Survive="SURVIVE THE CHAOS",Results="ROUND COMPLETE",Rebuilding="REBUILDING THE VALLEY"}
 self.status.Text=names[state.phase] or string.upper(state.phase)
 self.detail.Text=string.format("ROUND %02d  /  %s",state.round,state.phase=="Survive" and state.alive.." SURVIVORS" or Config.MapName)
 local show=state.phase=="Voting"
 if show and not self.voting.Visible and not self.reduced then
  self.voting.Position+=UDim2.fromOffset(0,35); animate(self.voting,{Position=self.voting.Position-UDim2.fromOffset(0,35)},.4)
 end
 self.voting.Visible=show
 for i,c in ipairs(self.cards) do
  local d=state.choices[i]; c.button.Visible=d~=nil
  if d then c.icon.Text=d.icon; c.icon.TextColor3=d.color; c.accent.BackgroundColor3=d.color; c.title.Text=d.title; c.desc.Text=d.description; c.count.Text=(self.choice==i and "✓ YOUR VOTE  /  " or "")..state.counts[i].." VOTES" end
 end
end
function UI:accepted(index)
 self.choice=index; self.voteHelp.Text="VOTE LOCKED IN • CHANGE IT BEFORE THE TIMER ENDS"
 for i,c in ipairs(self.cards) do c.accent.Size=UDim2.new(1,0,0,i==index and 7 or 4) end
end
function UI:tick()
 local remain=math.max(0,self.deadline-workspace:GetServerTimeNow())
 local value=string.format("%02d",math.ceil(remain))
 if self.time.Text~=value then
  self.time.Text=value
  if remain<5 and not self.reduced then self.time.TextSize=36; animate(self.time,{TextSize=32},.25) end
 end
 self.time.TextColor3=remain<5 and Color3.fromRGB(240,134,98) or white
 self.progress.Size=UDim2.fromScale(math.clamp(remain/math.max(self.duration,1),0,1),1)
end
function UI:announce(tag,title,description,color,duration)
 self.bannerToken+=1; local token=self.bannerToken
 self.bannerTag.Text=tag; self.bannerTitle.Text=title; self.bannerDesc.Text=description; self.bannerTitle.TextColor3=color or amber; self.banner.Visible=true
 if not self.reduced then self.banner.Position=UDim2.new(.5,0,.32,18); animate(self.banner,{Position=UDim2.new(.5,0,.32,0)},.4) end
 task.delay(duration or 4,function() if self.bannerToken==token then self.banner.Visible=false end end)
end
function UI:victory(won)
 if not won or self.reduced then return end
 -- One-shot screen-space paper fragments: no physics replication and no persistent render loop.
 for i=1,self.mode=="LOW" and 8 or 22 do
  local p=Instance.new("Frame",self.gui); p.BorderSizePixel=0; p.Size=UDim2.fromOffset(5+i%4,9+i%5)
  p.Position=UDim2.fromScale((i*0.618)%1,-.04); p.Rotation=i*31; p.BackgroundColor3=i%2==0 and amber or Color3.fromRGB(135,181,174)
  Tween:Create(p,TweenInfo.new(1.8+(i%5)*.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.fromScale((i*0.618+.12)%1,1.1),Rotation=p.Rotation+240,BackgroundTransparency=.65}):Play()
  game:GetService("Debris"):AddItem(p,2.7)
 end
end
function UI:cosmetic(kind,index)
 if kind=="Open" then self.shop.Visible=true
 elseif kind=="Equipped" then
  self.shopFeedback.Text="EQUIPPED / "..Config.Cosmetics[index].name
  for i,b in ipairs(self.shopButtons) do b.Text=(i==index and "✓  " or "")..Config.Cosmetics[i].name.." / "..Config.Cosmetics[i].wins.." WINS" end
 elseif kind=="Locked" then self.shopFeedback.Text="Keep surviving — you need more session wins." end
end
return UI
