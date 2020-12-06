import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';
import 'dart:ui';

import 'CharacterMode.dart';
import 'InterfaceBtn.dart';

class InterfaceBtnBar {
  List<InterfaceBtn> _buttons;
  PositionComponent _buttonBar;

  PositionComponent _topBar;
  double firstBtnX;
  double y;
  int activeButton;
  CharacterMode mode;

  InterfaceBtnBar(List<CharacterMode> btns) {
    _buttonBar = SpriteComponent.fromSprite(0, 0, Sprite('buttonBar.png'));
    _topBar = SpriteComponent.fromSprite(screenSize.width * 0.6,
        screenSize.height * 0.05, Sprite('buttonBar.png'));
    _topBar.renderFlipY = true;
    _buttons = [];
    btns.forEach((btnType) {
      _buttons.add(InterfaceBtn(btnType));
    });
  }

  List onTapDown(TapDownDetails detail) {
    bool btnBarClicked = false;
    _buttons.forEach((btn) {
      if (btn.toRect().contains(detail.globalPosition)) {
        btn.isActive = true;
        mode = btn.getMode();
        btnBarClicked = true;
      } else {
        btn.isActive = false;
      }
    });
    return [mode, btnBarClicked];
  }

  void render(Canvas canvas) {
    canvas.save();
    _buttonBar.render(canvas);
    canvas.restore();
    canvas.save();
    _topBar.render(canvas);
    canvas.restore();
    _buttons.forEach((element) {
      canvas.save();
      element.render(canvas);
      canvas.restore();
    });
  }

  void resize() {
    _topBar.x = screenSize.width * 0.2;
    _buttonBar.width = screenSize.width * 0.3;
    _buttonBar.height = screenSize.height * 0.07;
    _buttonBar.x = screenSize.width * 0.35;
    _buttonBar.y = screenSize.height - _buttonBar.height;

    double btnSize = screenSize.width * 0.06;

    double firstBtnX = screenSize.width / 2 - _buttons.length * btnSize / 2;
    double pushDistance = btnSize;

    for (int i = 0; i < _buttons.length; i++) {
      _buttons[i].resize(btnSize, firstBtnX + pushDistance * i);
    }
  }

  void update(double t) {
    _topBar.update(t);
    _buttons.forEach((element) {
      element.update(t);
    });
  }

  void deactivateAll() {
    _buttons.forEach((element) {
      element.isActive = false;
    });
  }

  void getMode() {}
}
