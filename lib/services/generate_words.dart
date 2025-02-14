import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

Future<String> fetchFiveLetterSpanishWord() async {
  try {
    final databaseRef = FirebaseDatabase.instance.ref(); // Root reference
    final snapshot = await databaseRef.get();

    if (snapshot.exists) {
      // Cast snapshot value to a list
      List<dynamic> words = snapshot.value as List<dynamic>;

      // Filter 5-letter words
      List<String> fiveLetterWords =
      words.where((word) => word != null && word.length == 5).cast<String>().toList();

      if (fiveLetterWords.isNotEmpty) {
        // Return a random 5-letter word
        return fiveLetterWords[Random().nextInt(fiveLetterWords.length)];
      } else {
        throw Exception('No 5-letter words found');
      }
    } else {
      throw Exception('No data found in database');
    }
  } catch (e) {
    print('Error fetching target word: $e');
    return 'error'; // Fallback word
  }
}
