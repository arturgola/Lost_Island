extends TextureProgressBar

@export var player: Player

func _ready():
	if player:
		player.healthChanged.connect(update)
		update()
	else:
		push_error("Player reference is missing.")
		value = 0

func update():
	if player:
		value = player.health * 100 / player.maxHealth
