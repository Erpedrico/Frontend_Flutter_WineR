import 'package:flutter/material.dart';
import 'package:get/get.dart';  

Widget _buildOptionTile({
  required IconData icon,
  required String title,
}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
  );
}

class SupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOptionTile(
            icon: Icons.mail,
            title: 'Email: winnereetac@gmail.com',
          ),
          _buildOptionTile(
            icon: Icons.phone,
            title: 'Phone: +1234567890',
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Por favor, no dude en ponerse en contacto con el equipo de Winner Team.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
