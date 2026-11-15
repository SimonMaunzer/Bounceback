extends CharacterBody2D
## Der Pilz: laufen, springen, Schwerkraft und Animation.
## Steuerung: A/D oder Pfeiltasten = laufen, Leertaste/W/Pfeil hoch = springen.
## Der Ursprung (0, 0) des Pilzes liegt an seinen Füßen.

@export_group("Laufen")
## Höchsttempo in Pixel pro Sekunde
@export var speed: float = 130.0
## Wie schnell der Pilz auf Tempo kommt
@export var acceleration: float = 1000.0
## Wie schnell der Pilz abbremst
@export var friction: float = 1400.0

@export_group("Springen")
## Sprunghöhe in Pixel (Taste gedrückt halten)
@export var jump_height: float = 72.0
## Sekunden bis zum höchsten Punkt
@export var jump_time: float = 0.38
## Fallen ist schneller als Steigen (fühlt sich knackiger an)
@export var fall_multiplier: float = 1.6
@export var max_fall_speed: float = 480.0
## So lange darf man nach dem Verlassen einer Kante noch abspringen
@export var coyote_time: float = 0.1
## So früh vor der Landung darf man schon Springen drücken
@export var jump_buffer_time: float = 0.12

@export_group("Absturz")
## Unterhalb dieser Höhe springt der Pilz zurück zum Startpunkt
@export var fall_limit_y: float = 1500.0

var _start_position: Vector2
var _coyote: float = 0.0
var _jump_buffer: float = 0.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_setup_input()
	_start_position = global_position
	_sprite.play(&"idle")


func _physics_process(delta: float) -> void:
	# Aus Sprunghöhe und Sprungzeit ergeben sich Schwerkraft und Absprungtempo
	var gravity: float = 2.0 * jump_height / (jump_time * jump_time)
	var jump_velocity: float = -2.0 * jump_height / jump_time

	# Schwerkraft
	if not is_on_floor():
		var g: float = gravity * (fall_multiplier if velocity.y > 0.0 else 1.0)
		velocity.y = minf(velocity.y + g * delta, max_fall_speed)

	# Kleine Hilfen, damit sich Springen gut anfühlt
	_coyote = coyote_time if is_on_floor() else _coyote - delta
	_jump_buffer -= delta
	if Input.is_action_just_pressed(&"jump"):
		_jump_buffer = jump_buffer_time

	# Springen
	if _jump_buffer > 0.0 and _coyote > 0.0:
		velocity.y = jump_velocity
		_jump_buffer = 0.0
		_coyote = 0.0
	# Taste früh loslassen = kleiner Sprung
	if velocity.y < 0.0 and Input.is_action_just_released(&"jump"):
		velocity.y *= 0.45

	# Laufen
	var direction: float = Input.get_axis(&"move_left", &"move_right")
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	move_and_slide()

	# Aus der Welt gefallen -> zurück zum Start
	if global_position.y > fall_limit_y:
		global_position = _start_position
		velocity = Vector2.ZERO

	_update_animation(direction)


func _update_animation(direction: float) -> void:
	# Die Grafik schaut von sich aus nach links
	if direction != 0.0:
		_sprite.flip_h = direction > 0.0

	if not is_on_floor():
		# Es gibt keine Sprung-Grafik, also ein Bild aus "run" einfrieren
		_sprite.animation = &"run"
		_sprite.pause()
		_sprite.frame = 2
	elif absf(velocity.x) > 10.0:
		_sprite.play(&"run")
	else:
		_sprite.play(&"idle")


## Legt die Tasten fest. So muss nichts in den Projekteinstellungen stehen.
func _setup_input() -> void:
	_add_action(&"move_left", [KEY_A, KEY_LEFT])
	_add_action(&"move_right", [KEY_D, KEY_RIGHT])
	_add_action(&"jump", [KEY_SPACE, KEY_W, KEY_UP])


func _add_action(action: StringName, keys: Array) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for key: Key in keys:
		var key_event := InputEventKey.new()
		key_event.physical_keycode = key
		InputMap.action_add_event(action, key_event)
