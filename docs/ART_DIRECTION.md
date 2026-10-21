# Art handoff — Skybound Citadel

## Visual identity

A ruined sanctuary suspended over a misty river valley. Use aged limestone with broad bevels, dark blue recesses, oxidised copper roofs and restrained gold inlays. Celestial machinery breaks the serenity when players vote. Avoid copying characters, UI, sounds, textures or architecture from reference games.

This build uses Roblox primitives and built-in materials. It is intentionally identified as a procedural first pass, not final professional mesh art. It needs a Studio visual review before judging composition or fidelity.

## Required production assets

| Asset | Direction | Integration |
| --- | --- | --- |
| Modular wall kit | Bevelled arch bays, cracked limestone buttress, cornice, crenellation; shared UV/material atlas | Replace repeated Rampart/Recess/Buttress parts in World.build with owned MeshPart templates; preserve arena bounds |
| Pavilion kit | Open arcade, copper pitched roof, carved columns, shop counter | Replace solid Pavilion forms; keep ExchangeInteraction accessible |
| Cliff and mountain kit | 3 silhouette variants, layered rock strata, distant low-detail versions | Replace Distant mountain spheres and Floating bedrock; disable distant collisions |
| Cypress/grass/flowers | 3 tree variants, foliage cards with restrained transparency, low-detail distance versions | Replace Cypress canopy/trunk and Wildflower parts, keeping player paths clear |
| Waterfall/river | UV-scrolling waterfall ribbon, foam edge and splash atlas | Replace flat Waterfall sheets; maintain low emission rates and noncollision |
| Arena floor kit | Bevelled limestone tiles with gold seams and authored cracks | Preserve ArenaTiles children as BaseParts or adapt collapse transforms for Models |
| Lava | Seamless emissive flow texture, smoke and embers, readable hazard boundary | Replace Rising lava material presentation without changing damage height |
| Meteor/core | Low-poly fractured meteor, molten seam atlas; etched metal celestial ball | Preserve physics proxies and server impact timing |
| UI icon atlas | Original hourglass, ballot, crown, six disaster symbols, aura glyphs | Add ImageLabels to vote cards and HUD; provide 1×/2× exports and readable monochrome variants |
| Victory animation | Short raised-arm or celebratory animation, R6/R15 variants | Upload under experience owner, preload and play only for survivors; leave locomotion tracks intact |
| Ambient loop | Wind, soft water, distant stone creaks; seamless restrained mix | Config.Audio.Ambient |
| Audio stingers | Disaster intro, restrained victory flourish, meteor impact | Config.Audio.Disaster / Victory / Impact |

Use assets you own or have permission to use. Check creator ownership, moderation status and experience audio access. No unverified Marketplace IDs are embedded. For audio, set a field to `rbxassetid://YOUR_NUMERIC_ID`; blank strings intentionally play nothing. Imported assets should have explicit names, source/licence records and tested collision proxies.

## Next stages

1. **First playable (this source):** procedural environment, server round loop, six hazards, HUD, cosmetic unlock interface; complete Studio acceptance checks.
2. **Art production:** replace geometric stand-ins with the above mesh kit, terrain/cliff work, approved sound and icon assets. Preserve telegraphs and collision contracts.
3. **Presentation:** authored disaster sequences, lava/meteor texture animation, lobby transition camera paths, victory character animation and expanded accessibility settings.
4. **Release:** multiplayer soak tests, measured device budgets, final lighting/contrast pass, persistent progression only after save/recovery design and separate data-store testing.

Do not increase particle counts or physics objects simply to make screenshots look fuller. Evaluate in motion on the slowest supported device. Keep impact warnings above decorative effects, and preserve a clear silhouette against both day and night skies.
