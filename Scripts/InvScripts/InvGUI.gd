class_name InvGUI
extends CanvasLayer

@export var InvSlotNode = preload("res://Scenes/InvSlot.tscn")
@export var InvItemNode = preload("res://Scenes/InvItem.tscn")
@export var craftSlot = preload("res://Scenes/craft_slot.tscn")
@export var craftPreviewPanelContainer: PanelContainer
@export var crafting_ui_node: CraftingUI # Changed name for clarity and added type hint
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

# Handles adding an InvItemData (e.g., from crafting) to inventory
func add_item_data(data_to_add: InvItemData) -> void:
	if data_to_add == null:
		print("InvGUI: Invalid InvItemData to add.")
		return

	# Duplicate the data immediately so we work with an independent copy
	var item_data_copy: InvItemData = data_to_add.duplicate()

	var first_empty_slot: PanelContainer = null # Keep track of the first available empty slot
	var handled_by_stack: bool = false

	# First pass: Try to stack with existing items
	for slot_index in range(%Inv.get_child_count()):
		var slot = %Inv.get_child(slot_index) as PanelContainer
		
		if slot.get_child_count() > 0:
			var existing_inv_item_node = slot.get_child(0) as InvItemClass
			if existing_inv_item_node != null and existing_inv_item_node.data != null \
			and existing_inv_item_node.data.name == item_data_copy.name:
				# Found a stackable slot. Add count to existing inventory item's data.
				existing_inv_item_node.change_count(item_data_copy.count)
				handled_by_stack = true
				break # Item stacked, no need to check other slots

		# If we didn't stack, keep track of the first empty slot for later
		elif first_empty_slot == null:
			first_empty_slot = slot

	if handled_by_stack:
		return # Item handled, exit function

	# Second pass: If not stacked, try to add to an empty slot
	if first_empty_slot != null:
		var invItem = InvItemNode.instantiate()
		invItem.init(item_data_copy) # Use the duplicated data
		first_empty_slot.add_child(invItem)
	else:
		print("Inventory full! Cannot add item data: " + item_data_copy.name)

# This function should now trigger the craft action on the CraftingUI
func _on_button_pressed() -> void:
	# We now delegate the crafting process to the CraftingUI script.
	# The CraftingUI script is responsible for:
	# 1. Checking if a recipe is matched.
	# 2. Consuming ingredients from the crafting grid.
	# 3. Calling InvGUI.add_item_data() to add the crafted result.
	
	if crafting_ui_node:
		# Call the craft button's pressed function on the CraftingUI
		# This will internally handle recipe checking, consumption, and adding to inventory.
		crafting_ui_node._on_craft_button_pressed() 
	else:
		print("Error: CraftingUI node not assigned in InvGUI.")
