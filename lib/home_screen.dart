import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  final int gamesPlayed;
  final int gamesWon;

  const HomeScreen({
    super.key,
    required this.username,
    required this.gamesPlayed,
    required this.gamesWon,
  });

  @override
  Widget build(BuildContext context) {
    final double successRate =
        gamesPlayed == 0 ? 0 : (gamesWon / gamesPlayed * 100);

    return Scaffold(
      appBar: AppBar(
        title: Text('Merhaba, $username 👋'),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
            ),
            tooltip: 'Çıkış Yap',
            onPressed: () => Navigator.pop(context),
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
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
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
                            onPressed: () {},
                          ),
                          const SizedBox(width: 40),
                          _buildCircleMenuButton(
                            context,
                            label: 'Aktif\nOyunlar',
                            icon: Icons.play_circle_fill,
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      _buildCircleMenuButton(
                        context,
                        label: 'Biten\nOyunlar',
                        icon: Icons.history,
                        onPressed: () {},
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
}
