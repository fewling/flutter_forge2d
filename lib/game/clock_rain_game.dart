import 'dart:async';
import 'dart:math';

import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flutter/material.dart';

import '../screens/home.dart';

class ClockRainGame extends Forge2DGame {
  ClockRainGame() : super(gravity: Vector2(0, 50));
  late Timer _timer;

  var _second = -1;
  var _minute = -1;
  var _hour = -1;

  final secondBodies = <ClockFallingBody>[];
  final minuteBodies = <ClockFallingBody>[];
  final hourBodies = <ClockFallingBody>[];

  @override
  Future<void> onAttach() async {
    super.onAttach();
    createBoundaries();

    final current = DateTime.now();
    final nextSec = DateTime(
      current.year,
      current.month,
      current.day,
      current.hour,
      current.minute,
      current.second + 1,
    );

    final diff = nextSec.difference(current);
    await Future.delayed(diff);

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _timer = timer;
        _tick();
      },
    );
  }

  @override
  void onRemove() {
    _timer.cancel();
    super.onRemove();
  }

  void _tick() {
    final current = DateTime.now();
    final currentSec = current.second;
    final currentMin = current.minute;
    final currentHour = current.hour;
    final worldSize = screenToWorld(camera.viewport.effectiveSize);

    if (_second != currentSec) {
      _second = currentSec;
      final renderObj = measureSecondsKey.currentContext?.findRenderObject();
      final syze = renderObj?.semanticBounds.size ?? Size.zero;
      final scale = screenToWorld(Vector2(syze.width / 2, syze.height / 2));

      final fallingBody = ClockFallingBody(
        pos: Vector2(worldSize.x - 5, -5),
        w: scale.x,
        h: scale.y,
        msg: _second.toString().padLeft(2, '0'),
        type: FallingBodyType.seconds,
        angularVelocity: Random().nextDouble() * 6,
      );
      add(fallingBody);
      secondBodies.add(fallingBody);
    }

    if (_minute != currentMin) {
      _minute = currentMin;

      final renderObj = measureMinutesKey.currentContext?.findRenderObject();
      final syze = renderObj?.semanticBounds.size ?? Size.zero;
      final scale = screenToWorld(Vector2(syze.width / 2, syze.height / 2));

      final fallingBody = ClockFallingBody(
        pos: Vector2(worldSize.x / 2, -5),
        w: scale.x,
        h: scale.y,
        msg: _minute.toString().padLeft(2, '0'),
        type: FallingBodyType.minutes,
      );
      add(fallingBody);
      minuteBodies.add(fallingBody);
    }

    if (_hour != currentHour) {
      _hour = currentHour;

      final renderObj = measureHoursKey.currentContext?.findRenderObject();
      final syze = renderObj?.semanticBounds.size ?? Size.zero;
      final scale = screenToWorld(Vector2(syze.width / 2, syze.height / 2));

      final fallingBody = ClockFallingBody(
        pos: Vector2(5, -5),
        w: scale.x,
        h: scale.y,
        msg: _hour.toString().padLeft(2, '0'),
        type: FallingBodyType.hour,
      );
      add(fallingBody);
      hourBodies.add(fallingBody);
    }
  }

  void createBoundaries() {
    final topLeft = Vector2.zero();
    final bottomRight = screenToWorld(camera.viewport.effectiveSize);
    final topRight = Vector2(bottomRight.x, topLeft.y);
    final bottomLeft = Vector2(topLeft.x, bottomRight.y);

    addAll([
      // Wall(topLeft, topRight),
      Wall(topRight, bottomRight),
      Wall(bottomRight, bottomLeft),
      Wall(bottomLeft, topLeft),
    ]);
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
  hour,
  unknown,
}

class ClockFallingBody extends BodyComponent {
  final Vector2 pos;
  final double w;
  final double h;
  final String msg;
  final FallingBodyType type;
  final double angularVelocity;

  ClockFallingBody({
    required this.pos,
    required this.msg,
    required this.type,
    required this.w,
    required this.h,
    this.angularVelocity = 0,
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      angularVelocity: angularVelocity,
      position: pos,
      type: BodyType.dynamic,
    );
    final body = world.createBody(bodyDef);
    final shape = PolygonShape()..setAsBoxXY(w, h);
    final fixtureDef = FixtureDef(
      shape,
      density: type == FallingBodyType.seconds ? 10 : 50,
      restitution: 0.5,
      friction: 0.5,
    );
    body.createFixture(fixtureDef);
    renderBody = true;
    return body;
  }

  @override
  void onRemove() {
    world.destroyBody(body);
    super.onRemove();
  }
}
