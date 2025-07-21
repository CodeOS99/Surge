class_name HeldItem
extends PanelContainer

var is_mouse_in: bool = false
var idx: int

var currentSpawned: StaticBody2D

var slotT = "held"

func _ready() -> void:
	var style:StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.5, 0.5, 0.1, 0.6)
	add_theme_stylebox_override ("panel", style)

#func init(t: InvItemData, cms: Vector2, idx:int) -> void:
	#custom_minimum_size = cms
#
	#self.idx = idx

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_Q) and Input.is_key_pressed(KEY_ALT):
		if get_child_count() > 0:
			get_child(0).drop(true)
	if Input.is_action_just_released("drop") and is_mouse_in:
		if get_child_count() > 0:
			get_child(0).drop(false)
	
	if get_child_count() == 0:
		if currentSpawned:
			if is_instance_valid(currentSpawned):
				currentSpawned.queue_free()
	
	if Input.is_action_just_pressed("build"):
		if is_instance_valid(currentSpawned):
			if currentSpawned.place(): # was successful
				get_child(0).change_count(-1, false)
				if get_child_count() > 0:
					currentSpawned = get_child(0).data.building.instantiate()
					get_window().add_child(currentSpawned)

func _can_drop_data(at_position: Vector2, invItem: Variant) -> bool:
	# Always allow dropping for now, as per your original code.
	# You might want to add more specific checks here later based on crafting requirements.
	return true

func _drop_data(at_position: Vector2, invItem: Variant) -> void:
	if not (invItem is InvItemClass):
		return # Ensure we are dropping an InvItemClass
	if not (invItem.data.buildable):
		return
	print("flg")

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
		print("jfpsid")
		# If existing item and dragged item are different, swap them
		# Remove current item from this slot
		curr_item.reparent(invItem.get_parent()) # Place the current item in the dragging item's original slot
	invItem.reparent(self) # Place the dragged item in this slot
	print("yes")
	currentSpawned = invItem.data.building.instantiate()
	get_window().add_child(currentSpawned)

func _on_mouse_entered() -> void:
	var style:StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.5, 0.5, 0.3, 1)
	add_theme_stylebox_override ("panel", style)

func _on_mouse_exited() -> void:
	var style:StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.5, 0.5, 0.1, 0.6)
	add_theme_stylebox_override ("panel", style)
