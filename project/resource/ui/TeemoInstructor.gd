class_name TeemoInstructor extends MarginContainer

const IDLE = 0
const WRITING = 1
const CLICK = 2
const TASKING = 3

static var _instance: TeemoInstructor
static func is_already() -> bool:
	return is_instance_valid(_instance)

static func get_default() -> TeemoInstructor:
	return _instance


signal ui_navigating
signal writing_finished
signal understand
signal state_changed

var _text = ""
var _timer := 0.0
var _state: int:
	get:
		return _state
	set(value):
		_state = value
		state_changed.emit()
		if _state == CLICK:
			%Clickable.current_animation = "default"
			%Clickable.show()
		elif _state == TASKING:
			%Clickable.current_animation = "tasking"
			%Clickable.show()
		else:
			%Clickable.hide()

var _next_state := IDLE

var character := ""

const MS_PER_WORD := 0.01

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_instance = self
	char_play("idle")

func _process(delta: float) -> void:
	if _state == WRITING:
		_timer += delta
		var chars = floori(_timer / MS_PER_WORD)
		_write(chars)
		var vscroll = %ScrollContainer.get_v_scroll_bar() as VScrollBar
		vscroll.value = vscroll.max_value
		if _text.length() == 0:
			writing_finished.emit()
			char_play("idle")
			_state = _next_state
	else:
		_timer = 0.0

	if _state == IDLE:
		_state = IDLE if _text.length() == 0 else WRITING

func _write(chars = 0):
	_timer -= chars * MS_PER_WORD
	%Label.text += _text.left(chars)
	_text = _text.erase(0, chars)

func char_play(act: String):
	%Character.play((character + "_" + act) if character else act)

func task_complete() -> void:
	_state = IDLE
	char_play("idle")

func set_text(msg: String, new_conv: bool = false) -> void:
	if %Label.text.length() > 0:
		%Label.text += "\n"
	if new_conv:
		%Label.text = ""
	_text = msg

func tasking(msg: String, new_conv: bool = false) -> void:
	set_text(msg, new_conv)
	_next_state = TASKING
	char_play("talk")

func talking(msg: String, new_conv: bool = false) -> void:
	set_text(msg, new_conv)
	_next_state = CLICK
	char_play("talk")

func talk(msg: String, new_conv: bool = false) -> void:
	set_text(msg, new_conv)
	_next_state = IDLE
	char_play("talk")

func talk_random_coding() -> void:
	talk(TeemoSentence.random_coding_sentence())

func talk_random_observing() -> void:
	talk(TeemoSentence.random_observing_sentence())

func start_random_talks() -> void:
	talk(TeemoSentence.random_coding_sentence() if randi_range(0, 1) == 0 else TeemoSentence.random_observing_sentence())

func _exit_tree() -> void:
	_instance = null

func _on_dialog_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if _state == CLICK:
				_state = IDLE
				understand.emit()
			elif _state == WRITING:
				_write(_text.length())
