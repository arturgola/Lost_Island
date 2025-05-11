extends Control


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")



func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://scenes/new_world.tscn")
