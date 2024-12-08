import 'package:flutter/material.dart';
import '../models/userModel.dart'; 

class UserCard extends StatelessWidget {
  final UserModel user;

  const UserCard({Key? key, required this.user, Row? child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(user.mail),
          const SizedBox(height: 8),
          Text(user.comment),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  // Por ahora no hace nada
                },
                icon: Icon(Icons.chat_bubble_outline),
                tooltip: 'Abrir chat', // Mensaje emergente al pasar el cursor
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

}