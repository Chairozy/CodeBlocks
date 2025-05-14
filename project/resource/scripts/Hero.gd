extends CharacterBody2D
class_name Hero

const GAME_STATE = 0
const GAME_WIN = 1
const GAME_LOSE = 2


var sequence := {}
var health := 3
@onready var animate: AnimatedSprite2D = $AnimatedSprite2D
@export var default_anim := &"idle"
@export var direction := Vector2(0.0, 1.0)
var win_type := 1
var game_state := 0

signal error_action

func turn(preview_scene: PreviewScene):
	var turn_names := sequence.keys()
	turn_names.erase("start")
	for turn_name in turn_names:
		sequence[turn_name].act_name = turn_name
		preview_scene.turns.append(sequence[turn_name])
	if sequence.has("start"):
		var has_next_code = await sequence["start"].exec()
		if not has_next_code:
			error_action.emit()

func _ready():
	play_anim(direction, default_anim)
	get_parent().get_parent().append_actor(self, UuidV4.generate_uuid_v4())

func simple_setup():
	var rid_shape := PhysicsServer2D.rectangle_shape_create()
	PhysicsServer2D.body_add_shape(get_rid(), rid_shape)
	PhysicsServer2D.shape_set_data(rid_shape, Vector2(5.0, 5.0))

func tween_move_and_collide(distance: float, motion: Dictionary):
	if motion.back and motion.travel == 0.0:
		idle_anim()
		return
	var velo := direction
	motion.distance += absf(distance) - motion.latest_distance
	motion.latest_distance = absf(distance)
	velo *= floorf(abs(motion.distance))
	if motion.back:
		motion.travel -= abs(velo.y if velo.x == 0.0 else velo.x)
		velo *= -1.0
	else:
		motion.travel += abs(velo.y if velo.x == 0.0 else velo.x)
	motion.distance -= abs(velo.y if velo.x == 0.0 else velo.x)
	if velo != Vector2.ZERO:
		if move_and_collide(velo) != null:
			error_action.emit()
			motion.back = true

func walk_anim(dir: Vector2 = Vector2.ZERO):
	play_anim(dir, &"walk")

func idle_anim(dir: Vector2 = Vector2.ZERO):
	if game_state == GAME_WIN:
		animate.play(&"win")
	#elif game_state == GAME_LOSE:
		#animate.play(&"lose")
	else:
		play_anim(dir, &"idle")

func play_anim(dir: Vector2 = Vector2.ZERO, anim_prefix: StringName = &"idle"):
	if dir == Vector2.ZERO:
		if animate.sprite_frames.get_animation_names().has(anim_prefix):
			animate.play(anim_prefix)
		else:
			var _anim := animate.animation.split("_")
			_anim.set(0, anim_prefix)
			animate.play(_anim[0]+"_"+_anim[1])
	elif dir.x != 0.0:
		animate.play(anim_prefix+&"_side")
		animate.flip_h = dir.x == -1.0
	elif dir.y == 1.0:
		animate.play(anim_prefix+&"_front")
	elif dir.y == -1.0:
		animate.play(anim_prefix+&"_back")

func win_anim():
	game_state = GAME_WIN

func lose_anim():
	game_state = GAME_LOSE
	#if animate.animation.contains("idle"):
		#animate.play(&"lose")

func movement(axis: String, distance: int):
	var _dir := Vector2.ZERO
	_dir[axis] = signf(distance)
	direction = _dir
	walk_anim(_dir)
	await create_tween().tween_method(Callable(self, &"tween_move_and_collide").bind({"latest_distance": 0.0, "distance": 0.0, "back": false, "travel": 0.0}), 0.0, float(distance), 0.5).finished
	idle_anim(_dir)

func forward(distance: int):
	walk_anim()
	await create_tween().tween_method(Callable(self, &"tween_move_and_collide").bind({"latest_distance": 0.0, "distance": 0.0, "back": false, "travel": 0.0}), 0.0, float(distance), 0.5).finished
	idle_anim()

func rotating(_x: int = 0):
	var _next_dir := Vector2i(direction.rotated(deg_to_rad(float(_x) * 90.0)))
	animate.flip_h = _next_dir.x == -1 or direction.x == -1.0
	var is_front := direction.y == 1.0 or _next_dir.y == 1
	direction = Vector2(_next_dir)
	if direction.y == 0.0:
		animate.play((("front" if is_front else "back") +  &"_side"))
	else:
		animate.play((&"side_" + ("front" if is_front else "back")))
	await animate.animation_finished
	
	idle_anim(direction)

func goal(node: Area2D):
	CanvasScene.get_instance()._next_level(node.name, node.global_position)

func demaged(node):
	health -= node.attack
	create_tween().tween_method(Callable(func(value: int, node: Hero):
		node.get_node("AnimatedSprite2D").modulate.a = float(value % 2)
		).bind(self), 0, 11, .5)
