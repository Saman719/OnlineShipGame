import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:online_hidden_ship_game/cloud_functions/firebase.dart';
import 'package:online_hidden_ship_game/models/enemy.dart';

class GameManager extends ChangeNotifier {
  late int fieldSize;
  late int enemyNumber;
  late List<Enemy> enemies;
  late List<Enemy> allies;
  late String winner = 'NULL';
  late bool hostTurn;
  late FirebaseService _firebaseService;
  late Player player;

  GameManager({this.fieldSize = 5, this.enemyNumber = 4}) {
    hostTurn = true;
    player = Player.host;
    _firebaseService = FirebaseService(this);
    enemies = List.empty(growable: true);
    allies = List.empty(growable: true);
    generateRandomEnemy(allies, true);
    generateRandomEnemy(enemies, false);
    initFirebaseForHost();
  }

  GameManager.guest() {
    hostTurn = true;
    player = Player.guest;
    fieldSize = 0;
    enemyNumber = 0;
    _firebaseService = FirebaseService(this);
    enemies = List.empty(growable: true);
    allies = List.empty(growable: true);
    initFirebaseForGuest();
  }

  void initFirebaseForHost() async {
    _firebaseService.initGame();
    _firebaseService.putData();
    _firebaseService.addlistener();
  }

  void initFirebaseForGuest() {
    _firebaseService.initForGuest();
    _firebaseService.addlistener();
  }

  Future<void> attack(int x, int y, bool ally) async {
    List<Enemy> enemyOrAlly = ally ? allies : enemies;
    enemyOrAlly.forEach((enemy) {
      bool hitX = false;
      bool hitY = false;
      enemy.xPositions.forEach((element) {
        if (x == element) {
          hitX = true;
        }
      });
      enemy.yPositions.forEach((element) {
        if (y == element) {
          hitY = true;
        }
      });
      if (hitX && hitY) {
        enemy.xPositionsHit.add(x);
        enemy.yPositionsHit.add(y);
      }
    });
    hostTurn = !hostTurn;
    _firebaseService.putData();
    notifyListeners();
  }

  //this function randomly generate elements in the game
  void generateRandomEnemy(List<Enemy> enemies, bool ally) {
    for (int i = 1; i < enemyNumber + 1; i++) {
      bool vertical = Random().nextBool();
      int xPosition = Random().nextInt(fieldSize);
      int yPosition = Random().nextInt(fieldSize);
      int length = i;
      Enemy generatedEnemy = Enemy(
          xPosition: xPosition,
          yPosition: yPosition,
          length: length,
          vertical: vertical);
      if (!_isGeneratedEnemyInRightPlace(generatedEnemy, ally)) {
        i--;
        continue;
      }
      for (var j = 0; j < generatedEnemy.length; j++) {
        if (generatedEnemy.vertical) {
          generatedEnemy.xPositions.add(generatedEnemy.xPosition);
          generatedEnemy.yPositions.add(generatedEnemy.yPosition + j);
        } else {
          generatedEnemy.xPositions.add(generatedEnemy.xPosition + j);
          generatedEnemy.yPositions.add(generatedEnemy.yPosition);
        }
      }
      Color? color;
      if (i == 1) {
        color = Colors.blue[300];
      } else if (i == 2) {
        color = Colors.orange[300];
      } else if (i == 3) {
        color = Colors.red;
      } else if (i == 4) {
        color = Colors.green;
      } else {
        color = Color.fromRGBO(100, Random().nextInt(255), (i * 999) % 256, 1);
      }
      generatedEnemy.color = color;
      enemies.add(generatedEnemy);
    }
  }

  bool _isGeneratedEnemyInRightPlace(Enemy generatedEnemy, bool ally) {
    List<Enemy> enemyOrAlly = ally ? allies : enemies;
    if (generatedEnemy.vertical == true &&
            generatedEnemy.yPosition + (generatedEnemy.length - 1) >=
                fieldSize ||
        generatedEnemy.vertical == false &&
            generatedEnemy.xPosition + (generatedEnemy.length - 1) >=
                fieldSize) {
      return false;
    }
    for (Enemy enemy in enemyOrAlly) {
      List<int> enemyX = List.empty(growable: true);
      List<int> enemyY = List.empty(growable: true);
      List<int> generatedEnemyX = List.empty(growable: true);
      List<int> generatedEnemyY = List.empty(growable: true);
      if (enemy.vertical) {
        for (int i = 0; i < enemy.length; i++) {
          enemyX.add(enemy.xPosition);
          enemyY.add(enemy.yPosition + i);
        }
      } else {
        for (int i = 0; i < enemy.length; i++) {
          enemyX.add(enemy.xPosition + i);
          enemyY.add(enemy.yPosition);
        }
      }
      if (generatedEnemy.vertical) {
        for (int i = 0; i < generatedEnemy.length; i++) {
          generatedEnemyX.add(generatedEnemy.xPosition);
          generatedEnemyY.add(generatedEnemy.yPosition + i);
        }
      } else {
        for (int i = 0; i < generatedEnemy.length; i++) {
          generatedEnemyX.add(generatedEnemy.xPosition + i);
          generatedEnemyY.add(generatedEnemy.yPosition);
        }
      }
      for (var i = 0; i < enemy.length; i++) {
        for (var j = 0; j < generatedEnemy.length; j++) {
          if (enemyX[i] == generatedEnemyX[j] &&
              enemyY[i] == generatedEnemyY[j]) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void notify() {
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _firebaseService.stopListening();
  }
}

enum Player { host, guest }
