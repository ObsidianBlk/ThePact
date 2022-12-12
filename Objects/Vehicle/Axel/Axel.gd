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
@export var enable_trails : bool = true :						set = set_enable_trails

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var tll : TrailLine = $TrainLeftContainer/TrailLineLeft
@onready var tlr : TrailLine = $TrainRightContainer/TrailLineRight

@onready var ctll : Node2D = $TrainLeftContainer
@onready var ctlr : Node2D = $TrainRightContainer

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

func set_enable_trails(e : bool) -> void:
	if e != enable_trails:
		enable_trails = e
		if enable_trails:
			if tll:
				tll.clear_points()
			if tlr:
				tlr.clear_points()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	show_behind_parent = true
	_PositionTrails()

func _process(_delta : float) -> void:
	if not enable_trails:
		return
	
	if tll:
		tll.add_trail_point()
	if tlr:
		tlr.add_trail_point()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _PositionTrails() -> void:
	if ctll:
		ctll.position = Vector2.LEFT * beam_length
	if ctlr:
		ctlr.position = Vector2.RIGHT * beam_length
