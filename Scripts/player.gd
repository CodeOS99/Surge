extends CharacterBody2D

@onready var spruce_log_data = preload("res://Scripts/InvScripts/InvItems/spruce_log.tres")
@onready var drop_item = preload("res://Scenes/dropped_inv_item.tscn")
@onready var player_pickup_range = $player_pickup_range

const WALK_SPEED = 100.0
const RUN_SPEED = 200.0

var ANIMATED_SPRITE: AnimatedSprite2D
var axe_collider: Area2D
var child_parent: Node2D # Parent of everything so that it can be flipped

var can_move: bool = true

var can_pickup:bool = false
var pickup_obj: dropped_inv_item

var dir: int = 1

func _enter_tree() -> void:
	Globals.player = self

func _ready() -> void:
	ANIMATED_SPRITE = $Parent/AnimatedSprite2D
	axe_collider = $Parent/AxeCollider
	child_parent = $Parent

func _process(delta: float) -> void:
	if Input.is_action_pressed("pickup"):
		for area in player_pickup_range.get_overlapping_areas():
			if area.name == 'dropped_item_pickup_range':
				Globals.invGUI.add_item(area.get_parent())

func _physics_process(delta: float) -> void:
	handleMovement()
	handleAxe()
	move_and_slide()

func handleMovement():
	if not can_move: # If the player can't move, eg. axe
		velocity = Vector2.ZERO
		return
	
	var input_vector := Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)
	
	if input_vector.length() > 0: # If anything is actually pressed
		input_vector = input_vector.normalized() # Normalize speed
		if Input.is_action_pressed("ctrl"): # If running, user run speed
			velocity = RUN_SPEED * input_vector
			ANIMATED_SPRITE.play("run")
		else:
			velocity = WALK_SPEED * input_vector
			ANIMATED_SPRITE.play("walk")
		
		# Flip
		if input_vector.x < 0:
			child_parent.scale.x = -abs(child_parent.scale.x)
			dir = -1
		else:
			child_parent.scale.x = abs(child_parent.scale.x)
			dir = 1
	else:
		velocity = velocity.move_toward(Vector2.ZERO, WALK_SPEED)
		if ANIMATED_SPRITE.animation != "idle":
			ANIMATED_SPRITE.play("idle")

func handleAxe():
	if Input.is_key_pressed(KEY_E):
		ANIMATED_SPRITE.play('axe')
		can_move = false # stop player's

func _on_animated_sprite_2d_animation_finished() -> void:
	if ANIMATED_SPRITE.animation == 'axe': # allow movement again
		can_move = true
		ANIMATED_SPRITE.play("idle")

func _on_animated_sprite_2d_frame_changed() -> void:
	if not ANIMATED_SPRITE:
		return

	if ANIMATED_SPRITE.animation == "axe" and ANIMATED_SPRITE.frame in [5, 6, 7]:
		axe_collider.monitoring = true
	else:
		axe_collider.monitoring = false

func _on_axe_collider_area_entered(area: Area2D) -> void:
	if area.name == "TreeCollider":
		var log_inv_item = drop_item.instantiate()
		log_inv_item.init(spruce_log_data.duplicate())
		get_window().call_deferred("add_child", log_inv_item)
		log_inv_item.global_position = area.get_parent().global_position
		area.get_parent().queue_free()
