extends Node3D

@onready var player = $CharacterBody3D

@export var speed = 14
@export var aceleracion_caida = 75

var target_velocity = Vector3.ZERO
@export var impulso_salto = 20
var doblesalto = true

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("adelante"):
		direction.z -= 1
	if Input.is_action_pressed("atras"):
		direction.z += 1
	if Input.is_action_pressed("derecha"):
		direction.x += 1
	if Input.is_action_pressed("izquierda"):
		direction.x -= 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$CharacterBody3D/pivot.basis = Basis.looking_at(direction)
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	if not player.is_on_floor():
		target_velocity.y = target_velocity.y - (aceleracion_caida * delta)
		if Input.is_action_just_pressed("salto") and doblesalto == true:
			target_velocity.y = impulso_salto
			doblesalto = false
	
	player.velocity = target_velocity
	
	if player.is_on_floor():
		doblesalto = true
		if Input.is_action_just_pressed("salto"):
			target_velocity.y = impulso_salto
	
	
	player.move_and_slide()
