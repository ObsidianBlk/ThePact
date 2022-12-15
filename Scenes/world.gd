extends Node2D


const AXEL : PackedScene = preload("res://Objects/Vehicle/Axel/Axel.tscn")

func _ready() -> void:
	var axel : Axel = AXEL.instantiate()
	axel.beam_length = 20
	axel.steering_angle = 20.0
	$Vehicle.set_forward_axel(axel)
	
	axel = AXEL.instantiate()
	axel.beam_length = 20
	$Vehicle.set_rear_axel(axel)

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
