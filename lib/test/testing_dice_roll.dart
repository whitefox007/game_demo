// import 'dart:math';

// import 'package:flame/components.dart';
// import 'package:flame/flame.dart';
// import 'package:flame/game.dart';
// import 'package:flame/sprite.dart';
// import 'package:flame/components/text_component.dart';
// import 'package:flame/tween.dart';
// import 'package:flutter/material.dart';

// class DiceRoll extends FlameGame {
//   Random _random = Random();

//   TextComponent _dice1;
//   TextComponent _dice2;

//   TextStyle _diceStyle = TextStyle(fontSize: 64, color: Colors.black);

//   @override
//   Future<void> onLoad() async {
//     _dice1 = TextComponent('1', style: _diceStyle);
//     _dice2 = TextComponent('1', style: _diceStyle);

//     _dice1.position = Vector2(size.width / 4, size.height / 2);
//     _dice2.position = Vector2(3 * size.width / 4, size.height / 2);

//     add(_dice1);
//     add(_dice2);
//   }

//   void rollDice() {
//     _dice1.text = '${_random.nextInt(6) + 1}';
//     _dice2.text = '${_random.nextInt(6) + 1}';

//     _dice1.position = Vector2(size.width / 4, size.height / 2);
//     _dice2.position = Vector2(3 * size.width / 4, size.height / 2);
//   }
// }

// class DiceRollGame extends FlameGame {
//   final Random _random = Random();
//   late final Dice _dice1;
//   late final Dice _dice2;
//   late final TextPainter _textConfig;
//   late final Tween<double> _dice1RollAnimation;
//   late final Tween<double> _dice2RollAnimation;
//   late final List<int> _previousRolls = [];

//   DiceRollGame() {
//     _dice1 = Dice(100, 100);
//     _dice2 = Dice(200, 100);
//     _dice1RollAnimation = Tween<double>(begin: 0, end: pi * 2)
//       ..duration = const Duration(seconds: 2)
//       ..easing = Easing.easeInOutCubic;
//     _dice2RollAnimation = Tween<double>(begin: 0, end: pi * 2)
//       ..duration = const Duration(seconds: 2)
//       ..easing = Easing.easeInOutCubic;
//     add(_dice1);
//     add(_dice2);
//     add(TapDetector(onTapDown: _onTapDown));
//   }

//   void _onTapDown(TapDownDetails details) async {
//     if (isTweening()) {
//       return;
//     }
//     final roll1 = _random.nextInt(6) + 1;
//     final roll2 = _random.nextInt(6) + 1;
//     _previousRolls.add(roll1);
//     _previousRolls.add(roll2);
//     _dice1RollAnimation.start();
//     _dice2RollAnimation.start();
//     await Future.delayed(const Duration(seconds: 2));
//     _dice1.setFace(roll1);
//     _dice2.setFace(roll2);
//     _dice1RollAnimation.stop();
//     _dice2RollAnimation.stop();
//   }

//   bool isTweening() {
//     return _dice1RollAnimation.isRunning || _dice2RollAnimation.isRunning;
//   }

//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     for (var i = 0; i < _previousRolls.length; i += 2) {
//       _textConfig.render(
//         canvas,
//         '${_previousRolls[i]} + ${_previousRolls[i + 1]} = ${_previousRolls[i] + _previousRolls[i + 1]}',
//         Vector2(100, 200 + (i / 2) * 50),
//       );
//     }
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);
//     _dice1.angle = _dice1RollAnimation.value;
//     _dice2.angle = _dice2RollAnimation.value;
//   }
// }
