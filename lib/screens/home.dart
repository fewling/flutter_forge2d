import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/clock_rain_game.dart';
import '../services/preference_provider.dart';
import 'clock_rain_screen.dart';

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
  final clockRainGame = ClockRainGame();

  @override
  Widget build(BuildContext context) {
    final hourTextStyle = Theme.of(context).textTheme.displayLarge;
    final minuteTextStyle = Theme.of(context).textTheme.headlineLarge;
    final secondTextStyle = Theme.of(context).textTheme.labelLarge;
    const op = 0.0;

    final isDarkMode = ref.watch(appPreferenceProvider).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: isDarkMode ? 'Light mode' : 'Dark mode',
            onPressed: () {
              ref.read(appPreferenceProvider.notifier).toggleBrightness();
            },
            icon: isDarkMode
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
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
            child: ClockFallingTextWidget(
              '03',
              style: hourTextStyle,
            ),
          ),
          Opacity(
            key: measureMinutesKey,
            opacity: op,
            child: ClockFallingTextWidget(
              '02',
              style: minuteTextStyle,
            ),
          ),
          Opacity(
            key: measureSecondsKey,
            opacity: op,
            child: ClockFallingTextWidget(
              '01',
              style: secondTextStyle,
            ),
          ),
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
