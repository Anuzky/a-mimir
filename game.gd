extends Node

@onready var cam = $Camera2D
@onready var look_up_btn = $CanvasLayer/LookUp
@onready var look_down_btn = $CanvasLayer/LookDown

var looking_up = false
var looking_down = false

func _ready() -> void:
	look_up_btn.connect("button_down",_on_look_up.bind(true))
	look_down_btn.connect("button_down",_on_look_down.bind(true))
	look_up_btn.connect("button_up",_on_look_up.bind(false))
	look_down_btn.connect("button_up",_on_look_down.bind(false))
	
func _process(delta: float) -> void:
	if looking_up:
		if cam.position.y > 80:
			cam.position.y -= 40
	elif looking_down:
		if cam.position.y < 640:
			cam.position.y += 40
	
func _on_look_up(pressed : bool):
	if pressed:
		if !looking_down:
			looking_up = true
	else:
		looking_up = false
	
func _on_look_down(pressed : bool):
	if pressed:
		if !looking_up:
			looking_down = true
	else:
		looking_down = false
