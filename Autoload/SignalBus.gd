extends Node


signal player_hit(damage_taken)

signal enemy_hit(damage_taken, headshot_multiplier, collider, shape)

signal update_num_enemies_left(num_enemies)

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

signal few_enemies

signal disable_music

signal weapon_fire_recoil(recoil_amount, snap_amount, recoil_speed)

#signal kill_projectile

var current_difficulty = 1

var player_save = null
