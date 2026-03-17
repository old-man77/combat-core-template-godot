extends Node2D
@export var player : Node2D

@export var current_weapon : weapon_resource

var open_window = false
var can_attack = true
var attack_times : int = 0
var attack_in_window_times : int  = 0
var cooldown_after_attack : Timer 
var input_window_time = 0.0

signal attackd
signal combo_end 


func _ready() -> void:
	##---- SETTEING THE AFTER COMBO COOLDOWN TIMER --- #######
	cooldown_after_attack = Timer.new()
	cooldown_after_attack.one_shot = true
	cooldown_after_attack.wait_time = current_weapon.cooldown_time
	cooldown_after_attack.timeout.connect(Callable(self,"reset_combo"))
	add_child(cooldown_after_attack)
	
	
	##--- ASSIGNING PLAYER IF U DONT DO ----- ####
	if !player:
		get_tree().get_first_node_in_group("player")
	
	#####---- RESET COMBO IF DAMDAGED ------- #######
	player.damaged.connect(Callable(self,"damage_reset"))


func _process(delta: float) -> void:
	
	
	####---- TRIGGER ---- ####
	
	if player.current_state != player.states.DAMAGING:
		if Input.is_action_just_pressed("attack"):
			if can_attack: #### ---- FIRST ATTAACK ---- ####
				attack()
				can_attack = false
			elif open_window && attack_times < current_weapon.max_attacks:
				#### --- SAVING THE ATTACK UNTIL FINISHING CURRENT ATTACK ----- ###
				attack_in_window_times += 1 
	
	
	#### ----- ATTACK BUFFER ---- ######
	if open_window:
		input_window_time += delta
	
	
	
	
	##### --- ENDING WINDOW IF PLAYER LATE ---- #########
	if input_window_time > current_weapon.window_time:
		cooldown_after_attack.start()
		input_window_time = 0
		open_window = false
		emit_signal("combo_end")
		
	
	
	
	### ---- APPPLY THE ATTACKS WICH SAVED UPPER ----- ####
	
	if !player.animation_player.is_playing():
		if attack_in_window_times > 0 && attack_times < current_weapon.max_attacks:
			attack()
			input_window_time = 0
			attack_in_window_times -= 1
	


func damage_reset():
	open_window = false
	input_window_time = 0
	attack_times = 0
	can_attack = true

func attack():
	emit_signal("attackd")
	attack_times += 1
	
	#### ----- OPEN WINDOW AFTER FIRIST ATTACK ---- ######
	if open_window == false:
		open_window = true



func reset_combo():
	player.animation_player.speed_scale = 1
	attack_times = 0
	attack_in_window_times = 0
	can_attack = true
