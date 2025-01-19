import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/userModel.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:flutter_application_1/services/experienceService.dart';
import 'package:flutter_application_1/models/experienceModel.dart';
import 'package:flutter_application_1/Widgets/experienceCardWM.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ExperienciesPageWM extends StatefulWidget {
  const ExperienciesPageWM({super.key});

  @override
  _ExperienciesPageStateWM createState() => _ExperienciesPageStateWM();
}

class _ExperienciesPageStateWM extends State<ExperienciesPageWM> {
  final ExperienceService _experienceService = ExperienceService();
  List<ExperienceModel> _experiences = [];
  bool _isLoading = true;
  bool _showForm = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactnumberController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final List<Service> selectedServices = [];
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

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
      int status = await _experienceService.deleteExperienceById(id);
      if (status == 200) {
        setState(() {
          _experiences.removeWhere((experience) => experience.id == id);
        });
        _loadExperiences();
      } else {
        print('Error deleting experience');
      }
    } catch (e) {
      print('Error deleting experience: $e');
    }
    _loadExperiences();
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: const Text(
                  '¿Estás seguro de que deseas eliminar esta experiencia?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Eliminar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  final List<Service> servicesOptions = [
    Service(icon: "🍷", label: "Wine tastings"),
    Service(icon: "🍴", label: "Restaurant"),
    Service(icon: "🅿", label: "Parking"),
    Service(icon: "🌿", label: "Vineyard tours"),
    Service(icon: "🏛", label: "Winery tours"),
    Service(icon: "🐾", label: "Pet friendly"),
  ];

  void _toggleService(Service service) {
    setState(() {
      if (selectedServices.contains(service)) {
        selectedServices.remove(service);
      } else {
        selectedServices.add(service);
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
  }

  Future<void> _createExperience() async {
    try {
      final perfilProvider =
          Provider.of<PerfilProvider>(context, listen: false);
      UserModel? perfil = perfilProvider.perfilUsuario;
      String? propietario = perfil?.id;
      String? mail = perfil?.mail;

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
            return;
          }
        } else {
          print('Error en la solicitud: ${response.statusCode}');
          return;
        }
      } catch (e) {
        print('Error al geocodificar dirección: $e');
        return;
      }

      if (_titleController.text.isEmpty ||
          _descriptionController.text.isEmpty ||
          price == null ||
          _locationController.text.isEmpty ||
          contactnumber == null ||
          _imageUrlController.text.isEmpty) {
        print('Todos los campos obligatorios deben completarse.');
        return;
      }

      List<Service> services = selectedServices;

      ExperienceModel newExperience = ExperienceModel(
        title: _titleController.text,
        description: _descriptionController.text,
        owner: propietario,
        price: price,
        location: _locationController.text,
        contactnumber: contactnumber,
        contactmail: mail,
        rating: 0.0,
        reviews: [],
        date: _selectedDate,
        services: services,
        averageRating: 0.0,
        imagen: _imageUrlController.text, // Agregar URL de la imagen
      );

      int status = await _experienceService.createExperience(newExperience);

      if (status == 201) {
        _titleController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _locationController.clear();
        _contactnumberController.clear();
        _imageUrlController.clear(); // Limpiar el campo de URL de la imagen
        selectedServices.clear();
        _loadExperiences();
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
      appBar: AppBar(title: const Text('Gestión de Experiencias')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _experiences.length,
                    itemBuilder: (context, index) {
                      return ExperienceCardWM(
                        experience: _experiences[index],
                        onDelete: () async {
                          final confirm =
                              await _showDeleteConfirmationDialog(context);
                          if (confirm) {
                            await _deleteExperience(_experiences[index].id!);
                            _loadExperiences();
                          }
                        },
                        onRatingUpdate: (rating) async {
                          setState(() {
                            _experiences[index].rating = rating;
                          });
                        },
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
                      _showForm ? 'Ocultar Formulario' : 'Crear Experiencia'),
                ),
                if (_showForm) _buildForm(),
              ],
            ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Precio'),
          ),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Localización'),
          ),
          TextField(
            controller: _contactnumberController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Número de contacto'),
          ),
          TextField(
            controller: _imageUrlController,
            decoration: const InputDecoration(labelText: 'URL de la Imagen'),
          ),
          TextField(
            controller: _dateController,
            decoration: InputDecoration(labelText: 'Fecha'),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 16),
          Text('Selecciona los servicios:'),
          SizedBox(
            height: 150,
            child: ListView(
              children: servicesOptions
                  .map(
                    (service) => ListTile(
                      title: Text(service.label),
                      leading: Text(service.icon),
                      trailing: Checkbox(
                        value: selectedServices.contains(service),
                        onChanged: (_) => _toggleService(service),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _createExperience,
            child: const Text('Crear Experiencia'),
          ),
        ],
      ),
    );
  }
}
