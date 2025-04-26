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
        title: const Text(
          "KELİME MAYINLARI",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          )
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
                        final placedLetters = await getPlacedLetters();

                        if (placedLetters.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Tahtaya harf yerleştirin.')),
                          );
                          return;
                        }

                        await _gameManager.submitWord(
                          gameId: widget.gameId,
                          userId: widget.currentUserId,
                          placedTiles: placedLetters,
                          isHost: widget.isHost,
                        );

                        final newLetters =
                            await _gameManager.drawLettersFromPool(
                          widget.gameId,
                          placedLetters.length,
                        );

                        final letterKey =
                            widget.isHost ? 'hostLetters' : 'guestLetters';
                        await FirebaseFirestore.instance
                            .collection('games')
                            .doc(widget.gameId)
                            .update({
                          letterKey: newLetters,
                          "isFirstMove": false,
                        });

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
                    });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleTileTap(int row, int col) {
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
      _selectedLetterChar = '';
    });

    _savePlacedLetterToFirestore(row, col, _selectedLetterChar!);
  }

  Future<void> _savePlacedLetterToFirestore(
      int row, int col, String letter) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('games').doc(widget.gameId);
      final placedKey = '$row-$col';

      await docRef.set({
        'placedLetters.$placedKey': {
          'letter': letter,
          'row': row,
          'col': col,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      print('Harf Firestore\'a kaydedilemedi: $e');
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
