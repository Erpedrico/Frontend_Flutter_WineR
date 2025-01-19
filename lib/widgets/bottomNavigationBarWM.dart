import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/screenWineMaker/calendarioWM.dart';
import 'package:flutter_application_1/screen/screenWineMaker/experienciasPropias.dart';
import 'package:flutter_application_1/screen/screenWineMaker/homeWM.dart';
import 'package:flutter_application_1/screen/screenWineMaker/perfilPersonalWM.dart';
import 'package:flutter_application_1/screen/screenWineMaker/userWM.dart';
import 'package:flutter_application_1/screen/screenWineMaker/experienciesWM.dart';


class BottomNavScaffoldWM extends StatefulWidget {
  const BottomNavScaffoldWM({super.key});

  @override
  _BottomNavScaffoldStateWM createState() => _BottomNavScaffoldStateWM();
}

class _BottomNavScaffoldStateWM extends State<BottomNavScaffoldWM> {
  // Índice para controlar la pestaña seleccionada
  int _selectedIndex = 2;

  // Lista de widgets para las diferentes pantallas
  final List<Widget> _pages = [   
    HomePageWM(),
    UserPage(),        
    ExperienciasPropiasPage(),
    CalendarioPageWM(),
    PerfilPage(),           
  ];

  // Método para manejar el cambio de pestaña
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Actualiza el índice seleccionado
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo lila aplicado correctamente a toda la pantalla
      backgroundColor: Color(0xFFD8BFD8), // Lila suave (Hex: #D8BFD8)
      body: _pages[_selectedIndex], // Muestra la página según el índice seleccionado
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Índice de la pestaña seleccionada
        onTap: _onItemTapped, // Llama al método para cambiar de pestaña
        selectedItemColor: Colors.white, // Iconos seleccionados en blanco
        unselectedItemColor: Colors.white60, // Iconos no seleccionados en blanco con opacidad
        backgroundColor: const Color.fromARGB(255, 173, 13, 88), // Fondo púrpura de la barra de navegación
        type: BottomNavigationBarType.fixed, // Asegura que los iconos estén alineados correctamente
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.wine_bar),
            label: 'MyWinery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Reviews',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wine_bar),
            label: 'Mis Experiencias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}





