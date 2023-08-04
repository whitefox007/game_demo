import 'package:flame/components.dart';
import 'package:flame/game.dart';

class TestBase extends FlameGame {
  TestBoard board = TestBoard();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await add(board);
    
      
  }
}

class TestBoard extends SpriteComponent with HasGameRef {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('Ludo_board.png');
    sprite!.originalSize;
  }
}
