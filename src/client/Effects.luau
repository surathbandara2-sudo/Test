local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local Lighting=game:GetService("Lighting")
local SoundService=game:GetService("SoundService")
local Actions=game:GetService("ContextActionService")
local Config=require(game:GetService("ReplicatedStorage").VTR.Config)
local Effects={}; Effects.__index=Effects
local player=Players.LocalPlayer
function Effects.new()
 local self=setmetatable({low=false,reduced=false,shake=0,offset=CFrame.identity,fx=0,wind={},trail={},emitters={},cinematic=nil,elapsed=0,weather={},lastSound={}},Effects)
 local gui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui")); gui.Name="DisasterLetterbox"; gui.IgnoreGuiInset=true; gui.DisplayOrder=5
 for i=1,2 do local bar=Instance.new("Frame",gui); bar.BackgroundColor3=Color3.new(); bar.BorderSizePixel=0; bar.Size=UDim2.new(1,0,0,0); bar.Position=i==1 and UDim2.fromScale(0,0) or UDim2.fromScale(0,1); bar.AnchorPoint=i==1 and Vector2.zero or Vector2.new(0,1); table.insert(self.weather,bar) end
 local atmosphere=Instance.new("ColorCorrectionEffect",Lighting); atmosphere.Name="LocalDisasterGrade"; atmosphere.Brightness=0; self.grade=atmosphere
 self.folder=Instance.new("Folder",workspace); self.folder.Name="LocalRuinEffects"
 local weatherPart=Instance.new("Part",self.folder); weatherPart.Name="Local airborne dust"; weatherPart.Anchored=true; weatherPart.Transparency=1; weatherPart.CanCollide=false; weatherPart.CanTouch=false; weatherPart.CanQuery=false
 local wa=Instance.new("Attachment",weatherPart)
 local dust=Instance.new("ParticleEmitter",wa); dust.Texture="rbxasset://textures/particles/smoke_main.dds"; dust.Rate=5; dust.Lifetime=NumberRange.new(2,4); dust.Speed=NumberRange.new(2,4); dust.SpreadAngle=Vector2.new(160,160); dust.Acceleration=Vector3.new(3,-2,0); dust.Size=NumberSequence.new(.3); dust.Color=ColorSequence.new(Color3.fromRGB(184,177,153)); dust.Transparency=NumberSequence.new(.65); dust.Enabled=false
 self.weatherPart=weatherPart; self.airborne=dust

 local function register(p)
  if not p:IsA("BasePart") then return end
  if p:GetAttribute("Wind") then self.wind[p]=p.CFrame end
  if p:GetAttribute("Smoke") or p:GetAttribute("Waterfall") then
   local a=Instance.new("Attachment",p); a.Name="LocalAtmospherics"; a.Position=Vector3.new(0,p.Size.Y/2,0)
   local e=Instance.new("ParticleEmitter",a); e.Texture="rbxasset://textures/particles/smoke_main.dds"; e.Rate=4; e.Enabled=not self.low
   e.Lifetime=NumberRange.new(2,4); e.Speed=NumberRange.new(2,4); e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,2),NumberSequenceKeypoint.new(1,9)})
   e.Color=ColorSequence.new(p:GetAttribute("Smoke") and Color3.fromRGB(119,123,122) or Color3.fromRGB(196,220,217)); e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.7),NumberSequenceKeypoint.new(1,1)}); e.Acceleration=Vector3.new(2,2,0)
   if p:GetAttribute("Waterfall") then e.Acceleration=Vector3.new(0,-8,0); e.Speed=NumberRange.new(10,15) end
   self.emitters[e]=true
  elseif p:GetAttribute("Meteor") then
   local a=Instance.new("Attachment",p); local b=Instance.new("Attachment",p); a.Position=Vector3.new(-2,0,0); b.Position=Vector3.new(2,0,0)
   local t=Instance.new("Trail",p); t.Attachment0=a; t.Attachment1=b; t.Lifetime=.3; t.Color=ColorSequence.new(Color3.fromRGB(245,158,88)); t.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.1),NumberSequenceKeypoint.new(1,1)})
  end
 end
 for _,p in ipairs(workspace:GetDescendants()) do register(p) end
 workspace.DescendantAdded:Connect(register)
 workspace.DescendantRemoving:Connect(function(p) self.wind[p]=nil; self.emitters[p]=nil end)
 -- Remove our previous shake before Roblox's camera controller runs; apply a new offset afterward.
 Run:BindToRenderStep("RuinCameraRestore",Enum.RenderPriority.Camera.Value-1,function()
  local camera=workspace.CurrentCamera
  if camera and self.shakenCamera==camera then camera.CFrame*=self.offset:Inverse() end
  self.offset=CFrame.identity; self.shakenCamera=nil
 end)
 Run:BindToRenderStep("RuinCameraEffects",Enum.RenderPriority.Camera.Value+1,function(dt)
  local camera=workspace.CurrentCamera; if not camera then return end
  if self.cinematic and self.cinematic.camera~=camera then self:stopIntro() end
  if self.cinematic then
   local progress=math.clamp((os.clock()-self.cinematic.started)/2.6,0,1)
   local eased=1-(1-progress)^3
   camera.CFrame=CFrame.lookAt(Vector3.new(180-eased*65,190-eased*30,205-eased*60),Vector3.new(0,90,0))
   if progress>=1 then self:stopIntro() end
  elseif not self.reduced and self.shake>.005 then
   self.elapsed+=dt; self.shake*=math.exp(-dt*5)
   local t=self.elapsed*22
   self.offset=CFrame.new(math.noise(t,0)*self.shake,math.noise(0,t)*self.shake,0)*CFrame.Angles(0,0,math.noise(t,t)*self.shake*.008)
   camera.CFrame*=self.offset; self.shakenCamera=camera
  end
 end)
 local windClock=0
 Run.Heartbeat:Connect(function(dt)
  windClock+=dt; if windClock<.1 then return end; windClock=0
  local camera=workspace.CurrentCamera; if not camera then return end
  self.weatherPart.Position=camera.CFrame.Position+Vector3.new(0,8,-9)
  local n=0; local clock=os.clock()
  for p,base in pairs(self.wind) do
   if not p.Parent or not p.Anchored or not p:GetAttribute("Wind") then self.wind[p]=nil
   elseif not self.low and not self.reduced and (p.Position-camera.CFrame.Position).Magnitude<135 then
    p.CFrame=base*CFrame.Angles(0,0,math.sin(clock*1.3+base.Position.X)*.018); n+=1
    if n>=16 then break end
   end
  end
 end)
 player.CharacterAdded:Connect(function() self:stopIntro(); self:clearTrail() end)
 self:sound("Ambient",true)
 return self
end
function Effects:sound(name,looped)
 local id=Config.Audio[name]; if not id or not string.match(id,"^rbxassetid://%d+$") then return end
 local now=os.clock(); if self.lastSound[name] and now-self.lastSound[name]<.2 then return end; self.lastSound[name]=now
 local s=Instance.new("Sound",SoundService); s.SoundId=id; s.Volume=name=="Ambient" and .17 or .4; s.Looped=looped or false; s:Play(); if not looped then Debris:AddItem(s,15) end
end
function Effects:clearTrail()
 for _,p in ipairs(self.trail) do p:Destroy() end; table.clear(self.trail)
end
function Effects:movement(id)
 self:clearTrail(); if self.reduced or self.low or (id~="Speed" and id~="Gravity") or not player:GetAttribute("InRound") then return end
 local char=player.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); if not root then return end
 local a=Instance.new("Attachment",root); a.Position=Vector3.new(-.7,0,0); local b=Instance.new("Attachment",root); b.Position=Vector3.new(.7,0,0)
 local t=Instance.new("Trail",root); t.Attachment0=a; t.Attachment1=b; t.Lifetime=.22; t.Color=ColorSequence.new(Color3.fromRGB(175,206,201)); t.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.65),NumberSequenceKeypoint.new(1,1)}); self.trail={a,b,t}
end
function Effects:settings(mode,reduced)
 self.low=mode=="LOW"; self.reduced=reduced
 self.airborne.Enabled=self.storm and not self.low and not reduced or false
 if reduced then self.shake=0; self:stopIntro() end
 self:clearTrail()
 for p,base in pairs(self.wind) do if p.Parent and p.Anchored then p.CFrame=base end end
 for e in pairs(self.emitters) do if e.Parent then e.Enabled=not self.low else self.emitters[e]=nil end end
 local bloom=Lighting:FindFirstChild("ValleyBloom"); if bloom then bloom.Enabled=not self.low end
end
function Effects:stopIntro()
 if not self.cinematic then return end
 local old=self.cinematic; self.cinematic=nil
 Actions:UnbindAction("RuinIntroMovement")
 if old.camera==workspace.CurrentCamera then
  old.camera.CameraType=old.type; old.camera.FieldOfView=old.fov
  local c=player.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
  if h then old.camera.CameraSubject=h elseif old.subject and old.subject.Parent then old.camera.CameraSubject=old.subject end
 end
 for _,bar in ipairs(self.weather) do Tween:Create(bar,TweenInfo.new(.2),{Size=UDim2.new(1,0,0,0)}):Play() end
end
function Effects:intro()
 self:stopIntro()
 if self.reduced or not player:GetAttribute("InRound") then return end
 local camera=workspace.CurrentCamera; if not camera then return end
 self.cinematic={camera=camera,type=camera.CameraType,subject=camera.CameraSubject,fov=camera.FieldOfView,started=os.clock()}
 camera.CameraType=Enum.CameraType.Scriptable; camera.FieldOfView=62
 Actions:BindActionAtPriority("RuinIntroMovement",function() return Enum.ContextActionResult.Sink end,false,Enum.ContextActionPriority.High.Value,unpack(Enum.PlayerActions:GetEnumItems()))
 for _,bar in ipairs(self.weather) do Tween:Create(bar,TweenInfo.new(.25),{Size=UDim2.new(1,0,0,.065*camera.ViewportSize.Y)}):Play() end
end
function Effects:phase(phase,id)
 if phase=="Survive" then self:stopIntro(); self:movement(id) else self:clearTrail() end
 if phase~="Prepare" then self:stopIntro() end
 if self.gradeTween then self.gradeTween:Cancel() end
 local storm=phase=="Survive" and (id=="Meteors" or id=="Earthquake")
 self.storm=phase=="Survive" and (id=="Meteors" or id=="Earthquake" or id=="Lava")
 self.airborne.Enabled=self.storm and not self.low and not self.reduced or false
 self.gradeTween=Tween:Create(self.grade,TweenInfo.new(1),{Brightness=storm and -.035 or 0,Saturation=storm and -.1 or 0}); self.gradeTween:Play()
end
function Effects:burst(pos,color)
 if self.fx>=(self.low and 3 or 8) then return end; self.fx+=1
 local p=Instance.new("Part",self.folder); p.Position=pos; p.Anchored=true; p.Transparency=1; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false
 local a=Instance.new("Attachment",p); local e=Instance.new("ParticleEmitter",a)
 e.Texture="rbxasset://textures/particles/smoke_main.dds"; e.Rate=0; e.Color=ColorSequence.new(color); e.Lifetime=NumberRange.new(.8,1.6); e.Speed=NumberRange.new(7,18); e.Drag=3; e.SpreadAngle=Vector2.new(180,180); e.Acceleration=Vector3.new(0,3,0)
 e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,2),NumberSequenceKeypoint.new(1,12)}); e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.3),NumberSequenceKeypoint.new(1,1)}); e:Emit(self.low and 6 or 22)
 task.delay(1.8,function() p:Destroy(); self.fx-=1 end)
end
function Effects:cracks(pos)
 -- Cosmetic cracks have a short life and never modify server collision or danger timing.
 for i=1,self.low and 2 or 5 do
  local p=Instance.new("Part",self.folder); p.Name="Fault fissure"; p.Size=Vector3.new(.2,.08,9+i); p.CFrame=CFrame.new(pos+Vector3.new((i-3)*2,.1,0))*CFrame.Angles(0,i*.8,0); p.Color=Color3.fromRGB(52,47,41); p.Material=Enum.Material.Slate; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; Debris:AddItem(p,5)
 end
end
function Effects:event(kind,pos)
 local camera=workspace.CurrentCamera; local distance=camera and (camera.CFrame.Position-pos).Magnitude or 999
 if distance>270 then return end
 if kind=="Impact" or kind=="Quake" then
  self:sound(kind=="Quake" and "Earthquake" or "Impact")
  if not self.reduced then self.shake=math.max(self.shake,math.clamp(1-distance/220,0,.8)) end
  self:burst(pos,Color3.fromRGB(153,141,123))
  if kind=="Impact" and not self.low and not self.reduced and self.fx<7 then
   local ring=Instance.new("Part",self.folder); ring.Shape=Enum.PartType.Cylinder; ring.Size=Vector3.new(.1,3,3); ring.CFrame=CFrame.new(pos+Vector3.new(0,.2,0))*CFrame.Angles(0,0,math.pi/2); ring.Color=Color3.fromRGB(219,205,178); ring.Material=Enum.Material.SmoothPlastic; ring.Transparency=.6; ring.Anchored=true; ring.CanCollide=false; ring.CanTouch=false; ring.CanQuery=false
   Tween:Create(ring,TweenInfo.new(.45),{Size=Vector3.new(.1,55,55),Transparency=1}):Play(); Debris:AddItem(ring,.5)
  end
 elseif kind=="Dust" then self:burst(pos,Color3.fromRGB(153,147,129))
 elseif kind=="Crack" then self:cracks(pos)
 elseif kind=="Gravity" and not self.low then self:burst(pos,Color3.fromRGB(172,185,192)) end
end
return Effects
