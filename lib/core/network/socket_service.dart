import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../constants/api_constants.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService(ref);
});

class SocketService {
  late IO.Socket _socket;
  final Ref _ref;

  SocketService(this._ref) {
    _socket = IO.io(ApiConstants.socketUrl, 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build()
    );

    _socket.onConnect((_) {
      // Connection established
    });

    _socket.onDisconnect((_) {
      // Disconnected
    });

    _socket.on('notification.new', (data) {
      // Handle notification
    });
  }

  void disconnect() {
    _socket.disconnect();
  }

  IO.Socket? get socket => _socket;
}
