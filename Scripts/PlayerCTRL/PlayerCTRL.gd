extends Node

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal node_focus_requested(focus)

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
var _mode : int = MODE_CHARACTER
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
				vn.connect(&"control_requested", _on_vehicle_control_requested)
				vn.connect(&"control_relinquished", _on_vehicle_control_relinquished)
				vn.connect(&"node_focus_requested", _on_node_focus_requested)
				_vehicle_ctrl = weakref(vn)
				if _mode == MODE_VEHICLE:
					vn.enter()
		elif _vehicle_ctrl.get_ref() != null:
			var vn = _vehicle_ctrl.get_ref()
			vn.disconnect(&"control_requested", _on_vehicle_control_requested)
			vn.disconnect(&"control_relinquished", _on_vehicle_control_relinquished)
			vn.disconnect(&"node_focus_requested", _on_node_focus_requested)
			_vehicle_ctrl = weakref(null)

func _CheckCharacterCTRL(force_update : bool = false) -> void:
	if _character_ctrl.get_ref() == null or force_update:
		if character_ctrl_path != ^"":
			var cn = get_node_or_null(character_ctrl_path)
			if cn.has_method("get_ctrl_type") and cn.get_ctrl_type() == &"PlayerCharacterControl":
				cn.connect(&"node_focus_requested", _on_node_focus_requested)
				_character_ctrl = weakref(cn)
				if _mode == MODE_CHARACTER:
					cn.enter()
		elif _character_ctrl.get_ref() != null:
			var cn = _character_ctrl.get_ref()
			cn.disconnect(&"node_focus_requested", _on_node_focus_requested)
			_character_ctrl = weakref(null)

func _GetActiveControl() -> Node:
	match _mode:
		MODE_VEHICLE:
			return _vehicle_ctrl.get_ref()
		MODE_CHARACTER:
			return _character_ctrl.get_ref()
	return null

func _ChangeMode(new_mode : int, msg : Dictionary = {}) -> void:
	if new_mode != _mode:
		var ctrl = _GetActiveControl()
		if ctrl != null:
			ctrl.exit()
		_mode = new_mode
		ctrl = _GetActiveControl()
		if ctrl != null:
			print("MSG: ", msg)
			ctrl.enter(msg)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_vehicle_control_requested() -> void:
	_ChangeMode(MODE_VEHICLE)

func _on_vehicle_control_relinquished(msg : Dictionary = {}) -> void:
	_ChangeMode(MODE_CHARACTER, msg)

func _on_node_focus_requested(focus_node : Node2D) -> void:
	node_focus_requested.emit(focus_node)
