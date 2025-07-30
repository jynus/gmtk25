extends CharacterBody2D


const SPEED = 400.0


func _physics_process(_delta: float) -> void:
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")

	velocity = direction * SPEED

	move_and_slide()
