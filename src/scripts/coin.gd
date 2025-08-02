extends Area2D

var value : int = 1

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("hero"):
		Fx.coin_pickup.play()
		if body and body.has_method("pickup_coin"):
			body.pickup_coin(value)
		queue_free()

func _on_timer_visible_timeout() -> void:
	show()

func _on_timer_despawn_timeout() -> void:
	%AnimationPlayer.play("about_to_dissapear")
	await %AnimationPlayer.animation_finished
	queue_free()
