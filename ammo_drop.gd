class_name ammo extends Node3D

var type
var amount
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("player_death", despawn)
	var player = PlayerManager.player
	var wep1 = player.get_current_weapon()
	var wep2 = player.get_other_weapon()
	#if randi_range(0,10) % 2 == 0: # randomly chooses between giving ammo for current or other weapon
	if wep1:
		type = wep1.name
		amount = wep1.get_reward_amount()
	else:
		if wep2:
			type = wep2.name
			amount = wep2.get_reward_amount()
		elif wep1:
			type = wep1.name
			amount = wep1.get_reward_amount()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$"../model".rotation_degrees = $"../model".rotation_degrees + Vector3(0,1,0)
	self.rotation_degrees = self.rotation_degrees + Vector3(0,1,0)
	pass

func despawn():
	var collision = get_child(0)
	collision.disabled = true
	get_parent().queue_free()
