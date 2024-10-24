extends RigidBody3D

var health = 5

func got_hit(dmg):
	health -= dmg
	print("Health: " + str(health))
	if health <= 0:
		queue_free()
