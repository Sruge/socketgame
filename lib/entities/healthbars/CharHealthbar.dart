import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

class CharHealthbar {
  Rect _healthbarGreen;
  Rect _healthbarRed;
  Rect _healthbarBorder;
  SpriteComponent _coinsRect;
  Rect _scoreRect;
  int maxHealth;
  int health;
  TextPainter tpBullets;
  TextPainter tpCoins;
  TextPainter tpScore;
  TextPainter tpHealth;
  Offset coinsTextOffset;
  Offset scoreTextOffset;
  Offset healthTextOffset;

  int _coins;
  int _score;
  Paint paintGreen;
  Paint paintRed;
  Paint paintBlack;
  Paint paintBullet;
  Paint paintScore;

  CharHealthbar(this.maxHealth, this.health, this._coins, this._score) {
    paintGreen = Paint();
    paintGreen.color = Color(0xff00ff00);
    paintRed = Paint();
    paintRed.color = Color(0xffff0000);
    paintBlack = Paint();
    paintBlack.color = Color(0xff000000);
    paintBullet = Paint();
    paintBullet.color = Color(0xffdcb430);
    paintScore = Paint();
    paintScore.color = Color(0xff50006c);

    double greenSize = (health / maxHealth) * 100;
    double redSize = ((maxHealth - health) / maxHealth) * 100;
    _healthbarGreen =
        Rect.fromLTWH(screenSize.width / 3, 20, greenSize * 2, 30);
    _healthbarRed =
        Rect.fromLTWH(screenSize.width / 3 + greenSize, 20, redSize * 2, 30);
    _healthbarBorder = Rect.fromLTWH(
        screenSize.width / 3 - 2, 18, greenSize + redSize + 4, 34);

    tpBullets = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tpCoins = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tpScore = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tpHealth = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
  }

  void render(Canvas canvas) {
    canvas.save();
    canvas.drawRect(_healthbarBorder, paintBlack);
    canvas.drawRect(_healthbarGreen, paintGreen);
    canvas.drawRect(_healthbarRed, paintRed);
    canvas.drawRect(_scoreRect, paintScore);
    canvas.save();
    _coinsRect.render(canvas);
    canvas.restore();
    tpScore.paint(canvas, scoreTextOffset);
    tpCoins.paint(canvas, coinsTextOffset);
    tpHealth.paint(canvas, healthTextOffset);
  }

  void resize() {
    double greenSize = (health / maxHealth) * 100;
    double redSize = ((maxHealth - health) / maxHealth) * 100;
    _healthbarGreen =
        Rect.fromLTWH(screenSize.width / 3, 10, greenSize * 2, 30);
    _healthbarRed =
        Rect.fromLTWH(screenSize.width / 3 + greenSize, 10, redSize * 2, 30);
    _healthbarBorder = Rect.fromLTWH(
        (screenSize.width - 100) / 2, 8, greenSize + redSize + 4, 32);
    _scoreRect = Rect.fromLTWH(screenSize.width / 3 - 10 - 48, 8, 48, 32);
    _coinsRect = SpriteComponent.fromSprite(34, 34, Sprite('coinsCount.png'));
    _coinsRect.x = screenSize.width / 1.5 + 20;
    _coinsRect.y = 8;
  }

  void updateRect(int maxH, int h) {
    maxHealth = maxH;
    health = h;
    double greenSize = (health / maxHealth) * screenSize.width / 3;
    double redSize = ((maxHealth - health) / maxHealth) * screenSize.width / 3;
    _healthbarGreen = Rect.fromLTWH(screenSize.width / 3, 10, greenSize, 28);
    _healthbarRed =
        Rect.fromLTWH(screenSize.width / 3 + greenSize, 10, redSize, 28);
    _healthbarBorder = Rect.fromLTWH(
        (screenSize.width - screenSize.width / 3) / 2 - 2,
        8,
        greenSize + redSize + 4,
        32);
    tpHealth.text = TextSpan(
      text: '${h.toInt()}/${maxH.toInt()}',
      style: TextStyle(color: Color(0xffffffff), fontSize: 16),
    );
    tpHealth.layout();
    healthTextOffset = Offset((screenSize.width - tpHealth.width) / 2,
        _healthbarBorder.top + (_healthbarBorder.height - tpHealth.height) / 2);
  }

  void updateCounts(int score, int coins) {
    _coins = coins;
    _score = score;

    tpScore.text = TextSpan(
      text: (_score).toString(),
      style: TextStyle(color: Color(0xffffffff), fontSize: 25),
    );
    tpScore.layout();
    scoreTextOffset = Offset(
      _scoreRect.center.dx - (tpScore.width / 2),
      _scoreRect.top + (_scoreRect.height * .5) - (tpScore.height / 2),
    );

    tpCoins.text = TextSpan(
      text: (_coins).toString(),
      style: TextStyle(color: Color(0xffffffff), fontSize: 25),
    );
    tpCoins.layout();
    coinsTextOffset = Offset(
      _coinsRect.x + ((_coinsRect.width - tpCoins.width) / 2),
      _coinsRect.y + ((_coinsRect.height - tpCoins.height) / 2),
    );
  }

  void update(int maxH, int h, int score, int coins) {
    updateRect(maxH, h);
    updateCounts(score, coins);
  }
}
