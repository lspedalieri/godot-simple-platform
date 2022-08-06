extends KinematicBody2D

enum States {AIR = 1, FLOOR = 2, LADDER = 3, WALL = 4}
var state = States.AIR
var velocity = Vector2(0,0)
var coins = 0

const SPEED = 350
const RUNSPEED = 600
const JUMPFORCE = -1000
const GRAVITY = 30
const BOUNCEFACTOR = 0.7
const FIREBALL = preload("res://Fireball.tscn")
const FIREBALL_OFFSET = 25

func _physics_process(delta):
	print(velocity.x)
	match state:
		
		States.AIR:
			if is_on_floor():
				state = States.FLOOR
				continue
			$Sprite.play("air")
			if Input.is_action_pressed("right_keys"):
				velocity.x =  lerp(velocity.x, SPEED, 0.1) if velocity.x < SPEED else lerp(velocity.x, SPEED, 0.03)
				$Sprite.flip_h = false
			elif Input.is_action_pressed("left_keys"):
				velocity.x = lerp(velocity.x, -SPEED, 0.1) if velocity.x > -SPEED else lerp(velocity.x, -SPEED, 0.03)
				$Sprite.flip_h = true
			else:
				velocity.x = lerp(velocity.x, 0, 0.2)
			move_and_fall()
			fire()
			
		States.FLOOR:
			if not is_on_floor():
				state = States.AIR
			if Input.is_action_pressed("right_keys"):
				if Input.is_action_pressed("run_keys"):
					velocity.x = lerp(velocity.x, RUNSPEED, 0.1)
					$Sprite.set_speed_scale(1.8)
				else:
					velocity.x = lerp(velocity.x, SPEED, 0.1)
					$Sprite.set_speed_scale(1.0)
				$Sprite.flip_h = false
				$Sprite.play("walk")
			elif Input.is_action_pressed("left_keys"):
				if Input.is_action_pressed("run_keys"):
					velocity.x = lerp(velocity.x, -RUNSPEED, 0.1)
					$Sprite.set_speed_scale(1.8)
				else:
					velocity.x = lerp(velocity.x, -SPEED, 0.1)
					$Sprite.set_speed_scale(1.0)
				$Sprite.flip_h = true
				$Sprite.play("walk")
			else:
				$Sprite.play("idle")
				velocity.x = lerp(velocity.x, 0, 0.2)
				
			if Input.is_action_just_pressed("jump_keys"):
				velocity.y = JUMPFORCE
				$SoundJump.play()
				state = States.AIR
			move_and_fall()
			fire()
			
	if coins == 9:
		win()

func fire():
	if Input.is_action_just_pressed("fire"):
		var direction = 1 if not $Sprite.flip_h else -1
		var f = FIREBALL.instance()
		f.direction = direction
		get_parent().add_child(f)
		f.position.y = position.y
		f.position.x = position.x + direction * FIREBALL_OFFSET

func move_and_fall():
	velocity.y += GRAVITY
	#returning velocity frame by frame, we stop acceleration after a vertical collision
	#the second parameter fix the jump, setting where is the ceiling
	velocity = move_and_slide(velocity, Vector2.UP)


func _on_Fallzone_body_entered(body):
	die()

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
	die()

func die():
	get_tree().change_scene("res://gameover.tscn")
	
func win():
	get_tree().change_scene("res://YouWin.tscn")
