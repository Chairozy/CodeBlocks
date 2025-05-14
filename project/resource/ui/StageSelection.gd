extends TextureButton

@export var level = 0
@export var starts = 0
const EMPTY_STAR = Rect2i(560, 112, 16, 16)
const FILL_STAR = Rect2i(528, 112, 16, 16)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Number.text = str(level)
	var istar = 0
	for i in range(3):
		istar += 1
		var star = get_node("Star" + str(istar)) as TextureRect
		star.texture.region = FILL_STAR if i < starts else EMPTY_STAR
