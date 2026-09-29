class_name MaxLevelBalanceAudit
extends RefCounted

const MAX_LEVEL: int = 40
const MAX_RANK: int = 5
const ASSUMED_WEAPON_POWER: float = 130.0
const ASSUMED_PRIMARY_ATTRIBUTE: float = 30.0

const DAMAGE_MODEL: Dictionary = {
	0:  {"hits":1.0, "mult":1.0, "add":13.0, "role":"aoe"},
	2:  {"hits":1.0, "mult":1.0, "add":12.0, "role":"mobility"},
	3:  {"hits":1.0, "mult":1.0, "add":15.0, "role":"pierce"},
	5:  {"hits":1.0, "mult":1.0, "add":40.0, "role":"burst"},
	7:  {"hits":3.0, "mult":1.0, "add":10.0, "role":"burst"},
	12: {"hits":1.0, "mult":1.0, "add":14.0, "role":"control"},
	13: {"hits":3.0, "mult":1.0, "add":9.0, "role":"chain"},
	15: {"hits":1.0, "mult":1.0, "add":32.0, "role":"ultimate"},
	16: {"hits":1.0, "mult":0.68, "add":7.0, "role":"projectile"},
	17: {"hits":1.0, "mult":0.72, "add":5.0, "role":"aoe_control"},
	18: {"hits":1.0, "mult":1.0, "add":22.0, "role":"pierce"},
	20: {"hits":3.0, "mult":0.72, "add":7.0, "role":"burst"},
	22: {"hits":4.0, "mult":1.0, "add":22.0, "role":"aoe_burst"},
	23: {"hits":3.0, "mult":0.47, "add":0.0, "role":"aoe"},
	24: {"hits":3.0, "mult":1.0, "add":20.0, "role":"ultimate"},
	25: {"hits":1.0, "mult":1.0, "add":22.0, "role":"mark"},
	26: {"hits":3.0, "mult":0.72, "add":7.0, "role":"burst"},
	28: {"hits":1.0, "mult":1.0, "add":7.0, "role":"dot"},
	29: {"hits":1.0, "mult":1.0, "add":7.0, "role":"control"},
	30: {"hits":1.0, "mult":1.0, "add":7.0, "role":"chain"},
	31: {"hits":4.0, "mult":1.0, "add":7.0, "role":"aoe_burst"},
	33: {"hits":6.0, "mult":1.0, "add":28.0, "role":"ultimate"}
}

const CLASS_LABELS: Array = ["Krieger", "Magier", "Bogenschütze"]

static func base_power() -> float:
	return (17.0 + float(MAX_LEVEL) * 2.4 + ASSUMED_WEAPON_POWER * 1.15 + float(MAX_RANK - 1) * 8.0) * (1.0 + ASSUMED_PRIMARY_ATTRIBUTE * 0.012)

static func ability_row(id: int, ability: Dictionary) -> Dictionary:
	if not DAMAGE_MODEL.has(id):
		return {
			"id": id,
			"name": str(ability.get("name", "Skill")),
			"utility_only": true,
			"burst": 0.0,
			"sustain": 0.0,
			"efficiency": 0.0
		}

	var model: Dictionary = DAMAGE_MODEL[id]
	var burst: float = float(model["hits"]) * (base_power() * float(model["mult"]) + float(model["add"]))
	var cooldown: float = maxf(0.1, float(ability.get("cd", 1.0)) * (1.0 - 0.06 * float(MAX_RANK - 1)))
	var cost: float = maxf(1.0, float(ability.get("cost", 1.0)))

	return {
		"id": id,
		"name": str(ability.get("name", "Skill")),
		"role": str(model["role"]),
		"utility_only": false,
		"burst": burst,
		"sustain": burst / cooldown,
		"efficiency": burst / cost
	}

static func audit(abilities: Array, class_skills: Array, class_ultimates: Array) -> Dictionary:
	var report: Dictionary = {
		"level": MAX_LEVEL,
		"rank": MAX_RANK,
		"base_power": base_power(),
		"classes": [],
		"warnings": []
	}
	var class_scores: Array = []

	for class_index in range(class_skills.size()):
		var ids: Array = class_skills[class_index].duplicate()
		if class_index < class_ultimates.size():
			ids.append(int(class_ultimates[class_index]))

		var rows: Array = []
		var sustain_sum: float = 0.0
		var damage_count: int = 0
		var best_burst: float = 0.0
		var best_name: String = ""

		for raw_id in ids:
			var ability_id: int = int(raw_id)
			if ability_id < 0 or ability_id >= abilities.size():
				continue

			var row: Dictionary = ability_row(ability_id, abilities[ability_id])
			rows.append(row)

			if not bool(row["utility_only"]):
				sustain_sum += float(row["sustain"])
				damage_count += 1
				if float(row["burst"]) > best_burst:
					best_burst = float(row["burst"])
					best_name = str(row["name"])

		var avg_sustain: float = sustain_sum / maxf(1.0, float(damage_count))
		class_scores.append(avg_sustain)

		var class_name: String = "Klasse %d" % class_index
		if class_index < CLASS_LABELS.size():
			class_name = str(CLASS_LABELS[class_index])

		report["classes"].append({
			"id": class_index,
			"name": class_name,
			"average_sustain": avg_sustain,
			"best_burst": best_burst,
			"best_burst_skill": best_name,
			"abilities": rows
		})

	if class_scores.size() >= 2:
		var lowest: float = INF
		var highest: float = -INF

		for raw_score in class_scores:
			var score: float = float(raw_score)
			lowest = minf(lowest, score)
			highest = maxf(highest, score)

		if lowest > 0.0 and highest / lowest > 1.18:
			var deviation: float = (highest / lowest - 1.0) * 100.0
			report["warnings"].append("Klassen-Durchsatz weicht um mehr als 18%% ab (%.1f%%)." % deviation)

	report["combos"] = [
		{"class":"Krieger", "name":"Kampfschrei + Klingenregen + Erdspalter", "risk":"hoher Nahkampf-Burst, aber positionsabhängig"},
		{"class":"Magier", "name":"Eisschild + Meteorschauer + Sternenfunken", "risk":"sehr starke sichere Flächenkontrolle"},
		{"class":"Bogenschütze", "name":"Falkenruf + Pfeilhagel + Mehrfachschuss", "risk":"starker Fernkampf-Burst durch Markierung + 22%% Schaden"}
	]

	return report

static func print_report(abilities: Array, class_skills: Array, class_ultimates: Array) -> void:
	var report: Dictionary = audit(abilities, class_skills, class_ultimates)
	print("[BALANCE] Max-Level Audit: Level %d / Rang %d" % [int(report["level"]), int(report["rank"])])

	for raw_entry in report["classes"]:
		var entry: Dictionary = raw_entry
		print("[BALANCE] %s: Ø Durchsatz %.1f | stärkster Burst %s %.1f" % [
			str(entry["name"]),
			float(entry["average_sustain"]),
			str(entry["best_burst_skill"]),
			float(entry["best_burst"])
		])

	for raw_warning in report["warnings"]:
		push_warning("[BALANCE] %s" % str(raw_warning))
