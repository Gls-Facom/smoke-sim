extends Node2D

var grid_size 		= OS.get_window_size()
var squares_qtd 	= Vector2(32, 32)
var tile_size 		= Vector2(grid_size.x/squares_qtd.x, grid_size.y/squares_qtd.y)
var show_vectors 	= false
var show_grid 		= false
var timer = 0.0
var mouse_pos: Vector2

var rho = 1.0
var gravity = Vector2(0, -0.981) 
var sub_steps = 10 # random value, maybe be lowered for performance improvement
var MAX_VELOCITY = 100

var Particle = preload("res://scenes/particle.tscn")
var Vector = preload("res://scenes/vector.tscn")

var grid_vectors = []
var particles = []

class VectorClass:
	var pressure: float
	var velocity: Vector2
	var pos: Vector2

func get_velocity(_pos):
	return Vector2(_pos.x, _pos.y)/100

func get_pressure(_pos):
	return (_pos.x+_pos.y)/50

func copy_vector(obj):
	var vec = VectorClass.new()
	vec.pressure = obj.pressure
	vec.velocity = obj.velocity
	vec.pos = obj.pos
	return vec

func _ready():
	$native_lib.tile_size = tile_size
	$native_lib.grid_size = grid_size
	$native_lib.max_speed = MAX_VELOCITY
	
	for x in range(squares_qtd.y):
		grid_vectors.append([])
		for y in range(squares_qtd.x):
			# middle point
			var pos = Vector2((y+1) * tile_size.x + tile_size.x/2.0, (x+1) * tile_size.y + tile_size.y/2.0)
			var vector = Vector.instance()
			vector.pos = pos
			vector.velocity = get_velocity(pos)
			vector.pressure = get_pressure(pos) 
			grid_vectors[x].append(vector)
			$vector_visualizer.add_child(vector)
		
		# vertical
		var front = copy_vector(grid_vectors[x][0])
		var back = copy_vector(grid_vectors[x][-1])
		front.pos.x = tile_size.x/2.0
		front.velocity *= -1 
		back.pos.x += tile_size.x
		back.velocity *= -1
		grid_vectors[x].push_front(front)
		grid_vectors[x].push_back(back)
	
	# horizontal
	var front_list = []
	var back_list = []
	for y in range(squares_qtd.x+2):
		var vec = copy_vector(grid_vectors[0][y])
		vec.pos.y = tile_size.y/2.0
		if y > 0:
			vec.velocity *= -1
		front_list.append(vec)
	for y in range(squares_qtd.x+2):
		var vec = copy_vector(grid_vectors[-1][y])
		vec.pos.y += tile_size.y
		if y>0:
			vec.velocity *= -1
		back_list.append(vec)
	grid_vectors.push_front(front_list)
	grid_vectors.push_back(back_list)
	
	$native_lib.vector_size = Vector2(squares_qtd.y+2, squares_qtd.x+2)

func add_particle(pos):
	var new_particle = Particle.instance()
	new_particle.position = pos
	particles.append(new_particle)
	add_child(new_particle)

func external_forces():
	return gravity # + bouancy (+ mouse_reppelant_force)
	
func _process(delta):
	timer += delta
	var mouse_repel = Vector2(0, 0)
	
	if Input.is_action_pressed("left_click"):
		var pos = get_global_mouse_position()
		if timer >= 0.05 and not get_parent().check_inter_col(pos):
			add_particle(pos)
			timer = 0
	
	if Input.is_action_just_pressed("right_click"):
		mouse_pos = get_global_mouse_position()
	
	if Input.is_action_just_released("right_click"):
		var pos = get_global_mouse_position()
		mouse_repel = pos - mouse_pos
	
	if get_parent().interface_visible:
		return
	
	$native_lib.update_field(delta, grid_vectors, particles, external_forces() + mouse_repel)


func _on_interface_show_grid_signal():
	show_grid = not show_grid
	$grid_visualizer.update()

func _on_interface_show_vectors_signal():
	show_vectors = not show_vectors
	if show_vectors:
		$vector_visualizer.show()
	else:
		$vector_visualizer.hide()
