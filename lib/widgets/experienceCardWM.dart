import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:flutter_application_1/services/userService.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/experienceModel.dart';
import '../services/experienceService.dart';
import 'package:http/http.dart' as http;

class ExperienceCardWM extends StatefulWidget {
  final ExperienceModel experience;
  final VoidCallback onDelete;
  final ValueChanged<double> onRatingUpdate;

  const ExperienceCardWM({
    Key? key,
    required this.experience,
    required this.onDelete,
    required this.onRatingUpdate,
  }) : super(key: key);

  @override
  _ExperienceCardStateWM createState() => _ExperienceCardStateWM();
}

class _ExperienceCardStateWM extends State<ExperienceCardWM> {
  LatLng? _coordinates;
  LatLngBounds? _bounds;
  double? _currentRating;
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
  @override
  Widget build(BuildContext context) {
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
            Text('Descripción: ${widget.experience.description ?? 'Sin descripción'}'),
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
                    boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(10)),
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
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
              Text('Precio: \$${widget.experience.price ?? 'N/A'}'),
              Text('Correo de contacto: ${widget.experience.contactmail ?? 'Sin Correo de contacto'}'),
              Text('Número de contacto: ${widget.experience.contactnumber ?? 'Sin número de contacto'}'),
              Text('Puntuación actual: ${_currentRating?.toStringAsFixed(1) ?? 'N/A'}'),
              Text('Calificación promedio: ${widget.experience.averageRating?.toStringAsFixed(1) ?? 'N/A'}'),
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
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: widget.onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*@override
  Widget build(BuildContext context) {
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
            Text('Descripción: ${widget.experience.description ?? 'Sin descripción'}'),
            Text('Propietario: ${_ownerName ?? 'Sin propietario'}'),
            Text('Precio: \$${widget.experience.price ?? 'N/A'}'),
            Text('Correo de contacto: ${widget.experience.contactmail ?? 'Sin Correo de contacto'}'),
            Text('Número de contacto: ${widget.experience.contactnumber ?? 'Sin localización'}'),
            Text('Puntuación actual: ${_currentRating?.toStringAsFixed(1) ?? 'N/A'}'),
            Text('Calificación promedio: ${widget.experience.averageRating?.toStringAsFixed(1) ?? 'N/A'}'), // Muestra la calificación promedio
            Text('Localización: ${widget.experience.location ?? 'Sin localización'}'),
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
                    boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(10)),
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    if (_coordinates != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _coordinates!,
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              color: Colors.red,
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

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: widget.onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }*/
}

