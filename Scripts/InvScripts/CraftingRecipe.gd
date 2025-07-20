class_name CraftingRecipe extends Resource

@export var recipe_name: String = "New Recipe"
@export_multiline var recipe_description: String = ""

# name or none
@export var pattern: Array[String] = [
	"none", "none", "none",
	"none", "none", "none",
	"none", "none", "none"
]

@export var result_item_template: InvItemData

@export var result_count: int = 1

# Dictionary to hold the *exact* count needed for each item in the pattern.
# Format: {idx: count}
@export var item_counts_in_pattern: Array[int] = [
	1, 1, 1,
	1, 1, 1,
	1, 1, 1
]
