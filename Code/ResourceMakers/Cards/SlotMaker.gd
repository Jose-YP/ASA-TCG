##Responcible for holding characters cards that are in play
extends Resource
class_name Slot

var current_card: Card

@warning_ignore("unused_signal")
signal played
