class_name InvItem
extends TextureRect

@export var data: InvItemData
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

func increment_count(n: int) :
	data.count += n
	count_label.text = str(data.count)
