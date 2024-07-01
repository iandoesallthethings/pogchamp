extends Node3D
var Pog = preload("res://pogs/Pog.tscn")

signal pogs_done

@onready var rng = RandomNumberGenerator.new()
@onready var pogs = []
@onready var slammer = Pog.instantiate().with_mass(20).with_shape(Vector2(0.5, 0.25))


func _process(_delta):
	var flipped_pogs = pogs.filter(func(pog): return pog.flipped).size()

	$Score.text = str(flipped_pogs) if flipped_pogs > 0 else ""


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_S:  # Stack
				drop_pog(random_offset())
			KEY_SPACE:
				drop_slammer()
			KEY_ESCAPE:
				destroy_pogs()
				pogs_done.emit()


func drop_slammer():
	if slammer.get_parent() == self:
		remove_child(slammer)

	var offset = random_offset(0.5)
	var velocity = Vector3(0, -30, 0)

	slammer.reset().with_offset(offset).with_velocity(velocity)

	add_child(slammer)


func drop_pog(offset = Vector3(0, 0, 0)):
	var new_pog = Pog.instantiate().reset().with_offset(offset)

	pogs.append(new_pog)
	add_child(new_pog)


func destroy_pogs():
	for pog in pogs:
		pog.queue_free()
	pogs.clear()
	remove_child(slammer)


func _on_board_piece_destroyed(_color: String):
	var new_pog = Pog.instantiate()
	pogs.append(new_pog)


func _on_board_resolved():
	for i in pogs.size():
		var offset = random_offset() + Vector3(0, 0.1 * i, 0)
		drop_pog(offset)


func random_offset(width: float = 0.05) -> Vector3:
	return Vector3(
		rng.randf_range(-width, width),
		rng.randf_range(-width, width),
		rng.randf_range(-width, width)
	)
