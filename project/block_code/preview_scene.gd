extends Node2D
class_name PreviewScene

class PromiseAll:
	signal completed
	var completed_signals := 0
	var size := 0
	func _init(signals: Array):
		size = signals.size()
		for sig in signals:
			promise(sig)
	func promise(callable: Callable):
		await callable.call()
		completed_signals += 1
		if completed_signals == size:
			completed.emit()
	func wait_completed():
		if completed_signals != size:
			await completed

static var _instance: PreviewScene

static func get_instance() -> PreviewScene:
	return _instance

func _enter_tree() -> void:
	_instance = self

var actors := {}
var turns := []
var play := false

func _ready():
	for actor_name in actors:
		for actor in actors[actor_name]:
			actor.start()
	Callable(func():
		play = true
		start()
		).call_deferred()

func start():
	for actor_name in actors:
		var callbacks = actors[actor_name].map(func(sig): return sig.turn.bind(self))
		await PromiseAll.new(callbacks).wait_completed()
	while not turns.is_empty():
		var turn = turns.pop_back()
		await turn.exec()
	if get_tree():
		await get_tree().create_timer(0.01).timeout
		if play:
			call_deferred(&"start")
		

func pause():
	play = false

func append_actor(node, node_name: String = ""):
	if not actors.has(node_name):
		actors[node_name] = []
	actors[node_name].append(node)
