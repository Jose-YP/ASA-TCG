##Responcible for displaying a single Slot's data, should not hold data except for the Slot itself
extends Control
class_name UI_Slot

#--------------------------------------
#region VARIABLES
@export var active: bool = true
@export var player: bool = true
@export var home: bool = true

@onready var name_section: RichTextLabel = %Name
@onready var max_hp: RichTextLabel = %MaxHP

#Unfinished, doesn't account for special energy
var connected_slot: Slot = Slot.new()
var current_display: Node

#endregion
#--------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready():
	if %ArtButton.benched: %ArtButton/PanelContainer.size = Vector2(149, 96)
	clear()
	connected_slot.slot_into(self)
	%ArtButton.connected_ui = self
	%Conditions.move_child(%ChangeDisplay, 0)

func display_hp(current_max: int) -> void:
	var typical_max: int = connected_slot.get_pokedata().HP
	var hp_color: String
	
	if current_max != typical_max:
		hp_color = str("[color=",Color.AQUA.to_html() if current_max > typical_max else Color.RED.to_html(),"]")
	
	max_hp.clear()
	max_hp.append_text(str(hp_color, "HP: ", current_max,
	 "[/color]" if hp_color != null else ""))

#--------------------------------------
#region ART BUTTON FUNCTIONS
func switch_shine(value: bool):
	%ArtButton.material.set_shader_parameter("shine_bool", value)

func make_allowed(is_allowed: bool):
	%ArtButton.disabled = not is_allowed

func display_image(card: Card):
	%ArtButton.current_card = card
#endregion
#--------------------------------------

func clear():
	name_section.clear()
	max_hp.clear()
	display_image(null)
