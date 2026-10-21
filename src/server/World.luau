local Lighting = game:GetService("Lighting")
local World = {}
function World.build()
 local old=workspace:FindFirstChild("Citadel"); if old then old:Destroy() end
 local root=Instance.new("Folder"); root.Name="Citadel"; root.Parent=workspace
 local stone=Color3.fromRGB(91,108,120); local pale=Color3.fromRGB(192,194,177); local gold=Color3.fromRGB(216,174,91)
 local function part(name,size,cf,color,material,parent)
  local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color; p.Material=material or Enum.Material.Slate; p.Anchored=true; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent or root; return p
 end
 local function block(n,s,v,c,m) return part(n,s,CFrame.new(v),c,m) end
 local function glow(n,s,v) local p=block(n,s,v,gold,Enum.Material.Neon); p.CanCollide=false; return p end
 local tiles=Instance.new("Folder"); tiles.Name="ArenaTiles"; tiles.Parent=root
 block("Floating bedrock",Vector3.new(194,20,194),Vector3.new(0,66,0),stone)
 for x=-5,5 do for z=-5,5 do
  part("Tile",Vector3.new(15.7,3,15.7),CFrame.new(x*16,78.5,z*16),((x+z)%2==0) and pale or Color3.fromRGB(153,164,158),Enum.Material.Limestone,tiles)
 end end
 for _,v in ipairs({Vector3.new(-56,84,-56),Vector3.new(56,84,-56),Vector3.new(-56,84,56),Vector3.new(56,84,56)}) do
  block("Sanctuary",Vector3.new(23,8,23),v,stone)
  block("Gilded refuge",Vector3.new(24,1,24),v+Vector3.new(0,4.5,0),gold,Enum.Material.Metal)
 end
 -- Repeated buttresses, inset wall panels, cornices and lantern crowns.
 for side=0,3 do
  local rotation=CFrame.Angles(0,side*math.pi/2,0)
  for i=-3,3 do
   local frame=CFrame.new(0,80,0)*rotation*CFrame.new(i*29,0,-103)
   part("Rampart",Vector3.new(27,36,9),frame*CFrame.new(0,18,0),stone)
   part("Recess",Vector3.new(20,23,1),frame*CFrame.new(0,19,5),Color3.fromRGB(49,68,82))
   part("Buttress",Vector3.new(5,44,15),frame*CFrame.new(-14,20,0),pale)
   part("Cornice",Vector3.new(29,3,14),frame*CFrame.new(0,38,0),gold,Enum.Material.Metal)
   for j=-1,1 do part("Merlon",Vector3.new(5,6,10),frame*CFrame.new(j*10,42,0),pale) end
  end
 end
 -- Southern gate is a bridge over the wall, keeping the arena enclosed during rounds.
 block("Lobby island",Vector3.new(154,16,100),Vector3.new(0,70,171),stone)
 block("Garden lawn",Vector3.new(150,2,96),Vector3.new(0,79,171),Color3.fromRGB(71,113,91),Enum.Material.Grass)
 for z=120,212,8 do block("Processional stone",Vector3.new(22,1,7.6),Vector3.new(0,80.5,z),pale,Enum.Material.Cobblestone) end
 block("Arrival dais",Vector3.new(32,2,22),Vector3.new(0,81,162),pale)
 for _,x in ipairs({-52,52}) do
  block("Pavilion",Vector3.new(31,20,28),Vector3.new(x,90,190),pale)
  local roof=block("Copper roof",Vector3.new(37,5,34),Vector3.new(x,102,190),Color3.fromRGB(53,116,123),Enum.Material.Metal)
  for _,dx in ipairs({-12,12}) do block("Pavilion column",Vector3.new(3,22,3),Vector3.new(x+dx,91,174),gold) end
 end
 local function sign(text,position,width)
  local p=block("Inscription",Vector3.new(width,10,1),position,Color3.fromRGB(24,43,57)); local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Front; gui.PixelsPerStud=45; gui.Parent=p
  local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Text=text; t.TextColor3=gold; t.Font=Enum.Font.GothamBold; t.TextScaled=true; t.Parent=gui
 end
 sign("VOTE TO RUIN IT",Vector3.new(0,103,210),69)
 sign("THE EXCHANGE",Vector3.new(-52,97,174),29)
 sign("HALL OF SURVIVORS",Vector3.new(52,97,174),29)
 -- A stepped fountain anchors the arrival garden.
 for tier=0,2 do
  local basin=block("Fountain basin",Vector3.new(22-tier*6,2,22-tier*6),Vector3.new(31,82+tier*3,149),pale)
  block("Fountain water",Vector3.new(19-tier*6,.4,19-tier*6),basin.Position+Vector3.new(0,1.1,0),Color3.fromRGB(87,195,208),Enum.Material.Glass)
 end
 for i=1,12 do
  local angle=i*math.pi/6
  local p=block("Garden boulder",Vector3.new(4+i%3,3,5),Vector3.new(math.cos(angle)*68,81,170+math.sin(angle)*35),stone)
  p.CFrame*=CFrame.Angles(.15,angle,.12)
 end
 local board=block("Survivor ledger",Vector3.new(27,13,1),Vector3.new(52,87,173),Color3.fromRGB(24,43,57))
 local surface=Instance.new("SurfaceGui",board); surface.Face=Enum.NormalId.Front; surface.PixelsPerStud=35
 local ledger=Instance.new("TextLabel",surface); ledger.Size=UDim2.fromScale(1,1); ledger.BackgroundTransparency=1; ledger.Font=Enum.Font.GothamMedium; ledger.TextSize=36; ledger.TextColor3=gold; ledger.TextWrapped=true
 task.spawn(function()
  while board.Parent do
   local players=game:GetService("Players"):GetPlayers()
   table.sort(players,function(a,b) local av=a:FindFirstChild("leaderstats"); local bv=b:FindFirstChild("leaderstats"); return (av and av.Wins.Value or 0)>(bv and bv.Wins.Value or 0) end)
   local lines={"THIS SESSION"}
   for i=1,math.min(5,#players) do local stats=players[i]:FindFirstChild("leaderstats"); table.insert(lines,string.format("%d. %s   %d",i,players[i].DisplayName,stats and stats.Wins.Value or 0)) end
   ledger.Text=table.concat(lines,"\n"); task.wait(3)
  end
 end)
 local rng=Random.new(421)
 for i=1,48 do
  local x=rng:NextNumber(-73,73); local z=rng:NextNumber(130,212)
  if math.abs(x)>19 and (z<172 or math.abs(x)<30) then
   block("Cypress trunk",Vector3.new(2,11,2),Vector3.new(x,85,z),Color3.fromRGB(88,69,55),Enum.Material.Wood)
   for j=0,2 do local p=block("Cypress canopy",Vector3.new(11-j*2,10,11-j*2),Vector3.new(x,92+j*5,z),Color3.fromRGB(44+j*8,101+j*8,83)); p.Shape=Enum.PartType.Ball; p.Material=Enum.Material.Grass end
   for j=1,3 do local p=block("Wildflower",Vector3.new(.7,.8,.7),Vector3.new(x+j*1.1,81,z+3),gold,Enum.Material.Neon); p.CanCollide=false end
  end
 end
 for i=1,22 do
  local a=i*math.pi*2/22; local distance=rng:NextNumber(420,660); local height=rng:NextNumber(120,260)
  local p=block("Distant mountain",Vector3.new(180,height,180),Vector3.new(math.cos(a)*distance,height/2-55,math.sin(a)*distance),Color3.fromRGB(78,105,120)); p.Shape=Enum.PartType.Ball; p.CanCollide=false
 end
 for _,x in ipairs({-112,112}) do
  local water=block("Waterfall",Vector3.new(13,100,2),Vector3.new(x,27,10),Color3.fromRGB(98,204,222),Enum.Material.Glass); water.Transparency=.35; water.CanCollide=false
  local a=Instance.new("Attachment",water); a.Position=Vector3.new(0,48,0)
  local e=Instance.new("ParticleEmitter",a); e.Texture="rbxasset://textures/particles/smoke_main.dds"; e.Color=ColorSequence.new(Color3.fromRGB(175,234,240)); e.Rate=12; e.Lifetime=NumberRange.new(2); e.Speed=NumberRange.new(20); e.Acceleration=Vector3.new(0,-30,0); e.SpreadAngle=Vector2.new(15,15); e.Size=NumberSequence.new(3); e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.65),NumberSequenceKeypoint.new(1,1)})
 end
 block("River below",Vector3.new(650,2,100),Vector3.new(0,-24,0),Color3.fromRGB(55,145,166),Enum.Material.Glass).Transparency=.25
 Lighting.ClockTime=16.5; Lighting.Brightness=2.4; Lighting.Ambient=Color3.fromRGB(91,110,134); Lighting.OutdoorAmbient=Color3.fromRGB(124,142,157); Lighting.GlobalShadows=true
 for _,name in ipairs({"CitadelAtmosphere","CitadelBloom","CitadelGrade"}) do local o=Lighting:FindFirstChild(name); if o then o:Destroy() end end
 local atmosphere=Instance.new("Atmosphere",Lighting); atmosphere.Name="CitadelAtmosphere"; atmosphere.Density=.28; atmosphere.Haze=1.6; atmosphere.Color=Color3.fromRGB(190,216,230); atmosphere.Decay=Color3.fromRGB(117,141,169)
 local bloom=Instance.new("BloomEffect",Lighting); bloom.Name="CitadelBloom"; bloom.Intensity=.25; bloom.Size=24; bloom.Threshold=1.3
 local grade=Instance.new("ColorCorrectionEffect",Lighting); grade.Name="CitadelGrade"; grade.Contrast=.12; grade.Saturation=.09
 local sky=Lighting:FindFirstChildOfClass("Sky"); if not sky then sky=Instance.new("Sky",Lighting) end; sky.CelestialBodiesShown=true
 local clouds=workspace.Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds",workspace.Terrain); clouds.Cover=.55; clouds.Density=.45
 local spawn=Instance.new("SpawnLocation"); spawn.Name="CitadelSpawn"; spawn.Size=Vector3.new(10,1,10); spawn.Position=Vector3.new(0,83,162); spawn.Anchored=true; spawn.Neutral=true; spawn.Transparency=1; spawn.Parent=root
 return root
end
return World
