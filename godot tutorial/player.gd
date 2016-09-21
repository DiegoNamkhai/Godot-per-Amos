
extends RigidBody2D
var input_states = preload("res://scripts/input_states.gd")
export var player_speed = 300
export var extra_gravity = 400
export var player_jump = 400
export var acceleration = 7
export var air_acceleration = 1
var btn_right = input_states.new("btn_right")
var btn_left = input_states.new("btn_left")
var btn_jump = input_states.new("btn_jump")
var current_speed = Vector2(0,0)
var raycast_down = null
var playerstate_prev = ""
var playerstate = ""
var playerstate_next = "ground"
var orientation_prev = ""
var orientation = "right"
var orientation_next = "right"
var jumping = 0
var rotate = null

func move(speed,acc,delta):
	current_speed.x = lerp(current_speed.x,speed,acc*delta)
	set_linear_velocity(Vector2(current_speed.x,get_linear_velocity().y))

func is_on_ground():
	if raycast_down.is_colliding():
		return true
	else:
		return false

func rotate_behavior():
	if orientation == "right" and orientation_next == "left":
		rotate.set_scale(rotate.get_scale()*Vector2(-1,1))
	elif orientation == "left" and orientation_next == "right":
		rotate.set_scale(rotate.get_scale()*Vector2(-1,1))


func _ready():
	raycast_down = get_node("RayCast2D")
	raycast_down.add_exception(self)
	rotate = get_node("rotate")

	set_fixed_process(true)
	set_applied_force(Vector2(0,extra_gravity))

func _fixed_process(delta):
	#doublejump
	playerstate_prev = playerstate
	playerstate = playerstate_next
	#rotate
	orientation_prev = orientation
	orientation = orientation_next
	
	if playerstate == "ground":
		ground_state(delta)
	elif playerstate == "air":
		air_state(delta)

func ground_state(delta):			
	
	#sx-dx
	if btn_left.check() == 2:
		move(-player_speed,acceleration,delta)
		orientation_next = "left"
	elif btn_right.check() == 2:
		move(player_speed,acceleration,delta)
		orientation_next= "right"
	else:
		move(0,acceleration,delta)
	rotate_behavior()
	
	#jump
	if is_on_ground():
		if btn_jump.check() == 1:
			set_axis_velocity(Vector2(0,-player_jump))
			jumping = 1
	else:
		playerstate_next = "air"
				
func air_state(delta):
	#sx-dx
	
	if btn_left.check() == 2:
		move(-player_speed,air_acceleration,delta)
		orientation_next = "left"
	elif btn_right.check() == 2:
		move(player_speed,air_acceleration,delta)
		orientation_next = "right"
	else:
		move(0,acceleration,delta)
	rotate_behavior()
	
	#jump
	if btn_jump.check() == 1 and jumping == 1:
		set_axis_velocity(Vector2(0,-player_jump))
		jumping += 1
		
	if is_on_ground():
		playerstate_next = "ground"
				
