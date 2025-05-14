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
	_instructor.talking("Hai, saya Teemo sang instruktur coding mungil kamu!.")
	await _instructor.understand
	_instructor.talking("Kita akan belajar komputer sains, salah satunya kita belajar tentang Sequences (urutan).")
	await _instructor.understand
	_instructor.talking("Mengurutkan langkah per langkah untuk menyelesaikan masalah atau suatu tugas.")
	await _instructor.understand
	_instructor.tasking("Pertama-tama coba buka tab code di sebelah bawah kiri lalu tarik blok kode ke dalam canvas.")
	await _instructor.writing_finished
	BlockCodeManager.main_panel.get_node("%BlockCodeNode").button_mask = 1
	await BlockCodeManager.main_panel.get_node("%BlockCodeNode").toggled
	var has_statement = false
	while not has_statement:
		await BlockCodeManager.main_panel._drag_manager.block_dropped
		BlockCodeManager.main_panel\
			._block_canvas.rebuild_ast_list()
		var curr_asts = BlockCodeManager.main_panel\
			._block_canvas._current_ast_list
		var asts = curr_asts.get_top_level_nodes_of_type(Types.BlockType.ENTRY)
		
		for ent_ast in asts:
			for ast in ent_ast.root.children:
				if ast.data.type == Types.BlockType.STATEMENT:
					has_statement = true
	_instructor.task_complete()
	_instructor.tasking("Bagus, sekarang coba jalankan kode yang telah kamu buat dengan menekan tombol play hijau di sebelah tab code.")
	await _instructor.writing_finished
	BlockCodeManager.main_panel.get_node("%RunNode").button_mask = 1
	await BlockCodeManager.main_panel.get_node("%RunNode").toggled
	_instructor.task_complete()
	_instructor.tasking("Kemudian untuk menghentikan kode yang sudah dijalankan kamu bisa kembali dengan menekan tombol stop.")
	await BlockCodeManager.main_panel.get_node("%RunNode").toggled
	_instructor.task_complete()
	_instructor.talk("Hebat, kamu sudah tau cara membuat kode nya sekarang tinggal kamu susun, dan bantu robot untuk bergerak sampai ke titik pin kuning.")
	await _instructor.writing_finished
	BlockCodeManager.main_panel.pinned_instructor = false
	#BlockCodeManager.main_panel.toggle_pin_instructor(false)

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
