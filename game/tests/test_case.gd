class_name TestCase
extends RefCounted
## Minimal test base class. Test methods start with "test_".

var failures: Array[String] = []
var current_test := ""


func assert_true(condition: bool, message: String = "") -> void:
	if not condition:
		failures.append("%s: expected true. %s" % [current_test, message])


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s. %s" % [current_test, str(expected), str(actual), message])


func assert_near(actual: float, expected: float, tolerance: float = 0.0001, message: String = "") -> void:
	if absf(actual - expected) > tolerance:
		failures.append("%s: expected %s, got %s. %s" % [current_test, str(expected), str(actual), message])
