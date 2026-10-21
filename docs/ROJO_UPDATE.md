# Updating your Roblox Studio place

## 1. Get the branch

If the repository is already on your computer, open its folder in a terminal:

```sh
git fetch origin
git switch feat/disaster-valley-overhaul
git pull --ff-only origin feat/disaster-valley-overhaul
```

If it is not cloned:

```sh
git clone https://github.com/surathbandara2-sudo/Test.git
cd Test
git switch feat/disaster-valley-overhaul
```

After the PR is merged, switch to `main` and pull that branch instead. Commit or stash any local work before switching; never discard unsaved changes just to update.

## 2. Install official Rojo 7

Use the CLI release from https://github.com/rojo-rbx/rojo/releases and the Studio plugin linked by https://rojo.space/docs/v7/getting-started/installation/ . Follow the instructions for your operating system and restart the terminal if PATH changed. Avoid similarly named unofficial package downloads.

From this project directory run:

```sh
rojo --version
rojo serve default.project.json
```

Leave that terminal open. The default address is `localhost:34872`. This is a local development connection, not a public game preview.

## 3. Back up and sync in Studio

1. Open the existing place in **Roblox Studio**.
2. Click **File → Save to File** to make a local backup. Use a separate test place for first validation.
3. Click **Stop** if a Play session is running. Do not sync the upgrade into an active old round.
4. In **Plugins**, open **Rojo**. Click **Connect** using the default local address above.
5. Inspect the pending changes, then click **Sync In** (wording may vary by plugin version).
6. In **View → Explorer**, verify the following objects:
   - ReplicatedStorage → VTR → Config, RoundRules.
   - ServerScriptService → VTRServer → Main, World, Destruction, Disasters.
   - StarterPlayer → StarterPlayerScripts → VTRClient → Main, Interface, Effects.
7. Ensure the old manually copied VTR scripts are not also running elsewhere. Keep one server Main and one client Main. Preserve unrelated game code and review integrations instead of deleting it blindly.
8. In Workspace properties, verify **StreamingEnabled** is enabled. In Lighting properties, choose the current realistic lighting style available in your Studio version and enable shadows. Device graphics settings still determine actual rendering quality.
9. Remove only the default template Baseplate/SpawnLocation if this is a fresh test place. Do not delete unrelated world content. Generated `RuptureValley` geometry appears only after Play begins.
10. Click **Play**. Use **View → Output** to inspect errors. Click **Stop** before further sync changes.

The update generates a fresh `RuptureValley` world on server startup; `Arena` is regenerated between rounds. The lobby stays intact. An old `Citadel` manually saved into edit mode is not removed automatically; back it up and remove it from the test place so both worlds do not overlap.

## 4. Test, then publish to Roblox

Follow STUDIO_TESTS.md with multiple clients and mobile emulation, then real devices. Only after these pass, use **File → Publish to Roblox** (or **Publish to Roblox As…** for a separate test experience). Check the target experience/place carefully before confirming. GitHub pushes and pull requests do not publish a Roblox experience.

## Without live sync

```sh
rojo build default.project.json -o VoteToRuinIt.rbxlx
```

Open the generated place in Studio, test it, then publish to the intended place. This cloud workspace did not execute the Rojo build and has not generated a tested place file.
