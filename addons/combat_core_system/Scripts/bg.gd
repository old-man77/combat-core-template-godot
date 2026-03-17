extends ParallaxBackground


@export var scroll_speed = Vector2(50, 50) 
@onready var bg : ParallaxLayer = $ParallaxLayer

func _process(delta):
	bg.motion_offset += scroll_speed * delta 
