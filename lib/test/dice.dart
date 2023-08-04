import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Dice {
  late final Paint _paint;
  late final Vector2 _position;
  late int _face;
  double angle = 0;

  Dice(double x, double y) {
    _paint = Paint()..color = Colors.white;
    _position = Vector2(x, y);
    _face = 1;
  }

  void setFace(int value) {
    _face = value;
  }

  void draw(Canvas canvas) {
    final rect = Rect.fromLTWH(-32, -32, 64, 64);
    canvas.save();
    canvas.translate(_position.x, _position.y);
    canvas.rotate(angle);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(8)), _paint);
    canvas.drawCircle(
        Offset(-16, -16), 4, _face == 1 || _face == 3 || _face == 5 ? _paint : Paint()..color = Colors.transparent);
    canvas.drawCircle(
        Offset(16, 16), 4, _face == 2 || _face == 3 || _face == 4 ? _paint : Paint()..color = Colors.transparent);
    if (_face > 3) {
      canvas.drawCircle(
          Offset(-16, 16), 4, _face == 4 || _face == 5 || _face == 6 ? _paint : Paint()..color = Colors.transparent);
      canvas.drawCircle(
          Offset(16, -16), 4, _face == 4 || _face == 5 || _face == 6 ? _paint : Paint()..color = Colors.transparent);
    }
    if (_face == 6) {
      canvas.drawCircle(Offset(0, 0), 4, _paint);
    }
    canvas.restore();
  }
}