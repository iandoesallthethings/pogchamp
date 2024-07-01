extends Node

var pieces = {
	"blue": preload("res://textures/pieces/blue.png"),
	"gray": preload("res://textures/pieces/gray.png"),
	"green": preload("res://textures/pieces/green.png"),
	"orange": preload("res://textures/pieces/orange.png"),
	"pink": preload("res://textures/pieces/pink.png"),
	"rainbow": preload("res://textures/pieces/rainbow.png"),
	# "yellow": preload("res://textures/pieces/yellow.png"),
}

var names = pieces.keys()

var not_allowed_for_characters = [
	"rainbow",
	"gray",
]

var names_for_characters = pieces.keys().filter(func(n): return n not in not_allowed_for_characters)


func random(for_character = false):
	if for_character:
		var index = randi() % names_for_characters.size()
		return names_for_characters[index]
	else:
		var index = randi() % names.size()
		return names[index]
