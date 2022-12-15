@tool
extends PointLight2D


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Flicker Light")
@export var enable : bool = false
@export var scale_variance : float = 0.5
@export var energy_variance : float = 0.5
@export var transition_time : float = 0.2
@export var transition_variance : float = 0.8


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _rng : RandomNumberGenerator = RandomNumberGenerator.new()
var _base_scale : float = 0.0
var _base_energy : float = 0.0

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_enable(e : bool) -> void:
	if enable != e:
		enable = e
		if enable:
			_TweenState()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_rng.seed = randi()
	_base_scale = scale.x
	_base_energy = energy
	_TweenState()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _TweenState() -> void:
	if not enable:
		return
	
	var variance : float = transition_time * transition_variance
	var dur : float = _rng.randf_range(variance, transition_time + variance)
	
	variance = _base_scale * scale_variance
	var nscale : float = _rng.randf_range(variance, _base_scale + variance)
	
	variance = _base_energy * energy_variance
	var nenergy : float = _rng.randf_range(variance, _base_energy + variance)
	
	var _tween : Tween = create_tween()
	_tween.tween_property(self, "scale", Vector2(nscale, nscale), dur)
	_tween.tween_property(self, "energy", nenergy, dur)
	_tween.parallel()
	_tween.finished.connect(_TweenState)
