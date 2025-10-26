##Shows the number of cards in a single CardStack array, press it to see the stack
extends PanelContainer
class_name CardStackButton

@export var icon: CompressedTexture2D
@export var home: bool = true
@export var list: Consts.STACKS = Consts.STACKS.HAND

@onready var texture_rect: TextureRect = %TextureRect
@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var button: Button = $Button

var  current_num: int

func _ready() -> void:
	texture_rect.texture = icon
	update(-5)

func update(num: int):
	rich_text_label.clear()
	var text: String = Convert.stack_into_string(list)
	current_num = num
	rich_text_label.append_text(str("[u]",text,"[/u]\n",num))

func _on_button_pressed() -> void:
	print("Bring up ", list)
	print()
	SigBus.show_list.emit(home, list, Consts.STACK_ACT.PLAY if list == Consts.STACKS.HAND else Consts.STACK_ACT.LOOK)
