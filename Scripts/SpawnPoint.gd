@tool
extends Node2D
class_name SpawnPoint


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const VEHICLE_COLOR : Color = Color.YELLOW
const CHARACTER_COLOR : Color = Color.WHEAT

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("SpawnPoint")
@export var character_offset : Vector2 = Vector2(96.0, 0.0)


# ------------------------------------------------------------------------------
# Setter
# ------------------------------------------------------------------------------
func set_character_offset(o : Vector2) -> void:
	character_offset = o
	queue_redraw()


# ------------------------------------------------------------------------------
# Override Method
# ------------------------------------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
		
	draw_rect(Rect2(Vector2(-32.0, -64), Vector2(64, 128)), VEHICLE_COLOR, true)
	draw_circle(character_offset, 32.0, CHARACTER_COLOR)
	var pv2a : PackedVector2Array = PackedVector2Array([
		Vector2.ZERO,
		Vector2(0.0, -96.0),
		Vector2(-32.0, -64.0),
		Vector2(0.0, -80.0),
		Vector2(32.0, -64.0),
		Vector2(0.0, -96.0)
	])
	draw_polyline(pv2a, Color.TOMATO, 1.0, true)


# ------------------------------------------------------------------------------
# Public Method
# ------------------------------------------------------------------------------
func get_vehicle_position() -> Vector2:
	return global_position

func get_character_position() -> Vector2:
	return global_position + character_offset.rotated(rotation)


