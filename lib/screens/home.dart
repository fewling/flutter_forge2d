import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_side.dart';
import '../services/pref_providers.dart';
import 'game_mirror.dart';

/// Since all the falling widgets are the same, we can place an invisible one on the screen,
/// then use this key to obtain the `currentContext`, in turn the size of the widget.
/// So tha we can match the size of the [FallingWidget] and [FallingBody].
final measureSecondsKey = GlobalKey();
final measureMinutesKey = GlobalKey();

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  var myGame = GameSide();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayLarge = Theme.of(context).textTheme.displayLarge;
    final titleLarge = Theme.of(context).textTheme.titleLarge;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playground - Stopwatch x Forge2D'),
        foregroundColor: colorScheme.onPrimaryContainer,
        actions: [
          Tooltip(
            message: 'Change color (random)',
            child: IconButton(
              onPressed: () {
                ref.read(colorProvider.notifier).state =
                    Colors.primaries[Random().nextInt(Colors.primaries.length)];
              },
              icon: const Icon(Icons.colorize_sharp),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Restart',
            child: IconButton(
              onPressed: () {
                setState(() {
                  myGame.secondsTimer.cancel();
                  myGame = GameSide();
                });
              },
              icon: const Icon(Icons.restart_alt_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Place at the bottom layer just to measure the size of the widget.
          Opacity(
            key: measureSecondsKey,
            opacity: 0.0,
            child: FallingText(
              '01',
              style: titleLarge,
            ),
          ),
          Opacity(
            key: measureMinutesKey,
            opacity: 0.0,
            child: FallingText(
              '01',
              style: displayLarge,
            ),
          ),
          GameWidget<GameSide>(
            game: myGame,
            overlayBuilderMap: {
              'falling_screen': (context, game) => GameMirror(game: game),
            },
            initialActiveOverlays: const ['falling_screen'],
          ),
        ],
      ),
    );
  }
}
