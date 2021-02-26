extends KinematicBody2D

const ACCLERATION = 512
const MAX_SPEED = 100
const FRICTION = 0.25
const AIR_RESISTANCE = 0.02
const GRAVITY = 400
const JUMP_FORCE = 175

var state = MOVE
var motion = Vector2.ZERO
var in_air = false 

onready var swordhit = $SwordHit	
onready var sprite = $Sprite													#acessing the sprite node
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

enum {MOVE,ROLL,ATTACK}
enum {jump,fall}
enum {idle,run}
enum {ground,air}


func _ready():
	animationTree.active = true
	
	
func _physics_process(delta):													#if our state is == to move run move_state
	move_state(delta)
		

								
func move_state(delta):															#handles movement of the player
	#get action strength is 1 if pressing the right key and -1 if pressing the \
	#left key. So x_input is 1(right) or -1(left)
	
	var x_input = (Input.get_action_strength("ui_right") 
	- Input.get_action_strength("ui_left"))
	
	var current = animationState.get_current_node()
	
	
	#Running
	if x_input != 0:															#Checks the make sure left or right are being pressed 
		motion.x += x_input * ACCLERATION * delta								#assigns the speed to motion.x
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)						#clamp prevents out motion variable from going faster then -MAX_SPEED OR MAX_SPEED 
		if x_input < 0:
			sprite.scale.x = -1												    #flips character sprite to the left if true
		else:
			sprite.scale.x = 1
					
		if sprite.scale.x == -1:							
			sprite.offset = Vector2(10,0)	
		else:
			sprite.offset = Vector2(0,0)
										
		
	motion.y += GRAVITY * delta													#applies gravity to our player every frame
	
	#Jumping
	var motion_x = motion.x
	if is_on_floor():															#checks if the players is on the ground before jumping
		if x_input == 0:
			motion.x = lerp(motion.x, 0, FRICTION)								#lerp takes motion.x and makes it try to reach 0 by our FRICTION amount
		if Input.is_action_just_pressed("ui_up"):
			motion.y = -JUMP_FORCE
		#animationTree.set("parameters/Movement/current", int(motion_x.length()>50))
	else:
		if Input.is_action_just_released("ui_up") and motion.y < -JUMP_FORCE/2:	#Checks to make sure our player is moving upwards
			motion.y = -JUMP_FORCE/2											#short hops the player
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE)
			
			
	motion = move_and_slide(motion, Vector2.UP)									#move_and_slide returns left over motion
																				#by setting motion to move_and_slide we can avoid stacking fall speed

	run_anim(x_input)
	crouch()
	attack()
	jump_anim()
	air_attack()
	


	
													
func attack_state():
	state = MOVE
	
func jump_anim():
	if motion.y < 0:
		animationState.travel("Jump")
		in_air = true
	elif motion.y > 0:
		animationState.travel("Fall")
		in_air = true
	else:
		in_air = false
		
func run_anim(x_input):
	if x_input == 0:											
		animationState.travel("Idle")
	else:
		animationState.travel("Run")

		
func air_attack():
	if is_on_floor() == false:
		if Input.is_action_just_pressed("attack"):
			animationState.travel("DashAttack")
		
func attack():
	if is_on_floor() == true:
		if Input.is_action_just_pressed("attack"):
			animationState.travel("Attack")
			return
				


func crouch():
	if is_on_floor() == true:
		if Input.is_action_just_pressed("ui_down"):
			animationState.travel("Crouch")
			print("crouch")

		

func _on_SwordHit_area_entered(area):
		if area.is_in_group("hurtbox"):
			area.take_damage()


func _on_DashAttack_area_entered(area):
	pass # Replace with function body.
