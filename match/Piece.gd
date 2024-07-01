extends "res://match/Entity.gd"

var matched = false


func _ready():
	$sprite.set_texture(Colors.pieces[color])


func set_color(new_color = "random"):
	super(new_color)
	$sprite.set_texture(Colors.pieces[self.color])
	return self


func set_matched():
	matched = true
	$sprite.modulate = Color(1, 1, 1, .5)


func clear_matched():
	matched = false
	$sprite.modulate = Color(1, 1, 1, 1)
