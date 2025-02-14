import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'words.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE words(id INTEGER PRIMARY KEY, category TEXT, word TEXT, definition TEXT, audioPath TEXT)',
        );
        // Populate the database with initial data if empty
        await _populateDatabase(db);
      },
    );
  }

  Future<void> _populateDatabase(Database db) async {
    // Check if the database is already populated
    final List<Map<String, dynamic>> existingWords = await db.query('words');
    if (existingWords.isNotEmpty) return; // Exit if already populated

    List<Map<String, dynamic>> initialWords = [
      // Common Words
      {'category': 'Common Words', 'word': 'Adiós', 'definition': 'A common farewell in Spanish, meaning "Goodbye".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'Por favor', 'definition': 'A polite phrase used to say "Please".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'Gracias', 'definition': 'A way to express gratitude, meaning "Thank you".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'Lo siento', 'definition': 'A phrase used to apologize, meaning "I’m sorry".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'Buenos días', 'definition': 'A morning greeting, meaning "Good morning".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'Buenas tardes', 'definition': 'An afternoon greeting, meaning "Good afternoon".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'Buenas noches', 'definition': 'An evening or night greeting, meaning "Good night".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'Sí', 'definition': 'The Spanish word for "Yes".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'No', 'definition': 'The Spanish word for "No".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'Amigo', 'definition': 'A word for "Friend", commonly used informally.', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'Familia', 'definition': 'The Spanish word for "Family".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'Comida', 'definition': 'A word referring to "Food" or a meal.', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'Agua', 'definition': 'The Spanish word for "Water".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'Casa', 'definition': 'A word meaning "House" or "Home".', 'audioPath': ''},

      {'category': 'Common Words', 'word': 'de', 'definition': 'Indicates origin or possession, meaning "of/from".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'la', 'definition': 'The definite article used for feminine singular nouns, meaning "the".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'que', 'definition': 'Used to introduce relative clauses, meaning "that/which".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'el', 'definition': 'The definite article used for masculine singular nouns, meaning "the".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'en', 'definition': 'Indicates location or time, meaning "in/on".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'y', 'definition': 'A conjunction used to connect words or phrases, meaning "and".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'a', 'definition': 'Indicates direction or destination, meaning "to/at".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'los', 'definition': 'The definite article used for masculine plural nouns, meaning "the".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'se', 'definition': 'Refers to oneself or indicates reflexive actions, meaning "oneself".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'del', 'definition': 'A contraction of "de" and "el", meaning "from the".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'las', 'definition': 'The definite article used for feminine plural nouns, meaning "the".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'un', 'definition': 'An indefinite article used for masculine singular nouns, meaning "a/an".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'por', 'definition': 'Indicates cause, reason, or means, meaning "by/for/through".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'con', 'definition': 'Indicates accompaniment or association, meaning "with".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'no', 'definition': 'Used to negate verbs or phrases, meaning "no/not".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'una', 'definition': 'An indefinite article used for feminine singular nouns, meaning "a/an/one".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'su', 'definition': 'Indicates possession, meaning "his/her/its/your".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'para', 'definition': 'Indicates purpose or destination, meaning "for/to/in order to".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'es', 'definition': 'The third person singular form of "ser", meaning "is".', 'audioPath': ''},
      {'category': 'Common Words', 'word': 'al', 'definition': 'A contraction of "a" and "el", meaning "to the".', 'audioPath': ''},

      // Advanced Words
      {'category': 'Advanced Words', 'word': 'Ejemplar', 'definition': 'A term used to describe something that serves as a model or example, meaning "Exemplary".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Espléndido', 'definition': 'Something magnificent or splendid, meaning "Splendid".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Perspicaz', 'definition': 'Someone sharp or insightful, meaning "Perceptive".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Meticuloso', 'definition': 'A term describing someone very careful, meaning "Meticulous".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Innovador', 'definition': 'Something or someone pioneering, meaning "Innovative".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Sofisticado', 'definition': 'Describes elegance or complexity, meaning "Sophisticated".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Ambicioso', 'definition': 'Someone with big aspirations, meaning "Ambitious".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Resiliencia', 'definition': 'The ability to recover, meaning "Resilience".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Paralelogramo', 'definition': 'A geometric shape, meaning "Parallelogram".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Transparente', 'definition': 'Something clear or open, meaning "Transparent".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Increíble', 'definition': 'Something hard to believe, meaning "Incredible".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Inmutable', 'definition': 'Describes something unchanging, meaning "Immutable".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Simbólico', 'definition': 'Represents something abstract, meaning "Symbolic".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Eficiencia', 'definition': 'The quality of being efficient, meaning "Efficiency".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Versatilidad', 'definition': 'The quality of adaptability, meaning "Versatility".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'Complejidad', 'definition': 'The state of being complex, meaning "Complexity".', 'audioPath': ''},

      {'category': 'Advanced Words', 'word': 'nuevo/a', 'definition': 'Describes something that has recently come into existence or is being introduced for the first time, meaning "new".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'viejo/a', 'definition': 'Refers to something that has existed for a long time or is no longer new, meaning "old".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'feliz', 'definition': 'Describes a state of joy or contentment, meaning "happy".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'triste', 'definition': 'Indicates a feeling of sorrow or unhappiness, meaning "sad".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'enfermo/a', 'definition': 'Refers to a state of being unwell or ill, meaning "sick".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'bien', 'definition': 'Describes a state of being good or satisfactory, meaning "well".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'grande', 'definition': 'Indicates a large size or magnitude, meaning "big".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'chico/a', 'definition': 'Refers to something small in size, often used informally in Latin America, meaning "small".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'pequeño/a', 'definition': 'Describes something that is small in size, often used in Spain, meaning "small".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'bueno/a', 'definition': 'Indicates a positive quality or state, meaning "good".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'malo/a', 'definition': 'Describes something that is of poor quality or undesirable, meaning "bad".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'sin', 'definition': 'Indicates the absence of something, meaning "without".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'con', 'definition': 'Indicates the presence of something together with another, meaning "with".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'mucho', 'definition': 'Refers to a large quantity or degree, meaning "a lot".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'poco', 'definition': 'Indicates a small quantity or degree, meaning "a little bit".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'hermoso/a', 'definition': 'Describes something that is visually appealing or beautiful, meaning "beautiful".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'feo/a', 'definition': 'Indicates something that is unattractive or unpleasant in appearance, meaning "ugly".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'fácil', 'definition': 'Describes something that is not difficult to do or understand, meaning "easy".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'fantástico/a', 'definition': 'Indicates something that is extraordinarily good or impressive, meaning "fantastic".', 'audioPath': ''},
      {'category': 'Advanced Words', 'word': 'automático/a', 'definition': 'Refers to something that operates automatically or without human intervention, meaning "automatic".', 'audioPath': ''},


      // Phrases
      {'category': 'Phrases', 'word': '¿Cómo estás?', 'definition': 'A way to ask someone how they are, meaning "How are you?".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¿Qué pasa?', 'definition': 'A casual greeting meaning "What’s up?".', 'audioPath': ''},
      {'category': 'Phrases', 'word': 'Mucho gusto', 'definition': 'A polite way to express pleasure in meeting someone, meaning "Nice to meet you".', 'audioPath': ''},
      {'category': 'Phrases', 'word': 'No entiendo', 'definition': 'A way to say you do not understand, meaning "I don’t understand".', 'audioPath': ''},
      {'category': 'Phrases', 'word': 'Tengo hambre', 'definition': 'A way to express hunger, meaning "I’m hungry".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¿Dónde está el baño?', 'definition': 'A question asking for the bathroom, meaning "Where is the bathroom?".', 'audioPath': ''},
      {'category': 'Phrases', 'word': 'No hay problema', 'definition': 'A way to reassure, meaning "No problem".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¿Puedo ayudarte?', 'definition': 'A way to offer help, meaning "Can I help you?".', 'audioPath': ''},
      {'category': 'Phrases', 'word': 'Estoy perdido', 'definition': 'A way to say you are lost, meaning "I’m lost".', 'audioPath': ''},
      {'category': 'Phrases', 'word': 'Voy a la tienda', 'definition': 'A way to state your intention to go to the store, meaning "I’m going to the store".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¿Cuánto cuesta?', 'definition': 'A way to ask about the price, meaning "How much does it cost?".', 'audioPath': ''},
      {'category': 'Phrases', 'word': 'Hasta luego', 'definition': 'A farewell meaning "See you later".', 'audioPath': ''},
      {'category': 'Phrases', 'word': 'Lo siento', 'definition': 'A way to express regret, meaning "I’m sorry".', 'audioPath': ''},
      {'category': 'Phrases', 'word': 'De nada', 'definition': 'A polite response to gratitude, meaning "You’re welcome".', 'audioPath': ''},
      {'category': 'Phrases', 'word': 'Por supuesto', 'definition': 'A way to affirm something, meaning "Of course".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¿Qué hora es?', 'definition': 'A way to ask for the time, meaning "What time is it?".', 'audioPath': ''},
      {'category': 'Phrases', 'word': 'Estoy cansado/cansada', 'definition': 'A way to express tiredness, meaning "I’m tired".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¿Cómo te llamas?', 'definition': 'A way to ask someone their name, meaning "What is your name?".', 'audioPath': ''},
      {'category': 'Phrases', 'word': 'Me gustaría...', 'definition': 'A way to express a desire, meaning "I would like...".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¿Puedes ayudarme?', 'definition': 'A way to ask for help, meaning "Can you help me?".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¿Dónde vives?', 'definition': 'A way to ask where someone lives, meaning "Where do you live?".', 'audioPath': ''},
      {'category': 'Phrases', 'word': 'Estoy aquí de vacaciones', 'definition': 'A way to say you are here on vacation, meaning "I am here on vacation".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¿Qué recomiendas?', 'definition': 'A way to ask for recommendations, meaning "What do you recommend?".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¿Hay un restaurante cerca?', 'definition': 'A way to ask if there is a restaurant nearby, meaning "Is there a restaurant nearby?".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¿Tienes wifi?', 'definition': 'A way to ask if there is wifi available, meaning "Do you have wifi?".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¿Puedo tomar una foto?', 'definition': 'A way to ask if you can take a photo, meaning "Can I take a photo?".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¿Dónde puedo comprar...?', 'definition': 'A way to ask where you can buy something, meaning "Where can I buy...?".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¡Feliz cumpleaños!', 'definition': 'A way to wish someone a happy birthday, meaning "Happy birthday!".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¡Buena suerte!', 'definition': 'A way to wish someone good luck, meaning "Good luck!".', 'audioPath': ''},
      {'category': 'Phrases', 'word': '¡Qué bonito!', 'definition': 'A way to express admiration, meaning "How beautiful!".', 'audioPath': ''},
    ];
  

    for (var word in initialWords) {
      await db.insert('words', word, conflictAlgorithm: ConflictAlgorithm.replace);
      print("Inserted: ${word['word']}"); // Debugging statement
    }
  }

  Future<void> insertWord(Map<String, dynamic> word) async {
    final db = await database;
    await db.insert('words', word, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getWords(String category) async {
    final db = await database;
    return await db.query('words', where: 'category = ?', whereArgs: [category]);
  }

  Future<List<Map<String, dynamic>>> getCommonWords() async {
    return await getWords('Common Words');
  }

  Future<List<Map<String, dynamic>>> getAdvancedWords() async {
    return await getWords('Advanced Words');
  }

  Future<List<Map<String, dynamic>>> getPhrases() async {
    return await getWords('Phrases');
  }

  Future<String> getRandomWord() async {
    final db = await database;
    final List<Map<String, dynamic>> words = await db.query('words');
    if (words.isNotEmpty) {
      return words[Random().nextInt(words.length)]['word'];
    }
    throw Exception('No words found in the database');
  }

  // Placeholder for updating a word
  Future<void> updateWord(Map<String, dynamic> word) async {
    final db = await database;
    await db.update('words', word, where: 'id = ?', whereArgs: [word['id']]);
  }

  // Placeholder for deleting a word
  Future<void> deleteWord(int id) async {
    final db = await database;
    await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }
}