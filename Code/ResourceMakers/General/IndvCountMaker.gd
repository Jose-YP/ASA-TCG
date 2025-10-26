@tool
##Responcible for counting the number of anything on the board
extends Resource
class_name IndvCounter

#--------------------------------------
#region VARIABLES
#script constants
const slotRes = preload("uid://boj1daeegynsi")
const stackRes = preload("uid://bb7mp0deiaycd")
const which_vars: PackedStringArray = ["Slot", "CardStack", "Input"]

var slot_instance = Slot.new()
var stack_instance = stackRes.new()
var internal_data = {"which" : "Slot",
 "slot_vars" : "current_card", "stack_vars" : "None" 
 ,"input_title" : "Input Number" ,"cap" : -1}
#endregion
#--------------------------------------

#--------------------------------------
func _get_property_list() -> Array[Dictionary]:
	#region GATHERINFO
	var props: Array[Dictionary] = []
	var slot_array_names: PackedStringArray = []
	var stack_array_names: PackedStringArray = ["None"]
	var res_prop_list = ClassDB.class_get_property_list("Resource")
	#Collect the name of every property that's in a poke_slot
	#Will not include any non-export variables
	for p in slot_instance.get_property_list():
		if (p.has("usage") and p.usage & PROPERTY_USAGE_DEFAULT
		 and p.name not in slot_array_names and not p in res_prop_list):
			slot_array_names.append(p.name)
		#else:
			#print(p.name, p.has("usage"), p.usage ,p.usage & PROPERTY_USAGE_DEFAULT,
			#p.name not in slot_array_names, not p in res_prop_list)
	
	#Only get the variables that are defined as variables without exports
	#These are the stacks that get used during play
	for p in stackRes.new().get_property_list():
		if (p.has("usage") and p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and
		 not p.usage & PROPERTY_USAGE_DEFAULT and p.name not in stack_array_names):
			stack_array_names.append(p.name)
	#endregion
	
	#region ESTABLISH PROPERTIES
	props.append({
		"name" : "which",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : ",".join(which_vars),
		"usage" : PROPERTY_USAGE_DEFAULT
	})
	if _get("which") != "Input":
		#I'll always need ask for at least defining side to check
		props.append({
				"name" : "ask",
				"type" : TYPE_OBJECT,
				"hint" : PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string" : "Ask",
				"usage" : PROPERTY_USAGE_DEFAULT
		})
	#Find slot_vars
	if _get("which") == "Slot":
		#Append their names into an enum to select from
		props.append({
			"name" : "slot_vars",
			"type" : TYPE_STRING,
			"hint" : PROPERTY_HINT_ENUM,
			"hint_string" : ",".join(slot_array_names),
			"usage" : PROPERTY_USAGE_DEFAULT
			})
	
	#Find CardStack vars
	elif _get("which") == "CardStack":
		props.append({
			"name" : "stack_vars",
			"type" : TYPE_STRING,
			"hint" : PROPERTY_HINT_ENUM,
			"hint_string" : ",".join(stack_array_names),
			"usage" : PROPERTY_USAGE_DEFAULT
		})
		props.append({
				"name" : "identifier",
				"type" : TYPE_OBJECT,
				"hint" : PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string" : "Identifier",
				"usage" : PROPERTY_USAGE_DEFAULT
		})
		props.append({
			"name" : "stack_portion",
			"type" : TYPE_INT,
			"usage" : PROPERTY_USAGE_DEFAULT
		})
	
	elif _get("which") == "Input":
		props.append({
				"name" : "input_title",
				"type" : TYPE_STRING,
				"usage" : PROPERTY_USAGE_DEFAULT
		})
		
	
	props.append({
		"name" : "cap",
		"type" : TYPE_INT,
		"usage" : PROPERTY_USAGE_DEFAULT
	})
	#endregion
	
	return props
#--------------------------------------

#--------------------------------------
#region GET FUNCTIONS
func _get(property):
	if internal_data == null:
		internal_data = _property_get_revert("internal_data")
		return null
	elif not internal_data.has(property) and _property_can_revert(property):
		internal_data[property] = _property_get_revert(property)
	
	match property:
		"which": return internal_data["which"]
		"slot_vars": return internal_data["slot_vars"]
		"stack_vars": return internal_data["stack_vars"]
		"ask": return internal_data["ask"] as Ask
		"identifier": return internal_data["identifier"] as Identifier
		"stack_portion": return internal_data["stack_portion"]
		"input_title": return internal_data["input_title"]
		"cap": return internal_data["cap"]
	
	return null

func _property_can_revert(property: StringName):
	if (property == "which" or property == "slot_vars" or property == "stack_vars"
	 or property == "ask" or property == "identifier" or property == "stack_portion"
	 or property == "input_title" or property == "cap"):
		return true
	return false

func _property_get_revert(property: StringName) -> Variant:
	match property: 
		"which": return "Slot"
		"slot_vars": return "current_card"
		"stack_vars": return "None"
		"ask": return load("uid://bns8h72u2hxqo") as Ask
		"identifier": return load("uid://dm2i7spst0qpp") as Identifier
		"stack_portion": return -1
		"input_title": return "Input Number"
		"cap": return -1
		"internal_data": return {"which" : "Slot",
		 "slot_vars" : "current_card", "stack_vars" : "None",
		 "ask" : load("uid://bns8h72u2hxqo") as Ask, "identifier": null,
		 "stack_portion" : -1, "input_title" : "Input Number" ,"cap" : -1}
	return null
#endregion
#--------------------------------------

#--------------------------------------
func _set(property, value):
	match property:
		"which":
			internal_data["which"] = value
			notify_property_list_changed()
			return true
		"slot_vars": 
			internal_data["slot_vars"] = value
			notify_property_list_changed()
			return true
		"stack_vars": 
			internal_data["stack_vars"] = value
			return true
		"ask": 
			if not value is Ask:
				return false
			internal_data["ask"] = value as Ask
			return true
		"identifier":
			if not value is Identifier:
				return false
			internal_data["identifier"] = value as Identifier
			return true
		"stack_portion":
			internal_data["stack_portion"] = value
			return true
		"input_title":
			internal_data["input_title"] = value
			return true
		"cap": 
			internal_data["cap"] = value
			return true
	
	return false
#--------------------------------------

#--------------------------------------
#region EVALUATION
##Non await evaluations go here
func evaluate() -> int:
	var result: int = 0
	
	match _get("which"):
		"Slot":
			result = slot_evaluation(_get("slot_vars"), _get("ask"))
		"CardStack":
			result = stack_evaluation(_get("stack_vars"), _get("ask"))
	if _get("cap") != -1:
		result = clamp(result, 0, _get("cap"))
	
	return result

func slot_evaluation(slot_data: String, ask_data: Ask) -> int:
	var result: int = 0
	var slots: Array[Slot]
	var filtered_slots: Array[Slot] = []
	for slot in slots:
		if ask_data.check_ask(slot):
			filtered_slots.append(slot)
	#For now .filter doesn't work here so.....
	#print("a:", poke_slots.filter(func (slot: Slot): not ask_data.check_ask(slot)))
	#print("B:", poke_slots.filter(func (slot: Slot): ask_data.check_ask(slot)))
	
	for slot in filtered_slots:
		#print(slot, slot.get(slot_data))
		var data = slot.get(slot_data)
		if data is Array:
			result += data.size()
		#This is here for counting number of pokemon as it will use current_card instead of an int
		elif not data is int and data != null:
			result += 1
		else:
			result += slot.get(slot_data)
	
	return result

func stack_evaluation(stack_data: String, ask_data: Ask) -> int:
	if ask_data.side_target == Consts.SIDES.BOTH:
		#Once stack locations are established replace these
		var atk_stack: CardStack = Glob.fundies.stack_manager.get_stacks(true)
		var def_stack: CardStack = Glob.fundies.stack_manager.get_stacks(false)
		
		var atk_num: int = identifier_count(atk_stack.get(stack_data), _get("identifier"))\
			if _get("identifier") else atk_stack.get(stack_data).size()
		var def_num: int = identifier_count(def_stack.get(stack_data), _get("identifier"))\
			if _get("identifier") else def_stack.get(stack_data).size()
		
		return atk_num + def_num
	else:
		var stacks: CardStack = Glob.fundies.stack_manager.get_stacks(\
			Glob.fundies.get_considered_home(ask_data.side_target))
		
		return identifier_count(stacks.get(stack_data), _get("identifier"))\
		 if _get("identifier") else stacks.get(stack_data).size()

func identifier_count(stack: Array[Card], identifier: Identifier) -> int:
	var num: int = 0
	var using: Array[Card] = stack
	if _get("stack_portion") != -1:
		using = stack.slice(0,_get("portion"))
	
	for card in using:
		if identifier.identifier_bool(card):
			num += 1
	
	print("Found ", num, " for stack identifer count")
	return num

func input_evaluation() -> int:
	var input_return: int = 0
	var input_box: Control = Consts.input_box.instantiate()
	
	input_box.title = _get("input_title")
	input_box.cap = _get("cap")
	
	#Place it on full_ui here
	
	await input_box.finished
	input_return = int(input_box.spin_box.value)
	
	print("INPUT: ", input_return)
	return input_return

#endregion
#--------------------------------------

func has_coinflip() -> bool:
	return _get("which") == "Coinflip"

func has_input() -> bool:
	return _get("which") == "Input"
