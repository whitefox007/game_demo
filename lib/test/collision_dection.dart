import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

class CollisionDetectionGame extends FlameGame
    with HasCollisionDetection, HasTappableComponents {
  final paint = BasicPalette.gray.paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  @override
  Future<void> onLoad() async {
    // final emberPlayer = EmberPlayer(
    //   position: Vector2(10, (size.y / 2) - 20),
    //   size: Vector2.all(40),
    //   onTap: (emberPlayer) {
    //     emberPlayer.add(
    //       MoveEffect.to(
    //         Vector2(size.x - 40, (size.y / 2) - 20),
    //         EffectController(
    //           duration: 5,
    //           reverseDuration: 5,
    //           repeatCount: 1,
    //           curve: Curves.easeOut,
    //         ),
    //       ),
    //     );
    //   },
    // );
    add(BoxComponent());
    add(RectangleCollidable(canvasSize / 2));
  }
}

class RectangleCollidable extends PositionComponent with CollisionCallbacks {
  final _collisionStartColor = Colors.amber;
  final _defaultColor = Colors.cyan;
  late ShapeHitbox hitbox;

  RectangleCollidable(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(50),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    final defaultPaint = Paint()
      ..color = _defaultColor
      ..style = PaintingStyle.stroke;
    hitbox = RectangleHitbox()
      ..paint = defaultPaint
      ..renderShape = true;

    add(hitbox);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    print(other);
    print(intersectionPoints);
    super.onCollisionStart(intersectionPoints, other);
    hitbox.paint.color = _collisionStartColor;
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (!isColliding) {
      hitbox.paint.color = _defaultColor;
    }
  }
}

class BoxComponent extends RectangleComponent with CollisionCallbacks {
  static const int squareSpeed = 250;
  static final squarePaint = Paint()..color = Colors.green;
  static const squareWidth = 20.0, squareHeight = 20.0;
  late Rect squarePos;
  int squareDirection = 1;
  late double screenWidth, screenHeight, centerX, centerY;
  final nextPosition = Vector2.zero();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    screenWidth = MediaQueryData.fromWindow(window).size.width;
    screenHeight = MediaQueryData.fromWindow(window).size.height;
    centerX = (screenWidth / 2) - (squareWidth / 2);
    centerY = (screenHeight / 2) - (squareHeight / 2);
    position = Vector2(centerX, centerY);
    size = Vector2(squareWidth, squareHeight);
    paint = squarePaint;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    position.x += squareSpeed * squareDirection * dt;
    if (squareDirection == 1 && position.x > screenWidth) {
      squareDirection = -1;
    } else if (squareDirection == -1 && position.x < 0) {
      squareDirection = 1;
    }
  }

  // @override
  // void render(Canvas canvas) {
  //   canvas.drawRect(position, squarePaint);
  //   super.render(canvas);
  // }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    print(intersectionPoints);
    print(intersectionPoints.length);
    if (intersectionPoints.length > 1) {
      print('object');
      paint = squarePaint..color = Colors.red;
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (!isColliding) {
      paint = squarePaint..color = Colors.green;
    }
  }
}

class Ball extends CircleComponent with CollisionCallbacks {
  late double screenWidth, screenHeight, centerX, centerY;
  Ball()
      : super(
          paint: Paint()..color = Colors.red,
          radius: 10,
          children: [CircleHitbox(isSolid: true)],
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    screenWidth = MediaQueryData.fromWindow(window).size.width;
    screenHeight = MediaQueryData.fromWindow(window).size.height;
    centerX = (screenWidth / 2) - (size.x / 2);
    centerY = (screenHeight / 2) - (size.y / 2);
    position = Vector2(
      centerX,
      centerY,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    print(other);
    print(intersectionPoints);
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    print(other);
  }
}
