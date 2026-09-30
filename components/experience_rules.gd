extends RefCounted

# Underleveled targets lose 20% of the remaining reward for each level gap.
# Stronger targets add 8% per level, capped at +50%.
static func multiplier(player_level: int, mob_level: int) -> float:
	var gap := maxi(1, mob_level) - maxi(1, player_level)
	return pow(0.8, -gap) if gap < 0 else minf(1.5, 1.0 + gap * 0.08)

static func reward(base_xp: float, player_level: int, mob_level: int) -> int:
	return maxi(0, roundi(maxf(0.0, base_xp) * multiplier(player_level, mob_level)))
