import 'package:example/models/user_model.dart';
import 'package:flutter/material.dart';

/// A widget to display user information in a card format.
class UserCard extends StatelessWidget {
  final User user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user.score.toString()),
        ),
        title: Text(user.name),
        subtitle: Text('User ID: ${user.id}'),
      ),
    );
  }
}
