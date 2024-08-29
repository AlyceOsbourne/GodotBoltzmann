extends Resource
class_name UtilityActionManager

@export var utility_names: Array[String]
@export var action_names: Array[String]

func _init(_utility_names: Array[String] = [], _action_names: Array[String] = []):
    utility_names = _utility_names
    action_names = _action_names

func print_utility_values(values: Array[float]):
    for i in range(values.size()):
        print("%s: %3f" % [utility_names[i], values[i]])

func map_to_highest_name(values: Array[float]) -> String:
    var max_index = 0
    var max_value = values[0]
    for i in range(1, values.size()):
        if values[i] > max_value:
            max_value = values[i]
            max_index = i
    return action_names[max_index]

func map_utility_names(dict: Dictionary) -> Array[float]:
    var out: Array[float] = []
    for n in utility_names:
        if n == "Low Utility": out.append(0.001)
        else: out.append(type_convert(dict.get(n, 0), TYPE_FLOAT))
    return out

func map_action_names(dict: Dictionary) -> Array[float]:
    var o: Array[float] = []
    o.assign(action_names.map(func(x): return dict.get(x, 0)).map(type_convert.bind(TYPE_FLOAT)))
    return o
