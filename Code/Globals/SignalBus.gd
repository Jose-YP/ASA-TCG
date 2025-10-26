##Easy communication between the entire system, though should probably minimize if possible
extends Node

@warning_ignore_start("unused_signal")
#--------------------------------------
#region SIGNALS
#--------------------------------------
#region STACK SIGNALS
signal show_list(home: bool, list: Consts.STACKS, act: Consts.STACK_ACT)
#signal make_placement(card: Array[Card], placement: Placement, from: Consts.STACKS)
#signal reorder_cards(card: Array[Card], placement: Placement,)
#signal start_tutor(search: Search)
signal tutor_card(card: Card)
signal cancel_tutor(button: Button)
#endregion
#--------------------------------------
#region SLOT SIGNALS
signal chosen_slot(showing: Slot)
signal ability_activated()
signal ability_checked()
signal force_disapear()
#endregion

signal get_candidate(pokeSlot: Slot) #Originally meant for effects, nmot sure if I should keep this

signal record_src_trg(home: bool, atk_stack: Array[Slot], def_stack: Array[Slot])
signal record_src_trg_from_prev(slot: Slot)
signal record_src_trg_from_self(slot: Slot)
signal remove_src_trg()

signal end_turn()
#endregion
#--------------------------------------

@warning_ignore_restore("unused_signal")
