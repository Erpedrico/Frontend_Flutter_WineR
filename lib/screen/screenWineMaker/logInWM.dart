import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/userModel.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:flutter_application_1/services/userService.dart';
import 'package:flutter_application_1/services/auth_services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LogInPageWM extends StatefulWidget {
  @override
  _LogInPageStateWM createState() => _LogInPageStateWM();
}

class _LogInPageStateWM extends State<LogInPageWM> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool isLoading = false;
  String errorMessage = '';

  final UserService userService = UserService();

  // Función para manejar el login
  void logIn() async {
    // Validación de campos
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Campos vacíos';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final logIn = (
      username: usernameController.text,
      password: passwordController.text,
    );

    try {
      // Llamada al servicio para iniciar sesión
      final response = await userService.logIn(logIn);

      if (response is UserModel) {
        // Si el login fue exitoso, actualizamos el perfil y redirigimos
        // Usamos el Provider para acceder a la instancia de PerfilProvider y actualizar el usuario
        final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
        perfilProvider.updateUser(response); // Actualizamos el perfil del usuario
        if (response.tipo=='wineLover'){
          Get.offNamed('/main');
        } else{
          Get.offNamed('/mainWM');
        } 
      } else {
        // Si el login no fue exitoso, mostramos un error
        setState(() {
          errorMessage = 'Usuario o contraseña incorrectos';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: No se pudo conectar con la API';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void toMainPage() async {
    Get.offNamed('/');
  }

  void logInWithGoogle() async {
    final credenciales = await AuthService().signInWithGoogle();

    final String? idToken = await credenciales?.user?.getIdToken();
    debugPrint(credenciales?.user?.displayName);
    debugPrint(credenciales?.user?.photoURL);
    debugPrint(credenciales?.user?.email);
    debugPrint(credenciales?.user?.uid);
    debugPrint('Token de Google (idToken): $idToken');

    final logIn = (
      username: credenciales?.user?.displayName,
      password: credenciales?.user?.uid,
    );

    try {
      // Llamada al servicio para iniciar sesión
      final response = await userService.logIn(logIn);

      if (response is UserModel) {
        // Si el login fue exitoso, actualizamos el perfil y redirigimos
        // Usamos el Provider para acceder a la instancia de PerfilProvider y actualizar el usuario
        final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
        perfilProvider.updateUser(response); // Actualizamos el perfil del usuario
        if (response.tipo=='wineLover'){
          Get.offNamed('/main');
        } else{
          Get.offNamed('/mainWM');
        } 
      } else {
        // Si el login no fue exitoso, mostramos un error
        setState(() {
          errorMessage = 'Usuario o contraseña incorrectos';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: No se pudo conectar con la API';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Nombre de usuario'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                onPressed: logIn,
                child: Text(
                'Iniciar Sesión',
                style: TextStyle(color: Colors.white), // Texto blanco
                ),
                style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB04D47), // Fondo rosa-rojo (puedes cambiar el valor según tu preferencia)
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Bordes redondeados
                ),
                ),
                ),
                ElevatedButton(
                  onPressed: toMainPage,
                  child: Text('Volver a la pagina principal',
                  style: TextStyle(color: Colors.white), // Texto blanco
                ),
                style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB04D47), // Fondo rosa-rojo (puedes cambiar el valor según tu preferencia)
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Bordes redondeados
                ),
                ),
                ),
                ElevatedButton(
                  onPressed: logInWithGoogle,
                  child: Text('Iniciar sesion con google',
                  style: TextStyle(color: Colors.white), // Texto blanco
                ),
                style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB04D47), // Fondo rosa-rojo (puedes cambiar el valor según tu preferencia)
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Bordes redondeados
                ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
