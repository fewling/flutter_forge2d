import 'dart:async';
import 'dart:math';

import 'package:flame_forge2d/flame_forge2d.dart' hide Transform, Timer;
import 'package:flutter/material.dart';

import '../screens/home.dart';

class GameSide extends Forge2DGame {
  GameSide() : super(gravity: Vector2(0, 50.0));

  late Timer _timer;
  var elapsedSeconds = 0;
  var elapsedMinutes = 0;

  final secBodies = <FallingBody>[];
  final minBodies = <FallingBody>[];
  final permeableBodies = <FallingBody>[];

  @override
  void onAttach() {
    super.onAttach();
    final x = size.x / 2;
    _timer = _initTimer(x: x);
  }

  @override
  void onDetach() {
    _timer.cancel();
    super.onDetach();
  }

  @override
  Future<void> onLoad() async {
    final boundaries = createBoundaries(this);
    addAll(boundaries);
  }

  List<Wall> createBoundaries(Forge2DGame game) {
    final topLeft = Vector2.zero() - Vector2(0, 100);
    final bottomRight = game.screenToWorld(game.camera.viewport.effectiveSize);
    final topRight = Vector2(bottomRight.x, topLeft.y);
    final bottomLeft = Vector2(topLeft.x, bottomRight.y);

    return [
      // Wall(topLeft, topRight),
      Wall(topRight, bottomRight),
      Wall(bottomRight, bottomLeft),
      Wall(bottomLeft, topLeft),
    ];
  }

  @override
  void update(double dt) {
    super.update(dt);
    permeableBodies
        .where((element) => element.body.position.y > size.y)
        .forEach((element) {
      element.removeFromParent();
    });
    permeableBodies.removeWhere((b) => b.body.position.y > size.y);
  }

  Timer _initTimer({
    required double x,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return Timer.periodic(
      duration,
      (timer) async {
        elapsedSeconds += 1;

        if (elapsedSeconds > 59) {
          // 1. reset all `seconds` related stuff.
          elapsedSeconds = 0;

          for (final b in secBodies) {
            final pb = FallingBody(
              b.body.position,
              b.hx,
              b.hy,
              msg: b.msg,
              type: b.type,
              permeable: true,
            );
            permeableBodies.add(pb);
            add(pb);
            b.removeFromParent();
          }
          secBodies.clear();

          // 2. update the `minutes` related stuff.
          elapsedMinutes += 1;

          if (minBodies.length > 5) {
            final b = minBodies.removeAt(0);
            final pb = FallingBody(b.body.position, b.hx, b.hy,
                msg: b.msg, type: b.type, permeable: true);
            b.removeFromParent();

            permeableBodies.add(pb);
            add(pb);
          }

          final renderObj =
              measureMinutesKey.currentContext?.findRenderObject();
          final syze = renderObj?.semanticBounds.size ?? Size.zero;
          final scale = screenToWorld(Vector2(syze.width / 2, syze.height / 2));
          // final x = Random().nextDouble() * size.x;
          final msg = elapsedMinutes.toString().padLeft(2, '0');

          final body = FallingBody(
            Vector2(x, -5),
            scale.x,
            scale.y,
            msg: msg,
            type: FallingBodyType.minutes,
          );
          add(body);
          minBodies.add(body);
        } else {
          final renderObj =
              measureSecondsKey.currentContext?.findRenderObject();
          final syze = renderObj?.semanticBounds.size ?? Size.zero;
          final scale = screenToWorld(Vector2(syze.width / 2, syze.height / 2));
          // final x = Random().nextDouble() * size.x;
          final msg = elapsedSeconds.toString().padLeft(2, '0');

          final body = FallingBody(
            Vector2(x, -5),
            scale.x,
            scale.y,
            msg: msg,
            type: FallingBodyType.seconds,
          );
          add(body);
          secBodies.add(body);
        }
      },
    );
  }

  void resetTimer(Duration duration) {
    _timer.cancel();
    _timer = _initTimer(x: size.x / 2, duration: duration);
  }

  void cancelTimer() => _timer.cancel();

  void reset() {
    elapsedSeconds = 0;
    elapsedMinutes = 0;
    for (var element in secBodies) {
      element.removeFromParent();
    }
    for (var element in minBodies) {
      element.removeFromParent();
    }
    for (var element in permeableBodies) {
      element.removeFromParent();
    }
    secBodies.clear();
    minBodies.clear();
    permeableBodies.clear();
    resetTimer(const Duration(milliseconds: 100));
  }
}

class Wall extends BodyComponent {
  final Vector2 start;
  final Vector2 end;

  Wall(this.start, this.end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);
    final fixtureDef = FixtureDef(
      shape,
      friction: 0.3,
      filter: Filter()..groupIndex = -1,
    );
    final bodyDef = BodyDef(
      userData: this, // To be able to determine object in collision
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

enum FallingBodyType {
  seconds,
  minutes,
}

class FallingBody extends BodyComponent {
  final Vector2 _position;
  final double hx;
  final double hy;
  final String msg;
  final FallingBodyType type;
  final bool permeable;

  FallingBody(
    this._position,
    this.hx,
    this.hy, {
    required this.msg,
    required this.type,
    this.permeable = false,
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      angularVelocity: Random().nextDouble() * 6 - 3,
      position: _position,
      type: BodyType.dynamic,
    );
    final body = world.createBody(bodyDef);

    Shape shape = PolygonShape()..setAsBoxXY(hx, hy);
    // final shape = CircleShape()..radius = hx;
    // if (type == FallingBodyType.minutes) {
    //   shape = CircleShape()..radius = hx;
    // }
    final fixtureDef = FixtureDef(
      shape,
      density: type == FallingBodyType.seconds ? 1 : 5,
      restitution: 0.5,
      friction: 0.5,
      filter: Filter()..groupIndex = permeable ? -1 : 0,
    );
    body.createFixture(fixtureDef);
    renderBody = false;
    // body.setMassData(
    //     MassData()..mass = type == FallingBodyType.seconds ? 0.1 : 1);
    return body;
  }

  @override
  void onRemove() {
    world.destroyBody(body);
    super.onRemove();
  }
}
