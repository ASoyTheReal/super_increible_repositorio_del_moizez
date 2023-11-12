extends CanvasLayer

signal phraseEnded

onready var regularTextDisp = $boxTexture/regularText
onready var portraitTextDisp = $boxTexture/portraitText/textDips

onready var textTimer = $textTimer

const default_speed = 0.04

func text_start():
	pass

func display_text(text : String, speed : float = default_speed, can_skip : bool = true) -> void:
	textDisp.visible_characters = 0
	textDisp.text = text
	var char_total = textDisp.get_total_character_count()
	textTimer.wait_time = speed
	
	while true:
		if !(textDisp.visible_characters < char_total):
			break
		if Input.is_action_pressed("cancel"):
			textDisp.visible_characters = char_total
			continue
		textDisp.visible_characters += 1
		
		textTimer.start(speed)
		await(textTimer.timeout)
	
	call_deferred("emit_signal", "phraseEnded")
