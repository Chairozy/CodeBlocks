extends Stage

const Types = preload("res://block_code/types/types.gd")

@onready var _instructor := TeemoInstructor.get_default()
@onready var character := $Character
@onready var goal := $Goal
@onready var gate := $Gate
@onready var key_gate := $KeyGate


# Called when the node enters the scene tree for the first time.
func _ready_as_canvas():
	_instructor.talk_random_coding()

func _ready_as_preview():
	character.connect("error_action", _on_character_error_action)

func _on_character_error_action():
	if not is_won:
		_instructor.talk_random_observing()
		character.lose_anim()
		fail()

func _on_goal_body_entered(body: Node2D):
	if body == character:
		character.win_anim()
		goal.play_out()
		star3 = int(BlockCodeManager.main_panel.used_blocks <= blocks_limit)
		win()


func _on_key_gate_body_entered(body):
	if body == character:
		gate.open = true
		key_gate.queue_free()
