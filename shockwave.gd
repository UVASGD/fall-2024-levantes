extends Node3D

@onready var inner = $inner
@onready var outer = $outer
@onready var donut = $donut
@export var speed:float = 0.08
@export var damage:int
@onready var animation_player = $AnimationPlayer
var outerspeed
# Called when the node enters the scene tree for the first time.
func _ready():
	donut.mesh.inner_radius = 0.839
	donut.mesh.outer_radius = 0.708
	outerspeed = speed #*0.99
	animation_player.play("idle")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	inner.scale += Vector3(speed,speed,speed)
	outer.scale += Vector3(outerspeed,outerspeed,outerspeed)
	donut.mesh.inner_radius += speed * 0.85
	donut.mesh.outer_radius += speed * 0.85
	pass



func _on_outer_body_entered(body):
	if body.is_in_group("Player") and body not in inner.get_overlapping_bodies():
		if body.is_on_floor():
			SignalBus.emit_signal("player_hit", damage)
			#apply force to player 
			pass

func despawn():
	animation_player.play("disappear")
	await animation_player.animation_finished
	SignalBus.emit_signal("shockwave_death")
	queue_free()


func _on_life_timer_timeout():
	despawn()
	pass # Replace with function body.
