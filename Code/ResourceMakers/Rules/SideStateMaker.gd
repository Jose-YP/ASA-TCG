extends Resource
class_name SideState

@export var card_stacks: CardStack
@export var prize_cards: int = 6
@export var bench_size: int = 5
##The boolean will determine whether or not a slot is active or not
##[br] take these cards inside slots from deck if [member home_UD] is null
@export var slots: Dictionary[Slot, bool]
@export var inital_supporter: Card
