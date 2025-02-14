import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildLeaderboardList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('profiles')
          .orderBy('score', descending: true)
          .snapshots(),
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!profileSnapshot.hasData || profileSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No leaderboard data available.'));
        }

        final profiles = profileSnapshot.data!.docs;

        return ListView.builder(
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profileData = profiles[index];
            final userId = profileData.id; // Assuming document ID is userId
            final score = profileData['score'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: CircleAvatar(),
                    title: Text('Loading...'),
                    subtitle: Text('Rank: ...'),
                  );
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const ListTile(
                    leading: CircleAvatar(),
                    title: Text('User not found'),
                    subtitle: Text('Rank: ...'),
                  );
                }

                final userData = userSnapshot.data!;
                final username = userData['name'];
                final profilePictureBase64 = userData['profileImage'];
                final profileImage = base64Decode(profilePictureBase64);

                return InkWell(
                  onTap: () => _showUserDetails(
                    context,
                    UserRank(
                      username: username,
                      score: score,
                      rank: index + 1,
                      profilePicture: MemoryImage(profileImage),
                      userId: userId,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: MemoryImage(profileImage),
                      ),
                      title: Text(
                        username,
                        style: TextStyle(
                          fontWeight: userId == "user123" ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text('Rank: ${index + 1}'),
                      trailing: Text(
                        score.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showUserDetails(BuildContext context, UserRank user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundImage: user.profilePicture,
            ),
            const SizedBox(height: 16),
            Text(
              user.username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildStatGrid(user),
            const SizedBox(height: 24),
            _buildAchievements(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(UserRank user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Score', user.score.toString()),
          _buildStatItem('Games Played', '157'), // Placeholder
          _buildStatItem('Win Rate', '78%'), // Placeholder
        ],
      ),
    );
  }

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
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5, // Placeholder for achievements
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.emoji_events, color: Colors.amber),
                      SizedBox(height: 4),
                      Text(
                        'Achievement',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class UserRank {
  final String username;
  final int score;
  final int rank;
  final MemoryImage profilePicture;
  final String userId;

  UserRank({
    required this.username,
    required this.score,
    required this.rank,
    required this.profilePicture,
    required this.userId,
  });
}
