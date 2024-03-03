# derived from: https://gist.github.com/AndreaCatania/316fc412a7b478ca5226b5c17d963737
extends Camera3D

const CROSSHAIR := preload("res://crosshair.tres")

const speed = 0.1
const sensitivity = 0.001

var motion: Vector3
var view_motion: Vector2
var gimbal_base: Transform3D
var gimbal_pitch: Transform3D
var gimbal_yaw: Transform3D

var preview : MeshInstance3D
var previewKind := -1

signal place_item()


static func raycast_at_cursor(
	viewport : Viewport, origin : Vector2, max_distance : float, mask : int
) -> Dictionary:
	var space_state := viewport.get_world_3d().direct_space_state
	var camera3d := viewport.get_camera_3d()
	var from := camera3d.project_ray_origin(origin)
	var to := from + camera3d.project_ray_normal(origin) * max_distance
	var ray_query := PhysicsRayQueryParameters3D.create(from, to)
	ray_query.collision_mask = mask
	var result := space_state.intersect_ray(ray_query)
	return result


func active():
	return current


func _ready():
	gimbal_base.origin = transform.origin


func _input(event):
	if !active():
		return

	if event is InputEventMouseMotion:
		view_motion += event.relative

	if event is InputEventMouseButton:
		if event.is_action_released("action_one"):
			place_item.emit()


func _physics_process(delta : float) -> void:
	if !active():
		return

	#
	# Movement
	#

	motion.x = 0
	motion.y = 0
	motion.z = 0
	if Input.is_action_pressed("move_forward"):
		motion.z = -1.0
	if Input.is_action_pressed("move_backward"):
		motion.z = 1.0
	if Input.is_action_pressed("move_left"):
		motion.x = -1.0
	if Input.is_action_pressed("move_right"):
		motion.x = 1.0
	if Input.is_action_pressed("move_jump"):
		if Input.is_action_pressed("move_sprint"):
			motion.y = -1.0
		else:
			motion.y = 1.0

	gimbal_base *= Transform3D(Basis(), transform.basis * (motion * speed))

	gimbal_yaw = gimbal_yaw.rotated(Vector3(0,1,0), view_motion.x * sensitivity * -1.0)
	gimbal_pitch = gimbal_pitch.rotated(Vector3(1,0,0), view_motion.y * sensitivity * -1.0)
	view_motion = Vector2.ZERO

	transform = gimbal_base * (gimbal_yaw * gimbal_pitch)

	# Stop going through the floor
	transform.origin.y = maxf(transform.origin.y, 1.0)

	#
	# Preview
	#
	update_preview()


func update_preview() -> void:
	var viewport := get_viewport()
	# Just use the middle of the screen since the cursor is locked
	var result := raycast_at_cursor(viewport, viewport.size / 2, 15, 1)
	if result:
		var result_collider : Node3D = result["collider"]
		if result_collider is BuildPieceCollision:
			var buildable : Buildable = BuildSystem.buildables[previewKind]
			var normal : Vector3 = result["normal"]
			# Collider snap point with normal most aligned with collision normal
			var collider_snap : Vector3 = result_collider.snap_position(normal)

			# Preview snap point with normal most opposite collision normal
			var preview_basis := preview.basis
			# World to local space
			var local_basis := preview_basis.inverse()
			# Local space normal
			var local_normal := local_basis * normal
			var preview_snap : Vector3 = BuildSystem.snap_position(
				buildable, -local_normal
			)
			preview.position = collider_snap - preview_basis * preview_snap
			CROSSHAIR.set_shader_parameter("snap", true)
			return

	preview.position = position - basis.z * 5.0
	CROSSHAIR.set_shader_parameter("snap", false)
