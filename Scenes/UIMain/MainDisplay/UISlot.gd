extends Control
class_name UI_Slot

#--------------------------------------
#region VARIABLES
@export var active: bool = true
@export var player: bool = true
@export var home: bool = true
@export_enum("Left","Right","Up","Down") var list_direction: int = 0

@onready var name_section: RichTextLabel = %Name
@onready var max_hp: RichTextLabel = %MaxHP
@onready var tool: TextureRect = %Tool
@onready var tm: TextureRect = %TM
@onready var changes_display: Control = %ChangeDisplay
@onready var typeContainer: Array[Node] = %TypeContainer.get_children()
@onready var energy_container: Array[Node] = %EnergyTypes.get_children()
@onready var list_offsets: Array[Vector2] = [Vector2(-size.x / 2, 0),
 Vector2(size.x / 2,0), Vector2(0,-size.y / 2), Vector2(0,size.y / 2)]

#Unfinished, doesn't account for special energy
var connected_slot: Slot = Slot.new()
var current_display: Node

#endregion
#--------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready():
	%ArtButton.spawn_direction = list_direction
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
