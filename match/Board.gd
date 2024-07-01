extends Control

var Piece = preload("res://match/Piece.tscn")

signal piece_destroyed(color: String)
signal resolved

var block_input = false
var matches = 0

enum State {
	Matching, # Idle, waiting for input
	Checking,
	Destroying,
	Collapsing,
	Refilling,
}


func _ready():
	randomize()  # Seed RNG
	fill_board()
	$state.set_handler(do)


func _on_grid_swipe_end(start, direction, _end):
	if !block_input:
		try_swap_pieces(start, direction)


func _on_combo_timer_timeout():
	end_combo()

func _on_game_pogs_done():
	$state.do(State.Matching)

func do(state):
	match state:
		State.Matching:
			ready_to_match()

		State.Checking:
			block_input = true
			mark_matches()
			if matches > 0:
				$state.next(State.Destroying) 
			else: 
				hide_and_wait()
				# $state.next(State.Matching) # Go back to emit once we have a signal from the game

		State.Destroying:
			destroy_matches()
			$state.next(State.Collapsing)

		State.Collapsing:
			collapse_columns()
			$state.next(State.Refilling)

		State.Refilling:
			refill()
			$state.next(State.Checking)


func fill_board():
	$grid.for_each(func(space, _piece): set_random_piece_at(space))


func set_random_piece_at(space: Vector2i, avoid_matches: bool = true):
	var piece = Piece.instantiate()
	if avoid_matches:
		var loops = 0
		while match_at(space, piece.color) && loops < 100:
			piece = Piece.instantiate()
			loops += 1
	$grid.add_entity_at(piece, space)


func try_swap_pieces(start: Vector2i, direction: Vector2i):
	var end = start + direction
	var invalid_move = (direction == Vector2i(0,0) || !can_be_moved(start) || !can_be_moved(end))
	if invalid_move: return

	$grid.swap_entities(start, end)

	if match_at(start) || match_at(end):
		mark_matches()
		$combo_timer.start_or_boost()
	elif $combo_timer.is_stopped():
		$grid.swap_entities(start, end)
	else:
		end_combo()


func can_be_moved(space: Vector2i):
	var piece = $grid.get_entity_at(space)
	return piece != null && !piece.matched


func mark_matches():
	matches = 0
	var mark = func(space, piece):
		if piece == null: 
			return
		if match_at(space): 
			piece.set_matched()
		else: 
			piece.clear_matched()
		if piece.matched: 
			matches += 1
	$grid.for_each(mark)


func match_at(space: Vector2i, color = null) -> bool:
	# If the default above doesn't work, just do this instead:
	var piece = $grid.get_entity_at(space)
	if piece != null && !color:
		color = piece.color
	if color == null:
		return false

	for orientation in [$grid.HORIZONTAL, $grid.VERTICAL]:
		var matched = 1
		for direction in orientation:
			for offset in [1, 2]:
				var space_to_check = space + direction * offset
				var adjacent_piece = $grid.get_entity_at(space_to_check)
				if adjacent_piece != null && adjacent_piece.color == color:
					matched += 1
					if matched == 3:
						return true
				else:
					break
	return false


var original_position = self.position

func ready_to_match():
	move(original_position)
	block_input = false

func hide_and_wait():
	original_position = self.position
	move(Vector2(0, 1000))
	resolved.emit()


func end_combo():
	$combo_timer.stop()
	$state.do(State.Checking)


func destroy_matches():
	var destroy = func(space, piece):
		if piece != null && piece.matched:
			$grid.destroy_entity_at(space)
			piece_destroyed.emit(piece.color)
	$grid.for_each(destroy)


func collapse_columns():
	var collapse = func(space, piece):
		if piece != null: return
		for row_above in range(space.y + 1, $grid.height):
			var piece_above = $grid.get_entity_at(Vector2i(space.x, row_above))
			if piece_above != null:
				$grid.move_entity_to(piece_above, space)
				break
	$grid.for_each(collapse)


func refill():
	var fill = func(space, piece):
		if piece == null: 
			set_random_piece_at(space)
	$grid.for_each(fill)



func move(target: Vector2, time = 0.3):
	var tween = self.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target, time)
	tween.play()
