extends Node2D
class_name BlendMap

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("BlendMap")
@export var texture_scale : float = 1.0 :			set = set_texture_scale
@export var texture_a : Texture = null :			set = set_texture_a
@export var texture_b : Texture = null :			set = set_texture_b
@export var texture_c : Texture = null :			set = set_texture_c
@export var texture_d : Texture = null :			set = set_texture_d
@export var blend_texture : Texture = null :		set = set_blend_texture
@export var preserve_blend_alpha : bool = true :	set = set_preserve_blend_alpha

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite : Sprite2D = $Sprite2D

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_texture_scale(s : float) -> void:
	if s > 0.0:
		texture_scale = s

func set_texture_a(t : Texture) -> void:
	texture_a = t

func set_texture_b(t : Texture) -> void:
	texture_b = t

func set_texture_c(t : Texture) -> void:
	texture_c = t

func set_texture_d(t : Texture) -> void:
	texture_d = t

func set_blend_texture(t : Texture) -> void:
	blend_texture = t
	if _sprite:
		_sprite.texture = blend_texture

func set_preserve_blend_alpha(e : bool) -> void:
	if e != preserve_blend_alpha:
		preserve_blend_alpha = e

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if blend_texture != null:
		_sprite.texture = blend_texture




