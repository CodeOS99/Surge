class_name CurrentyWeapon
extends PanelContainer

@export var type: InvItemData.Type # This `type` variable isn't used in CraftSlot's _can_drop_data logic. Consider if it's necessary here.

var is_mouse_in: bool = false
var idx: int # Index of this slot within the crafting grid

var slotT = "craft" # Type identifier for this slot (e.g., "craft", "inventory", "equipment")

func _ready() -> void:
	var style:StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.6, 0.1, 0.1, 0.6) # Slightly darker teal for base
	add_theme_stylebox_override ("panel", style)
	self.idx = idx

func _process(delta: float) -> void:
	# Drop item from slot using hotkeys (Q + ALT)
	if Input.is_key_pressed(KEY_Q) and Input.is_key_pressed(KEY_ALT):
		if get_child_count() > 0:
			# Assuming 'drop(true)' means drop without checking mouse position (force drop)
			(get_child(0) as InvItemClass).drop(true)
	
	# Drop item from slot when 'drop' action is released and mouse is over this slot
	if Input.is_action_just_released("drop") and is_mouse_in:
		if get_child_count() > 0:
			# Assuming 'drop(false)' means drop checking mouse position
			(get_child(0) as InvItemClass).drop(false)


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# Check if the dragged 'data' is an InvItemClass instance
	# This slot allows any InvItemClass to be dropped, as it's a crafting input slot.
	return data is InvItemClass

# Handles the actual drop operation when an item is released over this slot
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var dragged_item_node = data as InvItemClass # The actual InvItemClass node being dragged

	# Basic validation to ensure we have a valid item node
	if not is_instance_valid(dragged_item_node):
		return

	var current_item_in_slot: InvItemClass = null
	if get_child_count() > 0:
		current_item_in_slot = get_child(0) as InvItemClass

	# Get the original parent (slot) of the dragged item before it was reparented for drag
	var original_slot: Control = dragged_item_node.get_parent() 
	# Note: get_parent() here will typically be null if _get_drag_data already removed it from its parent.
	# It is crucial that _get_drag_data handles the initial removal.

	# Case 1: Dragging to the same slot (no change needed)
	# This covers cases where an item is dragged out and then back onto its original slot
	if current_item_in_slot == dragged_item_node:
		return

	# Case 2: Stacking items (if target slot has the same item type and is not null)
	if current_item_in_slot != null and current_item_in_slot.data.name == dragged_item_node.data.name:
		# Increment the current stack's count
		current_item_in_slot.change_count(dragged_item_node.data.count)
		
		# Now that its count is added, the dragged item instance is no longer needed
		# We must free the dragged item node.
		if is_instance_valid(dragged_item_node):
			dragged_item_node.queue_free() # Free the node instance
		
		# If the original slot had a custom 'remove_item' logic to clear its reference
		# or handle its child count, ensure it's updated.
		# If the item was removed from its parent by _get_drag_data, this might not be needed.
		if is_instance_valid(original_slot) and original_slot.has_method("remove_item"):
			# This is a placeholder. A robust remove_item might take the item node as argument.
			# Or if _get_drag_data already removed the child, this won't do anything.
			# For simple setups, the queue_free above is enough.
			pass
		
		return # Stacking handled, exit function

	# Case 3: Empty target slot OR Swapping items (if target slot is occupied by a different item)
	if current_item_in_slot != null: # If there's an item in this slot (it's a swap)
		# Move the item currently in this slot back to the original slot of the dragged item
		if is_instance_valid(original_slot): # Check if the original slot is valid (not null or freed)
			current_item_in_slot.reparent(original_slot)
			current_item_in_slot.position = Vector2.ZERO # Reset position within the new parent
		else:
			# If the original slot is somehow gone (e.g., inventory closed),
			# decide what to do with current_item_in_slot (e.g., queue_free it, drop to world)
			current_item_in_slot.queue_free() # Default to freeing if nowhere to go
			print("Warning: Original slot for swap not found. Item was freed.")

	# Move the dragged item into this slot
	dragged_item_node.reparent(self) # Reparent the dragged item to this slot
	dragged_item_node.position = Vector2.ZERO # Reset its position within this slot


func _on_mouse_entered() -> void:
	is_mouse_in = true
	var style:StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.6, 0.5, 0.5, 1) # Slightly darker teal for base
	add_theme_stylebox_override ("panel", style)

func _on_mouse_exited() -> void:
	is_mouse_in = false
	var style:StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.6, 0.1, 0.1, 0.6) # Slightly darker teal for base
	add_theme_stylebox_override ("panel", style)
