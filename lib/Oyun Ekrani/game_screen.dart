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

  Map<String, dynamic> placedTiles = {};
  Map<String, dynamic>? _selectedLetter;
  String _selectedLetterChar = '';

  @override
  void initState() {
    super.initState();
    _drawInitialLetters();
    fetchGameData();
  }

  void _drawInitialLetters() async {
    final String gameId = widget.gameId;
    final String currentUserId = widget.currentUserId;
    final bool isHost = widget.isHost;
    final gameDoc = FirebaseFirestore.instance.collection('games').doc(gameId);
    final snapshot = await gameDoc.get();

    final key = isHost ? 'hostLetters' : 'guestLetters';

    if (snapshot.exists) {
      final data = snapshot.data()!;
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
        setState(() {
          hostUsername = data['hostUsername'];
          guestUsername = data['guestUsername'];
          hostScore =
              int.tryParse(data['scores']['hostUserID'].toString()) ?? 0;
          guestScore =
              int.tryParse(data['scores']['guestUserID'].toString()) ?? 0;
          isFirstMove = data['isFirstMove'] ?? true;
          currentTurn = data['turn'];
        });
      }
    } catch (e) {
      print("Veri çekme hatası: $e");
    }
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
                        final placedLetter = placedTiles[placedKey];

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
                  selectedLetterChar: _selectedLetterChar ?? '',
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

                      final placedLetters = await getPlacedLetters();

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
                      await savePlacedTilesToBoardLetters();

                      final letterKey =
                          widget.isHost ? 'hostLetters' : 'guestLetters';
                      final newLetters = await _gameManager.drawLettersFromPool(
                        widget.gameId,
                        placedLetters.length,
                      );

                      await FirebaseFirestore.instance
                          .collection('games')
                          .doc(widget.gameId)
                          .update({
                        letterKey: newLetters,
                        "isFirstMove": false,
                      });

                      final newTurn = widget.isHost ? 'guest' : 'host';
                      await FirebaseFirestore.instance
                          .collection('games')
                          .doc(widget.gameId)
                          .update({'turn': newTurn});

                      setState(() {
                        _playerLetters = newLetters;
                        placedTiles.clear();
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Şimdi tekrar yazabilirsiniz.')),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> savePlacedTilesToBoardLetters() async {
    final gameRef =
        FirebaseFirestore.instance.collection('games').doc(widget.gameId);
    final boardLettersRef = gameRef.collection('boardLetters');

    for (var tile in placedTiles.values) {
      await boardLettersRef.add({
        'row': tile['row'],
        'col': tile['col'],
        'letter': tile['letter'],
      });
    }
  }

  Future<void> loadBoardLetters() async {
    final boardLettersSnapshot = await FirebaseFirestore.instance
        .collection('games')
        .doc(widget.gameId)
        .collection('boardLetters')
        .get();

    for (var doc in boardLettersSnapshot.docs) {
      final data = doc.data();
      final row = data['row'];
      final col = data['col'];
      final letter = data['letter'];

      final placedKey = '$row-$col';

      placedTiles[placedKey] = {
        'row': row,
        'col': col,
        'letter': letter,
      };
    }

    setState(() {}); // GameBoard güncellensin diye
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

    if (_selectedLetterChar == null || _selectedLetterChar!.isEmpty) {
      return;
    }

    final placedKey = '$row-$col';

    if (placedTiles.containsKey(placedKey)) {
      return;
    }

    setState(() {
      placedTiles[placedKey] = {
        'letter': _selectedLetterChar,
        'row': row,
        'col': col,
      };
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
}

class LetterTile {
  final String char;
  final int point;

  LetterTile(this.char, this.point);
}
