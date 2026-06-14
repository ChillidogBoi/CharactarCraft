extends CharacterBody2D

@export var debug_key: Key

@export_category("Stats")
@export var speed: int = 6000
@export var damage: int
@export var attack_speed: float

@export_category("Nodes")
@export var nav: NavigationAgent2D
@export var health: Label
@export var timer: Timer
@export var zone: Area2D
@export var sprite: Node2D
@export var hit_graphic: Node2D

var sub: bool = false
signal hit


func _input(event):
	if not event is InputEventKey: return
	if event.key_label != debug_key: return
	if not event.is_pressed(): return
	
	nav.target_position = get_global_mouse_position()

func _physics_process(delta):
	if nav.is_target_reached(): return
	var dir = to_local(nav.get_next_path_position()).normalized()
	velocity = dir * speed * delta
	move_and_slide()


func _on_area_2d_area_entered(area):
	if timer.is_stopped(): timer.start((2.5 + randf_range(0.0,0.25)) - (attack_speed/10))
	await timer.timeout
	if not zone.overlaps_area(area): return
	var x = area.get_parent()
	if sub:
		timer.start((2.5 - randf_range(0.0,0.25)) - (attack_speed/10))
		await timer.timeout
	else: x.sub = true
	hit_graphic.look_at(area.global_position)
	hit_graphic.visible = true
	await get_tree().create_timer(0.025).timeout
	x.hit.emit()
	await get_tree().create_timer(0.025).timeout
	hit_graphic.visible = false
	x.health.text = str(int(x.health.text) - damage)
	if int(x.health.text) < 1:
		x.queue_free()
		return
	fight(area, x)

func fight(area: Area2D, x: Node):
	timer.start((2.5 + randf_range(0.0,0.25)) - (attack_speed/10))
	await timer.timeout
	print(sub)
	if not zone.overlaps_area(area): return
	hit_graphic.look_at(area.global_position)
	hit_graphic.visible = true
	await get_tree().create_timer(0.025).timeout
	x.hit.emit()
	await get_tree().create_timer(0.025).timeout
	hit_graphic.visible = false
	x.health.text = str(int(x.health.text) - damage)
	if int(x.health.text) < 1:
		x.queue_free()
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
