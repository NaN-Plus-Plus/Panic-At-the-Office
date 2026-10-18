extends CanvasLayer

@onready var node: Control = $Node

var count: int = 1
var player: CharacterBody2D
var isVisible := false

func _ready() -> void:
	$Node/Content/Gift.visible = true
	isVisible = false
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("gift") and not event.is_echo() and isVisible:
		use_gift()

func show_gift():
	node.visible = true
	isVisible = true

func hide_gift() -> void:
	node.visible = false
	isVisible = false

func use_gift():
	if count > 0 and isVisible:
		count -= 1
		player = get_tree().get_first_node_in_group("player")
		player.activate_shield()
		if count == 0:
			$Node/Content/Gift.visible = false
	else:
		pass

func reset_gift() -> void:
	count = 1
	$Node/Content/Gift.visible = true
	node.visible = false
	isVisible = false
