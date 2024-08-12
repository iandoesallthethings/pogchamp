extends Node3D
var Pog = preload("res://pogs/Pog.tscn")

signal pogs_done

@onready var rng = RandomNumberGenerator.new()
@onready var pogs = []
@onready var slammer = Pog.instantiate().with_mass(20).with_shape(Vector2(0.5, 0.25))

var flipped_pogs = 0


func _process(_delta):
	var new_flipped_pogs = pogs.filter(func(pog): return pog.flipped).size()

	if new_flipped_pogs != flipped_pogs:
		$MovementTimer.start_or_boost()

	flipped_pogs = new_flipped_pogs

	$Score.text = str(flipped_pogs) if not $MovementTimer.is_stopped() else ""


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
	if pogs.size() == 0:
		return

	if slammer.get_parent() == self:
		remove_child(slammer)

	var offset = random_offset(0.5)
	var velocity = Vector3(0, -30, 0)

	slammer.reset().with_offset(offset).with_velocity(velocity)

	add_child(slammer)
	if $MovementTimer.is_stopped():
		$MovementTimer.start_or_boost()


func drop_pog(offset = Vector3(0, 0, 0)):
	var new_pog = Pog.instantiate().reset().with_offset(offset)

	pogs.append(new_pog)
	add_child(new_pog)


func destroy_pogs():
	remove_child(slammer)
	for pog in pogs:
		pog.queue_free()
	pogs.clear()


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


func _on_movement_timer_timeout():
	destroy_pogs()
	print("Scored " + str(flipped_pogs) + " pogs!")
	flipped_pogs = 0
	pogs_done.emit()
