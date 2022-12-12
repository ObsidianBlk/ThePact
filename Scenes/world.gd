extends Node2D


const AXEL : PackedScene = preload("res://Objects/Vehicle/Axel/Axel.tscn")

func _ready() -> void:
	var axel : Axel = AXEL.instantiate()
	axel.beam_length = 20
	$Vehicle.set_forward_axel(axel)
	
	axel = AXEL.instantiate()
	axel.beam_length = 20
	$Vehicle.set_rear_axel(axel)
