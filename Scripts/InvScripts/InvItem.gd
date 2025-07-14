class_name InvItemClass
extends TextureRect

signal drag_started

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
	if data.count <= 0: return null # Don't allow dragging if count is zero or less
	var drag_data_item: InvItemClass
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		# Right-click: Drag a single item
		if data.count > 0:
			var single_item_data = data.duplicate()
			single_item_data.count = 1
			drag_data_item = InvItemClass.new() # InvItemNode is preloaded in InvGUI
			drag_data_item.init(single_item_data)
			get_parent().add_child(drag_data_item)
			drag_data_item.get_parent() # This is needed for the drag preview to work correctly sometimes

			set_drag_preview(make_drag_preview(at_position, 1))

			# Reduce the count of the original item
			change_count(-1, false) # Pass false to prevent dropping a physical item when dragging one out
			if get_parent().slotT == "craft" and self.data.count == 1: # magic word but its 10:11 so idc
				var n = InvItemData.new()
				n.type = InvItemData.Type.NONE
				n.name = "none"
				get_parent().recipe_changed.emit(get_parent().idx, n)

			return drag_data_item
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Left-click: Drag the entire stack
		set_drag_preview(make_drag_preview(at_position, data.count))
		if get_parent().slotT == "craft": # magic word but its 10:11 so idc
			var n = InvItemData.new()
			n.type = InvItemData.Type.NONE
			n.name = "none"
			get_parent().recipe_changed.emit(get_parent().idx, n)
		# Important: Don't remove the item from its parent immediately.
		# This will be handled in _drop_data of the target slot.
		return self
	return null

	
func make_drag_preview(at_position: Vector2, count_to_show: int):
	var t = TextureRect.new()
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture = data.texture
	t.custom_minimum_size = self.size
	t.modulate.a = 0.5
	t.position = Vector2(-at_position)

	var count_preview_label = Label.new()
	count_preview_label.text = str(count_to_show)
	count_preview_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	count_preview_label.add_theme_font_size_override("font_size", 20) # Adjust font size as needed
	count_preview_label.add_theme_color_override("font_color", Color(1, 1, 1))
	count_preview_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	count_preview_label.add_theme_constant_override("shadow_offset_x", 1)
	count_preview_label.add_theme_constant_override("shadow_offset_y", 1)

	var c = Control.new()
	c.add_child(t)
	c.add_child(count_preview_label)

	return c

func change_count(n: int, should_drop_physically:bool = true):
	data.count += n
	
	if n < 0 and should_drop_physically:
		var dropped = dropped_inv_item.instantiate()
		dropped.position = Globals.player.global_position
		dropped.init(data.duplicate())
		get_window().add_child(dropped)
		dropped.change_count(-n-dropped.data.count) # -n since n < 0 if we are dropping something 
	
	if data.count <= 0:
		self.queue_free()

	count_label.text = str(data.count)
	
func drop(should_drop_all: bool):
	if not should_drop_all:
		change_count(-1)
	if should_drop_all:
		change_count(-data.count)
