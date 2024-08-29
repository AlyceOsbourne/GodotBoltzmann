extends Resource

class_name TrainingCases

static var utility_action_manager = UtilityActionManager.new(
    ["Hungry", "Tired", "Bored", "Stressed", "Low Utility"],
    ["Eat", "Sleep", "Relax", "Exercise", "Idle"]
)

static var Hungry_Tired = TrainingCase.new([
    {"Hungry": 1, "Tired": 1}
], {"Eat": true})

static var Hungry_Bored = TrainingCase.new([
    {"Hungry": 1, "Bored": 1}
], {"Eat": true})

static var Hungry_Stressed = TrainingCase.new([
    {"Hungry": 1, "Stressed": 1}
], {"Eat": true})

static var Hungry_Only = TrainingCase.new([
    {"Hungry": 1}
], {"Eat": true})

static var Tired_Only = TrainingCase.new([
    {"Tired": 1}
], {"Sleep": true})

static var Bored_Only = TrainingCase.new([
    {"Bored": 1}
], {"Relax": true})

static var Stressed_Only = TrainingCase.new([
    {"Stressed": 1}
], {"Exercise": true})

static var Tired_Bored = TrainingCase.new([
    {"Tired": 1, "Bored": 1}
], {"Sleep": true})

static var Tired_Stressed = TrainingCase.new([
    {"Tired": 1, "Stressed": 1}
], {"Sleep": true})

static var Tired_Hungry = TrainingCase.new([
    {"Tired": 1, "Hungry": 0.7}
], {"Sleep": true})

static var Bored_Stressed = TrainingCase.new([
    {"Bored": 1, "Stressed": 1}
], {"Exercise": true})

static var Idle = TrainingCase.new([
    {},
    {"Hungry": 0.3},
    {"Tired": 0.3},
    {"Stressed": 0.3}
], {"Idle": true})

static var training_cases: Array[TrainingCase] = [
    Hungry_Tired,
    Hungry_Bored,
    Hungry_Stressed,
    Hungry_Only,
    Tired_Only,
    Bored_Only,
    Stressed_Only,
    Tired_Bored,
    Tired_Stressed,
    Tired_Hungry,
    Bored_Stressed,
    Idle
]
