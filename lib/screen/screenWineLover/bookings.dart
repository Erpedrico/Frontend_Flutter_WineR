import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/experienceModel.dart';
import '../../models/userModel.dart';
import '../../providers/perfilProvider.dart';
import '../../providers/settings_provider.dart';
import '../../services/userService.dart';
import '../../widgets/bookingsCardWL.dart';

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
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
    UserModel? perfil = perfilProvider.perfilUsuario;
    String? token = perfil?.token;

    _userService.token = widget.userToken;
    _currentExperiences = _userService.fetchUserExperiences(token);
  }

  @override
  Widget build(BuildContext context) {
    // Obtener las configuraciones dinámicas
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        title: Text(
          'Mis Reservas',
          style: TextStyle(
            fontSize: settings.fontSize + 4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: settings.backgroundColor,
      body: FutureBuilder<List<ExperienceModel>>(
        future: _currentExperiences,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.red.shade700));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: settings.fontSize, color: Colors.red.shade700),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No tienes reservas',
                style: TextStyle(fontSize: settings.fontSize, color: Colors.red.shade700),
              ),
            );
          } else {
            List<ExperienceModel> experiences = snapshot.data!;
            return ListView.builder(
              itemCount: experiences.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: BookingsCardWL(
                    experience: experiences[index],
                    onRatingUpdate: (rating) {
                      // Acción opcional al actualizar la puntuación
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}


