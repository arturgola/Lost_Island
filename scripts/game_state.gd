extends Node

@export var pauseMenuOverlay: Control
@export var dialogPanel: Control
var dialogLabel: Label

var dialogueShown = false

var tutorialDialogues = [
	"Hi there Player\nTo Win in this game you have to survive until timer ends\nPress Enter to continue",
 	"To move use WASD or Arrow keys\nTo attack press E key", 
	"From time to time health pack will spawn at random position\nWalk around map to find it"
]


var dialoguesQueue = []

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	global.achievedNextLevelScore.connect(nextLevelUnlockedDialogue)
	tutorialDialogues.append("Achieve %d score to unlock second level\n\nGood luck and may the best player win" % global.score_to_unlock_next_level)
	if global.currentLevel == 1:
		dialoguesQueue = tutorialDialogues

	dialogLabel = dialogPanel.get_node("DialogLabel") as Label
	# Show the first dialogue
	if dialoguesQueue.size() > 0:
		show_dialogue(dialoguesQueue[0])

# Called every frame, even when the game is paused
func _process(delta):
	if Input.is_action_just_pressed("ui_pause"):  # This checks the key press
		toggle_pause()

	if Input.is_action_just_pressed("ui_accept"):  # Enter key or equivalent
		if not dialoguesQueue.is_empty():
			dialoguesQueue.remove_at(0)  # Pop the first item
			if not dialoguesQueue.is_empty():
				show_dialogue(dialoguesQueue[0])
			else:
				hide_dialogue()  # Hide dialogue when the queue is empty

# Show a new dialogue and pause the game
func show_dialogue(dialogue: String):
	dialogPanel.visible = true
	dialogLabel.text = dialogue
	get_tree().paused = true  # Pause the game when dialogue is shown

# Hide the dialogue panel and unpause the game
func hide_dialogue():
	dialogPanel.visible = false
	get_tree().paused = false  # Unpause the game when dialogue is finished

func toggle_pause():
	if get_tree().paused:
		get_tree().paused = false  # Unpause
		pauseMenuOverlay.visible = false
		print("Game Unpaused")
	else:
		get_tree().paused = true   # Pause
		pauseMenuOverlay.visible = true
		print("Game Paused")
		
func nextLevelUnlockedDialogue():
	dialoguesQueue.push_front("You've achieved %d score\n\nDoor to new level appeared near you\nWalk to the door to get to the next level" % global.score_to_unlock_next_level)
	show_dialogue(dialoguesQueue[0])
	
