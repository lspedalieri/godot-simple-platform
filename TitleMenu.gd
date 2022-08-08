extends Control


func _on_Button_pressed():
	Global.lives = Global.max_lives
	get_tree().change_scene("res://Level1.tscn")
