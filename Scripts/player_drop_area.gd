extends Control

# You might need a way to reference your Player script to call a method like _consume_item
# @onready var player_script = get_parent() # If PlayerDropArea is direct child of Player
@onready var player_script = get_node("../") # Adjust path if needed

func _can_drop_data(position: Vector2, node: Variant) -> bool:
	var data: InvItemData = node.data
	if data.type == InvItemData.Type.CONSUMABLE:
		print("PlayerDropArea can consume: ", data.name)
		return true
	return false

func _drop_data(position: Vector2, node: Variant) -> void:
	var data: InvItemData = node.data
	if data.type == InvItemData.Type.CONSUMABLE:
		print("Consumable item '", data.name, "' dropped on player drop area.")
		
		# Call the consume function on the main Player script
		if is_instance_valid(player_script) and player_script.has_method("_consume_item"):
			player_script._consume_item(data)
		
		node.queue_free()
	else:
		print("Non-consumable item dropped on player drop area or invalid data.")
