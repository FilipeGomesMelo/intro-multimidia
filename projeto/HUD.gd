extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_charge(current_charge, max_charge):
	$nrg/nrg_empty.set_size(Vector2(32*max_charge, 32))
	$nrg/nrg_charged.set_size(Vector2(32*current_charge, 32))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
