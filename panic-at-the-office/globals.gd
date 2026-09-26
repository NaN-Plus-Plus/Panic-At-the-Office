extends Node


var player: CharacterBody2D
var vignette: ShaderMaterial
var difficulty: difficulty_enum
var rows := 25
var cols := 25

enum difficulty_enum {
	EASY,
	NORMAL,
	HARD
}
