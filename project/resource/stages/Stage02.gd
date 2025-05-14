extends Stage

const Types = preload("res://block_code/types/types.gd")

@onready var _instructor := TeemoInstructor.get_default()
@onready var character := $Character
@onready var goal := $Goal

# Called when the node enters the scene tree for the first time.
func _ready_as_canvas():
	_instructor.character = "robot"
	BlockCodeManager.main_panel.pinned_instructor = true
	BlockCodeManager.main_panel.get_node("%BlockCodeNode").button_mask = 0
	BlockCodeManager.main_panel.get_node("%RunNode").button_mask = 0
	_instructor.talking("Sekarang kita mulai dari yang mudah untuk melatih robotmu.")
	await _instructor.understand
	_instructor.talking("Saya telah menyebarkan robot di banyak tempat terdampar yang jauh.")
	await _instructor.understand
	_instructor.talk("Coba selesaikan tugas sederhananya.")
	BlockCodeManager.main_panel.get_node("%BlockCodeNode").button_mask = 1
	await BlockCodeManager.main_panel.get_node("%BlockCodeNode").pressed
	await get_tree().create_timer(1.0).timeout
	_instructor.talking("Oh iya...")
	await _instructor.understand
	_instructor.talking("Saya tidak akan menemani mu dalam perjalanan, tapi saya akan mengenalkan penggantinya")
	await _instructor.understand
	_instructor.character = ""
	_instructor.talking("Hai..", true)
	await _instructor.understand
	_instructor.talking("Saya Teemo kelinci sehat yang akan menemani perjalanan nanti")
	await _instructor.understand
	_instructor.talk("Saya hanya memberi sugesti yang sangat-sangat acak")
	BlockCodeManager.main_panel.get_node("%RunNode").button_mask = 1

func _ready_as_preview():
	character.connect("error_action", _on_character_error_action)

func _on_character_error_action():
	if not is_won:
		character.lose_anim()
		fail()

func _on_goal_body_entered(body: Node2D):
	if body == character:
		character.win_anim()
		goal.play_out()
		star3 = int(BlockCodeManager.main_panel.used_blocks <= blocks_limit)
		win()
