import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/experienceModel.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:flutter_application_1/services/experienceService.dart';
import 'package:flutter_application_1/services/userService.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final PopupController _popupController = PopupController();
  List<Marker> _markers = [];
  List<ExperienceModel> _experiences = [];

  @override
  void initState() {
    super.initState();
    _loadExperienceMarkers();
  }

  Future<void> _loadExperienceMarkers() async {
    try {
      final experiences = await ExperienceService().getExperiences();
      final List<Marker> markers = [];
      for (var exp in experiences) {
        if (exp.location != null) {
          final coords = await _getCoordinates(exp.location!);
          if (coords != null) {
            markers.add(
              Marker(
                width: 40.0,
                height: 40.0,
                point: coords,
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    _showPopup(context, coords, exp);
                    //_popupController.togglePopup(Marker(point: coords, builder: (ctx) => Container()));
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFFF44336),
                    size: 30.0,
                  ),
                ),
              ),
            );
          }
        }
      }
      setState(() {
        _markers = markers;
        _experiences = experiences;
      });
    } catch (e) {
      print('Error al cargar las experiencias: $e');
    }
  }

  Future<LatLng?> _getCoordinates(String address) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final double lat = double.parse(data[0]['lat']);
          final double lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon);
        }
      }
      return null;
    } catch (e) {
      print('Error obteniendo coordenadas: $e');
      return null;
    }
  }

  Future<void> _joinExperience(String experienceId) async {
    final user = context.read<PerfilProvider>().getUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no logueado')),
      );
      return;
    }

    final userService = UserService();
    final status = await userService.joinExperience(user.id!, experienceId);

    if (status == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te has apuntado con éxito a la experiencia')),
      );
    } else if (status == 404) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o experiencia no encontrado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al apuntarse a la experiencia')),
      );
    }
  }

  void _showPopup(BuildContext context, LatLng coords, ExperienceModel experience) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(experience.title ?? 'Sin título'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ubicación: ${experience.location}'),
              SizedBox(height: 4),
              Text(
                  'Descripción: ${experience.description ?? 'Sin descripción'}'),
              SizedBox(height: 4),
              Text('Propietario: ${experience.owner ?? 'Sin propietario'}'),
              SizedBox(height: 4),
              Text('Precio: \$${experience.price ?? 'N/A'}'),
              SizedBox(height: 4),
              Text(
                  'Calificación promedio: ${experience.averageRating?.toStringAsFixed(1) ?? 'N/A'}'), // Muestra la calificación promedio
              SizedBox(height: 4),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ExperienceDetailPage(experience: experience),
                    ),
                  );
                },
                child: const Text('Ver más'),
              ),
               const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _joinExperience(experience.id!),
                child: const Text('Apuntarse'),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Experiencias'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(41.382395521312176, 2.1567611541534366),
          zoom: 5.0,
          onTap: (_, __) => _popupController.hideAllPopups(),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _markers,
          )
        ],
      ),
    );
  }
}

class ExperienceDetailPage extends StatelessWidget {
  final ExperienceModel experience;

  const ExperienceDetailPage({Key? key, required this.experience})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(experience.title ?? 'Detalle de Experiencia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              experience.title ?? 'Sin título',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              experience.description ?? 'Sin descripción',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Ubicación: ${experience.location}',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}