import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:goandgoapp/Authentification/authentication/login.dart';
import 'package:goandgoapp/Cars/Screens/Add_Car.dart';
import '../Authentification/global/global.dart';
import './dialogs.dart';
import '../../Home/mainScreens/home_screen.dart'; // Import HomeScreen


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late User? currentUser;
  Map<String, dynamic> userData = {}; // Initialize with an empty map
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  int _statusIndex = 0; // 0 for Passenger, 1 for Driver

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
      _addressController = TextEditingController();

      fetchUserData();
    }
  }

  void fetchUserData() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.uid)
        .get()
        .then((userDataSnapshot) {
      if (userDataSnapshot.exists) {
        setState(() {
          userData = userDataSnapshot.data()!;
          _nameController.text = userData['userName'] ?? '';
          _emailController.text = userData['userEmail'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _statusIndex = (userData['status'] == 'driver') ? 1 : 0;
          _addressController.text = userData['address'] ?? '';
        });
      }
    });
  }

  Future<void> _updateProfileData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        // Update user data in Firestore
        await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser!.uid)
            .update({
          'userName': _nameController.text,
          'userEmail': _emailController.text,
          'phone': _phoneController.text,
          'status': _statusIndex == 1 ? 'driver' : 'passenger',
          'address': _addressController.text,
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // If an error occurs, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddCarDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a Car'),
          content: const Text('Do you want to add a new car to your profile?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCarScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00aa9b),
        title: const Text("My Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateProfileData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout, // Call the logout function
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.grey.withOpacity(0.3),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 30.0),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userData['userAvatarUrl'] ?? ''),
                  ),
                ),
                const SizedBox(height: 40.0),
                buildEditableProfileItem("Name", _nameController),
                const SizedBox(height: 10.0),
                buildEditableProfileItem("Email", _emailController),
                const SizedBox(height: 10.0),
                buildEditableProfileItem("Phone", _phoneController),
                const SizedBox(height: 10.0),
                buildEditableProfileItem("Address", _addressController),
                const SizedBox(height: 10),
                buildStatusToggle(),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEditableProfileItem(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF232d4b)),
          prefixIcon: Icon(
            _getIconForLabel(label),
            color: Color(0xFF232d4b),
          ),
          filled: true,
          fillColor: Colors.white70,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF232d4b), width: 3.0),
          ),
        ),
        style: const TextStyle(color: Color(0xFF232d4b)),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $label';
          }
          return null;
        },
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Name':
        return Icons.person;
      case 'Email':
        return Icons.email;
      case 'Phone':
        return Icons.phone;
      case 'Address':
        return Icons.home;
      default:
        return Icons.text_fields;
    }
  }

  Widget buildStatusToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ToggleButtons(
            borderColor: Colors.black,
            fillColor: const Color(0xFF00aa9b),
            borderWidth: 3,
            selectedBorderColor: Colors.black,
            selectedColor: Colors.white,
            borderRadius: BorderRadius.circular(10),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Passenger', style: TextStyle(fontSize: 16)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Driver', style: TextStyle(fontSize: 16)),
              ),
            ],
            isSelected: [_statusIndex == 0, _statusIndex == 1],
            onPressed: (int newIndex) {
              setState(() {
                if (_statusIndex == 0 && newIndex == 1) {
                  _showAddCarDialog();
                }
                _statusIndex = newIndex;
              });
            },
          ),
        ],
      ),
    );
  }

  // Function to handle logout action.
  logout() async {
    questionDialog(
      context: context,
      title: "Logout",
      content: "Are you sure want to logout from your account?",
      func: () async {
        // Your logout logic here
        firebaseAuth.signOut().then((value) {
          Navigator.push(context,
              MaterialPageRoute(builder: (c) => const LoginScreen()));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You are successfully logged out."),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  // Builds the logout button.
  Widget buildLogoutButton() {
    return ElevatedButton(
      onPressed: logout,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        foregroundColor: Colors.white,
        elevation: 10,
        backgroundColor: Colors.red,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.logout_outlined, size: 28),
          Gap(10),
          Text(
            "Log Out",
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
