extends CanvasLayer

var coins = 0

func _ready():
	$Coins.text = String(coins)


func _on_Coin_coin_collected():
	coins += 1
	_ready()
	if coins == 9:
		get_tree().change_scene("res://YouWin.tscn")
