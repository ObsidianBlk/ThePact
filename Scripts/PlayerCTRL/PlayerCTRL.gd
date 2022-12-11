extends Node

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const MODE_VEHICLE : int = 0
const MODE_CHARACTER : int = 1

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Player Control")
@export var vehicle_ctrl_path : NodePath = ^""
@export var character_ctrl_path : NodePath = ^""


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _mode : int = MODE_VEHICLE
var _vehicle_ctrl : WeakRef = weakref(null)
var _character_ctrl : WeakRef = weakref(null)

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_vehicle_ctrl_path(vcp : NodePath) -> void:
	if vcp != vehicle_ctrl_path:
		vehicle_ctrl_path = vcp
		_CheckVehicleCTRL(true)

func set_character_ctrl_path(ccp : NodePath) -> void:
	if ccp != character_ctrl_path:
		character_ctrl_path = ccp
		_CheckCharacterCTRL(true)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_CheckVehicleCTRL()
	_CheckCharacterCTRL()

func _unhandled_input(event : InputEvent) -> void:
	var ctrl : Node = _GetActiveControl()
	if ctrl != null:
		ctrl.handle_input(event)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CheckVehicleCTRL(force_update : bool = false) -> void:
	if _vehicle_ctrl.get_ref() == null or force_update:
		if vehicle_ctrl_path != ^"":
			var vn = get_node_or_null(vehicle_ctrl_path)
			if vn.has_method("get_ctrl_type") and vn.get_ctrl_type() == &"PlayerVehicleControl":
				_vehicle_ctrl = weakref(vn)
		elif _vehicle_ctrl.get_ref() != null:
			_vehicle_ctrl = weakref(null)

func _CheckCharacterCTRL(force_update : bool = false) -> void:
	if _character_ctrl.get_ref() == null or force_update:
		if character_ctrl_path != ^"":
			var cn = get_node_or_null(character_ctrl_path)
			if cn.has_method("get_ctrl_type") and cn.get_ctrl_type() == &"PlayerCharacterControl":
				_character_ctrl = weakref(cn)
		elif _character_ctrl.get_ref() != null:
			_character_ctrl = weakref(null)

func _GetActiveControl() -> Node:
	match _mode:
		MODE_VEHICLE:
			return _vehicle_ctrl.get_ref()
		MODE_CHARACTER:
			return _character_ctrl.get_ref()
	return null

