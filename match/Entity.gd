extends Control

@export var color: String
@export var counter: int


func _init(initial_color = "random"):
	if initial_color == "random":
		color = Colors.random()
	elif initial_color == "random_character":
		color = Colors.random(true)
	else:
		color = initial_color


func set_color(new_color):
	color = new_color
	return self


func set_counter(new_counter: int):
	counter = new_counter
	$counter.text = str(counter)
	return self


func move(target: Vector2, time = 0.3):
	var tween = self.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target, time)
	tween.play()


func animate(animation_name: String):
	$sprite.play(animation_name)


func _on_sprite_animation_finished():
	$sprite.play("idle")
