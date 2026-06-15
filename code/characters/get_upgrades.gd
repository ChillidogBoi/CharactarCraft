extends Area2D

var parent: CharacterBody2D

func _ready():
	parent = get_parent()

func _on_body_entered(body):
	print(body.name)
	if not body is Upgrade: return
	if body.name.begins_with("HealthRefil"):
		parent.health.text = str(clamp(int(parent.health.text) + body.value, 0, parent.max_health))
		body.queue_free()
