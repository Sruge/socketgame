import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flame/game/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/util.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:socketgame/Playground.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

MMOGame myGame = MMOGame();

class MMOGame extends Game with TapDetector {
  Function _fn;
  int _playerId;
  Map playerData;
  Playground state;
  Socket socket;
  StringBuffer _buffer;

  MMOGame() {
    _fn = _init;
  }

  void onPauseHandler() {
    print('on Pause');
  }

  Future<void> _init(double t) async {
    state = Playground();
    state.players = [];
    state.gametime = 0;
    _fn = _update;
    _buffer = StringBuffer("");

    Util flameUtils = Util();
    await flameUtils.fullScreen();
    await flameUtils.setOrientation(DeviceOrientation.landscapeLeft);

    socket = await Socket.connect('217.182.216.146', 5555);
    print('connected');

    // listen to the received data event stream
    socket.listen((List<int> event) {
      onSocketEvent(utf8.decode(event));
    });

    // send hello
    socket.add(utf8.encode('gerus'));

    // wait 5 seconds
    //await Future.delayed(Duration(seconds: 1));

    // .. and close the socket
    //socket.close();
  }

  void onTapDown(TapDownDetails details) {
    double x = (details.globalPosition.dx - screenSize.width / 2);
    double y = (details.globalPosition.dy - screenSize.height / 2);
    Map<String, dynamic> destination = {
      "x": x,
      "y": y,
    };
    socket.add(utf8.encode(jsonEncode(destination)));
  }

  void _update(double t) {
    state.update(t);
  }

  void render(Canvas canvas) {
    state.render(canvas);
  }

  void update(double t) {
    _fn(t);
  }

  void resize(Size size) {
    screenSize = size;
    state.resize();
  }

  void onSocketEvent(String event) {
    for (int i = 0; i < event.length; i++) {
      if (event[i] == "#") {
        _playerId = int.parse(
            event[i + 1] + event[i + 2] + event[i + 3] + event[i + 4]);
        i += 4;
      } else if (event[i] == ";") {
        String updateString = _buffer.toString();
        _buffer.clear();
        state.updateState(updateString, _playerId);
      } else {
        _buffer.write(event[i]);
      }
    }
  }
}
