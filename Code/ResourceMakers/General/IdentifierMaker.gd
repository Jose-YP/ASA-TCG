@icon("uid://bbeug7tffn308")
##Responcible for filtering cards regardless of if they're being played or not
##Major overhaul for this new project
extends Resource
class_name Identifier

enum COMP {GREATER, LESSER, EQUAL, NOT_EQ}

@export var comparisions: Dictionary[COMP, IdentifierDict] = {}

#Plan is to use get_property_list to make a resource that updates with card complexity
#Not necessary though, we can just use a ton of exports

#Goal, it'll be a dictionary of dictionaries first one is based on comparision type
#Within those dictionaries will be the properties to check and what they'll be compared against

func identifier_bool(card: Card, based_on: Array[Slot] = []) -> bool:
	##Not final at all
	for slot in based_on:
		if slot.current_card == card:
			return true
	return false
