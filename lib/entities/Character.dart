import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/spritesheet.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

import 'AnimatedEntity..dart';
import 'entityData.dart';

class Character {
  String _type;
  int id;

  AnimationComponent _entityRnDown;
  AnimationComponent _entityRnLeft;
  AnimationComponent _entityRnUp;
  AnimationComponent _entityRnRight;
  AnimationComponent _entityStdDown;
  AnimationComponent _entityStdLeft;
  AnimationComponent _entityStdUp;
  AnimationComponent _entityStdRight;
  AnimationComponent _activeEntity;

  List<Map<String, dynamic>> _nextState;
  List<Map<String, dynamic>> _previousState;
  //A player and an opponent use the same sprite images
  Character(this.id, this._type, double x, double y, int dir) {
    String _animationPath = entityData['opponents'][_type]["imgUrl"];
    int _txtWidth = entityData['opponents'][_type]["txtWidth"];
    int _txtHeight = entityData['opponents'][_type]["txtHeight"];
    int _cols = entityData['opponents'][_type]["cols"];
    int _rows = entityData['opponents'][_type]["rows"];
    double stepSize = 0.1;
    SpriteSheet spriteSheet = SpriteSheet(
        imageName: _animationPath,
        textureWidth: _txtWidth,
        textureHeight: _txtHeight,
        columns: _cols,
        rows: _rows);
    Animation animationRunningDown =
        spriteSheet.createAnimation(0, stepTime: stepSize);
    Animation animationRunningLeft =
        spriteSheet.createAnimation(1, stepTime: stepSize);
    Animation animationRunningRight =
        spriteSheet.createAnimation(2, stepTime: stepSize);
    Animation animationRunningUp =
        spriteSheet.createAnimation(3, stepTime: stepSize);
    Animation animationStandingDown =
        spriteSheet.createAnimation(4, stepTime: stepSize * 1.5);
    Animation animationStandingLeft =
        spriteSheet.createAnimation(5, stepTime: stepSize * 1.5);
    Animation animationStandingUp =
        spriteSheet.createAnimation(7, stepTime: stepSize * 1.5);
    Animation animationStandingRight =
        spriteSheet.createAnimation(6, stepTime: stepSize * 1.5);
    _entityRnDown = AnimationComponent(0, 0, animationRunningDown);
    _entityRnUp = AnimationComponent(0, 0, animationRunningUp);
    _entityRnLeft = AnimationComponent(0, 0, animationRunningLeft);
    _entityRnRight = AnimationComponent(0, 0, animationRunningRight);
    _entityStdDown = AnimationComponent(0, 0, animationStandingDown);
    _entityStdUp = AnimationComponent(0, 0, animationStandingUp);
    _entityStdLeft = AnimationComponent(0, 0, animationStandingLeft);
    _entityStdRight = AnimationComponent(0, 0, animationStandingRight);

    _activeEntity = _entityStdDown;
  }

  void render(Canvas canvas) {
    _activeEntity.x = (screenSize.width - baseAnimationWidth()) / 2;
    _activeEntity.y = (screenSize.height - baseAnimationHeight()) / 2;
    canvas.save();
    _activeEntity.render(canvas);
    canvas.restore();
  }

  void update(double t, double serverT) {
    _activeEntity.animation.update(t);
  }

  void updateState(Map<String, dynamic> characterState) {
    int timeNow = DateTime.now().millisecondsSinceEpoch;

    int nextDirection = characterState["dir"];

    switch (nextDirection) {
      case 0:
        _activeEntity = _entityRnLeft;
        break;
      case 1:
        _activeEntity = _entityRnUp;
        break;
      case 2:
        _activeEntity = _entityRnRight;
        break;
      case 3:
        _activeEntity = _entityRnDown;
        break;
      case 4:
        _activeEntity = _entityStdLeft;
        break;
      case 5:
        _activeEntity = _entityStdUp;
        break;
      case 6:
        _activeEntity = _entityStdRight;
        break;
      case 7:
        _activeEntity = _entityStdDown;
        break;
      default:
    }
  }

  void resize() {
    _entityRnDown.width = baseAnimationWidth();
    _entityRnDown.height = baseAnimationHeight();

    _entityRnLeft.width = baseAnimationWidth();
    _entityRnLeft.height = baseAnimationHeight();

    _entityRnUp.width = baseAnimationWidth();
    _entityRnUp.height = baseAnimationHeight();

    _entityRnRight.width = baseAnimationWidth();
    _entityRnRight.height = baseAnimationHeight();

    _entityStdDown.width = baseAnimationWidth();
    _entityStdDown.height = baseAnimationHeight();

    _entityStdUp.width = baseAnimationWidth();
    _entityStdUp.height = baseAnimationHeight();

    _entityStdRight.width = baseAnimationWidth();
    _entityStdRight.height = baseAnimationHeight();

    _entityStdLeft.width = baseAnimationWidth();
    _entityStdLeft.height = baseAnimationHeight();

    _entityStdDown.width = baseAnimationWidth();
    _entityStdDown.height = baseAnimationHeight();
  }

  factory Character.fromJson(Map<String, dynamic> json) => Character(json["id"],
      json["type"], json["x"].toDouble(), json["y"].toDouble(), json["dir"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": _type,
      };
}
