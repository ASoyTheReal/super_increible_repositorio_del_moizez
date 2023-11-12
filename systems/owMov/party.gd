extends Node2D

var walked_distance : int = 0
var walking_speed : int = 150
var walked_start : bool = false
const char_separation : int = 25
onready var pchar_disps : Array = $pchars.get_children()
onready var pchar_amount : int = pchar_disps.size()
onready var main_pchar : KinematicBody2D = pchar_disps[0]

var last_mov = Vector2(0, 0)
var steps : int = 0

var path : Array = [] #The points of the path
var path_dirs : Array = [] #Which direction is the next point
var path_anims : Array = [] #Which animation to play when traveling from this point
var path_steps : Array = [] #How many steps away is one point from the next
var path_progress : Array = [] #In what point is every pchar rn
var pchar_steps : Array = [] #How many steps did every pchar take

func _ready():
	path_progress.resize(pchar_amount)
	pchar_steps.resize(pchar_amount)
	for n in pchar_amount:
		path_progress[n] = 0
		pchar_steps[n] = 0

func _physics_process(_delta):
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
		var moved_dir : Vector2 = main_pchar.move_and_slide(mov * walking_speed)
		
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
		
		var pchar_disp : KinematicBody2D = pchar_disps[pchar_indx + 1]
		var pchar_progress = path_progress[pchar_indx]
		
		var no_points : bool = path_steps.size() == 0 or path_steps.size() - 1 < pchar_progress
		
		if no_points:
			pchar_steps[pchar_indx] += 1
			pchar_disp.move_and_slide(last_mov)
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
			pchar_disp.move_and_slide(next_path_dir)
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
