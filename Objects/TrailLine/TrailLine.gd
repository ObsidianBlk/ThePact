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
var _last_point : Vector2 = null

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
	set_notify_transform(false)
	show_behind_parent = true


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _reset_timer() -> void:
	var timer : SceneTreeTimer = get_tree().create_timer(decay)
	timer.timeout.connect(_on_decay_timeout)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _on_decay_timeout() -> void:
	if points.size() > 0:
		remove_point(0)
	_reset_timer()

