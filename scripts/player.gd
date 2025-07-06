# Player.gd
class_name Player
extends CharacterBody2D

@export var tile_size: int = 32
@onready var floor_layer = get_parent().get_node("FloorLayer")
@onready var se_player = $"../AudioStreamPlayer2D"

# タイルのAtlas座標をリストで管理（例：右側のタイルが壁なら[Vector2i(1, 0)]）
const WALL_ATLAS_COORDS = [Vector2i(1, 0)]
const GOAL_ATLAS_COORDS = [Vector2i(1, 1)]

var input_dir := Vector2.ZERO
var moving := false
var target_position := Vector2.ZERO

func _ready() -> void:
	target_position = floor_layer.map_to_local(Vector2i(1, 1))
	position = target_position

func _process(delta: float) -> void:
	if moving:
		position = position.move_toward(target_position, 200 * delta)
		if position.distance_to(target_position) < 1:
			position = target_position
			moving = false
		return

	input_dir = Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"):
		input_dir = Vector2.UP
	elif Input.is_action_just_pressed("ui_down"):
		input_dir = Vector2.DOWN
	elif Input.is_action_just_pressed("ui_left"):
		input_dir = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right"):
		input_dir = Vector2.RIGHT

	if input_dir != Vector2.ZERO:
		var map_pos = floor_layer.local_to_map(position) + Vector2i(input_dir)
		var atlas_coords = floor_layer.get_cell_atlas_coords(map_pos)
		print("map_pos: %s, atlas_coords: %s" % [map_pos, atlas_coords])
		# 空きマスは進める
		if atlas_coords == Vector2i(-1, -1):
			move_to(floor_layer.map_to_local(map_pos))
			return
		# 壁タイル（コリジョン）なら進めない
		if atlas_coords in WALL_ATLAS_COORDS:
			return
		# 通常タイルは進める
		move_to(floor_layer.map_to_local(map_pos))
		# ゴールイベント
		if atlas_coords in GOAL_ATLAS_COORDS:
			on_goal_reached()

func move_to(pos: Vector2):
	target_position = pos
	moving = true
	
func on_goal_reached():
	print("ゴールに到達！クリア！")
	se_player.play()
