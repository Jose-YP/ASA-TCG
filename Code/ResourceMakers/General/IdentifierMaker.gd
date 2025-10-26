@tool
@icon("uid://bbeug7tffn308")
##Responcible for filtering cards regardless of if they're being played or not
extends Resource
class_name Identifier

#var cardRes = preload("uid://boj1daeegynsi")

#var internal_data = {"card_vars" : {}}

#Plan is to use get_property_list to make a resource that updates with card complexity
#Not necessary though, we can just use a ton of exports

func identifier_bool(card: Card, based_on: Array[Slot] = []) -> bool:
	##Not final at all
	for slot in based_on:
		if slot.current_card == card:
			return true
	return false
