@tool
extends Control
class_name CardSideUI

##Not really a tool for functionality there's justa bug right now
##@tutorial https://github.com/godotengine/godot/commit/2d8f6c1b1d984222d1690f8afd504faed9f303be
##@tutorial https://stackoverflow.com/questions/79569605/my-godot-tool-script-produces-attempt-to-call-a-method-on-a-placeholder-instanc
@export var player_type: Consts.PLAYER_TYPES = Consts.PLAYER_TYPES.PLAYER
@export var home: bool = true

@onready var ui_slots: Array[Node] = %CurrentActive.get_children() + %Benches.get_children()
#$Main/Bench/BenchPokemon2, $Main/Bench/BenchPokemon3, $Main/Bench/BenchPokemon4, $Main/Bench/BenchPokemon5]
@onready var etc_display: ETC_Display = %ETC

func print_status():
	#------------------------------
	# [Active]
	# [Bench]
	#------------------------------
	const line: String = "---------------------------------------------"
	var status: String
	var active: String
	var benched: String
	var stack_status: String
	for slot in get_slots():
		var mon_name: String
		if slot.connected_slot.is_filled():
			mon_name = slot.connected_slot.current_card.name 
		if slot.active:
			active = str(active, " [", mon_name ,"]")
		else:
			benched = str(benched, " [", mon_name ,"]")
	
	stack_status = etc_display.print_stack_numbers()
	
	if home:
		status = str("HOME STATUS
		",line,"
		", stack_status,"
		", active, "
		", benched, "
		", line)
	else:
		status = str("AWAY STATUS
		",line,"
		", stack_status,"
		", benched, "
		",  active,"
		", line)
	
	print(status)

func get_slots() -> Array[UI_Slot]:
	var arr: Array[UI_Slot]
	for slot in %CurrentActive.get_children():
		arr.append(slot as UI_Slot)
	for slot in %Benches.get_children():
		arr.append(slot as UI_Slot)
	return arr

func is_side(side: Consts.SIDES):
	match side:
		Consts.SIDES.BOTH:
			return true
		Consts.SIDES.ATTACKING:
			return  home == Glob.fundies.home_turn
		Consts.SIDES.DEFENDING:
			return home != Glob.fundies.home_turn
		Consts.SIDES.SOURCE:
			return home == Glob.fundies.source_stack[-1]
		Consts.SIDES.OTHER:
			return home != Glob.fundies.source_stack[-1]
	
	return false

func insert_slot(slot: Slot, predefined: bool = false):
	if predefined or slot.is_active():
		for ui_slot in %CurrentActive.get_children():
			if not ui_slot.connected_slot.is_filled():
				ui_slot.attatch_pokeslot(slot, true)
				return
	else:
		for ui_slot in %Benches.get_children():
			if not ui_slot.connected_slot.is_filled():
				ui_slot.attatch_pokeslot(slot, true)
				return

func supporter_played() -> bool:
	return etc_display.current_supporter != null
