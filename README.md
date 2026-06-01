# Raise A Fridge

Roblox Rojo project for **Fridge RNG**.

## Workflow

- Code is synced by Rojo from `src/`.
- UI, map and models are Studio-owned so you can edit them in Roblox Studio and push the place/assets when you want.
- Run `studio/StudioBootstrap.command.lua` once in Roblox Studio Command Bar to create the required placeholder UI and map objects.
- Concept reference is stored in `docs/GameConcept.md`.

## Current MVP

Implemented foundation:

- Server-authoritative player state.
- Food registry and balancing config.
- Roll system with Common/Uncommon food and Clover-chain support.
- Food inventory.
- Feed Fridge action.
- Fridge XP/level system.
- Money/sec from Fridge level.
- Plot assignment and basic Fridge spawning.
- Client UI controller that binds to Studio-created UI.
- Server-authoritative skill tree purchases.
- Skill tree branches for Core, Luck, Clover, Income and Feeding.
- Skill tree effects for Rare/Epic unlocks, Luck, Money, XP and Clover cap.
- DataStore persistence for Money, total earned, Fridge level/XP, Prestige, Inventory, Index and Skilltree.

## Data Saving

The server loads player data once on join and saves player data when the player leaves or when the server closes. Runtime changes only mark the profile dirty; they do not trigger frequent DataStore writes.

## Testing Data Saving

Roblox Studio DataStores only work when API Services are enabled for the place. In Studio, enable **Game Settings > Security > Enable Studio Access to API Services** before testing persistence.

## Next step

MVP 2 continuation: stronger roll feedback and dopamine animations, then better inventory/index UI.
