import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/userService.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../models/experienceModel.dart';
import 'package:http/http.dart' as http;

class ExperienceCardWM extends StatefulWidget {
  final ExperienceModel experience;
  final VoidCallback onDelete;
  final ValueChanged<double> onRatingUpdate;

  const ExperienceCardWM({
    super.key,
    required this.experience,
    required this.onDelete,
    required this.onRatingUpdate,
  });

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
            // Título y Propietario
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.experience.title ?? 'Sin título',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Propietario: ${_ownerName ?? 'Sin propietario'}'),
            const SizedBox(height: 16),

            // Imagen
            if (widget.experience.imagen != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                  image: DecorationImage(
                    image: NetworkImage(widget.experience.imagen!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey[300],
                ),
                child: const Center(
                  child: Text('Sin imagen disponible'),
                ),
              ),

            const SizedBox(height: 16),

            // Mapa
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
                    boundsOptions: const FitBoundsOptions(
                        padding: EdgeInsets.all(10)),
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

            // Información adicional
            if (_showFullInfo) ...[
              Text('Precio: \$${widget.experience.price ?? 'N/A'}'),
              Text(
                  'Correo de contacto: ${widget.experience.contactmail ?? 'Sin correo'}'),
              Text(
                  'Número de contacto: ${widget.experience.contactnumber ?? 'Sin número'}'),
              Text('Fecha: $formattedDate'),
              Text('Servicios:'),
              Column(
                children: widget.experience.services!.map((service) {
                  return Text('${service.icon} ${service.label}');
                }).toList(),
              ),
            ],

            // Botón para mostrar más/menos
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

