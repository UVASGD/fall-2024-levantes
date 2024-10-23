extends Node



@export var navAgent_ : Node
@export var main: Node
@export var hurtbox: Node

@export var speed: float = 1.0
@export var health: float = 1.0
@export var dmg: float = 10.0
@export var attack_speed: float = 1.0
@export var acceleration: float = 7.0

var can_attack: bool = true
@onready var attack_speed_timer = $AttackSpeedTimer

enum ENTITY_STATE{
	# The real value of these enums are numbers
	IDLE,
	CHASE,
	ATTACK
}

@export var entity_state = ENTITY_STATE.IDLE

var can_move: bool = true
func _physics_process(delta):
	if main.player == null:
		return
	match entity_state:
		# The real value of the enum states are numbers
		# Idle
		0:
			can_move = true
		# Chase
		1: 
			can_move = true
		# Attack
		2:
			can_move = false
			if can_attack == true and hurtbox.player_overlapping:
				can_attack = false
				deal_damage(main.player)
				attack_speed_timer.start(attack_speed); await attack_speed_timer.timeout
				can_attack = true
				entity_state = ENTITY_STATE.IDLE
				
func deal_damage(player):
	player.update_health(dmg)

func update_health(damage):
	health -= damage
	if health <= 0:
		get_parent().queue_free()
	
			



