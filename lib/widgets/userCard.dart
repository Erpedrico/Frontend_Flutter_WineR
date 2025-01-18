import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/userModel.dart'; 
import '../providers/perfilProvider.dart'; 
import 'package:provider/provider.dart';
import '../services/userService.dart'; 

class UserCard extends StatelessWidget {
  final UserModel user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  void buscarUsuario(BuildContext context, String? nombre) async {
  // Instancia del servicio UserService
  final userService = UserService();
  // Obtener el PerfilProvider desde el contexto
  final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);

  // Obtener el usuario actual
  UserModel? currentUser = perfilProvider.getUser();

  if (currentUser != null) {
    try {
      // Llamar al método findUser del servicio UserService asegurando que los valores no sean nulos
      UserModel? foundUser = await userService.findUser(nombre ?? "", currentUser.token ?? "");

      if (foundUser == null) {
        // Mostrar mensaje si no se encuentra el usuario
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Usuario no encontrado"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Configurar el usuario externo en el provider y navegar a la página de perfil externo
        perfilProvider.setExternalUser(foundUser);
        Get.offNamed('/perfilExternalUsuario');
      }
    } catch (e) {
      // Mostrar mensaje de error si ocurre una excepción
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ocurrió un error al buscar el usuario"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);

    // Navegar al chat con el usuario seleccionado
    void toChat(String? username) {
      perfilProvider.setUsernameChat(username);
      Get.offNamed('/chat');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del usuario
            Text(
              user.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Correo del usuario
            Text(user.mail),
            const SizedBox(height: 8),
            // Comentario del usuario
            Text(user.comment),
            const SizedBox(height: 16),
            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botón "Ver Perfil"
                TextButton.icon(
                  onPressed: () => buscarUsuario(context, user.username),
                  icon: Icon(Icons.person_outline, color: Colors.blue),
                  label: Text(
                    'Ver Perfil',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón "Abrir Chat"
                TextButton.icon(
                  onPressed: () => toChat(user.username),
                  icon: Icon(Icons.chat_bubble_outline, color: Colors.green),
                  label: Text(
                    'Abrir Chat',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}