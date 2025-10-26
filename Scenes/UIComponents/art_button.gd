##Show a compressed view of the current active card
extends Button

##Probably change the dimentions when we get the final card art layout
#--------------------------------------
#region VARIABLES
@export var pokemon: bool = true
@export var spawn_position: Vector2 = Vector2(230,25)
@export var benched: bool = false
@export_enum("Left","Right","Up","Down") var spawn_direction: int = 0

@onready var art: TextureRect = %Art
@onready var spawn_offsets: Array[Vector2] = [Vector2(-size.x / 2, 0),
 Vector2(size.x / 2,0), Vector2(0,-size.y / 2), Vector2(0,size.y / 2)]


var current_card: Card:
	set(value):
		var old = current_card
		current_card = value
		disabled = value == null
		if value != old and value != null:
			%Art.texture = value.image
			var art_tween: Tween = create_tween().set_parallel()
			art.scale = Vector2.ZERO
			art_tween.tween_property(%Art, "scale", Vector2.ONE, .1)
		elif value == null:
			%Art.texture = null
#endregion
#--------------------------------------

#--------------------------------------
#region INITALIZATION & PROCESSING
func _ready():
	get_child(0).size = size
	if benched: 
		custom_minimum_size = Vector2(149, 96)
		art.custom_minimum_size = Vector2(142, 87)
		art.position = Vector2(4,3)

# Called when the node enters the scene tree for the first time.
func _gui_input(event):
	if event.is_action_pressed("ui_accept") and not disabled:
		if z_index > 0:
			SigBus.chosen_slot.emit()

func _on_pressed() -> void:
	if pokemon:
		SigBus.chosen_slot.emit(owner.connected_slot)
#endregion
#--------------------------------------
