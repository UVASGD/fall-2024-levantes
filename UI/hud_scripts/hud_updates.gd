extends CenterContainer
@export var crosshair_radius: float = 6.0
@export var crosshair_color: Color = Color.DODGER_BLUE

# Called when the node enters the scene tree for the first time.
func _ready():
	queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _draw():
	draw_circle(Vector2(20,20),crosshair_radius, crosshair_color)

#func initiate():
	#
#
#func decrease_ammo(wep_name, ammo):
	
	
	
