extends StaticBody2D

@onready var progBar: ProgressBar = $ProgressBar

var placed: bool = false
var isColliding: bool = true

var spawnable_resources = [preload("res://Scenes/Pickupables/coal.tscn"), preload("res://Scenes/Pickupables/iron.tscn")]
@export var coal_data: InvItemData
@export var iron_data: InvItemData

var _custom_timer_duration: float = 30.0 # This replaces 'tme'
var _custom_time_left: float = 0.0
var _custom_timer_running: bool = false

func _ready():
	# Initialize the progress bar with the custom timer's duration
	progBar.max_value = _custom_timer_duration
	_custom_time_left = _custom_timer_duration # Start with full time

func _process(delta: float) -> void:
	handle_placing()
	
	if placed and _custom_timer_running:
		_custom_time_left -= delta
		progBar.value = _custom_timer_duration - _custom_time_left # Update progress bar
		
		if _custom_time_left <= 0:
			_custom_time_left = 0.0
			_custom_timer_running = false # Stop the timer
			_on_custom_timer_timeout() # Call the timeout logic

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
	
	# Start the custom timer when placed
	_custom_start_timer(_custom_timer_duration) # Start with its full duration
	
	return true

func _custom_start_timer(duration: float) -> void:
	_custom_timer_duration = duration # Set the new total duration
	_custom_time_left = duration      # Reset time left to the new duration
	_custom_timer_running = true      # Start the timer
	progBar.max_value = _custom_timer_duration # Update progress bar max value

func _custom_stop_timer() -> void:
	_custom_timer_running = false

# This function replaces _on_timer_timeout()
func _on_custom_timer_timeout() -> void:
	if placed:
		var _res_template = spawnable_resources[randi() % spawnable_resources.size()]
		var _res = _res_template.instantiate()
		
		# Initialize item data based on its name
		if _res.name == "coal":
			_res.init(coal_data.duplicate())
		elif _res.name == "iron":
			_res.init(iron_data.duplicate())
		get_tree().get_current_scene().call_deferred("add_child", _res)
		
		var x_displacement = (randi() % 16) + 16
		if randi() % 2 == 1:
			x_displacement *= -1
		var y_displacement = (randi() % 16) + 16
		if randi() % 2 == 1:
			y_displacement *= -1
		
		_res.global_position = Vector2(self.global_position.x + x_displacement, self.global_position.y + y_displacement)
	
	# Restart the timer for the next cycle
	_custom_start_timer(_custom_timer_duration) # Restart with the original duration


# This function is called from Player.gd's _consume_item
func _consume_item(d: InvItemData):
	var efficiency_value = d.fuel_efficiency # How much time each unit of fuel provides
	var item_count = d.count                # How many units of fuel are being consumed
	var time_to_add = efficiency_value * item_count

	# If the timer isn't running, consuming fuel should start it
	# This effectively "primes" the machine to start producing
	if not _custom_timer_running:
		_custom_time_left = _custom_timer_duration # Reset to full for the first production cycle
		_custom_timer_running = true # Start the timer countdown

	# Calculate how much 'time_to_add' will push us past the next production cycle.
	# We simulate production cycles if 'time_to_add' is sufficient.
	while time_to_add >= _custom_time_left:
		# One full production cycle completes immediately
		time_to_add -= _custom_time_left # Deduct time used for this cycle
		_custom_time_left = 0.0 # Force current cycle to completion

		_on_custom_timer_timeout() # This will spawn a resource AND restart the timer (_custom_time_left resets to _custom_timer_duration)
		
		# After timeout, _custom_time_left is reset to _custom_timer_duration,
		# so we update our remaining_time_in_current_cycle for the next iteration of the loop
		_custom_time_left = _custom_timer_duration # Update for the next production cycle calculation

		if time_to_add <= 0: # If all provided time has been used up by exact or less than current cycle
			break # No more full cycles to simulate

	# After simulating all full cycles (if any), apply any remaining 'time_to_add'
	# This remaining time adds to the start of the current or next cycle.
	_custom_time_left -= time_to_add
	
	# Ensure time_left doesn't go below 0 (though the while loop should largely prevent this for full cycles)
	_custom_time_left = max(0.0, _custom_time_left) 
