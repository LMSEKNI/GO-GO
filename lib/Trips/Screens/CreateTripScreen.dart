import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../Home/mainScreens/home_screen.dart';
import '../Models/Trip.dart';
import '../Services/TripService.dart';

class CreateTripScreen extends StatefulWidget {
  final String carID;

  CreateTripScreen({required this.carID});

  @override
  _CreateTripScreenState createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  String? startingLocation;
  TimeOfDay? startTime;
  List<String> userIDs = [];
  Map<String, bool> availableDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
  };

  final TextEditingController _startTimeController = TextEditingController();

  Future<String?> getCurrentLocation() async {
    try {
      Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        newPosition.latitude,
        newPosition.longitude,
      );

      Placemark placemark = placemarks.first;

      return '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    } catch (e) {
      print('Error fetching location: $e');
      return null;
    }
  }

  Future<void> useCurrentLocation() async {
    String? currentLocation = await getCurrentLocation();
    if (currentLocation != null) {
      setState(() {
        startingLocation = currentLocation;
      });
    } else {
      // Handle error when getting location
      // Show an error dialog or toast message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch current location.'),
        ),
      );
    }
  }

  Future<void> pickStartTime(BuildContext context) async {
    // Show time picker to select start time
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        startTime = pickedTime;
        _startTimeController.text = pickedTime.format(context);
      });
    }
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Trip'),
        backgroundColor: Color(0xFF00aa9b),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Starting Location",
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.place, color: Colors.black),
                    filled: true,
                    fillColor: Colors.white70,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 3.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter starting location';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    startingLocation = value;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: useCurrentLocation,
                  child: Text('Use Current Location'),
                ),
                TextFormField(
                  onTap: () {
                    pickStartTime(context);
                  },
                  readOnly: true,
                  controller: _startTimeController,
                  decoration: InputDecoration(
                    labelText: 'Start Time',
                    prefixIcon: Icon(Icons.access_time),
                    filled: true,
                    fillColor: Colors.white70,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 3.0),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Available Days',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        SizedBox(height: 10),
                        ListView(
                          shrinkWrap: true,
                          children: availableDays.keys.map((String key) {
                            return CheckboxListTile(
                              title: Text(key),
                              value: availableDays[key],
                              onChanged: (bool? value) {
                                setState(() {
                                  availableDays[key] = value!;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      List<String> selectedDays = availableDays.entries
                          .where((element) => element.value)
                          .map((e) => e.key)
                          .toList();
                      Trip trip = Trip(
                        carID: widget.carID,
                        startingLocation: startingLocation!,
                        startTime: startTime!,
                        userIDs: userIDs,
                        availableDays: selectedDays,
                      );
                      TripService().createTrip(trip);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00aa9b),
                    padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 10),
                  ),
                  child: const Text(
                    'Create Trip',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
