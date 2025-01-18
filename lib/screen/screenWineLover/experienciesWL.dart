import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/experienceService.dart';
import 'package:flutter_application_1/models/experienceModel.dart';
import 'package:flutter_application_1/Widgets/experienceCardWL.dart';


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
      appBar: AppBar(title: const Text('Gestión de Experiencias')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _experiences.length,
                    itemBuilder: (context, index) {
                      return ExperienceCardWL(
                        experience: _experiences[index],
                        onRatingUpdate: (rating) async {
                          setState(() {
                            _experiences[index].rating = rating;
                          });
                        },
                      );
                    },
                  ),
                ),
                
              ],
            ),
    );
  }
}