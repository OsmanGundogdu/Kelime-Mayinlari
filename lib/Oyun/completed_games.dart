import 'package:flutter/material.dart';

class CompletedGamesScreen extends StatelessWidget {
  final List<Game> completedGames;

  const CompletedGamesScreen({super.key, required this.completedGames});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biten Oyunlar'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          // Arka plan resmi
          Positioned.fill(
            child: Image.asset(
              'assets/images/completed_games_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView.builder(
              itemCount: completedGames.length,
              itemBuilder: (context, index) {
                final game = completedGames[index];

                return Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                        _buildGameResult(game),
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

  // Oyun sonucunu gösteren fonksiyon
  Widget _buildGameResult(Game game) {
    if (game.userScore > game.opponentScore) {
      return const Text(
        'Kazandınız!',
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    } else if (game.userScore < game.opponentScore) {
      return const Text(
        'Kaybettiniz.',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    } else {
      return const Text(
        'Beraberlik',
        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
      );
    }
  }

  // Tamamlanan oyunun detayları
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
            _buildGameResult(game),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Burada oyunla ilgili ek işlemler yapılacak.
              },
              child: const Text('Yeni Oyun Başlat'),
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

  // Oyun sonucu
  Widget _buildGameResult(Game game) {
    if (game.userScore > game.opponentScore) {
      return const Text(
        'Kazandınız!',
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    } else if (game.userScore < game.opponentScore) {
      return const Text(
        'Kaybettiniz.',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    } else {
      return const Text(
        'Beraberlik',
        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
      );
    }
  }
}

// Oyun modeli
class Game {
  final String opponentName;
  final int userScore;
  final int opponentScore;

  Game({
    required this.opponentName,
    required this.userScore,
    required this.opponentScore,
  });
}
