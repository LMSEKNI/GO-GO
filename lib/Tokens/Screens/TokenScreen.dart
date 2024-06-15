import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TokenScreen extends StatefulWidget {
  @override
  _TokenScreenState createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  int tokenCount = 0;

  @override
  void initState() {
    super.initState();
    fetchTokenCount();
  }

  Future<void> fetchTokenCount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDataSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (userDataSnapshot.exists) {
        final userData = userDataSnapshot.data() as Map<String, dynamic>;
        setState(() {
          tokenCount = userData['tokens'] ?? 0;
        });
      }
    }
  }

  Widget _buildGiftItem(String gift, int requiredTokens) {
    return Card(
      color: Color.fromRGBO(147, 205, 221, 1.0),
      child: ListTile(
        leading: Icon(Icons.card_giftcard),
        title: Text(gift),
        subtitle: Text('Requires $requiredTokens tokens'),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          ),
          onPressed: () async {
            bool success = await redeemGift(requiredTokens);
            if (success) {
              setState(() {
                tokenCount -= requiredTokens;
              });
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Congratulations!'),
                  content: Text('You have successfully redeemed $gift!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Not Enough Tokens'),
                  content: Text('You do not have enough tokens to redeem $gift. Make sure to participate and win , You Are Almost There !'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
          child: Text(
            'Redeem',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<bool> redeemGift(int requiredTokens) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if (tokenCount >= requiredTokens) {
        try {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(currentUser.uid)
              .update({'tokens': FieldValue.increment(-requiredTokens)});
          return true;
        } catch (e) {
          print('Error redeeming gift: $e');
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tokens'),
        backgroundColor: Color(0xFF00aa9b),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'images/token.png',
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 5),
                  Text(
                    '$tokenCount ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 5),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Available Gifts:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildGiftItem('Gift 1', 10),
                  SizedBox(height: 10),
                  _buildGiftItem('Gift 2', 10),
                  SizedBox(height: 10),
                  _buildGiftItem('Gift 3', 10),
                  SizedBox(height: 10),
                  _buildGiftItem('Gift 4', 20),
                  SizedBox(height: 10),
                  _buildGiftItem('Gift 5', 20),
                  SizedBox(height: 10),
                  _buildGiftItem('Gift 6', 20),
                  SizedBox(height: 10),
                  _buildGiftItem('Gift 7', 30),
                  SizedBox(height: 10),
                  _buildGiftItem('Gift 8', 30),
                  SizedBox(height: 10),
                  _buildGiftItem('Gift 9', 30),
                  SizedBox(height: 10),
                  _buildGiftItem('Gift 10', 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
