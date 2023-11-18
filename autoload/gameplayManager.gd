extends Node

signal acceptPressed

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("acceptPressed")
