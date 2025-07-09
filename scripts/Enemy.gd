# Enemy.gd
class_name Enemy
extends CharacterBody2D

@onready var floor_layer = get_parent().get_node("FloorLayer")
const WALL_ATLAS_COORDS = [Vector2i(1, 0)]
var target_position := Vector2.ZERO

# マップの大きさ
const MAP_SIZE = Vector2i(20, 20)

func _ready() -> void:
	target_position = floor_layer.map_to_local(Vector2i(2, 5))
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
			
func move_astar(player_pos: Vector2):
	var astar = AStarGrid2D.new()
	astar.region = Rect2i(Vector2i(0, 0), MAP_SIZE)
	astar.cell_size = Vector2(1,1)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()  # ← regionやcell_sizeなど設定した後に必ずこれを呼ぶ！

	
	for x in MAP_SIZE.x:
		for y in MAP_SIZE.y:
			var atlas_coords = floor_layer.get_cell_atlas_coords(Vector2i(x, y))
			if atlas_coords in WALL_ATLAS_COORDS:
				astar.set_point_solid(Vector2i(x, y), true)
				
	var start = floor_layer.local_to_map(position)
	var goal = floor_layer.local_to_map(player_pos)
	
	#4 パス取得
	var path = astar.get_id_path(start, goal)
	# パスが1マス以上(１マス先が存在)なら1歩進む
	if path.size() > 1:
		var next_step = path[1]
		position = floor_layer.map_to_local(next_step)
		print("Enemy moved (A*): ", next_step)
	else:
		print("Enemy cannot move (A* path not found or already adjacent)")
