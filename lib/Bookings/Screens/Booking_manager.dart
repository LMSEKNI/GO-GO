import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingManagerScreen extends StatelessWidget {
  final String bookingID;
  final String userId;

  BookingManagerScreen({Key? key, required this.bookingID, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00aa9b),
        title: Text('Manage Booking'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Do you want to accept this user's request?"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => BookingManager.acceptBooking(context, bookingID, userId),
              child: Text('Accept Booking'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => BookingManager.declineBooking(context, bookingID, userId),
              child: Text('Decline Booking'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingManager {
  static void manageBooking(BuildContext context, String bookingID, String userID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Manage Booking'),
          content: Text('Choose an option for this booking:'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                acceptBooking(context, bookingID, userID);
              },
              child: Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                declineBooking(context, bookingID, userID,);
              },
              child: Text('Decline'),
            ),
          ],
        );
      },
    );
  }

  static void acceptBooking(BuildContext context, String bookingID, String userID) {
    FirebaseFirestore.instance.collection('bookings').doc(bookingID).update({
      'status': 'accepted',
      'acceptedUserID': userID,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking accepted ')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept booking ')),
      );
    });
  }
  static void declineBooking(BuildContext context, String bookingID, String userID) {
    // First fetch the carID
    getCarIdFromBooking(bookingID).then((carID) {
      // Proceed with declining the booking
      FirebaseFirestore.instance.collection('bookings').doc(bookingID).update({
        'status': 'declined',
        'declinedUserID': userID,
        'userIDs': FieldValue.arrayRemove([userID])  // Remove userID from the userIDs array
      }).then((_) {
        // After successfully updating the booking, update the car's seat count
        updateCarSeats(context, carID);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking declined ')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to decline booking : ${error.toString()}')),
        );
      });
    }).catchError((error) {
      // Handle errors when fetching the carID
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve car ID: ${error.toString()}')),
      );
    });
  }

  static Future<String> getCarIdFromBooking(String bookingID) async {
    DocumentSnapshot bookingDoc = await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingID)
        .get();

    if (bookingDoc.exists && bookingDoc.data() != null) {
      Map<String, dynamic> data = bookingDoc.data() as Map<String, dynamic>;
      String carID = data['carID'];
      if (carID != null) {
        return carID;
      } else {
        throw Exception('carID is not specified in the booking document');
      }
    } else {
      throw Exception('Booking not found or contains no data');
    }
  }

  static void updateCarSeats(BuildContext context, String carID) {
    var carRef = FirebaseFirestore.instance.collection('cars').doc(carID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      var carSnapshot = await transaction.get(carRef);
      if (carSnapshot.exists) {
        int currentSeats = carSnapshot.data()!['numberOfSeats'] ?? 0;
        transaction.update(carRef, {'numberOfSeats': currentSeats + 1});
      }
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Number of seats updated successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update number of seats: ${error.toString()}')),
      );
    });
  }

}
