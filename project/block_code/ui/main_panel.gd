extends Control

signal script_window_requested(script: String)

const BlockCanvas = preload("res://block_code/ui/block_canvas/block_canvas.gd")
const BlockCodePlugin = preload("res://block_code/block_code_manager.gd")
const BlocksCatalog = preload("res://block_code/code_generation/blocks_catalog.gd")
const DragManager = preload("res://block_code/drag_manager/drag_manager.gd")
const Picker = preload("res://block_code/ui/picker/picker.gd")
const TitleBar = preload("res://block_code/ui/title_bar/title_bar.gd")
const VariableDefinition = preload("res://block_code/code_generation/variable_definition.gd")

@onready var _context := BlockEditorContext.get_default()

@onready var _picker: Picker = %Picker
@onready var _block_canvas: BlockCanvas = %BlockCanvas
@onready var _drag_manager: DragManager = %DragManager
@onready var _title_bar: TitleBar = %TitleBar
@onready var _editor_inspector: PlayEditorInspector = PlayEditorInterface.get_inspector()
@onready var _picker_split: HSplitContainer = %PickerSplit
@onready var _collapse_button: Button = %CollapseButton
@onready var _node_option_button: OptionButton = %TitleBar/%NodeOptionButton

@onready var _icon_collapse := Texture2D.new()
@onready var _icon_expand := Texture2D.new()

const Constants = preload("res://block_code/ui/constants.gd")

var _block_code_nodes: Array
var _collapsed: bool = false
var _panel_collapsed: bool = false
var pinned_instructor: bool = false
var used_blocks: int = 0

func _ready():
	_context.changed.connect(_on_context_changed)
	_picker.block_picked.connect(_drag_manager.copy_picked_block_and_drag)
	_picker.variable_created.connect(_create_variable)
	_block_canvas.reconnect_block.connect(_drag_manager.connect_block_canvas_signals)
	#_drag_manager.block_dropped.connect(save_script)
	#_drag_manager.block_modified.connect(save_script)
	_drag_manager.block_dropped.connect(_update_block_limit)
	_drag_manager.block_modified.connect(_update_block_limit)

	if not _collapse_button.icon:
		_collapse_button.icon = _icon_collapse

	%Level.text = str(Game.currentLevel)

func _update_block_limit():
	_block_canvas.update_vscroll()
	save_script()
	used_blocks = _block_canvas._current_ast_list.array[0]\
		.ast.root.get_block_code_sizes() - 1
	var stage = Game.get_single_stage()
	
	%BlockLimitLabel.text = str(used_blocks) + " / " + str(stage.node.blocks_limit)
	%BlockLimitContainer.modulate = Color(1.0, 1.0, 1.0) if used_blocks <= stage.node.blocks_limit else Color(1.0, 0.0, 0.0)

func _on_undo_redo_version_changed():
	_context.force_update()


func _on_show_script_button_pressed():
	var script: String = _block_canvas.generate_script_from_current_window()

func _try_migration():
	var version: int = _context.block_script.version
	if version == Constants.CURRENT_DATA_VERSION:
		# No migration needed.
		return
	push_warning("Migration not implemented from %d to %d" % [version, Constants.CURRENT_DATA_VERSION])

func switch_block_code_node(block_code_node: BlockCode):
	BlocksCatalog.setup()

	var block_script := block_code_node.block_script if block_code_node != null else null
	var object_script := block_script.load_object_script() if block_script != null else null

	if object_script and object_script.has_method("setup_custom_blocks"):
		object_script.setup_custom_blocks()

	if block_script:
		block_script.initialize()

	_context.block_code_node = block_code_node


func _on_context_changed():
	if _context.block_code_node != null:
		_try_migration()
		_update_block_limit()


func save_script():
	if _context.block_code_node == null:
		print("No script loaded to save.")
		return

	var scene_node = PlayEditorInterface.get_edited_scene_root()

	if not BlockCodePlugin.is_block_code_editable(_context.block_code_node):
		print("Block code for {node} is not editable.".format({"node": _context.block_code_node}))
		return

	var block_script: BlockScriptSerialization = _context.block_script

	var resource_path_split = block_script.resource_path.split("::", true, 1)
	var resource_scene = resource_path_split[0]

	if resource_scene and scene_node and resource_scene != scene_node.scene_file_path:
		block_script = block_script.duplicate(true)
	_block_canvas.rebuild_ast_list()
	_block_canvas.rebuild_block_serialization_trees()
	var csl = _block_canvas._current_ast_list

	var generated_script = _block_canvas.generate_script_from_current_window()
	_context.block_script.generated_script = generated_script
	block_script.version = Constants.CURRENT_DATA_VERSION


func _input(event):
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				# Release focus
				var focused_node := get_viewport().gui_get_focus_owner()
				if focused_node:
					focused_node.release_focus()
			else:
				_drag_manager.drag_ended()

	if event is InputEventKey:
		if Input.is_key_pressed(KEY_CTRL) and event.pressed and event.keycode == KEY_BACKSLASH:
			_collapse_button.button_pressed = not _collapse_button.button_pressed
			toggle_collapse()


func toggle_collapse():
	_collapsed = not _collapsed

	_collapse_button.icon = _icon_expand if _collapsed else _icon_collapse
	_picker.set_collapsed(_collapsed)
	_picker_split.collapsed = _collapsed

func toggle_pin_instructor(toggle: bool):
	pinned_instructor = toggle
	var tween = create_tween()
	if toggle:
		tween.tween_property(%FrontUI, "custom_minimum_size:y", 152, 0.5).set_trans(Tween.TRANS_CUBIC)
	else:
		tween.tween_property(%FrontUI, "custom_minimum_size:y", 0, 0.5).set_trans(Tween.TRANS_CUBIC)

func _on_collapse_button_pressed():
	toggle_collapse()


func _on_block_canvas_add_block_code():
	var edited_node: Node = PlayEditorInterface.get_inspector().get_edited_object() as Node
	var scene_root: Node = PlayEditorInterface.get_edited_scene_root()

	if edited_node == null or scene_root == null:
		return

	var block_code = BlockCode.new()
	block_code.name = "BlockCode"


func _on_block_canvas_open_scene():
	var edited_node: Node = PlayEditorInterface.get_inspector().get_edited_object() as Node

	if edited_node == null or edited_node.owner == null:
		return


func _on_block_canvas_replace_block_code():
	var edited_node: Node = PlayEditorInterface.get_inspector().get_edited_object() as Node
	var scene_root: Node = PlayEditorInterface.get_edited_scene_root()


func _create_variable(variable: VariableDefinition):
	if _context.block_code_node == null:
		print("No script loaded to add variable to.")
		return

	var block_script: BlockScriptSerialization = _context.block_script
	var new_variables = block_script.variables.duplicate()
	new_variables.append(variable)
	_picker.reload_blocks()

	new_variables = block_script.variables.duplicate()
	new_variables.append(variable)

	_picker.reload_blocks()


func _on_block_code_node_pressed(toggle):
	_panel_collapsed = toggle
	if toggle:
		%BlockCodeNode.button_pressed = true
		BlockCodeManager.stop()
		%RunNode.button_pressed = false
		if %FailPanel.visible:
			%FailPanel.hide()
			%FailPanel/AnimationPlayer.play("RESET")
		var tween = create_tween()
		tween.tween_property(%Toolbar, "anchor_top", 1.0, 0.2)
		tween.tween_callback(%CodePanel.show)
		tween.tween_property(%Toolbar, "anchor_top", 0.0, 0.5).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(%Codebar, "anchor_left", 0.0, 0.5).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(%Codebar, "offset_left", 0, 0.5).set_trans(Tween.TRANS_CUBIC)
		if pinned_instructor:
			tween.parallel().tween_property(%TeemoInstructor, "offset_bottom", -16, 0.5).set_trans(Tween.TRANS_CUBIC)
			tween.parallel().tween_property(%UIProp, "offset_bottom", -48, 0.5).set_trans(Tween.TRANS_CUBIC)
		else:
			tween.parallel().tween_property(%TeemoInstructor, "offset_bottom", -24, 0.5).set_trans(Tween.TRANS_CUBIC)
			tween.parallel().tween_property(%FrontUI, "custom_minimum_size:y", 52, 0.5).set_trans(Tween.TRANS_CUBIC)
			tween.parallel().tween_property(%UIProp, "offset_bottom", -56, 0.5).set_trans(Tween.TRANS_CUBIC)
			
		tween.tween_callback(%BlockCanvas.set.bind("disable_access", false))

	else:
		var tween = create_tween()
		tween.tween_callback(%BlockCanvas.set.bind("disable_access", true))
		tween.tween_property(%Toolbar, "anchor_top", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(%Codebar, "anchor_left", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(%Codebar, "offset_left", -260, 0.5).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(%TeemoInstructor, "offset_bottom", 0, 0.5).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(%FrontUI, "custom_minimum_size:y", 152, 0.5).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(%UIProp, "offset_bottom", -16, 0.5).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(%CodePanel.hide)
		tween.tween_property(%Toolbar, "anchor_top", 0.0, 0.2)

func _on_run_node_pressed(toggle):
	if toggle:
		save_script()
		%BlockCodeNode.button_pressed = false
		BlockCodeManager.run()
	else:
		%BlockCodeNode.button_pressed = true
		BlockCodeManager.stop()

func _on_home_node_pressed():
	Game.home()

func win():
	pass

func fail(msg):
	if msg:
		%FailMessage.text = msg
	%FailPanel/AnimationPlayer.play("In")
	%FailPanel.show()
