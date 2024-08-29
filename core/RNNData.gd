
class_name RNNData
extends Resource

@export var n_visible: int
@export var n_hidden: int = -1:
    get:
        if n_hidden == -1 and n_visible != 0 and n_hidden != 0:
            n_hidden = n_visible + n_output
        return n_hidden
@export var n_output: int


@export_storage var weights_vh: PackedFloat64Array
@export_storage var weights_ho: PackedFloat64Array
@export_storage var visible_bias: PackedFloat64Array
@export_storage var hidden_bias: PackedFloat64Array
@export_storage var output_bias: PackedFloat64Array

@export_storage var ready = false:
    get:
        if [n_visible, n_hidden, n_output].any(func(x): return x == 0):
            return false
        if not ready:
            get_ready()
            ready = true
        return ready
    set(v):
        if not v:
            trained = false
        ready = v

@export_storage var trained = false

func get_ready() -> void:
    weights_vh = []
    weights_ho = []
    visible_bias = []
    hidden_bias = []
    output_bias = []

    randomize()
    weights_vh.resize(n_visible * n_hidden)
    weights_ho.resize(n_hidden * n_output)
    visible_bias.resize(n_visible)
    hidden_bias.resize(n_hidden)
    output_bias.resize(n_output)

    for i in range(weights_vh.size()):
        weights_vh[i] = randf() * 0.0001

    for i in range(weights_ho.size()):
        weights_ho[i] = randf() * 0.0001

    for i in range(visible_bias.size()):
        visible_bias[i] = 0.0

    for i in range(hidden_bias.size()):
        hidden_bias[i] = 0.0

    for i in range(output_bias.size()):
        output_bias[i] = 0.0
