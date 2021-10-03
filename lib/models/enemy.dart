import 'package:flutter/material.dart';

class Enemy {
  int xPosition;
  int yPosition;
  late List<int> xPositions;
  late List<int> yPositions;
  int length;
  bool vertical;
  Color? color;
  late List<int> xPositionsHit;
  late List<int> yPositionsHit;

  Enemy(
      {required this.xPosition,
      required this.yPosition,
      required this.length,
      required this.vertical,
      this.color}) {
    xPositions = List.empty(growable: true);
    yPositions = List.empty(growable: true);
    xPositionsHit = List.empty(growable: true);
    yPositionsHit = List.empty(growable: true);
  }

  Enemy.Guest(
      {this.xPosition = 0,
      this.yPosition = 0,
      this.length = 0,
      this.vertical = true,
      this.color,
      required this.xPositions,
      required this.yPositions,
      required this.xPositionsHit,
      required this.yPositionsHit});

  @override
  String toString() {
    return 'x : $xPositions, y : $yPositions';
  }
}
