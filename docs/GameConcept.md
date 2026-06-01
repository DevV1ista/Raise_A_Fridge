# Raise A Fridge - Game Concept

## Core Fantasy

Raise A Fridge is a Roblox RNG/Idle game where players grow a fridge by rolling food, feeding it, leveling it up, and earning money per second. The game should feel simple, funny, dopamine-heavy, and easy to expand.

## Core Loop

1. Player rolls for Food.
2. Roll can trigger a Clover chain that increases luck for that roll.
3. Player receives Food based on unlocked rarities and luck.
4. Player equips Food from inventory.
5. Player feeds equipped Food to their Fridge.
6. Fridge gains XP and levels up.
7. Higher Fridge level creates more money per second.
8. Player spends money on upgrades.
9. Upgrades unlock rarities and improve luck, XP gain, money gain, or Clover chain potential.
10. Later, Prestige resets the Fridge level but keeps meaningful long-term bonuses.

## Current MVP Priorities

### MVP 1 - Playable Foundation

- Server-authoritative player state.
- Rojo project structure similar to the existing `Game` repository.
- Code synced through Rojo.
- UI, map, models, and visual Roblox objects stay Studio-owned and editable.
- Roll Food.
- Food inventory.
- Equip Food as a Tool.
- Feed Fridge through a ProximityPrompt.
- Fridge XP, levels, and money per second.
- Basic plot/fridge placeholder world.

### MVP 2 - Progression Upgrades

- Money-based upgrades.
- Rare unlock through upgrades.
- Luck upgrades.
- Money multiplier upgrades.
- XP gain upgrades.
- Clover cap/chain upgrades.
- Upgrade state must be server-authoritative.
- Client UI only requests purchases and displays public state.

### MVP 3 - Dopamine/Retention

- Better roll feedback.
- Food rarity effects.
- Index rewards.
- Daily/quest-style retention hooks.
- Stronger visual placeholders for Fridge growth.

### Later Systems

- Prestige/Rebirth.
- Mutations.
- Permanent Mythic/Secret food bonuses.
- Skill tree.
- Monetization hooks.
- Better data saving.
- More Food rarities and models.
- Polished Studio-owned UI and map.

## Architecture Rules

- Important game logic is server-authoritative.
- The client must never decide money, XP, food rewards, upgrade ownership, or unlocks.
- Balance values belong in Config/Registry modules, not hidden hardcoded multipliers.
- Services own game logic.
- Registries define content.
- Studio command scripts can create temporary placeholder UI/objects, but runtime code should work with editable Studio templates.
