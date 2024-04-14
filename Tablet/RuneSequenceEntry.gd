class_name RuneSequenceEntry
extends Resource

@export var rune: Rune
@export var plural := false
@export var negative := false
@export var genitive := false

static func build(_rune: Rune, _plural: bool, _negative: bool, _genitive: bool) -> RuneSequenceEntry:
	var entry := RuneSequenceEntry.new()
	entry.rune = _rune
	entry.plural = _plural
	entry.negative = _negative
	entry.genitive = _genitive
	return entry

func get_text(first: bool) -> String:
	var text: String
	if plural:
		if genitive:
			text = rune.text_genitive_plural
		elif first:
			text = rune.text_plural
		else:
			text = rune.text_accusative_plural
	else:
		if genitive:
			text = rune.text_genitive
		elif first:
			text = rune.text
		else:
			text = rune.text_accusative
	if negative:
		text = rune.neg_prefix + text
	return text
