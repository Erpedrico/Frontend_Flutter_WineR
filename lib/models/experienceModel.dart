import 'package:latlong2/latlong.dart';

class ExperienceModel {
  String? id; // Identificador único de la experiencia
  String? title; // Título de la experiencia
  String? description; // Descripción de la experiencia
  String? owner; // ID del creador
  int? price; // Precio de la experiencia
  String? location; // Dirección o ubicación de la experiencia
  int? contactnumber; // Número de contacto
  String? contactmail; // Correo electrónico de contacto
  LatLng? coordinates; // Coordenadas (calculadas en el frontend si es necesario)
  double? rating; // Calificación de la experiencia
  List<String>? reviews; // Lista de IDs de las reseñas
  String? date; // Fecha de la experiencia
  List<Service>? services; // Lista de servicios ofrecidos

  ExperienceModel({
    this.id,
    this.title,
    this.description,
    this.owner,
    this.price,
    this.location,
    this.contactnumber,
    this.contactmail,
    this.coordinates,
    this.rating,
    this.reviews,
    this.date,
    this.services,
  });

  // Constructor desde JSON
  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      owner: json['owner'],
      price: json['price'],
      location: json['location'],
      contactnumber: json['contactnumber'],
      contactmail: json['contactmail'],
      coordinates: json.containsKey('latitude') && json.containsKey('longitude')
          ? LatLng(json['latitude'], json['longitude'])
          : null,
      rating: json['rating']?.toDouble(),
      reviews: (json['reviews'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      date: json['date'],
      services: (json['services'] as List<dynamic>?)
          ?.map((service) => Service.fromJson(service))
          .toList(),
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'owner': owner,
      'price': price,
      'location': location,
      'contactnumber': contactnumber,
      'contactmail': contactmail,
      'latitude': coordinates?.latitude, // Enviar coordenadas si están disponibles
      'longitude': coordinates?.longitude,
      'rating': rating,
      'reviews': reviews,
      'date': date,
      'services': services?.map((service) => service.toJson()).toList(),
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