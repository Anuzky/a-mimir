extends CanvasLayer

@onready var minigame_container = $MinigameContainer
@onready var minigame_panel = $MinigamePanel # Referencia al marco del minijuego

# Esta señal le avisará a game.gd que rehabilite la cámara y los botones
signal minigame_closed 

func _ready():
	minigame_panel.hide()
	minigame_container.hide()

func open_minigame(minigame : PackedScene):
	var minigame_inst = minigame.instantiate()
	minigame_container.add_child(minigame_inst)
	
	minigame_panel.show()
	minigame_container.show()
	
	if minigame_inst.has_signal("game_won"):
		minigame_inst.game_won.connect(_on_minigame_won)

func _on_minigame_won():
	close_minigame()

func close_minigame():
	minigame_panel.hide()
	minigame_container.hide()
	
	for child in minigame_container.get_children():
		child.queue_free()
		
	minigame_closed.emit()
