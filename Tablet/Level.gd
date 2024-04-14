class_name Level
extends Node2D

@export var level_name := ""
@export var completed := false
@export var phrase: Array[RuneSequenceEntry] = []

var level_id := 0

func _ready():
	$LevelLabel.text = level_name
	var text = ""
	for entry in phrase:
		text += entry.get_text()
	$PhraseLabel.text = text

func _process(delta):
	var is_level := GameManager.inst.current_level == level_id
	var has_prev := level_id > 1
	var has_next := level_id < GameManager.inst.levels.size()
	$PrevButton.set_process(PROCESS_MODE_INHERIT if is_level and has_prev else PROCESS_MODE_DISABLED)
	$PrevButton.visible = is_level and has_prev
	$NextButton.set_process(PROCESS_MODE_INHERIT if is_level and has_next else PROCESS_MODE_DISABLED)
	$NextButton.visible = is_level and has_next
	$LevelsButton.set_process(PROCESS_MODE_INHERIT if is_level else PROCESS_MODE_DISABLED)
	$LevelsButton.visible = is_level
	$ClearButton.set_process(PROCESS_MODE_INHERIT if is_level else PROCESS_MODE_DISABLED)
	$ClearButton.visible = is_level
	pass

func to_prev_level():
	GameManager.inst.set_level(level_id - 1)

func to_next_level():
	GameManager.inst.set_level(level_id + 1)

func to_levels():
	GameManager.inst.set_level(0)
