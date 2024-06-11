import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchUserStatus(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        final userStatus = snapshot.data;

        final items = <NavigationDestination>[
          if (userStatus == 'driver')
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: 'Traveler',
            ),
          if (userStatus != 'driver')
            NavigationDestination(
              icon: const Icon(Icons.car_rental_outlined),
              selectedIcon: const Icon(Icons.car_rental),
              label: 'Cars',
            ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: const Icon(Icons.message_outlined),
            selectedIcon: const Icon(Icons.message),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_outline),
            selectedIcon: const Icon(Icons.bookmark),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline),
            selectedIcon: const Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ];

        return NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          destinations: items,
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
