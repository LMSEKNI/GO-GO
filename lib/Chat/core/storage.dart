import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String userId;
  final String name;
  final String avatarUrl;

  UserData({required this.userId, required this.name, required this.avatarUrl});
}

class Storage {
  static Future<List<UserData>> getUsersData() async {
    List<UserData> usersData = [];

    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      querySnapshot.docs.forEach((doc) {
        String userId = doc.id;
        String name = doc['userName'];
        String imageUrl = doc['userAvatarUrl'];

        UserData userData = UserData(userId: userId, name: name, avatarUrl: imageUrl);
        usersData.add(userData);
      });

      return usersData;
    } catch (e) {
      print("Error loading users data: $e");
      return []; // Return empty list if error occurs
    }
  }

  // Define getUsers method to retrieve user data
  static Future<List<UserData>> getUsers() async {
    try {
      List<UserData> usersData = await getUsersData();
      return usersData;
    } catch (e) {
      print("Error getting users: $e");
      return []; // Return empty list if error occurs
    }
  }
}
