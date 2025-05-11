extends CharacterBody2D

var speed = 40
var player_chase = true
var player = null

var health = 100
var player_inattack_zone = false
var can_take_damage = true
var movement_blocked = false  # Variable to track if movement is blocked

func _on_damage_flash_timer_timeout():
	$AnimatedSprite2D.modulate = Color(1, 1, 1)
	$AnimatedSprite2D.scale = Vector2(1, 1)

func _ready():
	$damage_flash_timer.timeout.connect(_on_damage_flash_timer_timeout)
	
	player = get_node_or_null("/root/World/player")

func _physics_process(delta):
	deal_with_damage()

	if player_chase and not movement_blocked:  # Check if movement is not blocked
		var direction = (player.position - position).normalized()  # Normalizes the direction vector
		position += direction * speed * delta  # Moves the enemy at a constant speed (scaled by delta for frame-rate independence)
		$AnimatedSprite2D.play("walk")
		
		if(player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else: 
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("idle")

func enemy():
	pass

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false

func deal_with_damage():
	if player_inattack_zone and global.player_current_attack == true:
		if can_take_damage == true:
			$AnimatedSprite2D.modulate = Color(1, 0, 0)  # Red
			$AnimatedSprite2D.scale = Vector2(1.2, 1.2)
			$damage_flash_timer.start()
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_RECEIVE_DAMAGE)
			health -= 100
			$take_damage_cooldown.start()
			can_take_damage = false
			movement_blocked = true  # Block movement when damage is taken
			# Start a timer to unblock movement after 0.5 seconds
			await $take_damage_cooldown.timeout 
			movement_blocked = false  # Unblock movement after cooldown
		if health < 0:
			global.update_enemy_counter()
			self.queue_free()

func _on_take_damage_cooldown_timeout():
	can_take_damage = true
