extends KinematicBody2D

enum States {AIR = 1, FLOOR = 2, LADDER = 3, WALL = 4}
var state = States.AIR
var velocity = Vector2(0,0)
var coins = 0
var direction = 1
var last_jump_direction = 0
var on_ladder := false

const SPEED = 350
const RUNSPEED = 600
const JUMPFORCE = -1000
const GRAVITY = 30
const BOUNCEFACTOR = 0.7
const FIREBALL = preload("res://Fireball.tscn")
const FIREBALL_OFFSET = 30
const SLOW_FALL_SPEED = 200
const WALL_JUMP_SPEED_H = 450

func _physics_process(delta):
	#print(on_ladder)
	match state:
		States.AIR:
			if is_on_floor() and velocity.y == 0:
				last_jump_direction = 0
				state = States.FLOOR
				continue
			elif is_near_wall():
				state = States.WALL
				continue
			elif should_climb_ladder():
				state = States.LADDER
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
			set_direction()
			move_and_fall(false)
			fire()
			
		States.FLOOR:
			if not is_on_floor():
				state = States.AIR
				continue
			elif should_climb_ladder():
				state = States.LADDER
				continue
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
			set_direction()
			move_and_fall(false)
			fire()
		States.WALL:
			if is_on_floor():
				last_jump_direction = 0
				state = States.FLOOR
				continue
			elif not is_near_wall():
				state = States.AIR
				continue
			$Sprite.play("wall")
			if Input.is_action_just_pressed("jump_keys") and ((Input.is_action_pressed("left_keys") and direction == 1) or (Input.is_action_pressed("right_keys") and direction == -1)) and direction != last_jump_direction:
				last_jump_direction = direction
				velocity.x = WALL_JUMP_SPEED_H * -direction
				velocity.y = JUMPFORCE * 0.7
				$SoundJump.play()
				state = States.AIR
			move_and_fall(true)
		States.LADDER:
			if not on_ladder:
				state = States.AIR
				continue
			elif is_on_floor() and Input.is_action_pressed("down_keys") and velocity.y == 0:
				state = States.FLOOR
				Input.action_release("down_keys")
				Input.action_release("up_keys")
				continue
			elif Input.is_action_just_pressed("jump_keys"):
				Input.action_release("down_keys")
				Input.action_release("up_keys")
				velocity.y = JUMPFORCE * 0.7
				state = States.AIR
				continue
			if Input.is_action_pressed("down_keys") or Input.is_action_pressed("up_keys") or Input.is_action_pressed("left_keys") or Input.is_action_pressed("right_keys"):
				$Sprite.play("climb")
			else:
				$Sprite.stop()
			if Input.is_action_pressed("up_keys"):
				velocity.y = -SPEED
			elif Input.is_action_pressed("down_keys"):
				velocity.y = SPEED				
			else:
				velocity.y = lerp(velocity.y, 0, 0.3)

			if Input.is_action_pressed("left_keys"):
				velocity.x = -SPEED/6
			elif Input.is_action_pressed("right_keys"):
				velocity.x = SPEED/6
			else:
				velocity.x = lerp(velocity.x, 0, 0.3)				
			
			velocity = move_and_slide(velocity, Vector2.UP)


func should_climb_ladder() -> bool:
	if on_ladder and (Input.is_action_pressed("down_keys") or Input.is_action_pressed("up_keys")):
		return true
	else:
		return false

func set_direction():
	direction = 1 if not $Sprite.flip_h else -1
	$Wallchecker.rotation_degrees = -90 * direction

func is_near_wall():
	return $Wallchecker.is_colliding() and not $Wallchecker.get_collider().is_in_group("one_way")

func fire():
	if Input.is_action_just_pressed("fire") and not is_near_wall():
		var direction = 1 if not $Sprite.flip_h else -1
		var f = FIREBALL.instance()
		f.direction = direction
		get_parent().add_child(f)
		f.position.y = position.y
		f.position.x = position.x + direction * FIREBALL_OFFSET

func move_and_fall(slow_fall:bool):
	velocity.y += GRAVITY
	if slow_fall:
		velocity.y = clamp(velocity.y, JUMPFORCE, SLOW_FALL_SPEED)
	#returning velocity frame by frame, we stop acceleration after a vertical collision
	#the second parameter fix the jump, setting where is the ceiling
	velocity = move_and_slide(velocity, Vector2.UP)


func _on_Fallzone_body_entered(body):
	Global.lose_life()
	if Global.lives >= 1:
		get_tree().reload_current_scene()

func add_coin():
	coins += 1
	
func bounce():
	velocity.y = JUMPFORCE * BOUNCEFACTOR
	
func ouch(var enemyposx):
	Global.lose_life()
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
	set_modulate(Color(1,1,1,1))
	#die()

func die():
	get_tree().change_scene("res://gameover.tscn")
	
func win():
	get_tree().change_scene("res://YouWin.tscn")


func _on_Ladderchecker_body_entered(body):
	on_ladder = true


func _on_Ladderchecker_body_exited(body):
	on_ladder = false
