import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/settings_provider.dart';

Widget _buildOptionTile({
  required IconData icon,
  required String title,
  required double fontSize, // Tamaño de fuente dinámico
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    padding: const EdgeInsets.all(12.0),
    decoration: BoxDecoration(
      color: Colors.red.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          color: Colors.red.shade800,
          size: fontSize + 8, // Escalar el tamaño del icono según la fuente
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade900,
            ),
          ),
        ),
      ],
    ),
  );
}

class SupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtener los valores de configuración desde SettingsProvider
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        title: Text(
          'Support',
          style: TextStyle(
            fontSize: settings.fontSize + 4, // Ajustar el tamaño de la fuente
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
      ),
      backgroundColor: settings.backgroundColor, // Fondo dinámico
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOptionTile(
              icon: Icons.mail,
              title: 'Email: winnereetac@gmail.com',
              fontSize: settings.fontSize, // Aplicar tamaño de fuente dinámico
            ),
            _buildOptionTile(
              icon: Icons.phone,
              title: 'Phone: +1234567890',
              fontSize: settings.fontSize, // Aplicar tamaño de fuente dinámico
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Por favor, no dude en ponerse en contacto con el equipo de Winner Team.',
                style: TextStyle(
                  fontSize: settings.fontSize,
                  color: Colors.red.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


