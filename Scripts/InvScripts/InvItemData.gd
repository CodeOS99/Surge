class_name InvItemData
extends Resource

enum Type  {DEFENCE, SWORD, ACCESSORY, MAIN, CONSUMABLE, FUEL, NONE}

@export var type: Type
@export var name: String
@export_multiline var description: String
@export var texture: Texture2D

@export var count: int = 1

@export var buildable: bool = false
@export var building: PackedScene = null # It should have an animated sprite with default name

@export var is_weapon: bool = false
@export var strength: int = 0

@export var defence:int = 0

@export var fuel_efficiency: float = 0.0 # how good a fuel it is
