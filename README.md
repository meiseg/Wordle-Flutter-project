#Spanish Wordle Game with Firebase Integration
#Overview
Welcome to Spanish Wordle , an educational and interactive word-guessing game designed to help users learn Spanish while having fun! This Flutter-based mobile application combines gamification with language learning, offering a unique experience inspired by the popular New York Times Wordle game—but tailored specifically for Spanish learners.

The app integrates Google Firebase services to provide seamless user authentication, real-time data storage, and personalized user profiles. Additionally, it leverages Google's Text-to-Speech API to enhance the learning experience by pronouncing words correctly in Spanish.

Key Features:

User Authentication : Secure login and registration using email and password.
Personalized Profiles : Users can store their name, profile image, and progress.
Leaderboard : A global leaderboard to track user performance and encourage competition.
Daily Stats : Track your daily progress and streaks to stay motivated.
Spanish Word Database : A custom database of 6-letter Spanish words generated and filtered using an external API.
Text-to-Speech : Pronunciation of words to improve pronunciation skills.
Intuitive UI/UX : Smooth navigation across multiple screens with a clean and modern design.

#Features
#1. User Authentication
Users can create accounts or log in securely using email and password.
Firebase Authentication ensures secure and reliable user management.
#2. Personalized User Profiles
After logging in, users can upload a profile picture and enter their name.
Profile information is stored in Firebase Firestore , allowing users to maintain their progress and preferences.
#3. Leaderboard
A global leaderboard tracks user scores and ranks them based on their performance.
Real-time updates are powered by Firebase Realtime Database , ensuring accuracy and responsiveness.
#4. Daily Stats
Users can view their daily stats, including their current streak, total games played, and win rate.
Progress is saved in Firestore, enabling users to pick up where they left off.
#5. Spanish Word Database
The app uses an external API to generate a comprehensive list of Spanish words.
Words are filtered to include only 6-letter words, ensuring consistency with the Wordle format.
The database is stored in Firestore for efficient querying and scalability.
#6. Text-to-Speech Integration
Google's Text-to-Speech API is integrated to pronounce each word in Spanish.
This feature helps users improve their pronunciation and reinforces vocabulary retention.
#7. Wordle Game Screen
The game screen mimics the classic Wordle gameplay but focuses on Spanish words.
Users guess a 6-letter Spanish word within six attempts, receiving feedback on correct letters and positions.
The game resets daily with a new word, encouraging consistent engagement.
#8. Navigation and UI
The app features a clean and intuitive user interface with smooth navigation between screens.
#Key screens include:
Login/Register Screen : For user authentication.
Profile Screen : To view and update user details.
Game Screen : The main Wordle gameplay interface.
Leaderboard Screen : To view global rankings.
Stats Screen : To track personal progress.

Technologies Used
Flutter : Cross-platform framework for building the app's UI and logic.
Firebase :
Authentication : Secure user login and registration.
Firestore Database : Store user profiles, game progress, and word data.
Realtime Database : Power the global leaderboard with real-time updates.
Google Text-to-Speech API : Pronounce Spanish words accurately.
External API : Generate and filter Spanish words for the game database.
Dart : Programming language used for app development.
