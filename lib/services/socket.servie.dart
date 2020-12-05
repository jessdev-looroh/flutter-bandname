import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;
  SocketService() {
    this._initConfig();
  }

  set serverStatus(ServerStatus status) {
    this._serverStatus = status;
    notifyListeners();
  }

  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;

  void _initConfig() {
    this._socket = IO.io(
      'http://192.168.8.121:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );
    this._socket.onConnect((_) {
      print('connect');
      serverStatus = ServerStatus.Online;
      this._socket.emit('enviarMensaje', 'test');
    });
    this
        ._socket
        .onReconnecting((data) => serverStatus = ServerStatus.Connecting);

    this._socket.onDisconnect(
          (_) => {
            serverStatus = ServerStatus.Offline,
            print('disconnect'),
          },
        );

    // socket.on('enviarMensaje', (data) => print(data));
  }
}
