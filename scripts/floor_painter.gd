extends Node

const TEXTURE_SIZE := 1024
const FLOOR_SIZE := Vector2(440.0, 300.0)
const FLOOR_CENTER := Vector3(0.0, 0.0, -40.573303)

var _image: Image
var _texture: ImageTexture
var _dirty := false
var _mesh_count := 0
var _paint_calls := 0

func _ready() -> void:
	_image = Image.create_empty(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
	_image.fill(Color.TRANSPARENT)
	_texture = ImageTexture.create_from_image(_image)
	initialize() 
	
func initialize() -> void:
	await get_tree().process_frame
	_tag_and_paint(get_tree().root)
	print("[FloorPainter] shader applied to %d meshes" % _mesh_count) 

func _tag_and_paint(node: Node) -> void:
	if node is MeshInstance3D and not node.is_in_group("NoPaint"):
		_attach_paint_pass(node as MeshInstance3D)
	for child in node.get_children():
		_tag_and_paint(child)

func _attach_paint_pass(mesh: MeshInstance3D) -> void:
	var paint_mat := ShaderMaterial.new()
	paint_mat.shader = load("res://shaders/paint_overlay.gdshader")
	if paint_mat.shader == null:
		push_error("[FloorPainter] Failed to load shader!")
		return
	paint_mat.set_shader_parameter("paint_texture", _texture)
	paint_mat.set_shader_parameter("world_size", FLOOR_SIZE)
	paint_mat.set_shader_parameter("world_center", Vector2(FLOOR_CENTER.x, FLOOR_CENTER.z))

	var surface_count := mesh.mesh.get_surface_count() if mesh.mesh else 0
	for i in range(surface_count):
		var base_mat := mesh.get_active_material(i)
		if base_mat != null:
			var mat_copy := base_mat.duplicate() as Material
			mat_copy.next_pass = paint_mat
			mesh.set_surface_override_material(i, mat_copy)
		else:
			mesh.set_surface_override_material(i, paint_mat)
	_mesh_count += 1

func _process(_delta: float) -> void:
	if _dirty:
		_texture.update(_image)
		_dirty = false

func paint(world_pos: Vector3, color: Color, brush_world_radius: float = 1.0) -> void:
	var tex_u := (world_pos.x - FLOOR_CENTER.x + FLOOR_SIZE.x * 0.5) / FLOOR_SIZE.x
	var tex_v := (world_pos.z - FLOOR_CENTER.z + FLOOR_SIZE.y * 0.5) / FLOOR_SIZE.y

	if tex_u < 0.0 or tex_u > 1.0 or tex_v < 0.0 or tex_v > 1.0:
		if _paint_calls == 0:
			print("[FloorPainter] paint() called but world_pos %s is outside bounds (tex_u=%.2f tex_v=%.2f)" % [world_pos, tex_u, tex_v])
		_paint_calls += 1
		return

	_paint_calls += 1
	if _paint_calls <= 3:
		print("[FloorPainter] paint() at world_pos=%s tex_uv=(%.3f, %.3f)" % [world_pos, tex_u, tex_v])

	var pixel_x := int(tex_u * TEXTURE_SIZE)
	var pixel_y := int(tex_v * TEXTURE_SIZE)
	var pixel_radius := maxi(1, int(brush_world_radius / FLOOR_SIZE.x * TEXTURE_SIZE))

	for offset_y in range(-pixel_radius, pixel_radius + 1):
		for offset_x in range(-pixel_radius, pixel_radius + 1):
			if offset_x * offset_x + offset_y * offset_y <= pixel_radius * pixel_radius:
				_image.set_pixel(
					clampi(pixel_x + offset_x, 0, TEXTURE_SIZE - 1),
					clampi(pixel_y + offset_y, 0, TEXTURE_SIZE - 1),
					color
				)
	_dirty = true
