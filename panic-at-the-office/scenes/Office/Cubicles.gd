@tool
extends StaticBody2D
class_name Cubicles

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var cubicle_sprites_node: Node2D = $CubicleSprites
@onready var posted_notes_sprites_node: Node2D = $PostedNotesSprites
@onready var cubicle_end_wall_sprite: Sprite2D = $CubicleEndWallSprite
@onready var cubicles_sprite_sheet: Texture2D = preload("res://assets/Office/office_cubicles.png")

@export_range(0, 99) var cubicle_amount: int:
	get:
		return cubicle_amount
	set(value):
		set_cubicle_amount(value)
		cubicle_amount = value

const CUBICLE_WIDTH: int = 41
const CUBICLE_HEIGHT: int = 68
const CUBICLE_COLLISION_HEIGHT: int = 48


func _ready() -> void:
	if not Engine.is_editor_hint():
		return
	
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size.x = CUBICLE_WIDTH + 3
	collision_shape.shape.size.y = 48
	collision_shape.position = Vector2(float(CUBICLE_WIDTH + 3) / 2, 0)


func set_cubicle_amount(value) -> void:
	if not Engine.is_editor_hint():
		return
	
	collision_shape.shape.size.x = CUBICLE_WIDTH * value + 3
	collision_shape.position = Vector2(float(CUBICLE_WIDTH * value + 3) / 2, 0)
	
	cubicle_end_wall_sprite.position = Vector2(CUBICLE_WIDTH * (value + 0.5), -5)
	
	if value > cubicle_amount:
		for i in range(cubicle_sprites_node.get_child_count(), value):
			var cubicle_sprite = Sprite2D.new()
			var posted_notes_sprite = Sprite2D.new()
			cubicle_sprites_node.add_child(cubicle_sprite)
			posted_notes_sprites_node.add_child(posted_notes_sprite)
			cubicle_sprite.owner = get_tree().edited_scene_root
			posted_notes_sprite.owner = get_tree().edited_scene_root
			cubicle_sprite.name = "CubicleSprite" + str(i)
			posted_notes_sprite.name = "PostedNotesSprite" + str(i)
			cubicle_sprite.texture = cubicles_sprite_sheet
			posted_notes_sprite.texture = cubicles_sprite_sheet
			cubicle_sprite.hframes = 4
			posted_notes_sprite.hframes = 4
			cubicle_sprite.vframes = 2
			posted_notes_sprite.vframes = 2
			cubicle_sprite.frame_coords = Vector2i(randi_range(0, 2), 0)
			posted_notes_sprite.frame_coords = Vector2i(randi_range(0, 3), 1)
			cubicle_sprite.position = Vector2(CUBICLE_WIDTH * (i + 0.5), -5)
			posted_notes_sprite.position = Vector2(CUBICLE_WIDTH * (i + 0.5), -5)
	elif value < cubicle_amount:
		for i in range(value, cubicle_amount):
			var child := cubicle_sprites_node.get_child(i)
			if child != null:
				child.queue_free()
			
			child = posted_notes_sprites_node.get_child(i)
			if child != null:
				child.queue_free()
