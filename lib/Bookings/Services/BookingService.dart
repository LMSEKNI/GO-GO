import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookingService {
  static void bookCar(BuildContext context, String carID, Map<String, dynamic> carData) {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    int availableSeats = carData['numberOfSeats'];

    // Check if the carID exists in the 'bookings' collection
    FirebaseFirestore.instance.collection('bookings').where('carID', isEqualTo: carID).get().then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // Car already booked, update the existing document
        final existingDoc = querySnapshot.docs.first;
        final existingUserIDs = List<String>.from(existingDoc['userIDs']);

        // Check if the current user's ID is already in the userIDs array
        if (!existingUserIDs.contains(currentUserID)) {
          existingUserIDs.add(currentUserID);

          // Update the 'userIDs' array in the existing document
          existingDoc.reference.update({
            'userIDs': existingUserIDs,
            'timestamp': DateTime.now(),
          }).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Car booked successfully')),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to book car')),
            );
          });
        } else {
          // Current user already booked this car
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You have already booked this car')),
          );
        }
      } else {
        // Car not booked yet, add a new booking document
        _addNewBooking(context, carID, availableSeats);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car booked successfully')),
        );
      }
    }).catchError((error) {
      // Error occurred while querying the database
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book car')),
      );
    });
  }

  static void _addNewBooking(BuildContext context, String carID, int availableSeats) {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance.collection('bookings').add({
      'carID': carID,
      'timestamp': DateTime.now(),
      'userIDs': [currentUserID], // Initialize array with current user's ID
    }).then((value) {
      // Update number of seats for the booked car
      FirebaseFirestore.instance.collection('cars').doc(carID).update({
        'numberOfSeats': availableSeats - 1,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car booked successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update number of seats')),
        );
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book car')),
      );
    });
  }

}