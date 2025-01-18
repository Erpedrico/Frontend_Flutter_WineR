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

  @override
  Widget build(BuildContext context) {
    // Obtenemos el estado del perfil actual del usuario
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                // Crear un nuevo UserModel con los datos actualizados
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
                );

                // Acceder a UserService como una instancia
                UserService userService = UserService();
                int res = await userService.EditUser(updatedUser, currentUser.id, currentUser.token);

                // Usar PerfilProvider para actualizar el usuario
                Provider.of<PerfilProvider>(context, listen: false).updateUser(updatedUser);

                // Redirigir a la pantalla principal o donde quieras
                Get.back();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}


