local RS=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local Config=require(RS.VTR.Config)
local Destruction=require(script.Parent.Destruction)
local Disasters={}
function Disasters.start(id,arena,remote,active)
 local running=true; local failure=nil; local connections={}; local tweens={}
 local destruction=Destruction.new(arena,remote); local rng=Random.new(); local gravity=workspace.Gravity
 local root=Instance.new("Folder"); root.Name="Hazards"; root.Parent=arena
 local function character(p) local c=p.Character; return c and c:FindFirstChildOfClass("Humanoid"),c and c:FindFirstChild("HumanoidRootPart") end
 local function part(name,size,pos,color,material)
  local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=pos; p.Color=color; p.Material=material or Enum.Material.Rock; p.Anchored=true; if name=="Fractured meteor" then p:SetAttribute("Meteor",true) end; p.Parent=root; p.TopSurface=Enum.SurfaceType.Smooth; return p
 end
 local function effect(kind,pos) if running then remote:FireAllClients("Effect",kind,pos) end end
 local function damage(pos,radius,amount)
  for p in pairs(active) do local h,r=character(p); if h and r and (r.Position-pos).Magnitude<radius then h:TakeDamage(amount) end end
 end
 local function marker(pos,radius,delay)
  local p=part("DANGER / impact",Vector3.new(.18,radius*2,radius*2),pos,Color3.fromRGB(226,94,63),Enum.Material.Neon)
  p.Shape=Enum.PartType.Cylinder; p.CFrame=CFrame.new(pos)*CFrame.Angles(0,0,math.pi/2); p.CanCollide=false; p.CanTouch=false; p.Transparency=.45
  Debris:AddItem(p,delay+1); effect("Warning",pos); return p
 end
 local function target()
  -- Bias toward live players, but never remove the warning window.
  local choices={}; for p in pairs(active) do local _,r=character(p); if r then table.insert(choices,r.Position) end end
  local pos=#choices>0 and choices[rng:NextInteger(1,#choices)] or Vector3.new(rng:NextNumber(-150,150),80,rng:NextNumber(-150,150))
  local x=math.clamp(pos.X+rng:NextNumber(-22,22),-165,165); local z=math.clamp(pos.Z+rng:NextNumber(-22,22),-165,165)
  local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
  local exclude={root}; for p in pairs(active) do if p.Character then table.insert(exclude,p.Character) end end
  params.FilterDescendantsInstances=exclude
  local hit=workspace:Raycast(Vector3.new(x,190,z),Vector3.new(0,-140,0),params)
  return hit and hit.Position+Vector3.new(0,.25,0) or Vector3.new(x,80.5,z)
 end
 local function loop(fn)
  task.spawn(function()
   local ok,err=xpcall(fn,debug.traceback)
   if not ok and running then failure=err; running=false; warn("VTR disaster task: "..tostring(err)) end
  end)
 end
 local originals={}
 local function cleanup()
  running=false
  for _,c in ipairs(connections) do c:Disconnect() end
  for _,t in ipairs(tweens) do t:Cancel() end
  workspace.Gravity=gravity
  for h,values in pairs(originals) do if h.Parent then h.WalkSpeed=values.WalkSpeed end end
  destruction:stop(); root:Destroy()
 end
 local function configure()
 for p in pairs(active) do local h=character(p); if h then originals[h]={WalkSpeed=h.WalkSpeed}; if id=="Speed" then h.WalkSpeed=36 end end end
 if id=="Lava" then
  local lava=part("Lava flood",Vector3.new(360,2,360),Vector3.new(0,72,0),Color3.fromRGB(210,88,43),Enum.Material.CrackedLava); lava.CanCollide=false
  -- Thin molten seams, rather than a completely neon world.
  local started=os.clock(); local erosion=0
  loop(function() while running do
   local elapsed=os.clock()-started; lava.Position=Vector3.new(0,72+math.min(elapsed/Config.Round,1)*15,0)
   for p in pairs(active) do local h,r=character(p); if h and r and r.Position.Y<lava.Position.Y+3 then h:TakeDamage(6) end end
   erosion+=1
   if erosion%4==0 then local pos=target(); destruction:impact(Vector3.new(pos.X,82,pos.Z),16,12,2) end
   task.wait(.25)
  end end)
 elseif id=="Meteors" then
  loop(function() while running do
   local pos=target(); local warning=marker(pos,14,2.2); task.wait(1.6); if not running then break end
   local meteor=part("Fractured meteor",Vector3.new(8,8,8),pos+Vector3.new(35,125,-15),Color3.fromRGB(96,66,52)); meteor.Shape=Enum.PartType.Ball; meteor.CanCollide=false; meteor:SetAttribute("Meteor",true)
   local tween=Tween:Create(meteor,TweenInfo.new(.65,Enum.EasingStyle.Linear),{Position=pos}); table.insert(tweens,tween); tween:Play()
   task.wait(.65); if not running then break end
   warning:Destroy(); meteor:Destroy(); damage(pos+Vector3.new(0,5,0),17,100); destruction:impact(pos,36,44); task.wait(.65)
  end end)
 elseif id=="Collapse" then
  local tiles=arena.ArenaTiles:GetChildren()
  loop(function() while running and #tiles>25 do
   local index=rng:NextInteger(1,#tiles); local tile=table.remove(tiles,index)
   -- Roads and structures above floor remain alternative routes; holes are still visible off-road.
   tile.Color=Color3.fromRGB(226,165,79); marker(tile.Position+Vector3.new(0,2.2,0),12,1.4); effect("Crack",tile.Position+Vector3.new(0,2.2,0))
   task.wait(1.4); if not running then break end
   local pos=tile.Position; destruction:impact(pos,27,22,4)
   tile.CanCollide=false; local tween=Tween:Create(tile,TweenInfo.new(.7,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=pos-Vector3.new(0,55,0),Orientation=tile.Orientation+Vector3.new(15,0,8)})
   table.insert(tweens,tween); tween:Play(); Debris:AddItem(tile,1); effect("Dust",pos); task.wait(.3)
  end end)
 elseif id=="Balls" then
  loop(function() while running do
   local z=rng:NextNumber(-150,150); local start=Vector3.new(-169,92,z)
   local warning=marker(Vector3.new(start.X,80.5,start.Z),12,1.2); task.wait(1.2); if not running then break end; warning:Destroy()
   local ball=part("Quarry boulder",Vector3.new(14,14,14),start,Color3.fromRGB(116,124,121)); ball.Shape=Enum.PartType.Ball; ball.Anchored=false; ball:SetNetworkOwner(nil); ball.AssemblyLinearVelocity=Vector3.new(70,0,rng:NextNumber(-12,12)); ball.AssemblyAngularVelocity=Vector3.new(0,0,-10)
   local hitTimes={}
   table.insert(connections,ball.Touched:Connect(function(hit)
    if not running or not ball.Parent then return end
    local char=hit:FindFirstAncestorOfClass("Model"); local p=char and game:GetService("Players"):GetPlayerFromCharacter(char)
    if p and active[p] and not hitTimes[p] then hitTimes[p]=true; local h=character(p); if h then h:TakeDamage(100) end end
    if hit:GetAttribute("Destructible") then
     local now=os.clock(); if not hitTimes.impact or now-hitTimes.impact>.4 then hitTimes.impact=now; destruction:impact(ball.Position,22,32,5) end
    end
   end)); Debris:AddItem(ball,6); task.wait(3)
  end end)
 elseif id=="Earthquake" then
  loop(function() while running do
   local pos=target(); marker(pos,25,1.8); effect("Crack",pos); task.wait(1.8); if not running then break end
   for step=1,12 do if not running then break end; destruction:shake(pos,70,step); if step%4==0 then effect("Quake",pos) end; task.wait(.08) end
   if not running then break end
   destruction:impact(pos,65,30,9); damage(pos+Vector3.new(0,4,0),23,40); task.wait(.8)
  end end)
 elseif id=="Gravity" then
  workspace.Gravity=65
  loop(function() while running do
   local pos=target(); effect("Gravity",pos)
   -- Actual moving fragments, bounded by the same rubble budget.
   for _,p in ipairs(destruction.targets) do
    if p.Parent and p.Anchored and (p.Position-pos).Magnitude<40 then destruction:detach(p,pos,8,34); break end
   end
   task.wait(1.4)
  end end)
 elseif id=="Speed" then
  loop(function() while running do
   local pos=target(); marker(pos,16,1.4); task.wait(1.4); if not running then break end
   destruction:impact(pos,23,24,3); damage(pos+Vector3.new(0,4,0),13,35); task.wait(1)
  end end)
 end
 end -- configure
 local ok,err=xpcall(configure,debug.traceback)
 if not ok then cleanup(); error(err) end
 return cleanup,function() return failure end
end
return Disasters
