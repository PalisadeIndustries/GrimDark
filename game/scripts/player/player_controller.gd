extends CharacterBody3D
## First-person soldier movement (GDD 6.1): walk, sprint with stamina, crouch, prone, jump.
## Greybox version: no weapons yet.

@export var walk_speed := 4.0
@export var sprint_speed := 6.5
@export var crouch_speed := 2.2
@export var prone_speed := 0.9
@export var jump_velocity := 4.2
@export var mouse_sensitivity := 0.0025
@export var max_stamina := 100.0
@export var sprint_drain_per_s := 20.0
@export var stamina_regen_per_s := 15.0

const STAND_EYE := 1.6
const CROUCH_EYE := 1.0
const PRONE_EYE := 0.4

enum Stance { STAND, CROUCH, PRONE }

var stance := Stance.STAND
var stamina := 100.0
## What the interact key would use right now (has interact()), or null.
var interact_target: Node = null

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera


func _ready() -> void:
	stamina = max_stamina
	if DisplayServer.get_name() != "headless":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Mouse look runs in _input so no UI element can swallow the motion.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-85.0), deg_to_rad(85.0))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("release_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("crouch"):
		stance = Stance.STAND if stance == Stance.CROUCH else Stance.CROUCH
	elif event.is_action_pressed("prone"):
		stance = Stance.STAND if stance == Stance.PRONE else Stance.PRONE
	elif event.is_action_pressed("interact") and interact_target:
		interact_target.call("interact", self)


## Kicks the view up by `degrees`, with a little sideways wander (weapon recoil).
func add_recoil(degrees: float) -> void:
	head.rotation.x = clampf(head.rotation.x + deg_to_rad(degrees), deg_to_rad(-85.0), deg_to_rad(85.0))
	rotate_y(deg_to_rad(randf_range(-0.3, 0.3) * degrees))


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif Input.is_action_just_pressed("jump") and stance == Stance.STAND:
		velocity.y = jump_velocity

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()
	var speed := _current_speed(input, delta)

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	move_and_slide()
	_update_eye_height(delta)
	_update_interact_target()


func _update_interact_target() -> void:
	var from := camera.global_position
	var query := PhysicsRayQueryParameters3D.create(from, from - camera.global_basis.z * 4.0)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	interact_target = null
	if not hit.is_empty():
		var node: Node = hit.collider
		while node and not node.has_method("interact"):
			node = node.get_parent()
		interact_target = node


func _current_speed(input: Vector2, delta: float) -> float:
	var wants_sprint := Input.is_action_pressed("sprint") and input.y < 0.0 and stance == Stance.STAND
	if wants_sprint and stamina > 0.0:
		stamina = maxf(stamina - sprint_drain_per_s * delta, 0.0)
		return sprint_speed
	stamina = minf(stamina + stamina_regen_per_s * delta, max_stamina)
	match stance:
		Stance.CROUCH:
			return crouch_speed
		Stance.PRONE:
			return prone_speed
	return walk_speed


func _update_eye_height(delta: float) -> void:
	var target := STAND_EYE
	match stance:
		Stance.CROUCH:
			target = CROUCH_EYE
		Stance.PRONE:
			target = PRONE_EYE
	head.position.y = lerpf(head.position.y, target, clampf(delta * 10.0, 0.0, 1.0))
