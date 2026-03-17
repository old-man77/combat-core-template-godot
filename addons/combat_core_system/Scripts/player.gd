extends CharacterBody2D

enum states {MOVING , ATTACKING , DAMAGING}
var current_state = states.MOVING
@export var health : int = 5 

@export var my_node : Node2D 
@export var attack_col : Area2D

@export_category("Speed")
@export var max_speed_val = 125
@export var attack_max_speed_val = 45
@export var inc_speed : float = 5
@export var dec_speed: float = 5
var max_speed = 125
@export var attack_dash : float = 8

@export_category("grav & jump")
@export var grav = 500
@export var jump_force : float = -200
@export var attack_grav_scale := 2.5

var inputs : Vector2
var can_move = true
var apply_grav = true
var current_speed : float
var facing_direction : int = 1


var current_grav : float
var can_jump : bool = true
var jump_count : int = 0


@export_category("coyte jump")
var have_coyote: bool = true
@export var coyte_jump_time = 0.15
var coyote_jump_timer : Timer = Timer.new()

@export_category("damage")
var damdge_timer : Timer = Timer.new()
@export var damdge_time :float = 0.2 


signal damaged
signal attackd(position)



func _ready() -> void:
	
	##-----SETTING CURRENT GRAV----#####
	current_grav = grav
	
	##--------SETTING COYTE & DAMDGE TIMERS-------#########
	coyote_jump_timer.one_shot = true
	coyote_jump_timer.wait_time = coyte_jump_time
	add_child(coyote_jump_timer)
	
	damdge_timer.one_shot = true
	damdge_timer.wait_time = damdge_time
	add_child(damdge_timer)
	damdge_timer.timeout.connect(Callable(self,"damage_end"))
	damdge_timer.timeout.connect(Callable(self,"reset_anim"))

	
	####------ COMBO SIGNALS CONNECT ----- ######
	my_node.attackd.connect(Callable(self,"changing_to_attack_state"))
	my_node.combo_end.connect(Callable(self,"changing_to_normal_state"))
	
	attackd.connect(Callable(self,"attack_effects"))
	
	


func _physics_process(delta: float) -> void:
	
	
	#####------ FLIP & CHANGING FACING DIRECTION ---- #######
	if Input.is_action_just_pressed("right"):
		facing_direction = 1
	elif Input.is_action_just_pressed("left"):
		facing_direction = -1
		
	my_node.scale.x = facing_direction
	
	
	### MATCHING & ASSIGNING PLAYER STATES 
	match current_state:
		states.ATTACKING:
			max_speed = attack_max_speed_val
			can_jump = false
			current_grav = grav/attack_grav_scale
			movement(delta)
		states.MOVING:
			max_speed = max_speed_val
			
			movement(delta)
			
	
	
	
	move_and_slide()


func movement(delta):
	inputs = Vector2(Input.get_axis("left",'right'),Input.get_axis("up","down"))
	
	####----- FIXING CONTROLLER ANALOG INPUT ----- #######
	if abs(inputs.x) > 0.01:
		inputs.x = sign(inputs.x)
	if abs(inputs.y) > 0.01:
		inputs.y = sign(inputs.y)
	
	
	####-------APPLY GRAV IF NOT ON FLOOR ------########
	if apply_grav:
		if !is_on_floor():
			velocity.y += current_grav * delta
		else :
			velocity.y = 0
			have_coyote = true
			jump_count = 0 
	
	
	####------- MOVEING LEFT & RIGHT------########
	if can_move:
		var target_speed = max_speed * inputs.x
		var acc_rate = inc_speed if inputs.x != 0 else  dec_speed
		current_speed = move_toward(current_speed , target_speed , acc_rate )
		velocity.x = current_speed  
	
	
	##--------- APPLY JUMPING -------- #########
	jumping()

func jumping():
	####-------SETTING JUMP COYTE ------########
	if !is_on_floor():
		if have_coyote:
			coyote_jump_timer.start()
			have_coyote = false

	
	####------- SETTING JUMPING & DOUBLE JUMP------########
	if can_jump:
		if jump_count == 0:
			if Input.is_action_just_pressed("jump") && (is_on_floor() or !coyote_jump_timer.is_stopped()): 
				velocity.y = jump_force
				jump_count += 1 
		elif jump_count > 0 && jump_count < 2:
			if Input.is_action_just_pressed("jump"):
				velocity.y = jump_force
				jump_count += 1 


func _on_hit_col_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		var dir = Vector2(facing_direction,0)
		var damdge_val = my_node.current_weapon.damage_val
		var force =  my_node.current_weapon.knock_back_force
		body.take_damage(damdge_val,force,dir)
		emit_signal("attackd",attack_col.position)

func attack_effects(attack_pos):
	
	###--------- PAUSE TIME EFFECT ----- ####
	var freeze_val = my_node.current_weapon.freeze_time_val
	var freeze_duration = my_node.current_weapon.freeze_duration
	
	Engine.time_scale = freeze_val
	await get_tree().create_timer(freeze_duration,true,false,true).timeout
	Engine.time_scale = 1
	
	###--- YOU CAN USE HIT POSITION TO ADD PARTICALS 
	print(attack_pos)



func take_damage(damdge , force , dir):
	health -= damdge
	current_state = states.DAMAGING
	velocity = force * dir
	emit_signal("damaged")
	damdge_timer.start()

func damage_end():
	current_state = states.MOVING
	velocity = Vector2.ZERO
	print("damdge end")


func changing_to_attack_state():
	current_state = states.ATTACKING
	velocity.y = 0

func changing_to_normal_state():
	current_state = states.MOVING
	can_jump = true
	current_grav = grav

func attack_dash_offset():
	global_position.x += attack_dash * facing_direction
