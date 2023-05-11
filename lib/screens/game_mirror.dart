import 'package:flame_forge2d/flame_forge2d.dart' hide Transform;
import 'package:flutter/material.dart';
import 'package:flutter_forge2d/common/ticking_builder.dart';

import '../game/game_side.dart';
import 'home.dart';

class GameMirror extends StatelessWidget {
  const GameMirror({super.key, required this.game});

  final GameSide game;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayLarge = Theme.of(context).textTheme.displayLarge;
    final titleLarge = Theme.of(context).textTheme.titleLarge;

    final secRenderObj = measureSecondsKey.currentContext?.findRenderObject();
    final minRenderObj = measureMinutesKey.currentContext?.findRenderObject();

    final secSize = secRenderObj?.semanticBounds.size ?? Size.zero;
    final minSyze = minRenderObj?.semanticBounds.size ?? Size.zero;

    return Scaffold(
      body: TickingBuilder(
        builder: (context, child) {
          final secOffset = game
              .screenToWorld(Vector2(secSize.width / 2, secSize.height / 2));
          final minOffset = game
              .screenToWorld(Vector2(minSyze.width / 2, minSyze.height / 2));

          return Stack(
            children: [
              ...game.minBodies.map((minBody) {
                final b = minBody.body;
                final pos = game.worldToScreen(b.worldCenter - minOffset);
                return FallingWidget(
                  left: pos.x,
                  top: pos.y,
                  angle: b.angle,
                  msg: minBody.msg,
                  style: displayLarge,
                  // shape: const CircleBorder(),
                );
              }),
              ...game.secBodies.map((secBody) {
                final b = secBody.body;
                final pos = game.worldToScreen(b.worldCenter - secOffset);

                return FallingWidget(
                  left: pos.x,
                  top: pos.y,
                  angle: b.angle,
                  msg: secBody.msg,
                  style: titleLarge,
                );
              }),
              ...game.permeableBodies.map((permeableBody) {
                final b = permeableBody.body;
                final pos = game.worldToScreen(b.worldCenter - secOffset);

                return FallingWidget(
                  left: pos.x,
                  top: pos.y,
                  angle: b.angle,
                  msg: '',
                  style: titleLarge,
                  child: Card(
                    color: colorScheme.background,
                    child: SizedBox(
                      width: permeableBody.type == FallingBodyType.seconds
                          ? secSize.width
                          : minSyze.width,
                      height: permeableBody.type == FallingBodyType.seconds
                          ? secSize.height
                          : minSyze.height,
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class FallingWidget extends StatelessWidget {
  final double left;
  final double top;
  final double angle;

  /// If [child] is null, then [msg] will be used to create a [FallingText] widget.
  /// Otherwise, this will be ignored.
  final String? msg;
  final TextStyle? style;
  final Widget? child;
  final ShapeBorder? shape;

  const FallingWidget({
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
        child: child ?? FallingText(msg ?? '', style: style, shape: shape),
      ),
    );
  }
}

class FallingText extends StatelessWidget {
  const FallingText(this.msg, {super.key, this.style, this.shape});

  final String msg;
  final TextStyle? style;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: CardTheme.of(context).copyWith(
          margin: EdgeInsets.zero,
        ),
      ),
      child: Card(
        shape: shape,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(msg, style: style),
          ),
        ),
      ),
    );
  }
}
