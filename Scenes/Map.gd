extends Node2D


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal map_stopped()
signal dropplet_picked_up(tainted)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const DROPPLET : PackedScene = preload("res://Objects/Dropplet/Dropplet.tscn")
const DROPPLET_SPAWN_DELAY : float = 1.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _active : bool = false
var _max_available_dropplet_markers : int = 0
var _available_dropplet_markers : Array = []
var _used_dropplet_markers : Array = []


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _dropplet_spawner_container : Node2D = $DroppletSpawners
@onready var _dropplet_container : Node2D = $Dropplets

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	for child in _dropplet_spawner_container.get_children():
		if child is Marker2D:
			_available_dropplet_markers.append(child.position)
			_dropplet_spawner_container.remove_child(child)
			child.queue_free()
	_max_available_dropplet_markers = _available_dropplet_markers.size()
	if _active == true:
		_StartMap()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _StartMap() -> void:
	_SpawnRandomDropplet()
	_SpawnRandomDropplet()
	_SpawnRandomDropplet()
	_SpawnRandomDropplet()
	_SpawnRandomDropplet()
	_PotentialRandSpawnDropplet()

func _SpawnRandomDropplet() -> void:
	var idx : int = randi_range(0, _available_dropplet_markers.size() - 1)
	if idx < _available_dropplet_markers.size():
		var dropplet : Node2D = DROPPLET.instantiate()
		var pos : Vector2 = _available_dropplet_markers[idx]
		_available_dropplet_markers.remove_at(idx)
		_used_dropplet_markers.append(pos)
		dropplet.position = pos
		dropplet.dropplet_picked_up.connect(_on_dropplet_picked_up.bind(pos))
		_dropplet_container.add_child(dropplet)


func _PotentialRandSpawnDropplet() -> void:
	if _active != true or _max_available_dropplet_markers <= 0:
		return
	
	var probability : float = float(_available_dropplet_markers.size()) / float(_max_available_dropplet_markers)
	if probability > 0.0 and randf() <= probability:
		_SpawnRandomDropplet()
	var timer : SceneTreeTimer = get_tree().create_timer(DROPPLET_SPAWN_DELAY)
	timer.timeout.connect(_PotentialRandSpawnDropplet)

func _PopAllDropplets() -> void:
	for child in _dropplet_container.get_children():
		if child.has_method("die"):
			child.die()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_active() -> bool:
	return _active

func start() -> void:
	if not _active:
		_active = true
		if _max_available_dropplet_markers > 0:
			_StartMap()
		

func stop() -> void:
	if _active:
		_active = false
		_PopAllDropplets()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_dropplet_picked_up(tainted : bool, pos : Vector2) -> void:
	var idx : int = _used_dropplet_markers.find(pos)
	if idx >= 0:
		_used_dropplet_markers.remove_at(idx)
		_available_dropplet_markers.append(pos)
		if _used_dropplet_markers.size() <= 0 and not _active:
			map_stopped.emit()
	dropplet_picked_up.emit(tainted)



