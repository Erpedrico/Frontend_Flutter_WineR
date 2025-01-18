import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  double _fontSize = 16.0; // Tamaño de fuente predeterminado
  Color _backgroundColor = Colors.white; // Color de fondo predeterminado

  double get fontSize => _fontSize;
  Color get backgroundColor => _backgroundColor;

  void setFontSize(double newSize) {
    _fontSize = newSize;
    notifyListeners(); // Notificar a los widgets que escuchen este cambio
  }

  void setBackgroundColor(Color newColor) {
    _backgroundColor = newColor;
    notifyListeners(); // Notificar a los widgets que escuchen este cambio
  }
}
