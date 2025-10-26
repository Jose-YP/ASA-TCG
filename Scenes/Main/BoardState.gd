@icon("res://Art/ProjectSpecific/alpha.png")
extends Control
class_name BoardNode

#For easy access: PokeSlot
@export_enum("None", "Fail", "Success", "All") var debug_prompt: int = 0
@export var board_state: BoardState
@export var test: PackedScene

@onready var full_ui: FullBoardUI = $FullUI
@onready var fundies: Fundies = $FullUI/Fundies
var test_out: bool = false

func _ready() -> void:
	full_ui.home_side = board_state.home_side
	Glob.board_state = board_state
	
	board_state.duplicate_sides()
	set_up_stacks(true)
	set_up_stacks(false)
	set_up_slots(true)
	set_up_slots(false)
	
	fundies.current_turn_print()

func set_up_stacks(home: bool):
	var temp_side: SideState = board_state.get_side(home)
	var ui: CardSideUI = full_ui.get_home_side(home)
	var player_type: Consts.PLAYER_TYPES = board_state.get_player_type(home)
	var stacks: CardStack = temp_side.card_stacks
	
	Glob.board_state = board_state
	
	ui.player_type = player_type
	if player_type == Consts.PLAYER_TYPES.CPU:
		var adding_cpu = Consts.cpu_scene.instantiate()
		adding_cpu.home_side = home
		fundies.cpu_players.append(adding_cpu)
		fundies.add_child(adding_cpu)
	
	fundies.stack_manager.assign_card_stacks(stacks, home)
	stacks.make_deck()

func set_up_slots(home: bool):
	var temp_side: SideState = board_state.get_side(home)
	var ui: CardSideUI = full_ui.get_home_side(home)
	var stacks: CardStack = fundies.stack_manager.get_stacks(home)
	
	#Set up pre defined slots
	for slot in temp_side.slots:
		ui.insert_slot(slot, temp_side.slots[slot])
		stacks.account_for_slot(slot)
	
	stacks.setup()
	full_ui.update_stacks(stacks.sendStackDictionary(), home)

func _input(event: InputEvent) -> void:
	if event.is_action("TEST") and not test_out and test:
		fundies.record_source_target(true, 
		 [full_ui.get_poke_slots(Consts.SIDES.ATTACKING, Consts.SLOTS.ACTIVE)[0]],
		 [])
		var new = test.instantiate()
		
		#region EDIT WITH WHATEVER
		#new.side = full_ui.get_home_side(true)
		#endregion
		
		add_child(new)
		test_out = true
