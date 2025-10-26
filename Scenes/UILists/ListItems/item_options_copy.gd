##Meant to hold every possible action a player can do with a card depending on Consts.STACK_ACT
##Return whatever the player selects
extends Control
class_name ItemOptions

@export var timing: float = .1
@export var stack_act: Consts.STACK_ACT = Consts.STACK_ACT.PLAY

@onready var items: Array[Node] = $PlayAs/Items.get_children()

signal play_as(card: Card)

var old_position: Vector2
var origin_button: PlayingButton
var home: bool

#--------------------------------------
#region INITALIZATION AND REMOVAL
# Called when the node enters the scene tree for the first time.
func _ready():
	origin_button.selected = true
	
	for i in range($PlayAs/Items.get_child_count() - 1): items[i].hide()
	#Tutor and discard will also need to vary depening on card_flags
	match stack_act:
		Consts.STACK_ACT.PLAY:
			%Play.show()
		Consts.STACK_ACT.TUTOR:
			if origin_button.is_tutored():
				%Cancel.show()
			else:
				%Tutor.show()
		Consts.STACK_ACT.DISCARD:
			if origin_button.is_tutored():
				%Cancel.show()
			else:
				%Discard.show()
		Consts.STACK_ACT.LOOK:
			pass
		_: push_error(stack_act, " Not an actual stack_act")
	
	Glob.enter_check.connect(on_entered_check)
	Glob.exit_check.connect(on_exited_check)
	play_as.connect(Callable(SigBus, "call_action"))

func bring_up():
	var appear_tween: Tween = get_tree().create_tween().set_parallel()
	
	appear_tween.tween_property(self, "modulate", Color.WHITE, timing)
	appear_tween.tween_property(self, "scale", Vector2.ONE, timing)

#endregion
#--------------------------------------

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_UP:
			await get_tree().create_timer(.01).timeout
			position = origin_button.get_option_position()

func manage_input(event: InputEvent):
	if event.is_action("Back"):
		Glob.full_ui.remove_top_ui()
	if event.is_action("Check"):
		_on_check_pressed()

#--------------------------------------
#region SIGNALS
#Record source here, no need to record target as anything in particular
func _on_play_pressed():
	if not Glob.checking:
		Glob.full_ui.remove_top_ui()
		Glob.full_ui.remove_top_ui()
		play_as.emit(origin_button.card)
		origin_button.parent.finished.emit()

func _on_check_pressed():
	if not Glob.checking:
		Glob.show_card(origin_button.card, origin_button)

#Tutor and discard record source and target on effect call
func _on_tutor_pressed() -> void:
	print("Tutor ", origin_button.card.name, " from ", origin_button.parent.stack)
	SigBus.tutor_card.emit(origin_button.card)
	Glob.full_ui.remove_top_ui()

func _on_discard_pressed() -> void:
	print("Discard ", origin_button.card.name, " from ", origin_button.parent.stack)
	SigBus.tutor_card.emit(origin_button.card)
	Glob.full_ui.remove_top_ui()

func on_entered_check():
	for i in range($PlayAs/Items.get_child_count()):
		items[i].disabled = true

func on_exited_check():
	for i in range($PlayAs/Items.get_child_count()):
		items[i].disabled = false

func _on_cancel_pressed() -> void:
	SigBus.cancel_tutor.emit(origin_button)
	Glob.full_ui.remove_top_ui()

#endregion
#--------------------------------------
