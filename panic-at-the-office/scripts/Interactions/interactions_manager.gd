extends Node

@onready var label = $Label

const BASE_TEXT := "[F] "
const LABEL_OFFSET := Vector2(0, -36)

var active_areas = []
var can_interact = true
var frozen_process_modes := {}

func register_area(area: InteractionArea):
	active_areas.push_back(area)
	
func unregister_area(area: InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)
		
		
func _process(_delta):
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if active_areas.size() > 0 && can_interact && is_instance_valid(player):
		active_areas.sort_custom(_sort_by_distance_to_player)
		label.text = BASE_TEXT + active_areas[0].action_name
		label.global_position = player.global_position + LABEL_OFFSET - Vector2(label.size.x / 2, 0)
		label.show()
	else:
		label.hide()
	
		
func _sort_by_distance_to_player(area1, area2):
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not is_instance_valid(player):
		return false
	var area1_to_player = player.global_position.distance_to(area1.global_position)
	var area2_to_player = player.global_position.distance_to(area2.global_position)
	return area1_to_player < area2_to_player
	
func _input(event):
	if event.is_action_pressed("interact") && can_interact:
		if active_areas.size() > 0:
			can_interact = false
			label.hide()
			freeze_world()
			await active_areas[0].interact.call()
			unfreeze_world()
			can_interact = true


func freeze_world():
	if not frozen_process_modes.is_empty():
		return
	for node in get_tree().get_nodes_in_group("pause_during_interaction"):
		frozen_process_modes[node] = node.process_mode
		node.process_mode = Node.PROCESS_MODE_DISABLED


func unfreeze_world():
	for node in frozen_process_modes:
		if is_instance_valid(node):
			node.process_mode = frozen_process_modes[node]
	frozen_process_modes.clear()
