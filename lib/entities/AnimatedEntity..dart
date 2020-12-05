import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/spritesheet.dart';
import 'package:socketgame/views/BaseView.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

class AnimatedEntity extends BaseView {
  Animation animationRunningDown;
  Animation animationRunningLeft;
  Animation animationRunningUp;
  Animation animationRunningRight;
  Animation animationStandingDown;
  Animation animationStandingLeft;
  Animation animationStandingUp;
  Animation animationStandingRight;

  AnimationComponent _activeEntity;

  List<Map<String, dynamic>> _nextState;
  List<Map<String, dynamic>> _previousState;
  int _stateIndex = 0;

  String _animationPath;
  double gameTime;
  int _txtWidth, _txtHeight, _cols, _rows;
  double _velX, _velY;
  AnimatedEntity(this._animationPath, this._txtWidth, this._txtHeight,
      this._cols, this._rows, double x, double y, int dir) {
    Map<String, dynamic> initialState = {
      "x": x,
      "y": y,
      "dir": dir,
      "duration": DateTime.now().millisecondsSinceEpoch
    };
    _previousState = [initialState, initialState];
    _nextState = [initialState, initialState];
    _velX = _velY = 0;

    double stepSize = 0.1;
    SpriteSheet spriteSheet = SpriteSheet(
        imageName: _animationPath,
        textureWidth: _txtWidth,
        textureHeight: _txtHeight,
        columns: _cols,
        rows: _rows);
    animationRunningDown =
        spriteSheet.createAnimation(0, stepTime: stepSize * 1.5);
    animationRunningLeft =
        spriteSheet.createAnimation(1, stepTime: stepSize * 1.5);
    animationRunningRight =
        spriteSheet.createAnimation(2, stepTime: stepSize * 1.5);
    animationRunningUp =
        spriteSheet.createAnimation(3, stepTime: stepSize * 1.5);
    animationStandingDown =
        spriteSheet.createAnimation(4, stepTime: stepSize * 1.5);
    animationStandingLeft =
        spriteSheet.createAnimation(5, stepTime: stepSize * 1.5);
    animationStandingUp =
        spriteSheet.createAnimation(7, stepTime: stepSize * 1.5);
    animationStandingRight =
        spriteSheet.createAnimation(6, stepTime: stepSize * 1.5);
    _activeEntity = AnimationComponent(0, 0, animationStandingDown);
  }

  void render(Canvas canvas) {
    _activeEntity.x = _activeEntity.x + _velX;
    _activeEntity.y = _activeEntity.y + _velY;
    canvas.save();
    _activeEntity.render(canvas);
    canvas.restore();
  }

  void update(double t, double serverT) {
    double timeFactor = t / 0.05; //_nextState[1 - _stateIndex]["duration"];

    double dx = _nextState[1 - _stateIndex]["x"] - _activeEntity.x;
    double dy = _nextState[1 - _stateIndex]["y"] - _activeEntity.y;

    if (dx != 0) {
      _velX = dx * timeFactor / (dx.abs() + dy.abs()) * 10;
    }
    if (dx != 0) {
      _velY = dy * timeFactor / (dx.abs() + dy.abs()) * 10;
    }
    if (dx > 0 && _activeEntity.x + _velX > _nextState[1 - _stateIndex]["x"] ||
        dx < 0 && _activeEntity.x + _velX < _nextState[1 - _stateIndex]["x"]) {
      _velX = 0;
    }
    if (dy > 0 && _activeEntity.y + _velY > _nextState[1 - _stateIndex]["y"] ||
        dy < 0 && _activeEntity.y + _velY < _nextState[1 - _stateIndex]["y"]) {
      _velY = 0;
    }

    _activeEntity.animation.update(t);
  }

  void updateState(
      Map<String, dynamic> characterState, Map<String, dynamic> playerState) {
    int timeNow = DateTime.now().millisecondsSinceEpoch;

    _previousState[_stateIndex] = _nextState[_stateIndex];
    int nextDuration = timeNow - _nextState[_stateIndex]["duration"];
    double nextX = playerState["x"] -
        characterState["x"] +
        (screenSize.width - baseAnimationWidth()) / 2;
    double nextY = playerState["y"] -
        characterState["y"] +
        (screenSize.height - baseAnimationHeight()) / 2;
    int nextDirection = playerState["dir"];

    _nextState[_stateIndex]["x"] = nextX;
    _nextState[_stateIndex]["y"] = nextY;
    _nextState[_stateIndex]["dir"] = nextDirection;
    _nextState[_stateIndex]["duration"] = nextDuration;

    switch (nextDirection) {
      case 0:
        _activeEntity.animation = animationRunningLeft;
        break;
      case 1:
        _activeEntity.animation = animationRunningUp;
        break;
      case 2:
        _activeEntity.animation = animationRunningRight;
        break;
      case 3:
        _activeEntity.animation = animationRunningDown;
        break;
      case 4:
        _activeEntity.animation = animationStandingLeft;
        break;
      case 5:
        _activeEntity.animation = animationStandingUp;
        break;
      case 6:
        _activeEntity.animation = animationStandingRight;
        break;
      case 7:
        _activeEntity.animation = animationStandingDown;
        break;
      default:
    }

    _stateIndex = 1 - _stateIndex;
  }

  void resize() {
    _activeEntity.width = baseAnimationWidth();
    _activeEntity.height = baseAnimationHeight();

    _activeEntity.x = _nextState[_stateIndex]["x"];
    _activeEntity.y = _nextState[_stateIndex]["y"];
  }
}
