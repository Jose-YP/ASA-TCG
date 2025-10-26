##Responcible for comparing two counters together
@icon("res://Art/ProjectSpecific/car.png")
extends Resource
class_name Comparator

##[enum Return] Return the result of the first counter only[br]
##[enum Return] Return the result of the first minus the second counter[br]
##[enum Equals] Return a boolean if the first counter equals the second[br]
##[enum Not Equal] Return a boolean if the first counter doesn't equal the second[br]
##[enum Greater] Return a boolean if the first counter is greater than the second[br]
##[enum Lesser] Return a boolean if the first counter is lesser than the second[br]
@export_enum("Return", "Difference", "Equals", "Not Equal",
 "Greater", "Lesser") var comparision_type: String = "Return"

@export var first_comparison: IndvCounter
@export_enum("None", "Const", "Second") var compare_to: String = "None"
@export_group("Compare To Vars")
@export var second_constant: int = 0
@export var second_counter: IndvCounter
##Only usable with [member second_counter] while [member compare_to] is set to [enum Second]
##[br] Tip: When working with damage counters here use multiples of 10
@export_enum("None", "Plus", "Mult") var operate_w_constant: String = "None"

func start_comparision() -> Variant:
	var first_return: int = first_comparison.evaluate()
	match compare_to:
		"None":
			return first_return
		"Const":
			printt("CONST CHECK:", first_return, get_symbol(), second_constant)
			return make_comparision(first_return, second_constant)
		"Second":
			var second_return: int = second_arithmetic(second_counter.evaluate())
			printt("DUAL COUNTER CHECK:",first_return, get_symbol(), second_return)
			return make_comparision(first_return, second_return)
	return false

func input_comparison() -> Variant:
	var first_return: int = await first_comparison.input_evaluation()
	match compare_to:
		"None":
			return first_return
		"Const":
			printt("CONST CHECK:", first_return, get_symbol(), second_constant)
			return make_comparision(first_return, second_constant)
		"Second":
			printt("DUAL COUNTER CHECK:")
			var second: int = await second_counter.input_evaluation()
			second_arithmetic(second)
			
			return make_comparision(first_return, second)
	return false

func make_comparision(first: int, second: int) -> Variant:
	match comparision_type:
		"Return": return "How did I get here?"
		"Difference": return first - second
		"Equals": return first == second
		"Not Equal": return first != second
		"Greater": return first > second
		"Lesser": return first < second
	return ":("

func second_arithmetic(second: int):
	match operate_w_constant:
		"Plus":
			second += second_constant
		"Mult":
			second *= second_constant
	return second

func has_coinflip() -> bool:
	var result: bool = first_comparison.has_coinflip()
	if second_counter:
		result = result or second_counter.has_coinflip()
	return result

func has_input() -> bool:
	var result: bool = first_comparison.has_input()
	if second_counter:
		result = result or second_counter.has_input()
	return result

func get_symbol() -> String:
	match comparision_type:
		"Return": return "How did I get here?"
		"Difference": return "-"
		"Equals": return "=="
		"Not Equal": return "!="
		"Greater": return ">"
		"Lesser": return "<"
	return ":("
