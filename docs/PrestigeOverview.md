# Prestige Overview

Prestige is the long-term reset and scaling system for Raise A Fridge.

Requirement:
- Reach Fridge Level 25.

Current reset targets:
- Money
- Fridge Level
- Fridge XP

Persistent progression:
- Prestige Count
- Inventory
- Permanent rarity bonuses

Current permanent rewards:
- Increased Money multiplier
- Increased XP multiplier

Architecture note:
Prestige bonuses are routed through ProgressionMultiplierService so future systems can stack safely with mutations and event boosts.
