extends CanvasLayer

@onready var minigame_container = $MinigameContainer

func _ready():
	pass
	
func open_minigame(minigame : PackedScene):
	var minigame_inst = minigame.instantiate()
	minigame_container.add_child(minigame_inst)
