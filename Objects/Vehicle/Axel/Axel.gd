extends Node2D
class_name Axel

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Axel")
@export var beam_length : float = 10.0 :						set = set_beam_length
@export_range(0.0, 180.0) var steering_angle : float = 15.0 :	set = set_steering_angle
@export var breaking_power : float = 450.0 :					set = set_breaking_power
@export_range(0.0, 1.0) var traction_slow : float = 0.7 :		set = set_traction_slow
@export_range(0.0, 1.0) var traction_fast : float = 0.1 :		set = set_traction_fast
@export_range(0.0, 1.0) var friction : float = 0.9 :			set = set_friction
@export_range(0.0, 1.0) var drag : float = 0.0015 :				set = set_drag

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var tll : TrailLine = $TrailLineLeft
@onready var tlr : TrailLine = $TrailLineRight

# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_beam_length(l : float) -> void:
	if l > 0.0:
		beam_length = l
		_PositionTrails()

func set_steering_angle(a : float) -> void:
	steering_angle = max(0.0, min(180.0, a))

func set_breaking_power(b : float) -> void:
	if b >= 0.0:
		breaking_power = b

func set_traction_slow(t : float) -> void:
	traction_slow = max(0.0, min(1.0, t))

func set_traction_fast(t : float) -> void:
	traction_fast = max(0.0, min(1.0, t))

func set_friction(f : float) -> void:
	friction = max(0.0, min(1.0, f))

func set_drag(d : float) -> void:
	drag = max(0.0, min(1.0, d))

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	show_behind_parent = true
	_PositionTrails()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _PositionTrails() -> void:
	if tll and tlr:
		tll.position = Vector2.LEFT * beam_length
		tlr.position = Vector2.RIGHT * beam_length
