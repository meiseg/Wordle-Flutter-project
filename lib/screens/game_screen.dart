import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/generate_words.dart'; // Assuming this is the correct path for generate_word.dart

class WordleGameScreen extends StatefulWidget {
  final String userId;

  const WordleGameScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _WordleGameScreenState createState() => _WordleGameScreenState();
}

class _WordleGameScreenState extends State<WordleGameScreen> {
  static const int maxAttempts = 6;
  static const int wordLength = 5;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String currentGuess = '';
  List<String> guesses = [];
  late String targetWord;
  bool gameOver = false;
  int currentScore = 600; // Initial score for the game
  bool isLoading = true; // To track when the word is being fetched

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await _fetchUserData();
    await _fetchTargetWord();
  }

  Future<void> _fetchUserData() async {
    final userDoc = _firestore.collection('profiles').doc(widget.userId);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'totalWords': 0,
        'score': 0,
      });
    }
  }

  Future<void> _fetchTargetWord() async {
    setState(() {
      isLoading = true; // Start loading until we fetch the word
    });

    try {
      // Fetch a 5-letter Spanish word
      final word = await fetchFiveLetterSpanishWord();

      setState(() {
        targetWord = word ?? 'apple'; // Fallback to 'apple' if no word is found
        isLoading = false; // Stop loading
      });

      // Debugging: Print the fetched word
      print('Fetched target word: $targetWord');
    } catch (e) {
      setState(() {
        targetWord = 'apple'; // Fallback word
        isLoading = false; // Stop loading
      });

      // Debugging: Print the error
      print('Error fetching target word: $e');
    }
  }

  Future<void> _updateUserStats(bool won) async {
    final userDoc = _firestore.collection('profiles').doc(widget.userId);

    await userDoc.update({
      'totalWords': FieldValue.increment(1),
      if (won) 'score': FieldValue.increment(currentScore),
    });
  }

  void _checkGuess() {
    if (currentGuess.length < wordLength || gameOver) return;

    setState(() {
      guesses.add(currentGuess);
      if (currentGuess == targetWord) {
        gameOver = true;
        _showGameResult('Congratulations! You guessed the word.');
        _updateUserStats(true);
      } else {
        currentScore -= 100; // Deduct score for incorrect guess
        if (guesses.length == maxAttempts) {
          gameOver = true;
          _showGameResult('Game Over! The word was $targetWord.');
          _updateUserStats(false);
        }
      }
      currentGuess = '';
    });
  }

  void _showGameResult(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        content: Text(
          'Your final score is $currentScore. Play again or return to the menu.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                guesses.clear();
                currentGuess = '';
                _fetchTargetWord(); // Fetch a new target word when playing again
                currentScore = 600; // Reset score for the new game
                gameOver = false;
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade100, Colors.white],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Score and Title Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Score: $currentScore',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Game Grid
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _buildGameGrid(),
                ),
              ),
              
              // Keyboard
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                  child: _buildKeyboard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: wordLength,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: maxAttempts * wordLength,
        itemBuilder: (context, index) {
          final row = index ~/ wordLength;
          final col = index % wordLength;
          String letter = '';

          if (row < guesses.length) {
            letter = guesses[row][col];
          } else if (row == guesses.length && col < currentGuess.length) {
            letter = currentGuess[col];
          }

          return LetterTile(
            letter: letter,
            status: _getTileStatus(row, col),
          );
        },
      ),
    );
  }

  String _getTileStatus(int row, int col) {
    if (row >= guesses.length) return 'empty';

    final guess = guesses[row];
    final targetWordChars = targetWord.split('');
    final letter = guess[col];

    if (targetWordChars[col] == letter) return 'correct';
    if (targetWordChars.contains(letter)) return 'present';
    return 'absent';
  }

  Widget _buildKeyboard() {
    const keys = [
      ['Q','W','E','R','T','Y','U','I','O','P'],
      ['A','S','D','F','G','H','J','K','L','Ñ'],
      ['Z','X','C','V','B','N','M','⌫'],
    ];

    final accentOptions = {
      'A': ['Á', 'À', 'Â', 'Ä', 'Ã'],
      'E': ['É', 'È', 'Ê', 'Ë'],
      'I': ['Í', 'Ì', 'Î', 'Ï'],
      'O': ['Ó', 'Ò', 'Ô', 'Ö', 'Õ'],
      'U': ['Ú', 'Ù', 'Û', 'Ü'],
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...keys.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((key) {
                  // Special styling for backspace key
                  if (key == '⌫') {
                    return Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ElevatedButton(
                          onPressed: () => _onKeyPressed(key),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                            backgroundColor: Colors.red.shade300,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.backspace_outlined, size: 22),
                        ),
                      ),
                    );
                  }
                  
                  if (accentOptions.containsKey(key)) {
                    return Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _buildAccentKey(key, accentOptions[key]!),
                      ),
                    );
                  } else {
                    return Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ElevatedButton(
                          onPressed: () => _onKeyPressed(key),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                            backgroundColor: Colors.blue.shade50,
                            foregroundColor: Colors.black87,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            key,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }).toList(),
              ),
            );
          }).toList(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _checkGuess,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green.shade400,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccentKey(String key, List<String> accents) {
    return PopupMenuButton<String>(
      onSelected: (value) => _onKeyPressed(value),
      position: PopupMenuPosition.under,
      offset: const Offset(0, -10),
      child: ElevatedButton(
        onPressed: () => _onKeyPressed(key),
        onLongPress: () {}, // Disable default long-press behavior
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          backgroundColor: Colors.blue.shade50,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          key,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      itemBuilder: (context) {
        return accents
            .map((accent) => PopupMenuItem(
                  value: accent.toLowerCase(),
                  height: 40,
                  child: Text(
                    accent,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ))
            .toList();
      },
    );
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (key == '⌫') {
        if (currentGuess.isNotEmpty) {
          currentGuess = currentGuess.substring(0, currentGuess.length - 1);
        }
      } else if (currentGuess.length < wordLength && !gameOver) {
        currentGuess += key.toLowerCase();
      }
    });
  }
}

class LetterTile extends StatelessWidget {
  final String letter;
  final String status;

  const LetterTile({
    Key? key,
    required this.letter,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _getTileColor(),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getTileColor().withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: status == 'empty' ? Colors.black54 : Colors.white,
        ),
      ),
    );
  }

  Color _getTileColor() {
    switch (status) {
      case 'correct':
        return Colors.green.shade600;
      case 'present':
        return Colors.orange.shade600;
      case 'absent':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade200;
    }
  }
}
