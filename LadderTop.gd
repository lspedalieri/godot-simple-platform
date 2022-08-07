extends StaticBody2D

var above_ladder := false

func _physics_process(delta):
	if Input.is_action_pressed("down_keys") and above_ladder:
		$CollisionShape2D.rotation_degrees = 180
		print("flip")
	else:
		print("close")
		$CollisionShape2D.rotation_degrees = 0


func _on_AboveChecker_body_entered(body):
	#print("above ladder true")
	above_ladder = true


func _on_AboveChecker_body_exited(body):
	#print("above ladder false")
	above_ladder = false
