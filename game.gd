extends Node 

@onready var cam = $Camera2D 
@onready var ui = $UI 
@onready var look_up_btn = $UI/LookUp 
@onready var look_down_btn = $UI/LookDown 
@onready var interactables = $Interactables 

var looking_up = false 
var looking_down = false 
var is_in_minigame = false 

func _ready() -> void: 
	look_up_btn.connect("button_down",_on_look_up.bind(true)) 
	look_down_btn.connect("button_down",_on_look_down.bind(true)) 
	look_up_btn.connect("button_up",_on_look_up.bind(false)) 
	look_down_btn.connect("button_up",_on_look_down.bind(false)) 
	
	for interactable : Interactable in interactables.get_children(): 
		interactable.start_minigame.connect(_on_start_minigame)
		
	ui.minigame_closed.connect(_on_minigame_closed)

func _process(delta: float) -> void: 
	if looking_up: 
		if cam.position.y > 80: 
			cam.position.y -= 40 
	elif looking_down: 
		if cam.position.y < 640: 
			cam.position.y += 40 

func _on_look_up(pressed : bool): 
	if pressed: 
		if !looking_down: looking_up = true 
	else: 
		looking_up = false 

func _on_look_down(pressed : bool): 
	if pressed: 
		if !looking_up: looking_down = true 
	else: 
		looking_down = false 

func _on_start_minigame(minigame : PackedScene): 
	is_in_minigame = true 
	get_tree().call_group("buttons", "set_disabled",true) 
	ui.open_minigame(minigame)

func _on_minigame_closed():
	is_in_minigame = false
	get_tree().call_group("buttons", "set_disabled", false)
