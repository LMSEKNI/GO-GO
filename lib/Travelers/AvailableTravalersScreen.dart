import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material3_layout/material3_layout.dart';



import '../Chat/core/storage.dart';
import '../Menu/Widgets/MenuButtonWidget.dart';
import 'TravalerDetails.dart'; // Import UserDetailsScreen

class AvailableTravelerScreen extends StatefulWidget {
  const AvailableTravelerScreen({Key? key}) : super(key: key);

  @override
  _AvailableTravelerScreenState createState() =>
      _AvailableTravelerScreenState();
}

class _AvailableTravelerScreenState extends State<AvailableTravelerScreen> {
  late List<UserData> travelers = [];
  late String currentUserID;
  String _searchValue = '';

  @override
  void initState() {
    super.initState();
    // Fetch travelers from storage when the screen initializes
    fetchTravelers();
    fetchCurrentUserID();
  }

  void fetchTravelers() async {
    // Retrieve travelers from the storage
    travelers = await Storage.getUsers();
    setState(() {}); // Update the UI after fetching travelers
  }

  void fetchCurrentUserID() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserID = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00aa9b),
        title: const Text("Available Travelers"),
        centerTitle: true,
      ),
      drawer: const MenuDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search for travelers...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchValue = value;
                    });
                  },
                ),

              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: travelers.length,
                  itemBuilder: (context, index) {
                    final traveler = travelers[index];
                    if (_searchValue.isNotEmpty &&
                        !traveler.name
                            .toLowerCase()
                            .contains(_searchValue.toLowerCase())) {
                      return SizedBox.shrink(); // Hide if not matched
                    }
                    return GestureDetector(
                      onTap: () {
                        // Navigate to UserDetailsScreen when tapping on a traveler
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailsScreen(userId: traveler.userId),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 7),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 3,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(traveler.avatarUrl),
                                ),
                                SizedBox(width: 20.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      traveler.name,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Color(0xFF00aa9b),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 8.0,
                            right: 8.0,
                            child: FutureBuilder<bool>(
                              future: checkFavoriteStatus(traveler.userId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  final isFavorite = snapshot.data ?? false;
                                  return Icon(
                                    Icons.favorite,
                                    color: isFavorite ? Colors.red : Colors.grey,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
Future<bool> checkFavoriteStatus(String userId) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final currentUserId = currentUser.uid;
    final favoritesCollection = FirebaseFirestore.instance.collection('favorites');

    final querySnapshot = await favoritesCollection
        .where('userId', isEqualTo: currentUserId)
        .where('favoriteUserId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
  return false;
}