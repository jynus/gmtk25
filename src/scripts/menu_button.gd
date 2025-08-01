class_name CustomMenuButton
extends Button

func _on_button_down() -> void:
	Fx.click.play()


func _on_pressed() -> void:
	disabled = true
