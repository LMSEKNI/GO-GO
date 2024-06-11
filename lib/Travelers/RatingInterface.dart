import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingInterface extends StatelessWidget {
  final String ratedUserID;

  RatingInterface({required this.ratedUserID});

  @override
  Widget build(BuildContext context) {
    double rating = 0;
    String remarks = '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00aa9b),
        title: const Text('Rate User'),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFF232d4b),
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView( // Wrap Column in SingleChildScrollView
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Text(
                'Rate the user:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 40,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  rating = newRating;
                },
              ),
              const SizedBox(height: 90),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Add remarks (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  hintStyle: const TextStyle(color: Colors.white70),
                  labelStyle: const TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white54, width: 2.0),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 5, // Multiline TextField
                minLines: 3, // Minimum lines
                onChanged: (value) {
                  remarks = value;
                },
              ),
              const SizedBox(height: 100),
              Image.asset(
                "images/Asset 1.png",
                height: 80,
              ),
              const SizedBox(height: 100),
              ElevatedButton(
                onPressed: () {
                  submitRating(ratedUserID, rating, remarks);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 160, vertical: 15),
                  foregroundColor: Colors.white, backgroundColor: const Color(0xFF00aa9b),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitRating(String ratedUserID, double rating, String remarks) {
    FirebaseFirestore.instance.collection('rates').add({
      'ratedUserID': ratedUserID,
      'rating': rating,
      'remarks': remarks,
    }).then((value) {
      print('Rating submitted successfully');
    }).catchError((error) {
      print('Failed to submit rating: $error');
    });
  }
}
