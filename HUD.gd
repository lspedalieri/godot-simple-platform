extends CanvasLayer

var coins = 0

func _ready():
	$Coins.text = String(coins)


func _physics_process(delta):
	if(coins == 9):
		get_tree().change_scene("res://Level1.tscn")

func _on_Coin_coin_collected():
	coins += 1
	_ready()
