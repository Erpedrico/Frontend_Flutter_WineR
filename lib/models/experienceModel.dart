import 'package:latlong2/latlong.dart';

class ExperienceModel {
  String? id; // Identificador único de la experiencia
  String? title; // Título de la experiencia
  String? description; // Descripción de la experiencia
  String? owner; // ID del creador
  List<String>? participants;
  int? price; // Precio de la experiencia
  String? location; // Dirección o ubicación de la experiencia
  int? contactnumber; // Número de contacto
  String? contactmail; // Correo electrónico de contacto
  LatLng? coordinates; // Coordenadas (calculadas en el frontend si es necesario)
  double? rating; // Calificación de la experiencia
  List<String>? reviews; // Lista de IDs de las reseñas
  DateTime? date; // Fecha de la experiencia
  List<Service>? services; // Lista de servicios ofrecidos
  double? averageRating;

  ExperienceModel({
    this.id,
    this.title,
    this.description,
    this.owner,
    this.participants,
    this.price,
    this.location,
    this.contactnumber,
    this.contactmail,
    this.coordinates,
    this.rating,
    this.reviews,
    this.date,
    this.services,
    this.averageRating,
  });

  // Constructor desde JSON
  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      owner: json['owner'],
      participants: json['participants'] != null ? List<String>.from(json['participants']) : [],
      price: json['price'],
      location: json['location'],
      contactnumber: json['contactnumber'],
      contactmail: json['contactmail'],
      coordinates: json.containsKey('latitude') && json.containsKey('longitude')
          ? LatLng(json['latitude'], json['longitude'])
          : null,
      rating: (json['rating'] != null) ? json['rating'].toDouble() : null,
      reviews: (json['reviews'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      services: (json['services'] as List<dynamic>?)
          ?.map((service) => Service.fromJson(service))
          .toList(),
      averageRating: (json['averageRating'] != null) ? json['averageRating'].toDouble() : null, // Conversión a double
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'owner': owner,
      'participants': participants,
      'price': price,
      'location': location,
      'contactnumber': contactnumber,
      'contactmail': contactmail,
      'latitude': coordinates?.latitude, // Enviar coordenadas si están disponibles
      'longitude': coordinates?.longitude,
      'rating': rating,
      'reviews': reviews,
      'date': date?.toIso8601String(),
      'services': services?.map((service) => service.toJson()).toList(),
      'averageRating': averageRating,
    };
  }
}

// Modelo para representar los servicios
class Service {
  String icon; // Icono del servicio (emoji o URL)
  String label; // Descripción del servicio

  Service({
    required this.icon,
    required this.label,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      icon: json['icon'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'label': label,
    };
  }
}