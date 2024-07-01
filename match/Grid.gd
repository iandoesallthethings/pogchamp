extends Control

@export var width: int = 7
@export var height: int = 5
@export var cell_size: float = 128

signal swipe_start(space: Vector2i)
signal swipe_end(start: Vector2i, direction: Vector2i, end: Vector2i)
signal tap(space: Vector2i)

var board = []
var touch_start = Vector2i(0, 0)
var touch_end = Vector2i(0, 0)
var swiping = false

var x_offset = cell_size / 2
var y_offset = (height * cell_size) - (cell_size / 2)


func _ready():
	x_offset = cell_size / 2
	y_offset = (height * cell_size) - (cell_size / 2)

	initialize_board()


func _process(_delta):
	handle_touch()


func initialize_board():
	board = []
	for column in width:
		board.append([])
		for row in height:
			board[column].append(null)


func handle_touch():
	if Input.is_action_just_pressed("ui_touch"):
		var mouse = get_local_mouse_position()
		var space = pixel_to_grid(mouse)
		touch_start = space
		swiping = true
		swipe_start.emit(touch_start)
	if Input.is_action_just_released("ui_touch"):
		if swiping:
			touch_end = pixel_to_grid(get_local_mouse_position())
			var direction = normalized_direction(touch_start, touch_end)
			if direction == Vector2i(0, 0):
				tap.emit(touch_end)
			else:
				swipe_end.emit(touch_start, direction, touch_end)
		swiping = false  # Always cancel control on release just in case


# CRUD
func get_entity_at(space: Vector2i):
	if is_in_grid(space):
		return board[space.x][space.y]


func add_entity_at(entity, space: Vector2i):
	if is_in_grid(space):
		board[space.x][space.y] = entity

		entity.position = Vector2(grid_to_pixel(space).x, -height * cell_size)  # so it drops in.

		add_child(entity)
		move_entity_to(entity, space)  # In case we set an initial position


func move_entity_to(entity, space: Vector2i, empty_previous: bool = true):
	if entity != null && is_in_grid(space):
		if empty_previous:
			empty_space(pixel_to_grid(entity.position))
		board[space.x][space.y] = entity
		entity.move(grid_to_pixel(space))


func swap_entities(space1: Vector2i, space2: Vector2i):
	if is_in_grid(space1) && is_in_grid(space2):
		var entity1 = get_entity_at(space1)
		var entity2 = get_entity_at(space2)
		move_entity_to(entity1, space2, false)
		move_entity_to(entity2, space1, false)


func destroy_entity_at(space: Vector2i):
	if is_in_grid(space):
		var entity = get_entity_at(space)
		if entity != null:
			entity.queue_free()
		empty_space(space)


func empty_space(space: Vector2i):
	if is_in_grid(space):
		board[space.x][space.y] = null


func destroy_all():
	for column in width:
		for row in height:
			destroy_entity_at(Vector2i(column, row))


func is_empty():
	for column in width:
		for row in height:
			if get_entity_at(Vector2i(column, row)) != null:
				return false
	return true


# Grid Helpers
func for_each(callback: Callable):
	for column in width:
		for row in height:
			var space = Vector2i(column, row)
			var entity = get_entity_at(space)
			callback.call(space, entity)


func is_in_grid(space: Vector2i):
	if space.x >= 0 && space.x < width:
		if space.y >= 0 && space.y < height:
			return true
	return false


func grid_to_pixel(space: Vector2i):
	var x = (space.x * cell_size) + x_offset
	var y = (space.y * -cell_size) + y_offset
	return Vector2(x, y)


func pixel_to_grid(point: Vector2):
	var column = round((point.x - x_offset) / cell_size)
	var row = round((point.y - y_offset) / -cell_size)
	return Vector2i(column, row)


func normalized_direction(start: Vector2i, end: Vector2i):
	var difference = end - start
	return Vector2i(sign(difference.x), sign(difference.y))


# Note: Y is inverted
const LEFT = Vector2i(-1, 0)
const RIGHT = Vector2i(1, 0)
const DOWN = Vector2i(0, -1)
const UP = Vector2i(0, 1)
const HORIZONTAL = [LEFT, RIGHT]
const VERTICAL = [UP, DOWN]
