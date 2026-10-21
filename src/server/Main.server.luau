local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Config=require(RS.VTR.Config)
local Rules=require(RS.VTR.RoundRules)
local World=require(script.Parent.World)
local Destruction=require(script.Parent.Destruction)
local Disasters=require(script.Parent.Disasters)
local world=World.build()
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
 local stats=p:FindFirstChild("leaderstats"); if not stats or stats.Wins.Value<Config.Cosmetics[index].wins then shopRemote:FireClient(p,"Locked",index); return end
 equipped[p]=index; applyCosmetic(p); shopRemote:FireClient(p,"Equipped",index)
end)
local promptAnchor=Instance.new("Part"); promptAnchor.Name="ExchangeInteraction"; promptAnchor.Size=Vector3.new(1,1,1); promptAnchor.Position=Config.ShopPosition; promptAnchor.Anchored=true; promptAnchor.Transparency=1; promptAnchor.CanCollide=false; promptAnchor.Parent=world
local prompt=Instance.new("ProximityPrompt",promptAnchor); prompt.ActionText="Browse auras"; prompt.ObjectText="The Exchange"; prompt.MaxActivationDistance=16; prompt.RequiresLineOfSight=false
prompt.Triggered:Connect(function(p) shopRemote:FireClient(p,"Open") end)
local state={phase="Intermission",remaining=0,duration=Config.Intermission,deadline=0,choices={},counts={},disaster="",alive=0,round=0}
local votes={}; local active={}; local voting=false; local rng=Random.new(); local lastVote={}; local lastReady={}
local function broadcast() remote:FireAllClients("State",state) end
local function character(player) local c=player.Character; return c,c and c:FindFirstChildOfClass("Humanoid"),c and c:FindFirstChild("HumanoidRootPart") end
local function lobby(p)
 p:SetAttribute("InRound",false)
 local _,h,r=character(p); if r then r.AssemblyLinearVelocity=Vector3.zero; r.CFrame=CFrame.new(Config.LobbySpawn) end
 if h then h.WalkSpeed=16 end
end
local function setup(p)
 local stats=p:FindFirstChild("leaderstats") or Instance.new("Folder"); stats.Name="leaderstats"; stats.Parent=p
 if not stats:FindFirstChild("Wins") then local wins=Instance.new("IntValue"); wins.Name="Wins"; wins.Parent=stats end
 p:SetAttribute("InRound",false)
 local function onCharacter(c)
  active[p]=nil; p:SetAttribute("InRound",false); Destruction.character(c)
  local h=c:WaitForChild("Humanoid",10); if h then h.Died:Connect(function() active[p]=nil; p:SetAttribute("InRound",false) end) end
  local r=c:WaitForChild("HumanoidRootPart",10); if r then applyCosmetic(p) end
 end
 p.CharacterAdded:Connect(onCharacter); if p.Character then task.spawn(onCharacter,p.Character) end
end
Players.PlayerAdded:Connect(setup); for _,p in ipairs(Players:GetPlayers()) do setup(p) end
Players.PlayerRemoving:Connect(function(p)
 active[p]=nil
 if voting and votes[p] then state.counts[votes[p]]=math.max(0,state.counts[votes[p]]-1) end
 votes[p]=nil; equipped[p]=nil; lastEquip[p]=nil; lastVote[p]=nil; lastReady[p]=nil
end)
remote.OnServerEvent:Connect(function(p,kind)
 if kind~="Ready" then return end
 local now=os.clock(); if lastReady[p] and now-lastReady[p]<1 then return end; lastReady[p]=now
 remote:FireClient(p,"State",state)
end)
voteRemote.OnServerEvent:Connect(function(p,index)
 if not voting or not Rules.validVote(index,#state.choices) then return end
 local now=os.clock(); if lastVote[p] and now-lastVote[p]<.15 then return end; lastVote[p]=now
 if votes[p]~=index then
  if votes[p] then state.counts[votes[p]]=math.max(0,state.counts[votes[p]]-1) end
  votes[p]=index; state.counts[index]+=1
 end
 remote:FireClient(p,"VoteAccepted",index); broadcast()
end)
local function waitPhase(name,seconds,health)
 state.phase=name; state.duration=seconds; state.deadline=workspace:GetServerTimeNow()+seconds
 for t=seconds,1,-1 do
  local failure=health and health(); if failure then error(failure) end
  state.remaining=t; state.alive=0; for _ in pairs(active) do state.alive+=1 end
  broadcast(); task.wait(1)
 end
end
-- Authoritative elimination; cosmetic rubble uses collision groups and cannot kill by physics alone.
task.spawn(function()
 while true do
  for p in pairs(active) do
   local _,h,r=character(p)
   if not h or h.Health<=0 or not r then active[p]=nil; p:SetAttribute("InRound",false)
   elseif not Rules.insideArena(r.Position.X,r.Position.Y,r.Position.Z,Config.ArenaHalf+2) then h.Health=0; active[p]=nil; p:SetAttribute("InRound",false) end
  end
  task.wait(.2)
 end
end)
assert(#Config.Disasters>0,"At least one disaster must be configured")
while true do
 active={}; state.round+=1; state.disaster=""; state.choices={}; state.counts={}
 waitPhase("Intermission",Config.Intermission)
 local pool=table.clone(Config.Disasters); votes={}; lastVote={}
 for i=1,math.min(3,#pool) do local index=rng:NextInteger(1,#pool); state.choices[i]=table.remove(pool,index); state.counts[i]=0 end
 voting=true; waitPhase("Voting",Config.Voting); voting=false
 local tied=Rules.winnerIndices(state.counts)
 local selected=state.choices[tied[rng:NextInteger(1,#tied)]]; state.disaster=selected.id
 local prepared={}
 for _,p in ipairs(Players:GetPlayers()) do
  local _,h,r=character(p)
  if h and r and h.Health>0 then
   prepared[h]={WalkSpeed=h.WalkSpeed,JumpPower=h.JumpPower,JumpHeight=h.JumpHeight}
   h.WalkSpeed=0; h.JumpPower=0; h.JumpHeight=0; h.Health=h.MaxHealth
   active[p]=true; p:SetAttribute("InRound",true)
   -- Central crossroads are guaranteed clear in the procedural map.
   r.AssemblyLinearVelocity=Vector3.zero; r.CFrame=CFrame.new(rng:NextNumber(-7,7),85,rng:NextNumber(-65,65))
   local ff=p.Character:FindFirstChildOfClass("ForceField"); if ff then ff:Destroy() end
  end
 end
 remote:FireAllClients("Intro",selected); waitPhase("Prepare",Config.Prepare)
 for h,values in pairs(prepared) do if h.Parent then for key,value in pairs(values) do h[key]=value end end end
 local cleanup; local health
 local ok,err=xpcall(function()
  cleanup,health=Disasters.start(selected.id,world.Arena,remote,active)
  waitPhase("Survive",Config.Round,health)
  local failure=health and health(); if failure then error(failure) end
 end,debug.traceback)
 if cleanup then cleanup() end
 if not ok then warn("VTR round recovered: "..tostring(err)) end
 local winners={}; local winnerIds={}
 if ok then for p in pairs(active) do table.insert(winners,p.DisplayName); table.insert(winnerIds,p.UserId); p.leaderstats.Wins.Value+=1 end end
 active={}
 for _,p in ipairs(Players:GetPlayers()) do lobby(p) end
 if ok then remote:FireAllClients("Victory",winners,winnerIds) else remote:FireAllClients("RoundError") end
 waitPhase("Results",Config.Results)
 state.disaster=""; waitPhase("Rebuilding",3)
 World.rebuild(world)
end
