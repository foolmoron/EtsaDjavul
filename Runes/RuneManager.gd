class_name RuneManager
extends Node

static var inst: RuneManager

@export var all_runes: Array[Rune] = []

func _enter_tree():
	inst = self

func _ready():
	for r in all_runes:
		r.on_ready()
