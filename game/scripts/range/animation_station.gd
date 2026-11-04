extends Node3D
## Plays humanoid animations on the traitor guard. Drop animations into res://assets/animations/
## (any .glb/.fbx imported with a humanoid BoneMap, or .res/.tres AnimationLibrary files) and
## they appear here. Interact to cycle through them.

const ANIM_DIR := "res://assets/animations/"

var player: AnimationPlayer
var names: Array[String] = []
var index := -1
var _label: Label3D


func _ready() -> void:
	_label = Label3D.new()
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.position = Vector3(0, 2.4, 0)
	_label.font_size = 48
	_label.pixel_size = 0.004
	_label.outline_size = 12
	add_child(_label)
	var scene := load("res://assets/characters/traitor_guard/traitor_guard_1.glb") as PackedScene
	if scene == null:
		_label.text = "Animation Station\nTraitor guard model missing (see README)"
		return
	var model: Node3D = scene.instantiate()
	add_child(model)
	player = AnimationPlayer.new()
	model.add_child(player)
	player.root_node = player.get_path_to(model)
	_load_libraries()
	_update_label()


func _load_libraries() -> void:
	var dir := DirAccess.open(ANIM_DIR)
	if dir == null:
		return
	for file in dir.get_files():
		var path := ANIM_DIR + file.trim_suffix(".import").trim_suffix(".remap")
		if file.ends_with(".import") or not (path.ends_with(".glb") or path.ends_with(".gltf") or path.ends_with(".fbx") or path.ends_with(".res") or path.ends_with(".tres")):
			continue
		if names.size() > 0 and path in names:
			continue
		var res := load(path)
		var libraries: Array = []
		if res is AnimationLibrary:
			libraries.append([file.get_basename(), res])
		elif res is PackedScene:
			var inst: Node = res.instantiate()
			for ap in inst.find_children("*", "AnimationPlayer", true, false):
				for lib_name in (ap as AnimationPlayer).get_animation_library_list():
					libraries.append([file.get_basename() + ("_" + lib_name if lib_name != "" else ""), ap.get_animation_library(lib_name)])
			inst.free()
		for entry in libraries:
			var lib_name: String = String(entry[0]).validate_node_name()
			if not player.has_animation_library(lib_name):
				player.add_animation_library(lib_name, entry[1])
				for anim in (entry[1] as AnimationLibrary).get_animation_list():
					names.append(lib_name + "/" + anim)


func interact(_by: Node = null) -> void:
	if player == null or names.is_empty():
		return
	index = (index + 1) % names.size()
	var anim := player.get_animation(names[index])
	anim.loop_mode = Animation.LOOP_LINEAR
	player.play(names[index])
	_update_label()


func get_prompt() -> String:
	if names.is_empty():
		return "No animations yet: drop humanoid animations into assets/animations/"
	return "Next animation (%d/%d)" % [index + 2 if index + 1 < names.size() else 1, names.size()]


func _update_label() -> void:
	if names.is_empty():
		_label.text = "Animation Station\nDrop humanoid animations into\nres://assets/animations/"
	elif index == -1:
		_label.text = "Animation Station\n%d animations · press F" % names.size()
	else:
		_label.text = "Animation Station\n%s" % names[index]
