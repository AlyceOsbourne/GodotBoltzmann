class_name TrainingCase
extends Resource

var inputs: Array[Dictionary]
var target: Dictionary

func _init(_inputs: Array[Dictionary], _target: Dictionary) -> void:
    inputs = _inputs
    target = _target
