import 'package:flutter/material.dart';

class CompletedGamesScreen extends StatelessWidget {
  final List<Game> completedGames;

  const CompletedGamesScreen({super.key, required this.completedGames});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biten Oyunlar'),
        backgroundColor: Colors.red,
      ),
      body: Stack(
        children: [
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
                final cardColor = _getCardColor(game);

                return Card(
                  color: cardColor.withOpacity(0.5),
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      'Rakip: ${game.opponentName}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGameResult(game),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getCardColor(Game game) {
    if (game.userScore > game.opponentScore) {
      return Colors.green;
    } else if (game.userScore < game.opponentScore) {
      return Colors.red;
    } else {
      return Colors.amber;
    }
  }

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
