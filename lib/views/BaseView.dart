import 'dart:ui';

abstract class BaseView {
  void render(Canvas canvas, bool upperHalf) {}

  void update(double t, double serverT) {}

  void resize() {}
}
