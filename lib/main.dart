import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:game_demo/dino_game.dart';
import 'package:game_demo/helpers/navigation_keys.dart';
import 'package:game_demo/test/collision_dection.dart';
import 'package:game_demo/test/ray_detection.dart';
import 'package:game_demo/test/test_board.dart';
import 'package:game_demo/test/test_render.dart';


    void main() {
      final game = RayCastExample();
      runApp(
       GameWidget(
                  game: game,
                ),
      );
    }

