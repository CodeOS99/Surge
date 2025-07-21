extends Panel

# You might need a way to reference your Player script to call a method like _consume_item
# @onready var min_ext = get_parent() # If PlayerDropArea is direct child of Player
@export var min_ext: StaticBody2D # Adjust path if needed

func _can_drop_data(position: Vector2, node: Variant) -> bool:
	return true

func _drop_data(position: Vector2, node: Variant) -> void:
	var data: InvItemData = node.data
	print(data.type)
	if is_instance_valid(min_ext) and min_ext.has_method("_consume_item"):
		print("we are")
		min_ext._consume_item(data)
	
	node.queue_free()
