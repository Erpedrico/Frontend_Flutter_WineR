import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String? _username; 
  String? _id;       
  String? _token; 
  String _name;
  String _mail;
  String _password;
  String _comment;   
  String _tipo;  
  String? _imagen;    // Campo para la imagen del usuario
  List<String>? _amigos; 
  List<String>? _solicitudes; 
  List<String>? _experiences;

  // Constructor
  UserModel({
    String? username,
    String? id,
    String? token,
    required String name,
    required String mail,
    required String password,
    required String comment,
    required String tipo,
    String? imagen, // Se agrega la propiedad imagen
    List<String>? amigos,
    List<String>? solicitudes,
    List<String>? experiences,
  })  : _username = username,
        _id = id,
        _token = token,
        _name = name,
        _mail = mail,
        _password = password,
        _comment = comment,
        _tipo = tipo,
        _imagen = imagen,  // Asignación de la imagen
        _amigos = amigos,
        _solicitudes = solicitudes, 
        _experiences = experiences;

  // Getters
  String? get username => _username;
  String? get id => _id;
  String? get token => _token;
  String get name => _name;
  String get mail => _mail;
  String get password => _password;
  String get comment => _comment;
  String get tipo => _tipo;
  String? get imagen => _imagen; // Getter para la imagen
  List<String>? get amigos => _amigos; 
  List<String>? get solicitudes => _solicitudes;
  List<String>? get experiences => _experiences; 

  // Método para actualizar el usuario
  void setUser({
    String? username,
    String? id,
    String? token,
    required String name,
    required String mail,
    required String password,
    required String comment,
    required String tipo,
    String? imagen, // Parámetro para la imagen
    List<String>? amigos,
    List<String>? solicitud,
    List<String>? experiences,
  }) {
    _username = username;
    _id = id;
    _token = token;
    _name = name;
    _mail = mail;
    _password = password;
    _comment = comment;
    _tipo = tipo;
    _imagen = imagen; // Actualiza la imagen
    _amigos = amigos;
    _solicitudes = solicitud;
    _experiences = experiences;
    notifyListeners();
  }

  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }

  // Método fromJson para crear una instancia de UserModel desde un Map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'], 
      id: json['_id'],           
      token: json['token'],
      name: json['name'] ?? 'Usuario desconocido',
      mail: json['mail'] ?? 'No especificado',
      password: json['password'] ?? 'Sin contraseña',
      comment: json['comment'] ?? 'Sin comentarios',      
      tipo: json['tipo'] ?? 'Sin tipo',  
      imagen: json['image'], // Se agrega la propiedad imagen en el JSON
      amigos: json['amigos'] != null ? List<String>.from(json['amigos']) : [], 
      solicitudes: json['solicitudes'] != null ? List<String>.from(json['solicitudes']) : [], 
      experiences: json['experiences'] != null ? List<String>.from(json['experiences']) : [], 
    );
  }

  // Método toJson para convertir una instancia de UserModel en un Map
  Map<String, dynamic> toJson() {
    return {
      'username': _username, 
      'name': _name,
      'mail': _mail,
      'password': _password,
      'comment': _comment,       
      'tipo': _tipo,
      'habilitado': true,
      'image': _imagen, // Agrega la propiedad imagen en el JSON
      'amigos': _amigos,
      'solicitudes': _solicitudes,
      'experiences' : _experiences,
    };
  }
}

