extends Area2D

@export var powerup:Globals.powerup

func _on_area_entered(area: Node2D) -> void:
	if area.is_in_group("hero") and area.has_method("show_powerup"):
		area.show_powerup(powerup)

func _on_area_exited(area: Node2D) -> void:
	if area.is_in_group("hero") and area.has_method("hide_powerup"):
		area.hide_powerup()
