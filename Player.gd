extends KinematicBody2D

var velocity = Vector2(0,0)
const SPEED = 380
const JUMPFORCE = -1000
const GRAVITY = 30

func _physics_process(delta):

	if Input.is_action_pressed("left_keys"):
		velocity.x = -SPEED
		$Sprite.flip_h = true
		$Sprite.play("walk")
	elif Input.is_action_pressed("right_keys"):
		velocity.x =  SPEED
		$Sprite.flip_h = false
		$Sprite.play("walk")
	else:
		$Sprite.play("idle")

	if not is_on_floor():
		$Sprite.play("air")
			
	velocity.y += GRAVITY
	
	if Input.is_action_just_pressed("jump_keys") and is_on_floor():
		velocity.y = JUMPFORCE
		

	#returning velocity frame by frame, we stop acceleration after a vertical collision
	#the second parameter fix the jump, setting where is the ceiling
	velocity = move_and_slide(velocity, Vector2.UP)
	
	velocity.x = lerp(velocity.x, 0, 0.2)
