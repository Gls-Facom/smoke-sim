extends Node2D

onready var grid = get_parent()
var dynamic_font = DynamicFont.new()

func _ready():
	dynamic_font.font_data = load("res://textures/04B_19__.ttf")
	dynamic_font.size = 16

func normalize(value, minmax):
#	return value/minmax.y
	return (value - minmax.x)/(minmax.y - minmax.x)

func _process(delta):
	update()

func _draw():
	if not grid.show_pressure:
		return
	
	var vertex_pressure = []
	for x in range(1,grid.squares_qtd.y+2):
		vertex_pressure.append([])
		for y in range(1,grid.squares_qtd.x+2):

			var pos = grid.grid_vectors[x][y].pos - 0.5*grid.tile_size
			var position = pos-grid.tile_size
			var vec = grid.VectorClass.new()
			vec.pressure = grid.bilinear_interpolation_press(position)
#			if(x==5 and y==5): 
#				vec.pressure = 255
			vec.pos = position
			vertex_pressure[x-1].append(vec)
#			draw_circle(position + 0.5*grid.tile_size, 1, Color(1,1,1,vec.pressure/255.0))
	
	var minmax_presure = grid.get_minmax_pressure()
	#da pra otimizar, colocando em cpp
	for x in range(vertex_pressure.size()-1):
		for y in range(vertex_pressure[0].size()-1):
			var position = vertex_pressure[x][y].pos
			var lb = position
			var lt = lb + Vector2(0,grid.tile_size.y)
			var rb = lb + Vector2(grid.tile_size.x, 0)
			var rt = rb + Vector2(0,grid.tile_size.y)
			var verts = PoolVector2Array([lb, rb, rt, lt])
			var colors = PoolColorArray([Color(1,1,1, normalize(vertex_pressure[x][y].pressure, minmax_presure)),
										 Color(1,1,1, normalize(vertex_pressure[x][y+1].pressure, minmax_presure)),
										 Color(1,1,1, normalize(vertex_pressure[x+1][y+1].pressure, minmax_presure)),
										 Color(1,1,1, normalize(vertex_pressure[x+1][y].pressure, minmax_presure))])
			
			draw_primitive(verts, colors, verts)
#			draw_string(dynamic_font, lb+Vector2(0,dynamic_font.size), "%.2f" %vertex_pressure[x][y].pressure,Color(0,1,0))
