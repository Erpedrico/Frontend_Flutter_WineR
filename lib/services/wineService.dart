import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/userModel.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:provider/provider.dart';
import '../models/wineModel.dart';


class WineService {
  final Dio dio = Dio();
  
  final String baseUrl = "http://127.0.0.1:3000/api/wine";

  Future<List<WineModel>> getAllWines(BuildContext context) async {
    try {
      final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
      UserModel? perfil = perfilProvider.perfilUsuario;
      String? token = perfil?.token;
      final response = await dio.get(
        '$baseUrl',
        options: Options(
          headers: {
            'auth-token': token,
          },
        ),
        );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => WineModel.fromJson(json)).toList();
      } else {
          throw Exception('Failed to load wines');
      }
      }   catch (e) {
        print('Error al obtener los vinos: $e');
        return [];
      }
    }

  Future<List<WineModel>> getWinesByOwner(BuildContext context, String ownerId) async {
    try {
      final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
      UserModel? perfil = perfilProvider.perfilUsuario;
      String? token = perfil?.token;

      final response = await dio.get(
        '$baseUrl/owner/$ownerId',
        options: Options(
          headers: {
            'auth-token': token,
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => WineModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load wines');
      }
    } catch (e) {
      print('Error al obtener los vinos: $e');
      return [];
    }
  }

  Future<void> createWine(BuildContext context, WineModel wine) async {
    try {
      final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
      UserModel? perfil = perfilProvider.perfilUsuario;
      String? token = perfil?.token;

      final response = await dio.post(
        baseUrl,
        data: wine.toJson(),
        options: Options(
          headers: {
            'auth-token': token,
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create wine');
      }
    } catch (e) {
      print('Error al crear el vino: $e');
      throw e;
    }
  }
}