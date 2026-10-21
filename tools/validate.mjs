import {LuauState} from 'luau-web';
import fs from 'node:fs';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'..');
const state=await LuauState.createAsync();
try {
 let count=0;
 for(const dir of ['shared','server','client']) for(const name of fs.readdirSync(path.join(root,'src',dir))) {
  if(!name.endsWith('.luau')) continue;
  const file=path.join(root,'src',dir,name);
  state.loadstring(fs.readFileSync(file,'utf8'),file,true); count++;
 }
 const rules=fs.readFileSync(path.join(root,'src/shared/RoundRules.luau'),'utf8');
 const run=state.loadstring(`local Rules=(function() ${rules} end)()
 assert(Rules.validVote(1,3)); assert(Rules.validVote(3,3))
 for _,v in ipairs({0,4,-1,1.5,"1",false,math.huge,0/0}) do assert(not Rules.validVote(v,3)) end
 local winner=Rules.winnerIndices({0,3,1}); assert(#winner==1 and winner[1]==2)
 local tied=Rules.winnerIndices({2,0,2}); assert(#tied==2 and tied[1]==1 and tied[2]==3)
 assert(#Rules.winnerIndices({0,0,0})==3)
 assert(Rules.hasBudget(47,48)); assert(not Rules.hasBudget(48,48)); assert(not Rules.hasBudget(-1,48))
 assert(Rules.insideArena(180,65,-180,180)); assert(not Rules.insideArena(181,80,0,180))
 assert(not Rules.insideArena(0,64,0,180)); assert(not Rules.insideArena(0,80,-181,180))
 for i=-100,100 do assert(Rules.validVote(i,3)==(i>=1 and i<=3)) end
 return true`, 'round-rules-tests',true);
 await run();
 let harness=fs.readFileSync(path.join(root,'tools/tests/lifecycle.luau'),'utf8');
 for(const [marker,file] of Object.entries({CONFIG:'src/shared/Config.luau',RULES:'src/shared/RoundRules.luau',DESTRUCTION:'src/server/Destruction.luau',DISASTERS:'src/server/Disasters.luau'})) {
  harness=harness.replace('--[['+marker+']]',()=>fs.readFileSync(path.join(root,file),'utf8'));
 }
 await state.loadstring(harness,'disaster-lifecycle-harness',true)();
 const project=JSON.parse(fs.readFileSync(path.join(root,'default.project.json'),'utf8'));
 for(const name of ["ReplicatedStorage","ServerScriptService","StarterPlayer","Workspace","Lighting"]) {
  if(project.tree[name].$className!==name) throw Error("Wrong Rojo service class: "+name);
 }
 if(project.tree.StarterPlayer.StarterPlayerScripts.$className!=="StarterPlayerScripts") throw Error("Missing StarterPlayerScripts class");
 for(const node of [project.tree.ReplicatedStorage.VTR,project.tree.ServerScriptService.VTRServer,project.tree.StarterPlayer.StarterPlayerScripts.VTRClient]) {
  if(!fs.statSync(path.join(root,node.$path)).isDirectory()) throw Error('Missing mapped directory: '+node.$path);
 }
 console.log(`PASS: ${count} Luau files compile; vote/budget/bounds assertions; 7 disaster lifecycle and worker-failure scenarios using service doubles; Rojo JSON/source paths.`);
 console.log('Roblox APIs, physics, UI, multiplayer, and performance require Roblox Studio testing.');
} finally {state.destroy();}
