import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Menu/Widgets/MenuButtonWidget.dart';
import 'Booking_manager.dart';

class BookedCarsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookings"),
        centerTitle: true,
        backgroundColor: Color(0xFF00aa9b),
      ),
      drawer: const MenuDrawer(),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .where('userIDs', arrayContains: currentUserID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            final List<DocumentSnapshot> documents = snapshot.data!.docs;
            if (documents.isEmpty) {
              return Center(
                child: Text('No cars booked.'),
              );
            }
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final bookingData = documents[index].data() as Map<String, dynamic>;
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('cars').doc(bookingData['carID']).get(),
                  builder: (context, carSnapshot) {
                    if (carSnapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (carSnapshot.hasError) {
                      return ListTile(
                        title: Text("Error loading car data"),
                      );
                    }
                    if (!carSnapshot.hasData || carSnapshot.data!.data() == null) {
                      return ListTile(
                        title: Text("No data found for car"),
                      );
                    }
                    Map<String, dynamic> carData = carSnapshot.data!.data() as Map<String, dynamic>;
                    List<String> userIds = List.from(bookingData['userIDs']);
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        title: Text("${carData['carType']} Booking Details"),
                        children: userIds.map((userId) => FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (userSnapshot.hasError) {
                              return ListTile(
                                title: Text("Error loading user data"),
                              );
                            }
                            if (!userSnapshot.hasData || userSnapshot.data!.data() == null) {
                              return ListTile(
                                title: Text("No data found for user"),
                              );
                            }
                            Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(userData['userAvatarUrl']),
                              ),
                              title: Text(userData['userName']),
                              subtitle: Text(userData['userEmail']),

                              onTap: () {
                                // Within your ListView.builder or wherever you're setting up the onTap
                                final bookingData = documents[index];
                                final bookingID = bookingData.id; // Getting the document ID correctly
                                final Map<String, dynamic> data = bookingData.data() as Map<String, dynamic>; // This is your existing data map

                                // Navigate to BookingManager interface with user and booking details
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BookingManagerScreen(bookingID:bookingID, userId: userId)
                                  ),
                                );
                              },
                            );
                          },
                        )).toList(),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _cancelBooking(BuildContext context, String bookingID, String carID,
      int numberOfSeats) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel this booking?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _performCancellation(context, bookingID, carID, numberOfSeats);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _performCancellation(BuildContext context, String bookingID,
      String carID, int numberOfSeats) {
    FirebaseFirestore.instance.collection('bookings').doc(bookingID)
        .delete()
        .then((_) {
      // Update number of seats for the canceled booking
      FirebaseFirestore.instance.collection('cars').doc(carID).update({
        'numberOfSeats': numberOfSeats + 1,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking canceled successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update number of seats')),
        );
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel booking')),
      );
    });
  }
}

