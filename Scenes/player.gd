extends CharacterBody2D

const WALK_SPEED = 100.0
const RUN_SPEED = 200.0

@onready
var ANIMATED_SPRITE := $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input_vector := Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		if Input.is_action_pressed("ctrl"):
			velocity = RUN_SPEED*input_vector
			ANIMATED_SPRITE.animation = "run"
		else:
			velocity = WALK_SPEED*input_vector
			ANIMATED_SPRITE.animation = "walk"
		
		if input_vector.x > 0:
			ANIMATED_SPRITE.flip_h = false
		else:
			ANIMATED_SPRITE.flip_h = true
	else:
		velocity = velocity.move_toward(Vector2.ZERO, WALK_SPEED)
		ANIMATED_SPRITE.animation = "idle"
	
	move_and_slide()
