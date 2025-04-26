import 'package:flutter/material.dart';

class BottomPanel extends StatelessWidget {
  final List<Map<String, dynamic>> letters;
  final String myUsername;
  final int myScore;
  final String opponentUsername;
  final int opponentScore;
  final int remainingLetters;
  final String selectedLetterChar;
  final Function(Map<String, dynamic>) onLetterTap;
  final VoidCallback onSubmitPressed;

  const BottomPanel({
    super.key,
    required this.letters,
    required this.myUsername,
    required this.myScore,
    required this.opponentUsername,
    required this.opponentScore,
    required this.remainingLetters,
    required this.selectedLetterChar,
    required this.onLetterTap,
    required this.onSubmitPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade900.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$myUsername: $myScore',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                child: Text(
                  '$remainingLetters',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              Text('$opponentScore :$opponentUsername',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: letters.map((letter) {
              bool isSelected = selectedLetterChar == letter['char'];
              return GestureDetector(
                onTap: () => onLetterTap(letter),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.green
                            .withOpacity(0.8) // Seçilen harfe özel renk
                        : Colors.orange.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        letter['char'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        '${letter['point']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  // TODO: Oyunu başlat
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 80),
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.more_vert, color: Colors.white),
                  const Text("Daha",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: onSubmitPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Onayla',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
