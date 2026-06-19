extends CharacterBody3D

@export var debug_key: Key
const hit_dirs = [
	Vector3(1,0,0), Vector3(0.5,0,0.5), Vector3(0,0,1), Vector3(-0.5,0,0.5),
	Vector3(-1,0,0), Vector3(-0.5,0,-0.5), Vector3(0,0,-1), Vector3(0.5,0,-0.5)
]

@export_category("Stats")
@export var speed: int = 600
@export var damage: int
@export var attack_speed: float
@export var max_health: int
@export var look_dist: float

@export_category("Nodes")
@export var strat: Strategy
@export var nav: NavigationAgent3D
@export var healthbar: Sprite3D
@export var timer: Timer
@export var zone: Area3D
@export var sprite: Node3D
@export var hit_graphic: Node3D
@export var scanner: Area3D
@export var tester: Area3D
@export var tester2: RayCast3D

var stuck_counter: float = 0.0
var sub: bool = false
var is_in_fight: bool = false
signal hit
var slow: int = 0

var health: int = 0:
	set(v):
		health = v
		if v > 0: healthbar.frame = round(float(v / float(max_health)) * healthbar_frames)
var healthbar_frames: int

func _ready():
	healthbar_frames = healthbar.hframes * healthbar.vframes - 1
	health = max_health
	healthbar.frame = healthbar_frames
	$Look/CollisionShape2D.shape.radius = look_dist

func _input(event):
	if not event is InputEventKey: return
	if event.key_label != debug_key: return
	if not event.is_pressed(): return
	
#	nav.target_position = get_global_mouse_position()

func _process(delta):
	strat.function(delta)

func _physics_process(delta):
	strat.physics_function(delta)

	if is_in_fight: return
	if nav.is_navigation_finished(): return
	if is_on_wall(): stuck_counter += delta
	if stuck_counter > 0.25:
		nav.target_position = global_position + get_wall_normal()
		stuck_counter = 0.0
	
	var lll = Vector3(nav.get_next_path_position().x, 0, nav.get_next_path_position().z)
	var dir = to_local(lll).normalized()
	velocity = dir * (speed - slow) * delta
	move_and_slide()

func find_hit_dir(a: Vector3, j: Vector3) -> bool:
	if a.distance_to(j) < 0.5:
		print(a,j)
		return true
	return false

func _on_area_2d_area_entered(area):
	is_in_fight = true
	if timer.is_stopped(): timer.start((2.5 + randf_range(0.0,0.25)) - (attack_speed/10))
	await timer.timeout
	if not zone.overlaps_area(area):
		is_in_fight = false
		return
	var x = area.get_parent()
	if sub:
		timer.start((2.5 - randf_range(0.0,0.25)) - (attack_speed/10))
		await timer.timeout
	else: x.sub = true
	if not zone.overlaps_area(area):
		is_in_fight = false
		return
	
	var j = global_position.direction_to(x.global_position)
	hit_graphic.frame = hit_dirs.rfind_custom(find_hit_dir.bind(j))
	hit_graphic.visible = true
	await get_tree().create_timer(0.025).timeout
	if not zone.overlaps_area(area):
		is_in_fight = false
		hit_graphic.visible = false
		return
	x.hit.emit()
	await get_tree().create_timer(0.025).timeout
	hit_graphic.visible = false
	if not zone.overlaps_area(area):
		is_in_fight = false
		return
	
	x.health = health - damage
	if x.health < 1:
		is_in_fight = false
		x.queue_free()
		return
	fight(area, x)

func fight(area: Area3D, x: Node):
	nav.target_position = global_position
	timer.start((2.5 + randf_range(0.0,0.25)) - (attack_speed/10))
	await timer.timeout
	if not zone.overlaps_area(area):
		is_in_fight = false
		return
	var j = global_position.direction_to(x.global_position)
	hit_graphic.frame = hit_dirs.rfind_custom(find_hit_dir.bind(j))
	hit_graphic.visible = true
	await get_tree().create_timer(0.025).timeout
	if not zone.overlaps_area(area):
		is_in_fight = false
		hit_graphic.visible = false
		return
	x.hit.emit()
	await get_tree().create_timer(0.025).timeout
	hit_graphic.visible = false
	if not zone.overlaps_area(area):
		is_in_fight = false
		return
	x.health = x.health - damage
	print(x.name, ": ", x.health)
	if x.health < 1:
		x.queue_free()
		is_in_fight = false
		return
	fight(area, x)


func _on_hit():
	sprite.modulate = Color(0,0,0,0)
	await get_tree().create_timer(0.0675).timeout
	sprite.modulate = Color(1,1,1,1)
	await get_tree().create_timer(0.025).timeout
	sprite.modulate = Color(0,0,0,0)
	await get_tree().create_timer(0.025).timeout
	sprite.modulate = Color(1,1,1,1)


func _on_mouse_entered():
	print(2)
