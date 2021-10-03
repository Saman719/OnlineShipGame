import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:online_hidden_ship_game/screens/game_menu.dart';
import 'package:online_hidden_ship_game/screens/game_screen.dart';
import 'package:online_hidden_ship_game/utils/game_engine.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: FirebaseInitializer());
  }
}

class FirebaseInitializer extends StatefulWidget {
  const FirebaseInitializer({Key? key}) : super(key: key);

  @override
  _FirebaseInitializerState createState() => _FirebaseInitializerState();
}

class _FirebaseInitializerState extends State<FirebaseInitializer> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Ship Game'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('sth went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return const GameMenu();
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
