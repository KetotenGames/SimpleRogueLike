# Main.gd
extends Node

@onready var player = $Player
@onready var enemy = $Enemy

var turn = "player"

func _ready() -> void:
	turn = "player"
	print("playerノード:", player)
	var result = player.connect("moved", Callable(self, "_on_player_moved"))
	print("connect result:", result)

	
func _on_player_moved() -> void:
	print("player moved! enemy turn start")
	turn = "enemy"
	await get_tree().create_timer(0.3).timeout
	enemy.move_random()
	turn = "player"
	

	
