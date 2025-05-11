extends Control

@export var scoreLabel: Label

func _ready():
	if scoreLabel:
		scoreLabel.text = "Your Score: " + str(global.enemies_killed*1.2)
	
func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://scenes/new_world.tscn")
