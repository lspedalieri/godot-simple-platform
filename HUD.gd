extends CanvasLayer

var coins = 0
const HEARTS_HSIZE = 53

func _ready():
	Global.hud = self
	$Coins.text = String(coins)
	load_hearts()


func _on_Coin_coin_collected():
	coins += 1
	_ready()
	if coins == 9:
		get_tree().change_scene("res://YouWin.tscn")


func load_hearts():
	$HeartsFull.rect_size.x = Global.lives * HEARTS_HSIZE
	$HeartsEmpty.rect_size.x = (Global.max_lives - Global.lives) * HEARTS_HSIZE
	$HeartsEmpty.rect_position.x = $HeartsFull.rect_position.x + $HeartsFull.rect_size.x * $HeartsFull.rect_scale.x
