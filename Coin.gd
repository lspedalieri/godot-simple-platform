extends Area2D

signal coin_collected

func _on_Coin_body_entered(body):
	monitoring = false
	$AnimationPlayer.play("bounce")
	emit_signal("coin_collected")
	print("collect")
	set_collision_mask_bit(0, false)
	print("mask off")
	$SoundCoinCollect.play()
	
	


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()


