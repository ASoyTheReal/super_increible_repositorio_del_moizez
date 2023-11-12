extends Node2D

var walked_distance : int = 0
var walking_speed : int = 150
var walked_start : bool = false
const char_separation : int = 50
onready var pchar_disps : Array = $pchars.get_children()
onready var pchar_amount : int = pchar_disps.size()

var last_mov = Vector2(0, 0)
var steps : int = 0

var path : Array = []
var path_dirs : Array = []
var path_anims : Array = []
var path_steps : Array = []
var path_progress : Array = []
var pchar_steps : Array = []

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
	if Input.is_action_pressed("ui_down"):
		mov.y += 1
		moving = true
	if Input.is_action_pressed("ui_up"):
		mov.y -= 1
		moving = true
	
	if moving:
		var main_pchar : KinematicBody2D = pchar_disps[0]
		var moved_dir : Vector2 = main_pchar.move_and_slide(mov * walking_speed)
		
		if last_mov != Vector2.ZERO: #Add points to the path
			if last_mov != moved_dir:
				path.push_back(main_pchar.global_position)
				path_dirs.push_back(moved_dir)
				path_steps.push_back(steps)
				path_anims.push_back(get_anim(moved_dir))
				steps = 0
				
				var debugMarker : Sprite = Sprite.new()
				debugMarker.texture = load("res://icon.png")
				debugMarker.scale = Vector2(0.25, 0.25)
				add_child(debugMarker)
				debugMarker.global_position = path[-1]
		last_mov = moved_dir
		walked_distance += 1
		steps += 1
		
		if path_dirs == []:
			path_dirs.resize(1)
			path_anims.resize(1)
			
			path_dirs[-1] = moved_dir
			path_anims[-1] = get_anim(moved_dir)
		
		for pchar_indx in (pchar_amount - 1): #this is the segment where you actually move the pchars
			if !walked_start:
				if walked_distance / char_separation < pchar_indx + 1: #Enough was not walked
					break
			
			if path == []:
				path.push_back(main_pchar.global_position)
			
			var is_last = pchar_indx == pchar_amount - 2
			
			if is_last:
				walked_start = true
			
			var pchar_disp : KinematicBody2D = pchar_disps[pchar_indx + 1]
			path_progress[pchar_indx] = min(path_progress[pchar_indx], path.size() - 1)
			
			var pchar_progress = path_progress[pchar_indx]
			var next_path_point : Vector2 = path[pchar_progress]
			var next_path_dir : Vector2 = path_dirs[pchar_progress]
			
			var s : int = -1
			if !(path_steps.size() < pchar_progress): s = path_steps[pchar_progress]
			
			if path_steps[pchar_progress] == pchar_steps[pchar_indx]:
#			if has_reached_path_point(pchar_disp.global_position, next_path_point):
				pchar_steps[pchar_indx] = 0
				if is_last:
					path.pop_front()
					var pre_dir = path_dirs.pop_front()
					var pre_anim = path_anims.pop_front()
					
					if path.size() == 0:
						path.push_back(main_pchar.global_position)
						path_dirs.push_back(pre_dir)
						path_anims.push_back(pre_anim)
					
					for n in (pchar_amount - 1):
						var new_progress : int = max((path_progress[n] - 1), 0)
						path_progress[n] = new_progress
				else:
					var new_progress = min((pchar_progress + 1), (path_dirs.size() - 1))
					pchar_progress = max(new_progress, 0)
				
				pchar_disp.global_position = next_path_point
				
				next_path_point = path_dirs[pchar_progress]
				next_path_dir = path_dirs[pchar_progress]
			
			else:
				pchar_steps[pchar_indx] += 1
				pchar_disp.move_and_slide(next_path_dir)
	
	$debugText0.text = str(path_progress) + "\n" + str(pchar_steps) + "\n" + str(path_dirs) + "\n" + str(path_progress) + "\n"


func has_reached_path_point(pchar_disp_pos : Vector2, path_point : Vector2) -> bool:
	if pchar_disp_pos.distance_to(path_point) < 20:
#	var abs_pchar_pos : Vector2
#	abs_pchar_pos.x = make_absolute(pchar_disp_pos.x)
#	abs_pchar_pos.y = make_absolute(pchar_disp_pos.y)
#
#	var abs_path_point : Vector2
#	path_point.x = make_absolute(path_point.x)
#	path_point.y = make_absolute(path_point.y)
#
#	var distance_vec : Vector2 = abs_path_point - abs_pchar_pos
#	$debugText1.text = str(distance_vec)
#	if (make_absolute(distance_vec.x) < 1) and (make_absolute(distance_vec.y) < 1):
#		print("true")
		return true
	return false

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
