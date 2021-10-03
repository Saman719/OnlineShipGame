import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_hidden_ship_game/models/enemy.dart';
import 'package:online_hidden_ship_game/utils/game_engine.dart';

class FirebaseService {
  GameManager gameManager;
  FirebaseService(this.gameManager);
  late StreamSubscription subscribtion;

  void initGame() {
    FirebaseFirestore.instance.collection('match-info').doc('match-1').set({
      'enemy-number': gameManager.enemyNumber,
      'field-size': gameManager.fieldSize,
      'host-turn': gameManager.hostTurn,
      'winner': gameManager.winner
    });
    for (int i = 0; i < gameManager.enemyNumber; i++) {
      FirebaseFirestore.instance
          .collection('match-info')
          .doc('guest-${i + 1}')
          .set({
        'xPositions': gameManager.enemies[i].xPositions,
        'yPositions': gameManager.enemies[i].yPositions,
        'xPositionsHit': gameManager.enemies[i].xPositionsHit,
        'yPositionsHit': gameManager.enemies[i].yPositionsHit,
      });
      FirebaseFirestore.instance
          .collection('match-info')
          .doc('host-${i + 1}')
          .set({
        'xPositions': gameManager.allies[i].xPositions,
        'yPositions': gameManager.allies[i].yPositions,
        'xPositionsHit': gameManager.allies[i].xPositionsHit,
        'yPositionsHit': gameManager.allies[i].yPositionsHit,
      });
    }
  }

  void putData() {
    FirebaseFirestore.instance.collection('match-info').doc('match-1').update(
        {'host-turn': gameManager.hostTurn, 'winner': gameManager.winner});
    for (int i = 0; i < gameManager.enemyNumber; i++) {
      if (gameManager.player == Player.host) {
        FirebaseFirestore.instance
            .collection('match-info')
            .doc('guest-${i + 1}')
            .update({
          'xPositionsHit': gameManager.enemies[i].xPositionsHit,
          'yPositionsHit': gameManager.enemies[i].yPositionsHit,
        });
      } else {
        FirebaseFirestore.instance
            .collection('match-info')
            .doc('host-${i + 1}')
            .update({
          'xPositionsHit': gameManager.enemies[i].xPositionsHit,
          'yPositionsHit': gameManager.enemies[i].yPositionsHit,
        });
      }
    }
  }

  void addlistener() {
    String doc1 = gameManager.player == Player.host ? 'guest' : 'host';
    String doc2 = gameManager.player == Player.host ? 'host' : 'guest';
    subscribtion = FirebaseFirestore.instance
        .collection('match-info')
        .snapshots(includeMetadataChanges: true)
        .listen((event) {
      FirebaseFirestore.instance
          .collection('match-info')
          .doc('match-1')
          .get()
          .then((value) => gameManager.hostTurn = value.data()!['host-turn']);
      for (int i = 0; i < gameManager.enemyNumber; i++) {
        FirebaseFirestore.instance
            .collection('match-info')
            .doc('$doc1-${i + 1}')
            .get()
            .then((value) {
          var map = value.data();
          gameManager.enemies[i].xPositions = List.from(map!['xPositions']);
          gameManager.enemies[i].yPositions = List.from(map['yPositions']);
          gameManager.enemies[i].xPositionsHit =
              List.from(map['xPositionsHit']);
          gameManager.enemies[i].yPositionsHit =
              List.from(map['yPositionsHit']);
          gameManager.notify();
        });
      }
      for (int i = 0; i < gameManager.enemyNumber; i++) {
        FirebaseFirestore.instance
            .collection('match-info')
            .doc('$doc2-${i + 1}')
            .get()
            .then((value) {
          var map = value.data();
          gameManager.allies[i].xPositions = List.from(map!['xPositions']);
          gameManager.allies[i].yPositions = List.from(map['yPositions']);
          gameManager.allies[i].xPositionsHit = List.from(map['xPositionsHit']);
          gameManager.allies[i].yPositionsHit = List.from(map['yPositionsHit']);
          gameManager.notify();
        });
      }
    });
  }

  void initForGuest() async {
    await FirebaseFirestore.instance
        .collection('match-info')
        .doc('match-1')
        .get()
        .then((value) async {
      var map = value.data();
      gameManager.fieldSize = map!['field-size'];
      gameManager.enemyNumber = map['enemy-number'];
      gameManager.hostTurn = map['host-turn'];
      gameManager.winner = map['winner'];
    });
    for (int i = 0; i < gameManager.enemyNumber; i++) {
      var doc = await FirebaseFirestore.instance
          .collection('match-info')
          .doc('host-${i + 1}')
          .get();
      var map = doc.data();
      var xPositions = List<int>.from(map!['xPositions']);
      var yPositions = List<int>.from(map['yPositions']);
      var xPositionsHit = List<int>.from(map['xPositionsHit']);
      var yPositionsHit = List<int>.from(map['yPositionsHit']);
      Color? color;
      if (i == 0) {
        color = Colors.blue[300];
      } else if (i == 1) {
        color = Colors.orange[300];
      } else if (i == 2) {
        color = Colors.red;
      } else if (i == 3) {
        color = Colors.green;
      } else {
        color = Color.fromRGBO(100, Random().nextInt(255), (i * 999) % 256, 1);
      }
      gameManager.enemies.add(Enemy.Guest(
          color: color,
          xPositions: xPositions,
          yPositions: yPositions,
          xPositionsHit: xPositionsHit,
          yPositionsHit: yPositionsHit));
    }
    for (int i = 0; i < gameManager.enemyNumber; i++) {
      var doc = await FirebaseFirestore.instance
          .collection('match-info')
          .doc('guest-${i + 1}')
          .get();
      var map = doc.data();
      var xPositions = List<int>.from(map!['xPositions']);
      var yPositions = List<int>.from(map['yPositions']);
      var xPositionsHit = List<int>.from(map['xPositionsHit']);
      var yPositionsHit = List<int>.from(map['yPositionsHit']);
      Color? color;
      if (i == 0) {
        color = Colors.blue[300];
      } else if (i == 1) {
        color = Colors.orange[300];
      } else if (i == 2) {
        color = Colors.red;
      } else if (i == 3) {
        color = Colors.green;
      } else {
        color = Color.fromRGBO(
            100, Random(i * 17).nextInt(255), (i * 999) % 256, 1);
      }
      gameManager.allies.add(Enemy.Guest(
          color: color,
          xPositions: xPositions,
          yPositions: yPositions,
          xPositionsHit: xPositionsHit,
          yPositionsHit: yPositionsHit));
    }
    gameManager.notify();
  }

  void stopListening() {
    subscribtion.cancel();
  }
}
