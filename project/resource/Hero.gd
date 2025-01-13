extends CharacterBody2D
class_name Hero

func simple_setup():
	var rid_shape := PhysicsServer2D.rectangle_shape_create()
	PhysicsServer2D.body_add_shape(get_rid(), rid_shape)
	PhysicsServer2D.shape_set_data(rid_shape, Vector2(5.0, 5.0))

func tween_move_and_collide(distance: float, motion: Dictionary):
	if motion.back and motion.travel == 0.0:
		$AnimatedSprite2D.play("default")
		return
	var velo := Vector2(0.0, 0.0)
	motion.distance += distance - motion.latest_distance
	motion.latest_distance = distance
	velo[motion.axis] = floorf(abs(motion.distance)) * signf(motion.distance) 
	if motion.back:
		velo[motion.axis] *= -1.0
	motion.travel += velo[motion.axis]
	motion.distance -= velo[motion.axis]
	if velo != Vector2.ZERO:
		if move_and_collide(velo) != null:
			motion.back = true

func movement(axis: String, distance: int, repeat: int):
	distance *= repeat
	$AnimatedSprite2D.play("walk")
	if axis == "x":
		$AnimatedSprite2D.flip_h = distance < 0
	await create_tween().tween_method(Callable(self, &"tween_move_and_collide").bind({"axis": axis, "latest_distance": 0.0, "distance": 0.0, "back": false, "travel": 0.0}), 0.0, float(distance), float(repeat)).finished
	$AnimatedSprite2D.play("default")

func goal(node: Area2D):
	CanvasScene.get_instance()._next_level(node.name, node.global_position)