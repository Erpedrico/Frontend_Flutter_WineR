import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:latlong2/latlong.dart';
import '../models/experienceModel.dart';
import '../services/experienceService.dart';
import 'package:http/http.dart' as http;

class ExperienceCard extends StatefulWidget {
  final ExperienceModel experience;
  final VoidCallback onDelete;
  final ValueChanged<double> onRatingUpdate;

  const ExperienceCard({
    Key? key,
    required this.experience,
    required this.onDelete,
    required this.onRatingUpdate,
  }) : super(key: key);

  @override
  _ExperienceCardState createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> {
  LatLng? _coordinates;
  LatLngBounds? _bounds;
  double? _currentRating;

  @override
  void initState() {
    super.initState();
    _fetchCoordinates();
    _currentRating = widget.experience.rating ?? 0.0;
  }

  Future<void> _fetchCoordinates() async {
    if (widget.experience.location != null) {
      final coords = await getCoordinates(widget.experience.location!);
      setState(() {
        _coordinates = coords;
        if (coords != null) {
          _bounds =
              LatLngBounds(coords, coords); // Ajusta los límites al marcador
        }
      });
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

  Future<void> _updateRating(double rating) async {
    final experienceService = ExperienceService();
    final status = await experienceService.updateExperienceRating(
        widget.experience.id!, rating);

    if (status == 200) {
      setState(() {
        _currentRating = rating;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Puntuación actualizada con éxito')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la puntuación')),
      );
    }
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
            Text(
                'Descripción: ${widget.experience.description ?? 'Sin descripción'}'),
            Text(
                'Propietario: ${widget.experience.owner ?? 'Sin propietario'}'),
            Text(
                'Precio: \$${widget.experience.price ?? 'N/A'}'),
            Text(
                'Puntuación actual: ${_currentRating?.toStringAsFixed(1) ?? 'N/A'}'),
            /*Text(
                'Puntuación promedio: ${widget.experience.rating?.toStringAsFixed(1) ?? 'N/A'}'),*/

            Text(
                'Localización: ${widget.experience.location ?? 'Sin localización'}'),
            Text(
                'Teléfono: ${widget.experience.contactnumber ?? 'Sin número'}'),
            Text(
                'Correo: ${widget.experience.contactmail ?? 'Sin correo'}'),
            Text(
                'Latitud: ${_coordinates?.latitude ?? 'Sin latitud'}'),
            Text(
                'Longitud: ${_coordinates?.longitude ?? 'Sin longitud'}'),
            const SizedBox(height: 16),
            Container(
              height: 200, // Altura fija del mapa
              width: double.infinity, // Ocupa todo el ancho disponible
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Bordes redondeados
                border: Border.all(
                    color: Colors.grey), // Borde gris alrededor del mapa
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    10), // Mantiene los bordes redondeados
                child: FlutterMap(
                  options: MapOptions(
                    bounds:
                        _bounds, // Ajusta automáticamente la vista a los límites
                    boundsOptions: FitBoundsOptions(
                      padding:
                          EdgeInsets.all(10), // Margen alrededor de los límites
                    ),
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
                            builder: (ctx) => Icon(
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

            // RatingBar para puntuar la experiencia
            Text('Puntuar esta experiencia:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            RatingBar.builder(
              initialRating: widget.experience.rating ?? 0.0,
              minRating: 0,
              maxRating: 5,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              
              onRatingUpdate: (rating) async {
                // Actualiza el rating en el backend y el estado local
                final experienceService = ExperienceService();
                final status = await experienceService.updateExperienceRating(
                    widget.experience.id!, rating);
                    

                if (status == 200) {
                  setState(() {
                    _currentRating = rating;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Puntuación actualizada con éxito')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error al actualizar la puntuación')),
                  );
                }
              },
            ),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: widget.onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
