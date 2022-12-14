extends CharacterBody2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const AGENT_UPDATE_DELAY : float = 0.1

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Ghost")
@export var target_group : StringName = &""
@export var speed : float = 400.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _target : WeakRef = weakref(null)


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var agent : NavigationAgent2D = $Agent

# ------------------------------------------------------------------------------
# Override Method
# ------------------------------------------------------------------------------
func _ready() -> void:
	_CheckActiveTarget()
	var timer : SceneTreeTimer = get_tree().create_timer(AGENT_UPDATE_DELAY)
	timer.timeout.connect(_on_update_agent_target_position)

func _physics_process(delta : float) -> void:
	if agent.is_navigation_finished():
		return
	
	if agent.is_target_reachable() and not agent.is_target_reached():
		var nloc : Vector2 = agent.get_next_location()
		var dir : Vector2 = global_position.direction_to(nloc)
		velocity += ((dir * speed) - velocity) * delta
		move_and_slide()
		rotation = velocity.angle()

# ------------------------------------------------------------------------------
# Private Method
# ------------------------------------------------------------------------------
func _CheckActiveTarget() -> void:
	if target_group == &"":
		if _target.get_ref() != null:
			_target = weakref(null)
		return
	
	var tlist = get_tree().get_nodes_in_group(target_group)
	if tlist.size() > 0:
		if tlist[0] != _target.get_ref():
			print("My target is currently: ", tlist[0].name)
			_target = weakref(tlist[0])

# ------------------------------------------------------------------------------
# Handler Method
# ------------------------------------------------------------------------------
func _on_update_agent_target_position() -> void:
	_CheckActiveTarget()
	var target = _target.get_ref()
	if target != null:
		agent.target_location = target.global_position
	var timer : SceneTreeTimer = get_tree().create_timer(AGENT_UPDATE_DELAY)
	timer.timeout.connect(_on_update_agent_target_position)
