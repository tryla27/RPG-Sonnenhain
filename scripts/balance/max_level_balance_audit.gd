class_name MaxLevelBalanceAudit
extends RefCounted

const MAX_LEVEL := 40
const MAX_RANK := 5
const ASSUMED_WEAPON_POWER := 130.0
const ASSUMED_PRIMARY_ATTRIBUTE := 30.0

# Näherungswerte für Trefferanzahl/Multiplikatoren aus main.gd.
# Der Audit ist absichtlich konservativ: Utility, Heilung, CC und Flächentreffer
# werden separat markiert und nicht blind als Einzelziel-DPS gewertet.
const DAMAGE_MODEL := {
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

const CLASS_LABELS := ["Krieger", "Magier", "Bogenschütze"]

static func base_power() -> float:
	return (17.0 + MAX_LEVEL * 2.4 + ASSUMED_WEAPON_POWER * 1.15 + (MAX_RANK - 1) * 8.0) * (1.0 + ASSUMED_PRIMARY_ATTRIBUTE * 0.012)

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
	var burst := float(model["hits"]) * (base_power() * float(model["mult"]) + float(model["add"]))
	var cooldown := maxf(0.1, float(ability.get("cd", 1.0)) * (1.0 - 0.06 * float(MAX_RANK - 1)))
	var cost := maxf(1.0, float(ability.get("cost", 1.0)))
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
	var report := {
		"level": MAX_LEVEL,
		"rank": MAX_RANK,
		"base_power": base_power(),
		"classes": [],
		"warnings": PackedStringArray()
	}
	var class_scores: Array[float] = []
	for class_id in class_skills.size():
		var ids: Array = class_skills[class_id].duplicate()
		if class_id < class_ultimates.size():
			ids.append(int(class_ultimates[class_id]))
		var rows: Array = []
		var sustain_sum := 0.0
		var damage_count := 0
		var best_burst := 0.0
		var best_name := ""
		for raw_id in ids:
			var id := int(raw_id)
			if id < 0 or id >= abilities.size():
				continue
			var row := ability_row(id, abilities[id])
			rows.append(row)
			if not bool(row["utility_only"]):
				sustain_sum += float(row["sustain"])
				damage_count += 1
				if float(row["burst"]) > best_burst:
					best_burst = float(row["burst"])
					best_name = str(row["name"])
		var avg_sustain := sustain_sum / maxf(1.0, float(damage_count))
		class_scores.append(avg_sustain)
		report["classes"].append({
			"id": class_id,
			"name": CLASS_LABELS[class_id] if class_id < CLASS_LABELS.size() else "Klasse %d" % class_id,
			"average_sustain": avg_sustain,
			"best_burst": best_burst,
			"best_burst_skill": best_name,
			"abilities": rows
		})
	if class_scores.size() >= 2:
		var lowest := class_scores.min()
		var highest := class_scores.max()
		if lowest > 0.0 and highest / lowest > 1.18:
			report["warnings"].append("Klassen-Durchsatz weicht um mehr als 18%% ab (%.1f%%)." % ((highest / lowest - 1.0) * 100.0))
	# Bekannte Max-Level-Synergien, die bei Änderungen gezielt beobachtet werden sollen.
	report["combos"] = [
		{"class":"Krieger", "name":"Kampfschrei + Klingenregen + Erdspalter", "risk":"hoher Nahkampf-Burst, aber positionsabhängig"},
		{"class":"Magier", "name":"Eisschild + Meteorschauer + Sternenfunken", "risk":"sehr starke sichere Flächenkontrolle"},
		{"class":"Bogenschütze", "name":"Falkenruf + Pfeilhagel + Mehrfachschuss", "risk":"starker Fernkampf-Burst durch Markierung + 22%% Schaden"}
	]
	return report

static func print_report(abilities: Array, class_skills: Array, class_ultimates: Array) -> void:
	var report := audit(abilities, class_skills, class_ultimates)
	print("[BALANCE] Max-Level Audit: Level %d / Rang %d" % [report["level"], report["rank"]])
	for entry in report["classes"]:
		print("[BALANCE] %s: Ø Durchsatz %.1f | stärkster Burst %s %.1f" % [
			entry["name"], entry["average_sustain"], entry["best_burst_skill"], entry["best_burst"]
		])
	for warning in report["warnings"]:
		push_warning("[BALANCE] %s" % warning)
