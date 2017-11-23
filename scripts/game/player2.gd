extends KinematicBody2D
var AIStateClass = load("res://scripts/game/ai_state_handler.gd")
var PlayerStateClass = load("res://scripts/game/player_state_handler.gd")
var Player2StateClass = load("res://scripts/game/player2_state_handler.gd")
var state 

var life=100
var currentDamageRecoverFrame=0
var damageTimer=0

var height=0
var currentJumpPower =0

var minJumpHeight = 50
var jumpLockToEnd=false
var jumpPower = -400 
var maxJumpPower = -1000
var gravity = 3500
var walkSpeed = 200
var runSpeed = 300
var groundCollider
var animation

var pushbackVector = Vector2(0,0)

func _ready():
	groundCollider = get_node("groundCollider")
	animation = get_node("AnimationPlayer")
	
	if(GLOBAL_SYS.p2ModeEnable):
		if(GLOBAL_SYS.p1_char == GLOBAL_SYS.P2CHAR):
			state = PlayerStateClass.new(self)
		else:
			state = Player2StateClass.new(self)
	else:
		if(GLOBAL_SYS.p1_char == GLOBAL_SYS.P2CHAR):
			state = PlayerStateClass.new(self)
		else:
			state = AIStateClass.new(self)
		
	#state.set_idle()
	
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true);
	pass
	
func _process(delta):
	
	var parentTest = get_parent().get_parent()
	if(parentTest.get_name() == "World"):
		if(parentTest.endRound):
			return
		
	_clampInView()
	if(_handleHurt(delta)):
		return
	
	_handleWalk(delta)
	_handleJump(delta)
	_handleAttack(delta)
	
	_handleZIndex()
	
	pass

func _clampInView():
	# clamping to view
	# i.e. cannot walk out of view
	var view_size = get_viewport_rect().size
	var pos = get_pos()
	pos.x = clamp(pos.x,0+16, view_size.width-16)

func _KO():
	life=0
	state.charState.setKO()
	return

func _handleZIndex():
	set_z(get_pos().y+height)

func _handleHurt(delta):
	
	if(life<0):
		_KO()
		return
	
	if(state.checkHurt()):
		if(currentDamageRecoverFrame>0):
			damageTimer+= delta
			if(damageTimer >= currentDamageRecoverFrame*0.016):
				_reset_damage_recovery_counter()
		return true
	else:
		return false
		
	return false

func _reset_damage_recovery_counter():
	currentDamageRecoverFrame=0
	damageTimer=0
	state.idle()
			
func _handleWalk(delta):
	var direction = state.checkWalk()
	var invert_scale = Vector2(-1,1)
	var normal_scale = Vector2(1,1)
	if(direction.x < 0):
		set_scale(invert_scale)
	elif(direction.x>0):
		set_scale(normal_scale)
	move(direction * walkSpeed * delta)
	pass

func _handleJump(delta):
	#####new jump function#####
	
	#initially on ground
	if(height <=0):
		#initial jump check
		if(state.checkJump()):
			# set the initial jump speed
			currentJumpPower = jumpPower
	else:
		if(state.checkJump() && height < minJumpHeight && !jumpLockToEnd):
			currentJumpPower = jumpPower * 1.5
			if(currentJumpPower<maxJumpPower):
				currentJumpPower=maxJumpPower
	
	if(height > minJumpHeight):
		jumpLockToEnd=true
	
	#else:
		# character is in mid flight
		#if(state.checkJump()):
			# button is still held
			# maintain the power
		#	currentJumpPower = jumpPower
		#else:
			#jump power needs to decay
		#	currentJumpPower = currentJumpPower/1.5
			
	if(state.isAirborne()):
		var gravityPull = gravity*delta #gravity vector
		currentJumpPower += gravity*delta
		var jumpPowerDelta = currentJumpPower*delta #y vector of jump
		height += -(jumpPowerDelta)
		move(Vector2(0,jumpPowerDelta))
		var groundColliderPos = Vector2(groundCollider.get_pos().x,groundCollider.get_pos().y)
		groundColliderPos.y -= jumpPowerDelta
		groundCollider.set_pos(groundColliderPos)
		#jumping power needs to decay over time
		
		
	#Height can never be less than 0
	if(height<0):
		state.endJumping()
		move(Vector2(0,0+height))
		height=0
		currentJumpPower=0
		jumpLockToEnd=false

func _handleAttack(delta):
	state.checkAttack()
	pass
	
func setAttack():
	print("ATTACK STATE")
	state.attack()

func setRecover():
	print("RECOVER STATE")
	state.recover()

func setIdle():
	print("IDLE STATE")
	state.idle()

func setJumpAttack():
	print("JUMP ATTACK STATE")
	state.charState.jump_attack()

func setJumpRecover():
	print("JUMP RECOVER STATE")
	state.charState.jump_recover()

func setJump():
	print("JUMP STATE")
	state.charState.jump()

func damage(lifeDamage,frameDamage):
	life -= lifeDamage
	currentDamageRecoverFrame=frameDamage
	
	
func getLife():
	return life
	
func restart():
	life =100

func _on_hurtbox_area_enter( area ):
	print("something enter p2 hurtbox")
	state.hurt()
	pass # replace with function body

func _on_hitbox_area_enter( area ):
	print("something enter p2 hitbox")
	print(area.get_name())
	if(state.check_animation_playing("attack")):
		#then do the damage of that attack as well as the frame damage
		pass
	var test = area.get_parent()
	test.damage(5,5)
	
	pass # replace with function body
