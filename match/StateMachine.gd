extends Node2D

var switch: Callable
var current_state = 0
var next_state = 0
var default_wait_time = 0.5


func set_handler(switch_function, wait_time = default_wait_time):
	switch = switch_function
	default_wait_time = wait_time


# Executes the passed state immediately
func do(state = next_state):
	$timer.stop()
	current_state = state
	switch.call(current_state)


# Queues up a state after the timer
func next(state, wait_time = default_wait_time):
	next_state = state
	$timer.start(wait_time)


func _on_timer_timeout():
	do()
