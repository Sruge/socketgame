import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'dart:ui';

import 'package:socketgame/entities/interface/CharacterMode.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

class InterfaceBtn {
  PositionComponent _button;
  AnimationComponent _buttonActive;
  bool isActive;
  double x, y;
  CharacterMode _type;
  InterfaceBtn(this._type) {
    isActive = false;
    String imgUrl;
    switch (_type) {
      case CharacterMode.Attack:
        imgUrl = 'fire';
        break;
      case CharacterMode.Walk:
        imgUrl = 'tree';
        break;
    }
    _button =
        SpriteComponent.fromSprite(48, 48, Sprite('${imgUrl}inactive.png'));
    final sprShe = SpriteSheet(
        imageName: '${imgUrl}active.png',
        textureWidth: 128,
        textureHeight: 128,
        columns: 4,
        rows: 1);
    final animation = sprShe.createAnimation(0, stepTime: 0.2);
    _buttonActive = AnimationComponent(48, 48, animation);
  }

  void onTapDown(TapDownDetails detail, Function fn) {
    if (_button.toRect().contains(detail.globalPosition)) {
      isActive = !isActive;
    }
  }

  void render(Canvas canvas) {
    canvas.save();
    if (isActive)
      _buttonActive.render(canvas);
    else
      _button.render(canvas);
    canvas.restore();
  }

  void resize(double btnSize, double x) {
    _button.width =
        _button.height = _buttonActive.width = _buttonActive.height = btnSize;
    _button.y = _buttonActive.y =
        screenSize.height - screenSize.height * 0.02 - btnSize;
    _button.x = _buttonActive.x = x;
  }

  void update(double t) {
    if (isActive) {
      _buttonActive.update(t);
      _buttonActive.animation.update(t);
    } else {
      _button.update(t);
    }
  }

  Rect toRect() {
    return _button.toRect();
  }

  CharacterMode getMode() {
    return _type;
  }
}
