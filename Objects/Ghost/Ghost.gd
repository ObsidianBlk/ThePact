@tool
extends CharacterBody2D


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal target_caught()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const AGENT_UPDATE_DELAY : float = 0.1
const POI_UPDATE_DELAY : float = 3.0
const POI_UPDATE_DELAY_VARIANCE : float = 0.5

const REAPER_GROUP : StringName = &"reaper"
const DEAD_GROUP : StringName = &"dead"
const DROPPLET_GROUP : StringName = &"dropplet"
const SCAN_INTERVAL : int = 40
const SCAN_INTERVAL_ANGLE : float = deg_to_rad(2.0)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Ghost")
@export var target_group : StringName = &""
@export var poi_group : StringName = &""
@export var explore_speed : float = 300.0
@export var chase_speed : float = 500.0
@export var color : Color = Color.WHITE


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _target : WeakRef = weakref(null)
var _poi : WeakRef = weakref(null)
var _poi_timer : SceneTreeTimer = null

var _visible_dropplets : Array = []

var _fear_the_reaper : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var agent : NavigationAgent2D = $Agent
@onready var light : PointLight2D = $PointLight2D
@onready var colshape : CollisionShape2D = $Detection/CollisionShape2D
@onready var body_node : Node2D = $Body

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_color(c : Color) -> void:
	color = c
	if light:
		light.color = color

# ------------------------------------------------------------------------------
# Override Method
# ------------------------------------------------------------------------------
func _ready() -> void:
	#_CheckActiveTarget()
	light.color = color
	if not Engine.is_editor_hint():
		var timer : SceneTreeTimer = get_tree().create_timer(AGENT_UPDATE_DELAY)
		timer.timeout.connect(_on_update_agent_target_position)

func _physics_process(delta : float) -> void:
	if Engine.is_editor_hint():
		return
	
	if agent.is_navigation_finished():
		if _poi_timer != null:
			var min_delay : float = POI_UPDATE_DELAY * POI_UPDATE_DELAY_VARIANCE
			_poi_timer = get_tree().create_timer(randf_range(min_delay, POI_UPDATE_DELAY + min_delay))
			_poi_timer.timeout.connect(_UpdatePOI)
		elif not _TargetChaseable():
			_TaintADropplet()
			_UpdatePOI()
	
	if agent.is_target_reachable() and not agent.is_target_reached():
		var nloc : Vector2 = agent.get_next_location()
		var dir : Vector2 = global_position.direction_to(nloc)
		var speed : float = chase_speed if _target.get_ref() != null else explore_speed
		velocity += ((dir * speed) - velocity) * delta
		move_and_slide()
		body_node.rotation = velocity.angle()

# ------------------------------------------------------------------------------
# Private Method
# ------------------------------------------------------------------------------
func _TargetChaseable() -> bool:
	if _target.get_ref() != null:
		return not _target.get_ref().is_in_group(DEAD_GROUP)
	return false

func _UpdatePOI() -> void:
	_ClearPOITimer()
	if poi_group != &"" and not _TargetChaseable():
		var plist = get_tree().get_nodes_in_group(poi_group)
		if plist.size() > 0:
			var idx : int = randi_range(0, plist.size() - 1)
			if plist[idx] != _poi.get_ref():
				_poi = weakref(plist[idx])
				agent.target_location = plist[idx].global_position

func _ClearPOITimer() -> void:
	if _poi_timer != null:
		_poi_timer.timeout.disconnect(_UpdatePOI)
		_poi_timer = null

func _TaintADropplet() -> void:
	if _visible_dropplets.size() > 0:
		var idx = randi_range(0, _visible_dropplets.size() - 1)
		if not _visible_dropplets[idx].is_tainted():
			_visible_dropplets[idx].taint()

# ------------------------------------------------------------------------------
# Handler Method
# ------------------------------------------------------------------------------
func _on_update_agent_target_position() -> void:
	#_CheckActiveTarget()
	var target = _target.get_ref()
	if target != null:
		if target.is_in_group(DEAD_GROUP):
			if _poi_timer == null:
				_UpdatePOI()
			return
		_ClearPOITimer()
		if target.is_in_group(REAPER_GROUP):
			var r : float = colshape.shape.radius
			var dir : Vector2 = target.global_position.direction_to(global_position)
			var run_pos : Vector2 = dir * r
			var intervals : Array = []
			if randf() >= 0.5:
				intervals = range(0, SCAN_INTERVAL + 1)
				intervals.append_array(range(0, -(SCAN_INTERVAL + 1), -1))
			else:
				intervals = range(0, -(SCAN_INTERVAL + 1), -1)
				intervals.append_array(range(0, SCAN_INTERVAL + 1))
			var found : bool = false
			for i in intervals:
				var pos : Vector2 = run_pos.rotated(i + SCAN_INTERVAL_ANGLE)
				agent.target_location = pos
				if agent.is_target_reachable():
					found = true
					break
		else:
			agent.target_location = target.global_position
	var timer : SceneTreeTimer = get_tree().create_timer(AGENT_UPDATE_DELAY)
	timer.timeout.connect(_on_update_agent_target_position)


func _on_detection_body_entered(body : Node2D) -> void:
	if Engine.is_editor_hint():
		return
	
	if body.is_in_group(target_group):
		if _target.get_ref() != body:
			_target = weakref(body)


func _on_detection_body_exited(body : Node2D) -> void:
	if Engine.is_editor_hint():
		return
		
	if body == _target.get_ref():
		_target = weakref(null)


func _on_KillZone_body_entered(body : Node2D) -> void:
	if body.is_in_group(target_group):
		target_caught.emit()


func _on_drop_finder_area_entered(area : Area2D) -> void:
	if area.is_in_group(DROPPLET_GROUP) and not _TargetChaseable():
		if _visible_dropplets.find(area) < 0:
			_visible_dropplets.append(area)

func _on_drop_finder_area_exited(area : Area2D) -> void:
	var idx : int = _visible_dropplets.find(area)
	if idx >= 0:
		_visible_dropplets.remove_at(idx)
