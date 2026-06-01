# Raise A Fridge

Roblox Rojo project for **Fridge RNG**.

## Workflow

- Code is synced by Rojo from `src/`.
- UI, map and models are Studio-owned so you can edit them in Roblox Studio and push the place/assets when you want.
- Run `studio/StudioBootstrap.command.lua` once in Roblox Studio Command Bar to create the required placeholder UI and map objects.

## Current MVP

Implemented foundation:

- Server-authoritative player state.
- Food registry and balancing config.
- Roll system with Common/Uncommon food and initial Clover-chain support.
- Food inventory.
- Feed Fridge action.
- Fridge XP/level system.
- Money/sec from Fridge level.
- Plot assignment and basic Fridge spawning.
- Client UI controller that binds to Studio-created UI.

## Next step

MVP 2: upgrades and skilltree nodes for Rare/Epic unlocks, Luck, Money and XP multipliers.
