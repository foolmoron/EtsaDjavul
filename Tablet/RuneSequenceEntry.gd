class_name RuneSequenceEntry
extends Resource

@export var rune: Rune
@export var plural := false
@export var negative := false
@export var genitive := false

func get_text() -> String:
	var text: String
	if plural:
		if genitive:
			text = rune.text_genitive_plural
		else:
			text = rune.text_plural
	else:
		if genitive:
			text = rune.text_genitive
		else:
			text = rune.text
	if negative:
		text = rune.neg_prefix + text
	return text
