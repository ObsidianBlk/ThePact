extends Node

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const MAX_THROTTLE_TIME : float = 0.1
const MAX_BREAKING_TIME : float = 0.25
const MAX_STEERING_TIME : float = 0.1

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _tw_throttle : Tween = null
var _tw_breaking : Tween = null
var _tw_steering : Tween = null

var _throttle_value : float = 0.0
var _breaking_value : float = 0.0
var _steering_value : float = 0.0

var _dir : Array[float] = [0.0, 0.0]

var _parent : Vehicle = null

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if _parent == null:
		_enter_tree()

func _enter_tree() -> void:
	var p = get_parent()
	if p is Vehicle:
		_parent = p

func _exit_tree() -> void:
	_parent = null

func _unhandled_input(event : InputEvent) -> void:
	var update_steering : bool = false
	if event.is_action("v_accel"):
		_throttle(event.get_action_strength("v_accel"))
	elif event.is_action("v_break"):
		_break(event.get_action_strength("v_break"))
	elif event.is_action("v_reverse"):
		var rev : bool = event.get_action_strength("v_reverse") > 0.1
		if _parent:
			_parent.set_reverse(rev)
	elif event.is_action("v_left") or event.is_action("v_right"):
		print("Left")
		_dir[0] = event.get_action_strength("v_left")
		_dir[1] = event.get_action_strength("v_right")
		update_steering = true
	if update_steering:
		_steer(_dir[1] - _dir[0])


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _TimeToTarget(cur : float, targ : float, size : float, time : float) -> float:
	if size != 0.0:
		var dist = abs(targ - cur)
		return time * (dist / size)
	return 0.0

func _throttle(target : float) -> void:
	if target != _throttle_value:
		var time = _TimeToTarget(_throttle_value, target, 1.0, MAX_THROTTLE_TIME)
		
		if _tw_throttle != null:
			_tw_throttle.kill()
		_tw_throttle = create_tween()
		_tw_throttle.tween_method(_on_tween_throttle, _throttle_value, target, time)

func _break(target : float) -> void:
	if target != _breaking_value:
		var time = _TimeToTarget(_breaking_value, target, 1.0, MAX_BREAKING_TIME)
		
		if _tw_breaking != null:
			_tw_breaking.kill()
		_tw_breaking = create_tween()
		_tw_breaking.tween_method(_on_tween_breaking, _breaking_value, target, time)

func _steer(target : float) -> void:
	var time : float = 0.0
	if target == 0.0 or signf(target) == signf(_steering_value):
		time = _TimeToTarget(_steering_value, target, 1.0, MAX_STEERING_TIME)
	else:
		time = _TimeToTarget(_steering_value, target, 2.0, MAX_STEERING_TIME * 2.0)
	
	if _tw_steering != null:
		_tw_steering.kill()
	_tw_steering = create_tween()
	_tw_steering.tween_method(_on_tween_steering, _steering_value, target, time)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_tween_throttle(val : float) -> void:
	_throttle_value = val
	if _parent != null:
		_parent.set_throttle(_throttle_value)

func _on_tween_breaking(val : float) -> void:
	_breaking_value = val
	if _parent != null:
		_parent.set_break(_breaking_value)

func _on_tween_steering(val : float) -> void:
	_steering_value = val
	if _parent != null:
		_parent.set_steering(_steering_value)
