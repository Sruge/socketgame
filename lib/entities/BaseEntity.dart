import 'dart:math';
import 'dart:ui';
import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

import 'Entity.dart';

class BaseEntity extends Entity {
  PositionComponent activeEntity;

  List<Map<String, dynamic>> _nextState;
  List<Map<String, dynamic>> _previousState;
  Map<String, dynamic> initialState;
  int _stateIndex = 0;
  double _width, _height;

  String _imgUrl;
  double gameTime;
  double _velX, _velY;
  BaseEntity(this._imgUrl, this._width, this._height) {
    _velX = _velY = 0;

    activeEntity = SpriteComponent.fromSprite(_width, _height, Sprite(_imgUrl));
  }

  void render(Canvas canvas) {
    canvas.save();
    activeEntity.render(canvas);
    canvas.restore();
  }

  void update(double t, double serverT) {
    double timeFactor = t / _nextState[1 - _stateIndex]["duration"];

    double dx = _previousState[1 - _stateIndex]["x"] - activeEntity.x;
    double dy = _previousState[1 - _stateIndex]["y"] - activeEntity.y;

    if (dx != 0) {
      _velX = dx *
          timeFactor /
          (dx.abs() + dy.abs()) *
          400 *
          screenSize.width /
          20000;
    }
    if (dx != 0) {
      _velY = dy *
          timeFactor /
          (dx.abs() + dy.abs()) *
          400 *
          screenSize.height /
          10000;
    }
    if (dx > 0 && activeEntity.x + _velX > _nextState[1 - _stateIndex]["x"] ||
        dx < 0 && activeEntity.x + _velX < _nextState[1 - _stateIndex]["x"]) {
      _velX = 0;
    }
    if (dy > 0 && activeEntity.y + _velY > _nextState[1 - _stateIndex]["y"] ||
        dy < 0 && activeEntity.y + _velY < _nextState[1 - _stateIndex]["y"]) {
      _velY = 0;
    }

    activeEntity.x = activeEntity.x + _velX;
    activeEntity.y = activeEntity.y + _velY;
  }

  void updateState(Map<String, dynamic> characterState,
      Map<String, dynamic> objectState, double gametime) {
    _previousState[_stateIndex] = _nextState[_stateIndex];
    double nextX =
        scaledScreenSizeWidth * (objectState["x"] - characterState["x"]) +
            charOffsetX;
    double nextY =
        scaledScreenSizeHeight * (objectState["y"] - characterState["y"]) +
            charOffsetY;

    _nextState[_stateIndex]["x"] = nextX;
    _nextState[_stateIndex]["y"] = nextY;
    _nextState[_stateIndex]["duration"] = gametime;

    _stateIndex = 1 - _stateIndex;
  }

  void resize() {
    _previousState = [initialState, initialState];
    _nextState = [initialState, initialState];

    activeEntity.x = _nextState[_stateIndex]["x"];
    activeEntity.y = _nextState[_stateIndex]["y"];
  }
}
