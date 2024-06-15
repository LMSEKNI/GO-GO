import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Bookings/Screens/BookedCars.dart';
import '../../Cars/Screens/AvailableCarsScreen.dart';
import '../../Chat/screens/chat_screen.dart';
import '../../Favorites/mainPage.dart';
import '../../Travelers/AvailableTravalersScreen.dart';
import '../widgets/bottomNavigationBar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkFirstLogin();
  }

  Future<void> _checkFirstLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isFirstLogin = sharedPreferences.getBool('firstLogin') ?? false;

    if (isFirstLogin) {
      // Show the token information dialog
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (c) {
            return AlertDialog(
              title: Text("Welcome to GO&GO!"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('images/Asset 2.png',
                    width: 80,
                    height: 80,),
                  SizedBox(height: 10),
                  Text("You have received 1 token for signing up"),
                  SizedBox(width: 5),
                  Image.asset('images/token.png',
                    width: 80,
                    height: 80,),
                  SizedBox(width: 5),
                  Text("Keep collecting tokens by using GO&GO to gain free gifts!"),

                ],
              ),

              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(c).pop();
                    // Update first login flag
                    sharedPreferences.setBool('firstLogin', false);
                  },
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreen(),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildScreen() {
    return FutureBuilder<String>(
      future: fetchUserStatus(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while fetching user status
          return Center(child: CircularProgressIndicator());
        }

        final userStatus = snapshot.data;

        return IndexedStack(
          index: _currentIndex,
          children: [
            if (userStatus == 'driver')
              AvailableTravelerScreen()
            else
              AvailableCarsScreen(),
            Placeholder(),
            ChatScreen(),
            BookedCarsScreen(),
            FavoritesScreen_main(),
          ],
        );
      },
    );
  }

  Future<String> fetchUserStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDataSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (userDataSnapshot.exists) {
        final userData = userDataSnapshot.data() as Map<String, dynamic>;
        final userStatus = userData['status'] as String;
        return userStatus;
      }
    }

    return '';
  }
}
