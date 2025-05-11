extends Node2D

func _ready():
	global.init_score_label()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.LVL1_BACKGROUND_MUSIC)
