import 'package:flutter/material.dart';
import 'package:online_hidden_ship_game/screens/game_screen.dart';
import 'package:online_hidden_ship_game/utils/game_engine.dart';
import 'package:provider/provider.dart';

class GameMenu extends StatelessWidget {
  const GameMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: OutlinedButton(
              child: const Text(
                'Create Game',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                return ChangeNotifierProvider(
                    create: (_) => GameManager(), child: const GameScreen());
              })),
            ),
          ),
          const Divider(
            thickness: 20,
          ),
          Container(
            child: OutlinedButton(
              child: const Text(
                'Join Game',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                return ChangeNotifierProvider(
                    create: (_) => GameManager.guest(),
                    child: const GameScreen());
              })),
            ),
          ),
        ],
      ),
    );
  }
}
