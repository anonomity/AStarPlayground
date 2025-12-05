extends Node2D

@onready var floor_layer: TileMapLayer = $floorLayer

@onready var euclidean_button: Button = $CanvasLayer/Panel/HBoxContainer/EUCLIDEANButton
@onready var manhattan_button: Button = $CanvasLayer/Panel/HBoxContainer/MANHATTANButton
@onready var octile_button: Button = $CanvasLayer/Panel/HBoxContainer/OCTILEButton
@onready var chebyshev_button: Button = $CanvasLayer/Panel/HBoxContainer/CHEBYSHEVButton
@onready var max_button: Button = $CanvasLayer/Panel/HBoxContainer/MAXButton


var floor_atlas = Vector2i(0,1)
var grid_atlas = Vector2i(0,0)
var krok_atlas = Vector2i(1,1)
var uwutargete_atlas = Vector2i(1,0)
var agent_atlas = Vector2i(2,0)
var obstacle_atlas = Vector2i(2,1)

@onready var debug_layer: TileMapLayer = $debugLayer
@onready var grid_layer: TileMapLayer = $gridLayer
@onready var obstacle_layer: TileMapLayer = $obstacleLayer

var agent : Vector2i = Vector2i(0,0)
var target : Vector2i = Vector2i(0,0)
var old_target = agent

var ashartgrid: AStarGrid2D 

var obstacle_arr = []

func _ready() -> void:
	
	euclidean_button.pressed.connect(change_heuristic.bind(0))
	manhattan_button.pressed.connect(change_heuristic.bind(1))
	octile_button.pressed.connect(change_heuristic.bind(2))
	chebyshev_button.pressed.connect(change_heuristic.bind(3))
	max_button.pressed.connect(change_heuristic.bind(4))
	
	ashartgrid  = AStarGrid2D.new()
	ashartgrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	var grid_width = 32
	var grid_height = 32
	var starting_point : Vector2i = Vector2i(0,0)
	
	for x in range(grid_width):
		for y in range(grid_height):
			floor_layer.set_cell(Vector2i(x,y),0, floor_atlas)
			grid_layer.set_cell(Vector2i(x,y),0, grid_atlas)
	
	set_agent()
	ashartgrid.region = Rect2i(starting_point.x, starting_point.y, grid_width,grid_height)
	
	ashartgrid.cell_size = Vector2i(16,16)
	ashartgrid.update()
	
	print(ashartgrid.get_id_path(Vector2i(0, 0), Vector2i(3, 4)))
	
	print(ashartgrid.get_point_path(Vector2i(0, 0), Vector2i(3, 4)))
	
func change_heuristic(index : int):
	ashartgrid.default_compute_heuristic = index

func _process(_delta: float) -> void:
	agent = debug_layer.local_to_map(get_global_mouse_position())
	
	if agent != old_target:
		debug_layer.clear()
		set_agent()
		set_debug()
		old_target = agent

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		place_target()
	if event.is_action_pressed("rightclick"):
		place_obstacle()
		
func set_debug():
	var arr_of_points = ashartgrid.get_id_path(agent, target)
	debug_layer.clear()
	for cell in arr_of_points:
		debug_layer.set_cell(cell, 0, krok_atlas)
	
func place_obstacle():
	var obstacle_cell = obstacle_layer.local_to_map(get_global_mouse_position())
	obstacle_layer.set_cell(obstacle_cell,0, obstacle_atlas)
	obstacle_arr.append(obstacle_cell)
	ashartgrid.set_point_solid(obstacle_cell)
	obstacle_arr.append(obstacle_cell)

func place_target():
	obstacle_layer.erase_cell(target)
	target = obstacle_layer.local_to_map(get_global_mouse_position())
	obstacle_layer.set_cell(target, 0, uwutargete_atlas)
		
func set_agent():
	debug_layer.set_cell(agent,0, agent_atlas)
	
