-- Deterministic, replaceable round geometry. Static lobby/scenery never enter the debris budget.
local Lighting=game:GetService("Lighting")
local ServerStorage=game:GetService("ServerStorage")
local Config=require(game:GetService("ReplicatedStorage").VTR.Config)
local World={}
local C={stone=Color3.fromRGB(112,123,126), cream=Color3.fromRGB(218,207,180),
 asphalt=Color3.fromRGB(63,72,77), grass=Color3.fromRGB(105,137,85), roof=Color3.fromRGB(91,126,129),
 orange=Color3.fromRGB(202,116,70), wood=Color3.fromRGB(113,86,64), leaf=Color3.fromRGB(63,107,80), metal=Color3.fromRGB(112,135,145)}
local function folder(name,parent) local f=Instance.new("Folder"); f.Name=name; f.Parent=parent; return f end
local function part(parent,name,size,cf,color,material,breakable)
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=typeof(cf)=="Vector3" and CFrame.new(cf) or cf
 p.Color=color; p.Material=material or Enum.Material.Concrete; p.Anchored=true
 p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
 if breakable then p:SetAttribute("Destructible",true) end
 p.Parent=parent; return p
end
local function sign(parent,text,position,size)
 local p=part(parent,"Sign",size or Vector3.new(24,5,.5),position,Color3.fromRGB(30,43,48),Enum.Material.Metal)
 local s=Instance.new("SurfaceGui",p); s.Face=Enum.NormalId.Front; s.PixelsPerStud=35
 local t=Instance.new("TextLabel",s); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Font=Enum.Font.GothamBold; t.TextColor3=C.cream; t.TextScaled=true; t.Text=text
 local pad=Instance.new("UIPadding",t); pad.PaddingLeft=UDim.new(.04,0); pad.PaddingRight=UDim.new(.04,0)
 return t
end
local function stairs(parent,origin,height,width)
 local count=math.ceil(height/2)
 for i=1,count do part(parent,"Stair",Vector3.new(width,2,3),origin+Vector3.new(0,i*2-1,-i*3),C.stone) end
end
local function building(parent,origin,width,depth,floors,color,name)
 local model=Instance.new("Model"); model.Name=name; model.Parent=parent
 local h=floors*12
 part(model,"Foundation",Vector3.new(width+2,2,depth+2),origin+Vector3.new(0,1,0),C.stone)
 -- Doorway is physically open; window panels and facade sections detach independently.
 for level=0,floors-1 do
  local y=3+level*12
  part(model,"Floor",Vector3.new(width,1,depth),origin+Vector3.new(0,y-1,0),C.cream,Enum.Material.Concrete,level>0)
  for _,side in ipairs({-1,1}) do
   for z=-1,1 do part(model,"Side panel",Vector3.new(1.2,11,depth/3-.2),origin+Vector3.new(side*width/2,y+5,z*depth/3),color,Enum.Material.Brick,true) end
  end
  for _,z in ipairs({-depth/2,depth/2}) do
   for _,x in ipairs({-width*.34,width*.34}) do
    part(model,"Facade pier",Vector3.new(width*.3,11,1.2),origin+Vector3.new(x,y+5,z),color,Enum.Material.Brick,true)
    local pane=part(model,"Window",Vector3.new(width*.2,4,.3),origin+Vector3.new(x,y+6,z+(z<0 and -.7 or .7)),Color3.fromRGB(104,159,172),Enum.Material.Glass,true); pane.Transparency=.3; pane.CanCollide=false
    part(model,"Window lintel",Vector3.new(width*.24,.6,1.8),origin+Vector3.new(x,y+8.3,z),C.cream,nil,true)
   end
   part(model,"Door lintel",Vector3.new(width*.25,3,1.2),origin+Vector3.new(0,y+9,z),color,nil,true)
  end
 end
 part(model,"Roof terrace",Vector3.new(width+3,1.5,depth+3),origin+Vector3.new(0,h+3,0),C.roof,Enum.Material.Metal,true)
 for _,x in ipairs({-width/2,width/2}) do part(model,"Parapet",Vector3.new(1,2.5,depth+2),origin+Vector3.new(x,h+5,0),C.cream,nil,true) end
 part(model,"Awning",Vector3.new(width*.75,1,5),origin+Vector3.new(0,11,-depth/2-2),C.orange,Enum.Material.Fabric,true)
 stairs(model,origin+Vector3.new(width/2+5,0,depth/2+4),h+4,7)
 sign(model,name:upper(),origin+Vector3.new(0,8,-depth/2-2.7),Vector3.new(width*.7,3,.4))
 return model
end
local function tree(parent,pos,rng,breakable)
 local h=rng:NextNumber(13,21); local model=Instance.new("Model"); model.Name="WindTree"; model.Parent=parent
 local trunk=part(model,"Trunk",Vector3.new(2,h,2),pos+Vector3.new(0,h/2,0),C.wood,Enum.Material.Wood,breakable)
 for i=1,3 do
  local canopy=part(model,"Canopy",Vector3.new(12-i,10,12-i),pos+Vector3.new((i-2)*2,h+i*2,0),C.leaf:Lerp(C.grass,i*.12),Enum.Material.Grass,breakable)
  canopy.Shape=Enum.PartType.Ball; canopy.CanCollide=false; canopy:SetAttribute("Wind",true)
 end
 return trunk
end
local function rock(parent,pos,size,rng,breakable)
 local p=part(parent,"Boulder",size,CFrame.new(pos)*CFrame.Angles(rng:NextNumber(-.4,.4),rng:NextNumber(0,6),.2),C.stone,Enum.Material.Rock,breakable); p.Shape=Enum.PartType.Ball; return p
end
local function makeArena()
 local arena=folder("Arena",ServerStorage); local rng=Random.new(73)
 local tiles=folder("ArenaTiles",arena)
 for x=-7,7 do for z=-7,7 do
  local urban=x<0 and z<0; local industrial=x>0 and z>0
  part(tiles,"Ground",Vector3.new(23.8,4,23.8),Vector3.new(x*24,78,z*24),urban and C.stone or industrial and Color3.fromRGB(134,125,105) or C.grass,urban and Enum.Material.Cobblestone or industrial and Enum.Material.Ground or Enum.Material.Grass)
 end end
 for axis=1,2 do
  local road=part(arena,"Evacuation road",axis==1 and Vector3.new(360,.3,19) or Vector3.new(19,.3,360),Vector3.new(0,80.2,0),C.asphalt,Enum.Material.Asphalt)
  for i=-11,11 do part(arena,"Road marking",axis==1 and Vector3.new(7,.08,.35) or Vector3.new(.35,.08,7),Vector3.new(axis==1 and i*15 or 0,80.42,axis==2 and i*15 or 0),C.cream) end
 end
 for i,x in ipairs({-132,-77}) do for j,z in ipairs({-133,-70}) do
  building(arena,Vector3.new(x,80,z),30,28,(i+j)%2+1,i==1 and Color3.fromRGB(182,143,115) or Color3.fromRGB(148,164,155),({"VALLEY MARKET","POST OFFICE","RESCUE HQ","THE DINER"})[(i-1)*2+j])
 end end
 -- A central pavilion and visible climb routes give lava survivors real choices.
 building(arena,Vector3.new(-43,80,47),26,24,1,C.cream,"RANGER STATION")
 for _,x in ipairs({-172,-24}) do for z=-155,-30,35 do
  part(arena,"Sidewalk",Vector3.new(6,.6,29),Vector3.new(x,80.5,z),C.cream)
  local pole=part(arena,"Street lamp",Vector3.new(.7,15,.7),Vector3.new(x,88,z),C.metal,Enum.Material.Metal,true)
  part(arena,"Lamp hood",Vector3.new(4,.8,2),pole.Position+Vector3.new(1,7,0),C.asphalt,Enum.Material.Metal,true)
 end end
 for i=1,30 do
  local x=rng:NextNumber(32,163); local z=rng:NextNumber(-167,-34)
  tree(arena,Vector3.new(x,80,z),rng,true)
  if i%2==0 then rock(arena,Vector3.new(x+5,82,z+7),Vector3.new(5,4,6),rng,true) end
  for j=1,2 do local f=part(arena,"Wildflower",Vector3.new(.6,1,.6),Vector3.new(x+j*2,80.8,z+4),j==1 and C.orange or C.cream,Enum.Material.Grass); f.CanCollide=false end
 end
 -- Walkable, stepped cliff terraces with individual loose rock caps.
 for i=1,4 do
  local x=-147+(i%2)*39; local z=58+math.floor((i-1)/2)*66
  for tier=0,2 do
   part(arena,"Cliff terrace",Vector3.new(35-tier*7,4,43-tier*5),Vector3.new(x,82+tier*4,z),C.stone,Enum.Material.Rock)
  end
  rock(arena,Vector3.new(x,96,z),Vector3.new(11,9,13),rng,true)
  stairs(arena,Vector3.new(x+22,80,z+24),12,7)
 end
 local warehouse=building(arena,Vector3.new(100,80,104),47,35,1,Color3.fromRGB(155,164,161),"RUPTURE WORKS")
 for i=1,3 do
  local tank=part(arena,"Storage tank",Vector3.new(17,22,17),Vector3.new(43+i*34,91,155),C.metal,Enum.Material.Metal,true); tank.Shape=Enum.PartType.Cylinder; tank.CFrame*=CFrame.Angles(0,0,math.pi/2)
  part(arena,"Tank foot",Vector3.new(20,2,20),Vector3.new(43+i*34,81,155),C.stone)
 end
 for i=1,5 do
  part(arena,"Shipping crate",Vector3.new(11,8,9),Vector3.new(35+i*23,84,45),i%2==0 and C.roof or C.orange,Enum.Material.CorrodedMetal,true)
  part(arena,"Crate band",Vector3.new(11.2,.6,9.2),Vector3.new(35+i*23,86,45),C.asphalt,Enum.Material.Metal,true)
 end
 for _,pos in ipairs({Vector3.new(155,80,92),Vector3.new(155,80,115)}) do
  part(arena,"Exhaust stack",Vector3.new(6,37,6),pos+Vector3.new(0,18,0),C.orange,Enum.Material.Brick,true)
  local cap=part(arena,"Stack cap",Vector3.new(8,2,8),pos+Vector3.new(0,37,0),C.asphalt,Enum.Material.Metal,true); cap:SetAttribute("Smoke",true)
 end
 for i=1,8 do
  local pos=Vector3.new(i%2==0 and -15 or 15,82,-165+i*40)
  part(arena,"Road barrier",Vector3.new(3,4,9),pos,C.orange,nil,true)
 end
 sign(arena,"OLD TOWN",Vector3.new(-50,86,-17),Vector3.new(26,4,.4))
 sign(arena,"PINE RESERVE",Vector3.new(85,86,-17),Vector3.new(27,4,.4))
 sign(arena,"RUPTURE WORKS",Vector3.new(94,86,25),Vector3.new(30,4,.4))
 sign(arena,"QUARRY RIDGE",Vector3.new(-111,86,25),Vector3.new(29,4,.4))
 return arena
end
function World.rebuild(root)
 local old=root:FindFirstChild("Arena"); if old then old:Destroy() end
 local template=ServerStorage:FindFirstChild("VTRMapTemplate"); assert(template,"Missing map template")
 local arena=template:Clone(); arena.Name="Arena"; arena.Parent=root; return arena
end
function World.build()
 local old=workspace:FindFirstChild("RuptureValley"); if old then old:Destroy() end
 local root=folder("RuptureValley",workspace); local scenery=folder("Scenery",root); local rng=Random.new(94)
 local previous=ServerStorage:FindFirstChild("VTRMapTemplate"); if previous then previous:Destroy() end
 local template=makeArena(); template.Name="VTRMapTemplate"
 -- Distant silhouettes are entirely static and nonphysical.
 for i=1,32 do
  local angle=i*math.pi*2/32; local distance=rng:NextNumber(510,720); local height=rng:NextNumber(140,290)
  local cf=CFrame.new(math.cos(angle)*distance,70+height/2,math.sin(angle)*distance)*CFrame.Angles(0,angle,.13)
  local p=Instance.new("WedgePart"); p.Name="Mountain ridge"; p.Size=Vector3.new(180,height,210); p.CFrame=cf; p.Color=Color3.fromRGB(101,126,128); p.Material=Enum.Material.Rock; p.Anchored=true; p.CanCollide=false; p.Parent=scenery
  if i%3==0 then rock(scenery,Vector3.new(math.cos(angle)*380,64,math.sin(angle)*380),Vector3.new(150,90,120),rng,false) end
 end
 part(scenery,"River",Vector3.new(95,1,740),Vector3.new(260,41,0),Color3.fromRGB(92,155,165),Enum.Material.Glass).Transparency=.22
 for _,z in ipairs({-200,180}) do
  local p=part(scenery,"Waterfall",Vector3.new(20,77,1),Vector3.new(260,80,z),Color3.fromRGB(170,209,208),Enum.Material.Glass); p.Transparency=.4; p.CanCollide=false; p:SetAttribute("Waterfall",true)
 end
 local lobby=folder("Lobby",root)
 part(lobby,"Observation island",Vector3.new(160,18,106),Vector3.new(0,70,307),C.stone,Enum.Material.Rock)
 part(lobby,"Arrival lawn",Vector3.new(155,2,101),Vector3.new(0,80,307),C.grass,Enum.Material.Grass)
 part(lobby,"Promenade",Vector3.new(132,1,17),Vector3.new(0,81.5,298),C.cream,Enum.Material.Cobblestone)
 part(lobby,"Arrival pad",Vector3.new(24,1,20),Vector3.new(0,82,300),C.metal,Enum.Material.Metal)
 for x=-72,72,18 do
  part(lobby,"Lookout rail post",Vector3.new(1,5,1),Vector3.new(x,84,259),C.metal,Enum.Material.Metal)
 end
 part(lobby,"Lookout railing",Vector3.new(145,1,1),Vector3.new(0,86,259),C.metal,Enum.Material.Metal)
 building(lobby,Vector3.new(-43,81,333),31,23,1,C.cream,"THE EXCHANGE")
 building(lobby,Vector3.new(44,81,333),31,23,1,C.cream,"SURVIVOR LOG")
 sign(lobby,"VOTE TO RUIN IT",Vector3.new(0,104,351),Vector3.new(66,11,1))
 sign(lobby,"RUPTURE VALLEY / EVACUATION OUTPOST",Vector3.new(0,94,351),Vector3.new(65,4,1))
 for i=1,12 do local x=i<=6 and -70 or 70; tree(lobby,Vector3.new(x,81,265+(i%6)*15),rng,false) end
 local ledger=sign(lobby,"SURVIVORS",Vector3.new(44,89,320),Vector3.new(25,10,.5))
 task.spawn(function()
  while ledger.Parent do
   local players=game:GetService("Players"):GetPlayers()
   table.sort(players,function(a,b) local av=a:FindFirstChild("leaderstats"); local bv=b:FindFirstChild("leaderstats"); return (av and av.Wins.Value or 0)>(bv and bv.Wins.Value or 0) end)
   local lines={"THIS SESSION"}; for i=1,math.min(5,#players) do local stats=players[i]:FindFirstChild("leaderstats"); table.insert(lines,string.format("%d  %s  /  %d",i,players[i].DisplayName,stats and stats.Wins.Value or 0)) end
   ledger.Text=table.concat(lines,"\n"); task.wait(3)
  end
 end)
 local spawn=Instance.new("SpawnLocation"); spawn.Name="OutpostSpawn"; spawn.Size=Vector3.new(12,1,12); spawn.Position=Config.LobbySpawn-Vector3.new(0,3,0); spawn.Anchored=true; spawn.Transparency=1; spawn.Neutral=true; spawn.Parent=lobby
 Lighting.ClockTime=15.3; Lighting.Brightness=2.5; Lighting.GlobalShadows=true
 Lighting.Ambient=Color3.fromRGB(92,106,119); Lighting.OutdoorAmbient=Color3.fromRGB(133,143,151)
 Lighting.ExposureCompensation=.05; Lighting.EnvironmentDiffuseScale=.65; Lighting.EnvironmentSpecularScale=.8; Lighting.ShadowSoftness=.3
 for _,name in ipairs({"ValleyAtmosphere","ValleyBloom","ValleyGrade"}) do local item=Lighting:FindFirstChild(name); if item then item:Destroy() end end
 local a=Instance.new("Atmosphere",Lighting); a.Name="ValleyAtmosphere"; a.Density=.29; a.Haze=1.7; a.Color=Color3.fromRGB(207,223,223); a.Decay=Color3.fromRGB(135,156,172)
 local b=Instance.new("BloomEffect",Lighting); b.Name="ValleyBloom"; b.Intensity=.13; b.Threshold=1.7; b.Size=22
 local g=Instance.new("ColorCorrectionEffect",Lighting); g.Name="ValleyGrade"; g.Contrast=.08; g.Saturation=.1; g.TintColor=Color3.fromRGB(255,246,234)
 if not Lighting:FindFirstChildOfClass("Sky") then Instance.new("Sky",Lighting) end
 local clouds=workspace.Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds",workspace.Terrain); clouds.Cover=.55; clouds.Density=.5
 World.rebuild(root); return root
end
return World
