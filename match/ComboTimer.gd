extends Timer

@export var max_time = 3
@export var boost_time = 0.5
@export var delay = 0.0


func _ready():
	pass


func _process(_delta):
	if time_left < max_time - delay:
		$meter.value = ((time_left) / (max_time - delay)) * 100
	else:
		$meter.value = 0


func start_or_boost():
	if is_stopped():
		start(max_time)
	else:
		boost()


func boost():
	var new_time = min(time_left + boost_time, max_time)
	start(new_time)
