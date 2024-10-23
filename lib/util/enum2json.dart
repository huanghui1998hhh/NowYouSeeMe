int? enumToJson<T extends Enum>(T? value) => value?.index;
T? jsonToEnum<T extends Enum>(int? index, List<T> values) =>
    index != null && index >= 0 && index < values.length ? values[index] : null;
