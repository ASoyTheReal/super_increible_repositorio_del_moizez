extends Node


var playerx = Vector2(0, 0)
var playery = Vector2(0, 0)
var spawnpoint = ""
var current_level = ""
var LookAt = 0


###########Prevent loop Variables#################
var playerforloopspeed = 2
func stopquieting():
	playerforloopspeed = 2
