# Rupture Valley — art and audio handoff

## Identity and what is actually built

A mountain town, forest reserve, stepped quarry and industrial works share a valley. An evacuation outpost overlooks each round's destruction. Warm brick and grass contrast with muted copper/blue roofs and rusted industrial props. Warning amber and restrained red communicate danger. The UI borrows emergency signage and broadcast composition, not another game's branding.

World.luau builds original modular geometry directly: open doorways, separate facade piers, lintels and glass, awnings, accessible roof terraces, stairs, industrial props, rock terraces, trees, mountain wedges and water sheets. These are procedural parts with built-in Roblox materials. They are not custom sculpted, textured production assets. No external model, icon, animation or audio dependency is needed for the game loop.

## Production asset list

| Asset | Specification | Integration contract |
| --- | --- | --- |
| Town facade kit | Bevelled brick/window/door/awning sections, shared aged masonry atlas | Replace sections in `building()`; keep interiors and doorways open. Each breakable section must remain a separate anchored BasePart with `Destructible=true` |
| Roof/stair kit | Railings, gutters, roof vents, believable weathering | Preserve existing climb heights and collision. Keep structural floor proxies stable unless intentionally destructible |
| Forest kit | Original pine meshes, 3 variants, distance variants, subtle grass/flower clumps | Replace `tree()`; set `Wind=true` only on anchored canopy parts. Every separately animated/destructible piece must be a BasePart |
| Cliff/rock kit | 3–5 low-poly rock silhouettes, layered cliff strata, low-detail distant ridges | Replace `rock()`/mountain wedges. Use simple collision on walkable terraces; distant scenery is noncollidable |
| Industrial kit | Tanks, ribbed crates, stacks, pipe bends, machinery panels | Preserve boulder routes and escape access. Tag detachable panels rather than releasing a single enormous assembly |
| Destruction atlas | Dust, smoke, small grit, crack decals and meteor scorch marks | Replace built-in smoke texture in Effects; maintain local burst caps and readable server warnings |
| Waterfall/river kit | Ribbon mesh, scrolling flow texture, shore foam | Replace flat waterfall sheets and river plane. Keep `Waterfall=true` for local mist, or adapt the effect adapter |
| UI hazard icons | Seven original vector-like symbols with consistent stroke, transparent exports at 64/128/256px | Current symbols are text glyphs, not professional illustrated icons. Replace Interface card icons with ImageLabels; verify glyph fallback until then |
| Survivor animation | Brief R6/R15 celebratory animation, no locomotion override | Upload under the experience owner; add playback for the local winning user IDs. Current celebration is animated UI confetti, not custom character animation |
| Ambient loop | Wind, distant river, restrained industrial hum | `Config.Audio.Ambient` |
| Intro/quake/impact | Short tension hit, low-end controlled quake rumble, distinct rock impact | `Config.Audio.Disaster`, `Earthquake`, `Impact` |
| Vote/victory | Short ballot acknowledgement and restrained triumph | `Config.Audio.Vote`, `Victory` |

## Audio setup

Audio fields are empty deliberately: no invented IDs, unlicensed uploads, or inaccessible Marketplace assets. Set each to a permitted `rbxassetid://NUMERIC_ID` in Config. Ensure the experience has permission to use the audio, then verify loading and mixing in Studio. Ambient loops at volume .17; stingers at .4; impacts are only requested within the local effect distance and have a .2-second per-key rate limit. These are starting mix levels, not a completed professional audio mix.

## Importing replacement meshes safely

1. Keep ownership/licence records. Use the experience owner/group for imported assets and animations.
2. Use MeshParts with simple collision proxies. Disable collisions, touch and query on purely cosmetic scenery.
3. Replace the relevant factory in World.luau so templates and rebuilds include the asset. Adding art only to the live workspace Arena will be erased by the next rebuild.
4. Do not place scripts in imported art. Avoid arbitrary free-model script dependencies.
5. Keep detachable chunks independent and anchored until Destruction releases them. Welded models require a deliberate assembly adapter; the current system assumes independent BaseParts.
6. Measure texture memory, overdraw, instance count and physical assemblies on real low-end mobile hardware before raising detail or budgets.
7. Retest lava refuge heights, visible impact rings, collapse holes, stairs, spawn clearance and boulder corridors after art changes.

The map, UI composition and effects still require a human visual pass in Studio. Do not label generated geometry as final mesh art or infer device performance from the server budget alone.
