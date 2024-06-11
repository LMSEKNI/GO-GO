import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void addToFavorites(String userId) async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final currentUserId = currentUser.uid;
      final favoritesCollection = FirebaseFirestore.instance.collection('favorites');

      // Check if the user is already in favorites
      final snapshot = await favoritesCollection
          .where('userId', isEqualTo: currentUserId)
          .where('favoriteUserId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // User is already in favorites, so remove from favorites
        await favoritesCollection.doc(snapshot.docs[0].id).delete();
        // Show a success dialog or perform any other actions as needed
      } else {
        // User is not in favorites, so add to favorites
        await favoritesCollection.add({
          'userId': currentUserId,
          'favoriteUserId': userId,
        });
        // Show a success dialog or perform any other actions as needed
      }
    }
  } catch (error) {
    // Handle any errors that occur during the process
    print('Error adding to favorites: $error');
  }
}