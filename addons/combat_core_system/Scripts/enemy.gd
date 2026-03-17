extends Enemy_basic

var facing_dir 
@export var max_speed : int
@export var inc_speed : float
@export var dec_speed : float
var current_speed : float = 0
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@export var my_node : Node2D


@export var before_attack_near_time : float
var player_near = false
var near_time : float = 0
@onready var hit_collision = $my_node/hit_collision/CollisionShape2D

var damage_animations : Array[String] = ["damage1","damage2"]

func _physics_process(delta: float) -> void:
	super(delta)
	
	
	if current_state != states.ATTACKING && current_state !=  states.DAMAGING:
		facing_dir = 1 if global_position.x < player.global_position.x else -1
		hit_collision.disabled = true
	my_node.scale.x = facing_dir
	
	
	if current_state != states.ZZZ && current_state != states.DAMAGING:
		movement(delta)
	
	
	if player_near && current_state != states.ATTACKING && current_state != states.DAMAGING:
		near_time += delta
	
	if near_time > before_attack_near_time:
		attack()
		near_time = 0
	
	if current_state == states.DAMAGING:
		if animation_player.current_animation not in damage_animations:
			animation_player.play(damage_animations[randi() % damage_animations.size()])
	
	
	


func movement(delta):
	
	if current_state == states.MOVING && !player_near:
		var target_speed = max_speed * facing_dir
		current_speed = move_toward(current_speed , target_speed , inc_speed )
		animation_player.play("run")
	else:
		current_speed = move_toward(current_speed , 0 , dec_speed )
		if current_state != states.ATTACKING:
			animation_player.play("idle")
	
	velocity.x = current_speed


func attack():
	current_state = states.ATTACKING
	animation_player.play("attack")
	await animation_player.animation_finished
	if current_state == states.ATTACKING:
		current_state = states.MOVING
	


func attack_for():
	if global_position.distance_to(player.global_position) > 25:
		global_position.x += 10 * facing_dir
	elif global_position.distance_to(player.global_position) < 17:
		global_position.x -= 10 * facing_dir


func _on_trigger_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if current_state == states.ZZZ:
			animation_player.play("triggered")
			await animation_player.animation_finished
			current_state = states.MOVING
	

func _on_near_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true


func _on_near_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = false


func _on_hit_collision_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var dir = Vector2(facing_dir,0)
		player.take_damage(attack_damage,attack_force,dir)
