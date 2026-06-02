# Raise A Fridge

## Core Gameplay Loop

Players roll random food items, equip them from a custom inventory and feed them into their Fridge.

Feeding food gives Fridge XP. Higher Fridge levels generate more passive money per second.

The game focuses on:
- dopamine RNG rolls
- idle income progression
- satisfying level scaling
- long-term permanent progression
- skilltree upgrades
- prestige systems
- mutations and events
- collection/index completion

## Important Architecture Rules

- Server-authoritative gameplay.
- Clients never decide important values.
- UI and map objects should remain editable inside Roblox Studio.
- Core code should stay inside Rojo-managed source folders.
- Registries and configs should hold balancing values.

## Current Core Systems

- Food rolling
- Clover luck chains
- Inventory system
- Equip + feed flow
- Fridge XP and leveling
- Passive money generation
- Skilltree progression
- Persistent data saving
- Plot/fridge ownership

## Planned / Expanding Systems

### Permanent Rarity Bonuses
Mythic and Secret foods permanently boost progression even after prestige.

### Prestige
Prestige resets Fridge level but boosts long-term XP and money scaling.

### Mutations
Fridges can temporarily mutate and gain special bonuses.

### Merchant Events
Special merchants and temporary boosts appear over time.

### Collection / Index
Players are rewarded for discovering and feeding rare foods.

### Monetization
The game should support cosmetic, convenience and RNG-related monetization later.
