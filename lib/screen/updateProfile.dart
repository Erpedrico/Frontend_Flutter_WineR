import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../services/userService.dart';
import '../../providers/perfilProvider.dart';
import '../../models/userModel.dart';

class UpdateProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String? _imageUrl;

  @override
  Widget build(BuildContext context) {
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
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                // Permitimos al usuario ingresar una URL de imagen directamente
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
                    ? NetworkImage(_imageUrl!) // Mostrar imagen desde la URL proporcionada
                    : AssetImage('assets/images/default_profile.png') as ImageProvider,
                child: _imageUrl == null || _imageUrl!.isEmpty
                    ? Icon(Icons.add_a_photo, size: 30, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _mailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(labelText: 'Comment'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
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
                  imagen: _imageUrl, // Usar la URL de la imagen
                );

                UserService userService = UserService();
                await userService.EditUser(updatedUser, currentUser.id, currentUser.token);

                Provider.of<PerfilProvider>(context, listen: false).updateUser(updatedUser);

                Get.back();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // Método simplificado para mostrar un cuadro de diálogo y obtener una URL
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
