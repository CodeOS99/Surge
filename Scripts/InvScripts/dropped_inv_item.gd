class_name dropped_inv_item
extends StaticBody2D

@export var data: InvItemData

@onready var count_label := $Label
@onready var sprite := $Sprite2D

func init(d: InvItemData) -> void:
	data = d

func _ready() -> void:
	sprite.texture = data.texture
	count_label.text = str(data.count)

func change_count(n: int):
	data.count += n
	count_label.text = str(data.count)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name != "dropped_item_pickup_range":
		return

	var other = area.get_parent()
	if other.data.name != self.data.name:
		return

	# Prevent both absorbing each other by using instance_id
	if self.get_instance_id() > other.get_instance_id():
		return

	change_count(other.data.count)
	other.queue_free()
