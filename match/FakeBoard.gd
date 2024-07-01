extends Node2D

signal add_pogs(number: int)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


func _on_button_pressed():
	var pog_slider = self.find_child("Bar")

	add_pogs.emit(pog_slider.value)
