extends Node
class_name Strategy

@export var parent: CharacterBody2D

func _ready():
	parent = get_parent()
	parent.nav.target_position = parent.global_position + Vector2.DOWN

func function(delta: float):
	pass
func physics_function(delta: float):
	pass
