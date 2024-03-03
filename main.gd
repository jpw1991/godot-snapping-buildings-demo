extends Node3D


var current_structure_index = 0

var structures = [preload("res://Cube.tscn"),
	preload("res://Wood/WoodBeam.tscn"),
	preload("res://Wood/WoodWall.tscn")]


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Camera3D.set_preview_object(structures[0])


func _input(event):
	if event.is_action_released("quit"):
		get_tree().quit()
	
	if event.is_action_released("cube"):
		$Camera3D.set_preview_object(structures[0])
		current_structure_index = 0
	elif event.is_action_released("beam"):
		$Camera3D.set_preview_object(structures[1])
		current_structure_index = 1
	elif event.is_action_released("wall"):
		$Camera3D.set_preview_object(structures[2])
		current_structure_index = 2


func _on_camera_3d_place_item(pos, rot):
	var obj = structures[current_structure_index].instantiate()
	add_child(obj)
	obj.global_position = pos
	obj.global_rotation = rot
