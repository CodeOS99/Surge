extends CharacterBody2D

@onready var parentNode = $parent
@onready var animated_sprite = $parent/AnimatedSprite2D
@onready var damage_area = $parent/damage_area
@onready var healthBar = $healthBar


var speed:int = 75
var canMove:bool = true
var reboundWaitTime: float = 0.5

var health: int = 100
var dazed:bool = false

func _ready() -> void:
	healthBar.max_value = health
	healthBar.value = healthBar.max_value

func _physics_process(delta: float) -> void:
	var pPos: Vector2 = Globals.player.global_position
	var direction: Vector2 = (pPos - global_position).normalized()
	if canMove:
		velocity = direction * speed
		move_and_slide()

		# Flip sprite based on direction
		if direction.x < 0:
			parentNode.scale.x = -1
		else:
			parentNode.scale.x = 1
	else:
		if dazed:
			velocity = -direction * 2 *speed
		else:
			velocity = Vector2.ZERO
		move_and_slide()

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.name == "Player" and canMove:
		animated_sprite.play("attack")
		canMove = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		animated_sprite.play("dazed")
		dazed = true
		#var tween = get_tree().create_tween()
		#tween.tween_property($Sprite, "transform.position", Color.RED, 1)
		#tween.tween_property($Sprite, "scale", Vector2(), 1)
		#tween.tween_callback($Sprite.queue_free)
	elif animated_sprite.animation == "dazed":
		makeNormalAfterRebound()
	
func makeNormalAfterRebound():
	animated_sprite.play("walk")
	canMove = true
	dazed = false

func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite:
		if animated_sprite.animation == "attack" and animated_sprite.frame in [4, 5, 6]:
			damage_area.monitoring = true
		else:
			damage_area.monitoring = false

func set_health(n: int):
	health = n

func change_health(n: int):
	health -= n
	healthBar.value = health
