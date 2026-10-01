extends StaticBody2D


@export var books_node: Node2D
@export var randomize_books: bool = true

@onready var bookshelf_texture: Texture2D = preload("uid://d2bfu5fducixa")


func _ready() -> void:
	if not randomize_books:
		return
	
	for child in books_node.get_children():
		child.queue_free()
	
	for level in range(1, 4):
		add_book_sprite(level)


func add_book_sprite(level: int):
	var books: Sprite2D = Sprite2D.new()
	books_node.add_child(books)
	books.texture = bookshelf_texture
	books.offset.y = -13
	books.hframes = 5
	books.vframes = 4
	books.frame_coords = Vector2i(randi_range(0, 4), level)
