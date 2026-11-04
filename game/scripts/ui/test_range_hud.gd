extends CanvasLayer
## Test range HUD: ammo, fire mode, heat, a hit log with the damage maths, interaction prompt
## and controls help. Built in code so it stays easy to change.

@export var weapon_path: NodePath
@export var player_path: NodePath

var weapon: Node
var player: Node
var _ammo: Label
var _weapon_label: Label
var _log: Label
var _prompt: Label
var _help: Label
var _dot: ColorRect
var _banner: Label
var _heat: ProgressBar
var _mag_bar: ProgressBar
var _fps: Label
var _lines: Array[String] = []
var _banner_time := 0.0

const HELP := """WASD move · Shift sprint · C crouch · Z prone · Space jump
LMB fire · RMB aim · R reload · B fire mode · 1-7 / E weapons
V vent plasma · I infinite ammo · H dot · F interact · F1 help · Esc mouse"""


func _ready() -> void:
	weapon = get_node(weapon_path)
	player = get_node(player_path)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_dot = ColorRect.new()
	_dot.color = Color(1, 1, 1, 0.7)
	_dot.size = Vector2(4, 4)
	_dot.set_anchors_preset(Control.PRESET_CENTER)
	_dot.position = -_dot.size / 2
	_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE  # the captured mouse sits here; never eat its motion
	root.add_child(_dot)

	_weapon_label = _label(root, Control.PRESET_BOTTOM_RIGHT, Vector2(-420, -150), 20, HORIZONTAL_ALIGNMENT_RIGHT)
	_ammo = _label(root, Control.PRESET_BOTTOM_RIGHT, Vector2(-420, -110), 40, HORIZONTAL_ALIGNMENT_RIGHT)
	_mag_bar = _bar(root, Control.PRESET_BOTTOM_RIGHT, Vector2(-420, -48), Color(0.75, 0.8, 0.45))
	_heat = _bar(root, Control.PRESET_BOTTOM_RIGHT, Vector2(-420, -30), Color(0.4, 0.75, 1.0))
	_log = _label(root, Control.PRESET_TOP_LEFT, Vector2(20, 20), 16, HORIZONTAL_ALIGNMENT_LEFT)
	_prompt = _label(root, Control.PRESET_CENTER, Vector2(-200, 40), 20, HORIZONTAL_ALIGNMENT_CENTER)
	_help = _label(root, Control.PRESET_BOTTOM_LEFT, Vector2(20, -90), 15, HORIZONTAL_ALIGNMENT_LEFT)
	_help.text = HELP
	_banner = _label(root, Control.PRESET_CENTER_TOP, Vector2(-300, 60), 28, HORIZONTAL_ALIGNMENT_CENTER)
	_fps = _label(root, Control.PRESET_TOP_RIGHT, Vector2(-160, 10), 14, HORIZONTAL_ALIGNMENT_RIGHT)
	weapon.state_changed.connect(_refresh)
	weapon.hit_reported.connect(_on_hit)
	_refresh()


func _label(parent: Control, preset: int, offset: Vector2, font_size: int, align: HorizontalAlignment) -> Label:
	var l := Label.new()
	l.set_anchors_preset(preset)
	l.position += offset
	l.size = Vector2(400, 40) if align != HORIZONTAL_ALIGNMENT_LEFT else Vector2(900, 40)
	l.horizontal_alignment = align
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", Color(0.92, 0.9, 0.82))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


func _bar(parent: Control, preset: int, offset: Vector2, colour: Color) -> ProgressBar:
	var b := ProgressBar.new()
	b.set_anchors_preset(preset)
	b.position += offset
	b.size = Vector2(400, 12)
	b.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = colour
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.45)
	b.add_theme_stylebox_override("fill", fill)
	b.add_theme_stylebox_override("background", bg)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(b)
	return b


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_help"):
		_help.visible = not _help.visible
	elif event.is_action_pressed("toggle_dot"):
		_dot.visible = not _dot.visible


func _process(delta: float) -> void:
	var target: Node = player.get("interact_target")
	_prompt.text = "[F] " + target.call("get_prompt") if target and target.has_method("get_prompt") else ""
	_dot.modulate.a = 1.0 - float(weapon.get("ads"))
	_fps.text = "%d FPS" % Engine.get_frames_per_second()
	if _banner_time > 0.0:
		_banner_time -= delta
		if _banner_time <= 0.0:
			_banner.text = ""


func _refresh() -> void:
	var name := String(weapon.weapon_id).replace("_", " ").capitalize()
	var placeholder := "" if weapon.weapon_id == "lasgun" else "  (lasgun model)"
	_weapon_label.text = "%s · %s%s%s" % [name, weapon.fire_mode().to_upper(),
		"  · RELOADING" if weapon.reloading else "", placeholder]
	_ammo.text = "%d  |  %s" % [weapon.magazine, "∞" if weapon.infinite_ammo else str(weapon.reserve)]
	_mag_bar.max_value = float(weapon.stats.get("magazine", 30))
	_mag_bar.value = weapon.magazine
	_heat.visible = weapon.weapon_id == "plasma_gun"
	_heat.value = weapon.heat
	if weapon.overheat_lockout > 0.0:
		_weapon_label.text += "  · OVERHEATED %.1fs" % weapon.overheat_lockout


func _on_hit(r: Dictionary) -> void:
	match r.get("event", ""):
		"catastrophic":
			_show_banner("CATASTROPHIC PLASMA FAILURE — you would be dead (GDD 7.4)")
			return
		"overheat":
			_show_banner("Plasma overheat: %d damage to you, 5 s lockout" % int(r.damage))
			return
		"vent":
			_show_banner("Plasma vented (would cost 10 health)")
			return
	var parts := "%s → %s [%s]: %d dmg" % [String(r.weapon).capitalize(), r.target, r.location, roundi(r.damage)]
	parts += "  = pen %d vs armour %d ×%.1f" % [r.pen, r.armour, r.pen_mult]
	if r.reduction > 0.0:
		parts += ", armour −%d%%" % roundi(r.reduction * 100.0)
	if r.location_mult != 1.0:
		parts += ", %s ×%.1f" % [String(r.location).to_lower(), r.location_mult]
	if r.range_mult != 1.0:
		parts += ", range %dm ×%.2f" % [roundi(r.distance), r.range_mult]
	if r.killed:
		parts += "  ✝ DOWN"
	_lines.push_front(parts)
	_lines = _lines.slice(0, 8)
	_log.text = "\n".join(_lines)


func _show_banner(text: String) -> void:
	_banner.text = text
	_banner_time = 3.0
