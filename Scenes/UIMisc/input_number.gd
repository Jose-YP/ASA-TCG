extends Control
class_name InputNum

@export var cap: int = -1
@export var title: String

@onready var rich_text_label: RichTextLabel = $PanelContainer/VBoxContainer/PanelContainer2/RichTextLabel
@onready var spin_box: SpinBox = $PanelContainer/VBoxContainer/SpinBox
@onready var confirm: Button = $PanelContainer/VBoxContainer/Confirm

signal finished

var old_pos: Vector2 = Vector2.ZERO
var test: String
#Consts
func _ready() -> void:
	rich_text_label.clear()
	rich_text_label.append_text(title)
	
	if cap != -1:
		spin_box.max_value = cap

func _on_confirm_pressed() -> void:
	finished.emit()
	print("Return num: ", spin_box.value)
