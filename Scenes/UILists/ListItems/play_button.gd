##Meant to hold a single card as a selectable item in lists
##Definetly gonna change when the final card design is known
extends Button
class_name PlayingButton

@export var card: Card
@export var option_offset: Vector2 = Vector2(30, 100)

signal select

var from_id: Identifier
var parent: Node
var checking_card: Node
var stack_act: Consts.STACK_ACT
var disable_flags: int = 0
var allowed: bool = false
var selected: bool = false:
	set(value):
		selected = value
		if value:
			theme_type_variation = "DragButton"
		else:
			theme_type_variation = ""


#--------------------------------------
#region INITALIZATION
func _ready() -> void:
	%Class.clear()
	
	%Art.texture = card.image
	%Name.clear()
	%Name.append_text(card.name)
	
	set_name(card.name)

func allow(_play_as: int):
	allowed = true
	disabled = false

func not_allowed():
	allowed = false
	disabled = true

func allow_move_to(_destination: Consts.STACKS):
	allowed = true
	disabled = false
	#match destination:
		#Consts.STACKS.DISCARD: stack_act = Consts.STACK_ACT.DISCARD
		#Consts.STACKS.PLAY: stack_act = Consts.STACK_ACT.TUTOR

func is_tutored() -> bool:
	return not parent is PlayingList

#endregion
#--------------------------------------

func deselect():
	selected = false

#--------------------------------------
#region ACTIONS
#probably should add a way to check if closer to left or right
func show_options() -> Node:
	var option_Display = load("res://Scenes/UI/Lists/item_options_copy.tscn").instantiate()
	option_Display.scale = Vector2(.05, .05)
	option_Display.modulate = Color.TRANSPARENT
	option_Display.origin_button = self
	option_Display.stack_act = stack_act if allowed else Consts.STACK_ACT.LOOK
	
	Glob.full_ui.set_top_ui(option_Display, Glob.full_ui.ui_stack[-1])
	option_Display.tree_exited.connect(deselect)
	option_Display.position = get_option_position()
	option_Display.bring_up()
	
	return option_Display

func get_option_position() -> Vector2:
	var set_pos: Vector2 = Vector2.ZERO
	var adjustment: float
	
	if parent is PlayingList:
		adjustment = parent.par.global_position.y
	#I should adjust tutoring to remove the option popup
	else:
		adjustment = parent.global_position.y
	
	set_pos.y = %LeftSpawn.global_position.y - adjustment
	if %RightSpawn.global_position.x > float(get_window().size.x) / 2:
		set_pos.x = %LeftSpawn.position.x - option_offset.x
	else:
		set_pos.x = %RightSpawn.position.x
	
	return set_pos

func _gui_input(event):
	if not disabled:
		if event.is_action_pressed("A"):
			if stack_act == Consts.STACK_ACT.DISCARD or stack_act == Consts.STACK_ACT.MIMIC:
				select.emit()
			elif stack_act != Consts.STACK_ACT.LOOK:
				if parent.options:
					await Glob.full_ui.remove_top_ui()
				if not Glob.checking:
					parent.options = show_options()
			elif stack_act == Consts.STACK_ACT.LOOK:
				Glob.show_card(card, self)
	if event.is_action_pressed("Check"):
		Glob.show_card(card, self)

#endregion
#--------------------------------------
