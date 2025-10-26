##Holds all data for cards
extends Resource
class_name Card

@export var name: String
@export var art: Texture2D
@export var artist: String

##Which cards are listed first?
func card_priority(other: Card) -> bool:
	return name > other.name
