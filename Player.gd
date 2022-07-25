extends KinematicBody2D

var velocity = Vector2(0,0)
const SPEED = 180
const JUMPFORCE = -900
const GRAVITY = 30

func _physics_process(delta):
	if Input.is_action_pressed("left_keys"):
		velocity.x = -SPEED
	if Input.is_action_pressed("right_keys"):
		velocity.x =  SPEED
		
	velocity.y += GRAVITY
	
	if Input.is_action_just_pressed("jump_keys") and is_on_floor():
		velocity.y = JUMPFORCE
	#returning velocity frame by frame, we stop acceleration after a vertical collision
	#the second parameter fix the jump, setting where is the ceiling
	velocity = move_and_slide(velocity, Vector2.UP)
	
	velocity.x = lerp(velocity.x, 0, 0.2)
