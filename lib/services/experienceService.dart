import 'package:flutter_application_1/models/experienceModel.dart';
import 'package:flutter_application_1/models/userModel.dart';
import 'package:dio/dio.dart';

class ExperienceService {
  final String baseUrl = "http://127.0.0.1:3000/api/experiencias"; // URL de tu backend web
  //final String baseUrl = "http://10.0.2.2:3000"; // URL de tu backend Android
  final Dio dio = Dio(); // Instancia de Dio para realizar solicitudes HTTP
  var statusCode;
  var data;

  // Función para crear una nueva experiencia
  Future<int> createExperience(ExperienceModel newExperience) async {
    print('createExperience');
    try {
      // Enviar solicitud POST para crear una nueva experiencia
      Response response = await dio.post(
        '$baseUrl',
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
      var res = await dio.get('$baseUrl');
      print(res);
      List<dynamic> responseData = res.data;
      print(responseData);
      // Convertir la respuesta en una lista de ExperienceModel
      List<ExperienceModel> experiences =
          responseData.map((data) => ExperienceModel.fromJson(data)).toList();

      return experiences;
    } catch (e) {
      print('Error fetching experiences: $e');
      throw e;
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

  // Función para actualizar el rating de una experiencia
  Future<int> updateExperienceRating(String id, double rating, String userId) async {
    print('updateExperienceRating');
    try {
      // Enviar solicitud POST con los datos correctos
      Response response = await dio.post(
        '$baseUrl/rate/$id/$userId', // Endpoint ajustado
        data: {'ratingValue': rating}, // Clave actualizada
      );

      // Guardar datos de la respuesta
      final data = response.data.toString();
      final statusCode = response.statusCode;
      print('Data: $data');
      print('Status code: $statusCode');

      // Verificar el código de estado
      if (statusCode == 200) {
        print('200');
        return 200; // Éxito
      } else if (statusCode == 400) {
        print('400');
        return 400; // Error de cliente
      } else if (statusCode == 500) {
        print('500');
        return 500; // Error del servidor
      } else {
        print('-1');
        return -1; // Otro error
      }
    } catch (e) {
      print('Error updating experience rating: $e');
      return -1;
    }
  }
}
