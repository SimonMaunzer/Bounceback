extends Timer

var _label: Label


func _ready() -> void:

	var layer := CanvasLayer.new()
	add_child(layer)

	_label = Label.new()
	_label.position = Vector2(20, 10)
	_label.add_theme_font_size_override("font_size", 48)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 10)
	_label.text = str(ceili(wait_time))
	layer.add_child(_label)


	one_shot = true
	timeout.connect(_on_timer_timeout)


func _process(_delta: float) -> void:
	if not is_stopped():
		_label.text = str(ceili(time_left))


func _on_timer_timeout() -> void:
	_label.text = "Time is up"
	print("Time is up")
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()
