extends CharacterBody3D

var sensitivity = 0.0025
var speed
var jump_velocity = 5
var gravity = 9.8
var direction
var is_wallrunning
var is_running
var input_dir
var wallrun_timeout = false
var wall_direction
var double_jump = true
var is_mouse_captured
var ammo = 30
var is_reloading = false
var is_on_a_wall
var are_rays_detecting
var is_on_l_wall # Left
var is_on_r_wall # Right
var is_on_b_wall # Back
var wall_jump
var wall_normal
var same_wall = false
var old_wall_normal
var wall_normal_values
var is_ads = false

# Creates a new bullet scene on call.
var bullet = load("res://scenes/bullet.tscn")
var instance

@onready var neck = $Neck
@onready var camera = $Neck/Camera3D
@onready var gun = $Neck/Camera3D/AssaultRifle
@onready var gun_anim = $Neck/Camera3D/AssaultRifle/AnimationPlayer
@onready var crosshair = $HUD/Crosshair
@onready var gun_barrel = $Neck/Camera3D/AssaultRifle/RayCast3D
@onready var ammo_counter = $HUD/AmmoCounter
@onready var reloading_icon = $HUD/Reloading

signal paused
signal resumed

# Handles mouse focus.
func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_mouse_captured = true
		resumed.emit()
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_mouse_captured = false
		paused.emit()

	# Rotates the camera.
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * sensitivity)
			camera.rotate_x(-event.relative.y * sensitivity)
			# Limit to up and down rotation.
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-75), deg_to_rad(75))

func _physics_process(delta):
	# If the player falls outside the map, respawn.
	if position.y < -10:
		position.x = 0
		position.y = 2
		position.z = 0

	# Reloads the gun.
	if Input.is_action_just_pressed("reload") and ammo < 30:
		$Reload.start()
		is_reloading = true
		reloading_icon.text = "Reloading..."

	# Creates gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta

	# Handles jumping.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif double_jump and !is_on_a_wall:
			velocity.y = jump_velocity
			velocity.x = direction.x * speed / 1.5 + velocity.x
			velocity.z = direction.z * speed / 1.5 + velocity.z
			double_jump = false

	# Regenerates double jump when on a surface.
	if is_on_floor() or is_on_a_wall:
		double_jump = true

	# Handles sprinting.
	if Input.is_action_pressed("run"):
		speed = 7
		is_running = true
	else:
		speed = 4
		is_running = false

	# Moves the character IF they are not wallrunning.
	if !is_wallrunning:
		input_dir = Input.get_vector("left", "right", "forward", "backward")
		direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if is_on_floor():
			if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)

		# If the player is midair.
		else:
			if direction:
				velocity.x += direction.x * 0.02
				velocity.z += direction.z * 0.02

				# Maximum velocity while falling. NEEDS WORK, CAUSES BUG.
				if velocity.x > 10:
					velocity.x = 10
				elif velocity.x < -10:
					velocity.x = -10
				if velocity.z > 10:
					velocity.z = 10
				elif velocity.z < -10:
					velocity.z = -10

	# Fires a bullet.
	if Input.is_action_pressed("shoot") and is_mouse_captured and !is_reloading:
		if !gun_anim.is_playing() and ammo > 0:
			gun_anim.play("recoil")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			camera.rotation.x += deg_to_rad(0.75)
			if camera.rotation.x > deg_to_rad(75):
				camera.rotation.x = deg_to_rad(75)
			get_parent().add_child(instance)
			ammo -= 1

	# Aim down sights.
	if Input.is_action_pressed("aim"):
		gun.position.x = 0
		gun.position.y = -0.225
		gun.position.z = -0.45
		gun.rotation.y = 0
		camera.fov = 70
		is_ads = true
	else:
		gun.position.x = 0.25
		gun.position.y = -0.3
		gun.position.z = -0.6
		gun.rotation.y = deg_to_rad(0.5)
		camera.fov = 90
		is_ads = false

	move_and_slide()
	wall_run()
	HUD()

func wall_run():
	if old_wall_normal == wall_normal:
		same_wall = true

	if is_on_l_wall or is_on_r_wall or is_on_b_wall:
		is_on_a_wall = true
	else:
		is_on_a_wall = false

	if is_on_a_wall and Input.is_action_pressed("forward") and is_running and !wallrun_timeout and !same_wall and !is_on_floor():
		# Runs on the first instance.
		if !is_wallrunning:
			is_wallrunning = true

			# Decides the velocity of the player.
			direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			velocity.x = direction.x * speed * 1.75
			velocity.z = direction.z * speed * 1.75

			# Decides the direction of the wall normal, used for walljumping and blocking wallrun-chaining.
			wall_normal_values = get_wall_normal_from_rays()
			if wall_normal_values != null:
				direction = Vector3(wall_normal_values)
				wall_normal = rad_to_deg(atan2(direction.z, direction.x))

			# Starts a timer until the player falls off the wall.
			wallrun_timeout = false
			$WallrunTimer.start() 

		# Handles walljumping.
		if Input.is_action_just_pressed("jump"):
			velocity += direction * 7.5
			velocity.y = 7.5
			wall_jump = true

		# Leans the head away from the wall.
		if wall_direction == "r":
			camera.rotation.z = deg_to_rad(5)
		elif wall_direction == "l":
			camera.rotation.z = deg_to_rad(-5)

		if !wall_jump:
			velocity.y = 0

	# Runs when the player stops wallrunning.
	else:
		camera.rotation.z = 0
		is_wallrunning = false
		wall_jump = false
		wallrun_timeout = false
		$WallrunTimer.stop()
		
		# Saves the wall normal direction in order to prevent the use of the same wall
		if !is_on_floor():
			if wall_normal != null:
				old_wall_normal = wall_normal
				wall_normal = null
		else:
			old_wall_normal = NAN
			same_wall = false

# Sensitivity slider.
func _on_h_slider_value_changed(value):
	sensitivity = value * 0.0001

func _on_check_right_no_hit():
	is_on_r_wall = false

func _on_check_left_no_hit():
	is_on_l_wall = false

func _on_check_right_hit():
	wall_direction = "r"
	is_on_r_wall = true

func _on_check_left_hit():
	wall_direction = "l"
	is_on_l_wall = true

func _on_reload_timeout():
	$Reload.stop()
	ammo = 30
	is_reloading = false
	reloading_icon.text = ""

func _on_check_back_hit():
	is_on_b_wall = true

func _on_check_back_no_hit():
	is_on_b_wall = false

# In the future maybe rewrite this with a for-loop. Current code isn't well made but works.
func get_wall_normal_from_rays():
	var wall_normal

	if is_on_l_wall and !is_on_r_wall:
		var left = $Neck/CheckLeft
		var leftU = $Neck/CheckLeft/CheckLU
		var leftUU = $Neck/CheckLeft/CheckLU/CheckLUU
		var leftUD = $Neck/CheckLeft/CheckLU/CheckLUD
		var leftD = $Neck/CheckLeft/CheckLD
		var leftDU = $Neck/CheckLeft/CheckLD/CheckLDU
		var leftDD = $Neck/CheckLeft/CheckLD/CheckLDD

		if leftUU.is_colliding():
			wall_normal = leftUU.get_collision_normal()
		elif leftU.is_colliding():
			wall_normal = leftU.get_collision_normal()
		elif leftUD.is_colliding():
			wall_normal = leftUD.get_collision_normal()
		elif left.is_colliding():
			wall_normal = left.get_collision_normal()
		elif leftDU.is_colliding():
			wall_normal = leftDU.get_collision_normal()
		elif leftD.is_colliding():
			wall_normal = leftD.get_collision_normal()
		elif leftDD.is_colliding():
			wall_normal = leftDD.get_collision_normal()

	elif !is_on_l_wall and is_on_r_wall:
		var right = $Neck/CheckRight
		var rightU = $Neck/CheckRight/CheckRU
		var rightUU = $Neck/CheckRight/CheckRU/CheckRUU
		var rightUD = $Neck/CheckRight/CheckRU/CheckRUD
		var rightD = $Neck/CheckRight/CheckRD
		var rightDU = $Neck/CheckRight/CheckRD/CheckRDU
		var rightDD = $Neck/CheckRight/CheckRD/CheckRDD

		if rightUU.is_colliding():
			wall_normal = rightUU.get_collision_normal()
		elif rightU.is_colliding():
			wall_normal = rightU.get_collision_normal()
		elif rightUD.is_colliding():
			wall_normal = rightUD.get_collision_normal()
		elif right.is_colliding():
			wall_normal = right.get_collision_normal()
		elif rightDU.is_colliding():
			wall_normal = rightDU.get_collision_normal()
		elif rightD.is_colliding():
			wall_normal = rightD.get_collision_normal()
		elif rightDD.is_colliding():
			wall_normal = rightDD.get_collision_normal()

	elif is_on_b_wall:
		var back = $Neck/CheckBack

		if back.is_colliding():
			wall_normal = back.get_collision_normal()
	
	else:
		wall_normal = null

	return wall_normal

func _on_wallrun_timer_timeout():
	$WallrunTimer.stop()
	wallrun_timeout = true

func HUD():

	# Updates the ammo counter.
	ammo_counter.text = "%s/30" % ammo
	if is_mouse_captured and !is_ads:
		crosshair.visible = true
	else:
		crosshair.visible = false

func _on_hud_unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	is_mouse_captured = true

func _on_hud_pause():
	pass
