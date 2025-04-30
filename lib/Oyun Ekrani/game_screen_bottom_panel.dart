import 'package:flutter/material.dart';

class BottomPanel extends StatelessWidget {
  final List<Map<String, dynamic>> letters;
  final String myUsername;
  final int myScore;
  final String opponentUsername;
  final int opponentScore;
  final int remainingLetters;
  final String selectedLetterChar;
  final List<String> disabledLetters;
  final Function(Map<String, dynamic>) onLetterTap;
  final VoidCallback onSubmitPressed;
  final VoidCallback onResetPressed;

  const BottomPanel({
    super.key,
    required this.letters,
    required this.myUsername,
    required this.myScore,
    required this.opponentUsername,
    required this.opponentScore,
    required this.remainingLetters,
    required this.selectedLetterChar,
    required this.disabledLetters,
    required this.onLetterTap,
    required this.onSubmitPressed,
    required this.onResetPressed,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, int> disabledCountMap = {};
    for (var letter in disabledLetters) {
      disabledCountMap[letter] = (disabledCountMap[letter] ?? 0) + 1;
    }

    Map<String, int> currentCountMap = {};

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
              final char = letter['char'];
              final isSelected = selectedLetterChar == char;

              currentCountMap[char] = (currentCountMap[char] ?? 0);
              final isDisabled =
                  currentCountMap[char]! < (disabledCountMap[char] ?? 0);

              if (isDisabled) {
                currentCountMap[char] = currentCountMap[char]! + 1;
              }

              return GestureDetector(
                onTap: isDisabled ? null : () => onLetterTap(letter),
                child: Opacity(
                  opacity: isDisabled ? 0.3 : 1.0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.withOpacity(0.8)
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
                          char,
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
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: onResetPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tekrar Yaz',
                    style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                onPressed: onSubmitPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    const Text('Onayla', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
