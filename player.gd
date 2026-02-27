extends CharacterBody2D

var jumped = false
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var anim = $AnimatedSprite2D


func _process(delta):
	if velocity.x < 0:
		anim.flip_h = true 
	elif velocity.x > 0:
		anim.flip_h = false 
func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumped = false;
	if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and jumped == false:
		velocity.y = JUMP_VELOCITY
		jumped = true

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
