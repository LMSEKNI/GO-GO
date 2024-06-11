import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../Home/mainScreens/home_screen.dart';

class AddCarScreen extends StatefulWidget {
  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _carType;
  late String _serialNumber;
  late int _numberOfSeats;
  XFile? _carImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectImage() async {
    XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _carImage = pickedImage;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? userID = FirebaseAuth.instance.currentUser?.uid;
      if (userID == null) {
        return;
      }

      String photoUrl = '';
      if (_carImage != null) {
        photoUrl = await _uploadImage(File(_carImage!.path));
      }

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference ref = await FirebaseFirestore.instance.collection('cars').add({
          'carType': _carType,
          'serialNumber': _serialNumber,
          'numberOfSeats': _numberOfSeats,
          'photoUrl': photoUrl,
          'userID': userID,
        });
        await ref.update({
          'carID': ref.id,
        });

        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userID);
        transaction.update(userRef, {
          'status': 'driver',
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Car added successfully, status updated to driver!'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    final ref = FirebaseStorage.instance.ref().child('car_photos').child('${DateTime.now()}.jpg');
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Your Car'),
        centerTitle: true,
        backgroundColor: const Color(0xFF00aa9b),
      ),
      body: Container(
        color: Colors.grey[350],
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 40),
                InkWell(
                  onTap: () {
                    _selectImage();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 3.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.20,
                      backgroundColor: Colors.white70,
                      backgroundImage: _carImage == null ? null : FileImage(File(_carImage!.path)),
                      child: _carImage == null
                          ? Icon(
                        Icons.add_photo_alternate,
                        size: MediaQuery.of(context).size.width * 0.20,
                        color: Colors.grey,
                      )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text('Choose your car image'),
                SizedBox(height: 40),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Car Type",
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.car_rental, color: Colors.black),
                    filled: true,
                    fillColor: Colors.white70,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 3.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a car type';
                    }
                    return null;
                  },
                  onSaved: (value) => _carType = value!,
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Serial Number",
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.numbers, color: Colors.black),
                    filled: true,
                    fillColor: Colors.white70,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 3.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a serial number';
                    }
                    return null;
                  },
                  onSaved: (value) => _serialNumber = value!,
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Seats Number",
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.event_seat, color: Colors.black),
                    filled: true,
                    fillColor: Colors.white70,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 3.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of seats';
                    }
                    return null;
                  },
                  onSaved: (value) => _numberOfSeats = int.parse(value!),
                ),
                SizedBox(height: 155),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00aa9b),
                    padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 10),
                  ),
                  onPressed: _submitForm,
                  child: const Text(
                    "Add Car",
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
