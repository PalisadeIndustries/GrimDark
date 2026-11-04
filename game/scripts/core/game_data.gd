extends Node
## Loads the balance tables in res://data/ (GDD 20.2). Autoloaded as GameData.

const DATA_DIR := "res://data/"
const TABLES: Array[String] = ["armour", "weapons", "progression", "call_ins", "platoon"]

var tables: Dictionary = {}


func _init() -> void:
	load_all()


func load_all() -> void:
	tables.clear()
	for table_name in TABLES:
		tables[table_name] = load_table(table_name)


static func load_table(table_name: String) -> Dictionary:
	var path := DATA_DIR + table_name + ".json"
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_error("GameData: could not read %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		return parsed
	push_error("GameData: %s is not a JSON object" % path)
	return {}


func table(table_name: String) -> Dictionary:
	return tables.get(table_name, {})


func tiers() -> Array:
	return table("progression").get("tiers", [])


func armour_value(armour_class: String) -> int:
	return int(table("armour")["classes"].get(armour_class, 0))
