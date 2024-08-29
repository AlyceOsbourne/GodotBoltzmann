class_name BoltzmannTrainer
extends Node

@export var rbn: RestrictedBoltzmannMachine
@export var cases: GDScript
@export var save_path: String = "res://ai.txt"

func _train(training_cases: Array[TrainingCase]):
    rbn.rnn_data.n_visible = len(cases.utility_action_manager.utility_names)
    rbn.rnn_data.n_output = len(cases.utility_action_manager.action_names)

    var inputs = []
    var targets = []
    for case in training_cases:
        for input_state in case.inputs:
            inputs.append(cases.utility_action_manager.map_utility_names(input_state))
            targets.append(cases.utility_action_manager.map_action_names(case.target))

    rbn.train(inputs, targets)

func _get_or_create(training_cases: Array[TrainingCase]):
    if FileAccess.file_exists(save_path):
        rbn = Grumble.decode_from_file(save_path)
        assert(rbn.rnn_data.n_visible == len(cases.utility_action_manager.utility_names))
        assert(rbn.rnn_data.n_output == len(cases.utility_action_manager.action_names))
    else:
        _train(training_cases)
        Grumble.encode_to_file(save_path, rbn)

func _ready():
    var training_cases = cases.training_cases
    _get_or_create(training_cases)

    for case in training_cases:
        for _input_state in case.inputs:
            var input_state: Array[float] = []
            input_state.assign(cases.utility_action_manager.map_utility_names(_input_state))
            var recommended_actions = rbn.recommend(input_state)
            print("State data:")
            cases.utility_action_manager.print_utility_values(input_state)
            print("Recommended Action:", cases.utility_action_manager.map_to_highest_name(recommended_actions))
            print("\n")

    test_random_data()

    print(inst_to_dict(rbn.rnn_data))

func test_random_data():
    var random_tests = 10
    for i in range(random_tests):
        var random_state: PackedFloat64Array = []

        for j in range(rbn.rnn_data.n_visible):
            random_state.append(randf())

        var recommended_actions = rbn.recommend(random_state)

        print("Random Test #", i + 1)
        print("Random State Data:")
        cases.utility_action_manager.print_utility_values(random_state)
        print("Recommended Action:", cases.utility_action_manager.map_to_highest_name(recommended_actions))
        print("\n")
