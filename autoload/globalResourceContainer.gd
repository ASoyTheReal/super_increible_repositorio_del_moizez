extends Node

#----------PCHAR

var system_pchar_path : String = "res://systems/owMov/pchar/"
var mod_pchar_path : String = "res://mod/gdRes/pchar/"

var pchars : Dictionary = load_pchars()

func load_pchars() -> Dictionary:
	var pc : Dictionary
	
	for path in [system_pchar_path, mod_pchar_path]:
		var system_dir : DirAccess = DirAccess.open(path)
		if system_dir.get_open_error() == OK:
			var filenames : PackedStringArray = system_dir.get_files_at(path)
			for filename in filenames:
				var res : Resource = load(path + filename)
				if !res is pchar_dat:
					print("error at: ", path + filename)
					continue
				
				var pcharDat : pchar_dat = res
				pc[pcharDat.id] = pcharDat
	
	return pc 
#----------
