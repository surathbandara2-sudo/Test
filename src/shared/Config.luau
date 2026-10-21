return {
 Title = "VOTE TO RUIN IT", MapName = "RUPTURE VALLEY",
 Intermission = 15, Voting = 12, Prepare = 5, Round = 38, Results = 6,
 ArenaCenter = Vector3.new(0,80,0), ArenaHalf = 180,
 LobbySpawn = Vector3.new(0,86,300), ShopPosition = Vector3.new(-42,84,314),
 Destruction = {MaxLooseParts=48, MaxPerImpact=9, Lifetime=5, Radius=26},
 Audio = {Ambient="", Disaster="", Victory="", Impact="", Vote="", Earthquake=""},
 Cosmetics = {
  {name="Unadorned",wins=0,color=Color3.fromRGB(231,189,112)},
  {name="Survivor Gold",wins=3,color=Color3.fromRGB(231,189,112)},
  {name="Aftershock Violet",wins=10,color=Color3.fromRGB(157,135,255)},
 },
 Disasters = {
  {id="Lava", icon="≋", title="MELTDOWN", description="The valley is flooding. Climb rooftops and rock terraces.", color=Color3.fromRGB(242,137,76)},
  {id="Meteors", icon="☄", title="SKYFALL", description="Impact rings mean danger. Clear the blast before it lands.", color=Color3.fromRGB(230,163,90)},
  {id="Gravity", icon="↑", title="ZERO HOUR", description="Low gravity lifts rubble. Control your landing.", color=Color3.fromRGB(159,155,226)},
  {id="Collapse", icon="⌁", title="FAULT LINE", description="Amber ground is failing. Get off marked tiles.", color=Color3.fromRGB(231,188,93)},
  {id="Balls", icon="●", title="ROCKSLIDE", description="Boulders sweep the valley. Stay out of their path.", color=Color3.fromRGB(133,181,175)},
  {id="Speed", icon="»", title="OVERCLOCK", description="Extreme speed. Use the roads; mind the edge.", color=Color3.fromRGB(142,200,132)},
  {id="Earthquake", icon="⌁", title="AFTERSHOCK", description="Watch the fault zones. Buildings and cliffs are coming apart.", color=Color3.fromRGB(220,163,122)},
 }
}
