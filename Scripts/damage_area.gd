extends Area2D

@export var damage: int = 0
@export var coolDownTime: float = 0.25

@onready var cooldownTimer: Timer= $cooldownTimer

var canAtk: bool = true

func _process(delta: float) -> void:
	if monitoring:
		for body in get_overlapping_bodies():
			if body.name == "Player" and canAtk:
				body.takeDamage(damage)
				cooldownTimer.wait_time = coolDownTime 
				cooldownTimer.start()
				canAtk = false


func _on_cooldown_timeout() -> void:
	canAtk = true
