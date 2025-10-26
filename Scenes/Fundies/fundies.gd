@icon("res://Art/ProjectSpecific/cards.png")
extends Node
class_name Fundies

#--------------------------------------
#region VARIABLES
@export var board: FullBoardUI
@export var first_turn: bool = false

@onready var stack_manager: CardStackManager = $CardStackManager
@onready var card_player: CardPlayer = $CardPlayer
@onready var pass_turn_graphic: Control = $PassTurnGraphic

var turn_number: int = 1
var home_turn: bool = true
var atk_efect: bool = false
var home_targets: Array[Array]
var away_targets: Array[Array]
var source_stack: Array[bool]
var used_turn_abilities: Array[String]
var used_emit_abilities: Array[String]
var cpu_players: Array[CPU_Player]

#endregion
#--------------------------------------

func _ready() -> void:
	Glob.fundies = self
	SigBus.end_turn.connect(next_turn)
	SigBus.record_src_trg.connect(record_attack_src_trg)
	SigBus.record_src_trg_from_prev.connect(record_prev_src_trg_from_self)
	SigBus.record_src_trg_from_self.connect(record_prev_src_trg_from_self)
	SigBus.remove_src_trg.connect(remove_top_source_target)

#--------------------------------------
#region PRINT
func current_turn_print():
	#Get the side that's attacking
	print("CURRENT ATTACKER")
	Glob.full_ui.get_home_side(home_turn).print_status()
	
	#Get the side that's defending
	print("CURRENT DEFENDER")
	Glob.full_ui.get_home_side(not home_turn).print_status()
	
	print_simple_slot_types()

func print_simple_slot_types():
	print("-------------------------")
	#GET ATTACKING
	print_slots(Consts.SIDES.ATTACKING, Consts.SLOTS.ALL, "ATTACKING SLOTS: ")
	print_slots(Consts.SIDES.DEFENDING, Consts.SLOTS.ALL, "DEFENDING SLOTS: ")
	print_slots(Consts.SIDES.BOTH, Consts.SLOTS.ACTIVE, "ACTIVE SLOTS: ")
	print_slots(Consts.SIDES.BOTH, Consts.SLOTS.BENCH, "BENCH SLOTS: ")
	print("-------------------------")

func print_slots(sides: Consts.SIDES, slots: Consts.SLOTS, init_string: String):
	var slot_string: String = init_string
	for slot in Glob.full_ui.get_slots(sides, slots):
		if not slot.connected_slot.is_filled():
			continue
		slot_string = str(slot_string, "[", slot.connected_slot.current_card.name, "]")
	
	print(slot_string, "\n")
#endregion
#--------------------------------------

#--------------------------------------
#region HELPERS
func get_side_ui() -> CardSideUI:
	return Glob.full_ui.get_home_side(home_turn)

func get_considered_home(side: Consts.SIDES):
	match side:
		Consts.SIDES.ATTACKING:
			return home_turn
		Consts.SIDES.DEFENDING:
			return not home_turn
		Consts.SIDES.SOURCE:
			return get_source_considered()
		Consts.SIDES.OTHER:
			return not get_source_considered()

func is_home_side_player() -> bool:
	var check_side = board.board_state.home_side\
	 if home_turn else board.board_state.away_side
	
	return check_side == Consts.PLAYER_TYPES.PLAYER

func get_current_player():pass

func can_be_played(_card: Card) -> int:
	var allowed_to: int = 0
	
	return allowed_to

func check_all_passives() -> void:
	for ui in Glob.full_ui.every_slot:
		if ui.connected_slot.is_filled():
			ui.connected_slot.check_passive()

func used_ability(ability_name: String) -> bool:
	return used_turn_ability(ability_name) or used_emit_ability(ability_name)

func used_turn_ability(ability_name: String) -> bool:
	return ability_name in used_turn_abilities

func used_emit_ability(ability_name: String) -> bool:
	return ability_name in used_emit_abilities

func clear_emit_abilities() -> void:
	used_emit_abilities.clear()

#endregion
#--------------------------------------

#--------------------------------------
#region SLOT FUNCTIONS
func find_allowed_slots(condition: Callable, sides: Consts.SIDES,\
 slots: Consts.SLOTS = Consts.SLOTS.ALL) -> Array[UI_Slot]:
	return Glob.full_ui.get_slots(sides, slots).filter(func(uislot: UI_Slot):\
	 return condition.call(uislot.connected_slot))

#region TARGET SOURCE MANAGEMENT
func record_attack_src_trg(is_home: bool, atk_trg: Array, def_trg: Array):
	source_stack.append(is_home)
	if is_home:
		home_targets.append(atk_trg)
		away_targets.append(def_trg)
	else:
		home_targets.append(def_trg)
		away_targets.append(atk_trg)

#First record then print out what I can get from this, then rmeove when used up
func record_source_target(is_home: bool, home_trg: Array, away_trg: Array):
	source_stack.append(is_home)
	home_targets.append(home_trg)
	away_targets.append(away_trg)

func record_single_src_trg(slot: Slot):
	var home_trg: Array = []
	var away_trg: Array = []
	var is_home: bool = slot.is_home()
	
	if is_home: home_trg.append(slot)
	else: away_trg.append(slot)
	
	record_source_target(is_home, home_trg, away_trg)

##This function will record a src_trg stack with a new source item that equals the caller's side
func record_prev_src_trg_from_self(slot: Slot):
	source_stack.append(slot.is_home())
	home_targets.append(home_targets[-1])
	away_targets.append(away_targets[-1])

func remove_top_source_target():
	source_stack.pop_back()
	home_targets.pop_back()
	away_targets.pop_back()

func get_first_target(source: bool) -> Slot:
	return home_targets[-1][0] if source_stack[-1] == source else away_targets[-1][0]

func get_targets() -> Array:
	return home_targets[-1] + away_targets[-1]

func get_source_considered() -> bool:
	return source_stack[-1]

func get_single_src_trg() -> Slot:
	var src_stack = home_targets[-1] if source_stack[-1] else away_targets[-1]
	
	if src_stack.size() != 1:
		printerr("Using ", get_single_src_trg, " when the source stack's size is greater than 1")
	
	return home_targets[-1][-1] if source_stack[-1] else away_targets[-1][-1]

func print_src_trg():
	print("----------------------------------------------------------")
	print_slots(Consts.SIDES.SOURCE, Consts.SLOTS.ALL, "SOURCE SLOTS: ")
	print_slots(Consts.SIDES.BOTH, Consts.SLOTS.TARGET, "TARGET SLOTS: ")
	print("----------------------------------------------------------")

#endregion
#endregion
#--------------------------------------

func next_turn():
	print_rich("[center]--------------------------END TURN-------------------------")
	used_turn_abilities.clear()
	home_turn = not home_turn
	turn_number += 1
	
	await Glob.full_ui.set_between_turns()
	#When animations and other stuff are added for checkups, remove this
	await get_tree().create_timer(.1).timeout
	
	print_rich("[center]--------------------------TURN ", turn_number, "-------------------------")
	pass_turn_graphic.turn_change()
	await pass_turn_graphic.animation_player.animation_finished
	
	if stack_manager.get_stacks(home_turn).get_array(Consts.STACKS.DECK).size() == 0:
		print("You lose")
	else:
		stack_manager.draw(1)
	
	for player in cpu_players:
		player.can_operate()
