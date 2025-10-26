@icon("res://Art/ProjectSpecific/trading.png")
extends Node
class_name SlotUIActions

#--------------------------------------
#region VARIABLES
@export var preload_debug: bool = false
@export var cancel_txt: String = "Esc to go back"
@export var no_return_txt: String = "No going back"
@export var ability_ani_offset: Vector2
@export var ability_ani_time: float = 1
@export var color_tween_timing: float = .1

signal chosen
signal choice_ready

var adding_card: Card = null
var selected_slot: Slot = null
var allowed_slots: Array[UI_Slot]
var act_on_self: bool = true
var choosing: bool = false
var can_reverse: bool = false

#endregion
#--------------------------------------
func _ready():
	SigBus.connect("chosen_slot", left_button_actions)

#--------------------------------------
#region HELPER FUNCTIONS
func set_adding_card(for_card: Card) -> void:
	adding_card = for_card

#endregion
#--------------------------------------

#--------------------------------------
#region INPUTS
func left_button_actions(target: Slot):
	if choosing:
		if adding_card:
			selected_slot = target
			Glob.fundies.card_player.record_candidate(target)
			adding_card = null
		else:
			SigBus.get_candidate.emit(target)
		
		#target.refresh()
		reset_ui()

func _input(event: InputEvent) -> void:
	if event.is_action("Back") and can_reverse:
		reset_ui()

func get_choice(instruction: String):
	%AskInstructions.show()
	%Instructions.clear()
	%Instructions.append_text(str("[center]",instruction))
	%CancelText.clear()
	%CancelText.append_text(cancel_txt if can_reverse else no_return_txt)
	await color_tween(Color.WHITE)
	
	choosing = true
	for slot in allowed_slots:
		slot.switch_shine(true)

#endregion
#--------------------------------------

#--------------------------------------
#region CHOICE MANAGEMENT
#Use a lambda function to get different boolean functions
func get_allowed_slots(condition: Callable) -> void:
	allowed_slots = Glob.fundies.find_allowed_slots(condition, Consts.SIDES.BOTH)
	
	for slot in Glob.full_ui.every_slot:
		if slot in allowed_slots:
			slot.z_index = 1
			slot.make_allowed(true)
		else:
			slot.z_index = 0
			slot.make_allowed(false)

func color_tween(destination: Color):
	var color_tweener: Tween = create_tween().set_parallel()
	color_tweener.tween_property($ColorRect, "modulate", destination, color_tween_timing)
	await color_tweener.finished
	choice_ready.emit()

func reset_ui():
	%AskInstructions.hide()
	#Check every previously allowed slot
	#Reset them to look and display like the rest
	for ui_slot in allowed_slots:
		ui_slot.z_index = 0
		ui_slot.switch_shine(false)
	
	#Check every slot to see if they have a pokemon in them
	#If so, let them be checked again
	for slot in Glob.full_ui.every_slot:
		slot.make_allowed(slot.connected_slot.is_filled())
	
	choosing = false
	can_reverse = false
	await color_tween(Color.TRANSPARENT)
	chosen.emit()

#endregion
#--------------------------------------
