import 'package:flutter/material.dart';

class ActiveGamesScreen extends StatelessWidget {
  final List<Game> activeGames;

  const ActiveGamesScreen({super.key, required this.activeGames});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktif Oyunlar'),
        backgroundColor: Colors.blueAccent,
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
            child: ListView.builder(
              itemCount: activeGames.length,
              itemBuilder: (context, index) {
                final game = activeGames[index];

                return Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    onTap: () {
                      _openGameDetails(context, game);
                    },
                    title: Text(
                      'Rakip: ${game.opponentName}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Puanınız: ${game.userScore}'),
                        Text('Rakibin Puanı: ${game.opponentScore}'),
                        Text(
                            'Sıra: ${game.turn == 'user' ? 'Sizde' : 'Rakipte'}'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward,
                        color: Colors.blueAccent),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openGameDetails(BuildContext context, Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailScreen(game: game),
      ),
    );
  }
}

class GameDetailScreen extends StatelessWidget {
  final Game game;

  const GameDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oyun Detayları: ${game.opponentName}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rakip: ${game.opponentName}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('Puanınız: ${game.userScore}'),
            Text('Rakibin Puanı: ${game.opponentScore}'),
            Text('Sıra: ${game.turn == 'user' ? 'Sizde' : 'Rakipte'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Burada oyun devam etme işlemleri yapılacak
              },
              child: const Text('Oyuna Devam Et'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Oyun modeli
class Game {
  final String opponentName;
  final int userScore;
  final int opponentScore;
  final String turn; // "user" veya "opponent"

  Game({
    required this.opponentName,
    required this.userScore,
    required this.opponentScore,
    required this.turn,
  });
}
