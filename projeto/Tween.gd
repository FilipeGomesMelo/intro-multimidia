extends Tween

func _ready():
	self.interpolate_property(self, "module:a", 1.0, 0.0, 0.5, 3, 1)
	self.start()
