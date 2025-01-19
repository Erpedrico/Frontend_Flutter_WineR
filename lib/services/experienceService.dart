import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/experienceModel.dart';
import 'package:flutter_application_1/models/userModel.dart';
import 'package:dio/dio.dart';

class ExperienceService {
  final String baseUrl =
      "http://127.0.0.1:3000/api/experiencias"; // URL de tu backend web
  //final String baseUrl = "http://10.0.2.2:3000/api/experiencias"; // URL de tu backend Android
  final Dio dio = Dio(); // Instancia de Dio para realizar solicitudes HTTP
  var statusCode;
  var data;

  // Función para crear una nueva experiencia
  Future<int> createExperience(ExperienceModel newExperience) async {
    print('createExperience');
    try {
      // Enviar solicitud POST para crear una nueva experiencia
      Response response = await dio.post(
        '$baseUrl/flutter',
        data: newExperience.toJson(),
      );

      // Guardar datos de la respuesta
      data = response.data.toString();
      statusCode = response.statusCode;
      print('Data: $data');
      print('Status code: $statusCode');

      // Verificar el código de estado
      if (statusCode == 200) {
        print('200');
        return 201;
      } else if (statusCode == 400) {
        print('400');
        return 400;
      } else if (statusCode == 500) {
        print('500');
        return 500;
      } else {
        print('-1');
        return -1;
      }
    } catch (e) {
      print('Error creating experience: $e');
      return -1;
    }
  }

  // Función para obtener la lista de experiencias
  Future<List<ExperienceModel>> getExperiences() async {
    print('getExperiences');
    try {
      // Enviar solicitud GET para obtener las experiencias
      var res = await dio.get(baseUrl);
      print(res);
      List<dynamic> responseData = res.data;
      print(responseData);
      // Convertir la respuesta en una lista de ExperienceModel
      List<ExperienceModel> experiences =
          responseData.map((data) => ExperienceModel.fromJson(data)).toList();

      return experiences;
    } catch (e) {
      print('Error fetching experiences: $e');
      rethrow;
    }
  }

  // Función para editar una experiencia existente
  Future<int> editExperience(
      ExperienceModel updatedExperience, String id) async {
    print('editExperience');
    try {
      // Enviar solicitud PUT para actualizar una experiencia
      Response response = await dio.put(
        '$baseUrl/$id',
        data: updatedExperience.toJson(),
      );

      // Guardar datos de la respuesta
      data = response.data.toString();
      statusCode = response.statusCode;
      print('Data: $data');
      print('Status code: $statusCode');

      // Verificar el código de estado
      if (statusCode == 200) {
        print('200');
        return 201;
      } else if (statusCode == 400) {
        print('400');
        return 400;
      } else if (statusCode == 500) {
        print('500');
        return 500;
      } else {
        print('-1');
        return -1;
      }
    } catch (e) {
      print('Error editing experience: $e');
      return -1;
    }
  }

  // Función para eliminar una experiencia por Id
  Future<int> deleteExperienceById(String id) async {
    print('deleteExperienceById');
    try {
      // Enviar solicitud DELETE utilizando la Id como parámetro en la URL
      Response response = await dio.delete('$baseUrl/$id');

      // Guardar datos de la respuesta
      data = response.data.toString();
      statusCode = response.statusCode;
      print('Data: $data');
      print('Status code: $statusCode');

      // Verificar el código de estado
      if (statusCode == 200) {
        print('200');
        return 201;
      } else if (statusCode == 400) {
        print('400');
        return 400;
      } else if (statusCode == 500) {
        print('500');
        return 500;
      } else {
        print('-1');
        return -1;
      }
    } catch (e) {
      print('Error deleting experience: $e');
      return -1;
    }
  }

  // Método para apuntarse a una experiencia
  Future<int> joinExperience(String experienceId, String userId) async {
    print('joinExperience');
    try {
      // Construir URL
      final url = '$baseUrl/Participant/$experienceId/$userId';

      // Enviar solicitud POST
      Response response = await dio.post(url);

      // Verificar el código de estado
      final statusCode = response.statusCode;
      print('Status code: $statusCode');
      print('Data: ${response.data}');

      if (statusCode == 200) {
        print('Te has apuntado a la experiencia con éxito.');
        return 200; // Éxito
      } else {
        print('Error al apuntarse a la experiencia.');
        return statusCode ?? -1; // Devuelve el código de error
      }
    } catch (e) {
      print('Error en joinExperience: $e');
      return -1; // Otro error
    }
  }

  Future<void> addParticipantToExperience(String experienceId, String userId) async {
    try {
      final response = await dio.patch(
        '$baseUrl/experiences/$experienceId/participants/$userId',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to join experience');
      }
    } catch (e) {
      print('Error al unirse a la experiencia: $e');
      throw e;
    }
  }

  Future<int> addParticipantToExperiencia(String experienceId, String userId) async {
    try {
      // Construir URL
      final url = '$baseUrl/Participant/$experienceId/$userId';

      // Enviar solicitud POST
      Response response = await dio.post(url);

      // Verificar el código de estado
      final statusCode = response.statusCode;
      print('Status code: $statusCode');
      print('Data: ${response.data}');

      if (statusCode == 200) {
        print('Te has apuntado a la experiencia con éxito.');
        return 200; // Éxito
      } else {
        print('Error al apuntarse a la experiencia.');
        return statusCode ?? -1; // Devuelve el código de error
      }
    } catch (e) {
      print('Error en joinExperience: $e');
      return -1; // Otro error
    }
  }

  Future<int> addRatingWithComment(
      String experienceId, String userId, double rating, String comment) async {
    try {
      final response = await dio.post(
        '$baseUrl/rate/$experienceId/$userId',
        data: {
          'ratingValue': rating,
          'comment': comment,
        },
      );
      print(data);
      return response.statusCode ?? -1;
    } catch (e) {
      print('Error al enviar la valoración: $e');
      return -1;
    }
  }

  /*Future<int> getRatingWithComment(String experienceId,) async {
    try {
      final response = await dio.get(
        '$baseUrl/ratings/$experienceId',
      );
      return response.statusCode ?? -1;
    } catch (e) {
      print('Error al enviar la valoración: $e');
      return -1;
    }
  }*/

  Future<List<Map<String, dynamic>>> getRatingWithComment(
      String experienceId) async {
    try {
      final response = await dio.get('$baseUrl/ratings/$experienceId');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        return [];
      }
    } catch (e) {
      print('Error al obtener las valoraciones: $e');
      return [];
    }
  }

  Future<List<ExperienceModel>> getExperiencesByOwner(String ownerId) async {
    try {
      final response = await dio.get('$baseUrl/user/exp/$ownerId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ExperienceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load experiences');
      }
    } catch (e) {
      print('Error al obtener las experiencias: $e');
      return [];
    }
  }

  Future<ExperienceModel?> getExperienceById(BuildContext context, String experienceId) async {
    try {
      final response = await dio.get('$baseUrl/$experienceId');
      if (response.statusCode == 200) {
        return ExperienceModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load experience');
      }
    } catch (e) {
      print('Error al obtener la experiencia: $e');
      return null;
    }
  }
}
