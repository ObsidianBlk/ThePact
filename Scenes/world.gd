extends Node2D


func _ready() -> void:
	$Vehicle.set_forward_axel(Axel.new())
	$Vehicle.set_rear_axel(Axel.new())
