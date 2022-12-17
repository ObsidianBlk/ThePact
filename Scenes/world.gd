extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const AXEL : PackedScene = preload("res://Objects/Vehicle/Axel/Axel.tscn")


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var power_meter : Control = $GameUI/PowerMeter

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_ConnectAxelsToVehicle(20.0, 20.0)
	$PlayerCTRL.player_dead.connect(_on_player_dead)
	$Map.dropplet_picked_up.connect(_on_pickup)
	
	var spawn : Dictionary = $Map.get_random_spawnpoint()
	$PlayerCTRL.revive(spawn)
	$Map.start()


func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectAxelsToVehicle(beam : float, steering : float) -> void:
	var axel : Axel = AXEL.instantiate()
	axel.beam_length = beam
	axel.steering_angle = steering
	$Vehicle.set_forward_axel(axel)
	
	axel = AXEL.instantiate()
	axel.beam_length = beam
	$Vehicle.set_rear_axel(axel)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_pickup(tainted : bool) -> void:
	power_meter.increment_bar(tainted)

func _on_player_dead() -> void:
	pass

