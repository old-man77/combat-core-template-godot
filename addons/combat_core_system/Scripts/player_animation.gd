extends "res://addons/combat_core_system/Scripts/player.gd"

@onready var animation_player = $AnimationPlayer
@onready var animator = $AnimationTree
@export var attack_animations : Array[String] = []
@export var damage_animations : Array[String] = []

func _ready() -> void:
	animator.active = true
	my_node.attackd.connect(Callable(self,"play_attack_animations"))
	my_node.combo_end.connect(Callable(self,"reset_anim"))
	damaged.connect(Callable(self,"damage_animation"))
	
	super()
	

func _process(delta: float) -> void:
	animating()


func animating():
	animator.set("parameters/conditions/run",inputs.x != 0 && is_on_floor())
	animator.set("parameters/conditions/!run",inputs.x == 0 && is_on_floor())
	animator.set("parameters/conditions/jump",Input.is_action_just_pressed("jump") )
	animator.set("parameters/conditions/double_jump",jump_count > 1)
	animator.set("parameters/conditions/falling",velocity.y > 10)
	animator.set("parameters/conditions/hitted_ground",is_on_floor())


func damage_animation():
	animator.active = false
	animation_player.play(damage_animations[randi() % damage_animations.size()])


func play_attack_animations():
	animator.active = false
	animation_player.play(attack_animations[my_node.attack_times % attack_animations.size()])

func reset_anim():
	animator.active = true
