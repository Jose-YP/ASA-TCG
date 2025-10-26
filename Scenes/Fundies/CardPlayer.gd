@icon("res://Art/ProjSpecific/drag-and-drop.png")
##Manages any actions on slots after declaring actions or playing cards
extends Node
class_name CardPlayer

@onready var ui_act = $UIActions

signal chosen

var hold_candidate: Slot
var hold_playing: Card

func _ready() -> void:
	SigBus.get_candidate.connect(record_candidate)

#--------------------------------------
#region MANAGING CARD PLAY

#endregion
#--------------------------------------

#--------------------------------------
#region CHOICE MANAGEMENT
func start_add_choice(instruction: String, card: Card, play_as: int,
 bool_fun: Callable, reversable: bool):
	ui_act.set_adding_card(card)
	set_reversable(reversable)
	hold_playing = card
	hold_candidate = null
	await generic_choice(instruction, bool_fun)
	
	if ui_act.selected_slot:
		var went_back: bool = false
		if card.has_before_prompt() and not Convert.playing_as_pokemon(play_as):
			SigBus.record_src_trg.emit(ui_act.selected_slot)
			went_back = await card.play_before_prompt()
			SigBus.remove_src_trg.emit()
		
		if not went_back:
			hold_candidate.use_card(card, play_as, reversable)
			print("Attatch ", card.name)
		
		else: print("I changed my mind")
	else:
		print("Nevermind")
	hold_playing = null

func get_choice_candidates(instruction: String, bool_fun: Callable, reversable: bool,
 _choosing_player: Consts.PLAYER_TYPES = Consts.PLAYER_TYPES.PLAYER) -> Slot:
	set_reversable(reversable)
	hold_candidate = null
	await generic_choice(instruction, bool_fun)
	if hold_candidate:
		print("We'll choose ", hold_candidate.get_card_name())
		chosen.emit()
		return hold_candidate
	else:
		print("Nevermind")
		SigBus.went_back.emit()
		return null

func generic_choice(instruction: String, bool_fun: Callable,\
 _choosing_player: Consts.PLAYER_TYPES = Consts.PLAYER_TYPES.PLAYER):
	ui_act.get_allowed_slots(bool_fun)
	
	var allow_slots: Array[UI_Slot] = ui_act.allowed_slots
	#If there's only one choice and there's no going back, make the choice instantly
	if allow_slots.size() == 0:
		return
	elif allow_slots.size() == 1 and not ui_act.can_reverse:
		ui_act.choosing = true
		ui_act.left_button_actions(allow_slots[0].connected_slot)
	#Otherwise wait for player to choose
	else:
		await ui_act.get_choice(instruction)
		await ui_act.chosen
	
	chosen.emit()

func record_candidate(slot: Slot):
	hold_candidate = slot

func set_reversable(reversable: bool):
	ui_act.can_reverse = reversable
#endregion
#--------------------------------------
