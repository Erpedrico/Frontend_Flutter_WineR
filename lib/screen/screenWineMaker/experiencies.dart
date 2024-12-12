import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/userModel.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:flutter_application_1/services/experienceService.dart';
import 'package:flutter_application_1/models/experienceModel.dart';
import 'package:flutter_application_1/Widgets/experienceCard.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

class ExperienciesPage extends StatefulWidget {
  @override
  _ExperienciesPageState createState() => _ExperienciesPageState();
}

class _ExperienciesPageState extends State<ExperienciesPage> {
  final ExperienceService _experienceService = ExperienceService();
  List<ExperienceModel> _experiences = [];
  bool _isLoading = true;
  bool _showForm = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  //final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactnumberController =
      TextEditingController();
  final TextEditingController _contactmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExperiences();
  }

  Future<void> _loadExperiences() async {
    try {
      setState(() {
        _isLoading = true;
      });
      List<ExperienceModel> experiences =
          await _experienceService.getExperiences();
      setState(() {
        _experiences = experiences;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading experiences: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteExperience(String id) async {
    try {
      int status = await _experienceService.deleteExperienceById(id); // O reemplazar con `deleteExperience(id)` si está implementado
      if (status == 201) {
        setState(() {
          _experiences.removeWhere((experience) => experience.id == id);
        });
      } else {
        print('Error deleting experience');
      }
    } catch (e) {
      print('Error deleting experience: $e');
    }
  }

  Future<void> _createExperience() async {
    try {
      // Obtener el PerfilProvider desde el contexto
      final perfilProvider =
          Provider.of<PerfilProvider>(context, listen: false);
      // Acceder al perfil actual almacenado en el PerfilProvider
      UserModel? perfil = perfilProvider.perfilUsuario;
      String? propietario = perfil?.id;

      int? price = int.tryParse(_priceController.text);
      int? contactnumber = int.tryParse(_contactnumberController.text);

      final String address = _locationController.text.trim();

      if (address.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, ingrese una dirección')),
        );
        return;
      }
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1');

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          if (data.isNotEmpty) {
            final double lat = double.parse(data[0]['lat']);
            final double lon = double.parse(data[0]['lon']);
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
      // Validar que los campos obligatorios estén presentes
      if (_titleController.text.isEmpty ||
          _descriptionController.text.isEmpty ||
          //_ownerController.text.isEmpty ||
          price == null ||
          _locationController.text.isEmpty ||
          contactnumber == null ||
          _contactmailController.text.isEmpty) {
        print('Todos los campos obligatorios deben completarse.');
        return;
      }

      // Crear lista de servicios (esto puede venir de una interfaz)
      List<Service> services = [
        Service(icon: '🅿️', label: 'Parking'),
        Service(icon: '📶', label: 'Wi-Fi gratuito'),
      ];

      // Crear el modelo de experiencia
      ExperienceModel newExperience = ExperienceModel(
        title: _titleController.text,
        description: _descriptionController.text,
        //owner: _ownerController.text,
        owner: propietario,
        price: price,
        location: _locationController.text,
        contactnumber: contactnumber,
        contactmail: _contactmailController.text,
        //coordinates: coordinates, // Coordenadas calculadas
        rating: 0.0, // Inicializar con una calificación predeterminada
        reviews: [], // No hay reseñas inicialmente
        date: DateTime.now().toIso8601String(), // Fecha actual en formato ISO
        services: services, // Servicios predefinidos
      
      );

      // Enviar la experiencia al backend
      int status = await _experienceService.createExperience(newExperience);
      if (status == 201) {
        // Limpiar campos si la experiencia se creó correctamente
        _titleController.clear();
        _descriptionController.clear();
        //_ownerController.clear();
        _priceController.clear();
        _locationController.clear();
        _contactnumberController.clear();
        _contactmailController.clear();
        _loadExperiences(); // Recargar la lista de experiencias
        print(newExperience);
      } else {
        print('Error creating experience');
      }
    } catch (e) {
      print('Error creating experience: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestión de Experiencias')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _experiences.length,
                    itemBuilder: (context, index) {
                      final experience = _experiences[index];
                      return ExperienceCard(
                        experience: experience,
                        onDelete: () => _deleteExperience(experience.id!),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showForm = !_showForm;
                    });
                  },
                  child: Text(
                      _showForm ? 'Ocultar Formulario' : 'Mostrar Formulario'),
                ),
                if (_showForm)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(labelText: 'Titulo'),
                        ),
                        TextField(
                          controller: _descriptionController,
                          decoration: InputDecoration(labelText: 'Descripción'),
                        ),
                        /*TextField(
                          controller: _ownerController,
                          decoration: InputDecoration(labelText: 'Propietario'),
                        ),*/
                        TextField(
                          controller: _priceController,
                          decoration: InputDecoration(labelText: 'Precio'),
                        ),
                        TextField(
                          controller: _locationController,
                          decoration:
                              InputDecoration(labelText: 'Localización'),
                        ),
                        TextField(
                          controller: _contactnumberController,
                          decoration:
                              InputDecoration(labelText: 'Número de contacto'),
                        ),
                        TextField(
                          controller: _contactmailController,
                          decoration:
                              InputDecoration(labelText: 'Correo de contacto'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _createExperience,
                          child: Text('Crear Experiencia'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
