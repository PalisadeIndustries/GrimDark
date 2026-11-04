@tool
extends Node3D
## A soldier posed procedurally on Godot's humanoid skeleton until real animations exist.
##
## Poses are built from a few targets in character space (+Z forward, +Y up, +X = the soldier's
## left): where the weapon is held, how low the hips are, and where the feet are planted.
## Two-bone IK then places both arms on the weapon and both legs on their feet targets.
## The optional "walk" mode animates those targets procedurally.

const POSES := [
	"low_ready", "aim", "crouch_ready", "kneel_aim", "relaxed", "walk", "run", "t_pose",
]

@export_enum("low_ready", "aim", "crouch_ready", "kneel_aim", "relaxed", "walk", "run", "t_pose")
var pose := "low_ready":
	set(value):
		pose = value
		_time = 0.0
		if is_inside_tree():
			apply_pose()
## Look/aim offset in degrees (x = pitch up, y = yaw left), for aiming at things.
@export var aim_offset := Vector2.ZERO:
	set(value):
		aim_offset = value
		if is_inside_tree():
			apply_pose()
@export var animate_in_editor := false

var skeleton: Skeleton3D
var weapon: Node3D
var _time := 0.0
var _rest_feet := {}


func _ready() -> void:
	apply_pose()


func _process(delta: float) -> void:
	if pose in ["walk", "run"] and (animate_in_editor or not Engine.is_editor_hint()):
		_time += delta
		apply_pose()


func cycle_pose(step: int = 1) -> void:
	pose = POSES[(POSES.find(pose) + step + POSES.size()) % POSES.size()]


## Interact key: next pose.
func interact(_by: Node = null) -> void:
	cycle_pose()


func get_prompt() -> String:
	return "Next pose (now: %s)" % pose.replace("_", " ")


func apply_pose() -> void:
	if skeleton == null:
		var found := find_children("*", "Skeleton3D", true, false)
		if found.is_empty():
			return  # model missing or not loaded
		skeleton = found.front() as Skeleton3D
		weapon = get_node_or_null("Weapon") as Node3D
	skeleton.reset_bone_poses()
	skeleton.force_update_all_bone_transforms()
	if _rest_feet.is_empty():
		for side in ["Left", "Right"]:
			_rest_feet[side] = _to_char(_bone_pos(side + "Foot"))

	if weapon:
		weapon.visible = pose not in ["t_pose", "relaxed"]
	if pose == "t_pose":
		return

	var p := _pose_params()
	# Body: hips height and lean, then legs, then spine and head, then arms.
	_offset_hips(p.hips_drop, p.hips_forward)
	for side in ["Left", "Right"]:
		var foot: Dictionary = p.feet[side]
		_two_bone_ik(side + "UpperLeg", side + "LowerLeg", side + "Foot", foot.target, foot.pole)
	_aim_bone("Spine", "Chest", _dir(p.lean, 0.0, Vector3.UP))
	var look := _dir(aim_offset.x + p.head_pitch, aim_offset.y, Vector3.MODEL_FRONT)
	_aim_bone("Chest", "Head", _dir(p.lean * 0.6, 0.0, Vector3.UP))
	_point_head(look)

	if weapon and weapon.visible:
		_hold_weapon(p, look)
	else:
		_relaxed_arms()
	skeleton.force_update_all_bone_transforms()


## Pose definitions. Distances in metres, angles in degrees.
func _pose_params() -> Dictionary:
	var feet := {
		"Left": {"target": _rest_feet["Left"], "pole": Vector3(0.1, 0, 1)},
		"Right": {"target": _rest_feet["Right"], "pole": Vector3(-0.1, 0, 1)},
	}
	var p := {"hips_drop": 0.0, "hips_forward": 0.0, "lean": 4.0, "head_pitch": 0.0,
		"weapon_pitch": -30.0, "shoulder_mount": false, "feet": feet}
	match pose:
		"aim":
			p.weapon_pitch = 0.0
			p.shoulder_mount = true
			p.lean = 6.0
			feet.Left.target = _rest_feet["Left"] + Vector3(0.0, 0, 0.18)
			feet.Right.target = _rest_feet["Right"] + Vector3(-0.05, 0, -0.12)
		"crouch_ready":
			p.hips_drop = 0.28
			p.hips_forward = -0.06
			p.lean = 18.0
			p.weapon_pitch = -15.0
			feet.Left.target = _rest_feet["Left"] + Vector3(0.03, 0, 0.12)
			feet.Right.target = _rest_feet["Right"] + Vector3(-0.03, 0, -0.08)
		"kneel_aim":
			p.hips_drop = 0.42
			p.lean = 4.0
			p.weapon_pitch = 0.0
			p.shoulder_mount = true
			# Left foot planted forward, right knee on the ground with the foot behind.
			feet.Left.target = Vector3(_rest_feet["Left"].x, _rest_feet["Left"].y, 0.32)
			feet.Right.target = Vector3(_rest_feet["Right"].x, 0.12, -0.42)
			feet.Right.pole = Vector3(0, -1, 0.4)
		"walk", "run":
			var running: bool = pose == "run"
			var speed := 1.6 if not running else 2.6
			var stride := 0.28 if not running else 0.42
			var lift := 0.10 if not running else 0.18
			var t := _time * TAU * (speed / (stride * 4.0))
			p.hips_drop = 0.04 + 0.025 * abs(sin(t)) + (0.08 if running else 0.0)
			p.lean = 8.0 if not running else 16.0
			p.weapon_pitch = -30.0 if not running else -40.0
			for i in 2:
				var side: String = ["Left", "Right"][i]
				var phase := t + PI * i
				var rest: Vector3 = _rest_feet[side]
				feet[side].target = rest + Vector3(0, max(0.0, -cos(phase)) * lift, sin(phase) * stride)
	return p


## Holds the weapon: places it relative to the right shoulder, then IKs both hands onto it.
func _hold_weapon(p: Dictionary, look: Vector3) -> void:
	var shoulder := _to_char(_bone_pos("RightUpperArm"))
	var pitch: float = p.weapon_pitch + aim_offset.x
	var dir := _dir(pitch, aim_offset.y, Vector3.MODEL_FRONT)
	if p.shoulder_mount:
		dir = look
	var right := dir.cross(Vector3.UP).normalized()  # soldier's right (-X when facing +Z)
	var up := right.cross(dir).normalized()
	var grip: Vector3
	if p.shoulder_mount:
		# Stock against the shoulder: the grip sits ~0.24 m in front of it, slightly inward and down.
		grip = shoulder + dir * 0.24 - up * 0.07 - right * 0.06
	else:
		# Low ready: across the body, muzzle down.
		grip = shoulder + Vector3(0.10, -0.30, 0.30)
	# Weapon frame: -Z along the barrel, +Y up, +X to the weapon's right.
	weapon.global_transform = global_transform * Transform3D(Basis(right, up, -dir).orthonormalized(), grip)
	var grip_marker := weapon.get_node_or_null("Grip") as Node3D
	var fore_marker := weapon.get_node_or_null("Foregrip") as Node3D
	var grip_pos := _from_skel_global(grip_marker.global_position) if grip_marker else grip
	var fore_pos := _from_skel_global(fore_marker.global_position) if fore_marker else grip + dir * 0.3
	# Wrists sit a little behind/below the palm contact points.
	_two_bone_ik("RightUpperArm", "RightLowerArm", "RightHand", grip_pos - dir * 0.05 - up * 0.03,
		Vector3(-0.6, -1.0, -0.2))
	_two_bone_ik("LeftUpperArm", "LeftLowerArm", "LeftHand", fore_pos - up * 0.05,
		Vector3(0.5, -1.0, 0.0))


func _relaxed_arms() -> void:
	for side in ["Left", "Right"]:
		var out := 0.12 if side == "Left" else -0.12
		var shoulder := _to_char(_bone_pos(side + "UpperArm"))
		_two_bone_ik(side + "UpperArm", side + "LowerArm", side + "Hand",
			shoulder + Vector3(out * 0.6, -0.52, 0.06), Vector3(out, 0, -1))


func _point_head(look: Vector3) -> void:
	var index := skeleton.find_bone("Head")
	if index == -1:
		return
	# Rotate the head so its forward matches the look direction (keeps it upright).
	var g := skeleton.get_bone_global_pose(index)
	var char_to_skel := _char_to_skel_basis()
	var current_fwd := (char_to_skel.inverse() * g.basis * _head_forward_local(index)).normalized()
	var q := Quaternion(current_fwd, look.normalized()) if current_fwd.dot(look) < 0.9999 else Quaternion.IDENTITY
	_rotate_global(index, q)


var _head_fwd_cache := Vector3.ZERO
func _head_forward_local(index: int) -> Vector3:
	if _head_fwd_cache == Vector3.ZERO:
		var rest := skeleton.get_bone_global_rest(index)
		_head_fwd_cache = (rest.basis.inverse() * (_char_to_skel_basis() * Vector3.MODEL_FRONT)).normalized()
	return _head_fwd_cache


# --- Skeleton helpers -------------------------------------------------------------------------

## Character-space direction from pitch (up) and yaw (left) in degrees, around a base axis.
func _dir(pitch_deg: float, yaw_deg: float, base: Vector3) -> Vector3:
	if base == Vector3.UP:
		return Vector3.UP.rotated(Vector3.RIGHT, deg_to_rad(pitch_deg)).normalized()  # lean forward
	return base.rotated(Vector3.RIGHT, -deg_to_rad(pitch_deg)).rotated(Vector3.UP, deg_to_rad(yaw_deg)).normalized()


func _char_to_skel_basis() -> Basis:
	return (skeleton.global_transform.basis.inverse() * global_transform.basis).orthonormalized()


func _bone_pos(bone: String) -> Vector3:
	return skeleton.get_bone_global_pose(skeleton.find_bone(bone)).origin


## Skeleton space -> character space.
func _to_char(p_skel: Vector3) -> Vector3:
	return global_transform.affine_inverse() * (skeleton.global_transform * p_skel)


func _from_skel_global(p_world: Vector3) -> Vector3:
	return global_transform.affine_inverse() * p_world


func _to_skel(p_char: Vector3) -> Vector3:
	return skeleton.global_transform.affine_inverse() * (global_transform * p_char)


func _rotate_global(index: int, q_char: Quaternion) -> void:
	# q is a rotation in character space; convert to skeleton space.
	var b := _char_to_skel_basis()
	var q := Quaternion(b * Basis(q_char) * b.inverse())
	var g := skeleton.get_bone_global_pose(index)
	var new_basis := Basis(q) * g.basis
	var parent := skeleton.get_bone_parent(index)
	var parent_basis := skeleton.get_bone_global_pose(parent).basis if parent != -1 else Basis.IDENTITY
	skeleton.set_bone_pose_rotation(index, (parent_basis.inverse() * new_basis).get_rotation_quaternion())
	skeleton.force_update_all_bone_transforms()


## Rotates `bone` so the direction to `child` points along `dir` (character space).
func _aim_bone(bone: String, child: String, dir: Vector3) -> void:
	var i := skeleton.find_bone(bone)
	var c := skeleton.find_bone(child)
	if i == -1 or c == -1:
		return
	var cur := (_to_char(_bone_pos(child)) - _to_char(_bone_pos(bone))).normalized()
	if cur.dot(dir.normalized()) > 0.9999:
		return
	_rotate_global(i, Quaternion(cur, dir.normalized()))


func _offset_hips(drop: float, forward: float) -> void:
	var i := skeleton.find_bone("Hips")
	if i == -1:
		return
	var offset_skel := _char_to_skel_basis() * Vector3(0, -drop, forward)
	var parent := skeleton.get_bone_parent(i)
	var parent_basis := skeleton.get_bone_global_pose(parent).basis if parent != -1 else Basis.IDENTITY
	skeleton.set_bone_pose_position(i, skeleton.get_bone_pose_position(i) + parent_basis.inverse() * offset_skel)
	skeleton.force_update_all_bone_transforms()


## Analytic two-bone IK in character space. `pole` is the direction the middle joint bends toward.
func _two_bone_ik(upper: String, lower: String, end: String, target: Vector3, pole: Vector3) -> void:
	var iu := skeleton.find_bone(upper)
	var il := skeleton.find_bone(lower)
	var ie := skeleton.find_bone(end)
	if iu == -1 or il == -1 or ie == -1:
		return
	var a_pos := _to_char(_bone_pos(upper))
	var b_pos := _to_char(_bone_pos(lower))
	var c_pos := _to_char(_bone_pos(end))
	var len_a := a_pos.distance_to(b_pos)
	var len_b := b_pos.distance_to(c_pos)
	var to_target := target - a_pos
	var d := clampf(to_target.length(), absf(len_a - len_b) + 0.001, len_a + len_b - 0.001)
	var n := to_target.normalized()
	var cos_a := clampf((len_a * len_a + d * d - len_b * len_b) / (2.0 * len_a * d), -1.0, 1.0)
	var m := (pole - n * pole.dot(n))
	if m.length() < 0.001:
		m = Vector3.UP - n * n.y
	m = m.normalized()
	var elbow := a_pos + n * (len_a * cos_a) + m * (len_a * sqrt(1.0 - cos_a * cos_a))
	var hand := a_pos + n * d
	_aim_bone(upper, lower, (elbow - a_pos).normalized())
	_aim_bone(lower, end, (hand - _to_char(_bone_pos(lower))).normalized())
