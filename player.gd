extends CharacterBody2D

var jumped = false
var is_punching = false
var is_hurt = false
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var anim = $AnimatedSprite2D

func _process(_delta):
	if is_hurt:
		return
	if is_punching:
		return
		
	if velocity.x < 0:
		anim.flip_h = true 
	elif velocity.x > 0:
		anim.flip_h = false 
		
	if is_on_floor():
		if velocity.x == 0:
			anim.play("idle")
		else:
			anim.play("walk")
	else:
		anim.play("jump")

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_hurt:
		move_and_slide()
		return
		
	if is_punching:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumped = false
	if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and jumped == false:
		velocity.y = JUMP_VELOCITY
		jumped = true

	if Input.is_action_just_pressed("ui_down") and is_on_floor() and not is_punching:
		is_punching = true
		anim.play("punch")
		deal_damage_to_enemies()
		get_tree().create_timer(0.4).timeout.connect(func(): is_punching = false)

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func take_damage(knockback_force: Vector2):
	if is_hurt: return
	is_hurt = true
	velocity = knockback_force
	is_punching = false
	get_tree().create_timer(0.5).timeout.connect(func(): is_hurt = false)

func deal_damage_to_enemies():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if is_instance_valid(enemy) and global_position.distance_to(enemy.global_position) < 60.0:
			var direction = -1 if anim.flip_h else 1
			var enemy_direction = sign(enemy.global_position.x - global_position.x)
			if enemy_direction == direction or enemy_direction == 0:
				var force = Vector2(300 * direction, -200)
				if enemy.has_method("take_damage"):
					enemy.take_damage(force)
