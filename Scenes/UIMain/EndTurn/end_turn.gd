extends Button

func _on_pressed() -> void:
	SigBus.end_turn.emit()
