import 'dart:math';
import 'dart:ui';
import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

class BaseEntity {
  PositionComponent _activeEntity;

  List<Map<String, dynamic>> _nextState;
  List<Map<String, dynamic>> _previousState;
  Map<String, dynamic> initialState;
  int _stateIndex = 0;
  double _width, _height;

  String _imgUrl;
  double gameTime;
  double _velX, _velY;
  BaseEntity(this._imgUrl, this._width, this._height, double x, double y) {
    _velX = _velY = 0;

    _activeEntity =
        SpriteComponent.fromSprite(_width, _height, Sprite(_imgUrl));
  }

  void render(Canvas canvas, bool upperHalf) {
    canvas.save();
    _activeEntity.render(canvas);
    canvas.restore();
  }

  void update(double t, double serverT) {
    double timeFactor = t / 0.05; //_nextState[1 - _stateIndex]["duration"];

    double dx = _nextState[1 - _stateIndex]["x"] - _activeEntity.x;
    double dy = _nextState[1 - _stateIndex]["y"] - _activeEntity.y;

    if (dx != 0) {
      _velX = dx *
          timeFactor /
          (dx.abs() + dy.abs()) *
          500 *
          screenSize.width /
          20000;
    }
    if (dx != 0) {
      _velY = dy *
          timeFactor /
          (dx.abs() + dy.abs()) *
          250 *
          screenSize.height /
          10000;
    }
    if (dx > 0 && _activeEntity.x + _velX > _nextState[1 - _stateIndex]["x"] ||
        dx < 0 && _activeEntity.x + _velX < _nextState[1 - _stateIndex]["x"]) {
      _velX = 0;
    }
    if (dy > 0 && _activeEntity.y + _velY > _nextState[1 - _stateIndex]["y"] ||
        dy < 0 && _activeEntity.y + _velY < _nextState[1 - _stateIndex]["y"]) {
      _velY = 0;
    }

    _activeEntity.x = _activeEntity.x + _velX;
    _activeEntity.y = _activeEntity.y + _velY;
  }

  void updateState(
      Map<String, dynamic> characterState, Map<String, dynamic> objectState) {
    int timeNow = DateTime.now().millisecondsSinceEpoch;

    _previousState[_stateIndex] = _nextState[_stateIndex];
    int nextDuration = timeNow - _nextState[_stateIndex]["duration"];
    double nextX = (screenSize.width / 20000) * objectState["x"] -
        (screenSize.width / 20000) * characterState["x"] +
        (screenSize.width - _width) / 2;
    double nextY = (screenSize.height / 10000) * objectState["y"] -
        (screenSize.height / 10000) * characterState["y"] +
        (screenSize.height - _height) / 2;

    _nextState[_stateIndex]["x"] = nextX;
    _nextState[_stateIndex]["y"] = nextY;
    _nextState[_stateIndex]["duration"] = nextDuration;

    _stateIndex = 1 - _stateIndex;
  }

  void resize() {
    _previousState = [initialState, initialState];
    _nextState = [initialState, initialState];

    _activeEntity.x = _nextState[_stateIndex]["x"];
    _activeEntity.y = _nextState[_stateIndex]["y"];
  }
}
