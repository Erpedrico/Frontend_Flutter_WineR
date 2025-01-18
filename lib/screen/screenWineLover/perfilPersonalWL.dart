import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:flutter_application_1/models/userModel.dart';
import 'package:flutter_application_1/providers/settings_provider.dart'; // Asegúrate de importar SettingsProvider
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
    UserModel? perfil = perfilProvider.perfilUsuario;

    if (perfil == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Perfil")),
        body: Center(child: Text("No se ha encontrado el perfil")),
      );
    }

    void cerrarSesion() {
      perfilProvider.deleteUser();
      Get.offNamed('/login');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.red[400],
      ),
      body: Container(
        color: Colors.red[100], // Fondo fijo, no depende de la configuración
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
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/default_profile.png'),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, child) {
                            return Text(
                              perfil.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: settingsProvider.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${perfil.amigos?.length} Amigos', // Número de amigos
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              '${perfil.experiences?.length} Experiencias', // Número de experiencias
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
            Expanded(
              child: ListView(
                children: [
                  _buildOptionTile(
                    context: context,
                    icon: Icons.person,
                    title: 'Update Profile',
                    onTap: () => Get.toNamed('/updateProfile'),
                  ),
                  _buildOptionTile(
                    context: context,
                    icon: Icons.local_fire_department,
                    title: 'For You Page',
                    onTap: () => Get.toNamed('/forYouPage'),
                  ),
                  _buildOptionTile(
                    context: context,
                    icon: Icons.reviews,
                    title: 'Reviews',
                    onTap: () => Get.toNamed('/reviews'),
                  ),
                  _buildOptionTile(
                    context: context,
                    icon: Icons.payment,
                    title: 'Payments',
                    onTap: () => Get.toNamed('/payments'),
                  ),
                  _buildOptionTile(
                    context: context,
                    icon: Icons.support_agent,
                    title: 'Support',
                    onTap: () => Get.toNamed('/support'),
                  ),
                  _buildOptionTile(
                    context: context,
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () => Get.toNamed('/settings'),
                  ),
                ],
              ),
            ),
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
                label: Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, child) {
                    return Text(
                      'Sign Out',
                      style: TextStyle(fontSize: settingsProvider.fontSize),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.red[400]),
      title: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return Text(
            title,
            style: TextStyle(fontSize: settingsProvider.fontSize),
          );
        },
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: onTap,
    );
  }
}
