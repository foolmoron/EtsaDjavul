extends Area2D

@export_range(0, 100) var min_dist := 30.0

var is_drawing := false

@onready var line := $DrawingLine as Line2D
@onready var container := line.get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	container.remove_child(line)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_local = to_local(get_global_mouse_position())
	var inside = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Geometry2D.is_point_in_polygon(mouse_local, $CollisionPolygon2D.polygon)
	if is_drawing and not inside:
		is_drawing = false
		container.remove_child(line)
	elif is_drawing:
		var last_point := line.get_point_position(line.get_point_count() - 2)
		if line.get_point_count() == 2 or last_point.distance_squared_to(mouse_local) > min_dist * min_dist:
			line.add_point(mouse_local)
		else:
			line.set_point_position(line.get_point_count() - 1, mouse_local)
	pass


func _on_input_event(viewport, event, shape_idx):
	if not is_drawing and event is InputEventMouseButton:
		var evt := event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT and evt.is_pressed():
			container.add_child(line)
			line.clear_points()
			line.add_point(to_local(get_global_mouse_position()))
			line.add_point(to_local(get_global_mouse_position()))
			is_drawing = true
