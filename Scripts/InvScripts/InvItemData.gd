class_name InvItemData
extends Resource

enum Type  {HELMET, BREASTPLATE, LEGGINGS, BOOTS, SWORD, ACCESSORY, MAIN}

@export var type: Type
@export var name: String
@export_multiline var description: String
@export var texture: Texture2D
@export var count: int = 1
