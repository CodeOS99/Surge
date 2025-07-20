class_name CraftingUI extends PanelContainer

# This array will hold all your CraftingRecipe resources.
# Drag all your *.tres recipe files into this array in the Godot Editor!
@export var all_crafting_recipes: Array[CraftingRecipe]

# Renamed for clarity, stores the current names in the grid
var curr_grid_name_pattern: Array[String] = []
var curr_grid_count_pattern: Array[int] = []

# Stores the CraftingRecipe resource if a match is found
var current_matched_recipe: CraftingRecipe = null

@onready var previewRect: TextureRect = $TextureRect
@onready var grid: GridContainer = %CraftGrid # Assuming this is your GridContainer holding the slots
@onready var craft_button: Button = %CraftButton # Assuming you have a button to trigger craft

func _ready() -> void:
	# Initialize the crafting grid pattern array with "none" for all 9 slots
	for i in range(9):
		curr_grid_name_pattern.append("none")
		curr_grid_count_pattern.append(1)

	# Connect the craft button's pressed signal (you'll need to add a Button node)
	if craft_button:
		craft_button.pressed.connect(Callable(self, "_on_craft_button_pressed"))

func _process(delta: float) -> void:
	# This function will run every frame to check the crafting grid

	_read_grid_items()          # Read what items are currently in the grid
	current_matched_recipe = _match_recipe() # Find if any recipe matches
	_update_preview_and_button() # Update the preview texture and button state

# Populates curr_grid_pattern array with item names from the grid slots
func _read_grid_items() -> void:
	# Make sure curr_grid_pattern is always 9 elements long and reset for each read
	# We clear and re-add "none" to ensure any removed items are reflected.
	curr_grid_name_pattern.clear()
	curr_grid_count_pattern.clear()
	for i in range(9):
		curr_grid_name_pattern.append("none")
		curr_grid_count_pattern.append(1)

	for slot_idx in range(grid.get_child_count()):
		var slot = grid.get_child(slot_idx)
		if slot.get_child_count() > 0:
			var item_in_slot = slot.get_child(0) # Assumes the InvItemClass is the first child
			if item_in_slot is InvItemClass and item_in_slot.data != null:
				curr_grid_name_pattern[slot_idx] = item_in_slot.data.name
				curr_grid_count_pattern[slot_idx] = item_in_slot.data.count
			else:
				curr_grid_name_pattern[slot_idx] = "none"
				curr_grid_count_pattern[slot_idx] = 1
		else:
			curr_grid_name_pattern[slot_idx] = "none"
			curr_grid_count_pattern[slot_idx] = 1
# Matches the current grid pattern against your defined recipes
func _match_recipe() -> CraftingRecipe: # Returns a CraftingRecipe resource or null
	for recipe in all_crafting_recipes:
		if recipe.pattern.size() != curr_grid_name_pattern.size():
			push_warning("Recipe pattern size mismatch for recipe: ", recipe.recipe_name)
			continue # Skip this recipe if its pattern size is wrong
		
		var _match = true
		for i in range(curr_grid_name_pattern.size()):
			if recipe.pattern[i] != curr_grid_name_pattern[i] or recipe.item_counts_in_pattern[i] != curr_grid_count_pattern[i]:
				_match = false
				break # Mismatch found, move to next recipe
		
		if _match:
			return recipe # Found a match!
			
	return null # No recipe matched

# Updates the preview texture and enables/disables the craft button
func _update_preview_and_button() -> void:
	if current_matched_recipe != null:
		previewRect.texture = current_matched_recipe.result_item_template.texture
		if craft_button:
			craft_button.disabled = false # Enable craft button if recipe matched
	else:
		previewRect.texture = null
		if craft_button:
			craft_button.disabled = true # Disable craft button if no recipe matched

# Called when the Craft button is pressed
func _on_craft_button_pressed() -> void:
	if current_matched_recipe == null:
		print("No recipe to craft.")
		return

	# 1. Consume ingredients from the crafting grid
	for slot_idx in range(grid.get_child_count()):
		var slot = grid.get_child(slot_idx)
		if slot.get_child_count() > 0:
			var item_in_slot = slot.get_child(0) as InvItemClass
			# Only consume if the item is part of the matched pattern
			# This ensures we don't accidentally consume an item that's in the grid but not part of the current recipe
			if item_in_slot and current_matched_recipe.pattern[slot_idx] == item_in_slot.data.name:
				item_in_slot.change_count(-curr_grid_count_pattern[slot_idx], false) # Consumes one item from this slot
	
	# 2. Add the crafted item to the player's inventory
	# You'll need to ensure Globals.player and its get_inventory_gui() method exist and are correctly set up.
	var player_inventory_gui = Globals.invGUI
	if player_inventory_gui:
		# Create a NEW, DUPLICATED InvItemData for the crafted item instance
		var crafted_item_data = current_matched_recipe.result_item_template.duplicate()
		crafted_item_data.count = current_matched_recipe.result_count
		
		# Create a temporary 'dropped_inv_item' to leverage InvGUI's existing add_item logic
		# This is a convenient way to reuse your existing inventory pickup system.
		var temp_dropped_item = preload("res://Scenes/dropped_inv_item.tscn").instantiate()
		temp_dropped_item.init(crafted_item_data)
		
		player_inventory_gui.add_item(temp_dropped_item) 
		# Remember: add_item is responsible for queue_free()'ing temp_dropped_item if successful.
		# Consider how you'll handle it if the inventory is full (temp_dropped_item won't be freed).
	else:
		print("Error: Player inventory GUI not found to add crafted item.")

	# 3. Re-read the grid and update the preview after crafting (items might have been consumed)
	# The next _process frame will handle the update anyway, but calling it directly
	# ensures immediate visual feedback.
	_read_grid_items()
	current_matched_recipe = _match_recipe()
	_update_preview_and_button()
