class_name Action

class ControlLoop:
	var count: int
	var n := 0
	func _init(p_count: int = -1):
		count = p_count
	func is_loop():
		n += 1
		if n <= count:
			return true
		else:
			n = 0
			return false

class ControlStep:
	var begin_step := 0
	var end_step := 0
	var is_loop_control := false
	var is_else_control := false
	var control_step_if: ControlStep
	var expression: Callable
	var result_expression: bool = false
	func _init(p_step: int, p_is_loop: bool, p_is_else: bool):
		begin_step = p_step
		is_loop_control = p_is_loop
		is_else_control = p_is_else
	func exec_expression():
		result_expression = expression.call()
		return result_expression
	func is_loop():
		return result_expression and is_loop_control
	func is_decission():
		return result_expression and not is_else_control
	func is_else():
		return result_expression and is_else_control and  control_step_if != null and not control_step_if.result_expression
	func to_parent_result():
		result_expression = control_step_if.result_expression if control_step_if != null else false
var index := 0
var controls := {}
var runtime_controls := []
var creating_control := []
var creating_step := 0
var steps := []
var latest_pop_cs: ControlStep

func exec():
	is_index_on_runtime_controls()
	await index_decission()
func run_step():
	if index < steps.size():
		await steps[index].call()
		index += 1
func is_index_on_runtime_controls():
	var rcs := runtime_controls.size()
	while rcs > 0:
		if runtime_controls[rcs - 1].end_step == index:
			if runtime_controls[rcs - 1].expression.call():
				index = runtime_controls[rcs - 1].begin_step
				return true
			else:
				runtime_controls.pop_back()
				rcs -= 1
		else:
			return false
	return false
func index_decission():
	if controls.has(index):
		for ctrl in controls[index]:
			if not runtime_controls.has(ctrl):
				ctrl.exec_expression()
				if ctrl.is_loop():
					runtime_controls.append(ctrl)
				elif not ctrl.is_decission() and not ctrl.is_else():
					index = ctrl.end_step
					ctrl.to_parent_result()
					return await exec()
	await run_step()
func add(act: Callable):
	steps.append(act)
	creating_step += 1
func add_control(expression: Callable, is_loop_control: bool = false, is_else_control: bool = false):
	var cs := ControlStep.new(creating_step, is_loop_control, is_else_control)
	cs.expression = expression.bind(ControlLoop.new()) if is_loop_control else expression
	if is_else_control and latest_pop_cs != null:
		cs.control_step_if = latest_pop_cs
	if not controls.has(creating_step):
		controls[creating_step] = []
	controls[creating_step].append(cs)
	creating_control.append(cs)
func remove_control():
	latest_pop_cs = creating_control.pop_back()
	latest_pop_cs.end_step = creating_step
