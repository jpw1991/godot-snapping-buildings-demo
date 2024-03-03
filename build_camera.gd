# derived from: https://gist.github.com/AndreaCatania/316fc412a7b478ca5226b5c17d963737
extends Camera3D


const speed = 0.1
const sensitivity = 0.001

var motion: Vector3
var view_motion: Vector2
var gimbal_base: Transform3D
var gimbal_pitch: Transform3D
var gimbal_yaw: Transform3D

var _last_build_piece_collision = null

var _last_mouse_position : Vector2


@onready var _preview_node = $preview
var _preview_object = null
@onready var wireframe_material = load("res://wireframe_material.tres")

signal place_item(pos, rot)



func raycast_at_cursor(max_distance, mask):
	var space_state = get_viewport().get_world_3d().direct_space_state
	var camera3d = get_viewport().get_camera_3d()
	var from = camera3d.project_ray_origin(_last_mouse_position)
	var to = from + camera3d.project_ray_normal(_last_mouse_position) * max_distance
	var ray_query = PhysicsRayQueryParameters3D.create(from, to)
	ray_query.collision_mask = mask
	var result = space_state.intersect_ray(ray_query)
	return result


func set_preview_object(obj):
	if _preview_object and is_instance_valid(_preview_object):
		_preview_object.queue_free()
		_preview_object = null
	if obj != null:
		_preview_object = obj.instantiate()
		# add the preview to the top so it doesn't get its rotation all messed
		# up by the player moving around. The script will move the preview
		# where the cursor is looking instead.
		get_parent().add_child(_preview_object)
		_preview_object.get_child(0).set_surface_override_material(0, wireframe_material)
		# set to layer 13 so we don't hit this in later raycasts
		_preview_object.collision_layer = 1 << 12  # set to 13
		_preview_object.collision_mask = 1 << 12  # set to 13


func active():
	return $".".current


func _ready():
	gimbal_base.origin = transform.origin


func _input(event):
	if !active():
		return
	
	if event is InputEventMouse:
		_last_mouse_position = event.position
		
		var result = raycast_at_cursor(15, 1)
		if result:
			var result_collider = result.get("collider")
			if result_collider is BuildPieceCollision:
				_last_build_piece_collision = result_collider
			else:
				_last_build_piece_collision = null
			
			if event is InputEventMouseMotion:
				# predict the closest placement point to the 3d cursor
				if _last_build_piece_collision:
					_preview_object.global_transform = _last_build_piece_collision.closest_snap_point(_preview_object.get_child(0), result_collider.global_position)

	if event is InputEventMouseMotion:
		view_motion += event.relative
	
	if event is InputEventMouseButton:
		if event.is_action_released("rotate_preview_object_left"):
			#_preview_object.rotate_y(deg_to_rad(-90))
			#_last_snap_index += 1
			#if _last_snap_index >= _snap_points.size():
				#_last_snap_index = 0
			if _last_build_piece_collision:
				var next = _last_build_piece_collision.next_snap_point(_preview_object.get_child(0))
				_preview_object.global_transform = next
			else:
				_preview_object.rotate_y(deg_to_rad(-90))
		elif event.is_action_released("rotate_preview_object_right"):
			#_preview_object.rotate_y(deg_to_rad(90))
			#_last_snap_index -= 1
			#if _last_snap_index < 0:
				#_last_snap_index = _snap_points.size()-1
			if _last_build_piece_collision:
				var prev = _last_build_piece_collision.previous_snap_point(_preview_object.get_child(0))
				_preview_object.global_transform = prev
			else:
				_preview_object.rotate_y(deg_to_rad(90))
		elif event.is_action_released("action_one"):
			place_item.emit(_preview_object.global_position, _preview_object.global_rotation)


func _process(delta):
	var is_active = active()
	if _preview_object:
		_preview_object.visible = is_active
	
	if !is_active:
		return
	
	if !_last_build_piece_collision:
		_preview_object.global_position = _preview_node.global_position
	
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
	view_motion = Vector2()
	
	transform = gimbal_base * (gimbal_yaw * gimbal_pitch)
