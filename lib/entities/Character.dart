import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/gestures.dart';
import 'package:socketgame/MMOGame.dart';
import 'package:socketgame/entities/healthbars/CharHealthbar.dart';
import 'package:socketgame/entities/interface/CharacterMode.dart';
import 'package:socketgame/entities/interface/InterfaceBtnBar.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';
import 'Entity.dart';
import 'entityData.dart';

class Character extends Entity {
  String _type;
  int id;
  int _maxHealth;
  int _health;
  int _score, _coins;

  Animation animationRunningDown;
  Animation animationRunningLeft;
  Animation animationRunningRight;
  Animation animationRunningUp;
  Animation animationStandingDown;
  Animation animationStandingLeft;
  Animation animationStandingUp;
  Animation animationStandingRight;
  AnimationComponent animatedEntity;
  CharHealthbar _healthbar;
  InterfaceBtnBar _btnbar;

  //A player and an opponent use the same sprite images
  Character(this.id, this._type, this._health, this._maxHealth, int dir) {
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
    animationRunningDown = spriteSheet.createAnimation(0, stepTime: stepSize);
    animationRunningLeft = spriteSheet.createAnimation(1, stepTime: stepSize);
    animationRunningRight = spriteSheet.createAnimation(2, stepTime: stepSize);
    animationRunningUp = spriteSheet.createAnimation(3, stepTime: stepSize);
    animationStandingDown =
        spriteSheet.createAnimation(4, stepTime: stepSize * 1.5);
    animationStandingLeft =
        spriteSheet.createAnimation(5, stepTime: stepSize * 1.5);
    animationStandingUp =
        spriteSheet.createAnimation(7, stepTime: stepSize * 1.5);
    animationStandingRight =
        spriteSheet.createAnimation(6, stepTime: stepSize * 1.5);

    // coins and score is fake
    _coins = _score = 100;
    _healthbar = CharHealthbar(_maxHealth, _health, _coins, _score);
    _btnbar = InterfaceBtnBar([CharacterMode.Attack, CharacterMode.Walk]);
    animatedEntity = AnimationComponent(0, 0, animationStandingDown);
  }

  //All the taps in the game are handled here by the character itself
  void onTapDown(TapDownDetails details) {
    List btnBarResults = _btnbar.onTapDown(details);
    if (!btnBarResults[1]) {
      mmoGame.addToSocket(
          btnBarResults[0].toString(),
          (details.globalPosition.dx - screenSize.width / 2) /
              scaledScreenSizeWidth,
          (details.globalPosition.dy - screenSize.height / 2) /
              scaledScreenSizeHeight);
    }
  }

  void render(Canvas canvas) {
    canvas.save();
    animatedEntity.render(canvas);
    canvas.restore();
  }

  void renderInterface(Canvas canvas) {
    canvas.save();
    _btnbar.render(canvas);
    canvas.restore();
    canvas.save();
    _healthbar.render(canvas);
    canvas.restore();
  }

  void update(double t, double serverT) {
    _btnbar.update(t);
    _healthbar.update(_maxHealth, _health, _score, _coins);
    animatedEntity.animation.update(t);
  }

  void updateState(Map<String, dynamic> characterState) {
    _health = characterState["health"];
    _maxHealth = characterState["maxHealth"];
    int nextDirection = characterState["dir"];

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
  }

  void resize() {
    animatedEntity.x = charOffsetX;
    animatedEntity.y = charOffsetY;
    animatedEntity.width = baseAnimationWidth;
    animatedEntity.height = baseAnimationHeight;

    _healthbar.resize();
    _btnbar.resize();
  }

  factory Character.fromJson(Map<String, dynamic> json) => Character(
      json["id"], json["type"], json["health"], json["maxHealth"], json["dir"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": _type,
      };
}
