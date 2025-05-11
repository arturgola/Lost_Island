extends CharacterBody2D

class_name Player

signal healthChanged

# Remove @onready for basic variables
var maxHealth = 100
var health = maxHealth
var player_alive = true
var attack_ip = false
var speed = 100
var current_dir = "none"

# Initialize other variables
@onready var enemy_inattack_range = false
@onready var enemy_attack_cooldown = true

var back_walk_frames = [2,5]
var front_walk_frames = [2,5]
var side_walk_frames = [2,5]

func _on_damage_flash_timer_timeout():
	$AnimatedSprite2D.modulate = Color(1, 1, 1)
	$AnimatedSprite2D.scale = Vector2(1, 1)

func _ready():
	add_to_group("Player")
	$AnimatedSprite2D.play("front_idle")
	$attack_cooldown.timeout.connect(on_attack_cooldown_timeout)
	$damage_flash_timer.timeout.connect(_on_damage_flash_timer_timeout)


func _physics_process(delta):
	if not player_alive:
		return
		
	player_movement(delta)
	enemy_attack()
	attack()
	
	if health <= 0 and player_alive:
		player_alive = false #add here end screen
		health = 0
		
		$AnimatedSprite2D.play("death", 0.3)
		await $AnimatedSprite2D.animation_finished
		
		print("ready")
		
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
		

func player_movement(delta):
	if attack_ip:  # Prevent movement when attacking
		velocity.x = 0
		velocity.y = 0
		return  # Exit the function early to stop movement

	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_amin(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_amin(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_amin(1)
		velocity.y = speed
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_amin(1)
		velocity.y = -speed
		velocity.x = 0
	else: 
		play_amin(0)
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()


func play_amin(movement):
	if not player_alive:
		# If the player is dead, don't override the death animation
		return
		
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("side_idle")

	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("side_idle")

	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("front_idle")

	if dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("back_idle")

func player():
	pass

func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_inattack_range = true

func _on_player_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_inattack_range = false

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health -= 10
		healthChanged.emit()
		enemy_attack_cooldown = false
		$attack_cooldown.start()

		# Flash red
		$AnimatedSprite2D.modulate = Color(1, 0, 0) # Red
		$AnimatedSprite2D.scale = Vector2(1.2, 1.2)
		$damage_flash_timer.start()
		
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_RECEIVE_DAMAGE)

		#print("Player Health: ", health)


func on_attack_cooldown_timeout():
	enemy_attack_cooldown = true

func attack():
	var dir = current_dir
	
	if Input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		attack_ip = true

		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_attack",1.5)
			$deal_attack_timer.start()

		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_attack",1.5)
			$deal_attack_timer.start()

		if dir == "down":
			$AnimatedSprite2D.play("front_attack",1.5)
			$deal_attack_timer.start()

		if dir == "up":
			$AnimatedSprite2D.play("back_attack",1.5)
			$deal_attack_timer.start()

func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_ip = false

func current_camera():
	if global.current_scene == "world":
		$world_camera.enable = true
		$cliffside_camera.enabled = false
	elif global.current_scene == "cliff_side":
		$world_camera.enable = false
		$cliffside_camera.enabled = true

func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation == "back_idle": return
	if $AnimatedSprite2D.animation == "death": return
	if $AnimatedSprite2D.animation == "front_idle": return
	if $AnimatedSprite2D.animation == "side_idle": return
	
	if $AnimatedSprite2D.animation == "back_attack": 
		if $AnimatedSprite2D.frame == 1:
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_ATTACK)
		
	if $AnimatedSprite2D.animation == "front_attack": 
		if $AnimatedSprite2D.frame == 1:
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_ATTACK)
	
	if $AnimatedSprite2D.animation == "side_attack":
		if $AnimatedSprite2D.frame == 1:
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_ATTACK)

	if $AnimatedSprite2D.animation == "back_walk":
		if $AnimatedSprite2D.frame in back_walk_frames: 
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_WALK)
	if $AnimatedSprite2D.animation == "front_walk":
		if $AnimatedSprite2D.frame in front_walk_frames: 
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_WALK)
	if $AnimatedSprite2D.animation == "side_walk":
		if $AnimatedSprite2D.frame in side_walk_frames: 
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_WALK)
