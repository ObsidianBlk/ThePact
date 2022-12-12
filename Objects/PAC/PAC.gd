extends CharacterBody2D
class_name PAC

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal interacting(active)
signal alt_interacting(active)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("PAC")
@export_range(0.0, 360.0) var turn_rate : float = 180.0 :	set = set_turn_rate
@export var walking_speed : float = 100.0 :					set = set_walking_speed
@export var walking_decel : float = 0.3 :					set = set_walking_decel
@export var running_speed : float = 200.0 :					set = set_running_speed
@export var running_decel : float = 0.1 :					set = set_running_decel

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _running : bool = false
var _direction : Vector2 = Vector2.ZERO
var _turn_strength : float = 0.0
var _target_rotation : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var lower_body_anim : AnimationPlayer = $LowerBody/Anim
@onready var upper_body_anim : AnimationPlayer = $UpperBody/Anim
@onready var upper_body_node : Node2D = $UpperBody
@onready var head_node : Sprite2D = $UpperBody/Head

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_turn_rate(tr : float) -> void:
	turn_rate = max(0.0, min(360.0, tr))
func set_walking_speed(a : float) -> void:
	if a > 0.0:
		walking_speed = a

func set_walking_decel(d : float) -> void:
	walking_decel = max(0.0, min(1.0, d))

func set_running_speed(a : float) -> void:
	if a >= 0.0:
		running_speed = a

func set_running_decel(d : float) -> void:
	running_decel = max(0.0, min(1.0, d))

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------

func _process(_delta : float) -> void:
	if velocity.length() > 1.0:
		var targ_anim : String = "run" if _running else "walk"
		if lower_body_anim.current_animation != targ_anim:
			lower_body_anim.play(targ_anim)
	elif lower_body_anim.current_animation != "idle":
		lower_body_anim.play("idle")

func _physics_process(delta : float) -> void:
	if abs(_turn_strength) > 0.0:
		rotation += deg_to_rad(turn_rate) * _turn_strength * delta
		_target_rotation = rotation
	elif _target_rotation != rotation:
		var target : Vector2 = position + Vector2.RIGHT.rotated(_target_rotation)
		var new_trans : Transform2D = transform.looking_at(target)
		transform = transform.interpolate_with(new_trans, deg_to_rad(turn_rate) * delta)

	if _direction.length_squared() > 0.1:
		var speed : Vector2 = _direction.rotated(rotation) * (running_speed if _running else walking_speed)
		velocity = speed
	else:
		velocity = velocity.lerp(Vector2.ZERO, (running_decel if _running else walking_decel))
		if velocity.length() < 0.5:
			velocity = Vector2.ZERO
	move_and_slide()


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func show(e : bool = true) -> void:
	visible = e
	$CollisionShape2D.disabled = not e

func is_running() -> bool:
	return _running

func run(e : bool = true) -> void:
	_running = e

func toggle_running() -> void:
	_running = not _running

func move_v(amount : float) -> void:
	# Verticle for this node is along the X axis.
	_direction.x = max(-1.0, min(1.0, amount))

func move_h(amount : float) -> void:
	# Horizontal for this node is along the Y axis.
	_direction.y = max(-1.0, min(1.0, amount))

func move(dir : Vector2) -> void:
	_direction = dir

func turn(amount : float) -> void:
	_turn_strength = maxf(-1.0, minf(1.0, amount))

func face_position(pos : Vector2) -> void:
	_turn_strength = 0.0
	_target_rotation = global_position.angle_to_point(pos)

func interact(active : bool = true, alt : bool = false) -> void:
	if alt:
		alt_interacting.emit(active)
	else:
		interacting.emit(active)



