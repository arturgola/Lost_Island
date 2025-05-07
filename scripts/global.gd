extends Node

var player_current_attack = false

var current_scene = "world" #world cliff_side
var transition_scene = false

var enemies_killed = 0
var label_enemies_killed

var player_exit_cliffside_posx = 0
var player_exit_cliffside_posy = 0
var player_start_posx = 0
var player_start_posy = 0

var rng = RandomNumberGenerator.new()

func _ready():
	label_enemies_killed = get_tree().root.get_node("world/UI/KillCounterLabel")
	if label_enemies_killed:
		label_enemies_killed.text = "Enemies Killed: 0"
	else:
		print("❌ Label not found!")

func finish_changescenes():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "world":
			current_scene = "cliff_side"
		else:
			current_scene = "world"

func update_enemy_counter():
	enemies_killed += 1
	label_enemies_killed.text = "Enemies Killed: " + str(enemies_killed)
	print("Enemies killed: ", global.enemies_killed)
