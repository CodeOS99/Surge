extends StaticBody2D

@onready var progBar: ProgressBar = $ProgressBar
@onready var timer: Timer = $Timer

var placed: bool = false
var isColliding: bool = true

var spawnable_resources = [preload("res://Scenes/Pickupables/coal.tscn"), preload("res://Scenes/Pickupables/iron.tscn"), preload("res://Scenes/Pickupables/gold.tscn")]
@export var coal_data: InvItemData
@export var iron_data: InvItemData
@export var gold_data: InvItemData

func _ready():
	progBar.max_value = timer.wait_time

func _process(delta: float) -> void:
	handle_placing()
	if placed:
		progBar.value = timer.wait_time - timer.time_left

func handle_placing():
	if not placed:
		global_position = Vector2(Globals.player.global_position.x + Globals.player.dir * 50, Globals.player.global_position.y)
	
		var flag = false
		for ar in $Area2D.get_overlapping_areas():
			if ar.is_in_group("buildingColliders"):
				isColliding = true
				flag = true
		
		if not flag:
			isColliding = false
		
		if isColliding:
			$Confirm.visible = false
			$Cancel.visible = true
		else:
			$Confirm.visible = true
			$Cancel.visible = false

func place():	
	if isColliding:
		return false

	modulate.a = 255
	placed = true
	$Confirm.visible = false
	$Cancel.visible = false
	timer.start()
	return true

func _on_timer_timeout() -> void:
	if placed:
		var _res = spawnable_resources[randi() % len(spawnable_resources)].instantiate()
		get_window().add_child.call_deferred(_res)
		var x_displacement = (randi()%16) + 16
		if randi()%2 == 1:
			x_displacement *= -1
		var y_displacement = (randi()%16) + 16
		if randi()%2 == 1:
			y_displacement *= -1
		
		if _res.name == "coal":
			_res.init(coal_data.duplicate())
		elif _res.name == "iron":
			_res.init(iron_data.duplicate())
		elif _res.name == "gold":
			_res.init(gold_data.duplicate())

		_res.global_position = Vector2(self.global_position.x + x_displacement, self.global_position.y + y_displacement)
