import 'package:flutter/material.dart';
import 'package:online_hidden_ship_game/models/enemy.dart';
import 'package:online_hidden_ship_game/utils/game_engine.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (_, gameManager, __) {
        String title;
        if (gameManager.hostTurn && gameManager.player == Player.guest ||
            !gameManager.hostTurn && gameManager.player == Player.host) {
          title = 'Opponet Turn';
        } else {
          title = 'Your Turn';
        }

        String turn = gameManager.hostTurn ? 'host' : 'guest';
        return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(title),
            ),
            body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(children: [
                  GameSurface(
                    true,
                    color: Colors.grey[300],
                  ),
                  const Flexible(
                    flex: 1,
                    child: Divider(),
                  ),
                  GameSurface(false, color: Colors.grey[300])
                ])));
      },
    );
  }
}

class GameSurface extends StatelessWidget {
  const GameSurface(this.ally, {Key? key, required this.color})
      : super(key: key);

  final Color? color;
  final bool ally;

  List<Widget> _buildGameTiles(GameManager gameManager) {
    List<Widget> gameTiles = [];
    List<Enemy> enemeyOrAlly = ally ? gameManager.allies : gameManager.enemies;
    for (int i = 0; i < gameManager.fieldSize; i++) {
      List<Widget> rowContent = [];
      for (int j = 0; j < gameManager.fieldSize; j++) {
        Color? color = Colors.grey[500];
        Icon? icon;
        Function()? function = ally
            ? null
            : () {
                gameManager.attack(j, i, ally);
              };
        bool hit = false;
        enemeyOrAlly.forEach((enemy) {
          bool xFound = false;
          bool yFound = false;
          bool xHitFound = false;
          bool yHitFound = false;
          enemy.xPositions.forEach((element) {
            if (element == j) {
              xFound = true;
            }
          });
          enemy.yPositions.forEach((element) {
            if (element == i) {
              yFound = true;
            }
          });
          enemy.xPositionsHit.forEach((element) {
            if (element == j) {
              xHitFound = true;
            }
          });
          enemy.yPositionsHit.forEach((element) {
            if (element == i) {
              yHitFound = true;
            }
          });
          if (xFound && yFound) {
            color = enemy.color;
          }
          if (xHitFound && yHitFound) {
            hit = true;
            icon = const Icon(Icons.disabled_by_default_outlined);
            function = null;
          }
        });
        if ((gameManager.hostTurn && gameManager.player == Player.guest) ||
            (!gameManager.hostTurn && gameManager.player == Player.host)) {
          function = null;
        }
        rowContent.add(GameTile(
          j,
          i,
          ally,
          hit,
          color: color,
          icon: icon,
          function: function,
        ));
      }
      gameTiles.add(Flexible(
        flex: 1,
        fit: FlexFit.loose,
        child: Row(
          children: rowContent,
        ),
      ));
    }
    return gameTiles;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (_, gameManager, __) {
        List<Widget> gameTiles = _buildGameTiles(gameManager);
        return Flexible(
          flex: 20,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: color),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: gameTiles,
              ),
            ),
          ),
        );
      },
    );
  }
}

class GameTile extends StatelessWidget {
  const GameTile(this.x, this.y, this.ally, this.hit,
      {Key? key, this.color = Colors.yellow, this.icon, this.function})
      : super(key: key);
  final int x;
  final int y;
  final ally;
  final Color? color;
  final Icon? icon;
  final bool hit;
  final Function()? function;
  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          width: double.infinity,
          color: color,
          child: hit
              ? Placeholder()
              : MaterialButton(
                  onPressed: function,
                  child: Center(child: icon),
                ),
        ),
      ),
    );
  }
}
