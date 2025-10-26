##The draggable Node Component, used inside the Movable Button
##It allows any node to get draggled along the screen as long as it's recognizing that the object is held down.
##
##This node will be used for nodes that can drag and stop freely, do not use for slots.
##
##For UI nodes use the Movable Button Component that has this node inside.
extends Node
class_name Draggable

##The return value is the location of the mouse press
##Alone it needs the parent to manage dragging
signal started(event_position)
##Tells the node it's connected to that it's time to let go.
##Alone it needs the parent to manage ending drag
signal ended

##This function will check if the user is left clicking anywhere.
##
##Once it's pressed it will emit [signal started] to tell it's parent where and how to move.
##
##Since this function checks for InputEventMouseButton it won't work during the drag process,
##It only checks if the drag should start or end
func object_held_down(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			started.emit(event.position)
		else:
			ended.emit()
	
