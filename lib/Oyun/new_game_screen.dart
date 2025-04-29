import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewGameScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUsername;

  const NewGameScreen({
    super.key,
    required this.currentUserId,
    required this.currentUsername,
  });

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  int? selectedDuration;

  final List<int> durations = [2, 5, 720, 1440];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Yeni Oyun Başlat",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
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
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Oyun Süresi Seçin:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 70),
                  const Text(
                    "Hızlı Oyun",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.amberAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...durations.where((d) => d < 60).map(_buildDurationButton),
                  const SizedBox(height: 80),
                  const Text(
                    "Genişletilmiş Oyun",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.lightGreenAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...durations.where((d) => d >= 60).map(_buildDurationButton),
                  const SizedBox(height: 130),
                  const Text(
                    "Eşleşmek için aynı süreyi seçen başka bir oyuncu gerekli.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDurationButton(int duration) {
    String label =
        duration < 60 ? "$duration Dakika" : "${(duration / 60).toInt()} Saat";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedDuration = duration;
          });
          _findOrCreateGame(context, duration);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _findOrCreateGame(
      BuildContext context, int selectedDuration) async {
    final gamesRef = FirebaseFirestore.instance.collection('games');

    final querySnapshot = await gamesRef
        .where('isGameStarted', isEqualTo: false)
        .where('duration', isEqualTo: selectedDuration)
        .get();

    final openGames =
        querySnapshot.docs.where((doc) => doc['guestUserID'] == null).toList();

    if (openGames.isNotEmpty) {
      final matchedGame = openGames.first;

      await matchedGame.reference.update({
        'guestUserID': widget.currentUserId,
        'guestUsername': widget.currentUsername,
        'isGameStarted': true,
        'scores.${widget.currentUserId}': 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rakiple eşleştirildiniz!')),
      );

      Navigator.pop(context);
    } else {
      final newDocRef = gamesRef.doc();

      await newDocRef.set({
        'hostUserID': widget.currentUserId,
        'hostUsername': widget.currentUsername,
        'guestUserID': null,
        'guestUsername': null,
        'isGameStarted': false,
        'turn': 'host',
        'scores': {
          widget.currentUserId: 0,
        },
        'duration': selectedDuration,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await newDocRef.collection('boardLetters').add({
        'row': -1,
        'col': -1,
        'letter': '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oyun oluşturuldu. Rakip bekleniyor...')),
      );

      Navigator.pop(context);
    }
  }
}
