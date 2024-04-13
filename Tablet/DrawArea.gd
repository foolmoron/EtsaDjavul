extends Area2D

var is_drawing := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_local = to_local(get_global_mouse_position())
	var inside = Geometry2D.is_point_in_polygon(mouse_local, $CollisionPolygon2D.polygon)
	if not inside:
		is_drawing = false
	if is_drawing:
		print("Drawing %s: %s" % [get_parent().name, mouse_local])
	pass


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var evt := event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT and evt.is_pressed():
			is_drawing = true
