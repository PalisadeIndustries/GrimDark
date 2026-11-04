class_name Rules
extends RefCounted
## Pure game rules from the GDD. No scene or engine state, so they are easy to test.


## Damage multiplier for a weapon's penetration against an armour value (GDD 6.6).
static func pen_multiplier(pen: int, armour: int, gap_multipliers: Array = [1.0, 0.6, 0.3, 0.0]) -> float:
	var gap := armour - pen
	if gap <= 0:
		return float(gap_multipliers[0])
	if gap >= gap_multipliers.size():
		return float(gap_multipliers[-1])
	return float(gap_multipliers[gap])


## Index of the highest tier whose threshold the Favour total reaches (GDD 8.3).
static func tier_index_for_favour(favour: float, tiers: Array) -> int:
	var index := 0
	for i in tiers.size():
		if favour >= float(tiers[i]["favour"]):
			index = i
	return index


## Favour left after a death: lose a fraction of the Favour above the current tier's threshold (GDD 8.4).
static func favour_after_death(favour: float, tiers: Array, fraction: float = 0.25) -> float:
	var threshold := float(tiers[tier_index_for_favour(favour, tiers)]["favour"])
	var above := favour - threshold
	return favour - above * fraction


## Whether a player can buy an Ogryn life, and the Favour left afterwards (GDD 8.8).
static func can_buy_ogryn(favour: float, required_favour: float, cost: float) -> bool:
	return favour >= required_favour and favour >= cost


## Total platoon slots from the order of battle (GDD 4.1).
static func count_slots(sections: Array) -> int:
	var total := 0
	for section in sections:
		total += (section["slots"] as Array).size()
	return total
