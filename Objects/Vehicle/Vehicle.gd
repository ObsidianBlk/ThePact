extends CharacterBody2D
class_name Vehicle

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal reversed(rev)
signal throttle_changed(throttle)
signal steering_changed(steering_angle)
signal breaking()
signal enter_vehicle_requested()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const TRACTION_SLOW_SPEED : float = 100.0
const TRACTION_FAST_SPEED : float = 400.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Vehicle")
@export var max_engine_power : float = 800.0 :							set = set_max_engine_power
@export_range(0.0, 1.0) var engine_reverse_multiplier : float = 0.85 :	set = set_engine_reverse_multiplier

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _axel_fore : Axel = null
var _axel_rear : Axel = null

var _speed : float = 0.0
var _accel : Vector2 = Vector2.ZERO

var _max_breaking_power : float = 0.0
var _traction_slow : float = 0.0
var _traction_fast : float = 0.0
var _friction : float = 0.0
var _drag : float = 0.0

var _steering_angle = 0.0
var _engine_power : float = 0.0
var _breaking_power : float = 0.0
var _reverse : bool = false

var _enter_vehicle_timer : SceneTreeTimer = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var headlights : Sprite2D = $Headlights
@onready var headlights_light : PointLight2D = $PointLight2D
@onready var break1_light : PointLight2D = $Break1
@onready var break2_light : PointLight2D = $Break2

# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_max_engine_power(p : float) -> void:
	if p > 0.0:
		max_engine_power = p

func set_engine_reverse_multiplier(m : float) -> void:
	engine_reverse_multiplier = max(0.0, min(1.0, m))


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------

func _physics_process(delta : float) -> void:
	var accel_dir = -1.0 if _reverse else 1.0
	var power = -_breaking_power if _breaking_power > 0.0 else _engine_power
	
	_accel = -transform.y * power * accel_dir
	_ApplyFriction()
	_CalculateHeading(delta)
	
	velocity += _accel * delta
	move_and_slide()
	if get_slide_collision_count() > 0:
		velocity = Vector2.ZERO
	_speed = velocity.length()
	if _axel_fore:
		_axel_fore.enable_trails = _speed > TRACTION_SLOW_SPEED
	if _axel_rear:
		_axel_rear.enable_trails = _speed > TRACTION_SLOW_SPEED

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GenerateTraction() -> float:
	var traction : float = 1.0
	if _speed >= TRACTION_FAST_SPEED:
		traction = _traction_fast
	elif _speed >= TRACTION_SLOW_SPEED:
		var d : float = (_speed - TRACTION_SLOW_SPEED) / (TRACTION_FAST_SPEED - TRACTION_SLOW_SPEED)
		traction = _traction_slow + ((_traction_fast - _traction_slow) * d)
	return traction

func _CalculateHeading(delta : float) -> void:
	if _axel_fore == null or _axel_rear == null:
		return
	var fore_wheel : Vector2 = position - (transform.y * abs(_axel_fore.position.y))
	var rear_wheel : Vector2 = position + (transform.y * abs(_axel_rear.position.y))
	
	rear_wheel += velocity * delta
	fore_wheel += velocity.rotated(deg_to_rad(_steering_angle)) * delta
	var heading : Vector2 = (fore_wheel - rear_wheel).normalized()
	var traction : float = _GenerateTraction()
	var d : float = heading.dot(velocity.normalized())
	if d > 0 and not _reverse:
		velocity = velocity.lerp(heading * _speed, traction)
	elif d < 0 and _reverse:
		velocity = velocity.lerp(-heading * _speed, traction)
	rotation = (heading.angle() + deg_to_rad(90.0))

func _ApplyFriction() -> void:
	if _speed < 5.0:
		velocity = Vector2.ZERO
		_speed = 0.0
	if _breaking_power > 0.0 and _speed <= 0.0:
		_accel = Vector2.ZERO
	else:
		var force_fric : Vector2 = (-_friction) * velocity
		var force_drag : Vector2 = (-_drag) * _speed * velocity
		_accel += force_fric + force_drag

func _UpdateAxelValues() -> void:
	if _axel_fore != null and _axel_rear != null:
		_max_breaking_power = (_axel_fore.breaking_power + _axel_rear.breaking_power) * 0.5
		_traction_fast = (_axel_fore.traction_fast + _axel_rear.traction_fast) * 0.5
		_traction_slow = (_axel_fore.traction_slow + _axel_rear.traction_slow) * 0.5
		_friction = (_axel_fore.friction + _axel_rear.friction) * 0.5
		_drag = (_axel_fore.drag + _axel_rear.drag) * 0.5
	else:
		_max_breaking_power = 0.0
		_traction_fast = 0.0
		_traction_slow = 0.0
		_friction = 0.0
		_drag = 0.0

func _UpdateBreakLights() -> void:
	if _reverse or _breaking_power > 0.0:
		break1_light.energy = 1.0
		break2_light.energy = 1.0
	else:
		break1_light.energy = 0.2
		break2_light.energy = 0.2

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_exit_point() -> Vector2:
	if $ExitPoint:
		return $ExitPoint.global_position
	return Vector2.ZERO

func has_forward_axel() -> bool:
	return _axel_fore != null

func get_forward_axel() -> Axel:
	return _axel_fore

func set_forward_axel(axel : Axel) -> void:
	if axel != null and (axel == _axel_fore or axel == _axel_rear):
		return
	if _axel_fore != null:
		remove_child(_axel_fore)
		_axel_fore.queue_free()
	_axel_fore = axel
	if _axel_fore != null:
		$AxelForePos.add_sibling(_axel_fore)
		_axel_fore.position = $AxelForePos.position
	_UpdateAxelValues()

func has_rear_axel() -> bool:
	return _axel_rear != null

func get_rear_axel() -> Axel:
	return _axel_rear

func set_rear_axel(axel : Axel) -> void:
	if axel != null and (axel == _axel_fore or axel == _axel_rear):
		return
	if _axel_rear != null:
		remove_child(_axel_rear)
		_axel_rear.queue_free()
	_axel_rear = axel
	if _axel_rear != null:
		$AxelRearPos.add_sibling(_axel_rear)
		_axel_rear.position = $AxelRearPos.position
	_UpdateAxelValues()

func set_steering(v : float) -> void:
	if _axel_fore != null:
		v = (clamp(v, -1.0, 1.0) + 1) * 0.5
		_steering_angle = (_axel_fore.steering_angle * 2 * v) - _axel_fore.steering_angle
		steering_changed.emit(_steering_angle)

func is_reverse() -> bool:
	return _reverse

func set_reverse(r : bool) -> void:
	if _reverse != r:
		_reverse = r
		_UpdateBreakLights()
		reversed.emit(_reverse)

func toggle_reverse() -> void:
	set_reverse(not _reverse)

func get_throttle() -> float:
	var emax : float = max_engine_power * (engine_reverse_multiplier if _reverse else 1.0)
	if emax != 0.0:
		return _engine_power / emax
	return 0.0

func set_throttle(v : float) -> void:
	v = max(0.0, min(1.0, v))
	var epm = engine_reverse_multiplier if _reverse else 1.0
	_engine_power = max_engine_power * epm * v
	throttle_changed.emit(v)

func set_break(v : float) -> void:
	v = max(0.0, min(1.0, v))
	_breaking_power = _max_breaking_power * v
	if _breaking_power > 0.0:
		breaking.emit()
	else:
		_UpdateBreakLights()

func toggle_headlights() -> void:
	if headlights and headlights_light:
		headlights.visible = not headlights.visible
		headlights_light.visible = headlights.visible

func stop_activity() -> void:
	_engine_power = 0.0
	_breaking_power = 0.0

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_interactable_area_body_entered(body : Node2D) -> void:
	if body.has_signal(&"alt_interacting"):
		if not body.is_connected(&"alt_interacting", _on_enter_requested):
			body.connect(&"alt_interacting", _on_enter_requested)


func _on_interactable_area_body_exited(body : Node2D) -> void:
	if body.has_signal(&"alt_interacting"):
		if body.is_connected(&"alt_interacting", _on_enter_requested):
			body.disconnect(&"alt_interacting", _on_enter_requested)

func _on_enter_requested(active : bool) -> void:
	if active and _enter_vehicle_timer == null:
		_enter_vehicle_timer = get_tree().create_timer(1.0)
		_enter_vehicle_timer.timeout.connect(_on_enter_request_triggered)
	elif not active and _enter_vehicle_timer != null:
		_enter_vehicle_timer.timeout.disconnect(_on_enter_request_triggered)
		_enter_vehicle_timer = null

func _on_enter_request_triggered() -> void:
	_enter_vehicle_timer = null
	enter_vehicle_requested.emit()


