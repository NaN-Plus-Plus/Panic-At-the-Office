@tool
extends StaticBody2D
class_name OfficeWall


@export_enum("Horizontal", "Vertical") var axis: String = "Horizontal":
	get:
		return axis
	set(value):
		axis = value
		set_axis(axis)

@export_range(8, 16384, 1, "suffix:px") var length: int = 8:
	get:
		return length
	set(value):
		length = value
		set_length(length)

@onready var office_wall_sprite: NinePatchSprite2D = $OfficeWallSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Vector2(8, 8)


func set_axis(value):
	if not collision_shape:
		return
	
	if value == "Horizontal":
		office_wall_sprite.patch_margin_top = 9
		office_wall_sprite.patch_margin_bottom = 57
		office_wall_sprite.size = Vector2(length, 66)
		office_wall_sprite.position = Vector2(float(length) / 2 - 4, -29)
		
		collision_shape.shape.size = Vector2(length, 8)
		collision_shape.position = Vector2(float(length) / 2 - 4, 0)
	if value == "Vertical":
		office_wall_sprite.patch_margin_top = 2
		office_wall_sprite.patch_margin_bottom = 64
		office_wall_sprite.size = Vector2(8, length + 58)
		office_wall_sprite.position = Vector2(0, -float(length) / 2 - 25)
		
		collision_shape.shape.size = Vector2(8, length)
		collision_shape.position = Vector2(0, -float(length) / 2 + 4)


func set_length(value):
	if not collision_shape:
		return
	
	if axis == "Horizontal":
		office_wall_sprite.size.x = value
		office_wall_sprite.position.x = float(value) / 2 - 4
		
		collision_shape.shape.size.x = value
		collision_shape.position.x = float(value) / 2 - 4
	if axis == "Vertical":
		office_wall_sprite.size.y = value + 58
		office_wall_sprite.position.y = -float(value) / 2 - 25
		
		collision_shape.shape.size = Vector2(8, length)
		collision_shape.position.y = -float(value) / 2 + 4
