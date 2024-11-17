extends Node


signal player_hit(damage_taken)

signal enemy_hit(damage_taken, headshot_multiplier, collider, shape)

signal update_hud_shop_weapon_name(shop_weapon_name)

signal enemy_death

signal object_hit

signal update_ammo(ammo_amount)

signal call_hud_initialize

signal shockwave_death

signal round_start

signal gun_purchase

signal wave_killed 

signal score_add 

signal player_death 
var current_difficulty = 1

var player_save = null
