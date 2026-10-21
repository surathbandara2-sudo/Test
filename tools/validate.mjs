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
 return true`, 'round-rules-tests',true);
 await run();
 const project=JSON.parse(fs.readFileSync(path.join(root,'default.project.json'),'utf8'));
 for(const node of [project.tree.ReplicatedStorage.VTR,project.tree.ServerScriptService.VTRServer,project.tree.StarterPlayer.StarterPlayerScripts.VTRClient]) {
  if(!fs.statSync(path.join(root,node.$path)).isDirectory()) throw Error('Missing mapped directory: '+node.$path);
 }
 console.log(`PASS: ${count} Luau files compile; vote validation and winner selection assertions; Rojo JSON and source paths.`);
 console.log('Roblox APIs, physics, UI, multiplayer, and performance require Roblox Studio testing.');
} finally {state.destroy();}
