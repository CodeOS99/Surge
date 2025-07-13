class_name InvItemClass
extends TextureRect

@export var data: InvItemData

var dropped_inv_item = preload("res://Scenes/dropped_inv_item.tscn")

var count_label: Label

func init(d: InvItemData) -> void:
	data = d
	count_label = Label.new()
	count_label.text = str(data.count)
	add_child(count_label)

func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture = data.texture
	tooltip_text = "%s\n%s" % [data.name, data.description]

func _get_drag_data(at_position: Vector2) -> Variant:
	set_drag_preview(make_drag_preview(at_position))
	return self

func make_drag_preview(at_position: Vector2):
	var t = TextureRect.new()
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture = data.texture
	t.custom_minimum_size = self.size
	t.modulate.a = 0.5
	t.position = Vector2(-at_position)
	
	var c = Control.new()
	c.add_child(t)
	
	return c

func change_count(n: int):
	data.count += n
	
	if data.count <= 0:
		var dropped = dropped_inv_item.instantiate()
		dropped.position = Globals.player.global_position
		dropped.init(data)
		get_window().add_child(dropped)
		dropped.change_count(1-dropped.data.count)
		
		self.queue_free()
	
	count_label.text = str(data.count)
	
func drop(should_drop_all: bool):
	if not should_drop_all:
		self.global_position = Globals.player.global_position
		change_count(-1)
