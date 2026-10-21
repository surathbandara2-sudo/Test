# VOTE TO RUIN IT — Rupture Valley

**Vote. Run. Survive. Rebuild.** A procedural disaster-survival game with an original emergency-broadcast identity: warm brick, pine green, muted industrial blue, limestone, and warning amber. Colour belongs to the world; luminous surfaces are reserved for danger telegraphs.

The valley replaces the earlier citadel. Voting, spawning, session wins, auras and the intermission → vote → prepare → disaster → results loop are retained. The original six disasters remain and Earthquake is a seventh vote option.

**Validation:** nine Luau source files compile. Automated assertions cover voting, bounds, physics budgets and disaster-session cleanup using deterministic service doubles. **This version has not been run in Roblox Studio.** Visual quality, actual physics, UI behaviour, streaming, audio permissions, multiplayer and device performance remain Studio release gates.

## What changed

- **Four districts:** an open-door town with windows, lintels, awnings, roof terraces and exterior stairs; pine reserve with vegetation and boulders; stepped quarry cliffs; industrial yard with tanks, crates and exhaust stacks.
- **Survival routes:** central road crossroads, accessible roofs, building interiors, quarry terraces, industrial cover and visible climb routes. The arena spans 360 × 360 studs and is framed by distant mountain ridges and a river/waterfalls.
- **Observation outpost:** separate safe spawn, active survivor board, shop, lookout railings and wind-animated trees.
- **Physical destruction:** independently breakable facade sections, roof pieces, trees, rocks and industrial props receive linear/angular impulses. Earthquakes visibly displace nearby structures. Every round replaces the arena with a clean server-held template.
- **Distinct hazards:** rising material-based lava with erosion; telegraphed meteor impacts and flying debris; low-gravity fragments; cracked, falling ground; physical rolling boulders; speed with telegraphed local blasts; warned earthquake zones.
- **Emergency-broadcast UI:** animated voting cards, server-confirmed voting feedback, smooth deadline-based timer, survival count, disaster introduction, survivor report, personal victory confetti, shop feedback, portrait/landscape layouts and safe-area support.
- **Presentation controls:** high/low local FX, reduced motion, distance-limited smooth camera shake, short skippable-by-motion-setting intro flyover, local smoke/water mist, wind sway, dust and shockwaves. A server freeze protects players during Prepare.

This is code-generated modular geometry, not a completed custom mesh art pack. Professional audio and bespoke textures/animations are not bundled. See [art handoff](docs/ART_DIRECTION.md) for exact missing assets and integration points.

## Update Roblox Studio with Rojo

See the exact workflow in [docs/ROJO_UPDATE.md](docs/ROJO_UPDATE.md). Use a backup/test place first.

```sh
git clone https://github.com/surathbandara2-sudo/Test.git
cd Test
git switch feat/disaster-valley-overhaul
rojo serve default.project.json
```

Connect the official Rojo 7 Studio plugin to `localhost:34872`, inspect the sync changes, then sync while Studio is **stopped**. Press Play to generate the map. After merging the pull request, use `git switch main` and `git pull --ff-only` instead of the feature branch.

Alternatively, `rojo build default.project.json -o VoteToRuinIt.rbxlx` creates a place file. Rojo and Studio are not installed in this cloud workspace, so these commands have not been verified here.

## Validation

Node 22+ is only a development dependency; Roblox uses the Luau files directly.

```sh
npm ci --ignore-scripts
npm test
```

The lifecycle harness checks all seven disasters, cancellation during pending work, restored gravity/movement speed, bounded rubble, expired-budget recovery, and an injected worker error. It uses minimal service doubles, not a Roblox emulator. It does not prove collision behaviour, raycast geometry, replication, rendering or mobile performance.

Run [Studio acceptance checks](docs/STUDIO_TESTS.md) before publishing. No performance measurements or Roblox Studio passes are claimed.

## Source layout

| Source | Responsibility |
| --- | --- |
| `src/shared/Config.luau` | Timings, arena dimensions, disaster catalogue, budgets, permitted audio hooks, cosmetics |
| `src/shared/RoundRules.luau` | Pure vote, budget and bounds rules |
| `src/server/World.luau` | Deterministic arena, reusable template, static scenery and lobby |
| `src/server/Destruction.luau` | Bounded server-owned rubble, collision groups, impulses and structural shake |
| `src/server/Disasters.luau` | Seven hazard sessions, telegraphs, damage and cleanup |
| `src/server/Main.server.luau` | Players, votes, round ownership, state, shop and rebuilding |
| `src/client/Interface.luau` | Responsive UI and transient animation |
| `src/client/Effects.luau` | Local camera, particles, wind, audio hooks and quality settings |
| `src/client/Main.client.luau` | Client event wiring and ready handshake |

## Performance and limitations

- At most **48 loose destructible parts**, with up to **9 detached per impact** and a **5-second lifetime**. The rockslide adds at most approximately two physical boulders, each expiring after six seconds.
- Rubble has server network ownership, collides with the map but not characters or other rubble. Gameplay damage is server-authoritative. Boulders remain separate collidable hazards.
- Local dust bursts cap at eight (high) or three (low); wind updates at 10 Hz for up to 16 nearby canopies. Cosmetic FX cannot alter vote outcomes, damage timing or shared collision.
- Low FX affects local particles/bloom/trails/wind. It does not change the server arena, shared rubble budget, hazard warnings or Roblox's own graphics quality setting.
- Session wins/auras are preserved; there is no persistence, monetisation, matchmaking or custom character animation. Audio hooks are intentionally silent until permitted IDs are provided.
