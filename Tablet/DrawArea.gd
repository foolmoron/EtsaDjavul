class_name DrawArea
extends Area2D

@export_range(0, 100) var min_dist := 30.0
@export var line_scn: PackedScene

@onready var tablet := get_parent() as Tablet

var lines: Array[Line2D] = []
var is_drawing := false

var world_bounds: Rect2

# Called when the node enters the scene tree for the first time.
func _ready():
	world_bounds = Rect2($CollisionPolygon2D.to_global($CollisionPolygon2D.polygon[0]), Vector2(0, 0))
	for p in $CollisionPolygon2D.polygon:
		world_bounds = world_bounds.expand($CollisionPolygon2D.to_global(p))
	print(world_bounds)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_local = to_local(get_global_mouse_position())
	var inside = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Geometry2D.is_point_in_polygon(mouse_local, $CollisionPolygon2D.polygon)
	if is_drawing and not inside:
		is_drawing = false
		check_drawing()
	elif is_drawing:
		var line = lines[lines.size() - 1]
		if line.get_point_count() == 1 or line.get_point_position(line.get_point_count() - 2).distance_squared_to(mouse_local) > min_dist * min_dist:
			line.add_point(mouse_local)
		else:
			line.set_point_position(line.get_point_count() - 1, mouse_local)
	pass


func _on_input_event(viewport, event, shape_idx):
	if not is_drawing and event is InputEventMouseButton:
		var evt := event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT and evt.is_pressed():
			var line = line_scn.instantiate() as Line2D
			add_child(line)
			line.material.set_shader_parameter("base_pos", world_bounds.position)
			line.material.set_shader_parameter("base_size", world_bounds.size)
			line.clear_points()
			line.add_point(to_local(get_global_mouse_position()))
			lines.append(line)
			is_drawing = true

func check_drawing():
	var drawing_lines: Array[PackedVector2Array] = []
	for line in lines:
		drawing_lines.append(line.points)
	var drawing := Drawing.new(drawing_lines)
	var runes_to_rank = []
	for r in tablet.runes:
		runes_to_rank.append([r, r.points_normalized, "%s     " % r.resource_path])
		runes_to_rank.append([r, r.points_normalized_vflip, "%s VFLIP" % r.resource_path])
	var runes_ranked = Util.sorted_by(runes_to_rank, func(r): return -Rune.test_error(drawing, r[1]))
	print("Ranking %s:" % tablet.name)
	for r in runes_ranked:
		print("\t%s: %.3f" % [r[2], Rune.test_error(drawing, r[1])])
