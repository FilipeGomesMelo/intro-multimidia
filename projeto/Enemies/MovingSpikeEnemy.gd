tool
extends Path2D

enum ANIMATION_TYPE {
	LOOP,
	BOUNCE
}

export(ANIMATION_TYPE) var animation_type setget set_animation_type
export(float) var speed = 1 setget set_speed


onready var animationPlayer: = $AnimationPlayer

func _ready():
	update_animation(animationPlayer)
	update_speed(animationPlayer)

func set_animation_type(value):
	animation_type = value
	var ap: AnimationPlayer = find_node("AnimationPlayer")
	if ap: update_animation(ap)

func set_speed(value):
	speed = value
	var ap = find_node("AnimationPlayer")
	if ap: update_speed(ap)

func update_speed(ap: AnimationPlayer):
	match animation_type:
		ANIMATION_TYPE.LOOP: ap.playback_speed = speed / curve.get_baked_length()
		ANIMATION_TYPE.BOUNCE: ap.playback_speed = 0.5 * speed / curve.get_baked_length()

func update_animation(ap):
	match animation_type:
		ANIMATION_TYPE.LOOP: ap.play("MoveAlongPathLoop")
		ANIMATION_TYPE.BOUNCE: ap.play("MoveAlongPathBounce")
