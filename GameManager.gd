class_name GameManager
extends Node2D

static var inst: GameManager

@export var current_level := 0
@export_range(0.0, 0.5, 0.01, "or_greater") var pos_lerp_speed := 0.2
@export_range(0.0, 10, 0.01, "or_greater") var zoom_lerp_speed := 5.0

@onready var pos_orig := $Camera2D.global_position as Vector2
@onready var zoom_orig := $Camera2D.zoom as Vector2
@onready var pos_target := pos_orig
@onready var zoom_target := zoom_orig

var levels: Array[Level] = []

const SAVE_FILE := "user://etsa.save"
var save = {}
var save_loaded := false
var completed_id := 0

func _enter_tree():
	inst = self

func _ready():
	completed_id = get_save().completed_id
	for l: Level in find_children("*", "Level", false):
		levels.append(l)
		l.level_id = levels.size()
	update_completed()

func _process(delta):
	$Camera2D.global_position = lerp($Camera2D.global_position, pos_target, pos_lerp_speed)
	$Camera2D.zoom.x = move_toward($Camera2D.zoom.x, zoom_target.x, zoom_lerp_speed * delta)
	$Camera2D.zoom.y = move_toward($Camera2D.zoom.y, zoom_target.y, zoom_lerp_speed * delta)

func get_save() -> Dictionary:
	if not save_loaded:
		save_loaded = true
		if not FileAccess.file_exists(SAVE_FILE):
			save = {}
		else:
			var json := JSON.new()
			var res := json.parse(FileAccess.get_file_as_string(SAVE_FILE))
			if not res == OK:
				save = {}
			else:
				save = json.get_data()
		# init
		if not save.has("completed"):
			save.completed = []
		if not save.has("completed_id"):
			save.completed_id = 0
	return save

func do_save():
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(get_save()))

func set_level(level: int):
	current_level = level
	if level > 0:
		pos_target = levels[level-1].get_node("CameraTarget").global_position
		var zoom := 1.0 / levels[level-1].scale.x
		zoom_target = Vector2(zoom, zoom)
	else:
		pos_target = pos_orig
		zoom_target = zoom_orig

func update_completed():
	for l in levels:
		var c := l.level_id <= (completed_id + 1)
		l.set_process(c)
		l.visible = c