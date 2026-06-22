extends Strategy

func physics_function(delta: float):
	var a: Array[Node3D] = parent.scanner.get_overlapping_bodies()
	
	if parent.health < 4:
		for n in a:
			if n is CharacterBody3D and not n == parent:
				parent.slow = 0
				var p = (Vector3.ZERO - (n.global_position - parent.global_position)).normalized()
				parent.tester.global_position = p * (parent.look_dist + 32)
				# wall
				if parent.tester.get_overlapping_bodies() != []:
					evade()
					return
				# floor
				if not parent.tester2.is_colliding():
					evade()
					return
				parent.nav.target_position = p * (parent.look_dist + 2)
				return
	
	if parent.is_in_fight: return
	
	# agressively charge characters
	for n in a:
		if n is CharacterBody3D and not n == parent:
			parent.slow = 0
			get_parent().nav.target_position = n.global_position
			return
	
	# agressively charge buildings
	for n in a:
		if n.name.begins_with("Building"):
			parent.slow = 0
			print("b")
			get_parent().nav.target_position = n.global_position
			return
	
	if not parent.nav.is_navigation_finished():
		return
	
	
	# upgrades are low priority
	
	# wander
	if parent.health > (parent.max_health / 8) - 1: parent.slow = parent.speed / 7.0
	var loc: Vector3 = Vector3(randi_range(-2, 2), 1, randi_range(-2, 2)) * 20
	parent.tester.global_position = loc + parent.global_position
	parent.tester.global_position.y = 0
	# wall
	if parent.tester.get_overlapping_bodies() != []: return
	# floor
	if not parent.tester2.is_colliding(): return
	get_parent().nav.target_position = loc + parent.global_position
	

func evade():
	if not parent.nav.is_target_reached(): return
	while true:
		for n: int in 64:
			var loc: Vector3 = Vector3(randi_range(-3, 3), 1, randi_range(-3, 3)) * 10
			parent.tester.global_position = loc + parent.global_position
			# wall
			if parent.tester.get_overlapping_bodies() == [] and\
				parent.tester2.is_colliding() and\
					abs(loc.distance_to(parent.global_position)) > 30:
						get_parent().nav.target_position = loc + parent.global_position
						return
		await get_tree().create_timer(0).timeout
