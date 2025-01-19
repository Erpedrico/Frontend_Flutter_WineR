import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/experienceService.dart';
import 'package:flutter_application_1/models/experienceModel.dart';
import 'package:flutter_application_1/Widgets/experienceCardWL.dart';
import 'package:get/get.dart'; // Importar para manejar `Get.offNamed`

class ExperienciesPageWL extends StatefulWidget {
  const ExperienciesPageWL({super.key});

  @override
  _ExperienciesPageStateWL createState() => _ExperienciesPageStateWL();
}

class _ExperienciesPageStateWL extends State<ExperienciesPageWL> {
  final ExperienceService _experienceService = ExperienceService();
  List<ExperienceModel> _experiences = [];
  bool _isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Experiencias'),
        backgroundColor: const Color(0xFFFF6F61), // Color rojo coral del encabezado
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Get.offNamed('/calendarioWL'); // Navegar a la página de calendario
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6F61), // Rojo coral fuerte
              Color(0xFFFFB3B3), // Rosa claro
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _experiences.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: ExperienceCardWL(
                            experience: _experiences[index],
                            onRatingUpdate: (rating) async {
                              setState(() {
                                _experiences[index].rating = rating;
                                _loadExperiences();
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
