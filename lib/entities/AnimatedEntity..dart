import 'dart:math';
import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/spritesheet.dart';
import 'package:socketgame/entities/healthbars/EnemyHealthbar.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

import 'Entity.dart';

class AnimatedEntity extends Entity {
  Animation animationRunningDown;
  Animation animationRunningLeft;
  Animation animationRunningUp;
  Animation animationRunningRight;
  Animation animationStandingDown;
  Animation animationStandingLeft;
  Animation animationStandingUp;
  Animation animationStandingRight;

  AnimationComponent animatedEntity;

  List<Map<String, dynamic>> _nextState;
  List<Map<String, dynamic>> _previousState;
  Map<String, dynamic> initialState;
  EnemyHealthbar _healthbar;
  int health, maxHealth;
  int _stateIndex = 0;
  Random _random;

  String _animationPath;
  double gameTime;
  int _txtWidth, _txtHeight, _cols, _rows;
  double _velX, _velY;
  AnimatedEntity(this._animationPath, this._txtWidth, this._txtHeight,
      this._cols, this._rows, double x, double y, int dir) {
    _velX = _velY = 0;

    _random = Random();
    double stepSize = 0.1;
    // they all whip up and down equally which is not nice
    double _randomStandingStepSize = 1.6 + _random.nextDouble() / 2;
    SpriteSheet spriteSheet = SpriteSheet(
        imageName: _animationPath,
        textureWidth: _txtWidth,
        textureHeight: _txtHeight,
        columns: _cols,
        rows: _rows);
    animationRunningDown = spriteSheet.createAnimation(0, stepTime: stepSize);
    animationRunningLeft = spriteSheet.createAnimation(1, stepTime: stepSize);
    animationRunningRight = spriteSheet.createAnimation(2, stepTime: stepSize);
    animationRunningUp = spriteSheet.createAnimation(3, stepTime: stepSize);
    animationStandingDown = spriteSheet.createAnimation(4,
        stepTime: stepSize * _randomStandingStepSize);
    animationStandingLeft = spriteSheet.createAnimation(5,
        stepTime: stepSize * _randomStandingStepSize);
    animationStandingUp = spriteSheet.createAnimation(7,
        stepTime: stepSize * _randomStandingStepSize);
    animationStandingRight = spriteSheet.createAnimation(6,
        stepTime: stepSize * _randomStandingStepSize);
    animatedEntity = AnimationComponent(0, 0, animationStandingDown);
  }

  void render(Canvas canvas) {
    canvas.save();
    animatedEntity.render(canvas);
    canvas.restore();
    canvas.save();
    _healthbar.render(canvas);
    canvas.restore();
  }

  void update(double t, double serverT) {
    double timeFactor = t / _nextState[1 - _stateIndex]["duration"];

    double dx = _previousState[1 - _stateIndex]["x"] - animatedEntity.x;
    double dy = _previousState[1 - _stateIndex]["y"] - animatedEntity.y;
    health = _previousState[1 - _stateIndex]["health"];
    maxHealth = _previousState[1 - _stateIndex]["maxHealth"];
    if (health < 0) {
      health = 0;
    }

    if (dx != 0) {
      _velX =
          dx * timeFactor / (dx.abs() + dy.abs()) * scaledScreenSizeWidth * 245;
    }
    if (dy != 0) {
      _velY = dy *
          timeFactor /
          (dx.abs() + dy.abs()) *
          scaledScreenSizeHeight *
          245;
    }
    if ((dx > 0 &&
                animatedEntity.x + _velX > _nextState[1 - _stateIndex]["x"] ||
            dx < 0 &&
                animatedEntity.x + _velX < _nextState[1 - _stateIndex]["x"]) ||
        (dy > 0 &&
                animatedEntity.y + _velY > _nextState[1 - _stateIndex]["y"] ||
            dy < 0 &&
                animatedEntity.y + _velY < _nextState[1 - _stateIndex]["y"])) {
      _velX = 0;
      _velY = 0;
    }

    animatedEntity.x = animatedEntity.x + _velX;
    animatedEntity.y = animatedEntity.y + _velY;

    animatedEntity.animation.update(t);
    _healthbar.updateRect(
        maxHealth, health, animatedEntity.x, animatedEntity.y);
  }

  void updateState(Map<String, dynamic> characterState,
      Map<String, dynamic> playerState, double gametime) {
    _previousState[_stateIndex] = _nextState[_stateIndex];
    double nextX = (screenSize.width / 20000) * playerState["x"] -
        (screenSize.width / 20000) * characterState["x"] +
        charOffsetX;
    double nextY = (screenSize.height / 10000) * playerState["y"] -
        (screenSize.height / 10000) * characterState["y"] +
        charOffsetY;
    int nextDirection = playerState["dir"];

    _nextState[_stateIndex]["x"] = nextX;
    _nextState[_stateIndex]["y"] = nextY;
    _nextState[_stateIndex]["dir"] = nextDirection;
    _nextState[_stateIndex]["duration"] = gametime;
    _nextState[_stateIndex]["health"] = playerState["health"];
    _nextState[_stateIndex]["maxHealth"] = playerState["maxHealth"];

    switch (nextDirection) {
      case 0:
        animatedEntity.animation = animationRunningLeft;
        break;
      case 1:
        animatedEntity.animation = animationRunningUp;
        break;
      case 2:
        animatedEntity.animation = animationRunningRight;
        break;
      case 3:
        animatedEntity.animation = animationRunningDown;
        break;
      case 4:
        animatedEntity.animation = animationStandingLeft;
        break;
      case 5:
        animatedEntity.animation = animationStandingUp;
        break;
      case 6:
        animatedEntity.animation = animationStandingRight;
        break;
      case 7:
        animatedEntity.animation = animationStandingDown;
        break;
      default:
    }

    _stateIndex = 1 - _stateIndex;
  }

  void resize() {
    _previousState = [initialState, initialState];
    _nextState = [initialState, initialState];
    animatedEntity.width = baseAnimationWidth;
    animatedEntity.height = baseAnimationHeight;

    animatedEntity.x = _nextState[_stateIndex]["x"];
    animatedEntity.y = _nextState[_stateIndex]["y"];

    health = _nextState[_stateIndex]["health"];
    maxHealth = _nextState[_stateIndex]["maxHealth"];

    _healthbar = EnemyHealthbar(health, maxHealth);
    _healthbar.resize(animatedEntity.x, animatedEntity.y);
  }
}
