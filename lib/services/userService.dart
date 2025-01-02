import 'package:dio/dio.dart';
import 'package:flutter_application_1/models/userModel.dart';
class UserService {
  //final String baseUrl = "http://147.83.7.158:5000";
  //final String baseUrl = "http://127.0.0.1:3000"; // URL de tu backend Web
  final String baseUrl = "http://10.0.2.2:3000"; // URL de tu backend Android
  final Dio dio = Dio(); // Usa el prefijo 'Dio' para referenciar la clase Dio
  var statusCode;
  var data;
  String? token;
  UserModel? perfilUsuario;
  

  //Función createUser
  Future<dynamic> createUser(UserModel newUser) async {
    print('createUser');
    print('try');
    //Aquí llamamos a la función request
    print('request');
    print(newUser.toJson());
    // Utilizar Dio para enviar la solicitud POST a http://127.0.0.1:3000/user
    Response response =
        await dio.post('$baseUrl/api/user', data: newUser.toJson());
    print('response');
    token = response.headers['auth-token']?.first; // Accede al primer valor del header
      if (token != null) {
        print('Token: $token');
      } else {
        print('No token found');
      }
    //En response guardamos lo que recibimos como respuesta
    //Printeamos los datos recibidos

    data = response.data['user'];
    print('Data: $data');
    //Printeamos el status code recibido por el backend

    statusCode = response.statusCode;
    print('Status code: $statusCode');

    if (statusCode == 200) {
      // Si el usuario se crea correctamente, retornamos el código 200
      UserModel perfil = UserModel.fromJson(data);
      print(perfil);
      perfil.setToken(token);
      print('Perfil: ${perfil.username}, ${perfil.mail}, ${perfil.token}');
      perfilUsuario = perfil;

      print('200');
      print(perfilUsuario);
      return perfilUsuario;
    } else if (statusCode == 400) {
      // Si hay campos faltantes, retornamos el código 400
      print('400');

      return 400;
    } else if (statusCode == 500) {
      // Si hay un error interno del servidor, retornamos el código 500
      print('500');

      return 500;
    } else {
      // Otro caso no manejado
      print('-1');

      return -1;
    }
  }

  Future<List<UserModel>> getUsers() async {
    print('getUsers');
    try {
      var res = await dio.get('$baseUrl/api/user');
      List<dynamic> responseData =
          res.data; // Obtener los datos de la respuesta

      // Convertir los datos en una lista de objetos Place
      List<UserModel> users =
          responseData.map((data) => UserModel.fromJson(data)).toList();

      return users; // Devolver la lista de lugares
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la solicitud
      print('Error fetching data: $e');
      throw e; // Relanzar el error para que el llamador pueda manejarlo
    }
  }

  Future<UserModel?> findUser(String id, String? token) async {
  try {
    print('Empieza el findUser');
    dio.options.headers['auth-token'] = token;
    print('Le añadimos el tocken');
    var res = await dio.get('$baseUrl/api/user/findByUsername/$id');
    print('Ha llegado la respuesta');
    if (res.statusCode == 200) {
      print('Usuario no nullo');
      UserModel user = UserModel.fromJson(res.data);
      return user; 
    } if (res.statusCode == 201) {
      print('Usuario nullo');
      return null;
    }
    else {
      throw Exception('Failed to load user data');
    }
  } catch (e) {
    print('Error fetching data: $e');
    throw e; 
  }
}


  Future<int> EditUser(UserModel newUser, String id) async {
    print('createUser');
    print('try');
    //Aquí llamamos a la función request
    print('request');

    // Utilizar Dio para enviar la solicitud POST a http://127.0.0.1:3000/user
    Response response =
        await dio.put('$baseUrl/api/user/$id', data: newUser.toJson());
    //En response guardamos lo que recibimos como respuesta
    //Printeamos los datos recibidos

    data = response.data.toString();
    print('Data: $data');
    //Printeamos el status code recibido por el backend

    statusCode = response.statusCode;
    print('Status code: $statusCode');

    if (statusCode == 201) {
      // Si el usuario se crea correctamente, retornamos el código 201
      print('201');
      return 201;
    } else if (statusCode == 400) {
      // Si hay campos faltantes, retornamos el código 400
      print('400');

      return 400;
    } else if (statusCode == 500) {
      // Si hay un error interno del servidor, retornamos el código 500
      print('500');

      return 500;
    } else {
      // Otro caso no manejado
      print('-1');

      return -1;
    }
  }

  Future<int> deleteUser(String id) async {
    print('createUser');
    print('try');
    //Aquí llamamos a la función request
    print('request');

    // Utilizar Dio para enviar la solicitud POST a http://127.0.0.1:3000/user
    Response response =
        await dio.delete('$baseUrl/api/user/$id');
    //En response guardamos lo que recibimos como respuesta
    //Printeamos los datos recibidos

    data = response.data.toString();
    print('Data: $data');
    //Printeamos el status code recibido por el backend

    statusCode = response.statusCode;
    print('Status code: $statusCode');

    if (statusCode == 201) {
      // Si el usuario se crea correctamente, retornamos el código 201
      print('201');
      return 201;
    } else if (statusCode == 400) {
      // Si hay campos faltantes, retornamos el código 400
      print('400');

      return 400;
    } else if (statusCode == 500) {
      // Si hay un error interno del servidor, retornamos el código 500
      print('500');

      return 500;
    } else {
      // Otro caso no manejado
      print('-1');

      return -1;
    }
  }

Future<dynamic> logIn(logIn) async {
  print('LogIn');
  print('try');

  try {
    // Realiza la solicitud POST
    Response response =
        await dio.post('$baseUrl/api/user/logIn', data: logInToJson(logIn));

    // Extrae el token del encabezado
      token = response.headers['auth-token']?.first; // Accede al primer valor del header
      if (token != null) {
        print('Token: $token');
      } else {
        print('No token found');
      }

    // En response guardamos lo que recibimos como respuesta
    // Printeamos los datos recibidos
    data = response.data['user'];
    print('Data: $data');

    
    // Printeamos el status code recibido por el backend
    statusCode = response.statusCode;
    print('Status code: $statusCode');

    // Verifica si el estado es 200 (éxito)
    if (statusCode == 200) {
      print('200');

      // Convierte la respuesta en un modelo PerfilModel
      UserModel perfil = UserModel.fromJson(data);
      perfil.setToken(token);
      print('Perfil: ${perfil.username}, ${perfil.mail}, ${perfil.token}');
      perfilUsuario = perfil;

      return perfilUsuario;
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
    // Manejo de errores en caso de excepción
    print('Error: $e');
    return -1;
  }
}

Future<int> addSolicitud(String? myname, String? hisname) async {
  if (myname == null || myname.isEmpty || hisname == null || hisname.isEmpty) {
    throw ArgumentError('myname and hisname cannot be null or empty');
  }

  final encodedMyname = Uri.encodeComponent(myname);
  final encodedHisname = Uri.encodeComponent(hisname);
  final url = '$baseUrl/api/user/solicitud/$encodedHisname/$encodedMyname';

  try {
    print('Sending POST request to $url');
    var response = await dio.get(url);
    final statusCode = response.statusCode;

    print('Response status code: $statusCode');
    if (statusCode == 200) {
      return 200;
    } else if (statusCode == 400) {
      return 400;
    } else if (statusCode == 500) {
      return 500;
    } else {
      return -1;
    }
  } catch (e) {
    print('Error during HTTP request: $e');
    return -1;
  }
}

  
  Future<int> delSolicitud(String? myname, String? hisname) async {
    if (myname == null || myname.isEmpty || hisname == null || hisname.isEmpty) {
    throw ArgumentError('myname and hisname cannot be null or empty');
  }

  final encodedMyname = Uri.encodeComponent(myname);
  final encodedHisname = Uri.encodeComponent(hisname);
  final url = '$baseUrl/api/user/solicitud/$encodedMyname/$encodedHisname';

  try {
    print('Sending DELETE request to $url');
    var response = await dio.delete(url);
    final statusCode = response.statusCode;

    print('Response status code: $statusCode');
    if (statusCode == 200) {
      return 200;
    } else if (statusCode == 400) {
      return 400;
    } else if (statusCode == 500) {
      return 500;
    } else {
      return -1;
    }
  } catch (e) {
    print('Error during HTTP request: $e');
    return -1;
  }
}

Future<int> addFriend(String? myname, String? hisname) async {
    if (myname == null || myname.isEmpty || hisname == null || hisname.isEmpty) {
    throw ArgumentError('myname and hisname cannot be null or empty');
  }

  final encodedMyname = Uri.encodeComponent(myname);
  final encodedHisname = Uri.encodeComponent(hisname);
  final url = '$baseUrl/api/user/friend/$encodedMyname/$encodedHisname';

  try {
    print('Sending POST request to $url');
    var response = await dio.get(url);
    final statusCode = response.statusCode;

    print('Response status code: $statusCode');
    if (statusCode == 200) {
      return 200;
    } else if (statusCode == 400) {
      return 400;
    } else if (statusCode == 500) {
      return 500;
    } else {
      return -1;
    }
  } catch (e) {
    print('Error during HTTP request: $e');
    return -1;
  }
}

  Future<int> delFriend(String? myname, String? hisname) async {
    if (myname == null || myname.isEmpty || hisname == null || hisname.isEmpty) {
    throw ArgumentError('myname and hisname cannot be null or empty');
  }

  final encodedMyname = Uri.encodeComponent(myname);
  final encodedHisname = Uri.encodeComponent(hisname);
  final url = '$baseUrl/api/user/friend/$encodedMyname/$encodedHisname';

  try {
    print('Sending DELETE request to $url');
    var response = await dio.delete(url);
    final statusCode = response.statusCode;

    print('Response status code: $statusCode');
    if (statusCode == 200) {
      return 200;
    } else if (statusCode == 400) {
      return 400;
    } else if (statusCode == 500) {
      return 500;
    } else {
      return -1;
    }
  } catch (e) {
    print('Error during HTTP request: $e');
    return -1;
  }
  }

  Map<String, dynamic> logInToJson(logIn) {
    return {'username': logIn.username, 'password': logIn.password};
  }
}
