extends KinematicBody2D

class_name Player



var Run = false
var velocity = Vector2.ZERO
var velocidad = 100 * PlayerGlobal.playerforloopspeed
var aceleratiom = 500
var max_speed = 100
var Friction = 500
onready var mira = $RayCast2D
onready var Animtree = $AnimationTree
onready var Animstate = $AnimationTree.get("parameters/playback")


func _physics_process(delta):
	if Input.is_action_pressed("Run"):
		Run = true
	else:
		Run = false
	if Run == true:
		velocidad = 100 * PlayerGlobal.playerforloopspeed
	else:
		velocidad = 50 * PlayerGlobal.playerforloopspeed
	
	var movimiento = Vector2.ZERO
	movimiento.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	movimiento.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if movimiento != Vector2.ZERO and Run == false:
		Animtree.set("parameters/Run/blend_position", movimiento)
		Animtree.set("parameters/Walk/blend_position", movimiento)
		Animtree.set("parameters/Idle/blend_position", movimiento)
		velocity = velocity.move_toward(movimiento * max_speed, aceleratiom * delta)
		Animstate.travel("Walk")
	else:
		Animstate.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)
	
	if movimiento != Vector2.ZERO and Run == true:
		Animtree.set("parameters/Run/blend_position", movimiento)
		Animtree.set("parameters/Walk/blend_position", movimiento)
		Animtree.set("parameters/Idle/blend_position", movimiento)
		Animstate.travel("Run")
	
	
	if Input.is_action_pressed("ui_up"):
		mira.set_rotation_degrees(180)
	if Input.is_action_pressed("ui_left"):
		mira.set_rotation_degrees(90)
	if Input.is_action_pressed("ui_right"):
		mira.set_rotation_degrees(-90)
	if Input.is_action_pressed("ui_down"):
		mira.set_rotation_degrees(0)
	
	
	move_and_slide(movimiento * velocidad)

func _input(event):
	if Input.is_action_just_pressed("Interact"):
		$RayCast2D/InteractionSystem/CollisionShape2D.disabled = false
	else:
		$RayCast2D/InteractionSystem/CollisionShape2D.disabled = true

func _ready():
	$RayCast2D/InteractionSystem/CollisionShape2D.disabled = true
	var spawnpoints = get_tree().get_nodes_in_group("spawnpoints")
	for spawnpoint in spawnpoints:
		if spawnpoint.name == PlayerGlobal.spawnpoint:
			global_position = spawnpoint.global_position
			break


func _on_LookAt_timeout():
	if PlayerGlobal.LookAt == 1:
		$AnimationPlayer.play("IdleUp")
		print("Works")
	if PlayerGlobal.LookAt == 2:
		$AnimationPlayer.play("IdleLeft")
		print("Works")
	if PlayerGlobal.LookAt == 3:
		$AnimationPlayer.play("IdleRight")
		print("Works")
	if PlayerGlobal.LookAt == 4:
		$AnimationPlayer.play("IdleDown")
		print("Works")
