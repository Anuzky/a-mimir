extends Control

@onready var play_btn : TextureButton = $Buttons/Play
@onready var options_btn : TextureButton = $Buttons/Options

func _ready():
	play_btn.pressed.connect(_on_play)
	
func _on_play():
	get_tree().change_scene_to_file("res://game.tscn")
