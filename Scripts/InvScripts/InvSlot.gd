class_name InvSlot
extends PanelContainer

@export var type: InvItemData.Type

var is_mouse_in: bool = false
var slotT = "inv"

func init(t: InvItemData.Type, cms:Vector2) -> void:
	type = t
	custom_minimum_size = cms

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_Q) and Input.is_key_pressed(KEY_ALT):
		if get_child_count() > 0:
			get_child(0).drop(true)
	if Input.is_action_just_released("drop") and is_mouse_in:
		if get_child_count() > 0:
			get_child(0).drop(false)

func _can_drop_data(at_position: Vector2, invItem: Variant) -> bool:
	if invItem is InvItemClass:
		# If the dragged item is a temporary single-item instance, allow dropping anywhere valid for the original item type.
		# This handles the case where InvItemClass.data.type is the relevant check.
		if self.type == InvItemData.Type.MAIN: # if this slot can hold anything
			if get_child_count() == 0: # and if its empty
				return true
			else:
				# If there's an item, check if they can stack or be swapped.
				# Allow dropping if types match for swapping or stacking.
				# Assuming InvItemClass.data.type is the 'type' field that dictates compatibility
				return get_child(0).data.name == invItem.data.name or self.type == invItem.get_parent().type
		else: # Specific type slot (e.g., equipment slot)
			return invItem.data.type == self.type
	return false

func _drop_data(at_position: Vector2, invItem: Variant) -> void:
	if not (invItem is InvItemClass):
		return # Ensure we are dropping an InvItemClass

	if get_child_count() > 0:
		var curr_item = get_child(0) as InvItemClass # Get the item which is currently in the slot
		if curr_item == invItem: # If it's back in the same slot (e.g., dragged single item back to its origin)
			# This handles the case where a single item was dragged out and then back into the same slot.
			# We need to re-add its count to the original stack.
			if invItem.data.count == 1 and invItem.get_parent() == null: # It's a single item from a right-click drag
				curr_item.change_count(invItem.data.count) # Add 1 back to the original stack
				invItem.queue_free() # Delete the dragged single item instance
				return
			else: # Full stack drag or simply moved around but not merged
				return # Do nothing if it's the same item instance and already in the slot

		if curr_item.data.name == invItem.data.name: # If they're the same item type, stack them
			curr_item.change_count(invItem.data.count) # Increment the current one by how much is in the second one
			invItem.queue_free() # Delete the one which is being dragged
			return # Don't reparent if stacked

		# If existing item and dragged item are different, swap them
		curr_item.reparent(invItem.get_parent()) # Place the current item in the dragging item's original slot
	invItem.reparent(self) # Place the dragged item in this slot

func _on_mouse_entered() -> void:
	var style:StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 1)
	add_theme_stylebox_override ("panel", style)

	is_mouse_in = true

func _on_mouse_exited() -> void:
	var style:StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.6)
	add_theme_stylebox_override ("panel", style)

	is_mouse_in = false
