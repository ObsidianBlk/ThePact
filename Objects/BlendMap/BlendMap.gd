@tool
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
		print("Updating Scale")
		_UpdateShaderParam(&"texture_scale", texture_scale)

func set_texture_a(t : Texture) -> void:
	texture_a = t
	print("Updating TextureA")
	_UpdateShaderParam(&"textureA", texture_a)

func set_texture_b(t : Texture) -> void:
	texture_b = t
	print("Updating TextureB")
	_UpdateShaderParam(&"textureB", texture_b)

func set_texture_c(t : Texture) -> void:
	texture_c = t
	print("Updating TextureC")
	_UpdateShaderParam(&"textureC", texture_c)

func set_texture_d(t : Texture) -> void:
	texture_d = t
	print("Updating TextureD")
	_UpdateShaderParam(&"textureD", texture_d)

func set_blend_texture(t : Texture) -> void:
	blend_texture = t
	if _sprite:
		print("Attempting to set Sprite Texture")
		_sprite.texture = blend_texture

func set_preserve_blend_alpha(e : bool) -> void:
	if e != preserve_blend_alpha:
		preserve_blend_alpha = e
		_UpdateShaderParam(&"preserve_alpha", preserve_blend_alpha)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if blend_texture != null:
		_sprite.texture = blend_texture
	_UpdateAllShaderParams()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateAllShaderParams() -> void:
	_UpdateShaderParam(&"texture_scale", texture_scale)
	_UpdateShaderParam(&"textureA", texture_a)
	_UpdateShaderParam(&"textureB", texture_b)
	_UpdateShaderParam(&"textureC", texture_c)
	_UpdateShaderParam(&"textureD", texture_d)
	_UpdateShaderParam(&"preserve_alpha", preserve_blend_alpha)


func _UpdateShaderParam(property : StringName, value) -> void:
	if _sprite:
		if _sprite.material != null:
			_sprite.material.set_shader_parameter(property, value)


