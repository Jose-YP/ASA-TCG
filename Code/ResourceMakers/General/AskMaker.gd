##Responcible for filtering out active Slot resources
@icon("uid://bbeug7tffn308")
extends Resource
class_name Ask

#--------------------------------------
#region VARIABLES
##Should it pass every requirement or at least one?[br]
##Note. Or only begins with the requirements that are in groups
@export_enum("And", "Or") var boolean_type: String = "And"
##Check the last source target stack for whatever they have
@export var previous_src_trg: bool = false
##Which side to pay attention to
@export var side_target: Consts.SIDES = Consts.SIDES.BOTH
@export var slot_target: Consts.SLOTS = Consts.SLOTS.ALL
@export var specifically: Array[String] = []

#endregion
#--------------------------------------

func ask_bool() -> bool:
	return true
