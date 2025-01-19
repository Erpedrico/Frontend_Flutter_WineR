import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/experienceModel.dart';
import '../../models/userModel.dart';
import '../../services/experienceService.dart';
import '../../providers/perfilProvider.dart';

class CalendarioPageWM extends StatefulWidget {
  @override
  _CalendarioPageWMState createState() => _CalendarioPageWMState();
}

class _CalendarioPageWMState extends State<CalendarioPageWM> {
  Map<DateTime, List<ExperienceModel>> _experiencesByDate = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Future<List<ExperienceModel>> _myExperiences;
  List<ExperienceModel> _selectedDayExperiences = [];
  final ExperienceService _experienceService = ExperienceService();

  @override
  void initState() {
    super.initState();
    _myExperiences = Future.value([]);
    _fetchMyExperiences();
  }

  Future<void> _fetchMyExperiences() async {
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
    UserModel? perfil = perfilProvider.perfilUsuario;
    String? ownerId = perfil?.id;

    if (ownerId != null) {
      try {
        final experiences = await _experienceService.getExperiencesByOwner(ownerId);
        setState(() {
          _experiencesByDate = _groupExperiencesByDate(experiences);
          _myExperiences = Future.value(experiences);
        });
      } catch (e) {
        print('Error al cargar las experiencias: $e');
      }
    }
  }

  Map<DateTime, List<ExperienceModel>> _groupExperiencesByDate(List<ExperienceModel> experiences) {
    Map<DateTime, List<ExperienceModel>> groupedExperiences = {};
    for (var experience in experiences) {
      if (experience.date != null) {
        final date = DateTime(experience.date!.year, experience.date!.month, experience.date!.day);
        if (groupedExperiences[date] == null) {
          groupedExperiences[date] = [];
        }
        groupedExperiences[date]!.add(experience);
      }
    }
    return groupedExperiences;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedDayExperiences =
          _experiencesByDate[DateTime(selectedDay.year, selectedDay.month, selectedDay.day)] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Experiencias'),
      ),
      body: FutureBuilder<List<ExperienceModel>>(
        future: _myExperiences,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar las experiencias'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay experiencias disponibles'));
          } else {
            return Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: _onDaySelected,
                  eventLoader: (day) {
                    final normalizedDay = DateTime(day.year, day.month, day.day);
                    return _experiencesByDate[normalizedDay] ?? [];
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final normalizedDay = DateTime(day.year, day.month, day.day);
                      if (_experiencesByDate.containsKey(normalizedDay)) {
                        return Container(
                          margin: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade200,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }
                      return null;
                    },
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          bottom: 4,
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: _selectedDayExperiences.isNotEmpty
                      ? ListView.builder(
                          itemCount: _selectedDayExperiences.length,
                          itemBuilder: (context, index) {
                            final experience = _selectedDayExperiences[index];
                            return ListTile(
                              title: Text(experience.title ?? 'Sin título'),
                              subtitle: Text(experience.description ?? 'Sin descripción'),
                            );
                          },
                        )
                      : Center(
                          child: Text(_selectedDay != null
                              ? 'No hay experiencias para este día'
                              : 'Selecciona un día para ver sus experiencias'),
                        ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

