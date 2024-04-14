class_name Level
extends Node2D

@export var level_name := ""
@export var ever_completed := false
@export var complete := false
@export var phrase: Array[RuneSequenceEntry] = []
@export var complete_shadow_color: Color = Color.WHITE
@export var complete_text_color: Color = Color.WHITE
@export var hint: Array[PackedVector2Array] = []

@onready var orig_shadow_color: Color = $Shadow.color
@onready var orig_text_color: Color = $LevelLabel.label_settings.font_color

var level_id := 0

func _ready():
	ever_completed = GameManager.inst.get_save().completed.has(level_name)
	update_colors()

	$LevelLabel.text = level_name
	
	var text = ""
	if phrase != null and phrase.size() > 0:
		phrase[0].genitive = false # ensure first is never genitive
		var first := true
		for entry in phrase:
			text += entry.get_text(first)
			first = false
	$PhraseLabel.text = text

	# swap genitives with previous item after calculating text
	for i in phrase.size():
		var item := phrase[i]
		if item.genitive:
			phrase.remove_at(i)
			phrase.insert(i - 1, item)

func _process(delta):
	var is_level := GameManager.inst.current_level == level_id
	var has_prev := level_id > 1
	var has_next := level_id < GameManager.inst.levels.size() and ever_completed
	$PrevButton.visible = is_level and has_prev
	$PrevButton.set_process($PrevButton.visible )
	$NextButton.visible = is_level and has_next
	$NextButton.set_process($NextButton.visible)
	$LevelsButton.visible = is_level
	$LevelsButton.set_process($LevelsButton.visible)
	$ClearButton.visible = is_level
	$ClearButton.set_process($ClearButton.visible)
	pass

func to_prev_level():
	GameManager.inst.set_level(level_id - 1)

func to_next_level():
	GameManager.inst.set_level(level_id + 1)

func to_levels():
	GameManager.inst.set_level(0)

func matches_phrase(to_match: Array[RuneSequenceEntry]) -> bool:
	if to_match.size() != phrase.size():
		return false
	for i in to_match.size():
		if phrase[i].rune != to_match[i].rune:
			return false
		if phrase[i].plural != to_match[i].plural:
			return false
		if phrase[i].negative != to_match[i].negative:
			return false
	return true

func do_complete():
	complete = true
	ever_completed = true
	update_colors()
	if not GameManager.inst.save.completed.has(level_name):
		GameManager.inst.save.completed.append(level_name)
	if level_id > GameManager.inst.save.completed_id:
		GameManager.inst.completed_id = level_id
		GameManager.inst.save.completed_id = level_id
		GameManager.inst.update_completed()
	GameManager.inst.do_save()

func update_colors():
	$Shadow.color = complete_shadow_color if ever_completed else orig_shadow_color
	$LevelLabel.label_settings.font_color = complete_text_color if complete else orig_text_color
	$PhraseLabel.label_settings.font_color = complete_text_color if complete else orig_text_color
