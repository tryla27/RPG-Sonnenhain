extends RefCounted

# Autoritative, statische Definitionen der vier handgebauten Fusionen.
# Die universelle 528-Paar-Generierung bleibt in fusion_rules.gd.

const BUILTIN_FUSIONS := [
	{"id":40,"a":0,"b":16,"gold":1200,"max_rank":4},
	{"id":41,"a":1,"b":36,"gold":2200,"max_rank":4},
	{"id":42,"a":18,"b":37,"gold":4200,"max_rank":4},
	{"id":43,"a":17,"b":18,"gold":1800,"max_rank":4}
]

# Damage-Fusionen lösen ihren Sekundäreffekt am tatsächlichen Trefferpunkt aus.
# Reine Schutz-/Buff-Fusionen bleiben als ON_CAST-Ausnahme am Spieler.
const IMPACT_PROFILES := {
	40:{"trigger":"ON_DAMAGE_HIT","spawn":"DAMAGE_IMPACT_POSITION","carrier":16,"secondary":0,"effect":"fire_whirl","radius":112.0,"damage_mult":0.34},
	41:{"trigger":"ON_CAST","spawn":"PLAYER_POSITION","carrier":1,"secondary":36,"effect":"reactor_wall","radius":150.0,"damage_mult":0.22},
	42:{"trigger":"ON_DAMAGE_HIT","spawn":"DAMAGE_IMPACT_POSITION","carrier":18,"secondary":37,"effect":"tesla_wave","radius":145.0,"damage_mult":0.38},
	43:{"trigger":"ON_DAMAGE_HIT","spawn":"DAMAGE_IMPACT_POSITION","carrier":18,"secondary":17,"effect":"iceball","radius":118.0,"damage_mult":0.42}
}
