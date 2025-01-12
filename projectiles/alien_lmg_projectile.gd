extends "res://throwable.gd"

var explosion = preload("res://projectiles/explosion.tscn")
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
@onready var lmg_proj_timer: Timer = $free_timer


func _ready():
	gravity_scale = 0
	sleeping = true
	animation_player = get_child(3)
	collision = get_child(1)
	if does_collision_wait:
		collision.disabled = true
	body_entered.connect(_on_body_entered)
	timer = Timer.new()
	timer.wait_time = cooldown
	add_child(timer)
	timer.connect("timeout", action)
	lmg_proj_timer.start()
	pass

func _process(delta):
	lmg_proj_timer.wait_time = 2.0
	pass


func _on_body_entered(body):
	if !body.is_in_group("Player") and body.is_in_group("enemies"):
		SignalBus.emit_signal("enemy_hit", damage, 1, body, 1)
		self.queue_free()
	elif !body.is_in_group("Player"):
		self.queue_free()


func _on_free_timer_timeout():
	$".".queue_free()
