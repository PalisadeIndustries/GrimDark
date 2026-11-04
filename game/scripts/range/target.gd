extends StaticBody3D
## Shooting-range target. Applies the GDD damage rules for its armour class and reports the maths.

signal hit(report: Dictionary)

@export var armour_class := "flak"
@export var display_name := "Guardsman"
@export var respawn_s := 3.0

var max_hp := 100.0
var hp := 100.0
var down := false
var _label: Label3D
var _last := ""


func _ready() -> void:
	max_hp = float(GameData.table("armour")["hit_points"].get(armour_class, 100))
	hp = max_hp
	_label = Label3D.new()
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.font_size = 48
	_label.pixel_size = 0.009
	_label.outline_size = 12
	_label.position = Vector3(0, _label_height(), 0)
	_label.no_depth_test = false
	add_child(_label)
	_refresh()


func _label_height() -> float:
	return float(get_meta("label_height", 2.3))


func take_hit(info: Dictionary) -> Dictionary:
	var armour: Dictionary = GameData.table("armour")
	var armour_value := int(armour["classes"].get(armour_class, 0))
	var reduction := float(armour["damage_reduction"].get(armour_class, 0.0))
	var falloff: Dictionary = GameData.table("weapons").get("range_falloff", {})
	var range_mult := Rules.range_multiplier(info.distance, info.range,
		float(falloff.get("beyond_range", 0.5)), float(falloff.get("beyond_double_range", 0.25)))
	var pen_mult := Rules.pen_multiplier(info.pen, armour_value)
	var dealt := Rules.damage(info.damage, info.pen, armour_value, reduction, info.location_multiplier) * range_mult
	var report := {
		"target": display_name, "armour_class": armour_class, "armour": armour_value,
		"weapon": info.weapon, "pen": info.pen, "pen_mult": pen_mult, "reduction": reduction,
		"location": info.location, "location_mult": info.location_multiplier,
		"range_mult": range_mult, "distance": info.distance, "damage": dealt, "killed": false,
	}
	if down:
		return report
	hp = maxf(hp - dealt, 0.0)
	_last = "-%d" % roundi(dealt) if dealt > 0.0 else "NO EFFECT"
	if hp <= 0.0:
		report.killed = true
		_knock_down()
	_refresh()
	hit.emit(report)
	return report


func _knock_down() -> void:
	down = true
	var tween := create_tween()
	tween.tween_property(self, "rotation_degrees:x", -80.0, 0.25)
	tween.tween_interval(respawn_s)
	tween.tween_callback(_reset)
	tween.tween_property(self, "rotation_degrees:x", 0.0, 0.3)


func _reset() -> void:
	down = false
	hp = max_hp
	_last = ""
	_refresh()


func _refresh() -> void:
	var armour_value := int(GameData.table("armour")["classes"].get(armour_class, 0))
	var bar_len := 10
	var filled := int(ceil(hp / max_hp * bar_len))
	_label.text = "%s\nArmour %d (%s)\n%s %d/%d\n%s" % [display_name, armour_value, armour_class.replace("_", " "),
		"■".repeat(filled) + "□".repeat(bar_len - filled), roundi(hp), roundi(max_hp), _last]
	_label.modulate = Color(1, 0.9, 0.75) if not down else Color(0.6, 0.6, 0.6)
