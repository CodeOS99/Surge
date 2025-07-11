extends CharacterBody2D

const WALK_SPEED = 100.0
const RUN_SPEED = 200.0

var ANIMATED_SPRITE: AnimatedSprite2D
var axe_collider: Area2D
var child_parent: Node2D # Parent of everything so that it can be flipped

var can_move: bool = true

func _ready() -> void:
	ANIMATED_SPRITE = $Parent/AnimatedSprite2D
	axe_collider = $Parent/AxeCollider
	child_parent = $Parent

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
		else:
			child_parent.scale.x = abs(child_parent.scale.x)
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
		area.get_parent().queue_free()
