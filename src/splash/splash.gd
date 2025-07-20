extends Node2D

@onready var fade = $CanvasLayer/Fade

func _ready() -> void:
	await fade.fade_in()
	await get_tree().create_timer(3.0).timeout
	await fade.fade_out()
	
	get_tree().change_scene_to_file("res://map/map.tscn")
