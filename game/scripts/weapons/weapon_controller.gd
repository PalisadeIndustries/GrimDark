extends Node3D
## First-person weapon for the test range: hitscan firing with the GDD's penetration rules,
## pooled magazines (GDD 7.1), fire modes, reloading, aiming down sights, recoil and plasma heat.
## Every test weapon uses the lasgun model as a placeholder.

signal fired(weapon_id: String)
signal hit_reported(report: Dictionary)
signal state_changed

const HIP_POS := Vector3(0.2, -0.24, -0.52)
const ADS_POS := Vector3(0.0, -0.105, -0.4)
const HIP_FOV := 80.0
const ADS_FOV := 55.0

@export var camera_path: NodePath = ^".."
@export var player_path: NodePath = ^"../../.."

var weapon_ids: Array = []
var weapon_index := 0
var stats: Dictionary = {}
var weapon_id := ""
var magazine := 0
var reserve := 0
var fire_mode_index := 0
var reloading := false
var infinite_ammo := false
var heat := 0.0
var overheat_lockout := 0.0
var ads := 0.0
var _cooldown := 0.0
var _burst_left := 0
var _reload_left := 0.0
var _recoil := 0.0
var _heat_idle := 0.0
var _ammo: Dictionary = {}  # weapon id -> [magazine, reserve], so switching keeps ammo

@onready var camera: Camera3D = get_node(camera_path)
@onready var player: Node3D = get_node(player_path)
@onready var model: Node3D = $Lasgun
@onready var muzzle: Node3D = $Lasgun/Muzzle


func _ready() -> void:
	weapon_ids = GameData.table("weapons").get("test_range_weapons", ["lasgun"])
	for m in model.find_children("*", "GeometryInstance3D", true, false):
		(m as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	select_weapon(0)


func select_weapon(index: int) -> void:
	if weapon_id != "":
		_ammo[weapon_id] = [magazine, reserve]
	weapon_index = (index + weapon_ids.size()) % weapon_ids.size()
	weapon_id = weapon_ids[weapon_index]
	var table: Dictionary = GameData.table("weapons")
	stats = table["small_arms"].get(weapon_id, table["special"].get(weapon_id, {}))
	var saved: Array = _ammo.get(weapon_id, [int(stats.get("magazine", 30)), int(stats.get("reserve", 120))])
	magazine = saved[0]
	reserve = saved[1]
	fire_mode_index = 0
	reloading = false
	_burst_left = 0
	heat = 0.0
	state_changed.emit()


func fire_mode() -> String:
	var modes: Array = stats.get("fire_modes", ["semi"])
	return modes[fire_mode_index % modes.size()]


func refill() -> void:
	magazine = int(stats.get("magazine", 30))
	reserve = int(stats.get("reserve", 120))
	_ammo.clear()
	state_changed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reload"):
		start_reload()
	elif event.is_action_pressed("fire_mode"):
		fire_mode_index += 1
		state_changed.emit()
	elif event.is_action_pressed("weapon_next"):
		select_weapon(weapon_index + 1)
	elif event.is_action_pressed("toggle_infinite_ammo"):
		infinite_ammo = not infinite_ammo
		state_changed.emit()
	elif event.is_action_pressed("vent") and weapon_id == "plasma_gun":
		_vent()
	else:
		for i in 7:
			if event.is_action_pressed("weapon_%d" % (i + 1)) and i < weapon_ids.size():
				select_weapon(i)


func _physics_process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)
	_update_heat(delta)
	if reloading:
		_reload_left -= delta
		if _reload_left <= 0.0:
			_finish_reload()

	var mouse_captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	var mode := fire_mode()
	if mouse_captured and _cooldown <= 0.0:
		if _burst_left > 0:
			_burst_left -= 1
			_shoot()
		elif Input.is_action_just_pressed("fire") or (mode == "auto" and Input.is_action_pressed("fire")):
			if mode == "burst3":
				_burst_left = 2
			_shoot()

	# Aim down sights and recoil.
	var want_ads := mouse_captured and Input.is_action_pressed("aim") and not reloading
	ads = move_toward(ads, 1.0 if want_ads else 0.0, delta * 6.0)
	_recoil = move_toward(_recoil, 0.0, delta * 8.0)
	position = HIP_POS.lerp(ADS_POS, ads) + Vector3(0, 0, _recoil * 0.06)
	rotation.x = deg_to_rad(_recoil * 4.0)
	var reload_tilt := 0.0 if not reloading else sin(clampf(1.0 - _reload_left / float(stats.get("reload_s", 2.0)), 0.0, 1.0) * PI) * 0.6
	rotation.z = reload_tilt
	camera.fov = lerpf(HIP_FOV, ADS_FOV, ads)


func _shoot() -> void:
	if reloading or overheat_lockout > 0.0:
		return
	if magazine <= 0:
		start_reload()
		return
	_cooldown = 60.0 / float(stats.get("rpm", 300))
	if not infinite_ammo:
		magazine -= 1

	var overcharged := weapon_id == "plasma_gun" and fire_mode() == "overcharge"
	var heat_rules: Dictionary = GameData.table("weapons").get("plasma_heat", {})
	if weapon_id == "plasma_gun":
		if overcharged and heat >= float(heat_rules.get("catastrophic_threshold", 90)) and randf() < float(heat_rules.get("catastrophic_chance", 0.33)):
			hit_reported.emit({"event": "catastrophic"})
			heat = 0.0
			state_changed.emit()
			return
		heat += float(heat_rules.get("overcharged_shot" if overcharged else "normal_shot", 10))
		_heat_idle = 0.0
		if heat >= float(heat_rules.get("overheat", 100)):
			overheat_lockout = float(heat_rules.get("overheat_lockout_s", 5))
			hit_reported.emit({"event": "overheat", "damage": heat_rules.get("overheat_damage", 40)})

	var pellets := int(stats.get("pellets", 1))
	for i in pellets:
		_fire_ray(overcharged)
	_recoil = minf(_recoil + float(stats.get("recoil", 1.0)) * 0.35, 1.5)
	player.call("add_recoil", float(stats.get("recoil", 1.0)) * (0.35 if ads > 0.5 else 0.6))
	_muzzle_flash()
	fired.emit(weapon_id)
	state_changed.emit()


func _fire_ray(overcharged: bool) -> void:
	var spread := lerpf(float(stats.get("spread_hip", 2.0)), float(stats.get("spread_ads", 0.3)), ads)
	var dir := -camera.global_transform.basis.z
	dir = dir.rotated(camera.global_transform.basis.x, deg_to_rad(randf_range(-spread, spread) * 0.5))
	dir = dir.rotated(camera.global_transform.basis.y, deg_to_rad(randf_range(-spread, spread) * 0.5))
	var from := camera.global_position
	var to := from + dir * 600.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	if player is CollisionObject3D:
		query.exclude = [(player as CollisionObject3D).get_rid()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	var end := to
	if not result.is_empty():
		end = result.position
		_impact(result.position, result.normal)
		var target: Node = result.collider
		while target and not target.has_method("take_hit"):
			target = target.get_parent()
		if target:
			var shape_node: Node = null
			var body := result.collider as CollisionObject3D
			if body:
				shape_node = body.shape_owner_get_owner(body.shape_find_owner(result.shape))
			var location := float(shape_node.get_meta("hit_multiplier", 1.0)) if shape_node else 1.0
			var info := {
				"weapon": weapon_id,
				"damage": float(stats.get("damage_overcharged" if overcharged else "damage", 50)),
				"pen": int(stats.get("pen_overcharged" if overcharged else "pen", 1)),
				"location_multiplier": location,
				"location": shape_node.name if shape_node else "Body",
				"distance": from.distance_to(result.position),
				"range": float(stats.get("range_m", 100)),
			}
			var report: Dictionary = target.take_hit(info)
			hit_reported.emit(report)
	_tracer(muzzle.global_position, end)


func start_reload() -> void:
	var mag_size := int(stats.get("magazine", 30))
	if reloading or magazine >= mag_size or (reserve <= 0 and not infinite_ammo):
		return
	reloading = true
	_burst_left = 0
	_reload_left = float(stats.get("reload_s", 2.0))
	state_changed.emit()


func _finish_reload() -> void:
	reloading = false
	var needed := int(stats.get("magazine", 30)) - magazine
	var taken := needed if infinite_ammo else mini(needed, reserve)
	magazine += taken
	if not infinite_ammo:
		reserve -= taken
	state_changed.emit()


func _update_heat(delta: float) -> void:
	if overheat_lockout > 0.0:
		overheat_lockout = maxf(overheat_lockout - delta, 0.0)
		if overheat_lockout == 0.0:
			heat = 0.0
		state_changed.emit()
		return
	if heat > 0.0:
		_heat_idle += delta
		var rules: Dictionary = GameData.table("weapons").get("plasma_heat", {})
		if _heat_idle > float(rules.get("decay_delay_s", 1)):
			heat = maxf(heat - float(rules.get("decay_per_s", 15)) * delta, 0.0)
			state_changed.emit()


func _vent() -> void:
	heat = 0.0
	overheat_lockout = 0.0
	hit_reported.emit({"event": "vent"})
	state_changed.emit()


# --- Effects -----------------------------------------------------------------------------------

const TRACER_COLOURS := {
	"las": Color(1.0, 0.15, 0.1), "bullet": Color(1.0, 0.85, 0.5), "bolt": Color(1.0, 0.6, 0.2),
	"plasma": Color(0.4, 0.75, 1.0), "melta": Color(1.0, 0.5, 0.1),
}


func _colour() -> Color:
	return TRACER_COLOURS.get(stats.get("tracer", "bullet"), Color.WHITE)


func _tracer(from: Vector3, to: Vector3) -> void:
	var length := from.distance_to(to)
	if length < 0.1:
		return
	var mesh := CylinderMesh.new()
	var width := 0.012 if stats.get("tracer") in ["las", "bullet"] else 0.03
	mesh.top_radius = width
	mesh.bottom_radius = width
	mesh.height = length
	mesh.radial_segments = 6
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = _colour()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = mat
	var beam := MeshInstance3D.new()
	beam.mesh = mesh
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	get_tree().current_scene.add_child(beam)
	beam.global_position = (from + to) * 0.5
	var y := (to - from).normalized()
	var x := y.cross(Vector3.UP if absf(y.y) < 0.99 else Vector3.RIGHT).normalized()
	beam.global_basis = Basis(x, y, x.cross(y))
	var tween := beam.create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, 0.08)
	tween.tween_callback(beam.queue_free)


func _muzzle_flash() -> void:
	var light := OmniLight3D.new()
	light.light_color = _colour()
	light.light_energy = 3.0
	light.omni_range = 4.0
	muzzle.add_child(light)
	var tween := light.create_tween()
	tween.tween_property(light, "light_energy", 0.0, 0.05)
	tween.tween_callback(light.queue_free)


func _impact(pos: Vector3, normal: Vector3) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 0.04 if stats.get("tracer") in ["las", "bullet"] else 0.12
	mesh.height = mesh.radius * 2.0
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = _colour().lightened(0.3)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = mat
	var spark := MeshInstance3D.new()
	spark.mesh = mesh
	get_tree().current_scene.add_child(spark)
	spark.global_position = pos + normal * 0.02
	var tween := spark.create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, 0.25)
	tween.tween_callback(spark.queue_free)
