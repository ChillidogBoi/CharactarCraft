extends CharacterBody2D

@export var debug_key: Key

@export_category("Stats")
@export var speed: int = 6000
@export var damage: int
@export var attack_speed: float
@export var max_health: int
@export var look_dist: int

@export_category("Nodes")
@export var strat: Strategy
@export var nav: NavigationAgent2D
@export var health: Label
@export var timer: Timer
@export var zone: Area2D
@export var sprite: Node2D
@export var hit_graphic: Node2D
@export var scanner: Area2D
@export var tester: Area2D
@export var tester2: Area2D

var stuck_counter: float = 0.0
var sub: bool = false
var is_in_fight: bool = false
signal hit
var slow: int = 0

func _ready():
	health.text = str(max_health)
	$Look/CollisionShape2D.shape.radius = look_dist

func _input(event):
	if not event is InputEventKey: return
	if event.key_label != debug_key: return
	if not event.is_pressed(): return
	
	nav.target_position = get_global_mouse_position()

func _process(delta):
	strat.function(delta)

func _physics_process(delta):
	strat.physics_function(delta)
	
	if nav.is_target_reached(): return
	if is_on_wall(): stuck_counter += delta
	if stuck_counter > 0.25:
		nav.target_position = global_position + get_wall_normal()
		stuck_counter = 0.0
	
	var dir = to_local(nav.get_next_path_position()).normalized()
	velocity = dir * (speed - slow) * delta
	move_and_slide()

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
	hit_graphic.look_at(area.global_position)
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
	
	x.health.text = str(int(x.health.text) - damage)
	if int(x.health.text) < 1:
		is_in_fight = false
		x.queue_free()
		return
	fight(area, x)

func fight(area: Area2D, x: Node):
	var d = global_position.direction_to(nav.target_position)
	nav.target_position = global_position - (d * 3)
	timer.start((2.5 + randf_range(0.0,0.25)) - (attack_speed/10))
	await timer.timeout
	if not zone.overlaps_area(area):
		is_in_fight = false
		return
	hit_graphic.look_at(area.global_position)
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
	x.health.text = str(int(x.health.text) - damage)
	if int(x.health.text) < 1:
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
