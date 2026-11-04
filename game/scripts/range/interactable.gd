extends StaticBody3D
## Something the player can use with the interact key. Calls `method` on `target`.

@export var prompt := "Use"
@export var target_path: NodePath
@export var method := "interact"

var target: Node


func _ready() -> void:
	if target == null and not target_path.is_empty():
		target = get_node(target_path)


func interact(player: Node) -> void:
	if target and target.has_method(method):
		if target.get_method_argument_count(method) > 0:
			target.call(method, player)
		else:
			target.call(method)


func get_prompt() -> String:
	if target and target.has_method("get_prompt"):
		return target.get_prompt()
	return prompt
