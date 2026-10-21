local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Debris=game:GetService("Debris")
local Config=require(RS.VTR.Config)
local Rules=require(RS.VTR.RoundRules)
local world=require(script.Parent.World).build()
local remote=Instance.new("RemoteEvent"); remote.Name="RoundEvent"; remote.Parent=RS.VTR
local voteRemote=Instance.new("RemoteEvent"); voteRemote.Name="Vote"; voteRemote.Parent=RS.VTR
local shopRemote=Instance.new("RemoteEvent"); shopRemote.Name="Cosmetics"; shopRemote.Parent=RS.VTR
local equipped={}; local lastEquip={}
local function applyCosmetic(p)
 local char=p.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); if not root then return end
 local old=root:FindFirstChild("CitadelAura"); if old then old:Destroy() end
 local index=equipped[p] or 1
 if index==1 then return end
 local a=Instance.new("Attachment",root); a.Name="CitadelAura"
 local e=Instance.new("ParticleEmitter",a); e.Texture="rbxasset://textures/particles/sparkles_main.dds"; e.Color=ColorSequence.new(Config.Cosmetics[index].color); e.Rate=5; e.Lifetime=NumberRange.new(.7,1.3); e.Speed=NumberRange.new(1,3); e.SpreadAngle=Vector2.new(180,180); e.Size=NumberSequence.new(.18); e.LightEmission=.7
end
shopRemote.OnServerEvent:Connect(function(p,index)
 if not Rules.validVote(index,#Config.Cosmetics) then return end
 local now=os.clock(); if lastEquip[p] and now-lastEquip[p]<.5 then return end; lastEquip[p]=now
 local stats=p:FindFirstChild("leaderstats"); if not stats or stats.Wins.Value<Config.Cosmetics[index].wins then return end
 equipped[p]=index; applyCosmetic(p); shopRemote:FireClient(p,"Equipped",index)
end)
local promptAnchor=Instance.new("Part"); promptAnchor.Name="ExchangeInteraction"; promptAnchor.Size=Vector3.new(1,1,1); promptAnchor.Position=Vector3.new(-52,84,170); promptAnchor.Anchored=true; promptAnchor.Transparency=1; promptAnchor.CanCollide=false; promptAnchor.Parent=world
local prompt=Instance.new("ProximityPrompt",promptAnchor); prompt.ActionText="Browse auras"; prompt.ObjectText="The Exchange"; prompt.MaxActivationDistance=16; prompt.RequiresLineOfSight=false
prompt.Triggered:Connect(function(p) shopRemote:FireClient(p,"Open") end)
local state={phase="Intermission",remaining=0,choices={},counts={},disaster="",alive=0}
local votes={}; local active={}; local voting=false; local rng=Random.new()
local function broadcast() remote:FireAllClients("State",state) end
local function character(player) local c=player.Character; return c,c and c:FindFirstChildOfClass("Humanoid"),c and c:FindFirstChild("HumanoidRootPart") end
local function lobby(p) local _,h,r=character(p); if r then r.CFrame=CFrame.new(Config.LobbySpawn) end; if h then h.WalkSpeed=16; h.JumpPower=50 end end
local function setup(p)
 local stats=Instance.new("Folder"); stats.Name="leaderstats"; stats.Parent=p
 local wins=Instance.new("IntValue"); wins.Name="Wins"; wins.Parent=stats
 p.CharacterAdded:Connect(function(c) active[p]=nil; c:WaitForChild("Humanoid").Died:Connect(function() active[p]=nil end); c:WaitForChild("HumanoidRootPart"); applyCosmetic(p) end)
 task.defer(function() if p.Parent then remote:FireClient(p,"State",state) end end)
end
Players.PlayerAdded:Connect(setup); for _,p in ipairs(Players:GetPlayers()) do setup(p) end
Players.PlayerRemoving:Connect(function(p) active[p]=nil; votes[p]=nil; equipped[p]=nil; lastEquip[p]=nil end)
voteRemote.OnServerEvent:Connect(function(p,index)
 if not voting or not Rules.validVote(index,#state.choices) then return end
 if votes[p]==index then return end
 if votes[p] then state.counts[votes[p]]=math.max(0,state.counts[votes[p]]-1) end
 votes[p]=index; state.counts[index]+=1; broadcast()
end)
local function waitPhase(name,seconds)
 state.phase=name
 for t=seconds,1,-1 do state.remaining=t; state.alive=0; for _ in pairs(active) do state.alive+=1 end; broadcast(); task.wait(1) end
end
local function hazardPart(name,size,pos,color)
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=pos; p.Anchored=true; p.Material=Enum.Material.Neon; p.Color=color; p.Parent=world; return p
end
local function damageAt(pos,radius)
 for p in pairs(active) do local _,h,r=character(p); if h and r and (r.Position-pos).Magnitude<radius then h:TakeDamage(100) end end
end
local function beginDisaster(id)
 local running=true; local objects={}; local connections={}; local changedTiles={}; local tweens={}; local oldGravity=workspace.Gravity
 local function keep(p) table.insert(objects,p); return p end
 if id=="Gravity" then workspace.Gravity=65 end
 for p in pairs(active) do local _,h=character(p); if h and id=="Speed" then h.WalkSpeed=36 end end
 if id=="Lava" then
  local lava=keep(hazardPart("Rising lava",Vector3.new(177,2,177),Vector3.new(0,74,0),Color3.fromRGB(255,91,35))); lava.CanCollide=false
  task.spawn(function() while running do lava.Position+=Vector3.new(0,.055,0); for p in pairs(active) do local _,h,r=character(p); if h and r and r.Position.Y<lava.Position.Y+3 then h:TakeDamage(9) end end; task.wait(.25) end end)
 elseif id=="Meteors" then
  task.spawn(function() while running do
   local target=Vector3.new(rng:NextNumber(-80,80),80.2,rng:NextNumber(-80,80))
   local marker=keep(hazardPart("Impact warning",Vector3.new(18,.15,18),target,Color3.fromRGB(255,66,65))); marker.CanCollide=false; marker.Transparency=.4
   remote:FireAllClients("Effect","Warning",target)
   task.wait(1.4); if not running then break end
   local meteor=keep(hazardPart("Meteor",Vector3.new(7,7,7),target+Vector3.new(20,95,0),Color3.fromRGB(255,147,53))); meteor.Shape=Enum.PartType.Ball; meteor.CanCollide=false
   game:GetService("TweenService"):Create(meteor,TweenInfo.new(.55,Enum.EasingStyle.Linear),{Position=target}):Play()
   task.wait(.55); if not running then break end
   damageAt(target,13); remote:FireAllClients("Effect","Impact",target); meteor:Destroy(); marker:Destroy(); task.wait(.45)
  end end)
 elseif id=="Collapse" then
  task.spawn(function() local tiles=world.ArenaTiles:GetChildren(); while running and #tiles>12 do
   local index=rng:NextInteger(1,#tiles); local tile=table.remove(tiles,index); table.insert(changedTiles,{tile=tile,cf=tile.CFrame,color=tile.Color})
   tile.Color=Color3.fromRGB(255,170,59); remote:FireAllClients("Effect","Warning",tile.Position); task.wait(1)
   if not running then break end
   remote:FireAllClients("Effect","Dust",tile.Position); tile.CanCollide=false; local tween=game:GetService("TweenService"):Create(tile,TweenInfo.new(.3),{CFrame=tile.CFrame*CFrame.new(0,-24,0)}); table.insert(tweens,tween); tween:Play(); task.wait(.35)
  end end)
 elseif id=="Balls" then
  task.spawn(function() while running do
   local ball=keep(hazardPart("Celestial core",Vector3.new(13,13,13),Vector3.new(-83,89,rng:NextNumber(-70,70)),Color3.fromRGB(65,212,219))); ball.Shape=Enum.PartType.Ball; ball.Anchored=false; ball:SetNetworkOwner(nil); ball.AssemblyLinearVelocity=Vector3.new(65,0,rng:NextNumber(-12,12))
   table.insert(connections,ball.Touched:Connect(function(hit) local p=Players:GetPlayerFromCharacter(hit.Parent); if p and active[p] then local _,h=character(p); if h then h:TakeDamage(100) end end end)); Debris:AddItem(ball,6); task.wait(2.5)
  end end)
 end
 return function()
  running=false; workspace.Gravity=oldGravity
  for _,tween in ipairs(tweens) do tween:Cancel() end
  for _,c in ipairs(connections) do c:Disconnect() end
  for _,p in ipairs(objects) do p:Destroy() end
  for _,entry in ipairs(changedTiles) do entry.tile.Anchored=true; entry.tile.CanCollide=true; entry.tile.AssemblyLinearVelocity=Vector3.zero; entry.tile.CFrame=entry.cf; entry.tile.Color=entry.color end
  for p in pairs(active) do local _,h=character(p); if h then h.WalkSpeed=16 end end
 end
end
-- Bounds checks also eliminate players who fall without relying on Touched events.
task.spawn(function() while true do for p in pairs(active) do local _,h,r=character(p); if not h or h.Health<=0 or not r then active[p]=nil elseif r.Position.Y<65 or math.abs(r.Position.X)>96 or math.abs(r.Position.Z)>96 then h.Health=0; active[p]=nil end end; task.wait(.2) end end)
while true do
 active={}; state.disaster=""; state.choices={}; state.counts={}; waitPhase("Intermission",Config.Intermission)
 local pool=table.clone(Config.Disasters); state.choices={}; state.counts={}; votes={}
 for i=1,math.min(3,#pool) do local index=rng:NextInteger(1,#pool); state.choices[i]=table.remove(pool,index); state.counts[i]=0 end
 voting=true; waitPhase("Voting",Config.Voting); voting=false
 local tied=Rules.winnerIndices(state.counts)
 local selected=state.choices[tied[rng:NextInteger(1,#tied)]]; state.disaster=selected.id
 for _,p in ipairs(Players:GetPlayers()) do
  local _,h,r=character(p); if h and r and h.Health>0 then active[p]=true; r.CFrame=CFrame.new(rng:NextNumber(-35,35),86,rng:NextNumber(-35,35)); local ff=p.Character:FindFirstChildOfClass("ForceField"); if ff then ff:Destroy() end end
 end
 remote:FireAllClients("Intro",selected); waitPhase("Prepare",4)
 local cleanup=beginDisaster(selected.id); waitPhase("Survive",Config.Round); cleanup()
 local winners={}; for p in pairs(active) do table.insert(winners,p.DisplayName); p.leaderstats.Wins.Value+=1 end
 remote:FireAllClients("Victory",winners); waitPhase("Results",6)
 for _,p in ipairs(Players:GetPlayers()) do lobby(p) end
end
