import 'dart:io'; // Import para manejar imágenes locales
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:flutter_application_1/models/userModel.dart';
import 'package:flutter_application_1/services/userService.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class PerfilExternalPage extends StatelessWidget {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    // Obtener el PerfilProvider desde el contexto
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);

    // Acceder al perfil externo almacenado en el PerfilProvider
    UserModel? perfil = perfilProvider.perfilExternalUsuario;
    UserModel? currentUser = perfilProvider.perfilUsuario;

    // Verificamos si existe el perfil, si no, mostramos un mensaje de error
    if (perfil == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Perfil")),
        body: Center(child: Text("No se ha encontrado el perfil")),
      );
    }

    // Función para volver
    void volver() {
      perfilProvider.deleteExternalUser();
      Get.offNamed('/main');
    }

    // Función para enviar solicitud de amistad
    void addSolicitud() async {
      int response = await _userService.addSolicitud(currentUser?.username, perfil.username);
      if (response == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Solicitud de amistad enviada"),
            duration: Duration(seconds: 2), // El tiempo que aparece el mensaje
          ),
        );
        Get.offNamed('/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al enviar solicitud"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    // Verificar si el usuario externo ya está en la lista de amigos
    bool isFriend = currentUser?.amigos?.contains(perfil.username) ?? false;

    // Si existe el perfil externo, mostramos los datos
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil de ${perfil.username}"),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        color: Colors.red[50],
        child: Center(
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _getImage(perfil), // Obtener la imagen del perfil
                  ),
                  const SizedBox(height: 16),
                  Text(
                    perfil.name ?? "Nombre no disponible",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Usuario: ${perfil.username ?? "N/A"}",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    perfil.mail ?? "Correo no disponible",
                    style: TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    perfil.comment ?? "Sin comentarios",
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: volver,
                        icon: Icon(Icons.arrow_back),
                        label: Text("Volver"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (!isFriend)
                        ElevatedButton.icon(
                          onPressed: addSolicitud,
                          icon: Icon(Icons.person_add),
                          label: Text("Enviar solicitud"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Obtiene la imagen de perfil del usuario.
  /// Manejamos tanto imágenes locales como remotas.
  ImageProvider _getImage(UserModel perfil) {
    // Si la imagen está disponible, verificamos si es remota o local
    if (perfil.imagen != null && perfil.imagen!.isNotEmpty) {
      if (perfil.imagen!.startsWith('http') || perfil.imagen!.startsWith('https')) {
        return NetworkImage(perfil.imagen!); // Imagen remota
      } else if (File(perfil.imagen!).existsSync()) {
        return FileImage(File(perfil.imagen!)); // Imagen local
      }
    }
    return AssetImage('assets/images/default_profile.png'); // Imagen predeterminada
  }
}
