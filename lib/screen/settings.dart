import 'package:flutter/material.dart';
import 'package:get/get.dart';  // Assuming GetX for navigation

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Settings Options',
              style: const TextStyle(
                fontSize: 24,  // Tamaño predeterminado
                color: Colors.black,  // Fondo por defecto
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes cambiar dinámicamente el color de fondo o del texto
                Get.changeTheme(
                  ThemeData(
                    primaryColor: Colors.blue,  // Cambio de fondo
                    textTheme: const TextTheme(
                      headlineMedium: TextStyle(color: Colors.white),  // Uso de headlineMedium
                    ),
                  ),
                );
              },
              child: const Text('Change Background Color'),
            ),
          ],
        ),
      ),
    );
  }
}

