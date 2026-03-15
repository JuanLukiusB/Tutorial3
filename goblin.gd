extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0
const CHASE_DISTANCE = 300.0
const ATTACK_DISTANCE = 50.0
const KNOCKBACK_FORCE = Vector2(300, -200)

var is_attacking = false
var is_hurt = false
var health = 2
var player = null

@onready var anim = $AnimatedSprite2D

func _ready():
	add_to_group("enemy")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		player = get_parent().get_node_or_null("Player")

func _process(_delta):
	if is_hurt or health <= 0:
		return
	if velocity.x < 0:
		anim.flip_h = true
	elif velocity.x > 0:
		anim.flip_h = false

	if is_attacking:
		anim.play("Attack")
	elif velocity.x != 0:
		anim.play("Chase")
	else:
		anim.play("Idle")

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_hurt or health <= 0:
		move_and_slide()
		return

	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	if player and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		
		if distance < ATTACK_DISTANCE:
			attack()
		elif distance < CHASE_DISTANCE:
			var direction = sign(player.global_position.x - global_position.x)
			if direction != 0:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func attack():
	if is_attacking: return
	is_attacking = true
	
	var direction = sign(player.global_position.x - global_position.x)
	var kb_dir = direction
	if kb_dir == 0: kb_dir = 1
	var force = Vector2(KNOCKBACK_FORCE.x * kb_dir, KNOCKBACK_FORCE.y)
	
	if player.has_method("take_damage"):
		player.take_damage(force)
	get_tree().create_timer(1.0).timeout.connect(func(): is_attacking = false)

func take_damage(knockback_force: Vector2):
	if is_hurt or health <= 0: return
	health -= 1
	if health <= 0:
		queue_free()
		return
		
	is_hurt = true
	velocity = knockback_force
	is_attacking = false
	get_tree().create_timer(0.5).timeout.connect(func(): is_hurt = false)
