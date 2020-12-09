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

  MMOGame() {
    _fn = _init;
  }

  void onPauseHandler() {
    print('on Pause');
  }

  Future<void> _init(double t) async {
    playground = Playground();
    playground.players = [];
    playground.gametime = 0;
    _fn = _update;
    _buffer = StringBuffer("");

    Util flameUtils = Util();
    await flameUtils.fullScreen();
    await flameUtils.setOrientation(DeviceOrientation.landscapeLeft);

    socket = await Socket.connect('217.182.216.146', 5555);
    print('connected');
    socket.add(utf8.encode("Gerus"));
    // listen to the received data event stream
    _sub = socket.listen((List<int> event) {});

    _sub.onData((data) {
      onSocketEvent(utf8.decode(data));
    });

    _sub.onDone(() async {
      while (true) {
        socket = await Socket.connect('217.182.216.146', 5555);
        await Future.delayed(Duration(seconds: 3));
        _sub = socket.listen((List<int> event) {});
      }
    });

    void handleError(error) {
      print(error);
    }

    _sub.onError(handleError);

    // send hello

    // wait 5 seconds
    //await Future.delayed(Duration(seconds: 1));

    // .. and close the socket
    //socket.close();
  }

  void onTapDown(TapDownDetails details) {
    // double x = (details.globalPosition.dx - screenSize.width / 2) /
    //     (screenSize.width / 2);
    // double y = (details.globalPosition.dy - screenSize.height / 2) /
    //     (screenSize.height / 2);
    playground.onTapDown(details);
  }

  void _update(double t) {
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
    } else if (AppLifecycleState.paused == state) {
      _sub.cancel();
    } else if (AppLifecycleState.resumed == state) {
      _sub.resume();
    } else if (AppLifecycleState.inactive == state) {
      _sub.cancel();
    }
  }

  void onSocketEvent(String event) {
    bool parsingPlayer = false;
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
              playground.updateState(updateString);
            }
          }
        } else {
          _buffer.write(event[i]);
        }
      }
    }
  }

  void addToSocket(String mode, double x, double y) {
    Map<String, dynamic> destination = {
      "mode": mode,
      "x": x,
      "y": y,
    };
    socket.add(utf8.encode(jsonEncode(destination)));
  }
}
