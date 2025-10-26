@tool
extends Resource
class_name IdentifierDict

var card_instance = Card.new()
var internal_data: Dictionary[String, Variant] = {
	"Comparision" : {}
}

#I'll try and compress these two resources into one later
#This is a very new resource so bear with me
#--------------------------------------
func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	var card_prop_names: Array[String]
	var res_prop_list = ClassDB.class_get_property_list("Resource")
	var enum_hint_string: String
	
	for p in card_instance.get_property_list(): #only properties unqiue to cards
		if (p.has("usage") and p.usage & PROPERTY_USAGE_DEFAULT
		 and not p in res_prop_list):
			card_prop_names.append(p.name)
	
	enum_hint_string = ",".join(card_prop_names)
	
	props.append({
		"name": "Comparision",
		"type" : TYPE_DICTIONARY,
		"hint" : PROPERTY_HINT_DICTIONARY_TYPE,
		"hint_string" : "%d/%d:%s;String" % [TYPE_STRING, PROPERTY_HINT_ENUM, enum_hint_string],
		"usage" : PROPERTY_USAGE_DEFAULT
	})
	
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
	
	if property == "Comparision":
		return internal_data["Comparision"]
	return null

func _property_can_revert(property: StringName) -> bool:
	return property in internal_data

func _property_get_revert(_property: StringName) -> Variant:
	return {}
#endregion
#--------------------------------------

#--------------------------------------
func _set(property, value):
	match property:
		"Comparision":
			internal_data["Comparision"] = value
			return true
		"Variant":
			internal_data["Variant"] = value
			return true
	
	return false
#--------------------------------------
