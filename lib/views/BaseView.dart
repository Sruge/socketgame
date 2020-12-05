import 'dart:ui';

abstract class BaseView {
  void render(Canvas canvas) {}

  void update(double t, double serverT) {}

  void resize() {}
}
