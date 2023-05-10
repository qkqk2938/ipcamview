import 'package:flutter/material.dart';
import './module/websocketStreaming.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class  MyApp extends StatelessWidget {
  const MyApp ({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(//실질적으로 감싸는 위젯.반드시 argument를 가져야함
      title: 'dapang app',//앱을 총칭하는 이름 
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
  bool _visibility = false;
  // final _ipTextEditController = TextEditingController(text: "ws://34.125.119.133");
  final _ipTextEditController = TextEditingController(text: "ws://sonorous-earth-377802.du.r.appspot.com");
  final _passwordTextEditController = TextEditingController(text: "mon_2938");

  @override
  void dispose(){
    _ipTextEditController.dispose();
    _passwordTextEditController.dispose();
    super.dispose();
  }

  connectWS2(){
    _webSocketStreaming.connect(_ipTextEditController.text, _passwordTextEditController.text);
    setState(() {
      _visibility = true;
    });
    _webSocketStreaming.startStreaming((data) {
              // 데이터 처리
      setState(() {
        _imageData = data;
      });
    });
    _webSocketStreaming.sendCommand("mecanum","off");
  }


void connectWS(){
  showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('비밀번호 입력'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('비밀번호를 입력하세요.!'),
              TextFormField(
                controller: _ipTextEditController,
                decoration: const InputDecoration(
                  labelText: 'IP',
                ),
              ),
              TextFormField(
                controller: _passwordTextEditController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('연결'),
            onPressed: () {
              Navigator.of(context).pop();
              connectWS2();
            },
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Center(
          child:
          JoystickArea(   
            mode: _joystickMode,
            initialJoystickAlignment: const Alignment(0, 0.8),
            listener: (details) {
              _webSocketStreaming.sendData(details.x, details.y);
            },          
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Visibility(
                   child: StatusWidget(),
                   visible: _visibility,
                )
                ,
                _imageData != null? Image.memory(
                  _imageData!,
                  gaplessPlayback: true,
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.of(context).size.width,
                ):CircularProgressIndicator(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  ElevatedButton(
                  onPressed: () {
                    
                    connectWS();
                  },
                  child: Text('Connect'),
                ),
                SizedBox(width: 10.0,),
                ElevatedButton(
                  onPressed: () {
                    _webSocketStreaming.close();
                  },
                  child: Text('Disconnect'),
                ),
                SizedBox(width: 10.0,),
                ElevatedButton(
                  onPressed: () {
                    _webSocketStreaming.sendCommand("capture","on");

                    //  if (_imageData != null) {
                    //   String encodedImage = base64Encode(_imageData!);
                    //   GallerySaver.saveImage(encodedImage);
                    // } else {
                    //   print("no image");
                    // }
                  },
                  child: Text('capture'),
                )
                ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('전방고정'),
                    Switch(
                      value: _value,
                      onChanged:(value){
                        setState((){
                          if(value){
                            _webSocketStreaming.sendCommand("mecanum","on");
                          }else{
                            _webSocketStreaming.sendCommand("mecanum","off");
                          }
                          _value = value;
                        });
                      },
                    ),
                  ]
                ),
              ],
            ),
          ),  
        );

  }
}


class StatusWidget extends StatefulWidget {
  @override
  _StatusWidgetState createState() => _StatusWidgetState();
}

class _StatusWidgetState extends State<StatusWidget> {
  late Timer _timer;
  // var url = Uri.parse('http://34.125.119.133/status');
  // var killMonUrl = Uri.parse('http://34.125.119.133/killmon');
  // var killCamUrl = Uri.parse('http://34.125.119.133/killcam');
  // var killDriveUrl = Uri.parse('http://34.125.119.133/killdrive');
  var url = Uri.parse('https://sonorous-earth-377802.du.r.appspot.com/status');
  var killMonUrl = Uri.parse('https://sonorous-earth-377802.du.r.appspot.com/killmon');
  var killCamUrl = Uri.parse('https://sonorous-earth-377802.du.r.appspot.com/killcam');
  var killDriveUrl = Uri.parse('https://sonorous-earth-377802.du.r.appspot.com/killdrive');
  var oldStatus = "";
  var monState = Colors.red;
  var ipcamState = Colors.red;
  var trainState = Colors.red;

  _StatusWidgetState(){
    _startTimer();

  }
  void _startTimer() {
    
    _timer = Timer.periodic(Duration(seconds: 1),(timer) async {
      var response = await http.get(url);
      var body = json.decode(response.body);
      if(oldStatus != response){
        oldStatus = response.body;
        setState(() {
          if(body["mon"]=="off"){
            monState = Colors.red;
          }else{
            monState = Colors.green;
          }
          if(body["ipcam"]=="off"){
            ipcamState = Colors.red;
          }else{
            ipcamState = Colors.green;
          }
          if(body["drivetrain"]=="off"){
            trainState = Colors.red;
          }else{
            trainState = Colors.green;
          }

        });

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return  ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: 
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RawMaterialButton(
              onPressed: () {
                http.get(killMonUrl);
              },
              elevation: 1.0,
              fillColor: monState,
              child: Icon(
                Icons.monitor,
                size: 15.0,
              ),
              shape: CircleBorder(),
            ),
            RawMaterialButton(
              onPressed: () {
                http.get(killCamUrl);
              },
              elevation: 1.0,
              fillColor: ipcamState,
              child: Icon(
                Icons.videocam,
                size: 15.0,
              ),
              shape: CircleBorder(),
            ),
            RawMaterialButton(
              onPressed: () {
                http.get(killDriveUrl);
              },
              elevation: 1.0,
              fillColor: trainState,
              child: Icon(
                Icons.drive_eta,
                size: 15.0,
              ),
              shape: CircleBorder(),
            ),
          ]
        ),
    );
  }

}

//monitor
//drive eta