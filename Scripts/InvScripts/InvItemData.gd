class_name InvItemData
extends Resource

enum Type  {HELMET, BREASTPLATE, LEGGINGS, BOOTS, SWORD, ACCESSORY, MAIN, CONSUMABLE, NONE}

@export var type: Type
@export var name: String
@export_multiline var description: String
@export var texture: Texture2D

@export var count: int = 1

@export var buildable: bool = false
@export var building: PackedScene = null # It should have an animated sprite with default name

@export var is_weapon: bool = false
@export var strength: int = 0
