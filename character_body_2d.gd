extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var _sprite: AnimatedSprite2D = $"Sprite Player"

func _physics_process(delta):

	
	
	if not is_on_floor():
		velocity.y += (gravity -10) * delta + -10
		
	

	

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = jump_velocity

	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed
	if velocity.x != 0 and  is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()


	if direction < 0:
		_sprite.flip_h = true
	elif direction > 0:
		_sprite.flip_h = false

	# Animation
	if direction != 0:
		_sprite.play("run")
	else:
		_sprite.play("idle")
