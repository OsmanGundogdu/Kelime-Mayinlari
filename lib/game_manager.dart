import 'dart:math';

class GameManager {
  final Map<String, Map<String, dynamic>> _letterData = {
    'A': {'count': 12, 'point': 1},
    'B': {'count': 2, 'point': 3},
    'C': {'count': 2, 'point': 4},
    'Ç': {'count': 2, 'point': 4},
    'D': {'count': 2, 'point': 3},
    'E': {'count': 8, 'point': 1},
    'F': {'count': 1, 'point': 7},
    'G': {'count': 1, 'point': 5},
    'Ğ': {'count': 1, 'point': 8},
    'H': {'count': 1, 'point': 5},
    'I': {'count': 4, 'point': 2},
    'İ': {'count': 7, 'point': 1},
    'J': {'count': 1, 'point': 10},
    'K': {'count': 7, 'point': 1},
    'L': {'count': 7, 'point': 1},
    'M': {'count': 4, 'point': 2},
    'N': {'count': 5, 'point': 1},
    'O': {'count': 3, 'point': 2},
    'Ö': {'count': 1, 'point': 7},
    'P': {'count': 1, 'point': 5},
    'R': {'count': 6, 'point': 1},
    'S': {'count': 3, 'point': 2},
    'Ş': {'count': 2, 'point': 4},
    'T': {'count': 5, 'point': 1},
    'U': {'count': 3, 'point': 2},
    'Ü': {'count': 2, 'point': 3},
    'V': {'count': 1, 'point': 7},
    'Y': {'count': 2, 'point': 3},
    'Z': {'count': 2, 'point': 4},
    '*': {'count': 2, 'point': 0},
  };

  final List<Map<String, dynamic>> _letterPool = [];
  final List<Map<String, dynamic>> playerLetters = [];
  final List<Map<String, dynamic>> opponentLetters = [];

  GameManager() {
    _generateLetterPool();
    _shufflePool();
  }

  void _generateLetterPool() {
    _letterData.forEach((char, data) {
      int count = data['count'];
      int point = data['point'];
      for (int i = 0; i < count; i++) {
        _letterPool.add({'char': char, 'point': point});
      }
    });
  }

  void _shufflePool() {
    _letterPool.shuffle(Random());
  }

  List<Map<String, dynamic>> drawLetters(int count) {
    int drawCount = count.clamp(0, _letterPool.length);
    final drawn = _letterPool.sublist(0, drawCount);
    _letterPool.removeRange(0, drawCount);
    return drawn;
  }

  void dealInitialLetters() {
    playerLetters.addAll(drawLetters(7));
    opponentLetters.addAll(drawLetters(7));
  }

  int get remainingLetters => _letterPool.length;
}
