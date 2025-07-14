extends PanelContainer

var currRecipe: Array

var twoLog: InvItemData = preload("res://Scripts/InvScripts/InvItems/test.tres")
var oneLog: InvItemData = preload("res://Scripts/InvScripts/InvItems/wheat.tres")

@onready var previewRect = $TextureRect
func _ready() -> void:
	for i in range(9):
		currRecipe.append('none')

func updatePreview(idx: int, newData: InvItemData):
	currRecipe[idx] = newData.name
	print(currRecipe)
	if currRecipe[0] == "Log":
		if currRecipe[1] == "Log":
			print("two log")
		print("one log")
	
	if currentItem() != null:
		previewRect.texture = currentItem().texture
	else:
		previewRect.texture = null

func currentItem() -> InvItemData: # TODO replace this garbage
	if currRecipe[0] == "Log":
		if currRecipe[1] == "Log":
			return twoLog
		return oneLog
	return null
