class_name Player extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 5

@onready var body = $Body
@onready var camera: Camera3D = get_parent().get_node("Camera3D")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var ray_origin := Vector3.ZERO
var ray_target := Vector3.ZERO

var look_at_direction := Vector3.ZERO

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * 1.5 * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	update_look_direction()
	move_and_slide()

func update_look_direction() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	ray_origin = camera.project_ray_origin(mouse_pos)
	ray_target = ray_origin + camera.project_ray_normal(mouse_pos) * 2000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
	var intersection : Dictionary = space_state.intersect_ray(query) 
	if not intersection.is_empty():
		var pos = intersection.get("position")
		var look_pos: Vector3 = Vector3(pos.x, body.position.y, pos.z)
		var lerp_dir = lerp(look_at_direction, look_pos, 0.05)
		body.look_at(lerp_dir, Vector3.UP)
		look_at_direction = lerp_dir
