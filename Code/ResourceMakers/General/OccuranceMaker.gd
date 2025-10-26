@tool
##Responcible for creating reactions to slot signals
extends Resource
class_name Occurance

const slotRes = preload("uid://bpgutxrd01458")

signal occur

var slot_instance = Slot.new()
var internal_data = { "signal": "checked_up",
 "from_ask" : null,
 "must_be_ask": null,
 "card_type" : null,
}

var owner: Slot
#--------------------------------------
func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	var signal_array_names: PackedStringArray = []
	var res_signal_list = ClassDB.class_get_signal_list("Resource")
	
	#Collect the name of every property that's in a poke_slot
	#Will not include any non-export variables
	for s in slot_instance.get_signal_list():
		if (not s in res_signal_list):
			signal_array_names.append(s.name)
	
	props.append({
		"name" : "from_ask",
		"type" : TYPE_OBJECT,
		"hint" : PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string" : "Ask",
		"usage" : PROPERTY_USAGE_DEFAULT
	})
	#Append their names into an enum to select from
	props.append({
		"name" : "signal",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : ",".join(signal_array_names),
		"usage" : PROPERTY_USAGE_DEFAULT
	})
	
	return props
#--------------------------------------

#--------------------------------------
#region GET FUNCTIONS
func _get(property):
	match property:
		"from_ask": return internal_data["from_ask"] as Ask
		"signal": return internal_data["signal"]
		"must_be_ask": return internal_data["must_be_ask"] as Ask
		"card_type": return internal_data["card_type"] as Identifier
	return null

func _property_can_revert(property: StringName):
	if (property == "from_ask" or property == "signal"
	or property == "must_be_ask" or property == "card_type"):
		return true
	return false

func _property_get_revert(property: StringName) -> Variant:
	match property: 
		"signal": return "checked_up"
	return null
#endregion
#--------------------------------------

#--------------------------------------
func _set(property, value):
	match property:
		"signal":
			internal_data["signal"] = value
			notify_property_list_changed()
			return true
		"from_ask": 
			if not value is Ask:
				return false
			internal_data["from_ask"] = value as Ask
			return true
		"must_be_ask":
			internal_data["must_be_ask"] = value
			return true
		"card_type":
			internal_data["card_type"] = value
			return true
	return false
#--------------------------------------

#--------------------------------------
#region SIGNAL FUNCTIONS
func connect_occurance():
	var slots: Array[Slot]
	
	for slot in slots:
		if not connected_to_this(slot):
			slot.connect(_get("signal"), should_occur)

func disconnect_occurance():
	var slots: Array[Slot]
	
	for slot in slots:
		if slot.get(_get("signal")).has_connections():
			slot.disconnect(_get("signal"), should_occur)

func single_connect(slot: Slot):
	if not connected_to_this(slot) and _get("from_ask").check_ask(slot):
		slot.connect(_get("signal"), should_occur)

func single_disconnect(slot: Slot):
	if slot.get(_get("signal")).has_connections() and _get("from_ask").check_ask(slot):
		slot.disconnect(_get("signal"), should_occur)

func should_occur(param: Variant = null):
	if param is String and param == "CheckingMultiples":
		return owner
	elif is_allowed(param):
		occur.emit()
		return

func is_allowed(param: Variant = null):
	if param is Slot:
		return _get("must_be_ask").check_ask(param)
	else:
		return true

func connected_to_this(slot: Slot) -> bool:
	for connection in slot.get(_get("signal")).get_connections():
		if connection["callable"] == should_occur:
			return true
	return false

#endregion
#--------------------------------------
