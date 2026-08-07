extends Control

@onready var hud : CanvasLayer = $HUD
@onready var minigame_popup : CanvasLayer = $MinigamePopup
@onready var minigame_container = $MinigamePopup/MinigameContainer
@onready var minigame_panel = $MinigamePopup/MinigamePanel # Referencia al marco del minijuego

# Esta señal le avisará a game.gd que rehabilite la cámara y los botones
signal minigame_closed 

func _ready():
	minigame_popup.hide()

func open_minigame(minigame : PackedScene):
	var minigame_inst : Minigame = minigame.instantiate()
	minigame_container.add_child(minigame_inst)
	
	minigame_popup.show()
	
	#if minigame_inst.has_signal("game_won"):
	minigame_inst.game_won.connect(_on_minigame_won)

func _on_minigame_won():
	close_minigame()

func close_minigame():
	minigame_popup.hide()
	
	for child in minigame_container.get_children():
		child.queue_free()
		
	minigame_closed.emit()
