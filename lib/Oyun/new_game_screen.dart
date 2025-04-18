import 'dart:math';
import 'package:flutter/material.dart';

class NewGameScreen extends StatelessWidget {
  const NewGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Oyun'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/new_game_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Oyun Süresi Seçin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildGameOption(
                  context,
                  'Hızlı Oyun - 2 Dakika',
                  '2 dakika içinde kelimeyi yazmalısınız.',
                  2,
                ),
                _buildGameOption(
                  context,
                  'Hızlı Oyun - 5 Dakika',
                  '5 dakika içinde kelimeyi yazmalısınız.',
                  5,
                ),
                const SizedBox(height: 20),
                _buildGameOption(
                  context,
                  'Genişletilmiş Oyun - 12 Saat',
                  '12 saat içinde kelimeyi yazmalısınız.',
                  720,
                ),
                _buildGameOption(
                  context,
                  'Genişletilmiş Oyun - 24 Saat',
                  '24 saat içinde kelimeyi yazmalısınız.',
                  1440,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOption(
      BuildContext context, String title, String description, int duration) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Rastgele kullanıcı eşleştirme ve oyun başlatma
                _startGame(context, duration);
              },
              child: const Text('Başlat'),
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

  void _startGame(BuildContext context, int duration) {
    // Burada kullanıcıları eşleştiriyoruz, şu an rastgele iki kullanıcı seçiyoruz.
    // Bu kısımları firebase database den çekeceğiz.
    List<String> users = [
      'Kullanıcı 1',
      'Kullanıcı 2'
    ]; // Rastgele kullanıcı listesi
    Random random = Random();
    String selectedUser1 = users[random.nextInt(users.length)];
    String selectedUser2 = users[random.nextInt(users.length)];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oyun Başladı!'),
          content: Text(
            '$selectedUser1 ve $selectedUser2, $duration dakika süresiyle eşleşti!',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
                // Oyun başladığında bir sonraki sayfaya yönlendirme yapacaz.
              },
            ),
          ],
        );
      },
    );
  }
}
