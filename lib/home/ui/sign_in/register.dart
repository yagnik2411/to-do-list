import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:job_task/firebase/firestore.dart';
import 'package:job_task/home/ui/home/home.dart';
import 'package:job_task/home/ui/sign_in/upload_profile.dart';
import 'package:job_task/main.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();

  // Dropdown values
  String? _selectedGender;
  String? _selectedCountry;

  // Constants
  static const double _fieldSpacing = 10.0;
  static const double _padding = 20.0;
  static const List<String> _genderOptions = ['Male', 'Female', 'Other'];
  static const List<String> _countryOptions = ['India', 'USA', 'UK', 'Canada'];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    // Clean up controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }

  // Initialize fields if already filled in `globalUser`
  void _initializeFields() {
    if (globalUser != null) {
      _firstNameController.text =
          globalUser!.firstName.isNotEmpty ? globalUser!.firstName : '';
      _lastNameController.text =
          globalUser!.lastName.isNotEmpty ? globalUser!.lastName : '';
      _dobController.text =
          globalUser!.dateOfBirth.isNotEmpty ? globalUser!.dateOfBirth : '';
      _emailController.text =
          globalUser!.email.isNotEmpty ? globalUser!.email : '';
      _selectedGender =
          globalUser!.gender.isNotEmpty ? globalUser!.gender : null;
      _selectedCountry =
          globalUser!.country.isNotEmpty ? globalUser!.country : null;
    }
  }

  // Sign up function
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update global user object
        _updateGlobalUserData();

        // Create Firebase account
        if (globalUser?.login != "facebook" && globalUser?.login != "google") {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
        }

        // Store user data in Firestore
        await fireStoreCreateUser();

        // Navigate to home screen
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UploadProfilePicture()),
        );
      } catch (e) {
        if (!mounted) return;
        _showErrorMessage("Error occurred: $e");
      }
    }
  }

  // Update global user data
  void _updateGlobalUserData() {
    globalUser?.setFirstName(_firstNameController.text);
    globalUser?.setLastName(_lastNameController.text);
    globalUser?.setDateOfBirth(_dobController.text);
    globalUser?.setGender(_selectedGender ?? '');
    globalUser?.setCountry(_selectedCountry ?? '');
    globalUser?.setIsSignIn(true);
    globalUser?.setEmail(_emailController.text);
  }

  // Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Check if social login is being used
  bool get _isSocialLogin =>
      globalUser?.login == "google" || globalUser?.login == "facebook";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(_padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SignUpNameFields(
                firstNameController: _firstNameController,
                lastNameController: _lastNameController,
              ),
              const SizedBox(height: _fieldSpacing),
              SignUpTextField(
                controller: _dobController,
                label: 'Date of Birth',
              ),
              const SizedBox(height: _fieldSpacing),
              SignUpGenderDropdown(
                items: _genderOptions,
                selectedValue: _selectedGender,
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: _fieldSpacing),
              SignUpCountryDropdown(
                items: _countryOptions,
                selectedValue: _selectedCountry,
                onChanged: (value) => setState(() => _selectedCountry = value),
              ),
              const SizedBox(height: _fieldSpacing),
              if (!_isSocialLogin) ...[
                SignUpEmailField(controller: _emailController),
                const SizedBox(height: _fieldSpacing),
                SignUpPasswordFields(
                  passwordController: _passwordController,
                  retypePasswordController: _retypePasswordController,
                ),
              ],
              const SizedBox(height: 20.0),
              SignUpSubmitButton(onPressed: _signUp),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final String? Function(String?)? validator;

  const SignUpTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        labelText: label,
      ),
      validator:
          validator ??
          (value) => value?.isEmpty == true ? '$label is required' : null,
    );
  }
}

class SignUpDropdownBase extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? selectedValue;
  final void Function(String?) onChanged;

  const SignUpDropdownBase({
    Key? key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        labelText: label,
      ),
      value: selectedValue,
      items:
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      validator: (value) => value == null ? 'Please select $label' : null,
      onChanged: onChanged,
    );
  }
}

class SignUpGenderDropdown extends StatelessWidget {
  final List<String> items;
  final String? selectedValue;
  final void Function(String?) onChanged;

  const SignUpGenderDropdown({
    Key? key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignUpDropdownBase(
      label: 'Gender',
      items: items,
      selectedValue: selectedValue,
      onChanged: onChanged,
    );
  }
}

class SignUpCountryDropdown extends StatelessWidget {
  final List<String> items;
  final String? selectedValue;
  final void Function(String?) onChanged;

  const SignUpCountryDropdown({
    Key? key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignUpDropdownBase(
      label: 'Country',
      items: items,
      selectedValue: selectedValue,
      onChanged: onChanged,
    );
  }
}

class SignUpNameFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  static const double _fieldSpacing = 10.0;

  const SignUpNameFields({
    Key? key,
    required this.firstNameController,
    required this.lastNameController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SignUpTextField(
            controller: firstNameController,
            label: 'First Name',
          ),
        ),
        const SizedBox(width: _fieldSpacing),
        Expanded(
          child: SignUpTextField(
            controller: lastNameController,
            label: 'Surname',
          ),
        ),
      ],
    );
  }
}

class SignUpEmailField extends StatelessWidget {
  final TextEditingController controller;

  const SignUpEmailField({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignUpTextField(
      controller: controller,
      label: 'Email',
      validator: _validateEmail,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }
}

class SignUpPasswordFields extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController retypePasswordController;
  static const double _fieldSpacing = 10.0;

  const SignUpPasswordFields({
    Key? key,
    required this.passwordController,
    required this.retypePasswordController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SignUpTextField(
            controller: passwordController,
            label: 'Password',
            obscureText: true,
            validator: _validatePassword,
          ),
        ),
        const SizedBox(width: _fieldSpacing),
        Expanded(
          child: SignUpTextField(
            controller: retypePasswordController,
            label: 'Retype Password',
            obscureText: true,
            validator:
                (value) =>
                    _validateRetypePassword(value, passwordController.text),
          ),
        ),
      ],
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateRetypePassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }
}

class SignUpSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SignUpSubmitButton({Key? key, required this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.black,
      ),
      child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
    );
  }
}
