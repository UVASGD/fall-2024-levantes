extends Resource


class_name Weapon_Resource

@export var Wep_Name: String
@export var Wep_Display_Name: String
@export var Equip_Ani: String
@export var Fire_Ani: String
@export var Reload_Ani: String
@export var Dequip_Ani: String
@export var Wait_Ani: String

@export var Fire_Sound: String

@export var Curr_Mag_Ammo: int
@export var Reserve_Ammo: int
@export var Max_Mag_Capacity: int
@export var Max_Ammo: int

@export var Fire_Mode: String
@export var Burst_Count: int
@export var Wait_Interval: float
@export var Is_Waiting: bool
@export var Is_Reloading: bool

@export_flags("HitScan","Projectile") var Type
@export var Projectile_Range: float
@export var dmg: int

@export var Weapon_Drop: PackedScene

@export var ray_path: String
@export var light_path: String
