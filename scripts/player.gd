extends CharacterBody3D

var sensitivity = 0.0025
var speed = 4
var jump_velocity = 4.5
var gravity = 9.82
var direction
var is_wallrunning = false
var is_running = false
var input_dir
var wall_direction
var double_jump = true
var is_mouse_captured
var ammo = 30
var is_reloading = false
var is_on_a_wall
var is_on_l_wall # Left
var is_on_r_wall # Right
var is_on_b_wall # Back
var wall_jump
var is_ads = false
var is_paused = false
var wall_parallel
var wall_normal_values

# Creates a new bullet scene on call
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
@onready var sens_slider = $"HUD/Options Screen/Controls/Sensitivity"

signal paused

# Handles mouse focus
func _unhandled_input(event):
	sensitivity = SettingsManager.settings_dict["controls"]["sensitivity"]

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_mouse_captured = false
		paused.emit()
		is_paused = true

	# Rotates the camera
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * sensitivity)
			camera.rotate_x(-event.relative.y * sensitivity)
			# Limit to up and down rotation
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _physics_process(delta):
	# If the player falls outside the map, respawn
	if position.y < -10:
		position.x = 0
		position.y = 2
		position.z = 0

	# Reloads the gun
	if Input.is_action_just_pressed("reload") and ammo < 30:
		$Reload.start()
		is_reloading = true
		reloading_icon.text = "Reloading..."

	# Creates gravity
	if !is_on_floor():
		velocity.y -= gravity * delta

	# Handles jumping
	if Input.is_action_just_pressed("jump") and !is_paused:
		if is_on_floor():
			velocity.y = jump_velocity
		elif double_jump and !is_wallrunning:
			velocity.y = jump_velocity
			velocity.x = direction.x * speed / 1.5 + velocity.x
			velocity.z = direction.z * speed / 1.5 + velocity.z
			double_jump = false

	# Regenerates double jump when on a surface
	if is_on_floor() or is_on_a_wall:
		double_jump = true

	# Moves the character IF they are not wallrunning
	if !is_wallrunning:
		if !is_paused:
			input_dir = Input.get_vector("left", "right", "forward", "backward")
		direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if is_on_floor():
			if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)

		# If the player is midair
		else:
			if direction:
				velocity.x += direction.x * 0.04
				velocity.z += direction.z * 0.04

				# Maximum velocity while falling
				if velocity.length() > 20:
					velocity = velocity.normalized() * 20

	# Fires a bullet
	if Input.is_action_pressed("shoot") and is_mouse_captured and !is_reloading:
		if !gun_anim.is_playing() and ammo > 0:
			gun_anim.play("recoil")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			camera.rotation.x += deg_to_rad(0.75)
			if camera.rotation.x > deg_to_rad(85):
				camera.rotation.x = deg_to_rad(85)
			get_parent().add_child(instance)
			ammo -= 1

	# Aim down sights
	if Input.is_action_pressed("aim") and !is_paused:
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
	sprint()

func wall_run():
	if is_on_l_wall or is_on_r_wall or is_on_b_wall:
		is_on_a_wall = true
	else:
		is_on_a_wall = false

	wall_normal_values = get_wall_normal_from_rays()
	if wall_normal_values != null:
		wall_parallel = Vector3(wall_normal_values.z, 0, -wall_normal_values.x).normalized() * 1.75

	# Checks if the wallrunning requirements are met and handles it
	if is_on_a_wall and is_running and !is_on_floor() and Input.is_action_pressed("forward"):
		if !is_wallrunning:
			is_wallrunning = true

			if is_on_l_wall and !is_on_r_wall:
				wall_direction = "left"
			elif !is_on_l_wall and is_on_r_wall:
				wall_direction = "right"

		# Smoothly nullifies the vertical velocity if velocity.y is negative
		if velocity.y < 0:
			velocity.y += 0.075

		# Assigns velocity and flips depending on direction
		if wall_direction == "left" and !wall_jump:
			velocity.x = wall_parallel.x * speed 
			velocity.z = wall_parallel.z * speed
		elif wall_direction == "right" and !wall_jump:
			velocity.x = wall_parallel.x * speed * -1
			velocity.z = wall_parallel.z * speed * -1


		# Handles walljumping
		if Input.is_action_just_pressed("jump") and abs(velocity.y) < 1:
			velocity += wall_normal_values * 5
			velocity.y = 6
			wall_jump = true

		# Tilts the camera
		if wall_direction == "right" and camera.rotation.z < deg_to_rad(5):
			camera.rotation.z += 0.003
		elif wall_direction == "left" and camera.rotation.z > deg_to_rad(-5):
			camera.rotation.z -= 0.003

	else:
		is_wallrunning = false
		wall_jump = false
		if camera.rotation.z > 0:
			camera.rotation.z -= 0.003
		elif camera.rotation.z < 0:
			camera.rotation.z += 0.003

func _on_h_slider_value_changed(value):
	# Sensitivity slider
	sensitivity = value * 0.0001

func _on_check_right_no_hit():
	is_on_r_wall = false

func _on_check_left_no_hit():
	is_on_l_wall = false

func _on_check_right_hit():
	is_on_r_wall = true

func _on_check_left_hit():
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

# In the future maybe rewrite this with a for-loop. Current code isn't well made but works
func get_wall_normal_from_rays():
	var wall_normal_val

	if is_on_l_wall and !is_on_r_wall:
		var left = $Neck/CheckLeft
		var leftU = $Neck/CheckLeft/CheckLU
		var leftUU = $Neck/CheckLeft/CheckLU/CheckLUU
		var leftUD = $Neck/CheckLeft/CheckLU/CheckLUD
		var leftD = $Neck/CheckLeft/CheckLD
		var leftDU = $Neck/CheckLeft/CheckLD/CheckLDU
		var leftDD = $Neck/CheckLeft/CheckLD/CheckLDD

		if leftUU.is_colliding():
			wall_normal_val = leftUU.get_collision_normal()
		elif leftU.is_colliding():
			wall_normal_val = leftU.get_collision_normal()
		elif leftUD.is_colliding():
			wall_normal_val = leftUD.get_collision_normal()
		elif left.is_colliding():
			wall_normal_val = left.get_collision_normal()
		elif leftDU.is_colliding():
			wall_normal_val = leftDU.get_collision_normal()
		elif leftD.is_colliding():
			wall_normal_val = leftD.get_collision_normal()
		elif leftDD.is_colliding():
			wall_normal_val = leftDD.get_collision_normal()

	elif !is_on_l_wall and is_on_r_wall:
		var right = $Neck/CheckRight
		var rightU = $Neck/CheckRight/CheckRU
		var rightUU = $Neck/CheckRight/CheckRU/CheckRUU
		var rightUD = $Neck/CheckRight/CheckRU/CheckRUD
		var rightD = $Neck/CheckRight/CheckRD
		var rightDU = $Neck/CheckRight/CheckRD/CheckRDU
		var rightDD = $Neck/CheckRight/CheckRD/CheckRDD

		if rightUU.is_colliding():
			wall_normal_val = rightUU.get_collision_normal()
		elif rightU.is_colliding():
			wall_normal_val = rightU.get_collision_normal()
		elif rightUD.is_colliding():
			wall_normal_val = rightUD.get_collision_normal()
		elif right.is_colliding():
			wall_normal_val = right.get_collision_normal()
		elif rightDU.is_colliding():
			wall_normal_val = rightDU.get_collision_normal()
		elif rightD.is_colliding():
			wall_normal_val = rightD.get_collision_normal()
		elif rightDD.is_colliding():
			wall_normal_val = rightDD.get_collision_normal()

	elif is_on_b_wall:
		var back = $Neck/CheckBack

		if back.is_colliding():
			wall_normal_val = back.get_collision_normal()
	
	else:
		wall_normal_val = null

	return wall_normal_val

func HUD():
	# Updates the ammo counter
	ammo_counter.text = "%s/30" % ammo
	if is_mouse_captured and !is_ads:
		crosshair.visible = true
	else:
		crosshair.visible = false

func _on_hud_unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	is_mouse_captured = true
	is_paused = false

func sprint():
	var settings = SettingsManager.settings_dict

	# Hold to run
	if settings["controls"]["sprint mode"] == 0:
		if Input.is_action_pressed("sprint"):
			speed = 8
			is_running = true
		else:
			speed = 4
			is_running = false
	# Toggle sprint
	elif settings["controls"]["sprint mode"] == 1:
		# Replace velocity with something that checks if WASD is pressed
		if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			if Input.is_action_just_pressed("sprint") and !is_running:
				is_running = true
				speed = 8
			elif Input.is_action_just_pressed("sprint") and is_running:
				is_running = false
				speed = 4
		else:
			is_running = false
			speed = 4
