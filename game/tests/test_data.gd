extends TestCase
## Checks the data tables load and match the GDD's fixed facts.

const GameDataScript := preload("res://scripts/core/game_data.gd")


func test_all_tables_load() -> void:
	for table_name in GameDataScript.TABLES:
		assert_true(not GameDataScript.load_table(table_name).is_empty(), table_name)


func test_platoon_has_45_slots() -> void:
	var sections: Array = GameDataScript.load_table("platoon")["sections"]
	assert_eq(Rules.count_slots(sections), 45)


func test_tiers_are_ascending() -> void:
	var tiers: Array = GameDataScript.load_table("progression")["tiers"]
	for i in range(1, tiers.size()):
		assert_true(float(tiers[i]["favour"]) > float(tiers[i - 1]["favour"]), tiers[i]["id"])


func test_only_heavy_stubber_braces_on_shoulder() -> void:
	var heavy: Dictionary = GameDataScript.load_table("weapons")["heavy"]
	for weapon in heavy:
		var on_shoulder: bool = "shoulder" in heavy[weapon]["braces"]
		assert_eq(on_shoulder, weapon == "heavy_stubber", weapon)


func test_tier_armour_classes_exist() -> void:
	var classes: Dictionary = GameDataScript.load_table("armour")["classes"]
	for tier in GameDataScript.load_table("progression")["tiers"]:
		assert_true(classes.has(tier["armour"]), tier["id"])
