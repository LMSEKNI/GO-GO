import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Trip {
  String carID;
  String startingLocation;
  TimeOfDay startTime; // Updated to TimeOfDay
  List<String> userIDs;
  List<String> availableDays;

  Trip({
    required this.carID,
    required this.startingLocation,
    required this.startTime,
    required this.userIDs,
    required this.availableDays,
  });

  Map<String, dynamic> toMap() {
    return {
      'carID': carID,
      'startingLocation': startingLocation,
      'startTimeHour': startTime.hour, // Store hour separately
      'startTimeMinute': startTime.minute, // Store minute separately
      'userIDs': userIDs,
      'availableDays': availableDays,
    };
  }

  static Trip fromMap(Map<String, dynamic> map) {
    return Trip(
      carID: map['carID'],
      startingLocation: map['startingLocation'],
      startTime: TimeOfDay(
        hour: map['startTimeHour'],
        minute: map['startTimeMinute'],
      ),
      userIDs: List<String>.from(map['userIDs']),
      availableDays: List<String>.from(map['availableDays']),
    );
  }
}
