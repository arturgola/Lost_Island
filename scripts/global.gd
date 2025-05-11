extends Node

var player_current_attack = false
var currentLevel = 1

var current_scene = "world" #world cliff_side
var transition_scene = false

var enemies_killed = 0
var score_label : Label

var maxHealthPacks = 3
var currentHealthPacks = 0

var score_to_unlock_next_level = 25

var next_level_door_unlocked = false

signal achievedNextLevelScore

var player_exit_cliffside_posx = 0
var player_exit_cliffside_posy = 0
var player_start_posx = 0
var player_start_posy = 0

var rng = RandomNumberGenerator.new()
		
		
func init_score_label():
	score_label = get_tree().current_scene.get_node("UI/ScoreLabel")
	if score_label:
		score_label.text = "Score: " + str(enemies_killed*1.2)
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
	if enemies_killed*1.2 >= score_to_unlock_next_level and currentLevel == 1 and not next_level_door_unlocked:
		achievedNextLevelScore.emit()
		next_level_door_unlocked = true
	if score_label:
		score_label.text = "Score: " + str(enemies_killed*1.2)
	#print("Enemies killed: ", global.enemies_killed)
