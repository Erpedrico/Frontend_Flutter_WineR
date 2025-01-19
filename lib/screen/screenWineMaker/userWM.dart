import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../models/userModel.dart';
import '../../services/userService.dart';
import '../../providers/perfilProvider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/userCard.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  List<UserModel> _friendsList = [];
  List<UserModel> _solicitudesList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _loadSolicitudes();
  }

  void _loadFriends() async {
    UserModel? currentUser = Provider.of<PerfilProvider>(context, listen: false).getUser();

    if (currentUser != null && currentUser.amigos!.isNotEmpty) {
      List<UserModel> loadedFriends = [];
      for (String amigo in currentUser.amigos!) {
        UserModel? user = await _userService.findUser(amigo, currentUser.token);
        if (user != null) {
          loadedFriends.add(user);
        }
      }

      setState(() {
        _friendsList = loadedFriends;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadSolicitudes() async {
    UserModel? currentUser = Provider.of<PerfilProvider>(context, listen: false).getUser();

    if (currentUser != null && currentUser.solicitudes!.isNotEmpty) {
      List<UserModel> loadedSolicitudes = [];
      for (String solicitud in currentUser.solicitudes!) {
        UserModel? user = await _userService.findUser(solicitud, currentUser.token);
        if (user != null) {
          loadedSolicitudes.add(user);
        }
      }

      setState(() {
        _solicitudesList = loadedSolicitudes;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void buscarUsuario(String nombre) async {
    UserModel? currentUser = Provider.of<PerfilProvider>(context, listen: false).getUser();
    if (currentUser != null) {
      UserModel? user = await _userService.findUser(nombre, currentUser.token);
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Usuario no encontrado")),
        );
      } else {
        Provider.of<PerfilProvider>(context, listen: false).setExternalUser(user);
        Get.offNamed('/perfilExternalUsuario');
      }
    }
  }

  void addFriend(String? username) async {
    UserModel? currentUser = Provider.of<PerfilProvider>(context, listen: false).getUser();
    int response = await _userService.addFriend(currentUser?.username, username);
    int response2 = await _userService.delSolicitud(currentUser?.username, username);

    if (response == 200 && response2 == 200) {
      _loadFriends();
      _loadSolicitudes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuario añadido como amigo")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuario no añadido como amigo")),
      );
    }
  }

  void noaddFriend(String? username) async {
    UserModel? currentUser = Provider.of<PerfilProvider>(context, listen: false).getUser();
    int response = await _userService.delSolicitud(currentUser?.username, username);

    if (response == 200) {
      _loadFriends();
      _loadSolicitudes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Solicitud de amistad eliminada")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar solicitud")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        title: Text(
          'Amigos',
          style: TextStyle(
            fontSize: settings.fontSize + 4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.group, color: Colors.white),
            tooltip: 'Todos los chats',
            onPressed: () {
              Get.offNamed('/roomPage');
            },
          ),
        ],
      ),
      backgroundColor: settings.backgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Añadir usuario',
                      hintText: 'Introduce un nombre',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    style: TextStyle(fontSize: settings.fontSize),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        buscarUsuario(value);
                      }
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.red.shade700),
                  onPressed: () {
                    final value = _searchController.text;
                    if (value.isNotEmpty) {
                      buscarUsuario(value);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.red.shade700))
                : _solicitudesList.isEmpty
                    ? Center(
                        child: Text(
                          'No hay solicitudes de amistad',
                          style: TextStyle(fontSize: settings.fontSize),
                        ),
                      )
                    : ExpansionTile(
                        title: Text(
                          'Mostrar solicitudes de amistad (${_solicitudesList.length})',
                          style: TextStyle(fontSize: settings.fontSize, fontWeight: FontWeight.w600),
                        ),
                        children: _solicitudesList.map((user) {
                          return ListTile(
                            title: Text(user.username ?? 'Usuario desconocido',
                                style: TextStyle(fontSize: settings.fontSize)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check, color: Colors.green),
                                  onPressed: () => addFriend(user.username),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () => noaddFriend(user.username),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
          ),
          Expanded(
            child: _friendsList.isEmpty
                ? Center(
                    child: Text(
                      'No hay amigos para mostrar',
                      style: TextStyle(fontSize: settings.fontSize),
                    ),
                  )
                : ListView.builder(
                    itemCount: _friendsList.length,
                    itemBuilder: (context, index) {
                      return UserCard(user: _friendsList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}