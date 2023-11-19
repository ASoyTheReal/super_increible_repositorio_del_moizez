extends Node2D

var can_move : bool = true

var walked_distance : int = 0
var sprinting_speed : int = 200
var running_speed : int = 150
var walking_speed : int = 100
var walked_start : bool = false
const char_separation : int = 30
var pchar_disps : Array
var pchar_amount : int
var main_pchar : CharacterBody2D

var last_mov = Vector2(0, 0)
var run : int = 0
var sprint : int = 0
var run_cap : int = 20
var sprint_cap : int = 100
var steps : int = 0

var path : Array = [] #The points of the path
var path_dirs : Array = [] #Which direction is the next point
var path_anims : Array = [] #Which animation to play when traveling from this point
var path_steps : Array = [] #How many steps away is one point from the next
var path_progress : Array = [] #In what point is every pchar rn
var pchar_steps : Array = [] #How many steps did every pchar take

var pchar_dispPacked : PackedScene = preload("res://systems/owMov/pcharDisp.tscn")

signal anim_ended(char_indx)

func _ready():
	setup()
	
	main_pchar.get_node("camera").enabled = true
	path_progress.resize(pchar_amount)
	pchar_steps.resize(pchar_amount)
	for n in pchar_amount:
		path_progress[n] = 0
		pchar_steps[n] = 0

func setup() -> void:
	for pchar_id in GameplayManager.party_ids:
		if GlobalResourceContainer.pchars.has(pchar_id):
			var disp : CharacterBody2D = pchar_dispPacked.instantiate()
			var dispAnimator : AnimatedSprite2D = disp.get_node("animations")
			dispAnimator.sprite_frames = GlobalResourceContainer.pchars[pchar_id].animations
			dispAnimator.offset = GlobalResourceContainer.pchars[pchar_id].sprite_offset
			var collision : CollisionShape2D = disp.get_node("collision")
			collision.shape = GlobalResourceContainer.pchars[pchar_id].collision_shape
			collision.position = GlobalResourceContainer.pchars[pchar_id].sprite_offset
			
			disp.set_collision_mask_value(2, false)
			
			$pchars.add_child(disp)
			$pchars.move_child(disp, $pchars.get_child_count() - 1)
			dispAnimator.play("down")
	
	pchar_disps = $pchars.get_children()
	main_pchar = pchar_disps[0]
	pchar_amount = pchar_disps.size()
	
	main_pchar.set_collision_mask_value(2, true)

func _physics_process(_delta):
	if !can_move: return
	process_movement()

func team_move(point : Vector2):
	for _c in pchar_disps:
		var c : CharacterBody2D = _c
		c
	var pixels_per_step : float = float(walking_speed) / float(Engine.physics_ticks_per_second)
	var steps : int = ceili(main_pchar.global_position.distance_to(point) / pixels_per_step)
	var dir : Vector2 = (main_pchar.global_position.direction_to(point)).round()
	
	for _i in steps:
		await get_tree().physics_frame
		move_step(dir)
	
	print(main_pchar.global_position)
	anim_ended.emit(-1)

func pchar_move(point : Vector2):
	pass

func process_movement():
	var mov : Vector2
	var moving : bool = false
	if Input.is_action_pressed("ui_right"):
		mov.x += 1
		moving = true
	if Input.is_action_pressed("ui_left"):
		mov.x -= 1
		moving = true
	if mov.x == 0: moving = false 
	
	if Input.is_action_pressed("ui_down"):
		mov.y += 1
		moving = true
	elif Input.is_action_pressed("ui_up"):
		mov.y -= 1
		moving = true
	if moving:
		move_step(mov)
	else:
		sprint = 0
		run = 0

func move_step(mov : Vector2):
	run = mini(run + 1, run_cap)
	var running : bool = Input.is_action_pressed("run")
	var cur_speed = walking_speed
	if running:
		if run == run_cap:
			sprint = mini(sprint + 1, sprint_cap)
			if sprint == sprint_cap:
				cur_speed = sprinting_speed
			else:
				cur_speed = running_speed
	else:
		sprint = 0
	
	main_pchar.set_velocity(mov * cur_speed)
	main_pchar.move_and_slide()
	var moved_dir : Vector2 = main_pchar.velocity.round()
	
	print(moved_dir)
	if moved_dir == Vector2.ZERO:
		sprint = 0
		run = 0
		return
	
	if last_mov != Vector2.ZERO: #Add points to the path
		if last_mov != moved_dir:
			path.push_back(main_pchar.global_position)
			path_dirs.push_back(moved_dir)
			path_steps.push_back(steps)
			path_anims.push_back(get_anim(moved_dir))
			steps = 0
			
#				var debugMarker : Sprite = Sprite.new()
#				debugMarker.texture = load("res://icon.png")
#				debugMarker.scale = Vector2(0.25, 0.25)
#				add_child(debugMarker)
#				debugMarker.global_position = path[-1]
	last_mov = moved_dir
	walked_distance += 1
	steps += 1
	
	if path_dirs == []:
		path_dirs.resize(1)
		path_anims.resize(1)
		
		path_dirs[-1] = moved_dir
		path_anims[-1] = get_anim(moved_dir)
	
	pchar_follow()
#	$debugText0.text = str(path) + "\n" +str(path_steps) + "\n" + str(pchar_steps) + "\n" + str(path_progress) + "\n" + str(path_progress) + "\n"

func pchar_follow(): #Move the pchars that follow the main one
	for pchar_indx in (pchar_amount - 1): #this is the segment where you actually move the pchars
		if !walked_start:
			if walked_distance / char_separation < pchar_indx + 1: #Enough was not walked
				break
		var is_last = pchar_indx == pchar_amount - 2
		
		if is_last:
			walked_start = true
		
		var pchar_disp : CharacterBody2D = pchar_disps[pchar_indx + 1]
		var pchar_progress = path_progress[pchar_indx]
		
		var no_points : bool = path_steps.size() == 0 or path_steps.size() - 1 < pchar_progress
		
		if no_points:
			pchar_steps[pchar_indx] += 1
			pchar_disp.set_velocity(last_mov)
			pchar_disp.move_and_slide()
			pchar_disp.velocity
			continue
		
		var next_path_point : Vector2 = path[pchar_progress]
		var next_path_dir : Vector2 = path_dirs[pchar_progress]
		
		
		var reached_path_point : bool = path_steps[pchar_progress] == pchar_steps[pchar_indx]
		
		if reached_path_point:
			pchar_steps[pchar_indx] = 0
			if is_last:
				path.pop_front()
				path_steps.pop_front()
				var pre_dir = path_dirs.pop_front()
				var pre_anim = path_anims.pop_front()
				
				for n in (pchar_amount - 1):
					var new_progress : int = max((path_progress[n] - 1), 0)
					path_progress[n] = new_progress
			else:
				path_progress[pchar_indx] += 1
				pchar_progress = path_progress[pchar_indx]
			
			pchar_disp.global_position = next_path_point
		
		else:
			pchar_disp.set_velocity(next_path_dir)
			pchar_disp.move_and_slide()
			pchar_disp.velocity
		pchar_steps[pchar_indx] += 1

func make_absolute(num : int) -> int:
	return num if num > 0 else num * -1

func get_anim(direction : Vector2) -> String: #Gives where a pchar should be looking
	var abs_x : int = make_absolute(direction.x)
	var abs_y : int = make_absolute(direction.y)
	
	if abs_x > abs_y:
		if direction.x > 0:
			return "right"
		else:
			return "left"
	else:
		if direction.y > 0:
			return "up"
		else:
			return "down"
