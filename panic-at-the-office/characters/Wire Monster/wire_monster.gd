extends CharacterBody2D


const SPEED = 100.0

@export var nav_agent: NavigationAgent2D


func _physics_process(_delta: float) -> void:
	nav_agent.target_position = Globals.player.global_position
	var target_pos = nav_agent.get_next_path_position()
	
	velocity = (target_pos - global_position).normalized() * SPEED
	
	move_and_slide()
