extends Node3D


@onready var camera : Camera3D = $camera

@export var buildables : Array[Buildable]


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.set_preview_object(buildables[0])


func _input(event : InputEvent) -> void:
	if event.is_action_released("quit"):
		get_tree().quit()

	if event.is_action_released("cube"):
		camera.set_preview_object(buildables[0])
	elif event.is_action_released("beam"):
		camera.set_preview_object(buildables[1])
	elif event.is_action_released("wall"):
		camera.set_preview_object(buildables[2])
	elif event.is_action_released("long_block"):
		camera.set_preview_object(buildables[3])
	elif event.is_action_released("rotate_preview_object_left"):
		camera.rotate_preview_left()
	elif event.is_action_released("rotate_preview_object_right"):
		camera.rotate_preview_right()


func _on_camera_3d_place_item(pos, rot) -> void:
	var scene = camera.current_buildable.scene.instantiate()
	add_child(scene)
	scene.global_position = pos
	scene.global_rotation = rot
