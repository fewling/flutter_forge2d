import 'dart:async';
import 'dart:math';

import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flutter/material.dart';

import '../screens/home.dart';

class ClockRainGame extends Forge2DGame {
  ClockRainGame() : super(gravity: Vector2(0, 30));
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

  Future<void> _tick() async {
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
        pos: Vector2(worldSize.x - scale.x, -scale.y),
        w: scale.x,
        h: scale.y,
        time: DateTime.now(),
        type: FallingBodyType.seconds,
        angularVelocity: -Random().nextDouble() * pi * 2,
      );
      await add(fallingBody);
      secondBodies.add(fallingBody);
    }

    if (_minute != currentMin) {
      _minute = currentMin;

      for (final fallingBody in secondBodies) {
        if (fallingBody.time.minute == currentMin) continue;
        fallingBody.shrinkRate = 0.9;
      }

      final renderObj = measureMinutesKey.currentContext?.findRenderObject();
      final syze = renderObj?.semanticBounds.size ?? Size.zero;
      final scale = screenToWorld(Vector2(syze.width / 2, syze.height / 2));

      final fallingBody = ClockFallingBody(
        pos: Vector2(worldSize.x / 2, -scale.y),
        w: scale.x,
        h: scale.y,
        time: DateTime.now(),
        type: FallingBodyType.minutes,
      );
      await add(fallingBody);
      minuteBodies.add(fallingBody);
    }

    if (_hour != currentHour) {
      _hour = currentHour;

      for (final fallingBody in minuteBodies) {
        if (fallingBody.time.hour == currentHour) continue;
        fallingBody.shrinkRate = 0.9;
      }

      for (final fallingBody in hourBodies) {
        if (fallingBody.time.hour == currentHour) continue;
        fallingBody.shrinkRate = 0.9;
      }

      final renderObj = measureHoursKey.currentContext?.findRenderObject();
      final syze = renderObj?.semanticBounds.size ?? Size.zero;
      final scale = screenToWorld(Vector2(syze.width / 2, syze.height / 2));

      final fallingBody = ClockFallingBody(
        pos: Vector2(scale.x, -scale.y),
        w: scale.x,
        h: scale.y,
        time: DateTime.now(),
        type: FallingBodyType.hour,
      );
      await add(fallingBody);
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

  @override
  void update(double dt) {
    super.update(dt);

    final allBodies = [...secondBodies, ...minuteBodies, ...hourBodies];

    for (final fallingBody in allBodies) {
      if (fallingBody.shrinkRate == 1) continue;

      fallingBody.w *= fallingBody.shrinkRate;
      fallingBody.h *= fallingBody.shrinkRate;

      for (final fixture in fallingBody.body.fixtures) {
        fixture.shape = PolygonShape()
          ..setAsBoxXY(
            fallingBody.w,
            fallingBody.h,
          );
      }
    }

    secondBodies.removeWhere((e) {
      final tooSmall = e.w < 0.1 || e.h < 0.1;
      if (tooSmall) e.removeFromParent();
      return tooSmall;
    });
    minuteBodies.removeWhere((e) {
      final tooSmall = e.w < 0.1 || e.h < 0.1;
      if (tooSmall) e.removeFromParent();
      return tooSmall;
    });
    hourBodies.removeWhere((e) {
      final tooSmall = e.w < 0.1 || e.h < 0.1;
      if (tooSmall) e.removeFromParent();
      return tooSmall;
    });
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
}

class ClockFallingBody extends BodyComponent {
  final Vector2 pos;
  final DateTime time;
  final FallingBodyType type;
  final double angularVelocity;
  double w;
  double h;
  double shrinkRate;

  ClockFallingBody({
    required this.pos,
    required this.time,
    required this.type,
    required this.w,
    required this.h,
    this.angularVelocity = 0,
    this.shrinkRate = 1,
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      angularVelocity: angularVelocity,
      position: pos,
      type: BodyType.dynamic,
    );

    final friction = type == FallingBodyType.seconds ? 0.8 : 0.3;

    final restitution = switch (type) {
      FallingBodyType.seconds => 0.3,
      FallingBodyType.minutes => 0.2,
      FallingBodyType.hour => 0.1,
    };

    final density = switch (type) {
      FallingBodyType.seconds => 1,
      FallingBodyType.minutes => 0,
      FallingBodyType.hour => 0,
    };

    final body = world.createBody(bodyDef);
    final shape = PolygonShape()..setAsBoxXY(w, h);
    final fixtureDef = FixtureDef(
      shape,
      density: density.toDouble(),
      restitution: restitution,
      friction: friction,
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
