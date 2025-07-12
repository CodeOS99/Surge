extends CanvasLayer

var invSize = 16

var items_to_load = [
	"res://Scripts/InvScripts/InvItems/spruce_log.tres",
	"res://Scripts/InvScripts/InvItems/text.tres",
	"res://Scripts/InvScripts/InvItems/spruce_log.tres"
]

func _ready() -> void:
	for i in range(invSize):
		var slot = InvSlot.new()
		slot.init(InvItemData.Type.MAIN, Vector2(64, 64))
		%Inv.add_child(slot)
		
	for i in items_to_load.size():
		var item = InvItem.new()
		item.init(load(items_to_load[i]))
		%Inv.get_child(i).add_child(item)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		visible = !visible
