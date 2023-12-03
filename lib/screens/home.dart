import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/clock_rain_game.dart';
import '../game/game_side.dart';
import '../services/pref_providers.dart';
import 'clock_rain_screen.dart';
import 'game_mirror.dart';

/// Since all the falling widgets are the same, we can place an invisible one on the screen,
/// then use this key to obtain the `currentContext`, in turn the size of the widget.
/// So tha we can match the size of the [FallingWidget] and [FallingBody].
final measureSecondsKey = GlobalKey();
final measureMinutesKey = GlobalKey();
final measureHoursKey = GlobalKey();

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final _speed = 100 / 1000; // 100 ms
  var myGame = GameSide();

  final clockRainGame = ClockRainGame();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hourTextStyle = Theme.of(context).textTheme.displayLarge;
    final minuteTextStyle = Theme.of(context).textTheme.headlineLarge;
    final secondTextStyle = Theme.of(context).textTheme.labelLarge;
    const op = 0.0;

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
        ],
      ),
      body: Stack(
        children: [
          // Place at the bottom layer just to measure the size of the widget.
          Opacity(
            key: measureHoursKey,
            opacity: op,
            child: FallingText(
              '03',
              style: hourTextStyle,
            ),
          ),
          Opacity(
            key: measureMinutesKey,
            opacity: op,
            child: FallingText(
              '02',
              style: minuteTextStyle,
            ),
          ),
          Opacity(
            key: measureSecondsKey,
            opacity: op,
            child: FallingText(
              '01',
              style: secondTextStyle,
            ),
          ),
          // GameWidget<GameSide>(
          //   game: myGame,
          //   overlayBuilderMap: {
          //     'falling_screen': (context, game) => GameMirror(game: game),
          //   },
          //   initialActiveOverlays: const ['falling_screen'],
          // ),
          GameWidget<ClockRainGame>(
            game: clockRainGame,
            overlayBuilderMap: {
              'clockRainScreen': (context, game) => ClockRainScreen(game: game),
            },
            initialActiveOverlays: const ['clockRainScreen'],
          ),
        ],
      ),
    );
  }
}
