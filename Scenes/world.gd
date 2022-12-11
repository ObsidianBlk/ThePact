extends Node2D


const AXEL : PackedScene = preload("res://Objects/Vehicle/Axel/Axel.tscn")

func _ready() -> void:
	$Vehicle.set_forward_axel(AXEL.instantiate())
	$Vehicle.set_rear_axel(AXEL.instantiate())
