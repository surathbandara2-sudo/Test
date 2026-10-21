-- Server-owned bounded rubble. Snapshot rebuilds restore geometry; never anchor fallen parts in midair.
local Physics=game:GetService("PhysicsService")
local Debris=game:GetService("Debris")
local Config=require(game:GetService("ReplicatedStorage").VTR.Config)
local Rules=require(game:GetService("ReplicatedStorage").VTR.RoundRules)
local Destruction={}; Destruction.__index=Destruction
for _,name in ipairs({"VTRRubble","VTRCharacters"}) do pcall(function() Physics:RegisterCollisionGroup(name) end) end
Physics:CollisionGroupSetCollidable("VTRRubble","VTRCharacters",false)
Physics:CollisionGroupSetCollidable("VTRRubble","VTRRubble",false)
function Destruction.character(char)
 local function assign(p) if p:IsA("BasePart") then p.CollisionGroup="VTRCharacters" end end
 for _,p in ipairs(char:GetDescendants()) do assign(p) end
 return char.DescendantAdded:Connect(assign)
end
function Destruction.new(arena,remote)
 local self=setmetatable({arena=arena,remote=remote,targets={},loose={},alive=true,rng=Random.new(),moved={}},Destruction)
 for _,p in ipairs(arena:GetDescendants()) do if p:IsA("BasePart") and p:GetAttribute("Destructible") then table.insert(self.targets,p) end end
 return self
end
function Destruction:count()
 local count=0
 for p in pairs(self.loose) do if p.Parent then count+=1 else self.loose[p]=nil end end
 return count
end
function Destruction:detach(p,origin,strength,lift)
 if not self.alive or not p.Parent or not p.Anchored or not Rules.hasBudget(self:count(),Config.Destruction.MaxLooseParts) then return false end
 self.loose[p]=true; p:SetAttribute("Wind",false); p:SetAttribute("Destructible",false)
 p.Anchored=false; p.CanCollide=true; p.CanTouch=false; p.CollisionGroup="VTRRubble"; p:SetNetworkOwner(nil)
 local delta=p.Position-origin; local direction=delta.Magnitude>.1 and delta.Unit or Vector3.new(1,0,0)
 local velocity=direction*strength+Vector3.new(0,lift or 22,0)
 p:ApplyImpulse(velocity*p.AssemblyMass)
 p:ApplyAngularImpulse(Vector3.new(self.rng:NextNumber(-3,3),self.rng:NextNumber(-3,3),self.rng:NextNumber(-3,3))*p.AssemblyMass)
 Debris:AddItem(p,Config.Destruction.Lifetime)
 return true
end
function Destruction:impact(position,radius,strength,limit)
 if not self.alive then return end
 local nearby={}
 for _,p in ipairs(self.targets) do if p.Parent and p.Anchored and (p.Position-position).Magnitude<radius then table.insert(nearby,p) end end
 table.sort(nearby,function(a,b) return (a.Position-position).Magnitude<(b.Position-position).Magnitude end)
 local n=0
 for _,p in ipairs(nearby) do if n>=(limit or Config.Destruction.MaxPerImpact) then break end; if self:detach(p,position,strength) then n+=1 end end
 self.remote:FireAllClients("Effect","Impact",position)
end
function Destruction:shake(position,radius,step)
 if not self.alive then return end
 -- Bounded server displacement is visible to everyone. Client camera effects are separate.
 local n=0
 for _,p in ipairs(self.targets) do
  if p.Parent and p.Anchored and (p.Position-position).Magnitude<radius then
   local base=self.moved[p] or p.CFrame; self.moved[p]=base
   p.CFrame=base*CFrame.new(math.sin(step*2.1)*.28,0,math.cos(step*1.7)*.2)*CFrame.Angles(0,0,math.sin(step*2)*.009)
   n+=1; if n>=45 then break end
  end
 end
end
function Destruction:stop()
 self.alive=false
 for p,cf in pairs(self.moved) do if p.Parent and p.Anchored then p.CFrame=cf end end
 for p in pairs(self.loose) do p:Destroy() end
 table.clear(self.loose); table.clear(self.moved); table.clear(self.targets)
end
return Destruction
