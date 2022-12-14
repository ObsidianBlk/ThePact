extends Node

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal control_requested()
signal control_relinquished(msg)
signal node_focus_requested(focus)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const MAX_THROTTLE_TIME : float = 0.1
const MAX_BREAKING_TIME : float = 0.25
const MAX_STEERING_TIME : float = 0.1

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Player Vehicle Control")
@export var vehicle_group : String = "" :			set = set_vehicle_group

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

var _vehicle : WeakRef = weakref(null)

var _exit_timer : SceneTreeTimer = null


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_vehicle_group(g : String) -> void:
	if vehicle_group != g:
		vehicle_group = g
		_CheckVehicle(true)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_CheckVehicle()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CheckVehicle(force_update : bool = false) -> void:
	var clear_vehicle : bool = true
	if _vehicle.get_ref() == null or force_update:
		if vehicle_group != "":
			if is_inside_tree():
				var varr : Array = get_tree().get_nodes_in_group(vehicle_group)
				for vn in varr:
					if vn is Vehicle and _vehicle.get_ref() != vn:
						_vehicle = weakref(vn)
						if vn.has_signal(&"enter_vehicle_requested"):
							vn.connect(&"enter_vehicle_requested", _on_enter_vehicle_requested)
						node_focus_requested.emit(vn)
						clear_vehicle = false
						break
	if _vehicle.get_ref() != null and clear_vehicle:
		_vehicle = weakref(null)

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
# Public Methods
# ------------------------------------------------------------------------------
func get_ctrl_type() -> StringName:
	return &"PlayerVehicleControl"

func enter(msg : Dictionary = {}) -> void:
	var vehicle = _vehicle.get_ref()
	if vehicle != null:
		vehicle.add_to_group(&"player_focus")
		node_focus_requested.emit(vehicle)

func exit() -> void:
	var vehicle = _vehicle.get_ref()
	if vehicle != null:
		vehicle.remove_from_group(&"player_focus")

func handle_input(event : InputEvent) -> void:
	var update_steering : bool = false
	if event.is_action("v_accel"):
		_throttle(event.get_action_strength("v_accel"))
	elif event.is_action("v_break"):
		_break(event.get_action_strength("v_break"))
	elif event.is_action("v_reverse"):
		if _vehicle.get_ref() != null:
			if event is InputEventKey and event.is_pressed() and not event.is_echo():
				_vehicle.get_ref().toggle_reverse()
			else:
				var rev : bool = event.get_action_strength("v_reverse") > 0.1
				_vehicle.get_ref().set_reverse(rev)
	elif event.is_action("v_left") or event.is_action("v_right"):
		_dir[0] = event.get_action_strength("v_left")
		_dir[1] = event.get_action_strength("v_right")
		update_steering = true
	elif event.is_action("interact_alt", true):
		var pressed = event.is_pressed()
		if pressed and not event.is_echo() and _exit_timer == null:
			_exit_timer = get_tree().create_timer(1.0)
			_exit_timer.timeout.connect(_on_exit_vehicle_requested)
		elif not pressed and _exit_timer != null:
			_exit_timer.timeout.disconnect(_on_exit_vehicle_requested)
			_exit_timer = null
			if _vehicle.get_ref() != null:
				_vehicle.get_ref().toggle_headlights()
	if update_steering:
		_steer(_dir[1] - _dir[0])

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_tween_throttle(val : float) -> void:
	_throttle_value = val
	if _vehicle.get_ref() != null:
		_vehicle.get_ref().set_throttle(_throttle_value)

func _on_tween_breaking(val : float) -> void:
	_breaking_value = val
	if _vehicle.get_ref() != null:
		_vehicle.get_ref().set_break(_breaking_value)

func _on_tween_steering(val : float) -> void:
	_steering_value = val
	if _vehicle.get_ref() != null:
		_vehicle.get_ref().set_steering(_steering_value)

func _on_enter_vehicle_requested() -> void:
	control_requested.emit()

func _on_exit_vehicle_requested() -> void:
	var pos : Vector2 = Vector2.ZERO
	if _vehicle.get_ref() != null:
		pos = _vehicle.get_ref().get_exit_point()
	control_relinquished.emit({
		&"spawn_point": pos
	})
