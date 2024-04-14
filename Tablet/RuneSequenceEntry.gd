class_name RuneSequenceEntry
extends Resource

@export var rune: Rune
@export var plural := false

func get_text() -> String:
    if plural:
        return rune.text_plural
    else:
        return rune.text
        