@tool
extends Node2D
class_name PathGraphNode


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal position_changed(pos)
signal weight_changed(w)
signal enabled(e)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("GraphNode")
@export var connections : Array[NodePath] = [] :	set = set_connections

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _last_pos : Vector2 = Vector2.ZERO
var _weight : float = 1.0
var _enabled : bool = true

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_connections(c : Array[NodePath]) -> void:
	connections = c
	_UpdateConnectionSignals()
	if Engine.is_editor_hint():
		queue_redraw()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_last_pos = global_position

func _enter_tree() -> void:
	var parent = get_parent()
	if parent.has_method("_IsPathGraphReady"):
		if parent._IsPathGraphReady():
			_on_parent_ready()
		else:
			parent.ready.connect(_on_parent_ready)

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	draw_circle(Vector2.ZERO, 12.0, Color.PALE_TURQUOISE)
	
	var arrow_points = [
		Vector2(-1.0, 1.0),
		Vector2.ZERO,
		Vector2(-1.0, -1.0),
		Vector2(-0.5, 0.0),
		Vector2(-1.0, 1.0)
	]
	
	for connection in connections:
		var pgn = get_node_or_null(connection)
		if pgn is PathGraphNode:
			var dist : float = global_position.distance_to(pgn.global_position)
			var dir : Vector2 = global_position.direction_to(pgn.global_position)
			draw_line(Vector2.ZERO, dir * (dist * 0.5), Color.SPRING_GREEN, 2.0, true)
			for i in range(arrow_points.size() - 1):
				var pos : Vector2 = (Vector2.RIGHT * (dist * 0.5)).rotated(dir.angle())
				var pointA : Vector2 = (arrow_points[i].rotated(dir.angle()) * 12.0) + pos
				var pointB : Vector2 = (arrow_points[i + 1].rotated(dir.angle()) * 12.0) + pos
				draw_line(pointA, pointB, Color.SPRING_GREEN, 2.0, true)

func _process(_delta : float) -> void:
	if _last_pos != global_position:
		_last_pos = global_position
		if Engine.is_editor_hint():
			queue_redraw()
#			for connection in connections:
#				var pgn = get_node_or_null(connection)
#				if pgn is PathGraphNode:
#					pgn.queue_redraw()
		position_changed.emit(_last_pos)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateConnectionSignals() -> void:
	for connection in connections:
		print("Checking connection: ", connection)
		var redraw : bool = false
		var pgn = get_node_or_null(connection)
		if pgn is PathGraphNode:
			if Engine.is_editor_hint() and not pgn.is_connected(&"position_changed", _on_connection_position_changed):
				print("Connection to ", pgn.name, " position_changed")
				pgn.connect(&"position_changed", _on_connection_position_changed)
				redraw = true
			if not pgn.is_connected(&"tree_exiting", _on_connection_exiting.bind(connection)):
				print("Connection to ", pgn.name, " tree_exiting")
				pgn.connect(&"tree_exiting", _on_connection_exiting.bind(connection))
				redraw = true
			if redraw:
				pgn.queue_redraw()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_weight() -> float:
	return _weight

func set_weight(w : float) -> void:
	if w >= 0.0 and w != _weight:
		_weight = w
		weight_changed.emit(_weight)

func is_enabled() -> bool:
	return _enabled

func set_enabled(e : bool = true) -> void:
	if e != _enabled:
		_enabled = e
		enabled.emit(_enabled)

func remove_connection(node : PathGraphNode) -> void:
	var c : NodePath = get_path_to(node)
	var idx : int = connections.find(c)
	if idx >= 0:
		connections.remove_at(idx)
		if Engine.is_editor_hint():
			queue_redraw()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_parent_ready() -> void:
	print("Connections for ", name, " - ", connections)
	_UpdateConnectionSignals()
	queue_redraw()

func _on_connection_position_changed(_pos : Vector2) -> void:
	queue_redraw()

func _on_connection_exiting(pgn : Node, connection : NodePath) -> void:
	print("Removing connection: ", connection)
	if pgn.has_signal(&"position_changed"):
		if pgn.is_connected(&"position_changed", _on_connection_position_changed):
			pgn.disconnect(&"position_changed", _on_connection_position_changed)
	if pgn.is_connected(&"tree_exiting", _on_connection_exiting):
		pgn.disconnect(&"tree_exiting", _on_connection_exiting)
	var idx : int = connections.find(connection)
	if idx >= 0:
		connections.remove_at(idx)
		if Engine.is_editor_hint():
			queue_redraw()
