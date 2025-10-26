extends Node
class_name CPU_Player

@export var home_side: bool = false

var operating: bool = false

func can_operate():
	if operating:
		it_is_my_turn()
	else:
		not_my_turn()

func it_is_my_turn():
	print("IT'S MY TURN NOW")
	end_turn()

func not_my_turn():
	print("aw man :(")

func end_turn():
	SigBus.end_turn.emit()
