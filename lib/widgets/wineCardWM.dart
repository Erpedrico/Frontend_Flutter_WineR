import 'package:flutter/material.dart';
import '../models/wineModel.dart';
import '../models/experienceModel.dart';
import '../services/experienceService.dart';

class WineCardWM extends StatelessWidget {
  final WineModel wine;

  const WineCardWM({Key? key, required this.wine}) : super(key: key);

  Future<ExperienceModel?> _getExperience(BuildContext context, String experienceId) async {
    final ExperienceService experienceService = ExperienceService();
    try {
      return await experienceService.getExperienceById(context, experienceId);
    } catch (e) {
      print('Error al obtener la experiencia: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExperienceModel?>(
      future: _getExperience(context, wine.experience),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar la experiencia'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Experiencia no encontrada'));
        } else {
          final experience = snapshot.data!;
          return Card(
            color: Color(0xFF892e3e),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wine.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text('Precio: \$${wine.price}', style: TextStyle(color: Colors.white)),
                  Text('Color: ${wine.color}', style: TextStyle(color: Colors.white)),
                  Text('Marca: ${wine.brand}', style: TextStyle(color: Colors.white)),
                  Text('Tipo de uva: ${wine.grapetype}', style: TextStyle(color: Colors.white)),
                  Text('Año: ${wine.year}', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                    'Experiencia: ${experience.title}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Notas:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  ...wine.notes.map((note) {
                    return Text('${note.icon} ${note.label}', style: TextStyle(color: Colors.white));
                  }).toList(),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}