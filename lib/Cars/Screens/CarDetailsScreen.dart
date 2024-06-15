import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Bookings/Services/BookingService.dart';
import '../../Travelers/favorites_service.dart';

class CarDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> carData;
  final String carID;

  CarDetailsScreen({required this.carID, required this.carData});

  @override
  _CarDetailsScreenState createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  bool isFavorite = false;
  late Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    final ownerID = widget.carData['userID'];
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(ownerID).get();
    if (snapshot.exists) {
      setState(() {
        userData = snapshot.data() as Map<String, dynamic>;
      });
      checkIfFavorite();
    }
  }

  void checkIfFavorite() async {
    final snapshot = await FirebaseFirestore.instance.collection('favorites')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('favoriteUserId', isEqualTo: userData['userUID'])
        .get();
    setState(() {
      isFavorite = snapshot.docs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Details'),
        centerTitle: true,
        backgroundColor: Color(0xFF00aa9b),
      ),
      body: Container(
        color: Colors.grey.withOpacity(0.5),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.green[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Image.network(
                          widget.carData['photoUrl'] ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                            return Icon(Icons.broken_image, size: 200, color: Colors.grey[500]);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              widget.carData['carType'] ?? '',
                              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xFF232d4b),
                            ),
                          ),
                          ),
                          SizedBox(height: 16.0),
                          _buildInfoBox('Serial Number:', widget.carData['serialNumber'] ?? ''),
                          SizedBox(height: 10.0),
                          _buildInfoBox('Seats available:', widget.carData['numberOfSeats'] ?? ''),
                          SizedBox(height: 24.0),
                          if (userData.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child:Text(
                                    'Owner',
                                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xFF232d4b)),
                                  ),

                                ),

                                SizedBox(height: 10.0),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(userData['userAvatarUrl'] ?? ''),
                                      radius: 30.0,
                                    ),
                                    SizedBox(width: 16.0),
                                    Text(
                                      userData['userName'] ?? '',
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          SizedBox(height: 40.0),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _showBookingDialog(context, widget.carID, widget.carData);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black, backgroundColor: Colors.green,
                                  ),
                                  child: Text('Book Car'),
                                ),
                                SizedBox(width: 16),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isFavorite = !isFavorite;
                                    });
                                    addToFavorites(userData['userUID']);
                                  },
                                  icon: Icon(
                                    Icons.favorite,
                                    color: isFavorite ? Colors.red : Colors.white,
                                  ),
                                ),
                                SizedBox(height: 120.0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

    );

  }
}

Widget _buildInfoBox(String title, dynamic value) {
  final valueString = value.toString();

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 5.0,
          offset: Offset(0, 2),
        ),
      ],
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        Text(valueString),
      ],
    ),
  );
}

void _showBookingDialog(BuildContext context, String carID, Map<String, dynamic> carData) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Confirm Booking'),
        content: Text('Do you want to book this car?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              BookingService.bookCar(context, carID, carData);
            },
            child: Text('Confirm'),
          ),
        ],
      );
    },
  );
}
