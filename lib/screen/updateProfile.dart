import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../services/userService.dart';
import '../../providers/perfilProvider.dart';
import '../../models/userModel.dart';
import '../../providers/settings_provider.dart';

class UpdateProfilePage extends StatefulWidget {
  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  String? _imageUrl;

  @override
  Widget build(BuildContext context) {
    // Obtener las configuraciones dinámicas
    final settings = Provider.of<SettingsProvider>(context);
    UserModel currentUser = Provider.of<PerfilProvider>(context).perfilUsuario ?? UserModel(
      name: '',
      mail: '',
      password: '',
      comment: '',
      tipo: '',
    );

    _nameController.text = currentUser.name;
    _mailController.text = currentUser.mail;
    _passwordController.text = currentUser.password;
    _commentController.text = currentUser.comment;
    _imageUrl ??= currentUser.imagen;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: settings.fontSize + 4,
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
      backgroundColor: settings.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  String? url = await _showImageUrlDialog(context);
                  if (url != null && url.isNotEmpty) {
                    setState(() {
                      _imageUrl = url;
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageUrl != null && _imageUrl!.isNotEmpty
                      ? NetworkImage(_imageUrl!)
                      : AssetImage('assets/images/default_profile.png') as ImageProvider,
                  child: _imageUrl == null || _imageUrl!.isEmpty
                      ? Icon(Icons.add_a_photo, size: 30, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                fontSize: settings.fontSize,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _mailController,
                label: 'Email',
                fontSize: settings.fontSize,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                fontSize: settings.fontSize,
                obscureText: true,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _commentController,
                label: 'Comment',
                fontSize: settings.fontSize,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () async {
                  UserModel updatedUser = UserModel(
                    username: currentUser.username,
                    id: currentUser.id,
                    token: currentUser.token,
                    name: _nameController.text,
                    mail: _mailController.text,
                    password: _passwordController.text,
                    comment: _commentController.text,
                    tipo: currentUser.tipo,
                    amigos: currentUser.amigos,
                    solicitudes: currentUser.solicitudes,
                    imagen: _imageUrl,
                  );

                  UserService userService = UserService();
                  await userService.EditUser(updatedUser, currentUser.id, currentUser.token);

                  Provider.of<PerfilProvider>(context, listen: false).updateUser(updatedUser);

                  Get.back();
                },
                child: Text(
                  'Save Changes',
                  style: TextStyle(fontSize: settings.fontSize, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required double fontSize,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: fontSize, color: Colors.red.shade700),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
      ),
      style: TextStyle(fontSize: fontSize),
    );
  }

  Future<String?> _showImageUrlDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Image URL'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Paste URL here',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

