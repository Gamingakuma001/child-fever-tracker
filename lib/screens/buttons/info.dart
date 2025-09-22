import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _sexController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _contactController = TextEditingController();

  File? _profileImage;
  String? _profileImageUrl;

  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null && data['profile'] != null) {
      final profile = data['profile'];
      _nameController.text = profile['name'] ?? '';
      _ageController.text = profile['age']?.toString() ?? '';
      _sexController.text = profile['sex'] ?? '';
      _parentNameController.text = profile['parentName'] ?? '';
      _contactController.text = profile['contact'] ?? '';
      _profileImageUrl = profile['profileImageUrl'];
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
      await _uploadToCloudinary(_profileImage!);
    }
  }

  Future<void> _uploadToCloudinary(File imageFile) async {
    const cloudName = 'dkfidppml';
    const uploadPreset = 'smilestones';

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);
      final imageUrl = jsonData['secure_url'];

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'profile.profileImageUrl': imageUrl,
      }, SetOptions(merge: true));

      setState(() {
        _profileImageUrl = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo uploaded successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload profile photo.')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'profile': {
        'name': _nameController.text.trim(),
        'age': _ageController.text.trim(),
        'sex': _sexController.text.trim(),
        'parentName': _parentNameController.text.trim(),
        'contact': _contactController.text.trim(),
        'profileImageUrl': _profileImageUrl,
      }
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      appBar: AppBar(
        title: Text('Patient Info', style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF4D8DFF),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.white,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : const AssetImage('assets/placeholder.png') as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickImage,
                child: Text(
                  "Change Profile Photo",
                  style: GoogleFonts.lato(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Profile Information",
                    style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 10),

              _buildTextField(_nameController, 'Name', Icons.person),
              _buildTextField(_ageController, 'Age', Icons.cake, keyboardType: TextInputType.number),
              _buildTextField(_sexController, 'Sex', Icons.wc),
              _buildTextField(_parentNameController, 'Parent Name', Icons.family_restroom),
              _buildTextField(_contactController, 'Contact Number', Icons.phone, keyboardType: TextInputType.phone),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D8DFF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    'Save Profile',
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}
