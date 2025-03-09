import 'package:flutter/material.dart';
import 'package:job_task/firebase/firestore.dart';
import 'package:job_task/main.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedGender;
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (globalUser != null) {
      _firstNameController.text = globalUser!.firstName;
      _lastNameController.text = globalUser!.lastName;
      _dobController.text = globalUser!.dateOfBirth;
      _selectedGender =
          ['Male', 'Female', 'Other'].contains(globalUser!.gender)
              ? globalUser!.gender
              : null;
      _selectedCountry =
          ['India', 'USA', 'UK', 'Canada'].contains(globalUser!.country)
              ? globalUser!.country
              : null;
    }
  }

  void _updateProfile() async {
    globalUser?.setFirstName(_firstNameController.text);
    globalUser?.setLastName(_lastNameController.text);
    globalUser?.setDateOfBirth(_dobController.text);
    globalUser?.setGender(_selectedGender ?? '');
    globalUser?.setCountry(_selectedCountry ?? '');
    await fireStoreUpdateUser();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_firstNameController, 'First Name'),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: _buildTextField(_lastNameController, 'Surname'),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              _buildTextField(_dobController, 'Date of Birth'),
              const SizedBox(height: 10.0),
              _buildDropdown(
                'Gender',
                ['Male', 'Female', 'Other'],
                _selectedGender,
                (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 10.0),
              _buildDropdown(
                'Country',
                ['India', 'USA', 'UK', 'Canada'],
                _selectedCountry,
                (value) => setState(() => _selectedCountry = value),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  'Update Profile',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        labelText: label,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    void Function(String?) onChanged,
  ) {
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
      onChanged: onChanged,
    );
  }
}
