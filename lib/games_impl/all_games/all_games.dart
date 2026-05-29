import ‘package:flutter/material.dart’;
import ‘game_1/game1.dart’;
import ‘game_2/game2.dart’;
import ‘game_3/game3.dart’;
import ‘game_4/game4.dart’;

class Game {
  final String title;
  final IconData icon;
  final WidgetBuilder builder;

  Game({
    required this.title,
    required this.icon,
    required this.builder,
  });
}

/// List consumed by the home grid.
final List<Game> games = [
  Game(
    title: 'Pac-Man Adventures',
    icon: Icons.sports_esports,
    builder: (ctx) => const Game1Page(),
  ),
  Game(
    title: 'Stick Runner',
    icon: Icons.casino,
    builder: (ctx) => const Game2Page(),
  ),
  Game(
    title: 'Snakes',
    icon: Icons.directions_run,
    builder: (ctx) => const Game3Page(),
  ),
  Game(
    title: 'Tetris',
    icon: Icons.memory,
    builder: (ctx) => const Game4Page(),
  ),
  // Game(
  //   title: 'Game 5',
  //   icon: Icons.public,
  //   builder: (ctx) => const Game5Page(),
  // ),
  // ─────────────── Reserved for future games ───────────────
  // Game(
  //   title: 'Game 6',
  //   icon: Icons.flight_takeoff,
  //   builder: (ctx) => const Game6Page(),
  // ),
  // Game(
  //   title: 'Game 7',
  //   icon: Icons.pets,
  //   builder: (ctx) => const Game7Page(),
  // ),
  // Game(
  //   title: 'Game 8',
  //   icon: Icons.palette,
  //   builder: (ctx) => const Game8Page(),
  // ),
  // Game(
  //   title: 'Game 9',
  //   icon: Icons.music_note,
  //   builder: (ctx) => const Game9Page(),
  // ),
  // Game(
  //   title: 'Game 10',
  //   icon: Icons.star,
  //   builder: (ctx) => const Game10Page(),
  // ),
];
