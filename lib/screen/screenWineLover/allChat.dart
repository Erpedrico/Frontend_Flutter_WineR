import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../models/userModel.dart'; 
import '../../providers/perfilProvider.dart'; 
import 'package:provider/provider.dart'; 

class chatPage2 extends StatefulWidget {
  @override
  _chatPageState createState() => _chatPageState();
}

class _chatPageState extends State<chatPage2> {
  late IO.Socket socket;
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = []; // Lista para almacenar los mensajes

  @override
  void initState() {
    super.initState();

    /* Conectarse al servidor WebSocket
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });*/

    socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Manejo de eventos
    socket.on('connect', (_) {
      print('Connected to server');
    });

    UserModel? currentUser = Provider.of<PerfilProvider>(context, listen: false).getUser();
    String? room = Provider.of<PerfilProvider>(context, listen: false).getRoomChat();
    socket.emit('joinRoom',room);

    socket.on('previousMessages', (data) {
      if (!mounted) return;
      setState(() {
      for (var item in data) {
        String username = item['username']?.toString() ?? 'Usuario desconocido';
        String content = item['content']?.toString() ?? 'Mensaje vacío';
        String premessage = username + content;
        _messages.add(premessage);
      }
      });
    });

    socket.on('message-receive', (data) {
      if (!mounted) return;
        setState(() {
        _messages.add(data['content'].toString());
      // Agregar el mensaje recibido a la lista
      });
    });

    socket.connect(); // Conectar el socket
  }

  @override
  void dispose() {
    socket.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    UserModel? currentUser = Provider.of<PerfilProvider>(context, listen: false).getUser();
    String? objectiveUser = Provider.of<PerfilProvider>(context, listen: false).getUsernameChat();
    //String? myname = currentUser?.username;
    List<String?> nombres = [currentUser?.username, objectiveUser];
    nombres.sort();
    String roomName = "${nombres[0]}_${nombres[1]}";
    print(roomName);

    final message = _messageController.text.trim();
    //final messageUser = "$myname:$message"; 
    if (message.isNotEmpty) {
      socket.emit('sendMessage', {'roomName': roomName, 'username':currentUser?.username, 'content': message});
      _messageController.clear(); // Limpiar el campo de texto
    }
  }

  void goBack() {
    Get.offNamed('/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: goBack
      ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

