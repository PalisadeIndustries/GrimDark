extends SceneTree
## Headless test runner. Runs every res://tests/test_*.gd file and exits non-zero on failure.
## Usage: godot --headless --path game -s res://tests/run_tests.gd

const TEST_DIR := "res://tests/"


func _init() -> void:
	var total := 0
	var failed: Array[String] = []
	for file in DirAccess.get_files_at(TEST_DIR):
		if not (file.begins_with("test_") and file.ends_with(".gd")) or file == "test_case.gd":
			continue
		var script: GDScript = load(TEST_DIR + file)
		for method in script.get_script_method_list():
			var name: String = method["name"]
			if not name.begins_with("test_"):
				continue
			var instance: TestCase = script.new()
			instance.current_test = "%s::%s" % [file, name]
			instance.call(name)
			total += 1
			if instance.failures.is_empty():
				print("  PASS ", instance.current_test)
			else:
				for failure in instance.failures:
					print("  FAIL ", failure)
				failed.append(instance.current_test)
	print("\n%d tests, %d failed" % [total, failed.size()])
	quit(1 if failed.size() > 0 or total == 0 else 0)
