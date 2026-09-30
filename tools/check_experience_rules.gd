extends SceneTree

const ExperienceRules = preload("res://components/experience_rules.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert(is_equal_approx(ExperienceRules.multiplier(10, 10), 1.0))
	assert(is_equal_approx(ExperienceRules.multiplier(10, 12), 1.16))
	assert(is_equal_approx(ExperienceRules.multiplier(10, 20), 1.5))
	assert(is_equal_approx(ExperienceRules.multiplier(10, 9), 0.8))
	assert(ExperienceRules.reward(100.0, 10, 10) == 100)
	assert(ExperienceRules.reward(100.0, 10, 12) == 116)
	assert(ExperienceRules.reward(-10.0, 10, 10) == 0)
	print("EXPERIENCE_RULES_OK")
	quit()
