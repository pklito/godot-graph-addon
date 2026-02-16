extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.global_shader_parameter_set("apply_screen_shader", true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
