import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/userModel.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart'; // Importa GetX
import '../../models/experienceModel.dart';
import '../../services/userService.dart';
import '../../providers/perfilProvider.dart';

class CalendarioPageWL extends StatefulWidget {
  @override
  _CalendarioPageWLState createState() => _CalendarioPageWLState();
}

class _CalendarioPageWLState extends State<CalendarioPageWL> {
  Map<DateTime, List<ExperienceModel>> _bookings = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Future<List<ExperienceModel>> _currentExperiences;
  List<ExperienceModel> _selectedDayExperiences = []; // Experiencias del día seleccionado
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _currentExperiences = Future.value([]);
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
    UserModel? perfil = perfilProvider.perfilUsuario;
    String? token = perfil?.token;

    if (token != null) {
      try {
        _userService.token = token;
        final experiences = await _userService.fetchUserExperiences(token);
        setState(() {
          _bookings = _groupBookingsByDate(experiences);
          _currentExperiences = Future.value(experiences);
        });
        print('Bookings loaded: $_bookings'); // Depuración
      } catch (e) {
        print('Error fetching experiences: $e');
      }
    } else {
      print('Token is null');
    }
  }

  Map<DateTime, List<ExperienceModel>> _groupBookingsByDate(List<ExperienceModel> bookings) {
    Map<DateTime, List<ExperienceModel>> data = {};
    for (var booking in bookings) {
      if (booking.date != null) {
        final date = DateTime(booking.date!.year, booking.date!.month, booking.date!.day);
        if (data[date] == null) {
          data[date] = [];
        }
        data[date]!.add(booking);
      } else {
        print("Booking without date: ${booking.title}");
      }
    }
    return data;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      // Actualiza las experiencias del día seleccionado
      _selectedDayExperiences = _bookings[DateTime(selectedDay.year, selectedDay.month, selectedDay.day)] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Reservas'),
      ),
      body: FutureBuilder<List<ExperienceModel>>(
        future: _currentExperiences,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar las reservas'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay reservas disponibles'));
          } else {
            return Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: _onDaySelected,
                  eventLoader: (day) {
                    final normalizedDay = DateTime(day.year, day.month, day.day);
                    return _bookings[normalizedDay] ?? [];
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final normalizedDay = DateTime(day.year, day.month, day.day);
                      if (_bookings.containsKey(normalizedDay)) {
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
                  // Muestra las experiencias del día seleccionado
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
                              ? 'No hay reservas para este día'
                              : 'Selecciona un día para ver sus reservas'),
                        ),
                ),
                const SizedBox(height: 16.0),
                // Botón para redirigir a /main
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offNamed('/main');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Color del botón
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Ir a Inicio',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
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

