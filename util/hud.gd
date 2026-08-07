extends CanvasLayer

@onready var look_up_btn = $LookUp 
@onready var look_down_btn = $LookDown 

signal cam_lookup
signal cam_lookdown

func _ready() -> void: 
	look_up_btn.connect("pressed",_on_look_up) 
	look_down_btn.connect("pressed",_on_look_down) 

func _on_look_up():
	cam_lookup.emit()

func _on_look_down(): 
	cam_lookdown.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("look_up"):
		_on_look_up()
	if event.is_action_pressed("look_down"):
		_on_look_down()
