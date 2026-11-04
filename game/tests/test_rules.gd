extends TestCase
## Rules from GDD sections 4.1, 6.6, 8.3, 8.4 and 8.8.

const GameDataScript := preload("res://scripts/core/game_data.gd")

var tiers: Array = GameDataScript.load_table("progression")["tiers"]


func test_pen_equal_or_higher_is_full_damage() -> void:
	assert_eq(Rules.pen_multiplier(2, 1), 1.0)
	assert_eq(Rules.pen_multiplier(2, 2), 1.0)


func test_pen_gap_falloff() -> void:
	assert_eq(Rules.pen_multiplier(2, 3), 0.6, "lasgun vs power armour")
	assert_eq(Rules.pen_multiplier(4, 6), 0.3, "autocannon vs Leman Russ front")
	assert_eq(Rules.pen_multiplier(2, 5), 0.0, "lasgun can't hurt a tank")
	assert_eq(Rules.pen_multiplier(1, 6), 0.0)


func test_tiers_from_favour() -> void:
	assert_eq(Rules.tier_index_for_favour(0, tiers), 0, "cultist")
	assert_eq(Rules.tier_index_for_favour(7.5, tiers), 0)
	assert_eq(Rules.tier_index_for_favour(8, tiers), 1, "Moebian Trooper")
	assert_eq(Rules.tier_index_for_favour(20, tiers), 2, "carapace")
	assert_eq(Rules.tier_index_for_favour(99, tiers), 3, "Blessed")


func test_death_cost_example_from_gdd() -> void:
	# GDD 8.4: a Moebian Veteran with 32 Favour dies and respawns with 29.
	assert_near(Rules.favour_after_death(32, tiers), 29.0)


func test_death_never_drops_a_tier() -> void:
	for favour in [0.0, 8.0, 19.9, 20.0, 39.0, 40.0, 75.0]:
		var before := Rules.tier_index_for_favour(favour, tiers)
		var after := Rules.tier_index_for_favour(Rules.favour_after_death(favour, tiers), tiers)
		assert_eq(after, before, "favour %s" % favour)


func test_ogryn_needs_blessed() -> void:
	assert_true(not Rules.can_buy_ogryn(39, 40, 30))
	assert_true(Rules.can_buy_ogryn(45, 40, 30))
