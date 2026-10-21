-- Deterministic service doubles, NOT a Roblox emulator. Tests session ownership/cancellation only.
local clock=0; local queue={}; local created=0
local function schedule(co,at) table.insert(queue,{co=co,at=at}) end
local function resume(co)
 local ok,delay=coroutine.resume(co); assert(ok,delay)
 if coroutine.status(co)~="dead" then schedule(co,clock+(delay or .01)) end
end
local task={}
function task.spawn(fn,...) local args={...}; resume(coroutine.create(function() fn(unpack(args)) end)) end
function task.wait(seconds) return coroutine.yield(seconds or .01) end
function task.delay(seconds,fn) schedule(coroutine.create(fn),clock+seconds) end
local function advance(seconds)
 local untilTime=clock+seconds; local iterations=0
 while true do
  local at=math.huge; local index=nil
  for i,item in ipairs(queue) do if item.at<at then at=item.at; index=i end end
  if not index or at>untilTime then break end
  local item=table.remove(queue,index); clock=at; resume(item.co); iterations+=1; assert(iterations<10000,"Runaway task")
 end
 clock=untilTime
end
local vec={}; vec.__index=function(v,k)
 if k=="Magnitude" then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z) end
 if k=="Unit" then return v/v.Magnitude end
 return vec[k]
end
local Vector3={}
function Vector3.new(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},vec) end
Vector3.zero=Vector3.new()
vec.__add=function(a,b) return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
vec.__sub=function(a,b) return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
vec.__mul=function(a,b) return Vector3.new(a.X*b,a.Y*b,a.Z*b) end
vec.__div=function(a,b) return Vector3.new(a.X/b,a.Y/b,a.Z/b) end
local cf={}; cf.__index=cf
local CFrame={}
function CFrame.new(x,y,z) return setmetatable({Position=type(x)=="table" and x or Vector3.new(x,y,z)},cf) end
function CFrame.Angles() return CFrame.new() end
cf.__mul=function(a,b) return CFrame.new(a.Position+b.Position) end
local Color3={fromRGB=function(r,g,b) return {R=r,G=g,B=b} end}
local Enum=setmetatable({},{__index=function(_,group) return setmetatable({},{__index=function(_,key) return group.."."..key end}) end})
local methods={}; local node={}
node.__index=function(self,key)
 local value=self.props[key]; if value~=nil then return value end
 if methods[key] then return methods[key] end
 if key=="Position" then return self.props.CFrame.Position end
 for _,child in ipairs(self.children) do if child.Name==key then return child end end
end
node.__newindex=function(self,key,value)
 if key=="Parent" then
  local old=self.props.Parent
  if old then for i,p in ipairs(old.children) do if p==self then table.remove(old.children,i); break end end end
  self.props.Parent=value
  if value then table.insert(value.children,self) end
 elseif key=="Position" then self.props.CFrame=CFrame.new(value)
 else self.props[key]=value end
end
local Instance={}
function Instance.new(class,parent)
 created+=1
 local p=setmetatable({props={ClassName=class,Name=class,Anchored=true,AssemblyMass=1,CFrame=CFrame.new(),Orientation=Vector3.zero},children={},attributes={}},node)
 p.Touched={Connect=function() return {Disconnect=function() end} end}; if parent then p.Parent=parent end; return p
end
function methods:IsA(class) return self.ClassName==class or class=="BasePart" and self.ClassName=="Part" end
function methods:SetAttribute(k,v) self.attributes[k]=v end
function methods:GetAttribute(k) return self.attributes[k] end
function methods:GetDescendants() local list={}; for _,child in ipairs(self.children) do table.insert(list,child); for _,descendant in ipairs(child:GetDescendants()) do table.insert(list,descendant) end end; return list end
function methods:GetChildren() return table.clone(self.children) end
function methods:FindFirstChild(name) for _,p in ipairs(self.children) do if p.Name==name then return p end end end
function methods:FindFirstChildOfClass(class) for _,p in ipairs(self.children) do if p.ClassName==class then return p end end end
function methods:Destroy() for _,p in ipairs(self:GetChildren()) do p:Destroy() end; self.Parent=nil end
function methods:SetNetworkOwner() end
function methods:ApplyImpulse(value) self.lastImpulse=value end
function methods:ApplyAngularImpulse(value) self.lastSpin=value end
function methods:TakeDamage(n) self.Health-=n end
local workspace={Gravity=196.2,Raycast=function() return nil end}
local RaycastParams={new=function() return {} end}
local TweenInfo={new=function(duration) return {duration=duration} end}
local services={}
services.PhysicsService={RegisterCollisionGroup=function() end,CollisionGroupSetCollidable=function() end}
services.Debris={AddItem=function(_,p,lifetime) task.delay(lifetime,function() p:Destroy() end) end}
services.TweenService={Create=function(_,p,info,values)
 local tween={cancelled=false}
 function tween:Play() task.delay(info.duration,function() if not self.cancelled and p.Parent then for k,v in pairs(values) do p[k]=v end end end) end
 function tween:Cancel() self.cancelled=true end
 return tween
end}
services.ReplicatedStorage={VTR={Config="Config",RoundRules="Rules"}}
local game={GetService=function(_,name) assert(services[name],"Unexpected service "..name); return services[name] end}
local script={Parent={Destruction="Destruction"}}
local Config; local Rules; local Destruction
local function require(key)
 if key=="Config" then return Config elseif key=="Rules" then return Rules elseif key=="Destruction" then return Destruction end
 error("Unknown module")
end
local Random={new=function() return {
 NextNumber=function(_,a,b) return (a+b)/2 end,
 NextInteger=function(_,a) return a end,
} end}
local os={clock=function() return clock end}
local warn=function() end
Config=(function() --[[CONFIG]] end)()
Rules=(function() --[[RULES]] end)()
Destruction=(function() --[[DESTRUCTION]] end)()
local Disasters=(function() --[[DISASTERS]] end)()
local function fixture()
 local arena=Instance.new("Folder"); local tiles=Instance.new("Folder",arena); tiles.Name="ArenaTiles"
 for i=1,40 do local p=Instance.new("Part",tiles); p.Position=Vector3.new(i%6,78,math.floor(i/6)); p.Color=Color3.fromRGB(1,2,3) end
 for i=1,70 do local p=Instance.new("Part",arena); p.Position=Vector3.new(i%8,84,math.floor(i/8)); p:SetAttribute("Destructible",true) end
 local character=Instance.new("Model"); local h=Instance.new("Humanoid",character); h.Health=10000; h.WalkSpeed=16
 local root=Instance.new("Part",character); root.Name="HumanoidRootPart"; root.Position=Vector3.new(0,85,0)
 local player={Character=character}; local remote={events=0,FireAllClients=function(self) self.events+=1 end}
 return arena,{[player]=true},h,remote
end
for _,id in ipairs({"Lava","Meteors","Collapse","Balls","Earthquake","Gravity","Speed"}) do
 local arena,active,h,remote=fixture()
 local cleanup,health=Disasters.start(id,arena,remote,active)
 if id=="Gravity" then assert(workspace.Gravity==65) end
 if id=="Speed" then assert(h.WalkSpeed==36) end
 advance(4); assert(not health(),id.." worker failed")
 cleanup(); assert(workspace.Gravity==196.2,id.." leaked gravity"); assert(h.WalkSpeed==16,id.." leaked speed")
 assert(not arena:FindFirstChild("Hazards"),id.." leaked hazards")
 local before=created; local events=remote.events
 advance(7); assert(created==before,id.." created objects after cancellation"); assert(remote.events==events,id.." emitted events after cancellation")
 arena:Destroy()
end
-- The physics budget is enforced across repeated blasts, then recovered when debris expires.
local arena,_,_,remote=fixture(); local d=Destruction.new(arena,remote)
for i=1,90 do d:detach(d.targets[(i-1)%#d.targets+1],Vector3.new(),20) end
assert(d:count()==Config.Destruction.MaxLooseParts,"Physics cap not enforced")
advance(Config.Destruction.Lifetime+.1); assert(d:count()==0,"Expired debris still consumes budget")
d:stop(); arena:Destroy()
-- Fail a worker deliberately: the supervisor must expose the error to round management.
local arena,active,_,remote=fixture(); local cleanup,health=Disasters.start("Gravity",arena,remote,active)
for _,p in ipairs(arena:GetDescendants()) do if p:GetAttribute("Destructible") then p.ApplyImpulse=function() error("Injected physics error") end end end
advance(2); assert(health(),"Worker failure was hidden"); cleanup(); assert(workspace.Gravity==196.2)
return true
