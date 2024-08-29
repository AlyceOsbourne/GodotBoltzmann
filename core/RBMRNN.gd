class_name RestrictedBoltzmannMachine
extends Resource


enum ActivationFunction {
    SIGMOID,
    TANH,
    RELU,
    LEAKY_RELU,
    ELU,
    SOFTPLUS
}

const leaky_relu_alpha: float = 0.1
const elu_alpha: float = 1.0

@export var rnn_data: RNNData:
    get:
        if rnn_data == null:
            rnn_data = RNNData.new()
        return rnn_data

@export var activation_function: ActivationFunction = ActivationFunction.SIGMOID

@export_category("Training Settings")
@export var learning_rate: float = 0.2
@export var epochs: int = 20000
@export var threshold: float = 0.001

func _ready() -> void:
    assert(rnn_data, "RNNData resource is not set.")
    assert(rnn_data.ready, "RNNData is not ready.")

func _apply_activation(x: float) -> float:
    match activation_function:
        ActivationFunction.SIGMOID:
            return 1.0 / (1.0 + exp(-x))
        ActivationFunction.TANH:
            return tanh(x)
        ActivationFunction.RELU:
            return max(0, x)
        ActivationFunction.LEAKY_RELU:
            return x if x > 0 else leaky_relu_alpha * x
        ActivationFunction.ELU:
            return x if x > 0 else elu_alpha * (exp(x) - 1.0)
        ActivationFunction.SOFTPLUS:
            return log(1.0 + exp(x))
        -1: return x
        _:
            push_error("Unsupported activation function")
            return x

func _sample_hidden_layer(visible: Array[float]) -> PackedFloat64Array:
    var activation: Array[float] = []
    for i in range(rnn_data.n_hidden):
        var sum = 0.0
        for j in range(rnn_data.n_visible):
            sum += visible[j] * rnn_data.weights_vh[j * rnn_data.n_hidden + i]
        activation.append(_apply_activation(sum + rnn_data.hidden_bias[i]))
    return activation

func _sample_output_layer(hidden: Array[float]) -> PackedFloat64Array:
    var activation: Array[float] = []
    for i in range(rnn_data.n_output):
        var sum = 0.0
        for j in range(rnn_data.n_hidden):
            sum += hidden[j] * rnn_data.weights_ho[j * rnn_data.n_output + i]
        activation.append(_apply_activation(sum + rnn_data.output_bias[i]))
    return activation

func _sample_visible_layer(hidden: Array[float]) -> PackedFloat64Array:
    var activation: Array[float] = []
    for i in range(rnn_data.n_visible):
        var sum = 0.0
        for j in range(rnn_data.n_hidden):
            sum += hidden[j] * rnn_data.weights_vh[i * rnn_data.n_hidden + j]
        activation.append(sum + rnn_data.visible_bias[i])
    return activation

func train(data: Array, target_output: Array) -> void:
    assert(rnn_data.ready, "Please make sure the RNNData is ready.")
    rnn_data.trained = true
    for epoch in range(epochs):
        for sample_index in range(data.size()):
            var sample: Array[float] = []
            sample.assign(data[sample_index])
            var target = target_output[sample_index]

            var hidden_probabilities = _sample_hidden_layer(sample)
            var positive_associations_vh = []
            var positive_associations_ho = []

            for i in range(rnn_data.n_visible):
                for j in range(rnn_data.n_hidden):
                    positive_associations_vh.append(sample[i] * hidden_probabilities[j])

            for i in range(rnn_data.n_hidden):
                for j in range(rnn_data.n_output):
                    positive_associations_ho.append(hidden_probabilities[i] * target[j])

            var visible_reconstruction = _sample_visible_layer(hidden_probabilities)
            var hidden_probabilities_reconstruction = _sample_hidden_layer(visible_reconstruction)
            var output_reconstruction = _sample_output_layer(hidden_probabilities_reconstruction)

            var negative_associations_vh = []
            var negative_associations_ho = []

            for i in range(rnn_data.n_visible):
                for j in range(rnn_data.n_hidden):
                    negative_associations_vh.append(visible_reconstruction[i] * hidden_probabilities_reconstruction[j])

            for i in range(rnn_data.n_hidden):
                for j in range(rnn_data.n_output):
                    negative_associations_ho.append(hidden_probabilities_reconstruction[i] * output_reconstruction[j])

            # Update weights and biases
            for i in range(rnn_data.weights_vh.size()):
                rnn_data.weights_vh[i] += learning_rate * (positive_associations_vh[i] - negative_associations_vh[i])

            for i in range(rnn_data.weights_ho.size()):
                rnn_data.weights_ho[i] += learning_rate * (positive_associations_ho[i] - negative_associations_ho[i])

            for i in range(rnn_data.visible_bias.size()):
                rnn_data.visible_bias[i] += learning_rate * (sample[i] - visible_reconstruction[i])

            for i in range(rnn_data.hidden_bias.size()):
                rnn_data.hidden_bias[i] += learning_rate * (hidden_probabilities[i] - hidden_probabilities_reconstruction[i])

            for i in range(rnn_data.output_bias.size()):
                rnn_data.output_bias[i] += learning_rate * (target[i] - output_reconstruction[i])

        var error = 0.0
        for i in range(data.size()):
            var sample: Array[float] = []
            sample.assign(data[i])
            var output = recommend(sample)
            for j in range(output.size()):
                error += pow(target_output[i][j] - output[j], 2)
        error /= data.size()
        if threshold > 0 and error < threshold:
            break
        if epoch % 100 == 0:
            if error < 0.0001:
                print("Epoch: %d, Error: %.4e" % [epoch + 1, error])
            else:
                print("Epoch: %d, Error: %8f" % [epoch + 1, error])
    print("\n")

func recommend(_state_data: Array[float]) -> PackedFloat64Array:
    assert(rnn_data.ready, "Please make sure the RNNData is ready.")
    assert(rnn_data.trained, "Please make sure to train the RNNData before use.")
    var state_data: Array[float] = []
    state_data.assign(_state_data)
    var hidden = _sample_hidden_layer(state_data)
    return _sample_output_layer(hidden)
