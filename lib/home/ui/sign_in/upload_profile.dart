import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:job_task/home/ui/home/home.dart';
import 'package:job_task/main.dart';

class UploadProfilePicture extends StatefulWidget {
  const UploadProfilePicture({Key? key}) : super(key: key);

  @override
  _UploadProfilePictureState createState() => _UploadProfilePictureState();
}

class _UploadProfilePictureState extends State<UploadProfilePicture> {
  // State variables
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isImageSelected = false;

  // Constants for styling
  static const double _cardBorderRadius = 20.0;
  static const double _profileImageRadius = 80.0;
  static const double _buttonVerticalPadding = 16.0;
  static const double _horizontalPadding = 24.0;

  /// Picks an image from the gallery and updates the profile picture
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isImageSelected = true;

          // Update global user profile picture if available
          if (globalUser != null) {
            globalUser!.setProfilePictureLink(pickedFile.path);
          }
        });
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: ${e.toString()}')),
      );
    }
  }

  /// Navigates to the home screen
  void _navigateToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFF5F5F5)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_buildSignupSuccessCard()],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the main card with signup success message and profile picture upload
  Widget _buildSignupSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeaderText(),
          const SizedBox(height: 40),
          _buildProfilePictureSelector(),
          const SizedBox(height: 40),
          _buildSuccessButton(),
          const SizedBox(height: 20),
          _buildGoToLoginButton(),
        ],
      ),
    );
  }

  /// Builds the header text section
  Widget _buildHeaderText() {
    return Column(
      children: [
        Text(
          "Thank You",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Thank you for signing up!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  /// Builds the profile picture selection widget
  Widget _buildProfilePictureSelector() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: _profileImageRadius,
          backgroundColor: Colors.grey[200],
          backgroundImage: _image != null ? FileImage(_image!) : null,
          child:
              _image == null
                  ? Icon(
                    Icons.add_photo_alternate,
                    size: 40,
                    color: Colors.grey[600],
                  )
                  : null,
        ),
      ),
    );
  }

  /// Builds the success button
  Widget _buildSuccessButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Implement success action or remove if not needed
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: _buttonVerticalPadding),
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: const Text(
          "Success",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Builds the go to login button
  Widget _buildGoToLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _navigateToHomeScreen,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.black, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(vertical: _buttonVerticalPadding),
        ),
        child: const Text(
          "Go to Login",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
