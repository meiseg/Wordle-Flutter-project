import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'word_master_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedLanguage = 'Spanish';

  Stream<Map<String, dynamic>> _userStatsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('profiles') // Adjust to match your collection name
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return {
          'score': snapshot['score'] ?? 0,
          'totalWords': snapshot['totalWords'] ?? 0,
        };
      } else {
        return {'score': 0, 'totalWords': 0}; // Default values
      }
    });
  }


  // Fetch user stats from Firestore

  Future<Map<String, dynamic>> _fetchUserStats(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('profiles') // assuming your collection is named 'profiles'
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return {
          'score': userDoc['score'] ?? 0,
          'totalWords': userDoc['totalWords'] ?? 0,
        };
      } else {
        throw Exception('User data not found');
      }
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Image.asset('assets/flags/spain.png', width: 24),
              title: const Text('Spanish'),
              onTap: () {
                setState(() => selectedLanguage = 'Spanish');
                Navigator.pop(context);
              },
              trailing: selectedLanguage == 'Spanish'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
            ),
            // Add more languages here
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildHomeTab(),
            const WordMasterScreen(),
            const LeaderboardScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.home),
              text: 'Home',
            ),
            Tab(
              icon: Icon(Icons.quiz),
              text: 'Quick Test',
            ),
            Tab(
              icon: Icon(Icons.leaderboard),
              text: 'Leaderboard',
            ),
          ],
        ),
      ),
    );
  }

  // Home tab layout with stats
  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'WordleMaster',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: _showLanguageSelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/flags/spain.png', width: 24),
                      const SizedBox(width: 8),
                      Text(selectedLanguage),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: Colors.blue.withOpacity(0.4),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordleGameScreen(userId: widget.userId),
                ),
              );
            },
            child: const Text(
              'Play Game',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Fetch user stats and display them
          StreamBuilder<Map<String, dynamic>>(
            stream: _userStatsStream(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return const Text('No data available');
              }

              var userStats = snapshot.data!;
              return _buildStatsCard(userStats['totalWords'], userStats['score']);
            },
          ),

          const SizedBox(height: 20),
          _buildFunFactsSection(), // Added fun facts section
        ],
      ),
    );
  }

  // Builds the stats card
  Widget _buildStatsCard(int totalWords, int score) {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Words', totalWords.toString()),
                _buildStatItem('Score', score.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build stat items
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Fun facts section
  Widget _buildFunFactsSection() {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50, // Set card background color to match WordMasterScreen
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Fun Language Facts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Did you know? Learning a new language can improve your memory and cognitive skills!',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),

            const Text(
              'Language learning can also enhance your career opportunities and cultural understanding.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}