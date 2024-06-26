class_name DrawArea
extends Area2D

const EMISSION_TIME = 0.1

@export_range(0, 100) var min_dist := 30.0
@export var line_scn: PackedScene
@export var hint_line_scn: PackedScene

@onready var level := get_parent() as Level
@onready var bounds := $CollisionShape2D.shape.get_rect() as Rect2
@onready var container := $CollisionShape2D

@onready var orig_pos: Vector2 = get_parent().position

@export var DEBUG_STROKES: Array[PackedVector2Array] = []

var orig_line_color: Color

var lines: Array[Line2D] = []
var is_drawing := false
var emission_time_left := 0.0

var frames_to_shake := 0

var world_bounds: Rect2

# Called when the node enters the scene tree for the first time.
func _ready():
	var dummy := line_scn.instantiate() as Line2D
	add_child(dummy)
	dummy.scale = Vector2(0, 0)
	orig_line_color = dummy.default_color
	world_bounds = Rect2(to_global(bounds.position), Vector2(0, 0)).expand(to_global(bounds.end))
	
	# spawn hint
	if level.hint != null and level.hint.size() > 0:
		for ps in level.hint:
			var line = hint_line_scn.instantiate() as Line2D
			container.add_child(line)
			line.clear_points()
			for p in ps:
				line.add_point(p)

	# spawn saved
	if GameManager.inst.get_save().has("linepts_"+level.level_name):
		var saved_lines = GameManager.inst.get_save()["linepts_"+level.level_name]
		for ps in saved_lines:
			var line = line_scn.instantiate() as Line2D
			container.add_child(line)
			# line.material.set_shader_parameter("base_pos", world_bounds.position)
			# line.material.set_shader_parameter("base_size", world_bounds.size)
			var p := 0
			line.clear_points()
			while p < ps.size():
				line.add_point(Vector2(ps[p], ps[p+1]))
				p += 2
			lines.append(line)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_local := to_local(get_global_mouse_position())
	mouse_local.x = clamp(mouse_local.x, bounds.position.x, bounds.end.x)
	mouse_local.y = clamp(mouse_local.y, bounds.position.y, bounds.end.y)
	var pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if is_drawing and not pressed:
		is_drawing = false
		var line = lines[lines.size() - 1]
		if line.points.size() < 4:
			line.queue_free()
			lines.pop_back()
		else:
			check_drawing()
	elif is_drawing:
		var line = lines[lines.size() - 1]
		if line.get_point_count() == 1 or line.get_point_position(line.get_point_count() - 2).distance_squared_to(mouse_local) > min_dist * min_dist:
			line.add_point(mouse_local)
			$CPUParticles2D.position = mouse_local
			emission_time_left = EMISSION_TIME
			frames_to_shake = 2
		else:
			line.set_point_position(line.get_point_count() - 1, mouse_local)
	
	# emission
	if emission_time_left > 0.0:
		emission_time_left -= delta
		$CPUParticles2D.emitting = true
		$DrawAudio.playing = true
	else:
		$CPUParticles2D.emitting = false
		$DrawAudio.playing = false

	# shake
	if frames_to_shake > 0:
		frames_to_shake -= 1
		var r := Vector2(randf_range(-0.3, 0.3), randf_range(-0.3, 0.3))
		get_parent().position = orig_pos + r
		pass
	else:
		get_parent().position = orig_pos
		pass

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var evt := event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT and evt.is_pressed():
			if GameManager.inst.current_level != level.level_id:
				GameManager.inst.set_level(level.level_id)
				return
			elif not is_drawing:
				var line = line_scn.instantiate() as Line2D
				container.add_child(line)
				# line.material.set_shader_parameter("base_pos", world_bounds.position)
				# line.material.set_shader_parameter("base_size", world_bounds.size)
				line.clear_points()
				var mouse_local := to_local(get_global_mouse_position())
				line.add_point(mouse_local)
				lines.append(line)
				is_drawing = true
				level.complete = false
				level.update_colors()
				$CPUParticles2D.position = mouse_local
				emission_time_left = EMISSION_TIME
				frames_to_shake = 2

func check_drawing():
	DEBUG_STROKES.clear()
	for l in lines:
		DEBUG_STROKES.append(l.points)

	var aa := Time.get_ticks_usec()
	const TOUCH_LEEWAY = 12.0
	var touchings = {}
	for l1 in lines.size():
		if not touchings.has(l1):
			touchings[l1] = {}
		var line1 := lines[l1]
		var rect1 = Rect2(line1.points[0], Vector2(0, 0))
		for p in line1.points:
			rect1 = rect1.expand(p)
		rect1 = rect1.grow(TOUCH_LEEWAY)
		for l2 in lines.size():
			var line2 := lines[l2]
			var rect2 = Rect2(line2.points[0], Vector2(0, 0))
			for p in line2.points:
				rect2 = rect2.expand(p)
			rect2 = rect2.grow(TOUCH_LEEWAY)
			if rect1.intersects(rect2, true):
				rect1 = rect1.merge(rect2)
				touchings[l1][l2] = null
				if not touchings.has(l2):
					touchings[l2] = {}
				touchings[l2][l1] = null
				var to_merge = touchings[l1].keys()
				for k in touchings[l2].keys():
					if not to_merge.has(k):
						to_merge.append(k)
				var i := 0
				while i < to_merge.size():
					for k in touchings[to_merge[i]].keys():
						if not to_merge.has(k):
							to_merge.append(k)
					i += 1
				for m in to_merge:
					touchings[l1].merge(touchings[m])
					touchings[m].merge(touchings[l1])
	var drawings: Array[Drawing] = []
	for key in touchings.keys():
		touchings[key] = touchings[key].keys()
		touchings[key].sort()
	while !touchings.is_empty():
		var keys = touchings.keys()
		var key = keys[0]
		var val = touchings[key]
		var drawing_lines: Array[PackedVector2Array] = []
		var k := keys.size() - 1
		while k >= 0:
			if touchings[keys[k]] == val:
				drawing_lines.append(lines[keys[k]].points)
				touchings.erase(keys[k])
			k -= 1
		var drawing = Drawing.new(drawing_lines)
		drawings.append(drawing)
	drawings.sort_custom(func(a, b): return a.get_sort_value() > b.get_sort_value())

	var bb := Time.get_ticks_usec()
	print("Best for %s:" % level.name)
	var sequence: Array[RuneSequenceEntry] = []
	var ruined := false
	var match_vals: Array[float] = []
	for drawing in drawings:
		var runes_to_rank = []
		for r in RuneManager.inst.all_runes:
			runes_to_rank.append([RuneSequenceEntry.build(r, false, false, false), r.points_normalized,           "%s          " % r.resource_path])
			runes_to_rank.append([RuneSequenceEntry.build(r, true,  false, false), r.points_normalized_vflip,     "%s VFLIP    " % r.resource_path])
			runes_to_rank.append([RuneSequenceEntry.build(r, false, true, false),  r.points_normalized_rot,       "%s ROT      " % r.resource_path])
			runes_to_rank.append([RuneSequenceEntry.build(r, true,  true, false),  r.points_normalized_rot_vflip, "%s ROT VFLIP" % r.resource_path])
		runes_to_rank = runes_to_rank.filter(func(r): return level.phrase.any(func(p): return p.same_except_genitive(r[0])))
		if runes_to_rank.size() == 0:
			ruined = true
			continue
		var res = Util.best_by(runes_to_rank, func(r, best): return -Rune.test_error(drawing, r[1], -best))
		var best_rune = res[0]
		var best_error = sqrt(-res[1])
		sequence.append(best_rune[0])
		if best_error > best_rune[0].rune.max_error:
			ruined = true
		match_vals.append(clamp(best_rune[0].rune.max_error / best_error, 0.0, 1.0))
		print("\t%s: %.3f" % [best_rune[2], best_error])

	var cc := Time.get_ticks_usec()
	print("\t\t elapsed a: %sus" % (bb - aa))
	print("\t\t elapsed b: %sus" % (cc - bb))
	print("\t\t elapsed c: %sus" % (Time.get_ticks_usec() - cc))

	var matches := level.matches_phrase(sequence)
	var correct := not ruined and matches.size() > 0 and matches.all(func(x): return x)
	var match_perc := 0.0
	for m in match_vals:
		match_perc += m / matches.size()

	level.get_node("MatchContainer/MatchRect").scale = Vector2(match_perc, 1.0)
	level.get_node("MatchContainer/MatchRect").color = level.complete_shadow_color
	level.get_node("MatchContainer/MatchLabel").text = str(int(match_perc * 99.0)) + "% MATCH"

	if correct:
		print("CORRECT!!!")
		level.do_complete()
		var all_lines: Array[PackedFloat32Array] = []
		for l in lines:
			var points: PackedFloat32Array = []
			for p in l.points:
				points.append(p.x)
				points.append(p.y)
			all_lines.append(points)
		GameManager.inst.get_save()["linepts_"+level.level_name] = all_lines
		GameManager.inst.do_save()
	else:
		print("not correct")

	queue_redraw()

func clear_drawing():
	for l in lines:
		l.queue_free()
	lines.clear()
	level.complete = false

	level.get_node("MatchContainer/MatchRect").scale = Vector2(0.0, 1.0)
	level.get_node("MatchContainer/MatchRect").color = level.complete_shadow_color
	level.get_node("MatchContainer/MatchLabel").text = str(int(0.0 * 100.0)) + "% MATCH"
