class_name Spark extends CPUParticles3D

var impactpoint
# Called when the node enters the scene tree for the first time.
func _ready():
	self.direction = self.direction.bounce(impactpoint.normalized())
	var sphere = SphereMesh.new()
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(255,100,0)
	mat.emission_enabled = true
	mat.emission = Color(255,100,0)
	mat.emission_energy_multiplier = 2
	mat.backlight_enabled = true
	mat.backlight = Color(255,100,0)
	sphere.set_height(0.01)
	sphere.set_radius(0.01)
	sphere.material = mat
	self.explosiveness = 0.5
	self.lifetime = 0.25
	self.mesh = sphere
	self.amount = 3
	self.local_coords = true
	self.draw_order = CPUParticles3D.DRAW_ORDER_VIEW_DEPTH
	self.initial_velocity_max = 20
	self.initial_velocity_min = 10
	self.scale_amount_max = 2
	self.scale_amount_min = 0.5
	self.one_shot = true
	self.emitting = true
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
