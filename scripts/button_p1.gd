extends TextureButton

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	

func _on_p1Button_pressed():
	pressed()
	
	pass # replace with function body
	
func pressed():
	print ("P1 Selected")
	TRANSITION.fade_to(get_node("/root/GLOBAL_SYS").GAME_SCENE_NAME)