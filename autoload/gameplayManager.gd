extends Node

signal acceptPressed

var party_ids : Array[String] = ["kris", "susie", "ralsei"]

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("acceptPressed")
