extends CharacterBody2D

@onready var spruce_log_data = preload("res://Scripts/InvScripts/InvItems/spruce_log.tres")
@onready var drop_item = preload("res://Scenes/dropped_inv_item.tscn")
@onready var player_pickup_range = $player_pickup_range
@onready var cam = $Camera2D
@onready var summonLabel = $SummonLabel
@onready var weapon_collider = $Parent/weaponCollider
@onready var returnLabel = $ReturnLabel

@export var foraging_point_label: Label
@export var currInvGUI: InvGUI
@export var wheat_data: InvItemData
@export var carrot_data: InvItemData
@export var potato_data: InvItemData
@onready var player_drop_area: Control = $"PlayerDropArea"

# --- NEW UI ELEMENT EXPORTS ---
@export var health_progress_bar: ProgressBar # Drag your HealthProgressBar here
@export var stamina_progress_bar: ProgressBar # Drag your StaminaProgressBar here
@export var hunger_progress_bar: ProgressBar # Drag your HungerProgressBar here
# -----------------------------

const STAMINA_COST_FOR_ATK = 5
const STAMINA_COST_FOR_AXE = 5

const WALK_SPEED = 100.0
const RUN_SPEED = 200.0

var ANIMATED_SPRITE: AnimatedSprite2D
var axe_collider: Area2D
var child_parent: Node2D # Parent of everything so that it can be flipped

var can_move: bool = true

var can_pickup:bool = false
var pickup_obj: dropped_inv_item

var dir: int = 1

var is_in_cutscene: bool = false

# --- Player Stats ---
var health: int = 100
var max_health: int = 100

var stamina: int = 100
var max_stamina: int = 100

var hunger: int = 100
var max_hunger: int = 100

var initStrength = 100
var strengthBuffs = {
	"weapon": 0
}

var initDefence = 1
var defenceBuffs = {
	"armour": 0
}

# --- Buff Management Variables ---
var _temp_defense_buff_timer: Timer = null
var _temp_defense_buff_amount: float = 0.0
var _is_defense_buff_active: bool = false

var _temp_perception_buff_timer: Timer = null
var _temp_perception_buff_amount: float = 0.0
var _is_perception_buff_active: bool = false

var _temp_regen_tick_timer: Timer = null
var _temp_regen_duration_timer: Timer = null
var _temp_regen_amount: float = 0.0
var _is_regen_buff_active: bool = false

# --- Hunger/Stamina Timers ---
var _hunger_tick_timer: Timer = null
var _stamina_regen_timer: Timer = null

func _enter_tree() -> void:
	Globals.player = self

func _ready() -> void:
	ANIMATED_SPRITE = $Parent/AnimatedSprite2D
	axe_collider = $Parent/AxeCollider
	child_parent = $Parent

	# Initialize buff timers
	_temp_defense_buff_timer = Timer.new()
	add_child(_temp_defense_buff_timer)
	_temp_defense_buff_timer.timeout.connect(_on_defense_buff_timeout)
	_temp_defense_buff_timer.wait_time = 1.0 # Give it a wait_time so it fires
	_temp_defense_buff_timer.start() # Explicitly start

	_temp_perception_buff_timer = Timer.new()
	add_child(_temp_perception_buff_timer)
	_temp_perception_buff_timer.timeout.connect(_on_perception_buff_timeout)
	_temp_perception_buff_timer.wait_time = 1.0 # Give it a wait_time so it fires
	_temp_perception_buff_timer.start() # Explicitly start

	_temp_regen_tick_timer = Timer.new()
	add_child(_temp_regen_tick_timer)
	_temp_regen_tick_timer.wait_time = 1.0 # Tick every second
	_temp_regen_tick_timer.timeout.connect(_on_regen_tick)
	_temp_regen_tick_timer.start() # Explicitly start

	_temp_regen_duration_timer = Timer.new() # This timer controls the total duration
	add_child(_temp_regen_duration_timer)
	_temp_regen_duration_timer.timeout.connect(_on_regen_duration_timeout)
	_temp_regen_duration_timer.wait_time = 5.0 # Give it a wait_time so it fires later than tick timer
	_temp_regen_duration_timer.start() # Explicitly start
	
	# Initialize hunger and stamina timers
	_hunger_tick_timer = Timer.new()
	add_child(_hunger_tick_timer)
	_hunger_tick_timer.wait_time = 3.0 # Hunger ticks down every 3 seconds
	_hunger_tick_timer.autostart = true
	_hunger_tick_timer.timeout.connect(_on_hunger_tick)
	_hunger_tick_timer.start() # Explicitly start (even with autostart)

	_stamina_regen_timer = Timer.new()
	add_child(_stamina_regen_timer)
	_stamina_regen_timer.wait_time = 1.0 # Stamina regens every 1 second when not moving/attacking
	_stamina_regen_timer.autostart = true
	_stamina_regen_timer.timeout.connect(_on_stamina_regen_tick)
	_stamina_regen_timer.start() # Explicitly start (even with autostart)

	# Set initial max values for UI bars and update HUD
	if health_progress_bar:
		health_progress_bar.max_value = max_health
	if stamina_progress_bar:
		stamina_progress_bar.max_value = max_stamina
	if hunger_progress_bar:
		hunger_progress_bar.max_value = max_hunger

	_update_hud() # Call once to set initial UI values

func _process(delta: float) -> void:
	if not is_in_cutscene and can_move:
		if Input.is_action_pressed("pickup"):
			for area in player_pickup_range.get_overlapping_areas():
				if area.name == 'dropped_item_pickup_range':
					Globals.invGUI.add_item(area.get_parent())
		
		if Input.is_action_just_pressed("attack"):
			attack()
	
	_update_hud() # Call every frame to keep UI updated

func attack():
	# Deduct stamina for attacking
	if stamina >= STAMINA_COST_FOR_ATK and can_move: # Cost of attack
		stamina -= STAMINA_COST_FOR_ATK
		var strength = calcStrength()
		ANIMATED_SPRITE.play("attack")
		can_move = false
	else:
		ANIMATED_SPRITE.play("idle") # Or a "fail attack" animation
	_update_hud() # Update UI after stamina change

func calcStrength():
	var _str = initStrength
	for key in strengthBuffs:
		_str += strengthBuffs[key]
	
	return _str

func _physics_process(delta: float) -> void:
	if not is_in_cutscene:
		handleMovement(delta)
		handleAxe()
		move_and_collide(velocity * delta)

func handleMovement(delta: float):
	if not can_move:
		velocity = Vector2.ZERO
		return
	
	var input_vector := Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)
	
	var current_speed = 0.0
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		if Input.is_action_pressed("ctrl"):
			current_speed = RUN_SPEED
			ANIMATED_SPRITE.play("run")
		else:
			current_speed = WALK_SPEED
			ANIMATED_SPRITE.play("walk")
		
		# Deduct stamina for movement
		var stamina_cost_multiplier = 0.0
		if current_speed == RUN_SPEED:
			stamina_cost_multiplier = 2.0
		
		var cost = int(stamina_cost_multiplier * delta * 5) # 10 for running
		if stamina >= cost:
			stamina -= cost
		else:
			current_speed = WALK_SPEED
		if current_speed == 0:
			print("yes")
		velocity = current_speed * input_vector
		
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
	_update_hud() # Update UI after stamina change

func handleAxe():
	if Input.is_action_just_pressed('axe'):
		# Deduct stamina for axing
		if stamina >= STAMINA_COST_FOR_AXE:
			stamina -= STAMINA_COST_FOR_AXE
			ANIMATED_SPRITE.play('axe')
			can_move = false
		else:
			ANIMATED_SPRITE.play("idle")
		_update_hud() # Update UI after stamina change

func _on_animated_sprite_2d_animation_finished() -> void:
	if ANIMATED_SPRITE.animation in ['axe', 'hurt', 'attack']:
		can_move = true
		ANIMATED_SPRITE.play("idle")
	elif ANIMATED_SPRITE.animation == "death":
		get_tree().change_scene_to_file("res://Scenes/game_over.tscn")

func _on_animated_sprite_2d_frame_changed() -> void:
	if not ANIMATED_SPRITE:
		return

	if ANIMATED_SPRITE.animation == "axe" and ANIMATED_SPRITE.frame in [5, 6, 7]:
		axe_collider.monitoring = true
	elif ANIMATED_SPRITE.animation == "attack" and ANIMATED_SPRITE.frame in [4, 5, 6]:
		weapon_collider.monitoring = true
	else:
		axe_collider.monitoring = false
		weapon_collider.monitoring = false

func _on_axe_collider_area_entered(area: Area2D) -> void:
	if area.name == "TreeCollider":
		var tree_node = area.get_parent() # The actual Tree node

		# 1. Increment Foraging Points
		Globals.foraging_points += 1
		foraging_point_label.text = "FORAGING POINTS: " + str(Globals.foraging_points)

		# 2. Calculate Log Drops (Numerically More)
		var base_log_amount = 1
		var log_quantity_multiplier = 1.03
		var max_log_quantity = 15
		
		var final_log_quantity = round(base_log_amount * pow(log_quantity_multiplier, Globals.foraging_points))
		final_log_quantity = clamp(final_log_quantity, base_log_amount, max_log_quantity)

		# Drop the logs
		if final_log_quantity > 0:
			_spawn_dropped_item(spruce_log_data, final_log_quantity, tree_node.global_position)

		# 3. Calculate Chance-Based Drops with Quantity Scaling (Wheat, Carrot, Potato)
		var base_wheat_chance = 0.05
		var wheat_chance_per_point = 0.001
		var wheat_max_chance = 0.3
		var current_wheat_chance = min(base_wheat_chance + (Globals.foraging_points * wheat_chance_per_point), wheat_max_chance)

		var base_wheat_qty = 1
		var wheat_qty_multiplier = 1.01
		var wheat_quantity_per_drop = round(base_wheat_qty * pow(wheat_qty_multiplier, Globals.foraging_points))
		wheat_quantity_per_drop = max(1, wheat_quantity_per_drop)

		if randf() < current_wheat_chance:
			_spawn_dropped_item(wheat_data, wheat_quantity_per_drop, tree_node.global_position)

		var base_carrot_chance = 0.02
		var carrot_chance_per_point = 0.0008
		var carrot_max_chance = 0.2
		var current_carrot_chance = min(base_carrot_chance + (Globals.foraging_points * carrot_chance_per_point), carrot_max_chance)

		var base_carrot_qty = 1
		var carrot_qty_multiplier = 1.008
		var carrot_quantity_per_drop = round(base_carrot_qty * pow(carrot_qty_multiplier, Globals.foraging_points))
		carrot_quantity_per_drop = max(1, carrot_quantity_per_drop)

		if randf() < current_carrot_chance:
			_spawn_dropped_item(carrot_data, carrot_quantity_per_drop, tree_node.global_position)

		var base_potato_chance = 0.005
		var potato_chance_per_point = 0.0005
		var potato_max_chance = 0.1
		var current_potato_chance = min(base_potato_chance + (Globals.foraging_points * potato_chance_per_point), potato_max_chance)

		var base_potato_qty = 1
		var potato_qty_multiplier = 1.006
		var potato_quantity_per_drop = round(base_potato_qty * pow(potato_qty_multiplier, Globals.foraging_points))
		potato_quantity_per_drop = max(1, potato_quantity_per_drop)

		if randf() < current_potato_chance:
			_spawn_dropped_item(potato_data, potato_quantity_per_drop, tree_node.global_position)

		# 4. Remove the Tree
		tree_node.queue_free()

# Helper function to spawn a dropped item with correct data and position
func _spawn_dropped_item(item_data_template: InvItemData, count: int, spawn_pos: Vector2) -> void:
	if count <= 0: return # Don't spawn if count is zero or less

	var item_data_instance = item_data_template.duplicate()
	item_data_instance.count = count

	var dropped_item_instance = drop_item.instantiate()
	dropped_item_instance.init(item_data_instance)

	# Add to the current scene's root to ensure it's independent of the tree that's being freed
	get_tree().get_current_scene().call_deferred('add_child', dropped_item_instance)
	
	# Add a slight random offset for visual scattering
	dropped_item_instance.global_position = spawn_pos + Vector2(randf_range(-16, 16), randf_range(-16, 16))

func get_in_battle():
	is_in_cutscene = true
	ANIMATED_SPRITE.play("battleArenaTransfer")
	cam.zoom = Vector2(10, 10)
	summonLabel.visible = true
	cam.apply_shake(0.0)
	
	var t := Timer.new()
	add_child(t)
	t.wait_time = 3.0
	t.one_shot = true
	t.start()
	t.timeout.connect(goToSoulYard)

func goToSoulYard():
	Globals.transition_to_scene(get_tree(), "res://Scenes/soulyard.tscn")

func takeDamage(n: int):
	if n < 0:
		var raw_damage = abs(n) # Get the positive value of the incoming damage

		var defense = initDefence + defenceBuffs["armour"]
		var _defense_scaling_factor: float = 1.0 
		var defense_reduction_percentage = float(defense) / (float(defense) + _defense_scaling_factor)
		
		# Clamp the reduction to prevent unintended effects (e.g., healing from extremely high defense, though unlikely with this formula)
		defense_reduction_percentage = clamp(defense_reduction_percentage, 0.0, 0.95) # Cap reduction at 95% to always take at least some damage

		var effective_damage = raw_damage * (1.0 - defense_reduction_percentage)
		
		# Ensure effective_damage is at least 0 (damage cannot result in healing)
		effective_damage = max(0.0, effective_damage)
		
		# Apply the calculated effective damage to health
		health -= int(effective_damage) # Convert to integer as health is likely an integer

		# Trigger hurt animation if any raw damage was incoming, and not already playing hurt
		if raw_damage > 0 and ANIMATED_SPRITE.animation != "hurt":
			ANIMATED_SPRITE.play("hurt")
			can_move = false
	else:
		# If 'n' is positive, it's considered healing, apply directly
		health += n

	# Ensure health stays within min/max bounds
	health = clamp(health, 0, max_health) 

	# Check for death after applying damage/healing
	if health <= 0:
		die()

var is_dying = false
func die():
	# Prevent multiple death animations/scene changes
	if is_dying:
		return
	is_dying = true

	# 1. Stop Player Movement, Input, and all processing
	can_move = false # Assuming you have this flag for movement control
	set_process(false)        # Stop _process(delta)
	set_physics_process(false) # Stop _physics_process(delta)
	set_process_input(false)  # Stop _input(event)

	# 2. Play Death Animation
	if ANIMATED_SPRITE:
		ANIMATED_SPRITE.play("death") # Play your death animation

	_update_hud() # Always update UI after health changes
func _on_weapon_collider_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy_bodies"):
		body.change_health(-calcStrength())

func transition_back():
	is_in_cutscene = true
	ANIMATED_SPRITE.play("battleArenaTransfer")
	cam.zoom = Vector2(10, 10)
	returnLabel.visible = true
	cam.apply_shake(0.0)
	
	var t := Timer.new()
	add_child(t)
	t.wait_time = 3.0
	t.one_shot = true
	t.start()
	t.timeout.connect(returnFromSoulyard)

func returnFromSoulyard():
	Globals.time = 0
	Globals.transition_to_scene(get_tree(), "res://Scenes/main_game.tscn")


# --- Stamina and Hunger Tick Functions ---
func _on_hunger_tick() -> void:
	hunger -= 1 # Decrease hunger by 1
	hunger = max(0, hunger) # Don't go below 0

	if hunger <= 0:
		# Player is starving, start taking health damage
		takeDamage(-5) # Take 1 damage per hunger tick when starving
	_update_hud() # Update UI after hunger change

func _on_stamina_regen_tick() -> void:
	# Regenerate stamina if not moving or performing actions
	if velocity.length_squared() == 0 and not ANIMATED_SPRITE.animation in ['axe', 'attack', 'hurt']:
		stamina = min(stamina + 5, max_stamina) # Regenerate 5 stamina per tick
	_update_hud() # Update UI after stamina change


# --- Buff Timeout Functions ---
func _on_defense_buff_timeout() -> void:
	_is_defense_buff_active = false
	_temp_defense_buff_amount = 0.0
	# Revert defense stat changes here if you apply them directly

func _on_perception_buff_timeout() -> void:
	_is_perception_buff_active = false
	_temp_perception_buff_amount = 0.0
	# Revert perception stat changes here if you apply them directly

func _on_regen_tick() -> void:
	# This timer ticks every second for regeneration
	if _is_regen_buff_active:
		health = min(health + int(_temp_regen_amount), max_health)
		stamina = min(stamina + int(_temp_regen_amount), max_stamina)
	_update_hud() # Update UI during regen ticks

func _on_regen_duration_timeout() -> void:
	_is_regen_buff_active = false
	_temp_regen_amount = 0.0
	_temp_regen_tick_timer.stop() # Stop the periodic regen ticks


# --- The _consume_item function with Hunger and Stamina ---
func _consume_item(data: InvItemData) -> void:
	for i in range(data.count):
		if data.name == "Carrot":
			# Primary: Quick burst of Stamina and minor Health
			stamina = min(stamina + 15, max_stamina)
			health = min(health + 5, max_health)
			hunger = min(hunger + 10, max_hunger) # Minor hunger fill

			# Secondary: Temporary Perception/Foraging Buff (e.g., increased rare drop chance)
			var buff_duration = 20.0 # seconds
			var buff_strength = 0.05 # 5% increase in a relevant stat (e.g., rare drop chance)
			_apply_perception_buff(buff_duration, buff_strength)

		elif data.name == "Potato":
			# Primary: Solid Health Recovery and good Hunger Satisfaction
			health = min(health + 15, max_health)
			hunger = min(hunger + 25, max_hunger) # Good hunger fill
			stamina = min(stamina + 10, max_stamina) # Minor stamina

			# Secondary: Temporary Defense Buff (e.g., damage resistance)
			var buff_duration = 45.0 # seconds
			var buff_strength = 0.10 # 10% damage resistance
			_apply_defense_buff(buff_duration, buff_strength)
			
		elif data.name == "Bread":
			# Primary: Excellent Health and Hunger Satisfaction, moderate Stamina
			health = min(health + 30, max_health)
			hunger = min(hunger + 40, max_hunger) # Excellent hunger fill
			stamina = min(stamina + 20, max_stamina) # Moderate stamina

			# Secondary: Temporary Regeneration Buff (Health/Stamina regen per second)
			var buff_duration = 60.0 # seconds (total duration of regen)
			var regen_rate = 2.0 # 2 HP/Stamina per second
			_apply_regen_buff(buff_duration, regen_rate)
			
	_update_hud() # Update UI after consuming an item


# --- Simplified Buff Application Functions ---
func _apply_defense_buff(duration: float, strength: float) -> void:
	_is_defense_buff_active = true
	_temp_defense_buff_amount = strength
	_temp_defense_buff_timer.wait_time = duration
	_temp_defense_buff_timer.start()
	# Apply actual defense modifier here, e.g.:
	# Globals.player_defense_modifier = 1.0 + strength

func _apply_perception_buff(duration: float, strength: float) -> void:
	_is_perception_buff_active = true
	_temp_perception_buff_amount = strength
	_temp_perception_buff_timer.wait_time = duration
	_temp_perception_buff_timer.start()
	# Apply actual perception modifier here, e.g.:
	# Globals.foraging_rare_drop_chance_bonus += strength

func _apply_regen_buff(duration: float, regen_rate: float) -> void:
	_is_regen_buff_active = true
	_temp_regen_amount = regen_rate
	
	# Stop any previous regen timers to avoid overlapping buffs
	if _temp_regen_tick_timer.is_stopped():
		_temp_regen_tick_timer.start() # Start the ticking for regen
	
	_temp_regen_duration_timer.wait_time = duration
	_temp_regen_duration_timer.start() # Start the timer for the total duration


# --- NEW: Function to update all HUD elements ---
func _update_hud() -> void:
	# Update Health Bar and Label
	if health_progress_bar:
		health_progress_bar.value = health

	# Update Stamina Bar and Label
	if stamina_progress_bar:
		stamina_progress_bar.value = stamina

	# Update Hunger Bar and Label
	if hunger_progress_bar:
		hunger_progress_bar.value = hunger
