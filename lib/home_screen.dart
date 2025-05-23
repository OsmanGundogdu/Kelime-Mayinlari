import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proje2/Giris/login_screen.dart';
import 'package:proje2/Oyun/completed_games.dart';
import 'package:proje2/Oyun/new_game_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userId;
  final String username;
  final int gamesPlayed;
  final int gamesWon;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.gamesPlayed,
    required this.gamesWon,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Kullanıcı verisi bulunamadı')),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final username = userData['username'] ?? 'Kullanıcı';
        final gamesPlayed = userData['gameplayed'] ?? 0;
        final gamesWon = userData['gamewon'] ?? 0;
        final double successRate =
            gamesPlayed == 0 ? 0 : (gamesWon / gamesPlayed * 100);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Merhaba, $username 👋',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.brown,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Çıkış Yap',
                onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false),
              ),
            ],
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/game_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
              Container(color: Colors.black.withOpacity(0.3)),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Oynanan Oyunlar',
                            gamesPlayed.toString(),
                            Icons.videogame_asset,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Kazanılan Oyunlar',
                            gamesWon.toString(),
                            Icons.emoji_events,
                            Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Başarı Yüzdesi',
                            '${successRate.toStringAsFixed(1)}%',
                            Icons.bar_chart,
                            successRate < 50 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCircleMenuButton(
                                context,
                                label: 'Yeni Oyun',
                                icon: Icons.add_circle_outline,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewGameScreen(
                                        currentUserId: userId,
                                        currentUsername: username,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 40),
                              _buildCircleMenuButton(
                                context,
                                label: 'Aktif\nOyunlar',
                                icon: Icons.play_circle_fill,
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/activeGames',
                                    arguments: {
                                      'userId': userId,
                                      'username': username,
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          _buildCircleMenuButton(
                            context,
                            label: 'Biten\nOyunlar',
                            icon: Icons.history,
                            onPressed: () async {
                              final completedGames =
                                  await fetchCompletedGames(userId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CompletedGamesScreen(
                                    completedGames: completedGames,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircleMenuButton(BuildContext context,
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.6),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, size: 40, color: Colors.black),
            onPressed: onPressed,
            tooltip: label,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color iconColor) {
    Color backgroundColor;

    if (label == 'Oynanan Oyunlar') {
      backgroundColor = Colors.blueAccent.withOpacity(0.6);
    } else if (label == 'Kazanılan Oyunlar') {
      backgroundColor = Colors.amber.withOpacity(0.6);
    } else if (label == 'Başarı Yüzdesi') {
      double percentage = double.tryParse(value.replaceAll('%', '')) ?? 0;
      backgroundColor = percentage < 50
          ? Colors.red.withOpacity(0.6)
          : Colors.green.withOpacity(0.6);
    } else {
      backgroundColor = Colors.grey.withOpacity(0.6);
    }

    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: iconColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Game>> fetchCompletedGames(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('games')
        .where('isGameOver', isEqualTo: true)
        .get();

    List<Game> completedGames = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final hostId = data['hostUserID'];
      final guestId = data['guestUserID'];

      if (userId != hostId && userId != guestId) continue;

      final isHost = userId == hostId;
      final opponentId = isHost ? guestId : hostId;
      final opponentName =
          isHost ? data['guestUsername'] : data['hostUsername'];

      final scores = Map<String, dynamic>.from(data['scores'] ?? {});
      final userScore = scores[userId]?.toInt() ?? 0;
      final opponentScore = scores[opponentId]?.toInt() ?? 0;

      completedGames.add(
        Game(
          opponentName: opponentName,
          userScore: userScore,
          opponentScore: opponentScore,
        ),
      );
    }

    return completedGames;
  }
}
