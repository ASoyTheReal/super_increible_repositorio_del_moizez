extends CanvasLayer

signal phraseEnded
signal acceptPressed

@onready var regularTextDisp = $boxTexture/regularText
@onready var portaritGroup = $boxTexture/portraitText
@onready var portraitDisp = $boxTexture/portraitText/portraitDisp
@onready var portraitTextDisp = $boxTexture/portraitText/textDips
@onready var voide_sfxPlayer = $voice_sfx
var textDisp : RichTextLabel

@onready var textTimer = $textTimer

const default_speed = 0.04

func _ready():
	pass
#	_test_dialog()

func _test_dialog():
	await GameplayManager.acceptPressed
	var phrase : PhraseRes = PhraseRes.new()
	phrase.text = "* Hola soy susie deltanr\n	y estoy mirando hacia la\n	izquierda"
	phrase.portrait = load("res://systems/ui/dialogSystem/assets/testPort.png")
	text_start(phrase)
	await self.phraseEnded
	await GameplayManager.acceptPressed
	phrase.text = "* Haha menti\n* Ahora estoy mirando a la\n	izquierda"
	phrase.portrait = load("res://systems/ui/dialogSystem/assets/testPortL.png")
	text_start(phrase)
	await self.phraseEnded
	await GameplayManager.acceptPressed
	phrase.text = "* Hehe...\n* ...\n* Gente "
	phrase.portrait = load("res://systems/ui/dialogSystem/assets/testPort.png")
	text_start(phrase)
	await self.phraseEnded
	await GameplayManager.acceptPressed
	phrase.text = "* Empiezo a pensar que moizez no va\n	a volver"
	phrase.portrait = null
	phrase.speed = 0.05
	text_start(phrase)

func text_start(phrase : PhraseRes):
	var portrait : Texture2D = phrase.portrait
	
	regularTextDisp.visible = true
	portaritGroup.visible = false
	textDisp = regularTextDisp
	if portrait != null:
		regularTextDisp.visible = false
		portaritGroup.visible = true
		
		textDisp = portraitTextDisp
		portraitDisp.texture = portrait
	
	voide_sfxPlayer.stream = phrase.voice
	
	display_text(phrase.text, phrase.speed, phrase.can_skip)

func display_text(text : String, speed : float = default_speed, can_skip : bool = true) -> void:
	textDisp.text = text
	var char_total = len(textDisp.text)
	textDisp.visible_characters = 0
	textTimer.wait_time = speed
	
	while true:
		if !(textDisp.visible_characters < char_total):
			break
		voide_sfxPlayer.play(0.0)
		if Input.is_action_pressed("cancel"):
			textDisp.visible_characters = char_total
			continue
		textDisp.visible_characters += 1
		
		textTimer.start(speed)
		await textTimer.timeout
	
	voide_sfxPlayer.stop()
	call_deferred("emit_signal", "phraseEnded")
