class_name InvSlot
extends PanelContainer

@export var type: InvItemData.Type

func init(t: InvItemData.Type, cms: Vector2) -> void:
	type = t
	custom_minimum_size = cms

func _can_drop_data(at_position: Vector2, invItem: Variant) -> bool:
	if invItem is InvItem:
		if self.type == InvItemData.Type.MAIN: # if this slot can hold anything)
			if get_child_count() == 0: # and if its empty
				return true
			else:
				if self.type == invItem.get_parent().type:# If transfer is from MAIN -> MAIN in order to prevent putting wheat to helmet :P
					return true
			return get_child(0).invItem.type == invItem.data.type
		else:
			return invItem.data.type == self.type
	return false
	
func _drop_data(at_position: Vector2, invItem: Variant) -> void:
	if get_child_count() > 0:
		var curr_item = get_child(0) # Get the item which is currently in the slot
		if curr_item == invItem: # If its back in the same slot
			return
		if curr_item.data == invItem.data: # If they're the same item,
			curr_item.increment_count(invItem.data.count) # increment the current one which however much is in the second one
			invItem.queue_free() # delete the one which is being dragged
			return # dont reparent the previous item, since it doesn't exist
		curr_item.reparent(invItem.get_parent()) # place the current item in the dragging item's slot
	invItem.reparent(self) # place the dragged item in this slit
