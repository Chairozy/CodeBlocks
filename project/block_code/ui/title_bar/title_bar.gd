extends MarginContainer

signal node_name_changed(node_name: String)

@onready var _context := BlockEditorContext.get_default()

@onready var _block_code_icon = load("res://block_code/block_code_node/block_code_node.svg") as Texture2D
@onready var _editor_inspector: PlayEditorInspector = PlayEditorInterface.get_inspector()
@onready var _node_option_button: OptionButton = %NodeOptionButton
var block_code_nodes: Array[BlockCode] = []


func _ready():
	_context.changed.connect(_on_context_changed)
	_node_option_button.connect("item_selected", _on_node_option_button_item_selected)
	_update_node_option_button_items.call_deferred()

func _on_context_changed():
	# TODO: We should listen for property changes in all BlockCode nodes and
	#       their parents. As a workaround for the UI displaying stale data,
	#       we'll crudely update the list of BlockCode nodes whenever the
	#       selection changes.
	pass
	#var select_index = _get_block_script_index(_context.block_script)
	#if _node_option_button.selected != select_index:
		#_node_option_button.select(select_index)

func clear_items():
	block_code_nodes.clear()
	_node_option_button.clear()

func _update_node_option_button_items():
	pass
	#_node_option_button.clear()
	#var scene_root = CanvasScene.get_instance()
	#if not scene_root:
		#return
#
	#for block_code in BlockCodeManager.list_block_code_nodes_for_node(scene_root, true):
		#if not BlockCodeManager.is_block_code_editable(block_code):
			#continue
#
		#var node_item_index = _node_option_button.item_count
		#var node_label = block_code.get_parent().name
		#_node_option_button.add_item(node_label)
		#_node_option_button.set_item_icon(node_item_index, _block_code_icon)
		#block_code_nodes.append(block_code)
#
	#_node_option_button.disabled = _node_option_button.item_count == 0
	#_node_option_button.selected = -1
	#create_tween().tween_interval(.1).finished.connect(Callable(func(_inst):
		#_inst.selected = 0
		#_inst.item_selected.emit(0)
		#).bind(_node_option_button))

func add_node_item_options(block_code: BlockCode):
	var node_item_index = _node_option_button.item_count
	var node_label = block_code.get_parent().name
	_node_option_button.add_icon_item(_block_code_icon, node_label)
	block_code_nodes.append(block_code)

	_node_option_button.disabled = _node_option_button.item_count == 0
	if _node_option_button.selected == -1:
		_node_option_button.selected = node_item_index
	_node_option_button.item_selected.emit(_node_option_button.selected)

func _get_block_script_index(block_script: BlockScriptSerialization) -> int:
	for index in range(_node_option_button.item_count):
		var block_code_node = block_code_nodes[index]
		if block_code_node.block_script == block_script:
			return index
	return -1


func _on_node_option_button_item_selected(index):
	if block_code_nodes.size() > index:
		var block_code_node := block_code_nodes[index]
		_context.block_code_node = block_code_node
