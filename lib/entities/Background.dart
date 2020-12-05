import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:socketgame/views/BaseView.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

class Background extends BaseView {
  static double stepSize;
  PositionComponent _entity;
  String _imgPath;
  List<List<double>> _nextState;
  List<List<double>> _previousState;
  int _stateIndex = 0;
  int _updateTime;

  Background(this._imgPath, double x, double y) {
    double initialX = -x;
    double initialY = -y;
    _updateTime = 0;
    List<double> initialState = [initialX, initialY, _updateTime.toDouble()];
    _nextState = [initialState, initialState];
    _previousState = [initialState, initialState];
    _entity = SpriteComponent.fromSprite(0, 0, Sprite(_imgPath));
  }

  void render(Canvas canvas) {
    canvas.save();
    _entity.render(canvas);
    canvas.restore();
  }

  void update(double t, double serverT) {
    double timeFactor = t / 0.05; //_nextState[1 - _stateIndex][2];

    double dx = _nextState[1 - _stateIndex][0] - _entity.x;
    double dy = _nextState[1 - _stateIndex][1] - _entity.y;
    double velX = 0;
    double velY = 0;
    if (dx != 0) {
      velX = dx * timeFactor / (dx.abs() + dy.abs()) * 10;
    }
    if (dy != 0) {
      velY = dy * timeFactor / (dx.abs() + dy.abs()) * 10;
    }
    if (dx > 0 && _entity.x + velX > _nextState[1 - _stateIndex][0] ||
        dx < 0 && _entity.x + velX < _nextState[1 - _stateIndex][0]) {
      velX = 0;
    }
    if (dy > 0 && _entity.y + velY > _nextState[1 - _stateIndex][1] ||
        dy < 0 && _entity.y + velY < _nextState[1 - _stateIndex][1]) {
      velY = 0;
    }

    _entity.x = _entity.x + velX;
    _entity.y = _entity.y + velY;
  }

  void updateState(Map<String, dynamic> characterState) {
    int timeNow = DateTime.now().millisecondsSinceEpoch;
    double duration = (timeNow - _updateTime) / 1000;
    _updateTime = timeNow;

    _previousState[_stateIndex] = _nextState[_stateIndex];
    double nextDuration = duration.toDouble();
    double nextX = -characterState["x"];
    double nextY = -characterState["y"];

    _nextState[_stateIndex][0] = nextX;
    _nextState[_stateIndex][1] = nextY;
    _nextState[_stateIndex][2] = nextDuration;

    _stateIndex = 1 - _stateIndex;
  }

  void resize() {
    _entity.x = _nextState[1 - _stateIndex][0];
    _entity.y = _nextState[1 - _stateIndex][1];
    _entity.width = baseBgWidth;
    _entity.height = baseBgHeight;
  }
}
