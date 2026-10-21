# VOTE TO RUIN IT — The Skybound Citadel

A first playable Roblox implementation with an original weathered limestone, oxidised copper, ink blue and celestial gold identity. The world is built at server startup. No paid models, external runtime libraries, or secret credentials are required.

**Status:** Luau compilation and pure voting-rule checks pass. This project has **not been run in Roblox Studio**. The checkout originally contained no files or commits, so there was no original gameplay implementation to preserve or compare. This implements the requested vote → disaster → survive loop; exact compatibility with an existing place requires its source and rules.

## Open in Roblox Studio

Use a separate test place. Do not overwrite your production game.

### With Rojo 7

1. Install Rojo 7 from its official project and its Roblox Studio plugin.
2. From this directory, run `rojo serve default.project.json`.
3. Open a new place in Studio, connect the Rojo plugin to the server, and sync.
4. Remove the template baseplate and template SpawnLocation in that test place. The generated world contains its own spawn. Do not remove an existing production world without a backup.
5. In Workspace properties, enable StreamingEnabled before Play. Select the current high-quality Lighting style available in your Studio version. Check shadows on the target devices.
6. Press Play. The world appears when the server starts. Use Test → Start Server with at least two clients for voting checks.

Alternatively, `rojo build default.project.json -o VoteToRuinIt.rbxlx` creates a place file to open in Studio. Neither Rojo command was executed in the cloud workspace; Rojo/Studio are not installed here.

### Without Rojo

Create this hierarchy, copying each file into the corresponding Studio object:

```
ReplicatedStorage
  VTR (Folder)
    Config (ModuleScript)             src/shared/Config.luau
    RoundRules (ModuleScript)         src/shared/RoundRules.luau
ServerScriptService
  VTRServer (Folder)
    World (ModuleScript)              src/server/World.luau
    Main (Script)                     src/server/Main.server.luau
StarterPlayer
  StarterPlayerScripts
    Main (LocalScript)                src/client/Main.client.luau
```

The server creates RoundEvent, Vote, and Cosmetics RemoteEvents under VTR. Do not add duplicates. Main waits for shared modules; the client waits for server-created remotes. World generation is synchronous before rounds begin.

## Included

- Procedural floating citadel with tiled arena, four raised lava refuges, ramparts, buttresses, recessed wall panels, cornices and crenellations.
- Separate garden lobby, two pavilions, stepped fountain, cypress-like trees, flowers, boulders, distant mountain forms, waterfall sheets with mist, and a river below.
- Atmosphere, bloom, colour grading, clouds, shadows, and a slow local day/night cycle.
- Three random disaster choices per vote, one changeable vote per connected player, random tie breaking, server-enforced vote validation, round timers, survivor counting and session wins.
- Rising lava, telegraphed meteors, low gravity, warned collapsing tiles, server-owned rolling cores and super speed. Gravity, tile positions and movement speed reset after a round.
- Safe-area-aware HUD, responsive percentage layouts, animated vote buttons, countdown, disaster and survivor banners, distance-limited impact shake, dust bursts and movement trails.
- Motion reduction button suppressing camera shake, new trails and effect bursts. Server danger markers remain visible.
- Session leaderboard and an Exchange interaction with a cosmetic aura menu. Auras unlock at 3 and 10 session wins. No Robux, purchases, currency deductions or persistence.
- Optional audio integration points; silent until you supply permitted audio IDs.

## Local validation

Node 22+ is required for the validation tool only; Roblox does not use Node.

```sh
npm ci --ignore-scripts
npm test
```

Validation compiles every Luau file through luau-web, runs the actual RoundRules module against valid/invalid vote cases and tie cases, and checks project JSON/source paths. This does not emulate Roblox services or prove Roblox API compatibility.

See [Studio acceptance checks](docs/STUDIO_TESTS.md) and [art and audio handoff](docs/ART_DIRECTION.md) before release.
