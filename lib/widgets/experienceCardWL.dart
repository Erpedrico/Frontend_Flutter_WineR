import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/experienceModel.dart';
import '../services/experienceService.dart';
import 'package:http/http.dart' as http;
import '../services/userService.dart';

class ExperienceCardWL extends StatefulWidget {
  final ExperienceModel experience;
  final ValueChanged<double> onRatingUpdate;

  const ExperienceCardWL({
    super.key,
    required this.experience,
    required this.onRatingUpdate,
  });

  @override
  _ExperienceCardStateWL createState() => _ExperienceCardStateWL();
}

class _ExperienceCardStateWL extends State<ExperienceCardWL> {
  LatLng? _coordinates;
  LatLngBounds? _bounds;
  double? _currentRating;
  List<Map<String, dynamic>> _reviews = [];
  String? _ownerName;
  bool _showFullInfo = false;

  @override
  void initState() {
    super.initState();
    _fetchCoordinates();
    _fetchOwnerName();
    _currentRating = widget.experience.rating ?? 0.0;
  }

  Future<void> _fetchCoordinates() async {
    if (widget.experience.location != null) {
      final coords = await getCoordinates(widget.experience.location!);
      if (mounted) {
        setState(() {
          _coordinates = coords;
          if (coords != null) {
            _bounds = LatLngBounds(coords, coords);
          }
        });
      }
    }
  }

  Future<LatLng?> getCoordinates(String address) async {
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
        } else {
          print('Dirección no encontrada.');
          return null;
        }
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al geocodificar dirección: $e');
      return null;
    }
  }

  Future<void> _fetchOwnerName() async {
    final userService = UserService();
    final id = widget.experience.owner;
    final ownerName = await userService.getUserNameById(id);
    setState(() {
      _ownerName = ownerName;
    });
  }

  Future<void> _confirmJoinExperience() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar inscripción'),
          content:
              const Text('¿Seguro que deseas apuntarte a esta experiencia?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _joinExperience();
                _addParticipantToExperience();
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _joinExperience() async {
    final user = context.read<PerfilProvider>().getUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no logueado')),
      );
      return;
    }

    final userId = user.id;
    final experienceId = widget.experience.id;

    if (experienceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID de experiencia no válido')),
      );
      return;
    }

    final userService = UserService();
    final status = await userService.joinExperience( userId!, experienceId);


    if (status == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Te has apuntado con éxito a la experiencia')),
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

  Future<void> _addParticipantToExperience() async {
    final user = context.read<PerfilProvider>().perfilUsuario;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no logueado')),
      );
      return;
    }

    final userId = user.id;
    final experienceId = widget.experience.id;

    if (experienceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID de experiencia no válido')),
      );
      return;
    }

    final experienceService = ExperienceService();
    try {
      await experienceService.addParticipantToExperience(experienceId, userId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te has apuntado con éxito a la experiencia')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al apuntarse a la experiencia')),
      );
    }
  }

  Future<void> _fetchReviews() async {
    final experienceService = ExperienceService();
    try {
      final response =
          await experienceService.getRatingWithComment(widget.experience.id!);
      setState(() {
        _reviews = response;
      });
    } catch (e) {
      print('Error al obtener las valoraciones: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar valoraciones')),
      );
    }
  }

  Future<void> _showReviewsDialog() async {
    await _fetchReviews();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Valoraciones'),
          content: _reviews.isEmpty
              ? const Text('No hay valoraciones disponibles.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return ListTile(
                        leading: Icon(Icons.star, color: Colors.amber),
                        title: Text(
                            'Calificación promedio: ${widget.experience.averageRating?.toStringAsFixed(1) ?? 'N/A'}'),
                        subtitle: Text(review['comment']),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = widget.experience.date != null
        ? DateFormat('dd-MM-yyyy').format(widget.experience.date!)
        : 'Fecha no disponible';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.experience.title ?? 'Sin título',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
                'Descripción: ${widget.experience.description ?? 'Sin descripción'}'),
            Text('Propietario: ${_ownerName ?? 'Sin propietario'}'),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FlutterMap(
                  options: MapOptions(
                    bounds: _bounds,
                    boundsOptions:
                        FitBoundsOptions(padding: EdgeInsets.all(10)),
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    if (_coordinates != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _coordinates!,
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              color: Color(0xFFF44336),
                              size: 30.0,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_showFullInfo) ...[
              Text(
                  'Precio: \$${widget.experience.price ?? 'N/A'}'),
              Text(
                  'Correo de contacto: ${widget.experience.contactmail ?? 'Sin Correo de contacto'}'),
              Text(
                  'Número de contacto: ${widget.experience.contactnumber ?? 'Sin número de contacto'}'),
              Text(
                  'Puntuación actual: ${_currentRating?.toStringAsFixed(1) ?? 'N/A'}'),
              Text(
                  'Calificación promedio: ${widget.experience.averageRating?.toStringAsFixed(1) ?? 'N/A'}'),
              Text(
                  'Servicios:'),
              Text(
                  'Fecha: $formattedDate'),
              Column(
                children: widget.experience.services!.map((service) {
                  return Text('${service.icon} ${service.label}');
                }).toList(),
              ),
              ElevatedButton(
                onPressed: () => _showReviewsDialog(),
                child: const Text('Ver valoraciones'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _confirmJoinExperience,
                child: const Text('Apuntarme a esta experiencia'),
              ),
            ],
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showFullInfo = !_showFullInfo;
                });
              },
              child: Text(_showFullInfo ? 'Ver menos' : 'Ver más'),
            ),
          ],
        ),
      ),
    );
  }
}
