extends StaticBody3D

class_name BuildPieceCollision


func snap_position(normal : Vector3, buildable : Buildable) -> Vector3:

	# World to local space
	var local_basis := basis.inverse()
	# Local space normal
	var local_normal := local_basis * normal

	# Return world space point
	return transform * BuildSystem.snap_position(buildable, local_normal)
