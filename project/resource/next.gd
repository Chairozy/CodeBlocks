extends Area2D

@export var is_preview := false

func _ready():
	if is_preview:
		body_entered.connect(func(body):
			if body.has_method(&"goal"):
				body.call(&"goal", self)
			)
	else:
		is_preview = true
