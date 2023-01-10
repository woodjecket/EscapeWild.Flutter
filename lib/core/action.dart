class ActionType {
  final String name;

  const ActionType(this.name);

  factory ActionType.named(String name) => ActionType(name);

  @override
  String toString() => name;
  static const ActionType move = ActionType("move"),
      explore = ActionType("explore"),
      rest = ActionType("rest"),
      hunt = ActionType("hunt"),
      cutDownTree = ActionType("cut-down-tree"),
      fish = ActionType("fish");

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ActionType || other.runtimeType != runtimeType) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}
