import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/experienceModel.dart';
import 'package:flutter_application_1/models/userModel.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:flutter_application_1/services/userService.dart';
import 'package:provider/provider.dart';// Asegúrate de tener tu UserService importado

class BookingsScreen extends StatefulWidget {
  final String userToken; // Token del usuario logueado

  BookingsScreen({required this.userToken});

  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late Future<List<ExperienceModel>> _currentExperiences;
  final UserService _userService = UserService();

   

  @override
  void initState() {
    final perfilProvider =
          Provider.of<PerfilProvider>(context, listen: false);
      // Acceder al perfil actual almacenado en el PerfilProvider
      UserModel? perfil = perfilProvider.perfilUsuario;
      String? token = perfil?.token;

    super.initState();
    // Inicializar el token del servicio de usuario
    _userService.token = widget.userToken;
    print(token);
    // Obtener las experiencias del usuario logueado
    _currentExperiences = _userService.fetchUserExperiences(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Reservas'),
      ),
      body: FutureBuilder<List<ExperienceModel>>(
        future: _currentExperiences,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tienes reservas'));
          } else {
            List<ExperienceModel> experiences = snapshot.data!;
            return ListView.builder(
              itemCount: experiences.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(experiences[index].title ?? 'Sin titulo'),
                  subtitle: Text('ID: ${experiences[index].id}'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    // Aquí puedes manejar la navegación a los detalles de la experiencia
                    print('Tapped on ${experiences[index].title}');
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
