extends Node
class_name BlockCodeManager

const MainPanelScene := preload("res://block_code/ui/main_panel.tscn")
const MainPanel = preload("res://block_code/ui/main_panel.gd")
const Types = preload("res://block_code/types/types.gd")
const ScriptWindow := preload("res://block_code/ui/script_window/script_window.tscn")

static var main_panel: MainPanel
static var block_code_button: Button
static var selected_block_code: BlockCode
static var preview_scene: PreviewScene
static var _instance: BlockCodeManager

const BlockInspectorPlugin := preload("res://block_code/inspector_plugin/block_script_inspector.gd")
var block_inspector_plugin: BlockInspectorPlugin

var editor_inspector: PlayEditorInspector = PlayEditorInspector.new()

var old_feature_profile: String = ""

const DISABLED_CLASSES := [
	"Block",
	"ControlBlock",
	"ParameterBlock",
	"StatementBlock",
	"SnapPoint",
	"BlockScriptSerialization",
	"CategoryFactory",
]


func _enter_tree():
	Types.init_cast_graph()

func script_window_requested(script: String):
	pass

static func run() -> void:
	var canvas_scene := CanvasScene.get_instance()
	preview_scene = canvas_scene.create_preview()
	canvas_scene.hide()
	_instance.get_parent().get_node("Stage").add_child(preview_scene, true)

static func stop() -> void:
	var canvas_scene := CanvasScene.get_instance()
	preview_scene.queue_free()
	canvas_scene.show()

func _ready():
	var i_main_panel = MainPanelScene.instantiate()
	add_child(i_main_panel)
	_instance = self
	#editor_inspector.connect("edited_object_changed", _on_editor_inspector_edited_object_changed)
	#_on_editor_inspector_edited_object_changed()

func make_bottom_panel_item_visible(_main_panel: MainPanel) -> void:
	add_child(_main_panel)

func _on_editor_inspector_edited_object_changed():
	var edited_object = editor_inspector.get_edited_object()
	var block_code_node = edited_object as BlockCode
	if block_code_node:
		# If a block code node was explicitly selected, activate the
		# Block Code panel.
		make_bottom_panel_item_visible(main_panel)
	else:
		# Find the first block code child.
		block_code_node = list_block_code_nodes_for_node(edited_object as Node).pop_front()
	select_block_code_node(block_code_node)


func select_block_code_node(block_code: BlockCode):
	# Skip duplicate selection unless new node is null. That happens when any
	# non-BlockCode node is selected and that needs to be passed through to the
	# main panel.
	if block_code and block_code == selected_block_code:
		return

	if not is_block_code_editable(block_code):
		block_code = null

	if is_instance_valid(selected_block_code):
		selected_block_code.tree_entered.disconnect(_on_selected_block_code_changed)
		selected_block_code.tree_exited.disconnect(_on_selected_block_code_changed)
		selected_block_code.property_list_changed.disconnect(_on_selected_block_code_changed)
		editor_inspector.property_edited.disconnect(_on_editor_inspector_property_edited)

	selected_block_code = block_code

	if is_instance_valid(selected_block_code):
		selected_block_code.tree_entered.connect(_on_selected_block_code_changed)
		selected_block_code.tree_exited.connect(_on_selected_block_code_changed)
		selected_block_code.property_list_changed.connect(_on_selected_block_code_changed)
		editor_inspector.property_edited.connect(_on_editor_inspector_property_edited)

	_refresh_block_code_node()


func _refresh_block_code_node():
	if main_panel:
		main_panel.switch_block_code_node(selected_block_code)


func _on_selected_block_code_changed():
	if selected_block_code:
		_refresh_block_code_node()


func _on_editor_inspector_property_edited(property: String):
	if selected_block_code:
		_refresh_block_code_node()


static func is_block_code_editable(block_code: BlockCode) -> bool:
	if not block_code:
		return false

	# A BlockCode node can be edited if it belongs to the edited scene, or it
	# is an editable instance.
	return true

static func node_has_block_code(node: Node, recursive: bool = false) -> bool:
	return list_block_code_nodes_for_node(node, recursive).size() > 0


static func list_block_code_nodes_for_node(node: Node, recursive: bool = false) -> Array[BlockCode]:
	var result: Array[BlockCode] = []

	if node is BlockCode:
		result.append(node)
	elif node:
		result.append_array(node.find_children("*", "BlockCode", recursive))

	return result
