import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'favorites_service.dart';
import 'RatingInterface.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;
  UserDetailsScreen({required this.userId});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        centerTitle: true,
        backgroundColor: Color(0xFF00aa9b),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.grey.withOpacity(0.5),
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection("users").doc(widget.userId).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data != null) {
                final userData = snapshot.data!.data()!;
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  final currentUserId = currentUser.uid;
                  final favoritesCollection = FirebaseFirestore.instance.collection('favorites');

                  return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: favoritesCollection
                        .where('userId', isEqualTo: currentUserId)
                        .where('favoriteUserId', isEqualTo: userData['userUID'])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        isFavorite = snapshot.data!.docs.isNotEmpty;
                        return Center(
                          child: Card(
                            color: Colors.green[50],
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 5.0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(userData['userAvatarUrl'] ?? ''),
                                  ),
                                  SizedBox(height: 20.0),
                                  buildProfileItem("Name", userData['userName'] ?? ''),
                                  buildProfileItem("Email", userData['userEmail'] ?? ''),
                                  buildProfileItem("Phone", userData['phone'] ?? ''),
                                  buildProfileItem("Address", userData['address'] ?? ''),
                                  buildProfileItem("Status", userData['status'] ?? ''),
                                  SizedBox(height: 20.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(

                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => RatingInterface(ratedUserID: widget.userId)),
                                          );
                                        },
                                        child: Text('Rate User',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF00aa9b),
                                          padding: const EdgeInsets.symmetric(horizontal: 40),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isFavorite = !isFavorite; // Toggle the favorite status
                                          });
                                          addToFavorites(userData['userUID']);
                                        },
                                        icon: Icon(
                                          Icons.favorite,
                                          color: isFavorite ? Colors.red : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                } else {
                  // User is not logged in
                  return Center(
                    child: Text(
                      'Please log in to manage favorites.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
              } else {
                return Center(child: Text('No user data found.'));
              }
            },
          ),
        ),
      ),
    );
  }

  // Builds a profile item with a label and its value
  Widget buildProfileItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF232d4b),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 10.0),
      ],
    );
  }

  void addToFavorites(String favoriteUserId) {
    // Add logic to add or remove from favorites
  }
}
