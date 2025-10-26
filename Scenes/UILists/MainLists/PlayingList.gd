@icon("res://Art/ProjSpecific/list(1).png")
##Meant to hold a group of cards to see which one will be used next
##Whether that be for tutoring, playing, etc
extends Control
class_name PlayingList

#--------------------------------------
#region VARIABLES
@export var par: Control
@export var all_lists: Array[Dictionary]
@export var list: Dictionary[Card, bool]
@export var stack_act: Consts.STACK_ACT = Consts.STACK_ACT.PLAY
@export var stack: Consts.STACKS = Consts.STACKS.HAND

@warning_ignore("unused_signal")
signal finished

var black_list: Array[String] = []
var white_list: Array[String] = []
var display: Node
var options: ItemOptions
var on_card: bool = false
var home: bool = true

#endregion
#--------------------------------------

#--------------------------------------
#region INITALIZATION
func set_items():
	stack = par.stack
	stack_act = par.stack_act
	
	for item in list:
		var making = Consts.playing_button.instantiate()
		making.card = item
		making.parent = self
		%CardList.add_child(making)
		is_allowed(making)
	
	if stack_act != Consts.STACK_ACT.PLAY and stack_act != Consts.STACK_ACT.LOOK and %CardList.get_child_count() != 0:
		sort_items()

func refresh_allowance():
	for item in %CardList.get_children():
		is_allowed(item)

func is_allowed(button: Button) -> void:
	#print("List checking if ", button.card.name, " is allowed ", list[button.card])
	button.stack_act = stack_act
	match stack_act:
		Consts.STACK_ACT.PLAY:
			var whitelisted: bool = white_list.has(button.card.name)
			var blacklisted: bool = black_list.has(button.card.name)
			var can_be_played_as: int = Glob.fundies.can_be_played(button.card)
			if (list[button.card] or whitelisted) and not blacklisted:
				button.allow(can_be_played_as)
			else: button.not_allowed()
		Consts.STACK_ACT.TUTOR:
			prints(button.card.name ,"allowed for tutor?", par.list_allowed(button.card))
			if par.list_allowed(button.card) and not button.card.name in black_list:
				button.allow_move_to(stack_act)
			else:
				button.not_allowed()
		_:
			if list[button.card]:
				button.allow_move_to(stack_act)

#endregion
#--------------------------------------

#--------------------------------------
#region ITEM MANAGEMENT
func reset_items():
	for item in %CardList.get_children():
		%CardList.remove_child(item)

func remove_item(card: Card):
	for item in %CardList.get_children():
		if item.card == card:
			%CardList.remove_child(item)

func add_item(card: Card):
	var making = Consts.playing_button.instantiate()
	making.card = card
	making.parent = self
	%CardList.add_child(making)
	is_allowed(making)

func sort_items():
	Convert.all_lists = all_lists
	var items = %CardList.get_children()
	items.sort_custom(Convert.default_card_sort)
	for i in range(items.size()):
		%CardList.move_child(items[i], i)

func get_items() -> Array[PlayingButton]:
	var items: Array[PlayingButton]
	for item in %CardList.get_children():
		items.append(item)
	
	return items

func connect_to_select(funct: Callable):
	for item in get_items():
		item.select.connect(funct.bind(item))

func disable_items(value: bool = true):
	for item in get_items():
		item.disabled = value

#endregion
#--------------------------------------
