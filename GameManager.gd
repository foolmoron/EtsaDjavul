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

func _enter_tree():
    inst = self

func _ready():
    for l: Level in find_children("*", "Level", false):
        levels.append(l)
        l.level_id = levels.size()

func _process(delta):
    $Camera2D.global_position = lerp($Camera2D.global_position, pos_target, pos_lerp_speed)
    $Camera2D.zoom.x = move_toward($Camera2D.zoom.x, zoom_target.x, zoom_lerp_speed * delta)
    $Camera2D.zoom.y = move_toward($Camera2D.zoom.y, zoom_target.y, zoom_lerp_speed * delta)

func set_level(level: int):
    current_level = level
    if level > 0:
        pos_target = levels[level-1].get_node("CameraTarget").global_position
        var zoom := 1.0 / levels[level-1].scale.x
        zoom_target = Vector2(zoom, zoom)
    else:
        pos_target = pos_orig
        zoom_target = zoom_orig