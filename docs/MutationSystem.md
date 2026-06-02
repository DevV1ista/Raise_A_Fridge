# Mutation System

## Goal

Mutations are temporary random boosts that create dopamine moments and stronger retention loops.

Every player periodically has a chance to receive a temporary Fridge mutation.

## Current Implementation

- Every 10 minutes the server rolls for a mutation.
- Mutation chance: 20%.
- Mutations last 5 minutes.
- Mutation logic is fully server-authoritative.
- Active mutations are stored in memory only for now.
- Clients should only display mutation state.

## Implemented Mutations

### Money Surge
- 2x money generation.

### XP Feast
- 2x Fridge XP gain.

### Golden Frost
- 1.5x money generation.
- 1.5x XP gain.
- Lower roll weight.

## Integration Notes

Other services should request multipliers through MutationService instead of hardcoding mutation logic.

Examples:
- MoneyService -> GetMoneyMultiplier(player)
- FridgeService -> GetXpMultiplier(player)

This keeps mutations modular and expandable.
