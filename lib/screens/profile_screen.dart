import 'package:bitirmeprojesi/screens/profileedit_screen.dart';
import 'package:flutter/material.dart';
import 'package:bitirmeprojesi/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String name;
  //final int userId;
  //final String email;

  const ProfileScreen({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFFA2D9FF),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFA2D9FF),
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage("assets/images/avatar.png"),
                ),
                const SizedBox(height: 10),
                Text(
                  "Kullanıcı Adı: $name",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("E-posta: $name", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Help us"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
