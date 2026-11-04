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

@onready var head: Node3D = $Head


func _ready() -> void:
	stamina = max_stamina
	if DisplayServer.get_name() != "headless":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-85.0), deg_to_rad(85.0))
	elif event.is_action_pressed("release_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("crouch"):
		stance = Stance.STAND if stance == Stance.CROUCH else Stance.CROUCH
	elif event.is_action_pressed("prone"):
		stance = Stance.STAND if stance == Stance.PRONE else Stance.PRONE


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
