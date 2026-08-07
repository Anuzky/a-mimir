extends Minigame

@onready var timer : Timer = $GameTimer
@onready var start_timer : Timer = $StartTimer

@onready var start_cd_label : Label = $StartCDLabel
@onready var cd_label : Label = $CDLabel
@onready var clicks_left : Label = $ClicksLeft

@onready var clickable_obj : TextureButton = $ClickableObject

var total_clicks : int
var seconds : int # El tiempo que tiene el jugador para hacer los clicks totales
var clicks : int = 0

func _ready() -> void:
	randomize() 
	seconds = randi_range(5, 10)
	total_clicks = randi_range(25, 45)
	start_timer.timeout.connect(_on_start)
	timer.timeout.connect(_on_end)
	
	
func _process(_delta: float) -> void:
	if not start_timer.is_stopped():
		if int(start_timer.time_left) == 0:
			start_cd_label.text = 'GO!'
		else:
			start_cd_label.text = str(int(start_timer.time_left)) + '...'
	elif not timer.is_stopped():
		cd_label.text = str(int(timer.time_left))

func _on_start():
	start_cd_label.hide()
	cd_label.text = str(seconds)
	timer.wait_time = seconds
	timer.start()
	clickable_obj.pressed.connect(_on_click)
	cd_label.show()
	clicks_left.text = 'Clicks left: ' + str(total_clicks) + '!'
	clicks_left.show()
	
func _on_end():
	clickable_obj.pressed.disconnect(_on_click)
	cd_label.hide()
	if clicks >= total_clicks:
		game_won.emit()
	else:
		print("noob")
		pass #perder?

func _on_click():
	clicks += 1
	if clicks == total_clicks:
		timer.stop()
		game_won.emit()
	else:
		clicks_left.text = 'Clicks left: ' + str(total_clicks - clicks) + '!'
