extends Node3D

func _ready():
	add_static_collisions(self)

func add_static_collisions(node):
	for child in node.get_children():
		if child is MeshInstance3D:
			var static_body = StaticBody3D.new()
			var collision_shape = CollisionShape3D.new()
			var shape = child.mesh.create_trimesh_shape()
			collision_shape.shape = shape
			static_body.add_child(collision_shape)
			static_body.transform = child.transform
			node.add_child(static_body)
		elif child is Node3D:
			add_static_collisions(child)
