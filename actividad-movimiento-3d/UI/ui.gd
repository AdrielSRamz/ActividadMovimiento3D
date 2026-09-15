extends Node

@onready var player = $"../Player"
@onready var label = $CanvasLayer/Label

func _ready() -> void:
	player.monedapick.connect(actualizar_contador)
	
func actualizar_contador(cantidad):
	label.text = "MONEDAS: " + str(cantidad)
