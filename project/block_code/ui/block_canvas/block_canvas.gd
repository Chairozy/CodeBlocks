extends MarginContainer

const ASTList = preload("res://block_code/code_generation/ast_list.gd")
const BlockAST = preload("res://block_code/code_generation/block_ast.gd")
const BlockCodePlugin = preload("res://block_code/block_code_manager.gd")
const BlockTreeUtil = preload("res://block_code/ui/block_tree_util.gd")
const DragManager = preload("res://block_code/drag_manager/drag_manager.gd")
const ScriptGenerator = preload("res://block_code/code_generation/script_generator.gd")
const Util = preload("res://block_code/ui/util.gd")

const EXTEND_MARGIN: float = 800
const BLOCK_AUTO_PLACE_MARGIN: Vector2 = Vector2(25, 8)
const DEFAULT_WINDOW_MARGIN: Vector2 = Vector2(45, 0) #45 , 40
const DEFAULT_MARGIN_CONTAINER: Vector2 = Vector2(32, 32) #45 , 40
const SNAP_GRID: Vector2 = Vector2(25, 25)
const ZOOM_FACTOR: float = 1.1

@onready var _context := BlockEditorContext.get_default()

@onready var _window: Control = %Window
@onready var _window_container: Control = %WindowContainer
@onready var _vscroll_bar: VScrollBar = %VScrollBar

@onready var _empty_box: BoxContainer = %EmptyBox

@onready var _zoom_button: Button = %ZoomButton
@onready var _top_button: Button = %TopButton


var _current_block_script: BlockScriptSerialization
var _current_ast_list: ASTList
var _panning := false
var zoom: float:
	set(value):
		_window.scale = Vector2(value, value)
		_zoom_button.text = "%.1fx" % value
	get:
		return _window.scale.x

var disable_access: bool:
	set(value):
		%MouseOverride.mouse_filter = MOUSE_FILTER_STOP if value else MOUSE_FILTER_IGNORE

var block_rect := Rect2(Vector2.ZERO, Vector2.ZERO)

signal reconnect_block(block: Block)
signal add_block_code
signal open_scene
signal replace_block_code


func _ready():
	_context.changed.connect(_on_context_changed)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if _context.block_code_node == null or _context.parent_node == null:
		return false
	if typeof(data) != TYPE_DICTIONARY:
		return false

	var nodes: Array = data.get("nodes", [])
	if nodes.size() != 1:
		return false
	var abs_path: NodePath = nodes[0]

	# Don't allow dropping BlockCode nodes or nodes that aren't part of the
	# edited scene.
	var node := get_tree().root.get_node(abs_path)
	if node is BlockCode or not Util.node_is_part_of_edited_scene(node):
		return false

	# Don't allow dropping the BlockCode node's parent as that's already self.
	var parent_path: NodePath = _context.parent_node.get_path()
	return abs_path != parent_path


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var abs_path: NodePath = data.get("nodes", []).pop_back()
	if abs_path == null:
		return

	# Figure out the best path to the node.
	var node := get_tree().root.get_node(abs_path)
	var node_path: NodePath = Util.node_scene_path(node, _context.parent_node)
	if node_path in [^"", ^"."]:
		return

	var block = _context.block_script.instantiate_block_by_name(&"get_node")
	block.set_parameter_values_on_ready({"path": node_path})
	add_block(block, at_position)
	reconnect_block.emit(block)

func add_block(block: Block, pos: Vector2 = Vector2.ZERO) -> void:
	pos.y = max(DEFAULT_MARGIN_CONTAINER.y + DEFAULT_WINDOW_MARGIN.y, pos.y)
	pos.x = max(DEFAULT_MARGIN_CONTAINER.x + DEFAULT_WINDOW_MARGIN.x, pos.x)
	if block is EntryBlock:
		block.position = canvas_to_window(pos).snapped(SNAP_GRID)
	else:
		block.position = canvas_to_window(pos)

	_window.add_child(block)


func get_blocks() -> Array[Block]:
	var blocks: Array[Block] = []
	for child in _window.get_children():
		var block = child as Block
		if block:
			blocks.append(block)
	return blocks


func arrange_block(block: Block, nearby_block: Block) -> void:
	add_block(block)
	var rect = nearby_block.get_global_rect()
	rect.position += (rect.size * Vector2.RIGHT) + BLOCK_AUTO_PLACE_MARGIN
	block.global_position = rect.position


func set_child(n: Node):
	n.owner = _window
	for c in n.get_children():
		set_child(c)


func _on_context_changed():
	clear_canvas()

	var edited_node = PlayEditorInterface.get_inspector().get_edited_object() as Node

	if _context.block_script != _current_block_script:
		_window.position = Vector2(0, 0)
		zoom = 1

	_window.visible = false
	_zoom_button.visible = false
	_top_button.visible = false

	_empty_box.visible = false

	if _context.block_script != null:
		_load_block_script(_context.block_script)
		_window.visible = true
		#_zoom_button.visible = true
		_top_button.visible = true

		#if _context.block_script != _current_block_script:
		reset_window_position()
	elif edited_node == null:
		_empty_box.visible = true

	_current_block_script = _context.block_script


func _load_block_script(block_script: BlockScriptSerialization):
	_current_ast_list = block_script.generate_ast_list()
	reload_ui_from_ast_list()


func reload_ui_from_ast_list():
	for ast_pair in _current_ast_list.array:
		var root_block = ui_tree_from_ast_node(ast_pair.ast.root)
		root_block.position = ast_pair.canvas_position
		_window.add_child(root_block)


func ui_tree_from_ast_node(ast_node: BlockAST.ASTNode) -> Block:
	var block: Block = _context.block_script.instantiate_block(ast_node.data)

	# Args
	var parameter_values: Dictionary

	for arg_name in ast_node.arguments:
		var argument = ast_node.arguments[arg_name]
		if argument is BlockAST.ASTValueNode:
			var value_block = ui_tree_from_ast_value_node(argument)
			parameter_values[arg_name] = value_block
		else:  # Argument is not a node, but a user input value
			parameter_values[arg_name] = argument

	block.set_parameter_values_on_ready(parameter_values)

	# Children
	var current_block: Block = block

	var i: int = 0
	for c in ast_node.children:
		var child_block: Block = ui_tree_from_ast_node(c)

		if i == 0:
			current_block.child_snap.add_child(child_block)
		else:
			current_block.bottom_snap.add_child(child_block)

		current_block = child_block
		i += 1

	reconnect_block.emit(block)
	return block


func ui_tree_from_ast_value_node(ast_value_node: BlockAST.ASTValueNode) -> Block:
	var block: Block = _context.block_script.instantiate_block(ast_value_node.data)

	# Args
	var parameter_values: Dictionary

	for arg_name in ast_value_node.arguments:
		var argument = ast_value_node.arguments[arg_name]
		if argument is BlockAST.ASTValueNode:
			var value_block = ui_tree_from_ast_value_node(argument)
			parameter_values[arg_name] = value_block
		else:  # Argument is not a node, but a user input value
			parameter_values[arg_name] = argument

	block.set_parameter_values_on_ready(parameter_values)

	reconnect_block.emit(block)
	return block


func clear_canvas():
	for child in _window.get_children():
		_window.remove_child(child)
		child.queue_free()


func rebuild_ast_list():
	_current_ast_list.clear()

	for c in _window.get_children():
		if c is StatementBlock:
			var root: BlockAST.ASTNode = build_ast(c)
			var ast: BlockAST = BlockAST.new()
			ast.root = root
			_current_ast_list.append(ast, c.position)


func build_ast(block: Block) -> BlockAST.ASTNode:
	var ast_node := BlockAST.ASTNode.new()
	ast_node.data = block.definition
	ast_node.block_node_id = block.get_instance_id()

	var parameter_values := block.get_parameter_values()

	for arg_name in parameter_values:
		var arg_value = parameter_values[arg_name]
		if arg_value is Block:
			ast_node.arguments[arg_name] = build_value_ast(arg_value)
		else:
			ast_node.arguments[arg_name] = arg_value

	var children: Array[BlockAST.ASTNode] = []

	if block.child_snap:
		var child: Block = block.child_snap.get_snapped_block()

		while child != null:
			var child_ast_node := build_ast(child)
			child_ast_node.data = child.definition

			children.append(child_ast_node)
			if child.bottom_snap == null:
				child = null
			else:
				child = child.bottom_snap.get_snapped_block()

	ast_node.children = children

	return ast_node


func build_value_ast(block: ParameterBlock) -> BlockAST.ASTValueNode:
	var ast_node := BlockAST.ASTValueNode.new()
	ast_node.data = block.definition

	var parameter_values := block.get_parameter_values()

	for arg_name in parameter_values:
		var arg_value = parameter_values[arg_name]
		if arg_value is Block:
			ast_node.arguments[arg_name] = build_value_ast(arg_value)
		else:
			ast_node.arguments[arg_name] = arg_value

	return ast_node


func rebuild_block_serialization_trees():
	_context.block_script.update_from_ast_list(_current_ast_list)


func find_snaps(node: Node) -> Array[SnapPoint]:
	var snaps: Array[SnapPoint]

	if node.is_in_group("snap_point") and node is SnapPoint:
		snaps.append(node)
	else:
		for c in node.get_children():
			snaps.append_array(find_snaps(c))

	return snaps


func set_scope(scope: String):
	for block in _window.get_children():
		var valid := false

		if block is EntryBlock:
			if scope == block.definition.code_template:
				valid = true
		else:
			var tree_scope := BlockTreeUtil.get_tree_scope(block)
			if tree_scope == "" or scope == tree_scope:
				valid = true

		if not valid:
			block.modulate = Color(0.5, 0.5, 0.5, 1)


func release_scope():
	for block in _window.get_children():
		block.modulate = Color.WHITE


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed and is_mouse_over():
				_panning = true
			else:
				_panning = false

		#var relative_mouse_pos := get_global_mouse_position() - get_global_rect().position

		#if is_mouse_over():
			#var old_mouse_window_pos := canvas_to_window(relative_mouse_pos)
#
			#if event.button_index == MOUSE_BUTTON_WHEEL_UP and zoom < 2:
				#zoom *= ZOOM_FACTOR
			#if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and zoom > 0.2:
				#zoom /= ZOOM_FACTOR

			#_window.position -= (old_mouse_window_pos - canvas_to_window(relative_mouse_pos)) * zoom

	if event is InputEventMouseMotion:
		if _panning or Input.is_key_pressed(KEY_SHIFT):
			var range = block_rect_range()
			_window.position.y = clampi(_window.position.y + event.relative.y, range.min, range.max)
			_update_vscroll(_window.position.y, range.min, range.max)

func blocks_rect() -> Rect2:
	var blocks = get_blocks()
	var top_left: Vector2 = Vector2.INF
	var bottom_right: Vector2 = Vector2.ZERO
	
	for block in blocks:
		if block.position.x < top_left.x:
			top_left.x = block.position.x
		if block.position.y < top_left.y:
			top_left.y = block.position.y
		if block.position.x + block.size.x > bottom_right.x:
			bottom_right.x = block.position.x + block.size.x
		if block.position.y + block.size.y > bottom_right.y:
			bottom_right.y = block.position.y + block.size.y
	
	if top_left == Vector2.INF:
		top_left = Vector2.ZERO

	return Rect2(top_left, bottom_right - top_left)

func block_rect_range():
	var canvas_height = _window_container.size.y - 200
	var max_value = -block_rect.position.y
	var min_value = mini(max_value, canvas_height - block_rect.end.y)
	return {"min": min_value, "max":max_value, "canvas_height": canvas_height}

func update_vscroll():
	block_rect = blocks_rect()
	var range = block_rect_range()
	_update_vscroll(_window.position.y, range.min, range.max)

func _get_position_by_parent_block(node: Node):
	var pos = node.position
	var parent = node.get_parent()
	pos += parent.position
	while parent and not parent is EntryBlock:
		parent = parent.get_parent()
		pos += parent.position
	return pos
	
func scroll_to_block(block):
	var pos_y = _get_position_by_parent_block(block).y
	var range = block_rect_range()
	var canvas_mid = range.canvas_height / 2
	create_tween().tween_method(func(val):
		_window.position.y = val
		_vscroll_bar.value = ceili((abs(_window.position.y) / _vscroll_bar.max_value) * (_vscroll_bar.max_value - _vscroll_bar.page))
		, _window.position.y, clampi(canvas_mid - pos_y, range.min, range.max), 0.3)
	

func _update_vscroll(value, min_value, max_value):
	_vscroll_bar.min_value = abs(max_value)
	_vscroll_bar.max_value = abs(min_value)
	var page = (_window_container.size.y + _vscroll_bar.min_value) / (_window_container.size.y + _vscroll_bar.max_value)
	_vscroll_bar.page = int((_vscroll_bar.max_value - _vscroll_bar.min_value) * page)
	_vscroll_bar.value = ceili((abs(value) / _vscroll_bar.max_value) * (_vscroll_bar.max_value - _vscroll_bar.page))
	if _vscroll_bar.max_value == 0:
		_window.position.y = 0

func reset_window_position():
	block_rect = blocks_rect() 

	_window.position = (-block_rect.position + DEFAULT_WINDOW_MARGIN)
	var range = block_rect_range()
	_update_vscroll(_window.position.y, range.min, range.max)

func canvas_to_window(v: Vector2) -> Vector2:
	return _window.get_transform().affine_inverse() * (v - DEFAULT_MARGIN_CONTAINER)


func window_to_canvas(v: Vector2) -> Vector2:
	return _window.get_transform() * (v + DEFAULT_MARGIN_CONTAINER)


func is_mouse_over() -> bool:
	return get_global_rect().has_point(get_global_mouse_position())


func generate_script_from_current_window() -> String:
	return ScriptGenerator.generate_script(_current_ast_list, _context.block_script)


func _on_zoom_button_pressed():
	zoom = 1.0
	reset_window_position()
	
func _on_top_button_pressed():
	reset_window_position()
