##Meant to hold a list of cards into a fixed sized UI element
extends Control
class_name RegList

@export var stack_act: Consts.STACK_ACT = Consts.STACK_ACT.PLAY
@export var stack: Consts.STACKS = Consts.STACKS.HAND
@export_flags("Basic", "Evolution", "Item",
"Supporter","Stadium", "Tool", "TM", "RSM", "Fossil",
 "Energy") var allowed_as: int = 1

@onready var header: UIHeader = %Header
@onready var playing_list: PlayingList = %PlayingList
@onready var footer: PanelContainer = %Footer
@onready var old_size: Vector2 = size

var display_text: String = ""
var instruction_text: String = ""
var old_pos: Vector2
var list: Dictionary[Card, bool]
var home: bool

func _ready() -> void:
	match stack_act:
		Consts.STACK_ACT.PLAY: instruction_text = "[center]Choose which allowed cards to play"
		Consts.STACK_ACT.TUTOR:
			%Close_Button.hide()
			instruction_text = "[center]Choose which allowed cards to add"
		Consts.STACK_ACT.DISCARD:
			%Close_Button.hide()
			instruction_text = "[center]Choose which allowed cards to discard"
		Consts.STACK_ACT.LOOK: instruction_text = "[center]Only allowed to check cards"
		_: printerr(stack_act, " not apart of stack act enum")
	match stack:
		Consts.STACKS.HAND: display_text = "HAND"
		Consts.STACKS.DECK: display_text = "DECK"
		Consts.STACKS.DISCARD: display_text = "DISCARD"
		Consts.STACKS.PLAY: display_text = "HAND"
		Consts.STACKS.NONE: pass
		_: printerr(stack, " not apart of stack enum")
	
	header.setup(str("[center]",display_text))
	footer.setup(instruction_text)
	
	playing_list.list = list
	playing_list.allowed_as = allowed_as
	playing_list.set_items()

func manage_input(event: InputEvent):
	if event.is_action("Back"):
		var opt: ItemOptions = playing_list.options
		if opt == null:
			header.handle_back(event)

func _on_playing_list_finished() -> void:
	Glob.full_ui.remove_top_ui()
	#Glob.control_disapear(self, .1, old_pos)
