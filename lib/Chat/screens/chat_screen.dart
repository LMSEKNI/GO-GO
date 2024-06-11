import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Menu/Widgets/MenuButtonWidget.dart';
import '../core/storage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<UserData> users = [];
  late String currentUserID;

  @override
  void initState() {
    super.initState();
    // Fetch users from storage when the screen initializes
    fetchUsers();
    fetchCurrentUserID();
  }

  void fetchUsers() async {
    // Retrieve users from the storage
    users = await Storage.getUsers();
    setState(() {}); // Update the UI after fetching users
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
        title: const Text("Chats"),
        centerTitle: true,
      ),
      drawer: const MenuDrawer(),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return GestureDetector(
                onTap: () {
                  // Handle tapping on a user
                  _navigateToConversation(user);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(user.avatarUrl),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xFF232d4b),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF232d4b),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _navigateToConversation(UserData user) async {
    final url = Uri.parse('https://teams.microsoft.com');

    final Uri fallbackUrl = Uri.parse('https://teams.microsoft.com');

    bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched) {
      // If the specific page can't be opened, try the homepage or show an error
      launched = await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Handle the failure here
        print('Could not launch Microsoft Teams.');
      }
    }
  }
}
