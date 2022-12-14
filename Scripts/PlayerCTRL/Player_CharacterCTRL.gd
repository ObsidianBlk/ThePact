extends Node

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal node_focus_requested(focus)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Player Character Control")
@export var character_group : String = "" :			set = set_character_group


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _character : WeakRef = weakref(null)

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_character_group(cp : String) -> void:
	if cp != character_group:
		character_group = cp
		_CheckCharacter(true)


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_CheckCharacter()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CheckCharacter(force_update : bool = false) -> void:
	var clear_character : bool = true
	if _character.get_ref() == null or force_update:
		if character_group != "":
			if is_inside_tree():
				var carr : Array = get_tree().get_nodes_in_group(character_group)
				for cn in carr:
					if cn is PAC and _character.get_ref() != cn:
						_character = weakref(cn)
						node_focus_requested.emit(cn)
						clear_character = false
						break
	if _character.get_ref() != null and clear_character:
		_character = weakref(null)


# ------------------------------------------------------------------------------
# Puplic Methods
# ------------------------------------------------------------------------------
func get_ctrl_type() -> StringName:
	return &"PlayerCharacterControl"

func enter(msg : Dictionary = {}) -> void:
	var character = _character.get_ref()
	if character != null:
		if &"spawn_point" in msg:
			if typeof(msg[&"spawn_point"]) == TYPE_VECTOR2:
				character.global_position = msg[&"spawn_point"]
		character.show(true)
		character.add_to_group(&"player_focus")
		node_focus_requested.emit(character)

func exit() -> void:
	var character = _character.get_ref()
	if character != null:
		character.remove_from_group(&"player_focus")
		character.show(false)

func handle_input(event : InputEvent) -> void:
	var char : PAC = _character.get_ref()
	if char == null:
		_CheckCharacter()
		return
	
	if event.is_action("c_forward") or event.is_action("c_backward"):
		# NOTE: This is for an X-axis aligned node.
		var amount = event.get_action_strength("c_forward") - event.get_action_strength("c_backward")
		char.move_v(amount)
	if event.is_action("c_strafe_left", true) or event.is_action("c_strafe_right", true):
		var amount = event.get_action_strength("c_strafe_right") - event.get_action_strength("c_strafe_left")
		char.move_h(amount)
	if event.is_action("c_turn_left", true) or event.is_action("c_turn_right", true):
		var amount = event.get_action_strength("c_turn_right") - event.get_action_strength("c_turn_left")
		char.turn(amount)
	if event.is_action("interact", true):
		var pressed : bool = event.is_pressed()
		if pressed and not event.is_echo():
			char.interact()
		elif not pressed:
			char.interact(false)
	if event.is_action("interact_alt", true):
		var pressed : bool = event.is_pressed()
		if pressed and not event.is_echo():
			char.interact(true, true)
		elif not pressed:
			char.interact(false, true)


