// lib/screens/profileedit_screen.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bitirmeprojesi/constant/app_colors.dart';
import 'package:bitirmeprojesi/constant/app_text_style.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  const EditProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late String userId;
  String name = '';
  String email = '';
  String password = '';
  bool isLoading = true;
  File? profileImage;
  final String baseUrl = 'https://projembackend-production-4549.up.railway.app';

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final resp = await http.get(Uri.parse('$baseUrl/api/auth/profile/$userId'));
    if (resp.statusCode == 200) {
      final user = jsonDecode(resp.body)['user'];
      setState(() {
        name = user['name'] ?? '';
        email = user['email'] ?? '';
        password = ''; // şifreyi backend'den çekmiyoruz
        isLoading = false;
      });
    } else {
      showSnack('Profil yüklenemedi', isError: true);
    }
  }

  Future<void> updateProfile(String field, String value) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/api/auth/updateProfile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'field': field, 'value': value}),
    );
    if (resp.statusCode == 200) {
      showSnack('$field başarıyla güncellendi ✅');
    } else {
      showSnack('$field güncellenemedi ❌', isError: true);
    }
  }

  void showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? Colors.redAccent : Colors.deepPurple.shade200,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEditPasswordSheet() {
    String current = '', newPass = '', confirm = '';
    bool obscureOld = true, obscureNew = true, obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final pad = MediaQuery.of(ctx).viewInsets.bottom + 20;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, pad),
          child: StatefulBuilder(
            builder: (ctx2, setM) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Şifreyi Düzenle',
                    style: AppTextStyle.HEADING.copyWith(
                      color: Colors.deepPurple.shade200,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: obscureOld,
                    onChanged: (v) => current = v,
                    decoration: InputDecoration(
                      labelText: 'Mevcut Şifre',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureOld ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setM(() => obscureOld = !obscureOld),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: obscureNew,
                    onChanged: (v) => newPass = v,
                    decoration: InputDecoration(
                      labelText: 'Yeni Şifre',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setM(() => obscureNew = !obscureNew),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: obscureConfirm,
                    onChanged: (v) => confirm = v,
                    decoration: InputDecoration(
                      labelText: 'Şifreyi Onayla',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            () => setM(() => obscureConfirm = !obscureConfirm),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (current != password) {
                        Navigator.pop(ctx2);
                        showSnack('Mevcut şifre yanlış ❌', isError: true);
                        return;
                      }
                      if (newPass.length < 6 || newPass != confirm) {
                        Navigator.pop(ctx2);
                        showSnack(
                          'Şifre uyuşmuyor veya çok kısa ❌',
                          isError: true,
                        );
                        return;
                      }
                      setState(() => password = newPass);
                      await updateProfile('password', newPass);
                      Navigator.pop(ctx2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kaydet',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showEditBottomSheet({
    required String title,
    required String currentValue,
    required ValueChanged<String> onSave,
  }) {
    final ctrl = TextEditingController(text: currentValue);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final pad = MediaQuery.of(ctx).viewInsets.bottom + 20;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, pad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$title Düzenle',
                style: AppTextStyle.HEADING.copyWith(
                  color: Colors.deepPurple.shade200,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  labelText: title,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onSave(ctrl.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kaydet',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(
    String label,
    String value,
    IconData icon,
    VoidCallback onEdit,
  ) {
    final horizontal = MediaQuery.of(context).size.width * 0.05;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 4),
      leading: Icon(icon, color: Colors.deepPurple.shade200),
      title: Text(
        label,
        style: AppTextStyle.BODY.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(value, style: AppTextStyle.BODY),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: Colors.deepPurple.shade200),
        onPressed: onEdit,
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // ekran ölçüleri
    final h = MediaQuery.of(context).size.height;
    final padVmedium = h * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Düzenle'),
        backgroundColor: Colors.deepPurple.shade200,
      ),
      backgroundColor: AppColors.backgroundLight,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: padVmedium),
                child: Column(
                  children: [
                    GestureDetector(
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.18,
                        backgroundColor: Colors.deepPurple.shade200,
                        child: Text(
                          _getInitials(name),

                          /// <<<--- EKLENDİ
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(name, style: AppTextStyle.HEADING),
                    const SizedBox(height: 24),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      child: Column(
                        children: [
                          _buildProfileItem(
                            'Kullanıcı Adı',
                            name,
                            Icons.person,
                            () {
                              _showEditBottomSheet(
                                title: 'Kullanıcı Adı',
                                currentValue: name,
                                onSave: (v) {
                                  setState(() => name = v);
                                  updateProfile('name', v);
                                },
                              );
                            },
                          ),
                          const Divider(height: 0, indent: 72),
                          _buildProfileItem('E-posta', email, Icons.email, () {
                            _showEditBottomSheet(
                              title: 'E-posta',
                              currentValue: email,
                              onSave: (v) {
                                setState(() => email = v);
                                updateProfile('email', v);
                              },
                            );
                          }),
                          const Divider(height: 0, indent: 72),
                          _buildProfileItem(
                            'Şifre',
                            '********',
                            Icons.lock,
                            _showEditPasswordSheet,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
