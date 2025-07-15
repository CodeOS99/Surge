extends StaticBody2D

var placed: bool = false
var isColliding: bool = true

func _process(delta: float) -> void:
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
	$Label.visible = true
	$Confirm.visible = false
	$Cancel.visible = false
	return true
