extends StaticBody3D

class_name BuildPieceCollision

@onready var _collision_shape_3d = $CollisionShape3D

@export var snap_points : Array[Node3D]


var _snap_index = 0


func _next_snap_index() -> int:
	_snap_index += 1
	if _snap_index >= snap_points.size():
		_snap_index = 0
	return _snap_index


func _previous_snap_index() -> int:
	_snap_index -= 1
	if _snap_index < 0:
		_snap_index = snap_points.size()-1
	return _snap_index


func next_snap_point(connecting_mesh : MeshInstance3D) -> Transform3D:
	var mesh_size = connecting_mesh.mesh.get_aabb().size
	var snap = snap_points[_next_snap_index()]
	var result = snap.global_transform
	result.origin += snap.position * mesh_size
	var test = snap.global_transform
	return result


func previous_snap_point(connecting_mesh : MeshInstance3D) -> Transform3D:
	var mesh_size = connecting_mesh.mesh.get_aabb().size
	var snap = snap_points[_previous_snap_index()]
	var result = snap.global_transform
	result.origin += snap.position * mesh_size
	var test = snap.global_transform
	return result


func closest_snap_point(connecting_mesh : MeshInstance3D, point : Vector3) -> Transform3D:
	var closest = null
	for snap in snap_points:
		if closest == null or snap.global_position.distance_to(point) < closest.global_position.distance_to(point):
			closest = snap
	var mesh_size = connecting_mesh.mesh.get_aabb().size
	var result = closest.global_transform
	result.origin += closest.position * mesh_size
	return result

