extends Node2D

@onready var party = $party
var points = [
	Vector2(200, 215),
	Vector2(200, 100),
	Vector2(300, 100),
	Vector2(300, 300)
]

func _ready():
	pass

func animation():
	party.can_move = false
	
	await get_tree().create_timer(0.5).timeout
	
	for point in points:
		party.team_move(point)
		
		await party.anim_ended
