extends Node

@export var health_amount = 50 
@onready var player = Player 


func _ready():
	global.currentHealthPacks += 1
	


func _on_health_pack_box_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.health = min(body.maxHealth, body.health + health_amount) 
		body.healthChanged.emit()
		global.currentHealthPacks -= 1
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_HEALTH_PICKUP)
		queue_free() 
