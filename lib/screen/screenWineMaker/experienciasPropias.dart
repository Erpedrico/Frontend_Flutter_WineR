import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/userModel.dart';
import 'package:flutter_application_1/models/experienceModel.dart';
import 'package:flutter_application_1/widgets/experienceCardWM.dart';
import 'package:flutter_application_1/services/experienceService.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:flutter_application_1/widgets/ownexperienceWM.dart';
import 'package:provider/provider.dart';


class ExperienciasPropiasPage extends StatefulWidget {
  @override
  _ExperienciasPropiasPageState createState() => _ExperienciasPropiasPageState();
}

class _ExperienciasPropiasPageState extends State<ExperienciasPropiasPage> {
  late Future<List<ExperienceModel>> _myExperiences;
  final ExperienceService _experienceService = ExperienceService();

  @override
  void initState() {
    super.initState();
    _fetchMyExperiences();
  }

  void _fetchMyExperiences() {
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
    UserModel? perfil = perfilProvider.perfilUsuario;
    String? ownerId = perfil?.id;

    if (ownerId != null) {
      setState(() {
        _myExperiences = _experienceService.getExperiencesByOwner(ownerId);
      });
    }
  }

  void _deleteExperience(String experienceId) async {
    // Aquí podrías implementar lógica para eliminar una experiencia usando el servicio.
    // Por ahora, simula eliminando de la lista local:
    setState(() {
      _myExperiences = _myExperiences.then((experiences) =>
          experiences.where((experience) => experience.id != experienceId).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Experiencias'),
      ),
      body: FutureBuilder<List<ExperienceModel>>(
        future: _myExperiences,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar las experiencias'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay experiencias disponibles'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final experience = snapshot.data![index];
                return OwnExperienceCardWM(
                  experience: experience,
                  onDelete: () => _deleteExperience(experience.id!),
                  onRatingUpdate: (rating) {
                    setState(() {
                      experience.rating = rating; // Actualiza la puntuación localmente
                    });
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
