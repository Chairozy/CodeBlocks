extends TextureRect

@export var autoplay: bool = false

func replay():
	if autoplay:
		play()
	else:
		play_fail()

func play():
	$AnimationPlayer.play("Fill")

func play_fail():
	$AnimationPlayer.play("Fail")
