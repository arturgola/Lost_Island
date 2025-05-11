extends Node2D


func _on_health_pack_box_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		global.currentLevel = 2
		get_tree().change_scene_to_file("res://scenes/new_world2.tscn")
