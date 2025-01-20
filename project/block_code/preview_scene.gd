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

var actors := {}
var turns := []

func _ready():
	for actor_name in actors:
		for actor in actors[actor_name]:
			actor.start()
	call_deferred(&"start")

func start():
	for actor_name in actors:
		var callbacks = actors[actor_name].map(func(sig): return sig.turn.bind(self))
		await PromiseAll.new(callbacks).wait_completed()
	while not turns.is_empty():
		var turn = turns.pop_back()
		await turn.exec()
	await get_tree().create_timer(0.01).timeout
	call_deferred(&"start")

func append_actor(node, node_name: String = ""):
	if not actors.has(node_name):
		actors[node_name] = []
	actors[node_name].append(node)
