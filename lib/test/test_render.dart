import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../util/colors.dart';

class TestRender extends FlameGame with HasCollisionDetection {
  @override
  Future<void> onLoad() async {
    await images.load('Ludo_board.png');

    add(Board(
      trackCalculationListener: (playerTrack) {},
      boxBound: () {
        
      },
    ));
    add(Spawn());
    // add(DicePaint(6));
    // add(BoxComponent());
    // add(BoxComponent2());
  }
}

class BoxComponent extends PositionComponent with CollisionCallbacks {
  static const int squareSpeed = 250;
  static final squarePaint = BasicPalette.green.paint();
  static final squareWidth = 100.0, squareHeight = 100.0;
  late Rect squarePos;
  int squareDirection = 1;
  late double screenWidth, screenHeight, centerX, centerY;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    screenWidth = MediaQueryData.fromWindow(window).size.width;
    screenHeight = MediaQueryData.fromWindow(window).size.height;
    centerX = (screenWidth / 2) - (squareWidth / 2);
    centerY = (screenHeight / 2) - (squareHeight / 2);
    squarePos = Rect.fromLTWH(centerX, centerY, squareWidth, squareHeight);

    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    squarePos = squarePos.translate(squareSpeed * squareDirection * dt, 0);
    if (squareDirection == 1 && squarePos.right > screenWidth) {
      squareDirection = -1;
    } else if (squareDirection == -1 && squarePos.left < 0) {
      squareDirection = 1;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(squarePos, squarePaint);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    print(other);
    print(intersectionPoints);
    super.onCollision(intersectionPoints, other);
  }
}

class BoxComponent2 extends PositionComponent with CollisionCallbacks {
  static const int squareSpeed = 200;
  static final squarePaint = BasicPalette.red.paint();
  static final squareWidth = 80.0, squareHeight = 80.0;
  late Rect squarePos;
  int squareDirection = 1;
  late double screenWidth, screenHeight, centerX, centerY;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    screenWidth = MediaQueryData.fromWindow(window).size.width;
    screenHeight = MediaQueryData.fromWindow(window).size.height;
    centerX = (screenWidth / 2) - (squareWidth / 2);
    centerY = (screenHeight / 2) - (squareHeight / 2);
    squarePos = Rect.fromLTWH(centerX, centerY, squareWidth, squareHeight);

    add(RectangleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    squarePos = squarePos.translate(0, squareSpeed * squareDirection * dt);
    if (squareDirection == -1 && squarePos.top < 0) {
      squareDirection = 1;
    } else if (squareDirection == 1 && squarePos.bottom > screenHeight) {
      squareDirection = -1;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(squarePos, squarePaint);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    print('Yeah');
    print(other);
    print(intersectionPoints);
    super.onCollision(intersectionPoints, other);
  }
}

class TestBoard extends SpriteComponent with HasGameRef {
  @override
  Future<void> onLoad() async {
    final groundImage = game.images.fromCache('Ludo_board.png');
    sprite = Sprite(groundImage);
  }
}

class Board extends PositionComponent {
  double? _stepSize, _homeStartOffset, _homeSize, _canvasCenter;
  final Function(List<List<List<Rect>>>)? trackCalculationListener;
  final Function()? boxBound;

  Board( {required this.trackCalculationListener, required this.boxBound,});
  final List<List<Offset>> _homeSpotsList = [];
  late double screenWidth, screenHeight, centerX, centerY;

  Paint fillPaint = Paint()..style = PaintingStyle.fill;
  Paint whiteArea = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..color = Colors.black;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    screenWidth = MediaQueryData.fromWindow(window).size.width;
    screenHeight = MediaQueryData.fromWindow(window).size.height;
    _stepSize = screenWidth / 15;
    _homeStartOffset = _stepSize! * 9;
    _homeSize = _stepSize! * 6;
    _canvasCenter = screenWidth / 2;
  }

  @override
  void update(double dt) {
    // print(MediaQueryData.fromWindow(window).size.width);
  }

  @override
  void render(Canvas canvas) {
    _drawHome(canvas);
    _drawDestination(canvas);

    _drawSteps(canvas);

    _calculatePlayerTracks();
  }

  void _drawHome(Canvas canvas) {
    /**
     * Draw home base
     */
    fillPaint.color = AppColors.home1;
    var home1 = Rect.fromLTWH(0, 0, _homeSize!, _homeSize!);
    canvas.drawRect(home1, fillPaint);
    canvas.drawRect(home1, _strokePaint);

    fillPaint.color = AppColors.home2;
    var home2 = Rect.fromLTWH(_homeStartOffset!, 0, _homeSize!, _homeSize!);
    canvas.drawRect(home2, fillPaint);
    canvas.drawRect(home2, _strokePaint);

    fillPaint.color = AppColors.home3;
    var home3 = Rect.fromLTWH(
        _homeStartOffset!, _homeStartOffset!, _homeSize!, _homeSize!);
    canvas.drawRect(home3, fillPaint);
    canvas.drawRect(home3, _strokePaint);

    fillPaint.color = AppColors.home4;
    var home4 = Rect.fromLTWH(0, _homeStartOffset!, _homeSize!, _homeSize!);
    canvas.drawRect(home4, fillPaint);
    canvas.drawRect(home4, _strokePaint);

    /**
     * Draw inner home
     */
    var innerHomeSize = 4 * _stepSize!;

    fillPaint.color = Colors.white;
    var innerHome1 = Rect.fromLTWH(home1.left + _stepSize!,
        home1.top + _stepSize!, innerHomeSize, innerHomeSize);
    canvas.drawRect(innerHome1, fillPaint);
    canvas.drawRect(innerHome1, _strokePaint);

    var innerHome2 = Rect.fromLTWH(home2.left + _stepSize!,
        home2.top + _stepSize!, innerHomeSize, innerHomeSize);
    canvas.drawRect(innerHome2, fillPaint);
    canvas.drawRect(innerHome2, _strokePaint);

    var innerHome3 = Rect.fromLTWH(home3.left + _stepSize!,
        home3.top + _stepSize!, innerHomeSize, innerHomeSize);
    canvas.drawRect(innerHome3, fillPaint);
    canvas.drawRect(innerHome3, _strokePaint);

    var innerHome4 = Rect.fromLTWH(home4.left + _stepSize!,
        home4.top + _stepSize!, innerHomeSize, innerHomeSize);
    canvas.drawRect(innerHome4, fillPaint);
    canvas.drawRect(innerHome4, _strokePaint);

    /**
     * Draw spawn spots
     */
    // _drawSpawnSpots(canvas, innerHome1, AppColors.home1);
    // _drawSpawnSpots(canvas, innerHome2, AppColors.home2);
    // _drawSpawnSpots(canvas, innerHome3, AppColors.home3);
    // _drawSpawnSpots(canvas, innerHome4, AppColors.home4);
  }

  void _calculatePlayerTracks() {
    Rect? prevRect;
    Offset? prevOffset;

    /**
     * Player 1 track
     */
    List<Rect> playerOneTrack = [];
    for (int stepIndex = 0; stepIndex < 57; stepIndex++) {
      if (stepIndex == 0) {
        var offset = _stepSize! / 2;
        prevOffset = Offset(_stepSize! + offset, _homeSize! + offset);
      } else if (stepIndex < 5 ||
          stepIndex > 50 ||
          stepIndex > 18 && stepIndex < 24 ||
          stepIndex > 10 && stepIndex < 13) {
        prevOffset =
            Offset(prevRect!.center.dx + _stepSize!, prevRect.center.dy);
      } else if (stepIndex == 5) {
        prevOffset = Offset(
            prevRect!.center.dx + _stepSize!, prevRect.center.dy - _stepSize!);
      } else if (stepIndex < 11 ||
          stepIndex > 38 && stepIndex < 44 ||
          stepIndex == 50) {
        prevOffset =
            Offset(prevRect!.center.dx, prevRect.center.dy - _stepSize!);
      } else if (stepIndex < 18 ||
          stepIndex > 31 && stepIndex < 37 ||
          stepIndex > 18 && stepIndex < 26) {
        prevOffset =
            Offset(prevRect!.center.dx, prevRect.center.dy + _stepSize!);
      } else if (stepIndex == 18) {
        prevOffset = Offset(
            prevRect!.center.dx + _stepSize!, prevRect.center.dy + _stepSize!);
      } else if (stepIndex < 31 ||
          stepIndex > 31 && stepIndex < 39 ||
          stepIndex > 44 && stepIndex < 50) {
        prevOffset =
            Offset(prevRect!.center.dx - _stepSize!, prevRect.center.dy);
      } else if (stepIndex == 31) {
        prevOffset = Offset(
            prevRect!.center.dx - _stepSize!, prevRect.center.dy + _stepSize!);
      } else if (stepIndex == 44) {
        prevOffset = Offset(
            prevRect!.center.dx - _stepSize!, prevRect.center.dy - _stepSize!);
      }

      prevRect = Rect.fromCenter(
          center: prevOffset!, width: _stepSize!, height: _stepSize!);
      playerOneTrack.add(prevRect);
    }

    /**
     * Player 2 track
     */
    List<Rect> playerTwoTrack = [];

    playerTwoTrack.addAll(playerOneTrack.sublist(13, 51));
    prevRect = playerTwoTrack.last;
    playerTwoTrack.add(Rect.fromCenter(
        center: Offset(prevRect.center.dx, prevRect.center.dy - _stepSize!),
        width: _stepSize!,
        height: _stepSize!));
    playerTwoTrack.addAll(playerOneTrack.sublist(0, 12));

    for (int stepIndex = 0; stepIndex < 6; stepIndex++) {
      prevRect = playerTwoTrack.last;
      playerTwoTrack.add(Rect.fromCenter(
          center: Offset(prevRect.center.dx, prevRect.center.dy + _stepSize!),
          width: _stepSize!,
          height: _stepSize!));
    }

    /**
     * Player 3 track
     */
    List<Rect> playerThreeTrack = [];

    playerThreeTrack.addAll(playerTwoTrack.sublist(13, 51));
    prevRect = playerThreeTrack.last;
    playerThreeTrack.add(Rect.fromCenter(
        center: Offset(prevRect.center.dx + _stepSize!, prevRect.center.dy),
        width: _stepSize!,
        height: _stepSize!));
    playerThreeTrack.addAll(playerTwoTrack.sublist(0, 12));

    for (int stepIndex = 0; stepIndex < 6; stepIndex++) {
      prevRect = playerThreeTrack.last;
      playerThreeTrack.add(Rect.fromCenter(
          center: Offset(prevRect.center.dx - _stepSize!, prevRect.center.dy),
          width: _stepSize!,
          height: _stepSize!));
    }

    /**
     * Player 4 track
     */
    List<Rect> playerFourTrack = [];

    playerFourTrack.addAll(playerThreeTrack.sublist(13, 51));
    prevRect = playerFourTrack.last;
    playerFourTrack.add(Rect.fromCenter(
        center: Offset(prevRect.center.dx, prevRect.center.dy + _stepSize!),
        width: _stepSize!,
        height: _stepSize!));
    playerFourTrack.addAll(playerThreeTrack.sublist(0, 12));

    for (int stepIndex = 0; stepIndex < 6; stepIndex++) {
      prevRect = playerFourTrack.last;
      playerFourTrack.add(Rect.fromCenter(
          center: Offset(prevRect.center.dx, prevRect.center.dy - _stepSize!),
          width: _stepSize!,
          height: _stepSize!));
    }

    /**
     * Add spots with tracks
     */
    List<List<List<Rect>>> _playerTracks = [];
    for (int playerIndex = 0; playerIndex < 4; playerIndex++) {
      List<List<Rect>> playerTrack = [];

      for (int spotIndex = 0;
          spotIndex < _homeSpotsList[playerIndex].length;
          spotIndex++) {
        List<Rect> track = [];

        track.add(Rect.fromCenter(
            center: _homeSpotsList[playerIndex][spotIndex],
            width: _stepSize!,
            height: _stepSize!));

        switch (playerIndex) {
          case 0:
            track.addAll(playerOneTrack);
            break;
          case 1:
            track.addAll(playerTwoTrack);
            break;
          case 2:
            track.addAll(playerThreeTrack);
            break;
          case 3:
            track.addAll(playerFourTrack);
            break;
          default:
        }

        playerTrack.add(track);
      }
      _playerTracks.add(playerTrack);
    }

    // trackCalculationListener!(_playerTracks);
  }
  
  void _boxBounds(){
    
  }

  void _drawSpawnSpots(Canvas canvas, Rect innerHome, Color color) {
    List<Offset> spotList = [];

    fillPaint.color = color;
    var spotOffsetOne = innerHome.width / 4;
    var spotOffsetTwo = 3 * spotOffsetOne;
    double spotRadius = spotOffsetOne / 2;

    canvas.save();
    canvas.translate(innerHome.left, innerHome.top);

    var spot1 = Offset(spotOffsetOne, spotOffsetOne);
    canvas.drawCircle(spot1, spotRadius, fillPaint);
    canvas.drawCircle(spot1, spotRadius, _strokePaint);

    var spot2 = Offset(spotOffsetTwo, spotOffsetOne);
    canvas.drawCircle(spot2, spotRadius, fillPaint);
    canvas.drawCircle(spot2, spotRadius, _strokePaint);

    var spot3 = Offset(spotOffsetOne, spotOffsetTwo);
    canvas.drawCircle(spot3, spotRadius, fillPaint);
    canvas.drawCircle(spot3, spotRadius, _strokePaint);

    var spot4 = Offset(spotOffsetTwo, spotOffsetTwo);
    canvas.drawCircle(spot4, spotRadius, fillPaint);
    canvas.drawCircle(spot4, spotRadius, _strokePaint);

    canvas.restore();

    /**
     * Spots coordinate calculation
     */
    var left = innerHome.left + spotOffsetOne;
    var right = innerHome.left + spotOffsetTwo;
    var up = innerHome.top + spotOffsetOne;
    var down = innerHome.top + spotOffsetTwo;

    spotList.add(Offset(left, up));
    spotList.add(Offset(right, up));
    spotList.add(Offset(right, down));
    spotList.add(Offset(left, down));

    _homeSpotsList.add(spotList);
  }

  void _drawDestination(Canvas canvas) {
    fillPaint.color = AppColors.home1;
    var redDestination = Path()
      ..moveTo(_canvasCenter!, _canvasCenter!)
      ..lineTo(_homeSize!, _homeStartOffset!)
      ..lineTo(_homeSize!, _homeSize!)
      ..close();
    canvas.drawPath(redDestination, fillPaint);
    canvas.drawPath(redDestination, _strokePaint);

    fillPaint.color = AppColors.home2;
    var greenDestination = Path()
      ..moveTo(_canvasCenter!, _canvasCenter!)
      ..lineTo(_homeSize!, _homeSize!)
      ..lineTo(_homeStartOffset!, _homeSize!)
      ..close();
    canvas.drawPath(greenDestination, fillPaint);
    canvas.drawPath(greenDestination, _strokePaint);

    fillPaint.color = AppColors.home3;
    var yellowDestination = Path()
      ..moveTo(_canvasCenter!, _canvasCenter!)
      ..lineTo(_homeStartOffset!, _homeSize!)
      ..lineTo(_homeStartOffset!, _homeStartOffset!)
      ..close();
    canvas.drawPath(yellowDestination, fillPaint);
    canvas.drawPath(yellowDestination, _strokePaint);

    fillPaint.color = AppColors.home4;
    var blueDestination = Path()
      ..moveTo(_canvasCenter!, _canvasCenter!)
      ..lineTo(_homeSize!, _homeStartOffset!)
      ..lineTo(_homeStartOffset!, _homeStartOffset!)
      ..close();
    canvas.drawPath(blueDestination, fillPaint);
    canvas.drawPath(blueDestination, _strokePaint);
  }

  void _drawSteps(Canvas canvas) {
    double verticalOffset;

    var arrowPaint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int homeIndex = 0; homeIndex < 4; homeIndex++) {
      verticalOffset = _homeSize!;
      switch (homeIndex) {
        case 0:
          fillPaint.color = AppColors.home1;
          break;
        case 1:
          fillPaint.color = AppColors.home2;
          break;
        case 2:
          fillPaint.color = AppColors.home3;
          break;
        default:
          fillPaint.color = AppColors.home4;
          break;
      }

      for (int pos = 0; pos < 6; pos++) {
        var unit = Rect.fromLTWH(
            pos * _stepSize!, verticalOffset, _stepSize!, _stepSize!);

        if (pos == 1) {
          canvas.drawRect(unit, fillPaint);
        } else {
          canvas.drawRect(unit, whiteArea);
        }

        canvas.drawRect(unit, _strokePaint);
      }

      verticalOffset += _stepSize!;
      for (int pos = 0; pos < 6; pos++) {
        var unit = Rect.fromLTWH(
            pos * _stepSize!, verticalOffset, _stepSize!, _stepSize!);

        if (pos > 0) {
          canvas.drawRect(unit, fillPaint);
        } else {
          var arrowPadding = unit.width / 4;
          var arrowWingGap = arrowPadding / 1.5;
          var arrowTip =
              Offset(unit.right - arrowPadding, unit.bottom - unit.height / 2);
          arrowPaint.color = fillPaint.color;
          canvas.drawRect(unit, whiteArea);
          canvas.drawPath(
              Path()
                ..moveTo(unit.left + arrowPadding, arrowTip.dy)
                ..lineTo(arrowTip.dx, arrowTip.dy)
                ..lineTo(arrowTip.dx - arrowWingGap, arrowTip.dy - arrowWingGap)
                ..moveTo(arrowTip.dx - arrowWingGap, arrowTip.dy + arrowWingGap)
                ..lineTo(arrowTip.dx, arrowTip.dy),
              arrowPaint);
        }

        canvas.drawRect(unit, _strokePaint);
      }

      verticalOffset += _stepSize!;
      for (int pos = 0; pos < 6; pos++) {
        var unit = Rect.fromLTWH(
            pos * _stepSize!, verticalOffset, _stepSize!, _stepSize!);

        if (pos == 2) {
          var safeSpotRadius = _stepSize! / 4;
          fillPaint.color = AppColors.safeSpot;
          canvas.drawCircle(unit.center, safeSpotRadius, fillPaint);
          canvas.drawCircle(unit.center, safeSpotRadius, _strokePaint);
        }
        canvas.drawRect(unit, whiteArea);
        canvas.drawRect(unit, _strokePaint);
      }

      canvas.translate(_canvasCenter!, _canvasCenter!);
      canvas.rotate(pi / 2);
      canvas.translate(-_canvasCenter!, -_canvasCenter!);
    }
  }
}

class Spawn extends CircleComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    paint = Paint()..color = Colors.green;
    size = Vector2(40, 40);
  }
}

class DicePaint extends PositionComponent {
  double? _stepSize, _homeStartOffset, _homeSize, _canvasCenter;

  late double screenWidth, screenHeight, centerX, centerY;
  final int _number;

  DicePaint(this._number);

  @override
  void render(Canvas canvas) {
    paint(canvas);

    // _calculatePlayerTracks();
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    screenWidth = MediaQueryData.fromWindow(window).size.width;
    screenHeight = MediaQueryData.fromWindow(window).size.height;
    _stepSize = screenWidth / 15;
    _homeStartOffset = _stepSize! * 9;
    _homeSize = _stepSize! * 6;
    _canvasCenter = screenWidth / 2;
  }

  void paint(
    Canvas canvas,
  ) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, screenWidth / 20, screenHeight / 20),
            const Radius.circular(5)),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5);

    var dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    var centerComponent = screenWidth / 40;
    var semiCenterComponent = screenWidth / 70;
    var semiComponent = screenWidth - screenWidth / 70;

    switch (_number) {
      case 1:
        canvas.drawCircle(Offset(centerComponent, centerComponent),
            screenWidth / 160, dotPaint);
        break;
      case 2:
        var radius = screenWidth / 200;
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiComponent), radius, dotPaint);
        break;
      case 3:
        var radius = screenWidth / 240;
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(centerComponent, centerComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiComponent), radius, dotPaint);
        break;
      case 4:
        var radius = screenWidth / 200;
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, semiComponent), radius, dotPaint);
        break;
      case 5:
        print(_number);
        var radius = screenWidth / 240;
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, semiComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(centerComponent, centerComponent), radius, dotPaint);
        break;
      case 6:
        print(_number);
        var radius = screenWidth / 300;
        canvas.drawCircle(
            Offset(semiComponent, centerComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, centerComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, semiComponent), radius, dotPaint);
        break;
      default:
    }
  }

  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
