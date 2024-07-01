extends RigidBody3D

var flipped = false


func _process(_delta):
	var up = Vector3.UP
	var normal = transform.basis.y

	var is_above_floor = position.y > -0.5

	flipped = is_above_floor and (normal.angle_to(up) > PI / 2)

	if flipped:
		$FlippedLabel.visible = true
	else:
		$FlippedLabel.visible = false


func reset():
	self.position = Vector3(0, 5, 0)
	self.rotation = Vector3(0, 0, 0)
	self.linear_velocity = Vector3(0, 0, 0)
	self.angular_velocity = Vector3(0, 0, 0)
	return self


func with_mass(new_mass = 1):
	self.mass = new_mass
	return self


func with_shape(shape: Vector2 = Vector2(0.5, 0.05)):
	$Mesh.mesh.top_radius = shape.x
	$Mesh.mesh.bottom_radius = shape.x
	$Mesh.mesh.height = shape.y

	$Collision.shape.radius = shape.x
	$Collision.shape.height = shape.y
	return self


func with_offset(offset = Vector3(0, 0, 0)):
	self.position = self.position + offset
	return self


func with_velocity(velocity = Vector3(0, 0, 0)):
	self.linear_velocity = velocity
	return self
