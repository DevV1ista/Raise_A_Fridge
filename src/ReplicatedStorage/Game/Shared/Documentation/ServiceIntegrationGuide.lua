--[[
	Raise A Fridge - Service Integration Guide

	This file documents how gameplay services should interact.
	It exists to keep the architecture modular and avoid hidden balancing hacks.

	Current Rule:
	All temporary or global progression multipliers should flow through
	ProgressionMultiplierService.

	Examples:

	Money reward:
		local multiplier = ProgressionMultiplierService:GetMoneyMultiplier(player)
		moneyReward *= multiplier

	XP reward:
		local multiplier = ProgressionMultiplierService:GetXpMultiplier(player)
		xpReward *= multiplier

	Why:
		- Keeps mutations centralized.
		- Makes Prestige easy later.
		- Makes monetization boosts easy later.
		- Avoids hidden multiplier hacks across services.
		- Prevents duplicated balancing logic.

	Future planned integrations:
		- Prestige bonuses
		- Mythic/Secret permanent boosts
		- Daily rewards
		- VIP boosts
		- Event multipliers
		- Limited-time consumables
]]

return true
