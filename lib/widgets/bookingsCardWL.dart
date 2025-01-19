import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:flutter_application_1/services/userService.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/experienceModel.dart';
import '../services/experienceService.dart';
import 'package:http/http.dart' as http;

class BookingsCardWL extends StatefulWidget {
  final ExperienceModel experience;
  final ValueChanged<double> onRatingUpdate;

  const BookingsCardWL({
    super.key,
    required this.experience,
    required this.onRatingUpdate,
  });

  @override
  _BookingsCardStateWL createState() => _BookingsCardStateWL();
}

class _BookingsCardStateWL extends State<BookingsCardWL> {
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

  Future<void> _showRatingDialog() async {
    double rating = _currentRating ?? 0.0;
    String comment = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Valorar Experiencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: rating,
                minRating: 0,
                maxRating: 5,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (value) {
                  rating = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Escribe tu comentario',
                ),
                onChanged: (value) {
                  comment = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _submitRating(rating, comment);
                Navigator.of(context).pop();
                _fetchReviews();
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRating(double rating, String comment) async {
    final user = context.read<PerfilProvider>().getUser();

    if (widget.experience.id == null || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: ID de experiencia o usuario no válido')),
      );
      return;
    }

    final experienceService = ExperienceService();
    final status = await experienceService.addRatingWithComment(
      widget.experience.id!,
      user.id!,
      rating,
      comment,
    );

    if (status == 200) {
      setState(() {
        _currentRating = rating;
        widget.experience.rating = rating;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Valoración enviada con éxito!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar la valoración')),
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
              Text('Precio: \$${widget.experience.price ?? 'N/A'}'),
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
            ],
            ElevatedButton(
              onPressed: () => _showReviewsDialog(),
              child: const Text('Ver valoraciones'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showRatingDialog,
              child: const Text('Valorar experiencia'),
            ),
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
