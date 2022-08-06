extends KinematicBody2D

var velocity = Vector2()
var direction = 1

const GRAVITY = 22
const BOUNCE = -300
const SPEED = 800
const ROTATION_ANGLE = 25

func _ready():
	velocity.x = SPEED * direction

func _physics_process(delta):
	$Sprite.rotation_degrees += ROTATION_ANGLE * direction
	velocity.y += GRAVITY
	if is_on_wall():
		queue_free()
	if is_on_floor():
		velocity.y = BOUNCE
	velocity = move_and_slide(velocity, Vector2.UP)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Timer_timeout():
	$AudioStreamPlayer2D.play()
