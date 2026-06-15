extends Strategy

func physics_function(delta: float):
	var a: Array[Node2D] = parent.scanner.get_overlapping_bodies()
	
	if int(parent.health.text) < parent.max_health / 4:
		for n in a:
			if n is Upgrade:
				parent.slow = 0
				get_parent().nav.target_position = n.global_position
				return
		for n in a:
			if n is CharacterBody2D and not n == parent:
				parent.slow = 0
				var p = (Vector2.ZERO - (n.global_position - parent.global_position)).normalized()
				parent.tester.global_position = p * (parent.look_dist + 32)
				# wall
				if parent.tester.get_overlapping_bodies() != []:
					evade()
					return
				# floor
				if parent.tester2.get_overlapping_bodies() == []:
					evade()
					return
				parent.nav.target_position = p * (parent.look_dist + 32)
				return
	
	if parent.is_in_fight: return
	
	# agressively charge characters
	for n in a:
		if n is CharacterBody2D and not n == parent:
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
	
	if not parent.nav.is_target_reached(): return
	
	# upgrades are low priority
	for n in a:
		if n is Upgrade:
			parent.slow = 0
			get_parent().nav.target_position = n.global_position
			return
	
	# wander
	if int(parent.health.text) > (parent.max_health / 4) - 1: parent.slow = parent.speed / 2
	var loc: Vector2 = Vector2(randi_range(-2, 2), randi_range(-2, 2)) * 160
	parent.tester.global_position = loc + parent.global_position
	# wall
	if parent.tester.get_overlapping_bodies() != []: return
	# floor
	if parent.tester2.get_overlapping_bodies() == []: return
	print(loc + parent.global_position)
	get_parent().nav.target_position = loc + parent.global_position

func evade():
	if not parent.nav.is_target_reached(): return
	while true:
		for n: int in 64:
			var loc: Vector2 = Vector2(randi_range(-3, 3), randi_range(-3, 3)) * 64
			parent.tester.global_position = loc + parent.global_position
			# wall
			if parent.tester.get_overlapping_bodies() == [] and\
				parent.tester2.get_overlapping_bodies() != [] and\
					loc.distance_to(parent.global_position) > 128:
						print(loc + parent.global_position)
						get_parent().nav.target_position = loc + parent.global_position
						return
		await get_tree().create_timer(0).timeout
