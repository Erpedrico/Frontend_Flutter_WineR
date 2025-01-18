import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:flutter_application_1/models/userModel.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el PerfilProvider desde el contexto
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);

    // Acceder al perfil actual almacenado en el PerfilProvider
    UserModel? perfil = perfilProvider.perfilUsuario;

    // Verificamos si existe el perfil, si no, mostramos un mensaje de error
    if (perfil == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Perfil")),
        body: Center(child: Text("No se ha encontrado el perfil")),
      );
    }

    // Función para cerrar sesión
    void cerrarSesion() {
      perfilProvider.deleteUser();
      Get.offNamed('/login');
    }

    // Si existe el perfil, mostramos los datos
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.red[400],
      ),
      body: Container(
        color: Colors.red[100],
        child: Column(
          children: [
            // Sección superior del perfil
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Imagen de perfil
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: //perfil.imageUrl != null
                        //? NetworkImage(perfil.imageUrl!)
                        AssetImage('assets/images/default_profile.png') as ImageProvider,
                  ),
                  SizedBox(width: 16),
                  // Información del usuario
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          perfil.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                  // Ícono de configuración de perfil
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Get.toNamed('/updateProfile');
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Opciones del perfil
            Expanded(
              child: ListView(
                children: [
                  _buildOptionTile(
                    icon: Icons.person,
                    title: 'Update Profile',
                    onTap: () => Get.toNamed('/updateProfile'),
                  ),
                  _buildOptionTile(
                    icon: Icons.local_fire_department,
                    title: 'For You Page',
                    onTap: () => Get.toNamed('/forYouPage'),
                  ),
                  _buildOptionTile(
                    icon: Icons.reviews,
                    title: 'Reviews',
                    onTap: () => Get.toNamed('/reviews'),
                  ),
                  _buildOptionTile(
                    icon: Icons.payment,
                    title: 'Payments',
                    onTap: () => Get.toNamed('/payments'),
                  ),
                  _buildOptionTile(
                    icon: Icons.support_agent,
                    title: 'Support',
                    onTap: () => Get.toNamed('/support'),
                  ),
                  _buildOptionTile(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () => Get.toNamed('/settings'),
                  ),
                ],
              ),
            ),
            // Botón de cerrar sesión
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red[400],
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  backgroundColor: Colors.red[50],
                ),
                onPressed: cerrarSesion,
                icon: Icon(Icons.logout),
                label: Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir una opción del menú
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.red[400]),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: onTap,
    );
  }
}
