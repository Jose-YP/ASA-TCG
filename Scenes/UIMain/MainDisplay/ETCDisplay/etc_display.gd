##Holds all UI elements that aren't played cards on slots
extends HBoxContainer
class_name ETC_Display

@export var home: bool = true

@onready var change_display: Control = %ChangeDisplay
@onready var stacks: Dictionary[Consts.STACKS, CardStackButton] = {Consts.STACKS.DISCARD:%DiscardButton,
Consts.STACKS.DECK:%DeckButton, Consts.STACKS.HAND:%HandButton}

var current_supporter: Card

func _ready() -> void:
	for button in stacks:
		stacks[button].home = home
	#So I don't have tow make two ETC scenes for each side
	if not home:
		move_child($CardStacks, 0)
	%ArtButton.get_child(0).size = %ArtButton.size

func print_stack_numbers() -> String:
	var lists: String
	for stack in stacks:
		var stack_str: String = Convert.stack_into_string(stack)
		lists = str(lists, "[", stack_str, " = ", stacks[stack].current_num, " ] ")
	return lists

func update_stack(which: Consts.STACKS, num: int) -> void:
	stacks[which].update(num)

func sync_stacks():
	var stack_arrays: CardStack = null
	for stack in stacks:
		stacks[stack].update(stack_arrays.get_array(stack).size())
