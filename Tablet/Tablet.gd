class_name Tablet
extends Node2D

@export var runes: Array[Rune] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for r in runes:
		r.on_ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
