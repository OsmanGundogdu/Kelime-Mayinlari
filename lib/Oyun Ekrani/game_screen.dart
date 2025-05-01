import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proje2/Oyun%20Ekrani/game_board.dart';
import 'package:proje2/Oyun%20Ekrani/game_manager.dart';
import 'package:proje2/Oyun%20Ekrani/game_screen_bottom_panel.dart';

class GameScreen extends StatefulWidget {
  final String gameId;
  final String currentUserId;
  final bool isHost;

  const GameScreen({
    super.key,
    required this.gameId,
    required this.currentUserId,
    required this.isHost,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameManager _gameManager = GameManager();
  List<Map<String, dynamic>> _playerLetters = [];
  int? guestScore;
  int? hostScore;
  String? hostUsername;
  String? guestUsername;
  String? currentTurn;
  bool isFirstMove = true;
  final List<String> _disabledLetters = [];

  Map<String, dynamic> placedTiles = {};
  Map<String, dynamic> boardTiles = {};
  String _selectedLetterChar = '';

  @override
  void initState() {
    super.initState();
    _drawInitialLetters();
    fetchGameData();
  }

  void _drawInitialLetters() async {
    final String gameId = widget.gameId;
    final bool isHost = widget.isHost;
    final gameDoc = FirebaseFirestore.instance.collection('games').doc(gameId);
    final snapshot = await gameDoc.get();

    final key = isHost ? 'hostLetters' : 'guestLetters';

    if (snapshot.exists) {
      final data = snapshot.data()!;

      if (!data.containsKey('letter')) {
        await _gameManager.generateLetterPointMap(gameId);
      }

      if (!data.containsKey('letterPool')) {
        await _gameManager.generateAndSaveLetterPool(gameId);
      }

      if (data.containsKey(key)) {
        final savedLetters = data[key] is String
            ? List<Map<String, dynamic>>.from(jsonDecode(data[key]))
            : List<Map<String, dynamic>>.from(data[key]);

        setState(() {
          _playerLetters = savedLetters;
        });
      } else {
        await _gameManager.loadLetterPool(gameId);
        final drawn = await _gameManager.drawLettersFromPool(gameId, 7);
        await gameDoc.update({key: drawn});

        setState(() {
          _playerLetters = drawn;
        });
      }
    }
  }

  Future<void> fetchGameData() async {
    try {
      await loadBoardLetters();

      var doc = await FirebaseFirestore.instance
          .collection('games')
          .doc(widget.gameId)
          .get();

      var data = doc.data();

      if (data != null) {
        final hostID = data['hostUserID'];
        final guestID = data['guestUserID'];

        setState(() {
          hostUsername = data['hostUsername'];
          guestUsername = data['guestUsername'];
          hostScore =
              int.tryParse(data['scores'][hostID]?.toString() ?? '0') ?? 0;
          guestScore =
              int.tryParse(data['scores'][guestID]?.toString() ?? '0') ?? 0;
          isFirstMove = data['isFirstMove'] ?? true;
          currentTurn = data['turn'];
        });
      }
    } catch (e) {
      print("Veri çekme hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hostUsername == null || guestUsername == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900.withOpacity(0.9),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "KELİME MAYINLARI",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              currentTurn == (widget.isHost ? 'host' : 'guest')
                  ? 'Senin sıran!'
                  : 'Rakibinin sırası...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
        elevation: 4,
      ),
      backgroundColor: Colors.blue.shade900.withOpacity(0.8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: GameBoard.boardSize,
                        childAspectRatio: 1,
                      ),
                      itemCount: GameBoard.boardSize * GameBoard.boardSize,
                      itemBuilder: (context, index) {
                        int row = index ~/ GameBoard.boardSize;
                        int col = index % GameBoard.boardSize;
                        TileType type = GameBoard.boardLayout[row][col];

                        final placedKey = '$row-$col';
                        final placedLetter =
                            placedTiles[placedKey] ?? boardTiles[placedKey];

                        return GestureDetector(
                          onTap: () {
                            _handleTileTap(row, col);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(0.2),
                            decoration: BoxDecoration(
                              color: _getTileColor(type),
                              border: Border.all(
                                  color: Colors.grey.shade700.withOpacity(0.8)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: placedLetter != null
                                  ? Text(
                                      placedLetter['letter'],
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )
                                  : _getTileLabel(type),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
            FutureBuilder<int>(
              future: _gameManager.getRemainingLetterCount(widget.gameId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Hata: kalan harf yüklenemedi');
                }

                int remaining = snapshot.data ?? 0;

                return BottomPanel(
                  letters: _playerLetters,
                  myUsername: hostUsername!,
                  myScore: hostScore ?? 0,
                  opponentUsername: guestUsername!,
                  opponentScore: guestScore ?? 0,
                  remainingLetters: remaining,
                  selectedLetterChar: _selectedLetterChar,
                  onLetterTap: _handleLetterTap,
                  onSubmitPressed: () async {
                    try {
                      final isHostTurn = currentTurn == 'host' && widget.isHost;
                      final isGuestTurn =
                          currentTurn == 'guest' && !widget.isHost;

                      if (!isHostTurn && !isGuestTurn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sıra sende değil.')),
                        );
                        return;
                      }

                      final placedLetters = getCurrentTurnPlacedLetters();

                      if (placedLetters.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Tahtaya harf yerleştirin.')),
                        );
                        return;
                      }

                      if (isFirstMove) {
                        bool touchesCenter = placedLetters.any((letter) {
                          return letter['row'] == 7 && letter['col'] == 7;
                        });

                        if (!touchesCenter) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'İlk kelimeniz ekranın ortasına (8,8) değmelidir.')),
                          );
                          return;
                        }
                      }

                      await updatePlacedLetters(placedLetters);
                      await updateUserScoreWithPlacedLettersFromGameLetterField(
                        widget.gameId,
                        widget.currentUserId,
                        placedLetters,
                      );
                      await savePlacedTilesToBoardLetters();

                      final letterKey =
                          widget.isHost ? 'hostLetters' : 'guestLetters';

                      List<Map<String, dynamic>> remainingLetters =
                          List.from(_playerLetters);

                      Map<String, int> usedCounts = {};
                      for (var used in placedLetters) {
                        usedCounts[used['letter']] =
                            (usedCounts[used['letter']] ?? 0) + 1;
                      }

                      for (var entry in usedCounts.entries) {
                        int countToRemove = entry.value;
                        String charToRemove = entry.key;

                        for (int i = 0; i < countToRemove; i++) {
                          int index = remainingLetters.indexWhere(
                              (letter) => letter['char'] == charToRemove);
                          if (index != -1) {
                            remainingLetters.removeAt(index);
                          }
                        }
                      }

                      final newLetters = await _gameManager.drawLettersFromPool(
                        widget.gameId,
                        placedLetters.length,
                      );

                      final updatedLetters = [
                        ...remainingLetters,
                        ...newLetters
                      ];

                      await FirebaseFirestore.instance
                          .collection('games')
                          .doc(widget.gameId)
                          .update({
                        letterKey: updatedLetters,
                        "isFirstMove": false,
                      });

                      final newTurn = widget.isHost ? 'guest' : 'host';
                      await FirebaseFirestore.instance
                          .collection('games')
                          .doc(widget.gameId)
                          .update({'turn': newTurn});

                      setState(() {
                        _playerLetters = updatedLetters;
                        placedTiles.clear();
                        _disabledLetters.clear();
                      });

                      await fetchGameData();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Kelime başarıyla gönderildi!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hata oluştu: $e')),
                      );
                    }
                  },
                  onResetPressed: () {
                    _resetPlacedTiles();
                    setState(() {
                      _disabledLetters.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tekrar yazabilirsiniz.')),
                    );
                  },
                  disabledLetters: _disabledLetters,
                  onPassPressed: () async => await passTurn(),
                  onSurrenderPressed: () async => await surrender(),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getPlacedLetters() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('games')
          .doc(widget.gameId)
          .get();

      final data = snapshot.data();
      if (data != null && data.containsKey('placedLetters')) {
        final rawList = data['placedLetters'] as List<dynamic>;
        return rawList
            .map((item) => {
                  'letter': item['letter'],
                  'row': item['row'],
                  'col': item['col'],
                })
            .toList();
      }
    } catch (e) {
      print('placedLetters alınırken hata: $e');
    }

    return [];
  }

  void _handleLetterTap(Map<String, dynamic> letter) {
    setState(() {
      _selectedLetterChar = letter['char'];
    });
  }

  void placeLetter(int row, int col, Map<String, dynamic> letterData) {
    setState(() {
      final key = '$row-$col';
      placedTiles[key] = letterData;
      _playerLetters.remove(letterData);
    });
  }

  List<Map<String, dynamic>> getCurrentTurnPlacedLetters() {
    return placedTiles.entries
        .map((e) => {
              'row': e.value['row'],
              'col': e.value['col'],
              'letter': e.value['letter'],
            })
        .toList();
  }

  Future<void> savePlacedTilesToBoardLetters() async {
    final boardLettersRef = FirebaseFirestore.instance
        .collection('games')
        .doc(widget.gameId)
        .collection('boardLetters');

    final existingDocs = await boardLettersRef.get();
    final existingKeys = existingDocs.docs
        .map((doc) => '${doc.data()['row']}-${doc.data()['col']}')
        .toSet();

    for (var tile in placedTiles.values) {
      final key = '${tile['row']}-${tile['col']}';
      if (!existingKeys.contains(key)) {
        await boardLettersRef.add(tile);
      }
    }
  }

  Future<void> loadBoardLetters() async {
    final boardLettersSnapshot = await FirebaseFirestore.instance
        .collection('games')
        .doc(widget.gameId)
        .collection('boardLetters')
        .get();

    boardTiles.clear();
    for (var doc in boardLettersSnapshot.docs) {
      final data = doc.data();
      final row = data['row'];
      final col = data['col'];
      final letter = data['letter'];
      final key = '$row-$col';

      boardTiles[key] = {
        'row': row,
        'col': col,
        'letter': letter,
      };
    }

    setState(() {});
  }

  void _resetPlacedTiles() {
    setState(() {
      placedTiles.clear();
    });
    _savePlacedLetterToFirestore();
  }

  void _handleTileTap(int row, int col) {
    final isHostTurn = currentTurn == 'host' && widget.isHost;
    final isGuestTurn = currentTurn == 'guest' && !widget.isHost;

    if (!isHostTurn && !isGuestTurn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sıra sende değil.')),
      );
      return;
    }

    if (_selectedLetterChar.isEmpty) return;

    final placedKey = '$row-$col';
    if (placedTiles.containsKey(placedKey)) return;

    setState(() {
      placedTiles[placedKey] = {
        'letter': _selectedLetterChar,
        'row': row,
        'col': col,
      };
      _disabledLetters.add(_selectedLetterChar);
      _selectedLetterChar = '';
    });

    _savePlacedLetterToFirestore();
  }

  Future<void> _savePlacedLetterToFirestore() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('games').doc(widget.gameId);
      final List<Map<String, dynamic>> placedLetters = [];

      placedTiles.forEach((key, value) {
        placedLetters.add(value);
      });

      await docRef.update({
        'placedLetters': placedLetters,
      });

      print("Harfler Firestore'a kaydedildi.");
    } catch (e) {
      print('Harf Firestore\'a kaydedilemedi: $e');
    }
  }

  Future<void> startNewGame() async {
    final gameDoc =
        FirebaseFirestore.instance.collection('games').doc(widget.gameId);
    final docSnapshot = await gameDoc.get();

    if (!docSnapshot.exists) {
      await gameDoc.set({
        'placedLetters': [],
        'turn': 'host',
        'isFirstMove': true,
      });
    } else {
      final data = docSnapshot.data();
      if (data != null && !data.containsKey('placedLetters')) {
        await gameDoc.update({
          'placedLetters': [],
        });
      }
    }
  }

  Future<void> updatePlacedLetters(
      List<Map<String, dynamic>> placedLetters) async {
    try {
      final gameDoc =
          FirebaseFirestore.instance.collection('games').doc(widget.gameId);
      final docSnapshot = await gameDoc.get();
      final data = docSnapshot.data();

      if (data == null) return;

      String currentTurn = data['turn'];
      String hostUserID = data['hostUserID'];
      String guestUserID = data['guestUserID'];

      String newTurn;
      if (currentTurn == hostUserID) {
        newTurn = guestUserID;
      } else {
        newTurn = hostUserID;
      }

      await gameDoc.update({
        'placedLetters': placedLetters,
        'turn': newTurn,
      });
    } catch (e) {
      print("Harfler güncellenirken hata: $e");
    }
  }

  Color _getTileColor(TileType type) {
    switch (type) {
      case TileType.doubleLetter:
        return Colors.lightBlue.shade300;
      case TileType.tripleLetter:
        return const Color.fromARGB(255, 197, 133, 49);
      case TileType.doubleWord:
        return Colors.green.shade300;
      case TileType.tripleWord:
        return Colors.brown.shade300;
      case TileType.start:
        return Colors.orange.shade300;
      default:
        return Colors.white;
    }
  }

  Widget _getTileLabel(TileType type) {
    switch (type) {
      case TileType.doubleLetter:
        return const Text("H²",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.brown));
      case TileType.tripleLetter:
        return const Text("H³",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.brown));
      case TileType.doubleWord:
        return const Text("K²",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.brown));
      case TileType.tripleWord:
        return const Text("K³",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.brown));
      case TileType.start:
        return const Icon(Icons.star, color: Colors.yellow, size: 20);
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> updateUserScoreWithPlacedLettersFromGameLetterField(
    String gameId,
    String currentUserId,
    List<Map<String, dynamic>> placedLetters,
  ) async {
    final gameDocRef =
        FirebaseFirestore.instance.collection('games').doc(gameId);
    final gameSnapshot = await gameDocRef.get();
    final gameData = gameSnapshot.data();

    if (gameData == null || !gameData.containsKey('letter')) return;

    List<dynamic> letterList = gameData['letter'];
    Map<String, int> letterPoints = {
      for (var item in letterList)
        item['char'].toString().toUpperCase():
            int.tryParse(item['point'].toString()) ?? 0
    };

    int totalPoints = 0;
    int wordMultiplier = 1;
    for (var letter in placedLetters) {
      String char = letter['letter'].toString().toUpperCase();
      int basePoint = letterPoints[char] ?? 0;

      int row = letter['row'];
      int col = letter['col'];
      TileType tileType = GameBoard.boardLayout[row][col];

      switch (tileType) {
        case TileType.doubleLetter:
          basePoint *= 2;
          break;
        case TileType.tripleLetter:
          basePoint *= 3;
          break;
        case TileType.doubleWord:
          wordMultiplier *= 2;
          break;
        case TileType.tripleWord:
          wordMultiplier *= 3;
          break;
        default:
          break;
      }

      totalPoints += basePoint;
    }
    totalPoints *= wordMultiplier;

    Map<String, dynamic> currentScores =
        Map<String, dynamic>.from(gameData['scores'] ?? {});
    int existingScore =
        int.tryParse(currentScores[currentUserId]?.toString() ?? '0') ?? 0;
    currentScores[currentUserId] = existingScore + totalPoints;

    await gameDocRef.update({'scores': currentScores});
  }

  Future<void> passTurn() async {
    final gameDocRef =
        FirebaseFirestore.instance.collection('games').doc(widget.gameId);
    final gameSnapshot = await gameDocRef.get();
    final gameData = gameSnapshot.data();

    if (gameData == null) return;

    final currentTurn = gameData['turn'];
    final newTurn = currentTurn == 'host' ? 'guest' : 'host';

    await gameDocRef.update({'turn': newTurn});
    await fetchGameData(); // UI güncelle
  }

  Future<void> surrender() async {
    final gameDocRef =
        FirebaseFirestore.instance.collection('games').doc(widget.gameId);
    final gameSnapshot = await gameDocRef.get();

    if (!gameSnapshot.exists) return;

    final gameData = gameSnapshot.data()!;
    final scores = Map<String, dynamic>.from(gameData['scores'] ?? {});
    final hostId = gameData['hostUserID'];
    final guestId = gameData['guestUserID'];

    final surrenderingUserId = widget.isHost ? hostId : guestId;
    final winnerUserId = widget.isHost ? guestId : hostId;
    final winnerKey = widget.isHost ? 'guest' : 'host';

    scores[surrenderingUserId] = 0;
    scores[winnerUserId] = 1;

    await gameDocRef.update({
      'isGameOver': true,
      'isGameStarted': false,
      'winner': winnerKey,
      'scores': scores,
    });

    final usersCollection = FirebaseFirestore.instance.collection('users');

    await usersCollection.doc(surrenderingUserId).update({
      'gameplayed': FieldValue.increment(1),
    });

    await usersCollection.doc(winnerUserId).update({
      'gameplayed': FieldValue.increment(1),
      'gamewon': FieldValue.increment(1),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Oyunu teslim ettiniz.')),
    );

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }
}

class LetterTile {
  final String char;
  final int point;

  LetterTile(this.char, this.point);
}
