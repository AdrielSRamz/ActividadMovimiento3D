extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.get_parent().aumentar_monedas()
	queue_free()
