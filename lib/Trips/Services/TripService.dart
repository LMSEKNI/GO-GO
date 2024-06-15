import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/Trip.dart';

class TripService {
  final CollectionReference tripsCollection = FirebaseFirestore.instance.collection('trips');

  // Create a new trip
  Future<void> createTrip(Trip trip) async {
    await FirebaseFirestore.instance.collection('trips').add(trip.toMap());
  }

}
