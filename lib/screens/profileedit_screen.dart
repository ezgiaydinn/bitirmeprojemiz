// lib/screens/profileedit_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  /// Dışarıdan gelen kullanıcı ID’si
  final String userId;

  const EditProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String name = "";
  String email = "";
  String password = "";
  bool isLoading = true;
  File? profileImage;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final id = widget.userId;
    if (id.isEmpty) {
      showSnack("User not logged in", isError: true);
      return;
    }

    final response = await http.get(
      Uri.parse("http://192.168.1.30:3000/api/user/$id"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        name = data["name"] ?? "";
        email = data["email"] ?? "";
        password = data["password"] ?? "";
        isLoading = false;
      });
    } else {
      showSnack("Failed to load profile", isError: true);
    }
  }

  Future<void> updateProfile(String field, String value) async {
    const apiUrl = 'http://192.168.1.30:3000/api/updateProfile';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": widget.userId,
        "field": field,
        "value": value,
      }),
    );
    if (response.statusCode == 200) {
      showSnack("$field updated successfully ✅");
    } else {
      showSnack("Failed to update $field", isError: true);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => profileImage = File(picked.path));

    final uri = Uri.parse("http://192.168.1.30:3000/api/uploadProfileImage");
    final req = http.MultipartRequest('POST', uri)
      ..fields['userId'] = widget.userId
      ..files.add(await http.MultipartFile.fromPath('image', picked.path));

    final res = await req.send();
    if (res.statusCode == 200) {
      showSnack("Profile photo updated ✅");
    } else {
      showSnack("Failed to upload photo", isError: true);
    }
  }

  void showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEditPasswordSheet() {
    String current = "", newPass = "", confirm = "";
    bool obscureOld = true, obscureNew = true, obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20, left: 20, right: 20,
        ),
        child: StatefulBuilder(
          builder: (_, setModal) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Edit Password", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                obscureText: obscureOld,
                onChanged: (v) => current = v,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  suffixIcon: IconButton(
                    icon: Icon(obscureOld ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setModal(() => obscureOld = !obscureOld),
                  ),
                ),
              ),
              TextField(
                obscureText: obscureNew,
                onChanged: (v) => newPass = v,
                decoration: InputDecoration(
                  labelText: "New Password",
                  suffixIcon: IconButton(
                    icon: Icon(obscureNew ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setModal(() => obscureNew = !obscureNew),
                  ),
                ),
              ),
              TextField(
                obscureText: obscureConfirm,
                onChanged: (v) => confirm = v,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  suffixIcon: IconButton(
                    icon: Icon(obscureConfirm ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setModal(() => obscureConfirm = !obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (current != password) {
                    Navigator.pop(context);
                    return showSnack("Current password incorrect ❌", isError: true);
                  }
                  if (newPass.length < 6 || newPass != confirm) {
                    Navigator.pop(context);
                    return showSnack("Password mismatch or too short ❌", isError: true);
                  }
                  setState(() => password = newPass);
                  updateProfile("password", newPass);
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value, IconData icon, VoidCallback onEdit) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
      trailing: IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
    );
  }

  void _showEditBottomSheet({
    required String title,
    required String currentValue,
    required Function(String) onSave,
  }) {
    final ctrl = TextEditingController(text: currentValue);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20, left: 20, right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Edit $title", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: ctrl, decoration: InputDecoration(labelText: title)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final val = ctrl.text.trim();
                Navigator.pop(context);
                onSave(val);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFFA2D9FF),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        children: [
          Center(
            child: GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey[300],
                backgroundImage: profileImage != null
                    ? FileImage(profileImage!)
                    : const AssetImage("assets/default_avatar.png")
                as ImageProvider,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 20),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          _buildProfileItem("Name", name, Icons.person, () {
            _showEditBottomSheet(
              title: "Name",
              currentValue: name,
              onSave: (val) {
                setState(() => name = val);
                updateProfile("name", val);
              },
            );
          }),
          _buildProfileItem("Email", email, Icons.email, () {
            _showEditBottomSheet(
              title: "Email",
              currentValue: email,
              onSave: (val) {
                setState(() => email = val);
                updateProfile("email", val);
              },
            );
          }),
          _buildProfileItem("Password", "********", Icons.lock, _showEditPasswordSheet),
        ],
      ),
    );
  }
}
