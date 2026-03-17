extends CharacterBody2D
class_name Enemy_basic

var player
@export var id = ""
@export var health : int = 3
const grav = 840
var cur_grav = 0
var damaged = false
var reciving_damage = true
@export var health_bar : TextureProgressBar


enum states {ZZZ, ATTACKING , MOVING , DAMAGING}
var current_state : int = states.ZZZ
@export var sprite : Sprite2D
var hitted_count : int = 0

@export var apply_moveing = true
@export var apply_grav = true


@export var attack_damage : int = 1
@export var attack_force : float = 75

@onready var damage_timer := Timer.new()
@export var damage_time : float = 0.2

func _ready() -> void:
	id = name
	cur_grav = grav
	player = get_tree().get_first_node_in_group("player")
	
	add_child(damage_timer)
	damage_timer.one_shot = true
	damage_timer.wait_time = damage_time
	damage_timer.timeout.connect(Callable(self,"damage_end"))
	
	if health_bar:
		health_bar.max_value = health
		health_bar.visible = false


func _physics_process(delta: float) -> void:
	if player:
		if apply_moveing:
			if apply_grav:
				velocity.y += cur_grav * delta
			move_and_slide()
	else:
		push_error("player unassigned")
	


func take_damage(val , force , dir):
	if reciving_damage:
		current_state = states.DAMAGING
		health -= val
		velocity = force * dir
		reciving_damage = false
		damage_timer.start()

func damage_end():
	velocity = Vector2.ZERO
	current_state = states.MOVING
	reciving_damage = true
