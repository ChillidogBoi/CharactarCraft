extends CharacterBody3D


const UP_DOWN_KEY_SPEED = 8.0
const UP_DOWN_WHEEL_SPEED = 60.0
const KEY_SPEED = 15.0
const MOUSE_SPEED = 3.0
var mouse_moved: int = 0
var last_mouse_pos: Vector2 = Vector2.ZERO


func _physics_process(delta):
	if Input.is_action_just_pressed("move_mouse"): Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_released("move_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_moved = 0
	
	if Input.is_action_just_pressed("move_down_mouse"):
		velocity.y = -UP_DOWN_WHEEL_SPEED
	elif Input.is_action_just_pressed("move_up_mouse"):
		velocity.y = UP_DOWN_WHEEL_SPEED
	else:
		var up_down_vel = Input.get_axis("move_down", "move_up") * UP_DOWN_KEY_SPEED
		velocity.y = up_down_vel
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * KEY_SPEED
		velocity.z = direction.z * KEY_SPEED
	elif mouse_moved < 1:
		velocity.x = 0
		velocity.z = 0
	mouse_moved -= 1

	move_and_slide()

func _unhandled_input(event):
	if not event is InputEventMouse: return
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): return
	if not event is InputEventMouseMotion: return
	var input_dir = Vector3(event.screen_relative.x, -velocity.y, event.screen_relative.y)
	velocity = -input_dir * Vector3(MOUSE_SPEED, 1, MOUSE_SPEED)
	mouse_moved = 5
	return
	
	
