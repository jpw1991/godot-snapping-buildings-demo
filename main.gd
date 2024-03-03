extends Node3D


@onready var camera : Camera3D = $camera
@onready var preview : MeshInstance3D = $preview


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.preview = preview
	update_preview(0)


func _input(event : InputEvent) -> void:
	if event.is_action_released("quit"):
		get_tree().quit()

	if event.is_action_released("cube"):
		update_preview(0)
	elif event.is_action_released("beam"):
		update_preview(1)
	elif event.is_action_released("wall"):
		update_preview(2)
	elif event.is_action_released("rotate_preview_object_left"):
		preview.rotation_degrees.y = fposmod(preview.rotation_degrees.y + 90.0, 360.0)
	elif event.is_action_released("rotate_preview_object_right"):
		preview.rotation_degrees.y = fposmod(preview.rotation_degrees.y - 90.0, 360.0)


func update_preview(kind : int) -> void:
	preview.mesh = BuildSystem.buildables[kind].mesh
	camera.previewKind = kind


func _on_camera_3d_place_item() -> void:
	var scene := BuildSystem.buildables[camera.previewKind].scene.instantiate()
	# HACK: Need a better way to associate metadata with the instances
	scene.kind = camera.previewKind
	add_child(scene)
	scene.transform = preview.transform
