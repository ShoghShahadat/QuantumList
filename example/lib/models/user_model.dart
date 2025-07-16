/// A simple data model for the user in the FilterableQuantumListController demo.
class User {
  final int id;
  final String name;
  final int score;

  User({required this.id, required this.name, required this.score});

  // We override `hashCode` and `==` to ensure the diffing algorithm in the controller
  // can correctly identify unique User objects.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, name: $name, score: $score}';
  }
}
