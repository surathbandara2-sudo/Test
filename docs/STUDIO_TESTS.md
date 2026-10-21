# Studio release gates — not yet executed

## Automated evidence available

`npm ci --ignore-scripts && npm test` compiles nine production Luau files, executes actual pure voting/budget/bounds helpers, validates Rojo service classes/source mappings and exercises all seven disaster sessions through deterministic service doubles. The harness checks cancellation, cleanup, movement/gravity restoration, rubble-cap enforcement, expiry recovery and error propagation after injected physics failure.

The harness deliberately does not emulate rendering, collisions, raycast surfaces, streaming, animation, replication or device performance. These checks cannot replace the following Studio tests. No check below is claimed as passed.

## Required multiplayer and round checks

1. **Fresh start:** sync into a backed-up test place while stopped. Confirm only one Main server/client script exists. Start a server and two clients. Expect one RuptureValley root, an Arena with four districts, a separate outpost and no red Output errors. Check default spawns do not compete with OutpostSpawn.
2. **Map access:** enter town interiors, use every external staircase, reach roofs/terraces and walk road intersections. Confirm door gaps, stair heights, roofs, tank collision and quarry access work for R6/R15 avatars. No geometry should trap the central crossroads spawn.
3. **Voting:** each client votes, changes choices and repeats the same vote. Counts must not inflate; server acknowledgements drive feedback. Confirm malformed indices, spam and votes outside Voting do not count. Disconnect a voter during Voting; their vote must be subtracted. Test a tied vote and an all-zero vote.
4. **Prepare:** living players deploy to the clear crossroads. Walk/jump must be frozen for Prepare, including on mobile. The 2.6-second intro flyover must restore the normal camera before Survive. Reduced motion skips it. Test death/reset during the flyover and toggling reduced motion while it runs.
5. **Late join:** join during Voting and Survive. The ready handshake must populate the HUD. A late joiner during Survive stays at the outpost until the next deployment. Respawning must remove round eligibility.
6. **Survival:** server boundary and fall checks eliminate players who leave the arena. Verify lava/meteor/quake/ball damage is authoritative. Cosmetic rubble must collide with the environment but pass through characters and other rubble; boulders remain actual collidable hazards.
7. **Results:** each eligible living player receives one win. Dead players receive none. Only personal winners receive confetti. Long survivor lists must truncate cleanly. Everyone returns to the outpost before rebuilding.
8. **Rebuild:** complete at least three rounds. Every building, tree and tile must return to its original state. No old markers, debris, cracks, elevated lava, lowered gravity, trails or speed modifiers may carry into the next round. The outpost and leaderboard remain intact.
9. **Recovery:** deliberately cause a worker error in a throwaway test copy. The server must clean up the hazard, return players safely, award no wins, and resume after rebuilding. Restore the code afterward.
10. **Cosmetics:** browse the outpost Exchange, try locked auras, equip an unlocked one and respawn. The server enforces session-win requirements. Wins/auras intentionally reset with the server; there is no persistent economy or purchase flow.

## Exercise each disaster

For deterministic QA only, keep one entry in Config.Disasters in a disposable Studio copy. The server supports fewer than three configured choices. Restore all seven entries afterward.

| Disaster | Required observations |
| --- | --- |
| Lava | Flood rises from below ground; floor players take damage; roofs and cliff terraces remain useful. Destruction erosion is visible but bounded. Check lava reaches appropriate heights across the map |
| Meteors | Warning precedes descent; raycast warning lands on real roofs/ground. Confirm trees or glass do not hide crucial telegraphs. Impact radius matches gameplay and blasts release nearby sections |
| Gravity | Gravity changes, fragments lift/move, default jump remains controllable. Return to normal gravity on cleanup, including error recovery |
| Collapse | Amber floor, crack effect and warning precede the fall. Holes cause falls off-road; central roads and structures provide alternate routes. No falling tile tween survives reset |
| Balls | A visible edge warning precedes rolling boulders. They collide, roll, damage players and break nearby props without excessive tunnelling. Check collision callback behaviour against accessories and avatars |
| Speed | Speed changes/restores; road movement remains controllable. Warned local blasts produce damage/destruction without removing escape opportunity |
| Earthquake | Fault rings precede structural shaking and debris. Check roof/ground warning placement, damage range and that structural displacement is visible to all clients |

## Presentation and input

- Use phone portrait (360×640), phone landscape, tablet and desktop emulation. Verify safe areas, stacked cards, descriptions, countdown, motion/FX buttons and shop hit targets. Dedicated gamepad navigation has not been authored; test Roblox default selection separately.
- Test normal, first person, shift-lock and mobile cameras, death/reset and CurrentCamera replacement. Reduced motion must cancel the cinematic immediately and disable shake, wind sway, trails, airborne weather and confetti. It retains short dust puffs and essential warning markers.
- Toggle low/high FX before and during a round and while streaming new areas. Low FX reduces local presentation without changing damage, floor collision or server telegraphs.
- Inspect the late-afternoon lighting at graphics quality 1, 5 and 10. Tune shadows and contrast for readable danger. Current lighting is an authored static afternoon, not a day/night cycle.
- Supply approved audio IDs and verify real loading, volume and distance expectations. The shipped empty audio hooks are silent; no audio quality claim is made.

## Performance gates

- Use Developer Console and MicroProfiler with 1, 10 and the intended maximum player count. Inspect script time, physics assemblies, replicated bandwidth, memory, instance count and client overdraw across at least ten rounds.
- Verify loose rubble never exceeds 48 plus approximately two rockslide boulders. Per-impact detach cap is 9, rubble lifetime 5s, boulder lifetime 6s. Failed or interrupted rounds must also clean these up.
- On representative low-end mobile devices target at least a stable 30 FPS and no sustained memory growth; target 60 FPS on representative PCs. **No FPS or memory measurements have been made here.**
- Confirm streaming loads floor and warnings before players deploy. If needed, adjust streaming radii in the test place after measuring, rather than assuming a universal setting.
- After replacing procedural parts with final assets, rerun all collision, readability and budget checks. The generated map is an implementation/art foundation, not a verified production-quality release.
