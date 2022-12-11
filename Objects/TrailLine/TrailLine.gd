extends Line2D
class_name TrailLine

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Trail Line")
@export var max_length : int = 100 :			set = set_max_length
@export var point_distance : float = 10.0 :		set = set_point_distance
@export var decay : float = 0.1 :				set = set_decay

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _last_point : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_max_length(l : int) -> void:
	if l > 0:
		max_length = l

func set_point_distance(d : float) -> void:
	if d > 0.0:
		point_distance = d

func set_decay(d : float) -> void:
	if d > 0.0:
		decay = d


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	top_level = true
	show_behind_parent = true


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _reset_timer() -> void:
	var timer : SceneTreeTimer = get_tree().create_timer(decay)
	timer.timeout.connect(_on_decay_timeout)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func add_trail_point() -> void:
	var parent = get_parent()
	if parent and points.size() < max_length:
		var point = parent.global_position
		if point.distance_to(_last_point) < point_distance:
			return
		add_point(point)
		if points.size() >= max_length:
			remove_point(0)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_decay_timeout() -> void:
	if points.size() > 0:
		remove_point(0)
	_reset_timer()

