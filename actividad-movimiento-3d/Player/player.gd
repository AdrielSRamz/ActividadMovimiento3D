extends Node3D

@onready var player = $CharacterBody3D
@onready var camara = $CharacterBody3D/SpringArm3D/Camera3D

@export var speed = 14
@export var aceleracion_caida = 75
@export var impulso_salto = 20
@export var dash_velocidad = 50
@export var slide_speed = 15.0
@export var min_tilt_slide = 20.0

signal monedapick(cantidad)

var target_velocity = Vector3.ZERO
var doblesalto = true
var dash = true
var en_dash = false
var final_direction = Vector3.ZERO
var monedas = 0

func _ready() -> void:
	monedas = 0

func _process(delta: float) -> void:
	if monedas == 3:
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	var adelante = camara.global_transform.basis.z
	var derecha = camara.global_transform.basis.x
	
	if Input.is_action_pressed("adelante"):
		direction -= adelante
	if Input.is_action_pressed("atras"):
		direction += adelante
	if Input.is_action_pressed("derecha"):
		direction += derecha
	if Input.is_action_pressed("izquierda"):
		direction -= derecha
	
	if direction != Vector3.ZERO:
		direction.y = 0
		direction = direction.normalized()
		final_direction = direction
		$CharacterBody3D/pivot.basis = Basis.looking_at(direction)
	
	if Input.is_action_just_pressed("dash") and dash and direction != Vector3.ZERO:
		hacer_dash(direction)
	if en_dash:
		player.move_and_slide()
		return
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
	
		slide(delta)
	
	player.move_and_slide()

func hacer_dash(direction: Vector3)->void:
	dash = false
	en_dash = true
	
	player.velocity = direction * dash_velocidad
	player.velocity.y = 0
	
	var dash_duration = 0.2
	await get_tree().create_timer(dash_duration).timeout
	
	en_dash = false
	
	var dash_cooldown = 2.0
	await get_tree().create_timer(dash_cooldown).timeout
	
	dash = true

func aumentar_monedas():
	monedas += 1
	monedapick.emit(monedas)

func slide(delta: float) -> void:
	if not player.is_on_floor():
		return
	
	
	var normal_suelo = player.get_floor_normal()
	var angulo = rad_to_deg(acos(normal_suelo.dot(Vector3.UP)))
	
	if angulo >= min_tilt_slide:
		var direccion_caida = Vector3.DOWN.slide(normal_suelo).normalized()
		
		target_velocity.x = direccion_caida.x * slide_speed * delta
		target_velocity.z = direccion_caida.z * slide_speed * delta
