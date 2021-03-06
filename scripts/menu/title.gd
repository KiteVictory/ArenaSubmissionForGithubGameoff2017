extends Control

var transitionLock=false
var callToActionNode=null
var callToActionText1="PRESS SPACE TO START"
var callToActionText2="PRESS BUTTON A TO START"
var currentText = callToActionText1

func _ready():
	set_process(true)
	set_process_input(true)
	callToActionNode = get_node("Panel/CallToAction");
	
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func _input(event):
	if(event.type == InputEvent.JOYSTICK_BUTTON || event.type == InputEvent.JOYSTICK_MOTION):
		currentText = callToActionText2
	if(event.type == InputEvent.KEY):
		currentText = callToActionText1
	
func _process(delta):
	if(transitionLock):
		return
	_effectCheck()
	
	if(Input.is_action_pressed("P1_START") || Input.is_action_pressed("P1_ATTACK")|| Input.is_action_pressed("P1_JUMP")):
		get_node("SamplePlayer").play("select")
		TRANSITION.fade_to(GLOBAL_SYS.CHAR_SELECT_SCENE_NAME);
		transitionLock=true;
		
	callToActionNode.set_text(currentText)
	
	GLOBAL_INPUT.quitGame();
	
	pass

func _effectCheck():
	GLOBAL_INPUT.changeEffect();
	
	if(GLOBAL_SYS.effect == 0):
		get_node("overlay").hide()
	else:
		get_node("overlay").show()