extends Node


static func snap_position(
	buildable : Buildable, normal : Vector3
) -> Vector3:
	# Some logic for deciding which snap point is best
	# Here we use the one facing the most in the direction of the local space
	# normal

	var best_point : Vector3
	var best_dot := -1.0

	for point in buildable.snap_points:
		# Approximate the normal at the snap point
		var point_normal := point.normalized()
		var dot := normal.dot(point_normal)
		if dot >= best_dot:
			best_dot = dot
			best_point = point

	return best_point
