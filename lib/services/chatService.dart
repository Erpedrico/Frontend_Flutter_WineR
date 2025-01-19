import 'package:dio/dio.dart';
import 'package:flutter_application_1/models/userModel.dart';
class ChatService {
  //final String baseUrl = "http://147.83.7.158:5000";
  //final String baseUrl = "http://127.0.0.1:3000"; // URL de tu backend Web
  //final String baseUrl = "http://10.0.2.2:3000"; // URL de tu backend Android
  final String baseUrl = "http://apiwiner.duckdns.org:5000";
  final Dio dio = Dio(); // Usa el prefijo 'Dio' para referenciar la clase Dio
  var statusCode;
  var data;
  String? token;
  UserModel? perfilUsuario;
  
  Future<List<String>> findRooms(String? id) async {
  try {
    print('Empieza el findRooms');
    
    // Realiza la solicitud al backend
    var res = await dio.get('$baseUrl/api/chat/rooms/$id');
    print('Ha llegado la respuesta');

    if (res.statusCode == 200) {
      print('Respuesta recibida correctamente');
      
      // Obtén los datos de la respuesta JSON
      var data = res.data as List<dynamic>; // Asegúrate de que sea una lista
      List<String> listadesalas = [];

      // Itera sobre los elementos y extrae las salas
      for (var item in data) {
        String sala = item['name']?.toString() ?? 'Usuario desconocido';
        listadesalas.add(sala);
      }

      return listadesalas; // Devuelve la lista de salas
    } else if (res.statusCode == 201) {
      print('Usuario no encontrado');
      return []; // Devuelve una lista vacía si no hay datos
    } else {
      throw Exception('Error: Código de estado inesperado (${res.statusCode})');
    }
  } catch (e) {
    print('Error fetching data: $e');
    throw Exception('Error fetching data: $e'); // Relanza el error para manejarlo en otro lugar
  }
}
}
