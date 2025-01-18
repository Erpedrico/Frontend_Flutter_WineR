import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart'; 
import '../../models/userModel.dart'; 
import '../../services/chatService.dart'; 
import '../../providers/perfilProvider.dart'; 

class RoomPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<RoomPage> {
  List<String> _roomsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  // Método para cargar las salas del usuario actual
  void _loadRooms() async {
    try {
      setState(() {
        _isLoading = true; // Mostrar indicador de carga
      });

      // Obtener el usuario actual desde PerfilProvider
      UserModel? currentUser = Provider.of<PerfilProvider>(context, listen: false).getUser();

      if (currentUser != null) {
        // Llamar al servicio para obtener las salas
        List<String> loadedRooms = await ChatService().findRooms(currentUser.username);
        setState(() {
          _roomsList = loadedRooms;
        });
      } else {
        print("Usuario no encontrado en el PerfilProvider");
      }
    } catch (e) {
      print("Error cargando las salas: $e");
    } finally {
      setState(() {
        _isLoading = false; // Detener el indicador de carga
      });
    }
  }

  void toChat(room) {
      Provider.of<PerfilProvider>(context, listen: false).setRoomChat(room);
      Get.offNamed('/chatPage');
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversaciones'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Mostrar cargando
          : _roomsList.isEmpty
              ? Center(child: Text('No hay conversaciones para mostrar')) // Si no hay salas
              : ListView.builder(
                  itemCount: _roomsList.length,
                  itemBuilder: (context, index) {
                    String roomName = _roomsList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        elevation: 2,
                        child: ListTile(
                          title: Text(roomName),
                          trailing: ElevatedButton(
                            onPressed: () {
                              toChat(roomName);
                            },
                            child: Text('Ir'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
