extends Node

# Reference to the countdown Timer
@onready var timer = $Game_Timer
# Add a separate timer for enemy spawning
@onready var enemy_timer = $Enemy_Spawn_Timer

@export var timer_label: Label
@export var enemy_object: PackedScene 
@export var health_pack: PackedScene
@export var door_next_level_entity: PackedScene
@export var player: Node2D 
@export var tilemap: TileMap 

var countdown_time = 60*2

func _ready():
	
	global.achievedNextLevelScore.connect(SpawnDoorToNextLevel)
	
	
	timer.wait_time = 1
	timer.start()
	set_timer_label(countdown_time)

	enemy_timer.wait_time = 5  # Change this to 5 seconds
	enemy_timer.start()

	# Initial enemy spawn
	spawn_n_enemies_in_distance_range(3, 10, 15)
	spawn_health_pack_in_distance_range(5,15)

func _on_enemy_spawn_timer_timeout():
	#print("spawn enemy")
	spawn_n_enemies_in_distance_range(3, 10, 15)
	
func _on_health_spawn_timer_timeout():
	print(global.currentHealthPacks)
	if(global.currentHealthPacks <= 3):
		spawn_health_pack_in_distance_range(5,15)


func _process(delta):
	if countdown_time > 0:
		countdown_time -= delta
		set_timer_label(countdown_time)
	elif countdown_time <= 0:
		get_tree().change_scene_to_file("res://scenes/game_win.tscn")

func set_timer_label(time_left):
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	var time_text = "%02d:%02d" % [minutes, seconds]

	if timer_label:
		timer_label.text = time_text

func spawn_n_enemies_in_distance_range(N: int, min_distance: int, max_distance: int):
	if not enemy_object or not player or not tilemap:
		return

	var player_cell = tilemap.local_to_map(player.global_position)

	var spawn_positions = []

	for dx in range(-max_distance, max_distance + 1):
		for dy in range(-max_distance, max_distance + 1):
			var offset = Vector2i(dx, dy)
			var spawn_cell = player_cell + offset

			var distance = offset.length()

			if distance >= min_distance and distance <= max_distance:
				var tile_data = tilemap.get_cell_tile_data(0, spawn_cell)
				if tile_data != null:
					var spawn_pos = tilemap.map_to_local(spawn_cell) + Vector2(tilemap.tile_set.tile_size) / 2
					spawn_positions.append(spawn_pos)

	spawn_positions.shuffle()

	var enemies_to_spawn = min(N, spawn_positions.size())

	for i in range(enemies_to_spawn):
		var enemy = enemy_object.instantiate()
		enemy.global_position = spawn_positions[i]
		add_child(enemy)
		
func spawn_health_pack_in_distance_range(min_distance: int, max_distance: int):
	if not health_pack or not player or not tilemap:
		return

	# Get the player's position in tilemap coordinates
	var player_cell = tilemap.local_to_map(player.global_position)

	var spawn_positions = []

	# Iterate through the cells in the given distance range
	for dx in range(-max_distance, max_distance + 1):
		for dy in range(-max_distance, max_distance + 1):
			var offset = Vector2i(dx, dy)
			var spawn_cell = player_cell + offset

			var distance = offset.length()

			if distance >= min_distance and distance <= max_distance:
				# Get the tile data and ensure the position is walkable (tile is not blocked)
				var tile_data = tilemap.get_cell_tile_data(0, spawn_cell)
				if tile_data != null:
					# Convert the spawn position back to world coordinates
					var spawn_pos = tilemap.map_to_local(spawn_cell) + Vector2(tilemap.tile_set.tile_size) / 2
					spawn_positions.append(spawn_pos)

	# Shuffle the spawn positions to get random locations within the range
	spawn_positions.shuffle()

	# If there are valid spawn positions, spawn the health pack at a random location
	if spawn_positions.size() > 0:
		var health = health_pack.instantiate()
		health.global_position = spawn_positions[0]  # Use the first random spawn position
		add_child(health)
		
func spawn_door_3_tiles_away():
	if not door_next_level_entity or not player or not tilemap:
		return

	var player_cell = tilemap.local_to_map(player.global_position)
	var spawn_positions = []

	# Check all 8 directions at exactly 3 tiles away
	var directions = [
		Vector2i(3, 0), Vector2i(-3, 0), Vector2i(0, 3), Vector2i(0, -3),
		Vector2i(2, 2), Vector2i(-2, 2), Vector2i(2, -2), Vector2i(-2, -2)
	]

	for offset in directions:
		var spawn_cell = player_cell + offset
		var tile_data = tilemap.get_cell_tile_data(0, spawn_cell)
		if tile_data != null:
			var spawn_pos = tilemap.map_to_local(spawn_cell) + Vector2(tilemap.tile_set.tile_size) / 2
			spawn_positions.append(spawn_pos)

	spawn_positions.shuffle()

	if spawn_positions.size() > 0:
		var door = door_next_level_entity.instantiate()
		door.global_position = spawn_positions[0]
		add_child(door)

		
		
func SpawnDoorToNextLevel():
	spawn_door_3_tiles_away()
	
