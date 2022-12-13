@tool
extends Node2D
class_name PathGraph2D


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _is_ready : bool = false
var _astar : AStar2D = AStar2D.new()
var _compiled : bool = false

# ------------------------------------------------------------------------------
# Override Mathods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_is_ready = true
	pass
	#child_entered_tree.connect(_on_child_entered)
	#child_exiting_tree.connect(_on_child_exiting)

# ------------------------------------------------------------------------------
# Private Mathods
# ------------------------------------------------------------------------------
func _IsPathGraphReady() -> bool:
	return _is_ready

# ------------------------------------------------------------------------------
# Public Mathods
# ------------------------------------------------------------------------------
func is_compiled() -> bool:
	return _compiled

func compile() -> int:
	if Engine.is_editor_hint():
		return ERR_CANT_CREATE
	return OK

func get_astar() -> AStar2D:
	return _astar

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_child_entered(node : Node) -> void:
	if node is PathGraphNode:
		if not node.is_connected(&"position_changed", _on_node_position_changed.bind(node)):
			node.connect(&"position_changed", _on_node_position_changed.bind(node))
		if not node.is_connected(&"weight_changed", _on_node_weight_changed.bind(node)):
			node.connect(&"weight_changed", _on_node_weight_changed.bind(node))
		if not node.is_connected(&"enabled", _on_node_enabled.bind(node)):
			node.connect(&"enabled", _on_node_enabled.bind(node))
	print("Child node entered: ", node.name)

func _on_child_exiting(node : Node) -> void:
	if node is PathGraphNode:
		if node.is_connected(&"position_changed", _on_node_position_changed.bind(node)):
			node.disconnect(&"position_changed", _on_node_position_changed.bind(node))
		if node.is_connected(&"weight_changed", _on_node_weight_changed.bind(node)):
			node.disconnect(&"weight_changed", _on_node_weight_changed.bind(node))
		if node.is_connected(&"enabled", _on_node_enabled.bind(node)):
			node.disconnect(&"enabled", _on_node_enabled.bind(node))
		
		var children : Array = get_children()
		for connection in node.connections:
			for child in children:
				if child is PathGraphNode:
					child.remove_connection(node)
		if not Engine.is_editor_hint():
			_compiled = false
			_astar.clear()

func _on_node_position_changed(pos : Vector2, node : PathGraphNode) -> void:
	pass

func _on_node_weight_changed(weight : float, node : PathGraphNode) -> void:
	pass

func _on_node_enabled(enabled : bool, node : PathGraphNode) -> void:
	pass
