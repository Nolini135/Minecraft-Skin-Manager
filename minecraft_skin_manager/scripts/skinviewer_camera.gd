extends Camera3D

@onready var container: Node3D = $".."

@export var skin_editor: TextureEditor

@export var tool_component: ToolComponent

var painting := false

func _process(_delta: float) -> void:
	if painting: shoot_ray()

func _input(event: InputEvent) -> void:
	rc_drawing_input(event)
	
	handle_zoom(event)
	handle_model_rotation(event)
	#handle_cam_rotation(event)

############## RayCast Drawing ##############

func rc_drawing_input(event: InputEvent):
	if tool_component.hold_click_tools.has(tool_component.selected_tool):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			painting = event.is_pressed()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		shoot_ray()

func shoot_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var hit = space.intersect_ray(ray_query)
	
	if hit:
		var collider = hit.get("collider")
		var pos = hit.get("position")
		var normal = hit.get("normal")
		
		# Get Parent Mesh
		var mesh_instance = collider.get_parent() as MeshInstance3D
		if mesh_instance == null:
			printerr("no MeshInstance3D found: return")
			return
		
		# Get UV
		var uv = get_mesh_uv_from_ray(mesh_instance, from, to)
		
		# Draw at The Position
		if uv:
			skin_editor.draw_from_uv(uv)

func get_mesh_uv_from_ray(mesh: MeshInstance3D, origin: Vector3, dir_end: Vector3):
	var closest_dist = INF
	var final_uv = null
	var mesh_res: Mesh = mesh.mesh
	
	var to_local = mesh.global_transform.affine_inverse()
	var local_origin = to_local * origin
	var local_dir = (to_local.basis * (dir_end - origin)).normalized()
	
	for s in mesh_res.get_surface_count():
		var arrays = mesh_res.surface_get_arrays(s)
		var verts = arrays[Mesh.ARRAY_VERTEX]
		var uvs = arrays[Mesh.ARRAY_TEX_UV]
		var indices = arrays[Mesh.ARRAY_INDEX]
	
		for i in range(0, indices.size(), 3):
			var a = verts[indices[i]]
			var b = verts[indices[i+1]]
			var c = verts[indices[i+2]]
			
			# Ignore les faces qui ne font pas face à la caméra
			var face_normal = (b - a).cross(c - a).normalized()
			if face_normal.dot(local_dir) <= 0:
				continue
			
			var hit = Geometry3D.ray_intersects_triangle(local_origin, local_dir, a, b, c)
			if hit:
				var dist = local_origin.distance_to(hit)
				if dist < closest_dist:
					closest_dist = dist
					var bary = Geometry3D.get_triangle_barycentric_coords(hit, a, b, c)
					var uv_a = uvs[indices[i]]
					var uv_b = uvs[indices[i+1]]
					var uv_c = uvs[indices[i+2]]
					final_uv = uv_a * bary.x + uv_b * bary.y + uv_c * bary.z
	return final_uv

func ray_triangle_intersection(origin, dir, a, b, c):
	return Geometry3D.ray_intersects_triangle(origin, dir, a, b, c)

############## Camera Movements ##############

func handle_zoom(event: InputEvent):
	if event.is_action_pressed("scroll_up"):
		position.z -= 0.25
	elif event.is_action_pressed("scroll_down"):
		position.z += 0.25

func handle_model_rotation(event: InputEvent):
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("right_click"):
			container.rotation.y -= event.relative.x * 0.01
			container.rotation.x -= event.relative.y * 0.01
			container.rotation_degrees.x = clamp(container.rotation_degrees.x, -90, 90)
