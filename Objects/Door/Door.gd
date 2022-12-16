extends Node2D


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal door_opened()
signal door_closed()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const DOOR_STATE_OPEN : int = 1
const DOOR_STATE_CLOSED : int = 0
const DOOR_LENGTH : float = 96.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Door")
@export var transition_duration : float = 1.2
@export var detection_group : StringName = &""
@export var auto_open_group : StringName = &""


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _valid_bodies : Array = []
var _door_state : int = DOOR_STATE_CLOSED
var _tween : Tween = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var north_door : StaticBody2D = $NorthDoor
@onready var south_door : StaticBody2D = $SouthDoor
@onready var north_edge : Sprite2D = $NorthEdge
@onready var south_edge : Sprite2D = $SouthEdge

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _EnableLights(e : bool) -> void:
	for child in north_edge.get_children():
		if child is PointLight2D:
			child.visible = e
	for child in south_edge.get_children():
		if child is PointLight2D:
			child.visible = e

func _OpenDoors() -> void:
	if _door_state == DOOR_STATE_CLOSED:
		if _tween != null:
			_tween.kill()
			_tween = null
		
		_tween = create_tween()
		
		var dur : float = (1.0 - (north_door.position.y / (-DOOR_LENGTH))) * transition_duration
		_tween.tween_method(_on_north_door_update, north_door.position, Vector2(0.0, -DOOR_LENGTH), dur)
		
		_tween.parallel()
		
		dur = (1.0 - (south_door.position.y / (DOOR_LENGTH))) * transition_duration
		_tween.tween_method(_on_south_door_update, south_door.position, Vector2(0.0, DOOR_LENGTH), dur)
		
		_tween.finished.connect(func(): _tween = null)
		_door_state = DOOR_STATE_OPEN
		door_opened.emit()

func _CloseDoor() -> void:
	if _door_state == DOOR_STATE_OPEN:
		if _tween != null:
			_tween.kill()
			_tween = null
		
		_tween = create_tween()
		
		var dur : float = (north_door.position.y / (-DOOR_LENGTH)) * transition_duration
		_tween.tween_method(_on_north_door_update, north_door.position, Vector2.ZERO, dur)
		
		_tween.parallel()
		
		dur = (south_door.position.y / DOOR_LENGTH) * transition_duration
		_tween.tween_method(_on_south_door_update, south_door.position, Vector2.ZERO, dur)
		
		_tween.finished.connect(func(): _tween = null)
		_door_state = DOOR_STATE_CLOSED
		door_closed.emit()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_door_open() -> bool:
	return _door_state == DOOR_STATE_OPEN

func open_door(open : bool = true, instant : bool = false) -> void:
	if open and _door_state == DOOR_STATE_CLOSED:
		if instant:
			north_door.position.y = -DOOR_LENGTH
			south_door.position.y = DOOR_LENGTH
			_door_state = DOOR_STATE_OPEN
		else:
			_OpenDoors()
	elif not open and _door_state == DOOR_STATE_OPEN:
		if instant:
			north_door.position.y = 0
			south_door.position.y = 0
			_door_state = DOOR_STATE_CLOSED
		else:
			_CloseDoor()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_north_door_update(val : Vector2) -> void:
	north_door.position = val
	for rid in NavigationServer2D.get_maps():
		NavigationServer2D.map_force_update(rid)

func _on_south_door_update(val : Vector2) -> void:
	south_door.position = val
	for rid in NavigationServer2D.get_maps():
		NavigationServer2D.map_force_update(rid)

func _on_detection_body_entered(body : Node2D) -> void:
	if body.is_in_group(detection_group):
		if _valid_bodies.find(body) < 0:
			_valid_bodies.append(body)
			_EnableLights(true)


func _on_detection_body_exited(body : Node2D) -> void:
	var idx : int = _valid_bodies.find(body)
	if idx >= 0:
		_valid_bodies.remove_at(idx)
		if _valid_bodies.size() <= 0:
			_EnableLights(false)
			if _door_state == DOOR_STATE_OPEN:
				_CloseDoor()


func _on_char_detection_body_entered(body : Node2D) -> void:
	if body.is_in_group(auto_open_group) and _door_state != DOOR_STATE_OPEN:
		_OpenDoors()

