import 'package:flame_forge2d/flame_forge2d.dart' hide Transform;
import 'package:flutter/material.dart';
import 'package:flutter_forge2d/common/ticking_builder.dart';
import 'package:flutter_forge2d/game/clock_rain_game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_mirror.dart';
import 'home.dart';

class ClockRainScreen extends ConsumerWidget {
  const ClockRainScreen({
    super.key,
    required this.game,
  });

  final ClockRainGame game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hourTextStyle = Theme.of(context).textTheme.displayLarge;
    final minuteTextStyle = Theme.of(context).textTheme.headlineLarge;
    final secondTextStyle = Theme.of(context).textTheme.labelLarge;

    return Scaffold(
      body: TickingBuilder(builder: (context, time) {
        final secBodies = game.secondBodies;
        final minBodies = game.minuteBodies;
        final hourBodies = game.hourBodies;

        return Stack(
          children: [
            for (final body in secBodies)
              _buildBodyWidget(body, secondTextStyle),
            for (final body in minBodies)
              _buildBodyWidget(body, minuteTextStyle),
            for (final body in hourBodies)
              _buildBodyWidget(body, hourTextStyle),
          ],
        );
      }),
    );
  }

  Widget _buildBodyWidget(ClockFallingBody body, TextStyle? textStyle) {
    final renderObj = switch (body.type) {
      FallingBodyType.seconds =>
        measureSecondsKey.currentContext?.findRenderObject(),
      FallingBodyType.minutes =>
        measureMinutesKey.currentContext?.findRenderObject(),
      FallingBodyType.hour =>
        measureHoursKey.currentContext?.findRenderObject(),
    };
    final syze = renderObj?.semanticBounds.size ?? Size.zero;
    final offset = game.screenToWorld(Vector2(syze.width / 2, syze.height / 2));
    final pos = game.worldToScreen(body.body.worldCenter - offset);
    final msg = switch (body.type) {
      FallingBodyType.seconds => body.time.second,
      FallingBodyType.minutes => body.time.minute,
      FallingBodyType.hour => body.time.hour,
    };

    return ClockFallingWidget(
      left: pos.x,
      top: pos.y,
      angle: body.angle,
      msg: msg.toString(),
      style: textStyle,
    );
  }
}

class ClockFallingWidget extends StatelessWidget {
  final double left;
  final double top;
  final double angle;

  /// If [child] is null, then [msg] will be used to create a [FallingText] widget.
  /// Otherwise, this will be ignored.
  final String? msg;
  final TextStyle? style;
  final Widget? child;
  final ShapeBorder? shape;

  const ClockFallingWidget({
    Key? key,
    required this.left,
    required this.top,
    required this.angle,
    this.msg,
    this.child,
    this.style,
    this.shape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: angle,
        child: child ??
            FallingText(
              msg ?? '',
              style: style,
              shape: shape,
            ),
      ),
    );
  }
}
