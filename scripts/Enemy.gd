# Enemy.gd
class_name Enemy
extends CharacterBody2D

@onready var floor_layer = get_parent().get_node("FloorLayer")
const WALL_ATLAS_COORDS = [Vector2i(1, 0)]
var target_position := Vector2.ZERO

func _ready() -> void:
	target_position = floor_layer.map_to_local(Vector2i(3, 2))
	position = target_position

func move_random():
	print("Enemy turn!")
	var directions = [Vector2i.UP, Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN]
	directions.shuffle()
	
	for dir in directions:
		var map_pos = floor_layer.local_to_map(position) + dir
		var atlas_coords = floor_layer.get_cell_atlas_coords(map_pos)
		
		# 壁やプレイヤーがいないマスのみ移動
		if atlas_coords != Vector2i(-1, -1) and atlas_coords not in WALL_ATLAS_COORDS:
			position = floor_layer.map_to_local(map_pos)
			break
