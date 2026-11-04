extends Node3D
## Builds the weapon and animation test range (GDD prototype, Section 23).
##   Weapons range: targets for every armour class at 25 m, flak targets at 50-200 m, ammo crate.
##   Animation yard: the traitor guard in every pose (interact to change), a walking soldier,
##   and the Animation Station for imported humanoid animations.
##   A squad of posed traitor guards on the firing line, for the look of the game.

const SOLDIER := preload("res://scenes/characters/traitor_guard.tscn")
const TARGET_SCRIPT := preload("res://scripts/range/target.gd")
const INTERACT_SCRIPT := preload("res://scripts/range/interactable.gd")
const STATION_SCRIPT := preload("res://scripts/range/animation_station.gd")

const KHAKI := Color(0.66, 0.58, 0.40)
const ASH := Color(0.33, 0.32, 0.29)
const SANDBAG := Color(0.42, 0.38, 0.30)

var walker: Node3D
var _walk_angle := 0.0


func _ready() -> void:
	_environment()
	_ground()
	_firing_line()
	_armour_row()
	_distance_row()
	_field_cover()
	_animation_yard()
	_squad()
	_sign(Vector3(-11, 2.4, 1), "GRIMDARK TEST RANGE\nWeapons range ahead  ·  Animation yard to the right →\nF1 for controls", 64)


func _process(delta: float) -> void:
	if walker == null:
		return
	var speed := 1.6 if walker.pose == "walk" else 2.6
	var radius := 7.0
	_walk_angle += speed / radius * delta
	var centre := Vector3(46, 0, -34)
	walker.position = centre + Vector3(cos(_walk_angle), 0, sin(_walk_angle)) * radius
	var tangent := Vector3(-sin(_walk_angle), 0, cos(_walk_angle))
	walker.look_at(walker.position - tangent, Vector3.UP)  # model faces +Z, look_at points -Z


func refill(by: Node) -> void:
	var weapon := by.get_node_or_null("Head/Camera/ViewModel")
	if weapon:
		weapon.refill()


func toggle_walker(_by: Node = null) -> void:
	walker.pose = "run" if walker.pose == "walk" else "walk"


# --- World -------------------------------------------------------------------------------------

func _environment() -> void:
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.34, 0.33, 0.30)
	sky_mat.sky_horizon_color = Color(0.66, 0.60, 0.50)
	sky_mat.ground_bottom_color = Color(0.16, 0.15, 0.13)
	sky_mat.ground_horizon_color = Color(0.66, 0.60, 0.50)
	sky_mat.sun_angle_max = 20.0
	var sky := Sky.new()
	sky.sky_material = sky_mat
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.9
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color(0.58, 0.54, 0.47)
	env.fog_density = 0.006
	env.fog_sky_affect = 0.6
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-32, 25, 0)  # low sun behind the firing line, lighting the targets
	sun.light_color = Color(1.0, 0.88, 0.72)
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 120.0
	add_child(sun)


func _ground() -> void:
	_box(Vector3(0, -0.5, -100), Vector3(260, 1, 320), ASH)
	_box(Vector3(46, -0.48, -22), Vector3(40, 1, 36), Color(0.29, 0.28, 0.26))  # yard pad


func _firing_line() -> void:
	for x in [-14, -9, -4, 4, 9, 14]:
		_box(Vector3(x, 0.45, -3), Vector3(3.6, 0.9, 0.9), SANDBAG)
	_box(Vector3(0, 0.02, -2.2), Vector3(32, 0.04, 0.12), Color(0.7, 0.6, 0.2))  # painted firing line
	var crate := _box(Vector3(2.2, 0.35, 0.5), Vector3(1.0, 0.7, 0.6), Color(0.27, 0.32, 0.17))
	crate.set_script(INTERACT_SCRIPT)
	crate.prompt = "Refill ammo"
	crate.target = self
	crate.method = "refill"
	_sign(Vector3(2.2, 1.1, 0.5), "AMMO", 40)


func _armour_row() -> void:
	var z := -25.0
	var rows := [
		["Cultist", "none", "dummy", Color(0.38, 0.30, 0.22)],
		["Guardsman", "flak", "dummy", KHAKI],
		["Veteran", "carapace", "dummy", KHAKI.darkened(0.25)],
		["Sister", "power", "dummy", Color(0.16, 0.16, 0.18)],
		["Sentinel (side)", "light_vehicle", "plate", Color(0.45, 0.47, 0.40)],
		["Chimera (front)", "medium_vehicle", "plate", Color(0.42, 0.44, 0.37)],
		["Leman Russ (front)", "heavy_vehicle", "plate", Color(0.38, 0.40, 0.33)],
	]
	for i in rows.size():
		var r: Array = rows[i]
		var pos := Vector3(-18 + i * 6, 0, z)
		if r[2] == "dummy":
			_dummy(pos, r[0], r[1], r[3])
		else:
			_plate(pos, r[0], r[1], r[3])
	_sign(Vector3(-22, 0.8, z), "25 m", 72)


func _distance_row() -> void:
	for d in [50, 100, 150, 200]:
		_dummy(Vector3(-6, 0, -d), "Guardsman %d m" % d, "flak", KHAKI)
		_dummy(Vector3(6, 0, -d), "Veteran %d m" % d, "carapace", KHAKI.darkened(0.25))
		_sign(Vector3(-12, 1.2, -d), "%d m" % d, 120 + d / 2)


func _field_cover() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 40000
	for i in 18:
		var pos := Vector3(rng.randf_range(-30, 30), 0.25, rng.randf_range(-35, -190))
		if absf(pos.x) < 9.0:
			continue
		var b := _box(pos, Vector3(rng.randf_range(2, 5), rng.randf_range(0.5, 1.2), rng.randf_range(0.8, 1.6)), SANDBAG.darkened(rng.randf_range(0, 0.3)))
		b.rotation.y = rng.randf_range(-0.5, 0.5)
	# Enemy bunker and trench at the far end.
	_box(Vector3(0, 1.6, -235), Vector3(16, 3.2, 8), Color(0.62, 0.56, 0.42))
	_box(Vector3(0, 0.6, -226), Vector3(70, 1.2, 1.2), Color(0.55, 0.50, 0.38))


func _animation_yard() -> void:
	_sign(Vector3(46, 3.2, -3), "ANIMATION YARD\nF on a soldier: next pose", 64)
	var poses := ["low_ready", "aim", "crouch_ready", "kneel_aim", "relaxed", "t_pose"]
	for i in poses.size():
		var pos := Vector3(32 + i * 5.5, 0, -12)
		_box(pos + Vector3(0, 0.1, 0), Vector3(2.2, 0.2, 2.2), Color(0.38, 0.36, 0.33))
		var s := _soldier(pos + Vector3(0, 0.2, 0), poses[i], 0.0)
		_sign(pos + Vector3(0, 2.5, 0), poses[i].replace("_", " "), 48)
		s.name = "Pose_" + poses[i]
	walker = _soldier(Vector3(53, 0, -34), "walk", 0.0)
	walker.name = "Walker"
	var body := walker.get_node("Interact") as StaticBody3D
	body.target = self
	body.method = "toggle_walker"
	body.prompt = "Switch walk / run"
	_sign(Vector3(46, 2.8, -34), "Procedural walk / run\n(F on the soldier to switch)", 48)
	var station := StaticBody3D.new()
	station.set_script(STATION_SCRIPT)
	station.position = Vector3(36, 0, -26)
	add_child(station)
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	shape.shape = capsule
	shape.position = Vector3(0, 0.9, 0)
	station.add_child(shape)
	station.rotation_degrees.y = 0
	_box(Vector3(36, 0.1, -26), Vector3(3, 0.2, 3), Color(0.30, 0.34, 0.24))


## Posed squad on the firing line and in the field ahead: a mockup of how the game should look.
func _squad() -> void:
	var placements := [
		[Vector3(-9, 0, -1.9), "kneel_aim", 4.0, Vector2(0, 0)],
		[Vector3(-14, 0, -1.9), "aim", 6.0, Vector2(0, 0)],
		[Vector3(9.5, 0, -1.9), "kneel_aim", -6.0, Vector2(0, 0)],
		[Vector3(14.5, 0, -2.0), "aim", -10.0, Vector2(1, 0)],
		[Vector3(-17, 0, 1.0), "low_ready", 25.0, Vector2(0, 0)],
		[Vector3(18, 0, 1.5), "crouch_ready", -20.0, Vector2(0, 0)],
	]
	for p in placements:
		var s := _soldier(p[0], p[1], p[2])
		s.aim_offset = p[3]


# --- Builders ----------------------------------------------------------------------------------

func _box(pos: Vector3, size: Vector3, colour: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = pos
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = colour
	mat.roughness = 0.95
	box.material = mat
	mesh.mesh = box
	body.add_child(mesh)
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	shape.shape = bs
	body.add_child(shape)
	add_child(body)
	return body


func _sign(pos: Vector3, text: String, font_size: int) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.position = pos
	l.font_size = font_size
	l.pixel_size = 0.005
	l.outline_size = 14
	l.modulate = Color(0.93, 0.88, 0.74)
	l.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	add_child(l)
	return l


func _material(colour: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = colour
	m.roughness = 0.8
	return m


func _dummy(pos: Vector3, display_name: String, armour_class: String, colour: Color) -> StaticBody3D:
	var t := StaticBody3D.new()
	t.set_script(TARGET_SCRIPT)
	t.armour_class = armour_class
	t.display_name = display_name
	t.position = pos
	var body_mesh := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.25
	cap.height = 1.45
	cap.material = _material(colour)
	body_mesh.mesh = cap
	body_mesh.position = Vector3(0, 0.78, 0)
	t.add_child(body_mesh)
	var head_mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.13
	sphere.height = 0.26
	sphere.material = _material(colour.darkened(0.3))
	head_mesh.mesh = sphere
	head_mesh.position = Vector3(0, 1.66, 0)
	t.add_child(head_mesh)
	var body_shape := CollisionShape3D.new()
	var cs := CapsuleShape3D.new()
	cs.radius = 0.25
	cs.height = 1.45
	body_shape.shape = cs
	body_shape.position = Vector3(0, 0.78, 0)
	body_shape.name = "Torso"
	t.add_child(body_shape)
	var head_shape := CollisionShape3D.new()
	var ss := SphereShape3D.new()
	ss.radius = 0.13
	head_shape.shape = ss
	head_shape.position = Vector3(0, 1.66, 0)
	head_shape.name = "Head"
	# GDD 6.2: head x3, or x2 with a helmet (everyone but cultists wears one).
	head_shape.set_meta("hit_multiplier", 3.0 if armour_class == "none" else 2.0)
	t.add_child(head_shape)
	t.set_meta("label_height", 2.25)
	add_child(t)
	return t


func _plate(pos: Vector3, display_name: String, armour_class: String, colour: Color) -> StaticBody3D:
	var t := StaticBody3D.new()
	t.set_script(TARGET_SCRIPT)
	t.armour_class = armour_class
	t.display_name = display_name
	t.position = pos
	var size := Vector3(2.4, 1.8, 0.25)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	box.material = _material(colour)
	mesh.mesh = box
	mesh.position = Vector3(0, 1.1, 0)
	t.add_child(mesh)
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	shape.shape = bs
	shape.position = Vector3(0, 1.1, 0)
	shape.name = "Plate"
	t.add_child(shape)
	t.set_meta("label_height", 2.75)
	add_child(t)
	return t


func _soldier(pos: Vector3, pose: String, yaw_deg: float) -> Node3D:
	var s: Node3D = SOLDIER.instantiate()
	s.position = pos
	s.rotation_degrees.y = 180.0 + yaw_deg  # face downrange (-Z)
	s.pose = pose
	add_child(s)
	var body := StaticBody3D.new()
	body.name = "Interact"
	body.set_script(INTERACT_SCRIPT)
	body.target = s
	var shape := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.8
	shape.shape = cap
	shape.position = Vector3(0, 0.9, 0)
	body.add_child(shape)
	s.add_child(body)
	return s
