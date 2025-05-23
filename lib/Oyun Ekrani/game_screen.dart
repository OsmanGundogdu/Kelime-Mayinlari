import 'dart:async';
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

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final GameManager _gameManager = GameManager();
  List<Map<String, dynamic>> _playerLetters = [];
  int? guestScore;
  int? hostScore;
  String? hostUsername;
  String? guestUsername;
  String? currentTurn;
  bool isFirstMove = true;
  final List<String> _disabledLetters = [];
  Timer? _timer;
  int remainingSeconds = 0;
  bool isMyTurn = false;
  int? _remainingLetterCount;
  bool _isLetterCountLoading = true;
  Widget? _bottomPanel;
  DateTime? _lastTimerUpdate;

  Map<String, dynamic> placedTiles = {};
  Map<String, dynamic> boardTiles = {};
  String _selectedLetterChar = '';
  int _consecutivePassCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _drawInitialLetters();
    fetchGameData();
    startCountdown();

    _gameManager.getRemainingLetterCount(widget.gameId).then((count) {
      setState(() {
        _remainingLetterCount = count;
        _isLetterCountLoading = false;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  void startCountdown() async {
    final doc = await FirebaseFirestore.instance
        .collection('games')
        .doc(widget.gameId)
        .get();

    final data = doc.data();
    if (data == null) return;

    final int duration = (data['duration'] ?? 2) * 60;
    final String currentTurn = data['turn'] ?? 'host';
    final bool isMyTurn = (widget.isHost && currentTurn == 'host') ||
        (!widget.isHost && currentTurn == 'guest');

    if (isMyTurn) {
      final String startTimeKey =
          widget.isHost ? 'hostStartTime' : 'guestStartTime';
      final Timestamp? startTime = data[startTimeKey];

      if (startTime == null) {
        // İlk hamle için startTime'ı güncelle
        await FirebaseFirestore.instance
            .collection('games')
            .doc(widget.gameId)
            .update({
          startTimeKey: Timestamp.now(),
        });
        setState(() {
          remainingSeconds = duration;
          _lastTimerUpdate = DateTime.now();
        });
      } else {
        final int startTimestamp = startTime.seconds;
        final int now = Timestamp.now().seconds;
        final int elapsed = now - startTimestamp;

        setState(() {
          remainingSeconds = duration - elapsed;
          _lastTimerUpdate = DateTime.now();
        });
      }

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (remainingSeconds > 0) {
          setState(() {
            remainingSeconds--;
          });
        } else {
          timer.cancel();
          handleTimeOut();
        }
      });
    } else {
      stopLocalCountdown();
    }
  }

  void startLocalCountdown() {
    _timer?.cancel();
    _lastTimerUpdate = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        handleTimeOut();
      }
    });
  }

  void stopLocalCountdown() {
    _timer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (isMyTurn && _lastTimerUpdate != null) {
        final now = DateTime.now();
        final elapsedSeconds = now.difference(_lastTimerUpdate!).inSeconds;
        setState(() {
          remainingSeconds = remainingSeconds - elapsedSeconds;
          if (remainingSeconds <= 0) {
            remainingSeconds = 0;
            handleTimeOut();
          }
        });
        startLocalCountdown();
      }
    } else if (state == AppLifecycleState.paused) {
      stopLocalCountdown();
    }
  }

  void handleTimeOut() async {
    final gameRef =
        FirebaseFirestore.instance.collection('games').doc(widget.gameId);
    final doc = await gameRef.get();
    final data = doc.data();
    if (data == null) return;

    final surrenderingUserId =
        widget.isHost ? data['hostUserID'] : data['guestUserID'];
    final winnerUserId =
        widget.isHost ? data['guestUserID'] : data['hostUserID'];

    // Oyunu bitir ve sonuçları kaydet
    await gameRef.update({
      'isGameOver': true,
      'isGameStarted': false,
      'winner': widget.isHost ? 'guest' : 'host',
      'scores': {
        surrenderingUserId: 0,
        winnerUserId: 1,
      },
    });

    // Kullanıcı istatistiklerini güncelle
    final usersCollection = FirebaseFirestore.instance.collection('users');
    await usersCollection.doc(surrenderingUserId).update({
      'gameplayed': FieldValue.increment(1),
    });

    await usersCollection.doc(winnerUserId).update({
      'gameplayed': FieldValue.increment(1),
      'gamewon': FieldValue.increment(1),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Süreniz doldu, oyunu kaybettiniz.')),
      );
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }

  void _drawInitialLetters() async {
    final String gameId = widget.gameId;
    final bool isHost = widget.isHost;
    final gameDoc = FirebaseFirestore.instance.collection('games').doc(gameId);
    final snapshot = await gameDoc.get();

    final key = isHost ? 'hostLetters' : 'guestLetters';

    if (snapshot.exists) {
      final data = snapshot.data()!;

      // ✅ letter alanı yoksa, oluştur
      if (!data.containsKey('letter')) {
        await _gameManager.generateLetterPointMap(gameId);
      }

      // ✅ letterPool yoksa, oluştur
      if (!data.containsKey('letterPool')) {
        await _gameManager.generateAndSaveLetterPool(gameId);
      }

      // Her iki oyuncunun harflerini kontrol et
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
        final currentTurn = data['turn'] ?? 'host';
        final int duration = (data['duration'] ?? 2) * 60;

        setState(() {
          hostUsername = data['hostUsername'];
          guestUsername = data['guestUsername'];
          hostScore =
              int.tryParse(data['scores'][hostID]?.toString() ?? '0') ?? 0;
          guestScore =
              int.tryParse(data['scores'][guestID]?.toString() ?? '0') ?? 0;
          isFirstMove = data['isFirstMove'] ?? true;
          this.currentTurn = currentTurn;
          isMyTurn = (widget.isHost && currentTurn == 'host') ||
              (!widget.isHost && currentTurn == 'guest');
        });

        // Süre sayacını başlat
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          if (!mounted) {
            timer.cancel();
            return;
          }

          // Her saniye güncel veriyi al
          final currentDoc = await FirebaseFirestore.instance
              .collection('games')
              .doc(widget.gameId)
              .get();

          final currentData = currentDoc.data();
          if (currentData == null) return;

          final currentTurn = currentData['turn'] ?? 'host';
          final hostStartTime = currentData['hostStartTime'];
          final guestStartTime = currentData['guestStartTime'];

          if (mounted) {
            setState(() {
              if (currentTurn == 'host' && hostStartTime != null) {
                final int startTimestamp = hostStartTime.seconds;
                final int now = Timestamp.now().seconds;
                final int elapsed = now - startTimestamp;
                remainingSeconds = duration - elapsed;
              } else if (currentTurn == 'guest' && guestStartTime != null) {
                final int startTimestamp = guestStartTime.seconds;
                final int now = Timestamp.now().seconds;
                final int elapsed = now - startTimestamp;
                remainingSeconds = duration - elapsed;
              }

              if (remainingSeconds <= 0) {
                timer.cancel();
                handleTimeOut();
              }
            });
          }
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
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('games')
              .doc(widget.gameId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text(
                "KELİME MAYINLARI",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final currentTurn = data['turn'] ?? 'host';
            final isMyTurn = (widget.isHost && currentTurn == 'host') ||
                (!widget.isHost && currentTurn == 'guest');

            return Column(
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
                  isMyTurn ? 'Senin sıran!' : 'Rakibinin sırası...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                _formatTime(remainingSeconds),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
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
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('games')
                        .doc(widget.gameId)
                        .collection('boardLetters')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Tahtadaki harfleri güncelle
                      boardTiles.clear();
                      for (var doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
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

                      return GridView.builder(
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
                                    color:
                                        Colors.grey.shade700.withOpacity(0.8)),
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
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            if (_bottomPanel == null && !_isLetterCountLoading)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('games')
                    .doc(widget.gameId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final currentTurn = data['turn'] ?? 'host';
                  final isMyTurn = (widget.isHost && currentTurn == 'host') ||
                      (!widget.isHost && currentTurn == 'guest');

                  return BottomPanel(
                    letters: _playerLetters,
                    myUsername: hostUsername!,
                    myScore: hostScore ?? 0,
                    opponentUsername: guestUsername!,
                    opponentScore: guestScore ?? 0,
                    remainingLetters: _remainingLetterCount!,
                    selectedLetterChar: _selectedLetterChar,
                    onLetterTap: _handleLetterTap,
                    onSubmitPressed: () async {
                      try {
                        final isHostTurn =
                            currentTurn == 'host' && widget.isHost;
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

                        final newLetters =
                            await _gameManager.drawLettersFromPool(
                          widget.gameId,
                          placedLetters.length,
                        );

                        final updatedLetters = [
                          ...remainingLetters,
                          ...newLetters
                        ];

                        final newTurn = widget.isHost ? 'guest' : 'host';
                        await FirebaseFirestore.instance
                            .collection('games')
                            .doc(widget.gameId)
                            .update({
                          letterKey: updatedLetters,
                          "isFirstMove": false,
                          'turn': newTurn,
                          '${newTurn}StartTime': Timestamp.now(),
                        });

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
                      stopLocalCountdown();
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
                    isMyTurn: isMyTurn,
                  );
                },
              ),
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
      totalPoints += letterPoints[char] ?? 0;
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

    // Puanın yarısını al
    totalPoints = (totalPoints / 2).round();

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

    // Pas geçme sayısını güncelle
    if (currentTurn == (widget.isHost ? 'host' : 'guest')) {
      _consecutivePassCount++;
    } else {
      _consecutivePassCount = 1;
    }

    // Eğer 2 kez üst üste pas geçildiyse oyunu bitir
    if (_consecutivePassCount >= 2) {
      final surrenderingUserId =
          widget.isHost ? gameData['hostUserID'] : gameData['guestUserID'];
      final winnerUserId =
          widget.isHost ? gameData['guestUserID'] : gameData['hostUserID'];
      final winnerKey = widget.isHost ? 'guest' : 'host';

      await gameDocRef.update({
        'isGameOver': true,
        'isGameStarted': false,
        'winner': winnerKey,
        'scores': {
          surrenderingUserId: 0,
          winnerUserId: 1,
        },
      });

      final usersCollection = FirebaseFirestore.instance.collection('users');
      await usersCollection.doc(surrenderingUserId).update({
        'gameplayed': FieldValue.increment(1),
      });

      await usersCollection.doc(winnerUserId).update({
        'gameplayed': FieldValue.increment(1),
        'gamewon': FieldValue.increment(1),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  '2 kez üst üste pas geçtiğiniz için oyunu kaybettiniz.')),
        );
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
      return;
    }

    // Karşı oyuncunun süresini sıfırla ve yeniden başlat
    final duration = (gameData['duration'] ?? 2) * 60;
    await gameDocRef.update({
      'turn': newTurn,
      '${newTurn}StartTime': Timestamp.now(),
    });

    if (mounted) {
      setState(() {
        remainingSeconds = duration;
        _lastTimerUpdate = DateTime.now();
      });
    }

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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oyunu teslim ettiniz.')),
      );

      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }
}

class LetterTile {
  final String char;
  final int point;

  LetterTile(this.char, this.point);
}
