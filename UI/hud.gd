extends Control

# Initialize your HUD weapon list with node references correctly
var hud_wep_list = [
	{
		"w_text": $Wep1/w_text,
		"mag_text": $Wep1/Mag,
		"reserve_text": $Wep1/Reserve
	},
	{
		"w_text": $Wep2/w_text,
		"mag_text": $Wep2/Mag,
		"reserve_text": $Wep2/Reserve
	}
]


func hud_initialize(weapons: Array, weapon_list: Dictionary):
	for i in range(len(weapons)):
		var wep_obj = weapon_list[weapons[i]]
		var cur_weapon = $weapons_info.get_child(i)
		
		cur_weapon.get_child(1).text = wep_obj.Wep_Name
		
		cur_weapon.get_child(2).text = str(wep_obj.Curr_Mag_Ammo)
		
		if wep_obj.Reserve_Ammo != 0:
			cur_weapon.get_child(4).text = str(wep_obj.Reserve_Ammo)
		else:
			cur_weapon.get_child(4).text = ""
			
func hud_initialize_player(shield, health):
	var shield_string = str(shield)
	var health_string = str(health)
	$player_info/shield/shield_amount.text = shield_string
	$player_info/health/health_amount.text = health_string
			
func update_ammo(mag: int, reserve: int, weapon_indicator: int):
	var cur_weapon = $weapons_info.get_child(weapon_indicator)
	cur_weapon.get_child(2).text = str(mag)
	cur_weapon.get_child(4).text = str(reserve)
	
		
func update_weapon_indicator(weapon_indicator: int):
	var cur_weapon = $weapons_info.get_child(weapon_indicator)
	var other_weapon = $weapons_info.get_child(!weapon_indicator)
	
	cur_weapon.get_child(0).show()
	other_weapon.get_child(0).hide()
		
func update_pickup_weapon_name(weapon_name: String, weapon_indicator: int):
	var cur_weapon = $weapons_info.get_child(weapon_indicator)
	cur_weapon.get_child(1).text = weapon_name
	
	
func update_shield_and_health(new_shield_amount: int, new_health_amount: int):
	var n_s_amount = str(new_shield_amount)
	var n_h_amount = str(new_health_amount)
	$player_info/shield/shield_amount.text = n_s_amount
	$player_info/health/health_amount.text = n_h_amount
	
	
	
