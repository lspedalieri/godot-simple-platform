extends KinematicBody2D

var velocity = Vector2(0,0)
var coins = 0

const SPEED = 380
const JUMPFORCE = -1000
const GRAVITY = 30
const BOUNCEFACTOR = 0.7

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
	
	if coins == 9:
		get_tree().change_scene("res://Level1.tscn")


func _on_Fallzone_body_entered(body):
	get_tree().change_scene("res://Level1.tscn")

func add_coin():
	coins += 1
	
func bounce():
	velocity.y = JUMPFORCE * BOUNCEFACTOR
	
func ouch(var enemyposx):
	set_modulate(Color(1,.3,.3,.3))
	velocity.y = JUMPFORCE * BOUNCEFACTOR
	if position.x < enemyposx:
		velocity.x = -800
	elif position.x > enemyposx:
		velocity.x = 800
	Input.action_release("left_keys")
	Input.action_release("right_keys")
	$Timer.start()


func _on_Timer_timeout():
	get_tree().change_scene("res://Level1.tscn")
