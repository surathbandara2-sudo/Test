local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local Players=game:GetService("Players")
local folder=RS:WaitForChild("VTR")
local remote=folder:WaitForChild("RoundEvent"); local vote=folder:WaitForChild("Vote"); local shop=folder:WaitForChild("Cosmetics")
local effects=require(script.Parent:WaitForChild("Effects")).new()
local ui=require(script.Parent:WaitForChild("Interface")).new({
 vote=function(index) vote:FireServer(index) end,
 cosmetic=function(index) shop:FireServer(index) end,
 settings=function(mode,reduced) effects:settings(mode,reduced) end,
})
local lastPhase=""; local lastRound=0; local lastState
remote.OnClientEvent:Connect(function(kind,a,b)
 if kind=="State" then
  lastState=a; ui:update(a)
  if lastPhase~=a.phase or lastRound~=a.round then effects:phase(a.phase,a.disaster); lastPhase=a.phase; lastRound=a.round end
 elseif kind=="VoteAccepted" then ui:accepted(a); effects:sound("Vote"); if lastState then ui:update(lastState) end
 elseif kind=="Intro" then
  ui.shop.Visible=false; effects:sound("Disaster"); effects:intro()
  ui:announce("DISASTER SELECTED / GET READY",a.title,a.description,a.color,4.5)
 elseif kind=="Victory" then
  effects:sound("Victory"); ui:victory(b and table.find(b,Players.LocalPlayer.UserId)~=nil)
  local names={}; for i=1,math.min(5,#a) do names[i]=a[i] end
  local summary=table.concat(names," • ")..(#a>5 and " + "..(#a-5).." more" or "")
  ui:announce("SURVIVAL REPORT",#a>0 and "AGAINST ALL ODDS" or "TOTAL WIPEOUT",#a>0 and summary or "The valley won this round. You get the next vote.",Color3.fromRGB(232,190,110),5)
 elseif kind=="RoundError" then ui:announce("ROUND RECOVERY","RESETTING THE VALLEY","This round was interrupted. No wins were awarded.",nil,5)
 elseif kind=="Effect" then effects:event(a,b) end
end)
shop.OnClientEvent:Connect(function(kind,index) ui:cosmetic(kind,index) end)
Players.LocalPlayer:GetAttributeChangedSignal("InRound"):Connect(function()
 if not Players.LocalPlayer:GetAttribute("InRound") then effects:clearTrail(); effects:stopIntro()
 elseif lastState and lastState.phase=="Survive" then effects:movement(lastState.disaster) end
end)
Run.RenderStepped:Connect(function() ui:tick() end)
-- Ready handshake avoids losing the first state event while LocalScripts/modules load.
remote:FireServer("Ready")
