import 'package:flutter/material.dart';
import './module/websocketStreaming.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'dart:typed_data';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class  MyApp extends StatelessWidget {
  const MyApp ({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(//실질적으로 감싸는 위젯.반드시 argument를 가져야함
      title: 'first app',//앱을 총칭하는 이름 
      theme: ThemeData(
        primarySwatch: Colors.blue //특정색의 음영을 사용
      ),
      home: MyHomePage(),//가장먼저 화면에 보이는 경로,커스텀위젯이므로 만들어야한다
    );
  }
}

class  MyHomePage extends StatelessWidget {
  const MyHomePage ({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(//앱화면의 빈 도화지 위젯
        appBar: AppBar(
          //제목
          title:Text('다빵'),
          
        ),  
        body: MainWidget(),
    );
  }
}

class MainWidget extends StatefulWidget {
  @override
  _MainWidgetState createState() => _MainWidgetState();
}


class _MainWidgetState extends State<MainWidget> {
  
  final WebSocketStreaming _webSocketStreaming = WebSocketStreaming();
  Uint8List? _imageData;
  double _x = 0;
  double _y = 0;
  JoystickMode _joystickMode = JoystickMode.all;
  bool _value = false;
  @override
  Widget build(BuildContext context) {
    return Center(
          child:
          JoystickArea(   
            mode: _joystickMode,
            initialJoystickAlignment: const Alignment(0, 0.8),
            listener: (details) {
              _webSocketStreaming.send(details.x, details.y);
            },          
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _imageData != null? Image.memory(
                  _imageData!,
                  gaplessPlayback: true,
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.of(context).size.width,
                ):CircularProgressIndicator(),
                ElevatedButton(
                  onPressed: () {
                    _webSocketStreaming.connect('ws://34.125.119.133', 'mon_2938');
                    _webSocketStreaming.startStreaming((data) {
                      // 데이터 처리
                      setState(() {
                        _imageData = data;
                      });
                    });
                  },
                  child: Text('Connect'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _webSocketStreaming.close();
                  },
                  child: Text('Disconnect'),
                ),
                Switch(
                  value: _value,
                  onChanged:(value){
                    setState((){
                      _value = value;
                    });
                  },
                ),
              ],
            ),
          ),  
        );

  }
}
