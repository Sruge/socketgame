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
import 'package:socketgame/entities/Character.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

MMOGame mmoGame = MMOGame();

class MMOGame extends Game with TapDetector {
  Function _fn;
  int _playerId;
  Map playerData;
  Playground playground;
  Socket socket;
  StringBuffer _buffer;
  StreamSubscription _sub;
  bool parsingPlayer = false;
  String nextUpdateState;
  int nextUpdateTime;
  double _sendTimer = 0;

  MMOGame() {
    _fn = _init;
  }

  Future<void> _init(double t) async {
    playground = Playground();
    playground.players = [];
    playground.gametime = 0;
    _fn = _update;
    _buffer = StringBuffer("");
    nextUpdateTime = DateTime.now().millisecondsSinceEpoch;

    Util flameUtils = Util();
    await flameUtils.fullScreen();
    await flameUtils.setOrientation(DeviceOrientation.landscapeLeft);

    socket = await Socket.connect('217.182.216.146', 5555);
    print('connected');
    _sub = socket.listen((List<int> event) {});
    // listen to the received data event stream

    _sub.onData((data) {
      onSocketEvent(utf8.decode(data));
    });
    socket.add(utf8.encode("Gerus"));

    _sub.onDone(() async {
      while (true) {
        //socket = await Socket.connect('217.182.216.146', 5555);
        await Future.delayed(Duration(seconds: 3));
        //_sub = socket.listen((List<int> event) {});
      }
    });

    void handleError(error) {
      print(error);
    }

    _sub.onError(handleError);
  }

  void onTapDown(TapDownDetails details) {
    playground.onTapDown(details);
  }

  void _update(double t) {
    _sendTimer += t;
    playground.update(t);
  }

  void render(Canvas canvas) {
    playground.render(canvas);
  }

  void update(double t) {
    _fn(t);
  }

  void resize(Size size) {
    screenSize = size;
    playground.resize();
  }

  void lifecycleStateChange(AppLifecycleState state) {
    if (AppLifecycleState.detached == state) {
      _sub.cancel();
      socket.close();
    } else if (AppLifecycleState.paused == state) {
      _sub.pause();
    } else if (AppLifecycleState.resumed == state) {
      _sub.resume();
    } else if (AppLifecycleState.inactive == state) {
      _sub.pause();
    }
  }

  void onSocketEvent(String event) {
    for (int i = 0; i < event.length; i++) {
      if (event[i] == "#") {
        _buffer.clear();
        parsingPlayer = true;
      } else {
        if (event[i] == ";") {
          if (parsingPlayer) {
            String updateString = _buffer.toString();
            _buffer.clear();
            playground.init(updateString);
            parsingPlayer = false;
          } else {
            String updateString = _buffer.toString();
            _buffer.clear();
            if (playground.isInitialized()) {
              //while (DateTime.now().millisecondsSinceEpoch < nextUpdateTime) {}
              nextUpdateState = updateString;
              playground.updateState(nextUpdateState);
              nextUpdateTime = DateTime.now().millisecondsSinceEpoch + 50;
            }
          }
        } else {
          _buffer.write(event[i]);
        }
      }
    }
  }

  void addToSocket(String mode, double x, double y) {
    if (_sendTimer > 0.4) {
      Map<String, dynamic> destination = {
        "mode": mode,
        "x": x,
        "y": y,
      };
      socket.add(utf8.encode(jsonEncode(destination)));
      _sendTimer = 0;
    }
  }
}
