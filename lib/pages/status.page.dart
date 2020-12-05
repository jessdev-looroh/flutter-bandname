import 'package:band_names/services/socket.servie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    ServerStatus status = socketService.serverStatus;
    bool online = status == ServerStatus.Online ? true : false;
    bool connecting = status == ServerStatus.Connecting ? true : false;

    TextStyle style = TextStyle(color: online ? Colors.green : Colors.red);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Enviamos mensaje al servidor");
          socketService.socket.emit(
            'enviarMensaje',
            {"nombre": "flutter", "mensaje": "Hola desde flutter"},
          );
        },
        child: Icon(Icons.message),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Estado del servidor:'),
            SizedBox(
              height: 20,
            ),
            connecting
                ? Column(
                    children: [
                      CircularProgressIndicator(
                        // backgroundColor: Colors.amber,
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text("Reconectando con el servidor...")
                    ],
                  )
                : Text(
                    online ? 'ONLINE' : 'OFFLINE',
                    style: style,
                  )
          ],
        ),
      ),
    );
  }
}
