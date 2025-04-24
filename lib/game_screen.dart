import 'package:flutter/material.dart';

enum TileType {
  normal,
  doubleLetter,
  tripleLetter,
  doubleWord,
  tripleWord,
  start
}

class GameBoard {
  static const int boardSize = 15;

  static final List<List<TileType>> boardLayout = [
    [
      // 1. satır
      TileType.normal,
      TileType.normal,
      TileType.tripleWord,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.tripleWord,
      TileType.normal,
      TileType.normal
    ],
    [
      // 2. satır
      TileType.normal,
      TileType.tripleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.tripleLetter,
      TileType.normal
    ],
    [
      // 3. satır
      TileType.tripleWord,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleWord,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.tripleWord
    ],
    [
      // 4. satır
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleWord,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleWord,
      TileType.normal,
      TileType.normal,
      TileType.normal
    ],
    [
      // 5. satır
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.tripleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.tripleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal
    ],
    [
      // 6. satır
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter
    ],
    [
      // 7. satır
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal
    ],
    [
      // 8. satır
      TileType.normal,
      TileType.normal,
      TileType.doubleWord,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.start,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleWord,
      TileType.normal,
      TileType.normal
    ],
    [
      // 9. satır
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal
    ],
    [
      // 10. satır
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter
    ],
    [
      // 11. satır
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.tripleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.tripleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal
    ],
    [
      // 12. satır
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleWord,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleWord,
      TileType.normal,
      TileType.normal,
      TileType.normal
    ],
    [
      // 13. satır
      TileType.tripleWord,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleWord,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.tripleWord
    ],
    [
      // 14. satır
      TileType.normal,
      TileType.tripleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.tripleLetter,
      TileType.normal
    ],
    [
      // 15. satır
      TileType.normal,
      TileType.normal,
      TileType.tripleWord,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.normal,
      TileType.doubleLetter,
      TileType.normal,
      TileType.normal,
      TileType.tripleWord,
      TileType.normal,
      TileType.normal
    ]
  ];
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900.withOpacity(0.9),
        title: const Text(
          "KELİME MAYINLARI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // TODO: Ayarlar ekranına yönlendir
            },
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

                      return Container(
                        margin: const EdgeInsets.all(0.2),
                        decoration: BoxDecoration(
                          color: _getTileColor(type),
                          border: Border.all(
                              color: Colors.grey.shade700.withOpacity(0.8)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(child: _getTileLabel(type)),
                      );
                    },
                  ),
                ),
              ),
            ),
            BottomPanel(
              letters: const [
                {'char': 'E', 'point': 1},
                {'char': 'N', 'point': 1},
                {'char': 'O', 'point': 2},
                {'char': 'T', 'point': 1},
                {'char': 'N', 'point': 1},
                {'char': 'R', 'point': 1},
                {'char': 'A', 'point': 1},
              ],
              myUsername: "Sen",
              myScore: 25,
              opponentUsername: "Atakan",
              opponentScore: 17,
              remainingLetters: 86,
            ),
          ],
        ),
      ),
    );
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

class BottomPanel extends StatelessWidget {
  final List<Map<String, dynamic>> letters;
  final String myUsername;
  final int myScore;
  final String opponentUsername;
  final int opponentScore;
  final int remainingLetters;

  const BottomPanel({
    super.key,
    required this.letters,
    required this.myUsername,
    required this.myScore,
    required this.opponentUsername,
    required this.opponentScore,
    required this.remainingLetters,
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
              Text('$opponentScore: $opponentUsername',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: letters.map((letter) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.8),
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
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${letter['point']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
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
                children: const [
                  Icon(Icons.more_vert, color: Colors.white),
                  Text("Daha",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
