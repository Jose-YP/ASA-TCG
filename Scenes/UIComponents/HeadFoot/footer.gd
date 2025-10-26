extends PanelContainer

##Which node will this component drag around?
@export var dragging_node: Control
##If this is filled, it will use this node's position as the offset
@export var based_on: Control
@export var offset: Vector2 = Vector2.ZERO

@onready var instructions: RichTextLabel = %Instructions
@onready var movable: Draggable_Control = $Movable

func _ready() -> void:
	movable.dragging_node = dragging_node
	movable.based_on = based_on
	movable.offset = offset

func setup(txt: String = ""):
	instructions.clear()
	instructions.append_text(txt)
	
	if txt == "":
		hide()
	else: show()

func has_text() -> bool:
	return instructions.text != ""
