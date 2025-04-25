import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  List<Map<String, dynamic>> _letterPool = [];

  Future<void> generateAndSaveLetterPool(String gameId) async {
    List<Map<String, dynamic>> pool = [];
    _letterData.forEach((char, data) {
      int count = data['count'];
      int point = data['point'];
      for (int i = 0; i < count; i++) {
        pool.add({'char': char, 'point': point});
      }
    });
    pool.shuffle(Random());

    await _firestore.collection('games').doc(gameId).set(
      {'letterPool': pool},
      SetOptions(merge: true),
    );
  }

  Future<void> loadLetterPool(String gameId) async {
    final snapshot = await _firestore.collection('games').doc(gameId).get();

    if (snapshot.exists && snapshot.data()!.containsKey('letterPool')) {
      _letterPool = List<Map<String, dynamic>>.from(snapshot['letterPool']);
    }
  }

  Future<List<Map<String, dynamic>>> drawLettersFromPool(
      String gameId, int count) async {
    final docRef = _firestore.collection('games').doc(gameId);
    final doc = await docRef.get();

    if (!doc.exists || !doc.data()!.containsKey('letterPool')) return [];

    List<Map<String, dynamic>> pool =
        List<Map<String, dynamic>>.from(doc['letterPool']);

    int drawCount = count.clamp(0, pool.length);
    final drawn = pool.sublist(0, drawCount);
    pool.removeRange(0, drawCount);

    await docRef.update({'letterPool': pool});
    _letterPool = pool;
    return drawn;
  }

  Future<int> getRemainingLetterCount(String gameId) async {
    final snapshot = await _firestore.collection('games').doc(gameId).get();

    if (snapshot.exists && snapshot.data()!.containsKey('letterPool')) {
      List<dynamic> pool = snapshot['letterPool'];
      return pool.length;
    }
    return 0;
  }
}
