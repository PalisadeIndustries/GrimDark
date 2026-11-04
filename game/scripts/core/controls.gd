extends Node
## Registers the default input actions at startup, so project.godot stays readable.
## Players will be able to rebind these later from a settings menu. Autoloaded as Controls.

const KEY_BINDINGS := {
	"move_forward": [KEY_W],
	"move_back": [KEY_S],
	"move_left": [KEY_A],
	"move_right": [KEY_D],
	"sprint": [KEY_SHIFT],
	"crouch": [KEY_C, KEY_CTRL],
	"prone": [KEY_Z],
	"jump": [KEY_SPACE],
	"interact": [KEY_F],
	"reload": [KEY_R],
	"ping": [KEY_Q],
	"map": [KEY_M],
	"release_mouse": [KEY_ESCAPE],
}

const MOUSE_BINDINGS := {
	"fire": [MOUSE_BUTTON_LEFT],
	"aim": [MOUSE_BUTTON_RIGHT],
}


func _init() -> void:
	register_defaults()


static func register_defaults() -> void:
	for action in KEY_BINDINGS:
		_ensure_action(action)
		for keycode in KEY_BINDINGS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action, event)
	for action in MOUSE_BINDINGS:
		_ensure_action(action)
		for button in MOUSE_BINDINGS[action]:
			var event := InputEventMouseButton.new()
			event.button_index = button
			InputMap.action_add_event(action, event)


static func _ensure_action(action: StringName) -> void:
	if InputMap.has_action(action):
		InputMap.action_erase_events(action)
	else:
		InputMap.add_action(action)
