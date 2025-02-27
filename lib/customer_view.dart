import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomerView extends StatefulWidget {
  final String? id;
  final String? name;
  final String? mobile;
  final String? email;
  final String? country;
  final String? nationality;
  final String? lang;
  final List<dynamic>? units;

  const CustomerView({
    super.key,
    this.id,
    this.name,
    this.mobile,
    this.email,
    this.country,
    this.nationality,
    this.lang,
    this.units,
  });

  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  bool isEditing = false;
  File? _image;

  final ImagePicker _picker = ImagePicker();

  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController langController = TextEditingController();
  final TextEditingController unitsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    idController.text = widget.id ?? '';
    nameController.text = widget.name ?? '';
    mobileController.text = widget.mobile ?? '';
    emailController.text = widget.email ?? '';
    countryController.text = widget.country ?? '';
    nationalityController.text = widget.nationality ?? '';
    langController.text = widget.lang ?? '';
    unitsController.text = widget.units?.join(", ") ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Customer View', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Align(
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 18,
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Buttons below AppBar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      idController.clear();
                      nameController.clear();
                      mobileController.clear();
                      emailController.clear();
                      countryController.clear();
                      nationalityController.clear();
                      langController.clear();
                      unitsController.clear();
                      setState(() {
                        isEditing = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Create", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text("Edit", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                      });
                      // Save data logic here
                      print("Saved Data:");
                      print("ID: ${idController.text}");
                      print("Name: ${nameController.text}");
                      print("Mobile: ${mobileController.text}");
                      print("Email: ${emailController.text}");
                      print("Country: ${countryController.text}");
                      print("Nationality: ${nationalityController.text}");
                      print("Lang: ${langController.text}");
                      print("Units: ${unitsController.text}");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("Save", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Form View with Card Style
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildTextField("ID", idController),
                      _buildTextField("Name", nameController),
                      _buildTextField("Mobile", mobileController),
                      _buildTextField("Email", emailController),
                      _buildTextField("Country", countryController),
                      _buildTextField("Nationality", nationalityController),
                      _buildTextField("Lang", langController),
                      _buildTextField("Units", unitsController),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        enabled: isEditing,
      ),
    );
  }
}
