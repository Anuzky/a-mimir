extends Node 

@onready var cam = $Camera2D 
@onready var ui = $UI 
@onready var hud = $UI/HUD 
@onready var interactables = $Interactables 

const GAMES_TO_WIN = 2

var is_in_minigame = false
var games_won = 0
var curr_interactable : Interactable = null 

func _ready() -> void: 
	hud.cam_lookup.connect(_on_cam_lookup)
	hud.cam_lookdown.connect(_on_cam_lookdown)
	
	for interactable : Interactable in interactables.get_children(): 
		interactable.start_minigame.connect(_on_start_minigame.bind(interactable))
		
	ui.minigame_closed.connect(_on_minigame_closed)

func _on_cam_lookup():
	if cam.position.y == 360 or cam.position.y == 640: # posiciones media, baja
		var tween = create_tween()
		tween.tween_property(cam, "position", Vector2(cam.position.x, cam.position.y-280), 0.25)
	
func _on_cam_lookdown():
	if cam.position.y == 360 or cam.position.y == 80: # posiciones media, alta
		var tween = create_tween()
		tween.tween_property(cam, "position", Vector2(cam.position.x, cam.position.y+280), 0.25)
		
func _on_start_minigame(minigame : PackedScene, interactable : Interactable): 
	curr_interactable = interactable
	is_in_minigame = true 
	ui.open_minigame(minigame)
	
func _on_minigame_closed(): # gano un minijuego
	is_in_minigame = false
	# visual cue
	interactables.remove_child(curr_interactable)
	curr_interactable.queue_free()
	games_won+=1
	if games_won == GAMES_TO_WIN:
		#good ending
		print("Ganaste el juego bro")
