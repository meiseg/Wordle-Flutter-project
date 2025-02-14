import 'dart:convert'; // For jsonEncode and jsonDecode
import 'dart:math'; // Import for random number generation
import 'dart:io'; // Import for File

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flip_card/flip_card.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:path_provider/path_provider.dart'; // Import for path_provider
import '../services/database_helper.dart'; // Import your database helper

class WordMasterScreen extends StatefulWidget {
  const WordMasterScreen({super.key});

  @override
  State<WordMasterScreen> createState() => _WordMasterScreenState();
}

class _WordMasterScreenState extends State<WordMasterScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> categories = ['Common', 'Advanced', 'Phrases'];
  final List<Map<String, dynamic>> savedWords = []; // Change type to dynamic

  // Initialize word lists as empty
  List<Map<String, dynamic>> commonWords = [];
  List<Map<String, dynamic>> advancedWords = [];
  List<Map<String, dynamic>> phrases = [];

  @override
  void initState() {
    super.initState();
    _fetchWordsFromDatabase(); // Fetch words when the screen initializes
  }

  void _fetchWordsFromDatabase() async {
    // Fetch words from the database
    DatabaseHelper dbHelper = DatabaseHelper();
    commonWords = await dbHelper.getCommonWords(); // Fetch common words
    advancedWords = await dbHelper.getAdvancedWords(); // Fetch advanced words
    phrases = await dbHelper.getPhrases(); // Fetch phrases

    // Debugging: Print the fetched words
    print("Common Words: $commonWords");
    print("Advanced Words: $advancedWords");
    print("Phrases: $phrases");

    // Generate initial words
    _generateNewWords();

    setState(() {}); // Update the UI
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _generateNewWords() {
    // Generate new words for each category
    setState(() {
      commonWords = _getRandomWords(commonWords, 10);
      advancedWords = _getRandomWords(advancedWords, 10);
      phrases = _getRandomWords(phrases, 10);
    });
  }

  List<Map<String, dynamic>> _getRandomWords(List<Map<String, dynamic>> words, int count) {
    final random = Random();
    List<Map<String, dynamic>> selectedWords = [];

    // Create a mutable copy of the list
    List<Map<String, dynamic>> mutableWords = List.from(words);

    // Shuffle the list and take the first 'count' words
    mutableWords.shuffle(random);
    for (int i = 0; i < count && i < mutableWords.length; i++) {
      selectedWords.add(mutableWords[i]);
    }
    return selectedWords;
  }

  void _toggleSaveWord(String word, String definition) {
    setState(() {
      // Check if the word is already saved
      final existingWord = savedWords.firstWhere(
        (savedWord) => savedWord['word'] == word,
        orElse: () => {}
      );

      if (existingWord.isNotEmpty) {
        // If it exists, remove it
        savedWords.removeWhere((savedWord) => savedWord['word'] == word);
      } else {
        // If it doesn't exist, add it
        savedWords.add({'word': word, 'definition': definition});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Word Master'),
          bottom: TabBar(
            tabs: categories.map((category) => Tab(text: category)).toList(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavedWordsScreen(savedWords: savedWords)),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView( // Wrap the Column in a SingleChildScrollView
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: _generateNewWords,
                  child: const Text('Generate New Words'),
                ),
              ),
              // Use Expanded if you want to fill the remaining space
              Container(
                height: 600, // Set a fixed height for the TabBarView
                child: TabBarView(
                  children: [
                    _buildCategorySection(commonWords),
                    _buildCategorySection(advancedWords),
                    _buildCategorySection(phrases),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(List<Map<String, dynamic>> words) {
    return ListView.builder(
      itemCount: words.length,
      itemBuilder: (context, index) {
        return _buildWordCard(words[index]['word']!, words[index]['definition']!);
      },
    );
  }

  Widget _buildWordCard(String word, String definition) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      front: _buildFrontCard(word, definition),
      back: _buildBackCard(definition),
    );
  }

  Widget _buildFrontCard(String word, String definition) {
    bool isSaved = savedWords.any((savedWord) => savedWord['word'] == word);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 180, // Increased height
        width: 100, // Set a fixed width
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.shade50,
        ),
        child: Stack( // Use Stack to overlay icons
          children: [
            Center( // Center the word text
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    word,
                    textAlign: TextAlign.center, // Center the text
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('(word)', textAlign: TextAlign.center), // Center the subtitle
                ],
              ),
            ),
            Positioned( // Position the icons at the top right
              top: 8,
              right: 14,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up_outlined, color: Colors.blue),
                    onPressed: () async {
                      await _playAudio(word); // Play audio logic here
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      _toggleSaveWord(word, definition); // Toggle save state
                    },
                    child: Icon(
                      Icons.favorite,
                      color: isSaved ? Colors.red : Colors.grey, // Change color based on saved state
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(String definition) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 180, // Increased height
        width: 100, // Set a fixed width
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.shade50,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Definition:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                definition,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _playAudio(String word) async {
    if (word.isEmpty) {
      print('No word provided for audio playback.');
      return;
    }

    final String url = '';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'input': {'text': word},
        'voice': {'languageCode': 'es-ES', 'name': 'es-ES-Standard-A'},
        'audioConfig': {'audioEncoding': 'MP3'},
      }),
    );

    if (response.statusCode == 200) {
      final audioContent = jsonDecode(response.body)['audioContent'];
      final bytes = base64Decode(audioContent);
      
      // Save bytes to a temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/audio.mp3');
      await file.writeAsBytes(bytes);
      
      // Use AudioSource.uri to play the audio
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.file(file.path)));
      _audioPlayer.play();
    } else {
      print('Failed to fetch audio: ${response.statusCode}');
      print('Response body: ${response.body}'); // Log the response body for debugging
    }
  }
}

class SavedWordsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> savedWords; // Change type to dynamic

  const SavedWordsScreen({Key? key, required this.savedWords}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Words'),
      ),
      body: ListView.builder(
        itemCount: savedWords.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(savedWords[index]['word']!),
            subtitle: Text(savedWords[index]['definition']!),
          );
        },
      ),
    );
  }
}