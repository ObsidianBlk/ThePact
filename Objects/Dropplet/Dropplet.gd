extends Area2D


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal dropplet_picked_up(tainted)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const TAINTED_PARTICLES : ParticleProcessMaterial = preload("res://Objects/Dropplet/TraintedParticleMat.tres")
const TAINTED_COLOR : Color = Color.PURPLE
const DECAY_TIME : float = 1.0


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _dead : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var particles : GPUParticles2D = $GPUParticles2D
@onready var light : PointLight2D = $PointLight2D

@onready var clean_sprite : Sprite2D = $Goo_Clean
@onready var tainted_sprite : Sprite2D = $Goo_Tainted

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(_delta : float) -> void:
	if not particles.emitting:
		_Remove()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Remove() -> void:
	var parent = get_parent()
	if parent != null:
		parent.remove_child(self)
	queue_free()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func taint() -> void:
	particles.process_material = TAINTED_PARTICLES
	light.color = TAINTED_COLOR
	clean_sprite.visible = false
	tainted_sprite.visible = true

func die() -> void:
	if not _dead:
		_dead = true
		var sprite : Sprite2D = clean_sprite if clean_sprite.visible else tainted_sprite
		var _tween : Tween = create_tween()
		_tween.tween_property(sprite, "scale", Vector2.ZERO, DECAY_TIME)
		_tween.parallel()
		_tween.tween_method(_on_decay, 1.0, 0.0, DECAY_TIME)
		_tween.finished.connect(func(): particles.one_shot = true)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_body_entered(body : Node2D) -> void:
	if body.is_in_group(&"player"):
		dropplet_picked_up.emit(tainted_sprite.visible)
		die()

func _on_decay(val : float) -> void:
	light.set_base_energy(light.get_base_energy() * val)
	light.set_base_scale(light.get_base_scale() * val)

