# Studio acceptance checklist — not yet executed

Do these in a new test place. Record actual results and device settings; do not treat this list as passed tests.

## Required first-playable checks

1. Start a server with two clients. Confirm each spawns in the garden and the world generates once, without red Output errors. Walk around the fountain, pavilions and paths. Confirm player collision and spawn height.
2. Wait through the 15-second intermission and 12-second vote. Vote differently on each client, change a vote, and repeatedly click the same choice. Counts must stay correct and one disaster must win. Disconnect a voter; currently their existing vote remains in that round's tally by design.
3. Both living players teleport into the arena. A late joiner stays in the lobby until the next round. Character death or respawn removes round eligibility. Confirm arena bounds eliminate escape attempts.
4. Exercise all six disasters. For targeted QA, temporarily set Config.Disasters to a single desired entry in an unsaved test copy; restore the full list afterward. Choices may be fewer than three during this test; only existing entries are accepted by the server.
5. Lava: a player on the floor takes damage; raised refuges remain safe. Meteors: markers precede impacts and hit damage matches their radius. Collapse: amber warning precedes a fall; all tiles return on the next round. Balls: server-owned cores hit players and expire. Gravity: jump arc changes and resets. Speed: movement changes and resets.
6. Complete at least three consecutive rounds. No old lava, cores, warning markers, altered gravity, falling tiles or trails should leak into the next round. Check server memory and instance counts settle.
7. Survivors gain exactly one session win. Deaths gain none. Confirm a session reset clears wins. Walk to The Exchange, open the prompt, try locked auras, and equip an unlocked aura; verify the server rejects locked choices. No purchase should be implied.
8. Enable mobile emulation at 360×640, landscape phone and tablet sizes. Verify card descriptions, voting controls, announcements, close controls, safe areas and the motion toggle. Check gamepad virtual cursor or selection behaviour separately; dedicated controller navigation has not been built.
9. Toggle reduced motion before a disaster. Verify no impact shake/new bursts/trails; toggle mid-round and check comfort. An existing trail finishes until the phase changes. Shared telegraph markers remain active.
10. Test reset/death during Prepare, Survive and Results. Check CharacterAdded handling and camera behaviour with Roblox's default camera. Custom camera controllers may need an explicit integration pass.

## Performance and release gates

- Use MicroProfiler, Developer Console and real low-end mobile hardware. Target a stable 30 FPS minimum on the lowest supported device and 60 FPS on representative PCs; no performance numbers have been measured here.
- Test 1, 10 and intended maximum player counts. Streaming must retain nearby floor and warning cues; raise streaming radii if load-in delays affect safety.
- Inspect daylight, sunset and night readability at low and high graphics settings. Hazard clarity is more important than bloom intensity.
- Audit collidable decorative parts, particle overdraw, audio volume and core physics. The arena stays small enough for a focused match while distant scenery gives scale. It is not a measured production asset budget.
- Test camera shake with default, shift lock, first person, mobile and spectator cameras. Current shake is a bounded local translation; there are no cinematic scripted camera transitions yet.
- Publish only after Roblox API/runtime errors are resolved, asset permissions are validated and playtesting confirms every hazard is fair.

## Known scope limits

Procedural geometry is a first art pass. There are no custom meshes, PBR surfaces, authored animations, professionally produced audio, persistent economy, monetisation, matchmaking, data saves, accessibility options beyond reduced motion, or production analytics. Default Roblox character animation remains in place. Mountain forms and waterfalls require final mesh/material work. Low gravity and speed are movement modifiers with trails rather than full authored cinematic effects. This source is a starting game, not a verified upgrade to an unavailable existing place.
