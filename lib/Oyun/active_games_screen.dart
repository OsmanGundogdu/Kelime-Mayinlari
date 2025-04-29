import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proje2/Oyun/game_detail_screen.dart';

class Game {
  final String opponentName;
  final int userScore;
  final int opponentScore;
  final String turn;

  Game({
    required this.opponentName,
    required this.userScore,
    required this.opponentScore,
    required this.turn,
  });
}

class ActiveGamesScreen extends StatelessWidget {
  const ActiveGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final userId = args['userId'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktif Oyunlar'),
        backgroundColor: Colors.limeAccent.withOpacity(0.7),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/active_games_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('games')
                  .where('isGameStarted', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aktif oyun bulunamadı.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final hostId = doc['hostUserID'];
                  final guestId = doc['guestUserID'];
                  return hostId == userId || guestId == userId;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Size ait aktif oyun bulunamadı.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final hostId = doc['hostUserID'];
                    final guestId = doc['guestUserID'];
                    final opponentName = doc['hostUserID'] == userId
                        ? doc['guestUsername'] ?? 'Rakip Bekleniyor'
                        : doc['hostUsername'];

                    final turn = doc['turn'] ?? 'user'; // Turn bilgisi

                    final game = Game(
                      opponentName: opponentName,
                      userScore: doc['scores']?[userId] ?? 0,
                      opponentScore: doc['scores']
                              ?[userId == hostId ? guestId : hostId] ??
                          0,
                      turn: turn,
                    );

                    return _buildGameCard(context, game, userId, doc);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Game game, String userId,
      QueryDocumentSnapshot doc) {
    return Card(
      elevation: 5,
      color: Colors.lime.withOpacity(0.6),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _openGameDetails(context, game, doc, userId),
        title: Text(
          'Rakip: ${game.opponentName}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Puanınız: ${game.userScore}'),
            Text('Rakibin Puanı: ${game.opponentScore}'),
            Text('Sıra: ${game.turn == 'host' ? 'Host\'ta' : 'Guest\'te'}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward, color: Colors.black),
      ),
    );
  }

  void _openGameDetails(BuildContext context, Game game,
      QueryDocumentSnapshot doc, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailScreen(
            game: game,
            userId: userId,
            doc: doc), // Ensure the correct Game class is used
      ),
    );
  }
}
