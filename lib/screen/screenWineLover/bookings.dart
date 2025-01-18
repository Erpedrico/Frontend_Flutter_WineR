import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/experienceModel.dart';
import 'package:flutter_application_1/models/userModel.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:flutter_application_1/services/userService.dart';
import 'package:flutter_application_1/widgets/bookingsCardWL.dart';
import 'package:provider/provider.dart'; // Asegúrate de tener tu UserService importado

class BookingsScreen extends StatefulWidget {
  final String userToken;

  const BookingsScreen({super.key, required this.userToken});

  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late Future<List<ExperienceModel>> _currentExperiences;
  final UserService _userService = UserService();

  @override
  void initState() {
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
    UserModel? perfil = perfilProvider.perfilUsuario;
    String? token = perfil?.token;

    super.initState();
    _userService.token = widget.userToken;
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
                return BookingsCardWL(
                  experience: experiences[index],
                  onRatingUpdate: (rating) {
                    // Acción opcional al actualizar la puntuación
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

