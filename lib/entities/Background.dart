import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:socketgame/entities/Thing.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

import 'Door.dart';
import 'Entity.dart';

class Background extends Entity {
  static double stepSize;
  PositionComponent activeEntity;
  List<List<double>> _nextState;
  List<List<double>> _previousState;

  List<Thing> things;
  List<Door> doors;
  int _stateIndex = 0;
  int _updateTime;
  double _move = 0;

  Background(_nextWorld, _nextCharState) {
    double initialX = _nextWorld["x"] -
        (_nextCharState["x"].toDouble() * scaledScreenSizeWidth) +
        charOffsetX;
    double initialY = _nextWorld["x"] -
        (_nextCharState["y"].toDouble() * scaledScreenSizeHeight) +
        charOffsetY;
    _updateTime = 0;
    List<double> initialState = [initialX, initialY, _updateTime.toDouble()];
    _previousState = [initialState, initialState];
    _nextState = [initialState, initialState];
    activeEntity =
        SpriteComponent.fromSprite(0, 0, Sprite("${_nextWorld["bg"]}.png"));
    things = [];
    doors = [];
    for (var thingJson in _nextWorld["things"]) {
      Thing thingToAdd = Thing.fromJson(thingJson);
      thingToAdd.initialState = {
        "x": (thingJson["x"] - _nextCharState["x"]) * scaledScreenSizeWidth +
            charOffsetX,
        "y": (thingJson["y"] - _nextCharState["y"]) * scaledScreenSizeHeight +
            charOffsetY,
        "duration": DateTime.now().millisecondsSinceEpoch
      };
      thingToAdd.resize();
      things.add(thingToAdd);
    }
    for (var doorJson in _nextWorld["doors"]) {
      Door doorToAdd = Door.fromJson(doorJson);
      doorToAdd.initialState = {
        "x": (doorJson["x"] - _nextCharState["x"]) * scaledScreenSizeWidth +
            charOffsetX,
        "y": (doorJson["y"] - _nextCharState["y"]) * scaledScreenSizeHeight +
            charOffsetY,
        "duration": DateTime.now().millisecondsSinceEpoch
      };
      doorToAdd.resize();
      doors.add(doorToAdd);
    }
  }

  //this and most other render functions get called twice, once for the upper
  //and once for the lower half of the screen, so that things are rendered
  //behind or in front of the player, wherever they want to be
  //the bg is of course only rendered once with and before the upper half things
  void render(Canvas canvas) {
    canvas.save();
    activeEntity.render(canvas);
    canvas.restore();
  }

  void update(double t, double serverT) {
    double timeFactor = t / _previousState[1 - _stateIndex][2];

    double dx = _previousState[1 - _stateIndex][0] - activeEntity.x;
    double dy = _previousState[1 - _stateIndex][1] - activeEntity.y;
    double velX = 0;
    double velY = 0;
    if (dx != 0) {
      velX =
          dx * timeFactor / (dx.abs() + dy.abs()) * scaledScreenSizeWidth * 245;
    }
    if (dy != 0) {
      velY = dy *
          timeFactor /
          (dx.abs() + dy.abs()) *
          scaledScreenSizeHeight *
          245;
    }

    //If moving the object according to its velocity would
    //overshoot the destination we set the object to the destination instead
    //of moving it
    if ((dx < 0 && activeEntity.x + velX <= _nextState[1 - _stateIndex][0] ||
            dx > 0 &&
                activeEntity.x + velX >= _nextState[1 - _stateIndex][0]) ||
        ((dy > 0 && activeEntity.y + velY >= _nextState[1 - _stateIndex][1] ||
            dy < 0 &&
                activeEntity.y + velY <= _nextState[1 - _stateIndex][1]))) {
      velX = 0;
      velY = 0;
    }

    activeEntity.x = activeEntity.x + velX;
    activeEntity.y = activeEntity.y + velY;

    for (Thing thing in things) {
      thing.updatePosition(velX, velY);
    }
    for (Door door in doors) {
      door.updatePosition(velX, velY);
    }
  }

  void updateState(Map<String, dynamic> characterState, double gametime) {
    _previousState[_stateIndex] = _nextState[_stateIndex];
    double nextX = charOffsetX - scaledScreenSizeWidth * characterState["x"];
    double nextY = charOffsetY - scaledScreenSizeHeight * characterState["y"];

    _nextState[_stateIndex][0] = nextX;
    _nextState[_stateIndex][1] = nextY;
    _nextState[_stateIndex][2] = gametime;

    _stateIndex = 1 - _stateIndex;
  }

  void resize() {
    activeEntity.x = _nextState[1 - _stateIndex][0];
    activeEntity.y = _nextState[1 - _stateIndex][1];
    activeEntity.width = screenSize.width * 3;
    activeEntity.height = screenSize.height * 3;
  }
}
