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


func hud_initialize(weapons: Array):
	for i in range(len(weapons)):
		if weapons[i] != null:
			var cur_weapon = $weapons_info.get_child(i)
			
			cur_weapon.get_child(1).text = weapons[i].Display_Name
			
			cur_weapon.get_child(2).text = str(weapons[i].Curr_Mag_Ammo)
			
			if weapons[i].Reserve_Ammo != 0:
				cur_weapon.get_child(4).text = str(weapons[i].Reserve_Ammo)
			else:
				cur_weapon.get_child(4).text = "0"
			
func hud_initialize_player(shield, health):
	var shield_string = str(shield)
	var health_string = str(health)
	$player_info/shield/shield_amount.text = shield_string
	$player_info/health/health_amount.text = health_string
			
func update_ammo(mag: int):
	var cur_weapon = $weapons_info.get_child(0)
	cur_weapon.get_child(2).text = str(mag)
	
		
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
	
func update_shop_weapon_name(shop_wep_name: String, cost: int):
	$shop_weapon_name.text = shop_wep_name
	if cost != 0:
		$cost.text = "Price: " + str(cost)
	else:
		$cost.text = ""
	
func _input(event):
	if event.is_action_pressed("disable_hud"):
		$".".visible = !$".".visible
