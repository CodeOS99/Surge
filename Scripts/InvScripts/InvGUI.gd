class_name InvGUI
extends CanvasLayer

@export var InvSlotNode = preload("res://Scenes/InvSlot.tscn")
@export var InvItemNode = preload("res://Scenes/InvItem.tscn")
@export var craftSlot = preload("res://Scenes/craft_slot.tscn")
@export var craftPreviewPanelContainer: PanelContainer

var invSize = 16
var craftSize = 9
#
#var items_to_load = [
	#"res://Scripts/InvScripts/InvItems/spruce_log.tres",
	#"res://Scripts/InvScripts/InvItems/text.tres",
	#"res://Scripts/InvScripts/InvItems/spruce_log.tres"
#]

func _ready() -> void:
	Globals.invGUI = self
	for i in range(invSize):
		var slot = InvSlotNode.instantiate()
		slot.init(InvItemData.Type.MAIN, Vector2(64, 64))
		%Inv.add_child(slot)
		
	for i in range(craftSize):
		var slot = craftSlot.instantiate()
		slot.init(null, Vector2(64, 64), i)
		%CraftGrid.add_child(slot)
		slot.recipe_changed.connect(craftPreviewPanelContainer.updatePreview)
		
	#for i in items_to_load.size():
		#var item = InvItemNode.instantiate()
		#item.init(load(items_to_load[i]))
		#%Inv.get_child(i).add_child(item)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		visible = !visible

func add_item(item: dropped_inv_item):
	var item_data_to_add: InvItemData = item.data.duplicate()

	var first_empty_slot: PanelContainer = null

	for slot_index in range(%Inv.get_child_count()):
		var slot = %Inv.get_child(slot_index) # Get the slot by index for clear ordering

		if slot.get_child_count() == 0:
			if first_empty_slot == null: # Only set the first empty slot found
				first_empty_slot = slot
			continue # Continue checking for stackable items first

		# Check if item can stack
		var existing_inv_item_node = slot.get_child(0) as Control # Assuming InvItemNode extends Control
		if existing_inv_item_node != null and existing_inv_item_node.data.name == item_data_to_add.name:
			# Item can stack
			existing_inv_item_node.change_count(item_data_to_add.count)
			item.queue_free() # ALWAYS free the dropped item node if it's handled
			return # Item handled, exit function

	# If we reached here, no stackable slot was found.
	# Try to add to the first empty slot found.
	if first_empty_slot != null:
		var invItem = InvItemNode.instantiate()
		invItem.init(item_data_to_add) # Use the duplicated data we created at the start
		first_empty_slot.add_child(invItem)
		item.queue_free() # ALWAYS free the dropped item node if it's handled
	else:
		return # Exit, as inventory is full

func add_item_data(dat: InvItemData):
	var item_data_to_add: InvItemData = dat.duplicate()

	var first_empty_slot: PanelContainer = null

	for slot_index in range(%Inv.get_child_count()):
		var slot = %Inv.get_child(slot_index) # Get the slot by index for clear ordering

		if slot.get_child_count() == 0:
			if first_empty_slot == null: # Only set the first empty slot found
				first_empty_slot = slot
			continue # Continue checking for stackable items first

		# Check if item can stack
		var existing_inv_item_node = slot.get_child(0) as Control # Assuming InvItemNode extends Control
		if existing_inv_item_node != null and existing_inv_item_node.data.name == item_data_to_add.name:
			# Item can stack
			existing_inv_item_node.change_count(item_data_to_add.count)
			return # Item handled, exit function

	# If we reached here, no stackable slot was found.
	# Try to add to the first empty slot found.
	if first_empty_slot != null:
		var invItem = InvItemNode.instantiate()
		invItem.init(item_data_to_add) # Use the duplicated data we created at the start
		first_empty_slot.add_child(invItem)
	else:
		return # Exit, as inventory is full

func _on_button_pressed() -> void:
	add_item(craftPreviewPanelContainer.currentItem())
