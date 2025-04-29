import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proje2/Oyun%20Ekrani/game_screen.dart';
import 'package:proje2/Oyun/active_games_screen.dart';

class GameDetailScreen extends StatelessWidget {
  final Game game;
  final String userId;
  final QueryDocumentSnapshot doc;

  const GameDetailScreen({
    super.key,
    required this.game,
    required this.userId,
    required this.doc,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyun Detayları'),
        backgroundColor:
            const Color.fromARGB(255, 139, 106, 63).withOpacity(0.6),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/game_details_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Rakip: ${game.opponentName}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                      'Siz '
                      '${userId == doc['hostUserID'] ? 'Hostsunuz' : 'Guestsiniz'}',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center),
                  Text(
                    'Puanınız: ${game.userScore}',
                    style: const TextStyle(fontSize: 22, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Rakibin Puanı: ${game.opponentScore}',
                    style: const TextStyle(fontSize: 22, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Sıra: ${game.turn == 'host' ? 'Host\'ta' : 'Guest\'te'}',
                    style: const TextStyle(
                        fontSize: 22, color: Colors.amberAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 400),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                            gameId: doc.id,
                            currentUserId: userId,
                            isHost: userId == doc['hostUserID'] ? true : false,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent.withOpacity(0.7),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Oyuna Devam Et',
                      style: TextStyle(color: Colors.black, fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
