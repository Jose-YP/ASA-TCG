extends Control

@onready var color_rect: ColorRect = %ColorRect
@onready var turn_graphic: TabContainer = %TurnGraphic
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func turn_change():
	animation_player.play("TurnChange")
