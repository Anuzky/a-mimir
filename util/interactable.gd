class_name Interactable
extends TextureButton

@export var minigame : PackedScene

signal start_minigame(minigame : PackedScene)

func _pressed() -> void:
	start_minigame.emit(minigame)
