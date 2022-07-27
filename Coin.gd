extends Area2D



func _on_Coin_body_entered(body):
	queue_free()
