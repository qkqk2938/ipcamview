import 'dart:typed_data';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class WebSocketStreaming {
  IOWebSocketChannel? _channel;

  void connect(String url, String protocol) {
    _channel = IOWebSocketChannel.connect(Uri.parse(url), protocols: [protocol]);
  }

  void startStreaming(Function(Uint8List data) onDataReceived) {
    _channel?.stream.listen((data) {
      onDataReceived(data);
    });
  }

  void sendData(double x, double y){
    final data = [x,y];
    final message = json.encode({"command": "axis","data": data});
    _channel?.sink.add(message);
  }

  void sendCommand(String command, String data){
    final message = json.encode({"command": command, "data": data});
    _channel?.sink.add(message);
  }

  void close() {
    _channel?.sink.close();
  }
}
